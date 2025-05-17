extends Control
@onready var messageLine: LineEdit = $VBoxContainer/MarginContainer/HBoxContainer/Message
@onready var chat: VBoxContainer = $VBoxContainer/ScrollContainer/Chat
@onready var chat_message_scene : PackedScene = load("res://test_area/Laptop/chat_message.tscn")

func _ready():
	Global.chat_update.connect(refresh_chat.bind())
	sync_chat()

func _on_send_pressed() -> void:
	if messageLine.text == '': return
	if !multiplayer.is_server(): 
		send_message_to_server.rpc_id(1, Global.player_name, Time.get_time_string_from_system(), messageLine.text)
	else:
		send_message_to_clients.rpc(Global.player_name, Time.get_time_string_from_system(), messageLine.text)
	messageLine.text = ''

@rpc("any_peer","call_remote","reliable")
func send_message_to_server(player_name : String, time : String, message : String):
	send_message_to_clients.rpc(player_name, time, message)

@rpc("any_peer","call_local","reliable")
func send_message_to_clients(player_name : String, time : String, message : String):
	var new_message = chat_message_scene.instantiate()
	new_message.setup(player_name, time, message)
	chat.add_child(new_message)
	Global.chat_history_append([player_name, time, message])

func create_message(player_name : String, time : String, message : String):
	var new_message = chat_message_scene.instantiate()
	new_message.setup(player_name, time, message)
	chat.add_child(new_message)

func sync_chat():
	Global.request_chat_history.rpc_id(1)

func refresh_chat():
	for child in chat.get_children():
		chat.remove_child(child)
	for i in Global.chat_history:
		create_message(i[0], i[1], i[2])
