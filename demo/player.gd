## This class handles the control of the player; it also contains some functions which allow the
## attachments to access information like: the direction the player is facing, where the camera
## is pointing, etc.
extends CharacterBody3D
class_name Player


const HURT_DURATION = 0.25
const SPEED = 5.0
const SPRINT_SPEED = 10.0
const SPRINT_ACCEL = 1.0
const MAX_SPRINT = 3.0
const SPRINT_REGEN = 0.2
const JUMP_SPEED = 9.0
const GRAVITY = -30.0
const CAMLOCK_BASE_SPEED = 12.0
const CAMLOCK_DBOOST = 5.0
const CAMLOCK_VRATIO = 0.1
const CAMLOCK_MARGIN = 0.05
const CAM_SENS = 0.001
const VCAM_RANGE = PI / 4 # This is the maximum vertical camera rotation, in radians

@export var max_hp = 10


@onready var facing_ray = $CollisionShape3D/FacingDirection
@onready var camera_pivot = $CameraPivot
@onready var camera = $CameraPivot/Camera3D
@onready var default_camera_pivot = camera_pivot.rotation

signal player_health
var hp = max_hp
var is_hurt = false
var hurt_timer = 0.0

var move_direction = Vector3.ZERO
var jump_direction = Vector3.ZERO
var locked_on = false
var target = null
var movement_slowed = false
var slow_speed = 0.0
var ms_timer = 0.0
var movement_locked = false
var ml_timer = 0.0

signal change_sprint
var sprint_meter = MAX_SPRINT

var left_attachment = null
var right_attachment = null
var special_attachment = null

## CONTROL

## Load attachments
# Once attachments are chosen, this function will fill out their references
func load_attachments():
	left_attachment = $LeftArmAttachment.get_child(0)
	left_attachment.type = Reference.AttachmentType.LeftArm
	right_attachment = $RightArmAttachment.get_child(0)
	right_attachment.type = Reference.AttachmentType.RightArm
	## TODO: special attachment and maybe a cleaner way to do this

## Ready (capture mouse)
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if GameState.left_arm and GameState.right_arm:
		var l = GameState.left_arm.instantiate()
		var r = GameState.right_arm.instantiate()
		$LeftArmAttachment.add_child(l)
		$RightArmAttachment.add_child(r)
		load_attachments() ## TEMPORARY FOR TESTING



## Input (camera movement)
func _input(event):
	if not GameState.paused:
		## Camera Movement
		if not locked_on and event is InputEventMouseMotion:
			var mouse_motion_h = -1 * event.screen_relative.x * CAM_SENS * GameState.sensitivity
			rotation += Vector3(0, mouse_motion_h, 0)
			var mouse_motion_v = -1 * event.screen_relative.y * CAM_SENS * GameState.sensitivity
			camera_pivot.rotation += Vector3(mouse_motion_v, 0, 0)
			if abs(camera_pivot.rotation.x) > VCAM_RANGE:
				camera_pivot.rotation.x = sign(camera_pivot.rotation.x) * VCAM_RANGE
		## Capture mouse for web code that i copied from reddit
		if (Input.mouse_mode != Input.MOUSE_MODE_CAPTURED) and event is InputEventMouseButton: 
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

## Process
func _process(delta):
	## Pause
	if Input.is_action_just_pressed("ui_cancel"):
		if not GameState.paused:
			GameState.paused = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			GameState.paused = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	## Other Actions
	elif not GameState.paused:
		## Target Lock
		if Input.is_action_just_pressed("target_lock"):
			if locked_on:
				target = null
				locked_on = false
			else:
				lock_on()
		## Change Shoulder
		if Input.is_action_just_pressed("change_shoulder"):
			camera.position.x *= -1
		## Left Arm
		if left_attachment and Input.is_action_pressed("left_ability"):
			left_attachment.do_action()
		## Right Arm
		if right_attachment and Input.is_action_pressed("right_ability"):
			right_attachment.do_action()
		## Special
		if special_attachment and Input.is_action_pressed("special_ability"):
			pass
		
		## Sprint Meter
		if sprint_meter < MAX_SPRINT:
			if Vector2(velocity.x, velocity.z).length() <= SPEED + SPRINT_ACCEL:
				sprint_meter += SPRINT_REGEN * delta
				change_sprint.emit(sprint_meter)
		
		## Timers
		## Movement slow
		if movement_slowed:
			ms_timer -= delta
		if ms_timer <= 0.0:
			movement_slowed = false
			ms_timer = 0.0
		## Movement lock
		if movement_locked:
			ml_timer -= delta
		if ml_timer <= 0.0:
			movement_locked = false
			ml_timer = 0.0
		## Hurt
		if hurt_timer <= 0.0:
			is_hurt = false
		else:
			hurt_timer -= delta
