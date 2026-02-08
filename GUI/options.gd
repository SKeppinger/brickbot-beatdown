extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Settings.resolution_idx != null:
		$ResolutionDropdown.selected = Settings.resolution_idx
	$SensitivityLabel.text = "Camera Sensitivity: " + str(GameState.sensitivity)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://GUI/main_menu.tscn")

func _on_sensitivity_slider_value_changed(value):
	$SensitivityLabel.text = "Camera Sensitivity: " + str(value)
	GameState.sensitivity = value


func _on_resolution_dropdown_item_selected(index: int) -> void:
	Settings.resolution_idx = index
	match index:
		0:
			# 1920x1080
			get_window().size = Vector2i(1920, 1080)
		1:
			# 1280x720
			get_window().size = Vector2i(1280, 720)
		2:
			# 1152x648 (godot default project resolution)
			get_window().size = Vector2i(1152, 648)
		3:
			#800x600
			get_window().size = Vector2i(800, 600)
