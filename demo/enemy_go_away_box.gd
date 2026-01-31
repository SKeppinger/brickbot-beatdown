extends StaticBody3D
func _physics_process(delta: float) -> void:
	var collision = move_and_collide(Vector3(0,0,0))
	if collision:
		if collision.get_collider().has_method("bounced"):
			collision.get_collider().bounced()
