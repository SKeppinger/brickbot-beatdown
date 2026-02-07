extends Control

func _ready():
	if GameState.victory:
		$Label.text = "VICTORY"
	else:
		$Label.text = "GAME OVER"

func _on_button_pressed():
	GameState.reset_to_defaults()
	get_tree().change_scene_to_file("res://GUI/main_menu.tscn")
