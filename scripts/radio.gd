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
