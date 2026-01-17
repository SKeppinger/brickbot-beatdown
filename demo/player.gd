extends CharacterBody3D
class_name Player

const SPEED = 10.0
const SPRINT_SPEED = 18.0
const JUMP_SPEED = 15.0
const GRAVITY = -30.0
const CAMLOCK_SPEED = 8.0
const CAMLOCK_VRATIO = 0.1
const CAMLOCK_MINDIST = 1.5
const CAMLOCK_MARGIN = 0.02
const CAM_SENS = 0.001
const VCAM_RANGE = PI / 4 # This is the maximum vertical camera rotation, in radians

@onready var facing = $CollisionShape3D/FacingDirection
@onready var camera_pivot = $CameraPivot
@onready var default_camera_pivot = camera_pivot.rotation

var move_direction = Vector2.ZERO
var locked_on = false
var target = null

## Ready (capture mouse)
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

## Input (camera movement)
func _input(event):
	if not GameState.paused:
		## Camera Movement
		if not locked_on and event is InputEventMouseMotion:
			var mouse_motion_h = -1 * event.screen_relative.x * CAM_SENS
			rotation += Vector3(0, mouse_motion_h, 0)
			var mouse_motion_v = event.screen_relative.y * CAM_SENS
			camera_pivot.rotation += Vector3(mouse_motion_v, 0, 0)
			if abs(camera_pivot.rotation.x) > VCAM_RANGE:
				camera_pivot.rotation.x = sign(camera_pivot.rotation.x) * VCAM_RANGE

## Process
func _process(_delta):
	## Pause
	if Input.is_action_just_pressed("ui_cancel"):
		if not GameState.paused:
			GameState.paused = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			GameState.paused = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	## Other Actions
	else:
		## Target Lock
		if Input.is_action_just_pressed("target_lock"):
			if locked_on:
				target = null
				locked_on = false
			else:
				lock_on()

## Physics process
func _physics_process(delta):
	if not GameState.paused:
		## Player Movement
		var input_dir = Input.get_vector("move_left", "move_right", "move_backward", "move_forward")
		var facing_direction = facing.to_global(Vector3.ZERO).direction_to(facing.to_global(facing.target_position.normalized()))
		var direction_strafe = (facing_direction.cross(up_direction) * input_dir.x).normalized()
		var direction_facing = (facing_direction * input_dir.y).normalized()
		move_direction = direction_facing + direction_strafe
		if not is_on_floor():
			# TODO: Maybe disallow the changing of forward/backward momentum while in the air
			velocity.y += GRAVITY * delta
		else:
			if Input.is_action_just_pressed("jump"):
				velocity.y = JUMP_SPEED
			else:
				velocity.y = 0
		if move_direction:
			velocity.x = move_direction.x * SPEED
			velocity.z = move_direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
		move_and_slide()
		
		## Camera Lock
		if locked_on:
			## Horizontal rotation
			var target_distance = (Vector2(global_position.x, global_position.z) - Vector2(target.global_position.x, target.global_position.z)).length()
			var current_rotation = rotation
			if target_distance >= CAMLOCK_MINDIST:
				look_at(target.global_position, up_direction)
				var target_rotation = rotation
				rotation = current_rotation
				var rotation_diff = rotation.y - target_rotation.y
				if rotation_diff > PI or rotation_diff < -1 * PI:
					rotation.y = lerp(rotation.y, PI * sign(rotation_diff), delta * CAMLOCK_SPEED)
					if abs(rotation.y) >= PI - CAMLOCK_MARGIN:
						rotation.y = PI * sign(rotation_diff)
				else:
					rotation.y = lerp(rotation.y, target_rotation.y, delta * CAMLOCK_SPEED)
			## Vertical rotation
			var height_diff = target.global_position.y - global_position.y
			camera_pivot.rotation.x = lerp(camera_pivot.rotation.x, height_diff * CAMLOCK_VRATIO, delta * CAMLOCK_SPEED)
			if abs(camera_pivot.rotation.x) > VCAM_RANGE:
				camera_pivot.rotation.x = sign(camera_pivot.rotation.x) * VCAM_RANGE

## Lock on to target
func lock_on():
	camera_pivot.rotation = default_camera_pivot
	target = get_tree().get_first_node_in_group("enemy") # TODO: Multiple enemies?
	locked_on = true
