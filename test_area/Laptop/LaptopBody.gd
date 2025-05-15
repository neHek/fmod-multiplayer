extends StaticBody3D
var player_cam
var player
var inventory_ui
@onready var gui_3d: Node3D = $"../gui3d"

# FIXME: Input breaks after quitting the laptop. Disable RMB?
# HACK: ----------------Will not work in multiplayer!----------------------------
func _ready():
	player = get_tree().get_first_node_in_group('player')
	player_cam = get_viewport().get_camera_3d()
	inventory_ui = get_tree().get_first_node_in_group('inventory_ui')
	

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


func handle_input():
	if Input.is_action_just_pressed("exit"):
		gui_3d.active = false
		player_cam.current = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		#$"../gui3d".mouse_entered = false
		inventory_ui.visible = true
