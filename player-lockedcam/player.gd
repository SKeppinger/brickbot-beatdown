extends CharacterBody3D
class_name PlayerLockedCam

@export var target: Node3D

const SPEED = 10.0

@onready var facing = $CollisionShape3D/FacingDirection
@onready var camera_pivot = $CameraPivot

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if not GameState.paused:
			GameState.paused = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			GameState.paused = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(_delta):
	if not GameState.paused:
		## Player Input
		var input_dir = Input.get_vector("move_left", "move_right", "move_backward", "move_forward")
		## Camera Lock
		look_at(target.global_position, up_direction)
		## Player Movement
		var direction_facing = (global_position.direction_to(target.global_position) * input_dir.y).normalized()
		var direction_strafe = (global_position.direction_to(target.global_position).cross(up_direction)) * input_dir.x
		var direction = direction_facing + direction_strafe
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
		move_and_slide()