## Physics process
func _physics_process(delta):
	if not GameState.paused:
		## Player Movement
		var input_dir = Input.get_vector("move_left", "move_right", "move_backward", "move_forward")
		if movement_locked:
			input_dir = Vector2.ZERO
		var facing_direction = get_facing_direction()
		var direction_strafe = (facing_direction.cross(up_direction) * input_dir.x).normalized()
		var direction_fb = (facing_direction * input_dir.y).normalized()
		move_direction = direction_fb + direction_strafe
		
		if not is_on_floor():
			move_direction = jump_direction + direction_strafe
			velocity.y += GRAVITY * delta
		else:
			if Input.is_action_just_pressed("jump"):
				jump_direction = direction_fb
				velocity.y = JUMP_SPEED
			else:
				jump_direction = Vector3.ZERO
				velocity.y = 0
		if move_direction:
			if is_on_floor() and Input.is_action_pressed("sprint") and input_dir.y > 0 and not movement_slowed:
				if sprint_meter > 0.0:
					velocity = Vector3(move_direction.x, 0, move_direction.z).normalized() * move_toward(velocity.length(), SPRINT_SPEED, SPRINT_ACCEL)
					sprint_meter -= delta
					change_sprint.emit(sprint_meter)
					if sprint_meter <= 0.0:
						sprint_meter = -0.5 # sprint exhaustion TODO: make this better
				else:
					velocity = Vector3(move_direction.x, 0, move_direction.z).normalized() * SPEED
			elif is_on_floor() and not movement_slowed:
				velocity = Vector3(move_direction.x, 0, move_direction.z).normalized() * SPEED
			elif is_on_floor() and movement_slowed:
				velocity = Vector3(move_direction.x, 0, move_direction.z).normalized() * slow_speed
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
		move_and_slide()
		
		## Camera Lock
		if not target:
			locked_on = false
		if locked_on:
			## Calculate camera speed
			var dist = global_position.distance_to(target.global_position)
			var cam_speed = CAMLOCK_BASE_SPEED + (CAMLOCK_DBOOST / dist)
			## Horizontal rotation
			var current_rotation = rotation
			look_at(target.global_position, up_direction)
			var target_rotation = rotation
			rotation = current_rotation
			var rotation_diff = rotation.y - target_rotation.y
			if rotation_diff > PI or rotation_diff < -1 * PI:
				rotation.y = lerp(rotation.y, PI * sign(rotation_diff), delta * cam_speed)
				if abs(rotation.y) >= PI - CAMLOCK_MARGIN:
					rotation.y = (PI * sign(rotation_diff))
			else:
				rotation.y = lerp(rotation.y, target_rotation.y, delta * cam_speed)
			## Vertical rotation
			var height_diff = target.global_position.y - global_position.y
			camera_pivot.rotation.x = lerp(camera_pivot.rotation.x, height_diff * CAMLOCK_VRATIO, delta * cam_speed)
			if abs(camera_pivot.rotation.x) > VCAM_RANGE:
				camera_pivot.rotation.x = sign(camera_pivot.rotation.x) * VCAM_RANGE

## Slow movement (for attachments that slow movement)
func slow_movement(speed, duration):
	movement_slowed = true
	slow_speed = speed
	ms_timer = duration

## Lock movement (for attachments that interrupt movement)
func lock_movement(duration):
	movement_locked = true
	ml_timer = duration

## Lock on to target
func lock_on():
	camera_pivot.rotation = default_camera_pivot
	target = get_tree().get_first_node_in_group("enemy") # TODO: Multiple enemies?
	locked_on = true

## Get hurt
func hurt(damage):
	if not is_hurt:
		hp -= damage
		player_health.emit(get_health())
		is_hurt = true
		hurt_timer = HURT_DURATION

## INFORMATION ACCESS

## Get the player's current health
func get_health():
	return hp

## Get the vertical pivot of the camera
# This is used by attachments which point where the player is aiming.
# Under the assumption that attachments will rotate with the player, they should
# theoretically only need this vertical pivot.
func get_camera_pivot():
	return camera_pivot.rotation.x

## Get the movement direction
func get_move_direction():
	return move_direction

## Get the facing direction
func get_facing_direction():
	return facing_ray.to_global(Vector3.ZERO).direction_to(facing_ray.to_global(facing_ray.target_position.normalized()))
