extends Node
var audio_muted : bool = false
var main_scene : Node
var RadioTimer : Timer
var player_name : String
var player : Player
var chat_history : Array = []
signal chat_update

func _enter_tree() -> void:
	RadioTimer = create_timer(0.5)
	RadioTimer.name = 'RadioTimer'

@rpc("any_peer","call_local","reliable")
func set_chat_history(history : Array):
	chat_history = history
	chat_update.emit()

func chat_history_append(message : Array):
	chat_history.append(message)
	chat_update.emit()

@rpc("any_peer","call_local","reliable")
func request_chat_history():
	set_chat_history.rpc_id(multiplayer.get_remote_sender_id(), chat_history)

func get_all_resources_in_folder(path):
	var items = {}
	var dir = DirAccess.open(path)
	
	if not dir:
		push_error("Invalid dir: " + path)
		return items  # Return an empty list if the directory is invalid
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if dir.current_is_dir():
			items.merge(get_all_resources_in_folder(path + str(file_name)))
		
		if !file_name.begins_with(".") and file_name.ends_with(".tres"):
			# print('Loaded scene: ', file_name)
			var full_path = path + "/" + file_name
			# Remove .remap extension if present
			if full_path.ends_with(".remap"):
				full_path = full_path.substr(0, full_path.length() - 6)
			# print("Checking path: ", full_path)
			if ResourceLoader.exists(full_path):
				# print("Path exists: ", full_path)
				var res = ResourceLoader.load(full_path)
				if res:
					# print("Loaded resource: ", full_path)
					items[file_name] = res
				else:
					push_error("Failed to load resource: ", full_path)
			else:
				push_error("Resource does not exist: ", full_path)
		file_name = dir.get_next()
	dir.list_dir_end()
	return items

func create_timer(time : float, oneShot : bool = false):
	var timer = Timer.new()
	timer.autostart = true
	timer.name = 'Timer_' + str(time) + ' sec'
	add_child(timer)
	timer.wait_time = time
	timer.one_shot = oneShot
	timer.start()
	return timer

@rpc("any_peer","call_local","reliable")
func sync_position(node : Node, authority : int) -> void:
	var synchronizer : MultiplayerSynchronizer = node.find_child('MultiplayerSynchronizer')
	if synchronizer == null:
		synchronizer = MultiplayerSynchronizer.new()
		synchronizer.name = node.name + '_MultiplayerSynchronizer'
		synchronizer.set_multiplayer_authority(authority)
		node.add_child(synchronizer)
		var config = SceneReplicationConfig.new()
		config.add_property(node.name + ':Sync_Pos')
		config.add_property(node.name + ':rotation')
		synchronizer.set_replication_config(config)
