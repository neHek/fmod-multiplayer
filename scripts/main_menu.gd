extends Control
const PORT = 20200
const MAX_CLIENTS = 4
var Address = '127.0.0.1'
var port = 8910
var peer

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	# multiplayer.server_disconnected.connect(_on_server_disconnected)

func peer_connected(id):
	print('Player connected, id: ', id)

func peer_disconnected(id):
	print('Player disconnected, id: ', id)

func connected_to_server():
	print('Connected to server')
	SendPlayerInformation.rpc_id(1, $Name.text, multiplayer.get_unique_id())

func connection_failed():
	print('Connection failed')

@rpc("any_peer")
func SendPlayerInformation(player_name, id):
	if !GameManager.Players.has(id):
		GameManager.Players[id] = {
			"name" : player_name,
			'id' : id
		}
	if multiplayer.is_server():
		for i in GameManager.Players:
			SendPlayerInformation.rpc(GameManager.Players[i].name, i)

@rpc("any_peer", "call_local")
func StartGame():
	var scene = load("res://scenes/main_scene.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide()

func _on_host_button_down():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 4)
	if error != OK:
		print("Can't host: ", error )
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)
	print('Waiting for players')
	SendPlayerInformation($Name.text, multiplayer.get_unique_id())
	

func _on_join_button_down():
	if $IP.text != '':
		Address = $IP.text
	peer = ENetMultiplayerPeer.new()
	peer.create_client(Address, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)


func _on_start_game_button_down():
	StartGame.rpc()
