extends Node

@export var animation_tree: AnimationTree
@onready var player : Player = get_owner()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	var idle = !player.velocity
	
	animation_tree.set("Run", player.velocity.normalized())
	animation_tree.set("Frozen", player.velocity.normalized())
