extends Node

@onready var input = $input
@export_enum('Voice', 'Sphere') var output_choice = 'Sphere'
@onready var output  = null
@export_range(16, 2048) var buffer_size : int
var playback : AudioStreamGeneratorPlayback
var idx : int
var effect : AudioEffectCapture
@export var initialized : bool = false


func _ready():
	match output_choice:
		'Sphere': output = get_tree().get_first_node_in_group('audio_output') 
		'Voice': output = $output
		_: push_error('Audio output is not set in voip_controller.gd')
	set_multiplayer_authority(int($"../../".name))
	output.play()
	print(output)
	playback = output.get_stream_playback()
	if is_multiplayer_authority():
		input.stream = AudioStreamMicrophone.new()
		input.play()
		idx = AudioServer.get_bus_index('Record')
		effect = AudioServer.get_bus_effect(idx, 0)
		initialized = true
	

func _process(_delta : float):
	if not is_multiplayer_authority(): return
	
	if effect.can_get_buffer(buffer_size) and playback.can_push_buffer(buffer_size):
		send_data.rpc(effect.get_buffer(buffer_size))
	effect.clear_buffer()

@rpc("any_peer","call_remote","reliable")
func send_data(data : PackedVector2Array):
	for i in range(0, buffer_size):
		playback.push_frame(data[i])
