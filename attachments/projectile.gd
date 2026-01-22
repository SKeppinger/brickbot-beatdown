extends StaticBody3D
class_name Projectile

## Projectile lifetime (in case of no collision)
@export var lifetime = 3.0

## Projectile speed
@export var speed = 26.0

## Projectile direction (to be set by source)
@export var direction: Vector3

## Projectile source
@export var source: Reference.Source

## Projectile uptime
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

## Physics process
func _physics_process(delta):
	var collision = move_and_collide(direction * speed * delta)
	if collision:
		## TODO: differentiate between player and enemy
		if collision.get_collider().has_method("hurt"):
			collision.get_collider().hurt()
		queue_free()
