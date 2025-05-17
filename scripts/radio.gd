extends Node3D
var power : bool = false
var transmitting : bool = false
var player = null
var max_energy : float = 100
var energy : float = 30
@onready var power_indicator_root = $PowerIndicator
var energy_drain_mod : float = 3

func _ready():
	await RadioCaster._receiver_spawned(self)
	update.rpc()
	Global.RadioTimer.timeout.connect(update_power_indicator.bind())

func _process(delta):
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		drain_battery(delta)
		if name =='Radio': print(position) #TODO Debug for radio

func drain_battery(time):
	if energy <= 0: 
		set_power.rpc(false)
		stop_transmitting()
		return
	
	if power and transmitting:
		energy -= time*energy_drain_mod*2
	elif power:
		energy -= time*energy_drain_mod
	clampf(energy, 0, max_energy)

func update_power_indicator():
	if power:
		var power_perc: int = (energy / max_energy) * 100
		var power_percentage_per_section : float = 100.0 / power_indicator_root.get_child_count()
		power_perc -= 5
		for section in power_indicator_root.get_children():
			if power_perc > 0:
				section.get_node('Green').visible = true
				section.get_node('Gray').visible = false
				section.get_node('Red').visible = false
				power_perc -= power_percentage_per_section
			else:
				section.get_node('Green').visible = false
				section.get_node('Gray').visible = false
				section.get_node('Red').visible = true
	else:
		for section in power_indicator_root.get_children():
				section.get_node('Green').visible = false
				section.get_node('Gray').visible = true
				section.get_node('Red').visible = false

@rpc("any_peer","call_local","reliable")
func switch_power():
	power = !power
	if power:
		$PowerLightOFF.visible = false
		$PowerLightON.visible = true
		#for power_node in $PowerIndicator.get_children():
			#power_node.mesh.material.set_albedo(Color.GREEN)
	else:
		$PowerLightOFF.visible = true
		$PowerLightON.visible = false
		#for power_node in $PowerIndicator.get_children():
			#power_node.mesh.material.set_albedo(Color.WEB_GRAY)
	update()
	update_power_indicator()

@rpc("any_peer","call_local","reliable")
func set_power(mode : bool = false):
	power = mode
	if power:
		$PowerLightOFF.visible = false
		$PowerLightON.visible = true
	else:
		$PowerLightOFF.visible = true
		$PowerLightON.visible = false
	update()
	update_power_indicator()

@rpc("any_peer","call_local","reliable")
func update():
	if power:
		unmute()
	else:
		mute()
	

func start_transmitting():
	transmitting = true
	if power:
		player.get_node('Anchor/voip_controller').radio_mode = true
		$AudioStreamPlayer3D.play()
		mute.rpc()
	play_animation.rpc('start_transmitting')

func stop_transmitting():
	if transmitting:
		play_animation.rpc('start_transmitting', true)
		if power:
			$AudioStreamPlayer3D.play()
	transmitting = false
	player.get_node('Anchor/voip_controller').radio_mode = false
	unmute.rpc()

@rpc("any_peer","call_local","reliable")
func play_animation(anim_name, reverse = false):
	if !reverse:
		$AnimationPlayer.play(anim_name)
	else:
		$AnimationPlayer.play_backwards(anim_name)
	

@rpc("any_peer","call_local","reliable")
func mute():
	for audioPlayer in $Streams.get_children():
			audioPlayer.volume_db = -80

@rpc("any_peer","call_local","reliable")
func unmute():
	for audioPlayer in $Streams.get_children():
			audioPlayer.volume_db = 0



#func _process(delta):
	#if get_multiplayer_authority() == multiplayer.get_unique_id():
		#drain_battery(delta)
	#
	#if power:
		#var active_power_ind : int = ceil(energy / max_energy * 10)
		#for i in range(10):
			#var power_node : MeshInstance3D = power_indicator_root.get_child(i)
			#if i in range(active_power_ind):
				#power_node.mesh.material.set_albedo(Color.GREEN)
			#else:
				#power_node.mesh.material.set_albedo(Color.RED)
	#else:
		#for i in range(10):
			#var power_node : MeshInstance3D = power_indicator_root.get_child(i)
			#power_node.mesh.material.set_albedo(Color.WEB_GRAY)
#
#@rpc("any_peer","call_local","reliable")
#func drain_battery(time):
	#if energy <= 0: 
		#set_power.rpc(false)
		#return
	#
	#if power and transmitting:
		#energy -= time*energy_drain_mod*2
	#elif power:
		#energy -= time*energy_drain_mod
	#clampf(energy, 0, max_energy)
