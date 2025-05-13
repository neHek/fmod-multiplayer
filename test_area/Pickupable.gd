extends Node3D
@export var Ui_texture: Texture2D
@onready var pickupable_object = $".."
var main_scene = Global.main_scene
var current_parent = null
var player = null

# Called when the node enters the scene tree for the first time.
func _ready():
	main_scene = Global.main_scene

@rpc("any_peer","call_local","reliable")
func interact(player_name : String):
	player = get_tree().get_nodes_in_group('player')
	for i in player:
		if i.name == player_name:
			player = i
	current_parent = player.find_child('ActiveItemSpot')
	pickupable_object.player = player
	
	var player_check = pickupable_object.get_node('../../..').is_in_group('player')
	if player_check:
		var inventory = pickupable_object.get_node('../../../InventoryNode')
		inventory.remove_item.rpc(pickupable_object.name)
	pickupable_object.get_parent().remove_child(pickupable_object)
	current_parent.add_child(pickupable_object)
	pickupable_object.position = Vector3.ZERO
	pickupable_object.rotation = Vector3.ZERO
	pickupable_object.update.rpc()

@rpc("any_peer","call_local","reliable")
func drop():
	pickupable_object.stop_transmitting()
	pickupable_object.get_node('AnimationPlayer').stop()
	pickupable_object.player = null
	current_parent.remove_child(pickupable_object)
	main_scene.add_child(pickupable_object)
	current_parent = null

func active_item_process():
	if get_multiplayer_authority() != multiplayer.get_unique_id(): return
	
	if Input.is_action_just_pressed('switch_radio'):
		pickupable_object.switch_power.rpc()
	if Input.is_action_just_pressed('LMB'):
		pickupable_object.start_transmitting()
	if Input.is_action_just_released('LMB'):
		pickupable_object.stop_transmitting()
