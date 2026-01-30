extends CharacterBody3D
class_name DemoEnemy

@onready var normal_mesh = $NormalMesh
@onready var hurt_mesh = $HurtMesh

@export var player: Player
@export var max_hp = 10

const SPEED = 2.5
const GRAVITY = -30.0
const HURT_DURATION = 0.25

var direction = Vector3(0, 0, 0)
var hp = max_hp

var dir_duration = 0.0
var dir_change_timer = 0.0
var is_hurt = false
var hurt_timer = 0.0
var health = 100
var desired_range = "close"
var target_position = Vector3.ZERO

func _process(delta):
	#Current desired behaviors: Pick between wanting to be close or far, then attempt to move to that range. Recheck and change every 15? sec
	if dir_change_timer <= 0.0:
		print("dir change timer")
		dir_change_timer = 15
		if desired_range == "far":
			desired_range = "close"
		else:
			#for far distance, moves in a direction perpendicular to the line between it and player, in order to be predictable. this is shitass but should work.
			desired_range = "far"
			
			direction.x = position.direction_to(player.position).z
			direction.z = sign(randf_range(-1,1))*position.direction_to(player.position).x
		print(desired_range)
	else:
		dir_change_timer -= delta
	
		
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
	if is_hurt:
		velocity.x = 0.0
		velocity.z = 0.0
	else:
		#If staying at far, move to target point, otherwise move towards player.
		if desired_range == "close":
			direction = position.direction_to(player.position)
			
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	move_and_slide()

func hurt(damage):
	if not is_hurt:
		hp -= damage
		if hp <= 0:
			queue_free()
		hurt_mesh.visible = true
		normal_mesh.visible = false
		is_hurt = true
		hurt_timer = HURT_DURATION
