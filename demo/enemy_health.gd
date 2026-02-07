extends ProgressBar

func _ready():
	var enemy_node = get_tree().get_first_node_in_group("enemy") # get player object on scene tree, actual name may differ
	if enemy_node:
		enemy_node.connect("enemy_health", Callable(self, "_on_enemy_health_changed")) # assumes player has a signal named player_health representing the current health
		value = enemy_node.get_health() # initialize progress bar value to player health
		max_value = enemy_node.get_health()

func _on_enemy_health_changed(new_health_value: float):
	value = new_health_value
