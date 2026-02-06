extends ProgressBar

func _ready():
	var player_node = get_tree().get_first_node_in_group("player") # get player object on scene tree, actual name may differ
	if player_node:
		player_node.connect("change_sprint", Callable(self, "_on_player_change_sprint"))
		value = player_node.MAX_SPRINT # initialize progress bar value to sprint meter
		max_value = player_node.MAX_SPRINT

func _on_player_change_sprint(new_meter_value: float):
	value = new_meter_value
	print(value)
