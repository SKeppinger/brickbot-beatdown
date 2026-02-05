extends Attachment
class_name MeleeAttachment

## The animation duration
@export var animation_duration = 0.25

## The cooldown (this includes the animation duration!)
@export var attack_cooldown = 0.4

## The attack object
@export var attack: PackedScene

## animation player test for melee
@export var target_anim_player: AnimationPlayer

## The pivot for rotation
@onready var pivot = $Pivot
## The attack spawn point
@onready var attack_spawn = $Pivot/AttackSpawn

## Remaining cooldown time
var cooldown = 0.0
## Whether the action is currently held
var action_held = false
## Animation Flags
var attackingAnim = false
var rightAttackAnim = false

## Process the cooldown timer/attack motion, and reset rotation
func _process(delta):
	if cooldown > 0.0:
		cooldown -= delta
		attackingAnim = false
		rightAttackAnim = false
	else:
		cooldown = 0.0
		if not action_held:
			pivot.rotation = Vector3.ZERO
		action_held = false
	## If still in the attack animation
	if attack_cooldown - cooldown <= animation_duration:
		## TODO: varied attack animations instead of hard coding
		if type == Reference.AttachmentType.LeftArm:
			pivot.rotation.y = lerp(pivot.rotation.y, 50 * ARM_ROTATION, 0.2)
		elif type == Reference.AttachmentType.RightArm:
			pivot.rotation.y = lerp(pivot.rotation.y, -50 * ARM_ROTATION, 0.2)

		

## Perform a melee attack
func do_action():
	## Only change horizontal rotation if not currently in animation
	if attack_cooldown - cooldown > animation_duration:
		## Aim slightly towards player center
		if type == Reference.AttachmentType.LeftArm:
			pivot.rotation.y = -50 * ARM_ROTATION
			
		elif type == Reference.AttachmentType.RightArm:
			pivot.rotation.y = 50 * ARM_ROTATION
	## Face the vertical direction the player is aiming (even if on cooldown)
	## TODO: animate this gradually or add a button to "line up" your arm attachments
	##		or automatically line up if locked onto the target?
	pivot.rotation.x = (PI / 2) + (player.get_camera_pivot() * VRATIO)
	action_held = true
	## If the cooldown is over
	if cooldown <= 0.0:
		## Lock movement
		player.lock_movement(animation_duration)
		## Spawn melee attack
		var atk = attack.instantiate()
		#atk.source = Reference.Source.Player
		attack_spawn.add_child(atk)
		
		##animations
		attackingAnim = true
		if Input.is_action_just_pressed("left_ability"):
			rightAttackAnim = true;
		
		## Start the cooldown
		cooldown = attack_cooldown
