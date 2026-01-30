extends Area3D
class_name Shield

## The shield's lifetime
@export var lifetime = 0.0 # Inherit from attachment

## Shield uptime
var uptime = 0.0

## Process the uptime
func _process(delta):
	uptime += delta
	if uptime >= lifetime:
		queue_free()
