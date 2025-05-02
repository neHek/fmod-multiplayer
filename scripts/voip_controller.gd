extends Node

@onready var input = $input
@export_enum('Voice', 'Sphere') var output_choice : String
@onready var current_output  = null
@export_range(16, 2048) var buffer_size : int
var current_playback : AudioStreamGeneratorPlayback
var idx : int
var effect : AudioEffectCapture
@export var initialized : bool = false
var playback_list : Dictionary


func _ready():
	playback_list['Voice'] = $output
	playback_list['Sphere'] = get_tree().get_first_node_in_group('audio_output')
	
	match output_choice:
		'Voice': current_output = playback_list['Voice']
		'Sphere': current_output = playback_list['Sphere']
		_: push_error('Audio output is not set in voip_controller.gd')
	set_multiplayer_authority(int($"../../".name))
	current_output.play()
	print(current_output)
	current_playback = current_output.get_stream_playback()
	if is_multiplayer_authority():
		input.stream = AudioStreamMicrophone.new()
		input.play()
		idx = AudioServer.get_bus_index('Record')
		effect = AudioServer.get_bus_effect(idx, 0)
		initialized = true
	

func _process(_delta : float):
	if not is_multiplayer_authority(): return
	
	if effect.can_get_buffer(buffer_size) and current_playback.can_push_buffer(buffer_size):
		send_data.rpc(effect.get_buffer(buffer_size))
	effect.clear_buffer()
	
	# Switching to radio
	if Input.is_action_just_pressed("switch_radio"):
		if output_choice == 'Voice':
			output_choice = 'Sphere'
			switch_output.rpc('Sphere')
		elif output_choice == 'Sphere':
			output_choice = 'Voice'
			switch_output.rpc('Voice')

@rpc("any_peer","call_remote","reliable")
func send_data(data : PackedVector2Array):
	for i in range(0, buffer_size):
		current_playback.push_frame(data[i])

@rpc("any_peer","call_remote","reliable")
func switch_output(output_name : String):
	current_output.stop()
	current_output = playback_list[output_name]
	current_output.play()
	current_playback = playback_list[output_name].get_stream_playback()
