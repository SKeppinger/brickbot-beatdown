extends Attachment
class_name RangedAttachment

## The firing cooldown in seconds
@export var fire_cooldown = 0.25

## The projectile object
@export var projectile: PackedScene

## The pivot for rotation
@onready var pivot = $Pivot
## The projectile spawn point
@onready var proj_spawn = $Pivot/ProjectileSpawn

## Remaining cooldown time
var cooldown = 0.0
## Whether the action is currently held
var action_held = false

## Process the cooldown timer and reset rotation
func _process(delta):
	if cooldown > 0.0:
		cooldown -= delta
	else:
		cooldown = 0.0
	if not action_held:
		pivot.rotation = Vector3.ZERO
	action_held = false

## Fire a projectile
func do_action():
	## Aim slightly towards player center
	if type == Reference.AttachmentType.LeftArm:
		pivot.rotation.y = -1 * ARM_ROTATION
	elif type == Reference.AttachmentType.RightArm:
		pivot.rotation.y = ARM_ROTATION
	## Face the vertical direction the player is aiming (even if on cooldown)
	## TODO: animate this gradually or add a button to "line up" your arm attachments
	##		or automatically line up if locked onto the target?
	pivot.rotation.x = (PI / 2) + player.get_camera_pivot()
	action_held = true
	## If the cooldown is over
	if cooldown <= 0.0:
		## Spawn a projectile
		var proj = projectile.instantiate()
		proj.direction = pivot.global_position.direction_to(proj_spawn.global_position)
		proj.source = Reference.Source.Player
		get_tree().root.add_child(proj)
		proj.global_position = proj_spawn.global_position
		## Start the cooldown
		cooldown = fire_cooldown
