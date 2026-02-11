extends CharacterBody3D
class_name DemoEnemy

@onready var normal_mesh = $NormalMesh
@onready var hurt_mesh = $HurtMesh
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D

#this means every enemy requires player to be assigned in the editor, find a better solution
@export var player: Player
@export var max_hp = 10
@export var projectile: PackedScene


const SPEED = 2.5
const GRAVITY = -30.0
const HURT_DURATION = 0.25
#I have COPIED this code and I DO NOT understand it.
### The pivot for rotation
#@onready var pivot = $Pivot
### The projectile spawn point
#@onready var proj_spawn = $Pivot/ProjectileSpawn

var direction = Vector3(0, 0, 0)
signal enemy_health
var hp = max_hp
var dir_duration = 0.0
var dir_change_timer = 0.0
var is_hurt = false
var hurt_timer = 0.0
var desired_range = "far"
var target_position = Vector3.ZERO
var attack_cooldown = 1.0
var attack_timer = attack_cooldown
var close_attack_rotation = PI/30
var y_axis = Vector3(0,1,0)
var far_direction_cooldown = 5
@onready var proj_angle = (position.direction_to(player.position)).rotated( y_axis, (PI/4))

#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("ui_accept"):
		#var random_position := Vector3.ZERO
		#random_position.x = randf_range(-5,5)
		#random_position.y = randf_range(-5,5)
		#navigation_agent_3d.set_target_position(random_position)
		
		
func _process(delta):
	#Current desired behaviors: Pick between wanting to be close or far, then attempt to move to that range. Recheck and change every 15? sec
	if dir_change_timer <= 0.0:
		dir_change_timer = 200
		if desired_range == "far":
			desired_range = "close"
			attack_cooldown = 0.2
			var proj_angle = (position.direction_to(player.position)).rotated( y_axis, (PI/4))

		else:
			#for far distance, moves in a direction perpendicular to the line between it and player, in order to be predictable. this is shitass but should work.
			desired_range = "far"
			attack_cooldown = 1
			var far_direction_cooldown = 5
			var random_position := Vector3.ZERO
			random_position.x = randf_range(-5,5) * SPEED
			random_position.y = randf_range(-5,5) * SPEED
			navigation_agent_3d.set_target_position(random_position)
		#print(desired_range)
	else:
		#if desired_range == "close":
			#close_attack_rotation += (PI/8)*delta
		dir_change_timer -= delta
	if desired_range == "far":
		if far_direction_cooldown == 0:
			far_direction_cooldown = 5
			var random_position = Vector3.ZERO
			random_position.x = randf_range(-5,5) * SPEED
			random_position.y = randf_range(-5,5) * SPEED
			navigation_agent_3d.set_target_position(random_position)
		else:
			far_direction_cooldown -= delta
	if attack_timer <= 0:
		if desired_range == "far":
			attack()
		else:
			attack_close()
		attack_timer = attack_cooldown
	else:
		attack_timer -= delta
	#if dir_change_timer <= 0.0:
		#dir_duration = randf_range(0.5, 3.0)
		#dir_change_timer = dir_duration
		#direction.x = randf_range(-1, 1)
		#direction.y = randf_range(-1, 1)
	#else:
		#dir_change_timer -= delta
	
	#Hurt color change
	if hurt_timer <= 0.0:
		normal_mesh.visible = true
		hurt_mesh.visible = false
		is_hurt = false
	else:
		hurt_timer -= delta

func _physics_process(delta):
	if desired_range == "close":
		navigation_agent_3d.set_target_position(player.position)

	var destination = navigation_agent_3d.get_next_path_position()
	var local_destination = destination - global_position
	var direction = local_destination.normalized()
	
	
	if is_hurt:
		velocity.x = 0.0
		velocity.z = 0.0
		velocity.y = 0.0
	else:
		#If staying at far, move to target point, otherwise move towards player.
		
		velocity.x = direction.x * SPEED
		velocity.y = direction.y * SPEED * 5
		velocity.z = direction.z * SPEED
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	move_and_slide()

func hurt(damage):
	if not is_hurt:
		hp -= damage
		if hp <= 0:
			queue_free()
			GameState.victory = true
			GameState.paused = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			get_tree().change_scene_to_file("res://GUI/end_screen.tscn")
		enemy_health.emit(get_health())
		hurt_mesh.visible = true
		normal_mesh.visible = false
		is_hurt = true
		hurt_timer = HURT_DURATION
		
#attack function, called whenever cooldown hits 0
func attack():
	var proj = projectile.instantiate()
	proj.direction = position.direction_to(player.position)
	#what does this do? did i do this right? we just dont know
	proj.source = Reference.Source.Enemy
	get_tree().root.add_child(proj)
	proj.global_position = position
func attack_close():
	proj_angle = proj_angle.rotated(y_axis, close_attack_rotation)
	for i in range(4):
		
		var proj = projectile.instantiate()
		proj.direction = proj_angle
		proj.source = Reference.Source.Enemy
		get_tree().root.add_child(proj)
		proj.global_position = position
		proj_angle = proj_angle.rotated( y_axis, PI/2)
func bounced():
	direction = -direction

## Get health
func get_health():
	return hp
