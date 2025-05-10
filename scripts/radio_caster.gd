extends Node3D
@onready var radio = $Radio

var audioStreams = {}
# {'1': {'voice': [], 'env_sound' : [], 'voice_radio' : []}

func _enter_tree():
	set_multiplayer_authority(multiplayer.get_unique_id()) 
	global_position = Vector3(1000,1000,1000)

func fetch(id : int, type : String):
	if audioStreams.has(str(id)):
		if audioStreams.get(str(id)).has(type):
			return audioStreams.get(str(id)).get(type)
	return false

func register(id : int):
	if !audioStreams.has(id):
		audioStreams.set(str(id), {'voice' : [], 'env_sound' : [], 'voice_radio' : []})
	# -----Voice local-----
	var voice = AudioStreamPlayer3D.new()
	voice.stream = AudioStreamGenerator.new()
	voice.set_multiplayer_authority(id)
	voice.name = str(id) + '_voice'
	voice.set_bus('Voice')
	
	# Move to the owner
	
	var players = get_tree().get_nodes_in_group('player')
	var owned_child = null
	for pl in players:
		if pl.name == str(id): owned_child = pl
	if owned_child: 
		if id == multiplayer.get_unique_id():
			voice.volume_db = -80
		owned_child.add_child(voice)
		voice.set_multiplayer_authority(id)
	else: add_child(voice)
	voice.play()
	
	# -----Voice over radio-----
	var voice_radio = AudioStreamPlayer3D.new()
	voice_radio.stream = AudioStreamGenerator.new()
	voice_radio.name = str(id) + '_voiceRad'
	voice_radio.set_bus('Radio')
	radio.add_child(voice_radio)
	voice_radio.play()
	
	# -----Environment sounds over radio-----
	var env_sound = AudioStreamPlayer3D.new()
	env_sound.stream = AudioStreamGenerator.new()
	env_sound.name = str(id) + '_env'
	env_sound.set_bus('Radio')
	radio.add_child(env_sound)
	env_sound.play()
	 
	audioStreams[str(id)].voice.append(voice.get_stream_playback())  
	audioStreams[str(id)].env_sound.append(env_sound.get_stream_playback())  
	audioStreams[str(id)].voice_radio.append(voice_radio.get_stream_playback())  
	#audioStreams.set(str(id), {'voice' : voice.get_stream_playback(), 'env_sound' : env_sound.get_stream_playback(), 'voice_radio' : voice_radio.get_stream_playback()} ) 

func broadcast_radio(id : int, types : String, data : PackedVector2Array) -> void:
	if !audioStreams.has(str(id)): return
	var types_arr = types.split(',', false)
	for type in types_arr:
		var audio_players = audioStreams[str(id)][type]
		for i in range(0, data.size()):
			for player in audio_players:
				player.push_frame(data[i])
		

func _receiver_spawned(rad : Node):
	await get_tree().create_timer(1.0).timeout
	for playerID in audioStreams:
		# ---Spawning Voice players---
		var voice_radio_player = AudioStreamPlayer3D.new()
		voice_radio_player.name = playerID + '_voice_rad'
		voice_radio_player.stream = AudioStreamGenerator.new()
		rad.get_node('Streams').add_child(voice_radio_player)
		voice_radio_player.set_bus('Radio')
		voice_radio_player.play()
		var playback = voice_radio_player.get_stream_playback()
		audioStreams[playerID].voice_radio.append(playback)
		
		# ---Spawning Env players---
		var env_player = AudioStreamPlayer3D.new()
		env_player.name = playerID + '_env'
		env_player.stream = AudioStreamGenerator.new()
		rad.get_node('Streams').add_child(env_player)
		env_player.set_bus('Radio')
		env_player.play()
		var playback_env = env_player.get_stream_playback()
		audioStreams[playerID].env_sound.append(playback_env)
	return true
