extends Attachment
class_name DashBoots

@export var dash_speed: float
@export var dash_time: float

func do_action():
	player.dash(dash_speed, dash_time)
