extends Control
const PORT = 20200
const MAX_CLIENTS = 4
var Address = '127.0.0.1'
var port = 8910
var peer

@onready var logNode = $Log
@export_category('Debug')
@export var autoconnect : bool = false


#signal player_connected(peer_id, player_info)
#signal player_disconnected(peer_id)
#signal server_disconnected

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.main_scene = self
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	# multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	if autoconnect:
		logNode.text += 'Autoconnecting...\n'
		for argument in OS.get_cmdline_args():
			if argument == '--host':
				_on_host_button_down()
			elif argument == '--client':
				DisplayServer.window_set_current_screen(2)
				var timer = Timer.new()
				timer.wait_time = .5
				timer.one_shot = true
				add_child(timer)
				timer.start()
				await timer.timeout
				_on_join_button_down()
				timer.start()
				await timer.timeout
				_on_start_game_button_down()
				



func peer_connected(id):
	print('Player connected, id: ', id)
	if multiplayer.is_server():
		logNode.text += 'Player joined, id: ' + str(id) + '\n'

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
	$PlayerList.text = '[center][b]Players[/b][/center]\n'
	for player in GameManager.Players:
		if GameManager.Players[player]['id'] == 1: $PlayerList.text += '(host)'
		$PlayerList.text += '[color=green]' + GameManager.Players[player]['name'] + ' id: ' + str(GameManager.Players[player]['id']) + '[/color]\n'
	if multiplayer.is_server():
		for i in GameManager.Players:
			SendPlayerInformation.rpc(GameManager.Players[i].name, i)

@rpc("any_peer", "call_local")
func StartGame():
	var scene = load("res://scenes/main_scene.tscn").instantiate()
	$'..'.add_child(scene)
	self.hide()

func _on_host_button_down():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 4)
	if error != OK:
		logNode.text += "Can't host, error: " + str(error) + '\n'
		print("Can't host: ", error )
		return
	else:
		logNode.text += '[color=green]Server started, port: ' + str(port) + '[/color]\n'
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	SendPlayerInformation($Name.text, multiplayer.get_unique_id())
	

func _on_join_button_down():
	if $IP.text != '':
		Address = $IP.text
	peer = ENetMultiplayerPeer.new()
	var _error = peer.create_client(Address, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	logNode.text += 'Trying to join at ' + str(Address,':',port) + '\n'


func _on_start_game_button_down():
	StartGame.rpc()
