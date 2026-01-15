extends CharacterBody3D
class_name PlayerSemilockedCam

const SPEED = 10.0
const CAM_SENS = 0.001
const VCAM_RANGE = PI / 4 # This is the maximum vertical camera rotation, in radians

@onready var facing = $CollisionShape3D/FacingDirection
@onready var camera_pivot = $CameraPivot

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if not GameState.paused:
		## Camera Movement
		if event is InputEventMouseMotion:
			var mouse_motion_h = -1 * event.screen_relative.x * CAM_SENS
			rotation += Vector3(0, mouse_motion_h, 0)
			var mouse_motion_v = event.screen_relative.y * CAM_SENS
			camera_pivot.rotation += Vector3(0, 0, mouse_motion_v)
			if abs(camera_pivot.rotation.z) > VCAM_RANGE:
				camera_pivot.rotation.z = sign(camera_pivot.rotation.z) * VCAM_RANGE
		
	## hi steven, i just quickly put in escape key functionality
	## you are the GOAT, but I'm going to put it in the process function bc otherwise it will trigger as long
	## as ESC is held down, not just when it's initially pressed! Also going to add a pause/unpause framework
	## to program defensively

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if not GameState.paused:
			GameState.paused = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			GameState.paused = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

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
