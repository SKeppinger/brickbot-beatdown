extends Node2D

## Just gonna do this the quick and dirty way for now
## TODO: THIS WILL BE DONE MORE SENSIBLY IN THE FUTURE
@onready var left_arm_dropdown = $"Left arm weapon"
@onready var right_arm_dropdown = $"Right arm weapon"
@export var attachment_1: PackedScene
@export var attachment_2: PackedScene
@export var attachment_3: PackedScene
@export var attachment_4: PackedScene
@export var attachment_5: PackedScene
func get_attachments_from_dropdowns():
	var attachments = [] #left then right
	var l = null
	var r = null
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
	return attachments

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_fight_pressed() -> void:
	if left_arm_dropdown.get_selected_id() and right_arm_dropdown.get_selected_id():
		print(left_arm_dropdown.get_selected_id())
		print(right_arm_dropdown.get_selected_id())
		GameState.left_arm = get_attachments_from_dropdowns()[0]
		GameState.right_arm = get_attachments_from_dropdowns()[1]
		get_tree().change_scene_to_file("res://demo/demo_arena.tscn")


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://GUI/options.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()
