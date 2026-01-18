## This class handles the control of the player; it also contains some functions which allow the
## attachments to access information like: the direction the player is facing, where the camera
## is pointing, etc.
extends CharacterBody3D
class_name Player

const SPEED = 10.0
const SPRINT_SPEED = 18.0
const JUMP_SPEED = 15.0
const GRAVITY = -30.0
const CAMLOCK_SPEED = 8.0
const CAMLOCK_VRATIO = 0.1
const CAMLOCK_MARGIN = 0.05
const CAM_SENS = 0.001
const VCAM_RANGE = PI / 5 # This is the maximum vertical camera rotation, in radians

@onready var facing_ray = $CollisionShape3D/FacingDirection
@onready var camera_pivot = $CameraPivot
@onready var default_camera_pivot = camera_pivot.rotation

var move_direction = Vector3.ZERO
var jump_direction = Vector3.ZERO
var locked_on = false
var target = null

var left_attachment = null
var right_attachment = null
var special_attachment = null

## CONTROL

## Load attachments
# Once attachments are chosen, this function will fill out their references
func load_attachments():
	left_attachment = $LeftArmAttachment.get_child(0)
	left_attachment.type = Reference.AttachmentType.LeftArm
	#right_attachment = $RightArmAttachment.get_child(0)
	#right_attachment.type = Reference.AttachmentType.RightArm
	## TODO: special attachment and maybe a cleaner way to do this

## Ready (capture mouse)
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	load_attachments() ## TEMPORARY FOR TESTING

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
		## Left Arm
		if Input.is_action_pressed("left_ability"):
			left_attachment.do_action()
		## Right Arm
		if Input.is_action_pressed("right_ability"):
			right_attachment.do_action()
		## Special
		if Input.is_action_pressed("special_ability"):
			pass

## Physics process
func _physics_process(delta):
	if not GameState.paused:
		## Player Movement
		var input_dir = Input.get_vector("move_left", "move_right", "move_backward", "move_forward")
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
			if Input.is_action_pressed("sprint") and input_dir.y > 0:
				velocity.x = move_toward(velocity.x, move_direction.x * SPRINT_SPEED, SPEED)
				velocity.z = move_toward(velocity.z, move_direction.z * SPRINT_SPEED, SPEED)
			else:
				velocity.x = move_direction.x * SPEED
				velocity.z = move_direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
		move_and_slide()
		
		## Camera Lock
		if locked_on:
			## Horizontal rotation
			var current_rotation = rotation
			look_at(target.global_position, up_direction)
			var target_rotation = rotation
			rotation = current_rotation
			var rotation_diff = rotation.y - target_rotation.y
			if rotation_diff > PI or rotation_diff < -1 * PI:
				rotation.y = lerp(rotation.y, PI * sign(rotation_diff), delta * CAMLOCK_SPEED)
				if abs(rotation.y) >= PI - CAMLOCK_MARGIN:
					rotation.y = (PI * sign(rotation_diff))
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

## INFORMATION ACCESS

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
