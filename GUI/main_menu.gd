extends Node2D

## Just gonna do this the quick and dirty way for now
## TODO: THIS WILL BE DONE MORE SENSIBLY IN THE FUTURE
@onready var left_arm_dropdown = $"Left arm weapon"
@onready var right_arm_dropdown = $"Right arm weapon"
@onready var special_dropdown = $SpecialAttachment
@export var attachment_1: PackedScene
@export var attachment_2: PackedScene
@export var attachment_3: PackedScene
@export var attachment_4: PackedScene
@export var attachment_5: PackedScene
@export var special_1: PackedScene
@export var special_2: PackedScene
func get_attachments_from_dropdowns():
	var attachments = [] #left then right then special
	var l = null
	var r = null
	var s = null
	match left_arm_dropdown.get_selected_id():
		1:
			l = attachment_1
		2:
			l = attachment_2
		3:
			l = attachment_3
		4:
			l = attachment_4
		5:
			l = attachment_5
	attachments.append(l)
	match right_arm_dropdown.get_selected_id():
		1:
			r = attachment_1
		2:
			r = attachment_2
		3:
			r = attachment_3
		4:
			r = attachment_4
		5:
			r = attachment_5
	attachments.append(r)
	match special_dropdown.get_selected_id():
		1:
			s = special_1
		2:
			s = special_2
	attachments.append(s)
	return attachments

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$SensitivityLabel.text = "Camera Sensitivity: " + str(GameState.sensitivity)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_fight_pressed() -> void:
	if left_arm_dropdown.get_selected_id() != 0 and right_arm_dropdown.get_selected_id() != 0 and special_dropdown.get_selected_id() != 0:
		print(left_arm_dropdown.get_selected_id())
		print(right_arm_dropdown.get_selected_id())
		GameState.left_arm = get_attachments_from_dropdowns()[0]
		GameState.right_arm = get_attachments_from_dropdowns()[1]
		GameState.special_attachment = get_attachments_from_dropdowns()[2]
		get_tree().change_scene_to_file("res://demo/demo_arena.tscn")


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://GUI/options.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_sensitivity_slider_value_changed(value):
	$SensitivityLabel.text = "Camera Sensitivity: " + str(value)
	GameState.sensitivity = value
