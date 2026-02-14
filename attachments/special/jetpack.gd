extends Attachment
class_name Jetpack

@export var max_fuel = 1.0
@export var fly_speed = 10.0

var current_fuel = max_fuel
var flying = false

func _process(delta):
	if not flying:
		current_fuel += delta / 2.0
		if current_fuel > max_fuel:
			current_fuel = max_fuel
		player.change_fuel.emit(current_fuel)
	else:
		flying = false

func do_action():
	flying = true
	if current_fuel > 0.0:
		current_fuel -= get_process_delta_time()
		player.fly(fly_speed)
		player.change_fuel.emit(current_fuel)
