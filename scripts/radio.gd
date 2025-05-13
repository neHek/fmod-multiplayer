extends Node3D
var power : bool = false
var transmitting : bool = false
var player = null

func _ready():
	await RadioCaster._receiver_spawned(self)
	update.rpc()

func _process(delta):
	pass

@rpc("any_peer","call_local","reliable")
func switch_power():
	power = !power
	if power:
		$PowerLightOFF.visible = false
		$PowerLightON.visible = true
	else:
		$PowerLightOFF.visible = true
		$PowerLightON.visible = false
	update()

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


#
#func _process(delta):
	#if get_multiplayer_authority() == multiplayer.get_unique_id():
		#drain_battery(delta)
		#if power and transmitting:
			#energy -= delta*energy_drain_mod*2
		#elif power:
			#energy -= delta*energy_drain_mod
		#clampf(energy, 0, max_energy)
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
