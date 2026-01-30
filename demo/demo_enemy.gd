extends CharacterBody3D
class_name DemoEnemy

@onready var normal_mesh = $NormalMesh
@onready var hurt_mesh = $HurtMesh

@export var max_hp = 10

const SPEED = 11.0
const GRAVITY = -30.0
const HURT_DURATION = 0.25

var hp = max_hp

var direction = Vector2(0, 0)
var dir_duration = 0.0
var dir_change_timer = 0.0
var is_hurt = false
var hurt_timer = 0.0

func _process(delta):
	if dir_change_timer <= 0.0:
		dir_duration = randf_range(0.5, 3.0)
		dir_change_timer = dir_duration
		direction.x = randf_range(-1, 1)
		direction.y = randf_range(-1, 1)
	else:
		dir_change_timer -= delta
	
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
		velocity.x = direction.x * SPEED
		velocity.z = direction.y * SPEED
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
