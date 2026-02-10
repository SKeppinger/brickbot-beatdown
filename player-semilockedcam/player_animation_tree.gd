extends Node

@export var animation_tree: AnimationTree
@onready var player : Player = get_owner()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	var idle = !player.velocity
	
	## animation_tree.set("parameters/RuningBlend/blend_position", player.velocity.normalized())
	animation_tree.set("Frozen", player.velocity.normalized())
	animation_tree.set("Melee-Left Still", player.velocity.normalized())
	## animation_tree.set("parameters/Melee - R - Run/Blend2/blend_amount", player.velocity.normalized())
