extends Node
var audio_gens : Dictionary = {}
var voice_playback
var voiceRad_playback
var voice_capture : AudioEffectCapture
var env_capture : AudioEffectCapture
@onready var input = $input
@export_range(16, 2048) var buffer_size : int
var current_playback : AudioStreamGeneratorPlayback
var idx : int
var radio_mode : bool = false
@export var initialized : bool = false
var output_list : Dictionary
@onready var player_name = $"../../".name
var unique_id 

func _ready():
	set_multiplayer_authority(int(player_name))
	RadioCaster.set_multiplayer_authority(int(player_name))
	unique_id = int(player_name)
	if is_multiplayer_authority():
		input.stream = AudioStreamMicrophone.new()
		input.play()
		idx = AudioServer.get_bus_index('Record')
		voice_capture = AudioServer.get_bus_effect(idx, 0)
		initialized = true
		bind_streams.rpc(unique_id)
		
		idx = AudioServer.get_bus_index('Environment')
		env_capture = AudioServer.get_bus_effect(idx, 0)

func _process(_delta : float):
	if not is_multiplayer_authority(): return
	if radio_mode:
		send_voice_stream('voice,voice_radio')
		send_env_stream()
	else:
		send_voice_stream('voice')



@rpc("any_peer","call_local","reliable")
func send_data(sender_id, type, data : PackedVector2Array):
	RadioCaster.broadcast_radio(sender_id, type, data)

@rpc("any_peer","call_local","reliable")
func bind_streams(id):
	RadioCaster.register(id)

func send_voice_stream(mode = 'voice'):
	var buff
	# Receiving the mic input
	if voice_capture.can_get_buffer(buffer_size):
		buff = voice_capture.get_buffer(buffer_size)
		send_data.rpc(unique_id, mode, buff)
		voice_capture.clear_buffer()
	else: return

func send_env_stream():
	var env_buff
	if radio_mode:
		if env_capture.can_get_buffer(buffer_size):
			env_buff = env_capture.get_buffer(buffer_size)
			send_data.rpc(unique_id, 'env_sound', env_buff)
			env_capture.clear_buffer()
	else: return




# Working copy
#extends Node
#
#@onready var input = $input
#@onready var current_output  = null
#@export_range(16, 2048) var buffer_size : int
#var current_playback : AudioStreamGeneratorPlayback
#var idx : int
#var effect : AudioEffectCapture
#var radio_mode : bool = false
#@export var initialized : bool = false
#var output_list : Dictionary
#@onready var player_name = $"../../".name
#
#func _ready():
	#set_multiplayer_authority(int(player_name))
	#output_list['Voice'] = $output
	#output_list['Radio'] = RadioCaster
	#
	#current_output = output_list['Voice']
	#current_output.play()
	#current_playback = current_output.get_stream_playback()
	#if is_multiplayer_authority():
		#input.stream = AudioStreamMicrophone.new()
		#input.play()
		#idx = AudioServer.get_bus_index('Record')
		#effect = AudioServer.get_bus_effect(idx, 0)
		#initialized = true
	#
#
#func _process(_delta : float):
	#if not is_multiplayer_authority(): return
	#
	#if effect.can_get_buffer(buffer_size) and current_playback.can_push_buffer(buffer_size):
		#send_data.rpc(effect.get_buffer(buffer_size))
	#effect.clear_buffer()
	#
	## Switching to radio
	#if Input.is_action_just_pressed("switch_radio"):
		#radio_mode = !radio_mode
#
#
#@rpc("any_peer","call_remote","reliable")
#func send_data(data : PackedVector2Array):
	#for i in range(0, buffer_size):
		#current_playback.push_frame(data[i])
#
#@rpc("any_peer","call_remote","reliable")
#func switch_output(output_name : String):
	#current_output.stop()
	#current_output = output_list[output_name]
	#current_output.play()
	#current_playback = output_list[output_name].get_stream_playback()
