extends Attachment
class_name ShieldAttachment

## The cooldown
@export var shield_cooldown = 0.2

## The shield object
@export var shield: PackedScene

## The pivot for rotation
@onready var pivot = $Pivot
## The shield spawn point
@onready var shield_spawn = $Pivot/ShieldSpawn

## Remaining cooldown time
var cooldown = 0.0
## Whether the action is currently held
var action_held = false
## Whether the shield is currently up
var shield_up = false

## Process the cooldown timer and reset rotation
func _process(delta):
	if cooldown > 0.0:
		cooldown -= delta
	else:
		cooldown = 0.0
		if not action_held:
			pivot.rotation = Vector3.ZERO
			shield_up = false
		action_held = false

## Hold up a shield
func do_action():
	## Aim slightly towards player center
	if type == Reference.AttachmentType.LeftArm:
		pivot.rotation.y = -50 * ARM_ROTATION
	elif type == Reference.AttachmentType.RightArm:
		pivot.rotation.y = 50 * ARM_ROTATION
	## Face the vertical direction the player is aiming (even if on cooldown)
	## TODO: animate this gradually or add a button to "line up" your arm attachments
	##		or automatically line up if locked onto the target?
	pivot.rotation.x = (PI / 2) + (player.get_camera_pivot() * VRATIO)
	if not shield_up:
		shield_up = true
	action_held = true
	## Lock movement
	player.lock_movement(shield_cooldown)
	## If the cooldown is over
	if cooldown <= 0.0:
		## Spawn shield
		var shld = shield.instantiate()
		shld.lifetime = shield_cooldown
		#atk.source = Reference.Source.Player
		shield_spawn.add_child(shld)
		
		##play animation test
		#target_anim_player.play("Melee-Left")
		
		## Start the cooldown
		cooldown = shield_cooldown
