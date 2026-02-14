extends ProgressBar

func _ready():
	var player_node = get_tree().get_first_node_in_group("player") # get player object on scene tree, actual name may differ
	if player_node:
		if GameState.special_attachment.instantiate() is Jetpack:
			player_node.connect("change_fuel", Callable(self, "_on_player_change_fuel"))
			value = GameState.special_attachment.instantiate().max_fuel # initialize progress bar value to fuel meter
			max_value = GameState.special_attachment.instantiate().max_fuel
		else:
			visible = false

func _on_player_change_fuel(new_meter_value: float):
	value = new_meter_value
