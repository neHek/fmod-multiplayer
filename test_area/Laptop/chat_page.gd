extends Control
@onready var message: LineEdit = $VBoxContainer/MarginContainer/HBoxContainer/Message
@onready var chat: VBoxContainer = $VBoxContainer/ScrollContainer/Chat
@onready var chat_message_scene : PackedScene = load("res://test_area/Laptop/chat_message.tscn")


func _ready():
	pass

func _on_send_pressed() -> void:
	if message.text == '': return
	var new_message = chat_message_scene.instantiate()
	new_message.setup(Global.player_name, Time.get_time_string_from_system(), message.text)
	chat.add_child(new_message)
	Global.chat_history.append([Global.player_name, Time.get_time_string_from_system(), message.text])
	message.text = ''
