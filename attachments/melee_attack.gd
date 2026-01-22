extends Area3D
class_name MeleeAttack

## Attack lifetime (in case of no collision)
@export var lifetime = 0.25

## Attack source
@export var source: Reference.Source

## Attack uptime
var uptime = 0.0

## Ready (set collision mask)
func _ready():
	## If fired by player, search for enemies
	if source == Reference.Source.Player:
		set_collision_mask_value(2, true)
	## Otherwise, search for player
	else:
		set_collision_mask_value(1, true)

## Process the uptime
func _process(delta):
	uptime += delta
	if uptime >= lifetime:
		queue_free()

## Collision handling
func _on_body_entered(body):
	## TODO: differentiate between enemy/player
	if body.has_method("hurt"):
		body.hurt()
	queue_free()
