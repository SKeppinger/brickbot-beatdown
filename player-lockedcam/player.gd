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
		## Camera Lock
		look_at(target.global_position, up_direction)
		## So, Godot has this look_at function, which is OBVIOUSLY the first thing I tried to do for target locking
		## and for some reason, at first, it was cooked. It would not do what I wanted no matter what. So I went on
		## a whole math journey to try and do what this function was doing manually. Then I scrapped that and
		## tried to just reconfigure the movement to do this on its own, with a bit of the angle math I did. But
		## by changing the movement to operate on the target position rather than the current facing direction, I
		## realized that was the problem with using look_at all along, so now the solution is 1 line long and I feel
		## very silly :(
