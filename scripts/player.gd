class_name Player extends CharacterBody3D

@export_category("Player")
@export_range(1, 35, 1) var speed: float = 10 # m/s
@export_range(10, 400, 1) var acceleration: float = 100 # m/s^2

@export_range(0.1, 3.0, 0.1) var jump_height: float = 1 # m
@export_range(0.1, 3.0, 0.1, "or_greater") var camera_sens: float = 1

var jumping: bool = false
var mouse_captured: bool = false
@onready var step_emitter = $FmodEventEmitter3D
const stepSoundTimer = 0.3
var currentStepSoundTimer = stepSoundTimer

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var move_dir: Vector2 # Input direction for movement
var look_dir: Vector2 # Input direction for look/aim

var walk_vel: Vector3 # Walking velocity 
var grav_vel: Vector3 # Gravity velocity 
var jump_vel: Vector3 # Jumping velocity
@onready var sync_pos = Vector3.ZERO

@onready var camera: Camera3D = $Anchor/Camera
@onready var anchor = $Anchor

func _ready() -> void:
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())
	capture_mouse()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		look_dir = event.relative * 0.001
		if mouse_captured: _rotate_camera()
	if Input.is_action_just_pressed("jump"): jumping = true
	if Input.is_action_just_pressed("exit"): get_tree().quit()

func _physics_process(delta: float) -> void:
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		sync_pos = global_position
		velocity = _walk(delta) + _gravity(delta) + _jump(delta)
		move_and_slide()
	else:
		global_position = global_position.lerp(sync_pos, 0.1)
	# Processing step sounds
	walking_sound(delta)


func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func _rotate_camera(sens_mod: float = 1.0) -> void:
	rotation.y -= look_dir.x * camera_sens * sens_mod
	anchor.rotation.x = clamp(anchor.rotation.x - look_dir.y * camera_sens * sens_mod, -1.5, 1.5)

func _walk(delta: float) -> Vector3:
	move_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var _forward: Vector3 = camera.global_transform.basis * Vector3(move_dir.x, 0, move_dir.y)
	var walk_dir: Vector3 = Vector3(_forward.x, 0, _forward.z).normalized()
	walk_vel = walk_vel.move_toward(walk_dir * speed * move_dir.length(), acceleration * delta)
	return walk_vel

func _gravity(delta: float) -> Vector3:
	grav_vel = Vector3.ZERO if is_on_floor() else grav_vel.move_toward(Vector3(0, velocity.y - gravity, 0), gravity * delta)
	return grav_vel

func _jump(delta: float) -> Vector3:
	if jumping:
		if is_on_floor(): jump_vel = Vector3(0, sqrt(4 * jump_height * gravity), 0)
		jumping = false
		return jump_vel
	jump_vel = Vector3.ZERO if is_on_floor() else jump_vel.move_toward(Vector3.ZERO, gravity * delta)
	return jump_vel

func walking_sound(delta):
	if walk_vel != Vector3.ZERO and is_on_floor():
		if currentStepSoundTimer <= 0:
			step_emitter.play()
			currentStepSoundTimer = stepSoundTimer
		else:
			currentStepSoundTimer -= delta
	
	if $floorRayCast3D.is_colliding():
		var floor = $floorRayCast3D.get_collider()
		if "SurfaceType" in floor:
			match floor.SurfaceType:
				"Wood": step_emitter.set_parameter("walking_material", 0.2)
				"Grass": step_emitter.set_parameter("walking_material", 0.1)
				"Carpet": step_emitter.set_parameter("walking_material", 0.0)
					
