extends VBoxContainer

@onready var senderNode: Label = $"request head/base request/HBoxContainer/Sender"
@onready var timeNode: Label = $"request head/base request/HBoxContainer/Time"
@onready var messageNode: RichTextLabel = $"request head/base request/Message"

var saved_sender : String
var saved_time : String
var saved_message : String


func setup(sender : String, time : String, message : String) -> void:
	saved_sender = sender
	saved_time = time
	saved_message = message
	name = sender + ' ' + time

func _ready():
	senderNode.text = saved_sender
	timeNode.text = saved_time
	messageNode.text = saved_message
	
