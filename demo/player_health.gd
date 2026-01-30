extends ProgressBar

func _ready():
	var player_node = get_tree().get_first_node_in_group("player") # get player object on scene tree, actual name may differ
	if player_node:
		player_node.connect("player_health", Callable(self, "_on_player_health_changed")) # assumes player has a signal named player_health representing the current health
		value = player_node.get_health() # initialize progress bar value to player health
		max_value = player_node.get_health()

func _on_player_health_changed(new_health_value: int):
	value = new_health_value
