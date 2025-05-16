extends StaticBody3D
var player_cam
var player
var inventory_ui
@onready var gui_3d: Node3D = $"../gui3d"


# HACK: ----------------Will not work in multiplayer!----------------------------
func _ready():
	player = Global.player
	player_cam = get_viewport().get_camera_3d()
	if player:
		inventory_ui = player.find_child('InventoryUI')


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	handle_input()

func interact():
	if not player or not player_cam or not inventory_ui:
		_ready()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$"../Camera3D".current = true
	#$"../gui3d".mouse_entered = true
	inventory_ui.visible = false
	gui_3d.active = true
	Global.player.process_mode = Node.PROCESS_MODE_DISABLED


func handle_input():
	if Input.is_action_just_pressed("exit"):
		Global.player.process_mode = Node.PROCESS_MODE_INHERIT
		gui_3d.active = false
		player_cam.current = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		#$"../gui3d".mouse_entered = false
		inventory_ui.visible = true
