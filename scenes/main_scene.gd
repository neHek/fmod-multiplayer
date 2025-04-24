extends Node3D


@export var PlayerScene: PackedScene

func _ready():
	if multiplayer.is_server():
		var spawn_points = get_tree().get_nodes_in_group('PlayerSpawnPoint')
		var index = 0
		for i in GameManager.Players:
			var playerToSpawn = PlayerScene.instantiate()
			var chosen_spawn = spawn_points[index]
			index += 1
			playerToSpawn.name = str(GameManager.Players[i].id)
			add_child(playerToSpawn)
			playerToSpawn.global_position = chosen_spawn.global_position
			print('Player spawned at: ', playerToSpawn.global_position)
			if multiplayer.get_unique_id() != GameManager.Players[i].id:
				playerToSpawn.get_node("Anchor/Camera").current = false
		for player in get_tree().get_nodes_in_group('player'):
			spawn_player.rpc(str(player.name), player.global_position)
			set_player_authority.rpc(str(player.name))
	
@rpc('any_peer')
func spawn_player(player_name, passed_position):
	var playerToSpawn = PlayerScene.instantiate()
	playerToSpawn.name = player_name
	add_child(playerToSpawn)
	playerToSpawn.global_position = passed_position

@rpc("any_peer","call_local")
func set_player_authority(player_name):
	get_node(player_name).set_multiplayer_authority(int(player_name))


#func _ready():
	#var spawnList = get_tree().get_nodes_in_group("PlayerSpawnPoint")
	#for i in GameManager.Players:
		#var currentPlayer = PlayerScene.instantiate()
		#currentPlayer.name = str(GameManager.Players[i].id)
		#add_child(currentPlayer)
		#var spawn = spawnList.pop_front()
		#currentPlayer.global_position = spawn.global_position
		#if multiplayer.get_unique_id() != str(currentPlayer.name).to_int():
			#currentPlayer.get_node("Anchor/Camera").current = false
		#if multiplayer.is_server():
			#PositionPlayers.rpc(str(currentPlayer.name), currentPlayer.global_position)
			#SetAuthority.rpc(str(currentPlayer.name))
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
#
#@rpc("any_peer", "call_local")
#func PositionPlayers(player, global_pos):
	#print('-----')
	#print('Player: ', player, ' new position: ', global_pos)
	#get_node(player).global_position = global_pos
#
#@rpc("any_peer", "call_local")
#func SetAuthority(player):
	#get_node(player).get_node('MultiplayerSynchronizer').set_multiplayer_authority(int(player))
	#print('Authority set for: ', player)
	#print('Peer: ', multiplayer.get_unique_id())
