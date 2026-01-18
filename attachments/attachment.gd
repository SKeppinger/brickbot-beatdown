extends StaticBody3D
class_name Attachment

## A rotation value to aim a (tiny) bit toward the player center, given this is an arm attachment
const ARM_ROTATION = PI / 512

## The type (left/right arm or special)
@export var type: Reference.AttachmentType

## A reference to the player
var player = null

## Ready function (get the player reference)
func _ready():
	player = get_tree().get_first_node_in_group("player")

## Override this function with attachment behavior
func do_action():
	pass
