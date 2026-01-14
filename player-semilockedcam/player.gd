extends CharacterBody3D
class_name PlayerSemilockedCam

const SPEED = 10.0
const CAM_SENS = 0.001

@onready var facing = $CollisionShape3D/FacingDirection

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	## Camera Movement
	if event is InputEventMouseMotion:
		var mouse_motion = -1 * event.screen_relative.x * CAM_SENS
		rotation += Vector3(0, mouse_motion, 0)
		
	## hi steven, i just quickly put in escape key functionality
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.MOUSE_MODE_CAPTURED

func _physics_process(_delta):
	## Player Movement
	var input_dir = Input.get_vector("move_left", "move_right", "move_backward", "move_forward")
	var facing_direction = facing.to_global(Vector3.ZERO).direction_to(facing.to_global(facing.target_position.normalized()))
	var direction_facing = (facing_direction * input_dir.y).normalized()
	var direction_strafe = (facing_direction.cross(up_direction) * input_dir.x).normalized()
	var direction = direction_facing + direction_strafe
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()
