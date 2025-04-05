extends ShapeCast3D
signal spotted(posistion: Vector3)

func _physics_process(_delta):
	if is_colliding():
		for i in range(0, get_collision_count()):
			var collider = get_collider(i)
			if not collider == null:
				if collider.has_method("is_player"):
					if collider.is_player():
						spotted.emit(collider.global_transform.origin)
