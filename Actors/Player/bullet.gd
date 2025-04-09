extends RigidBody3D
@export var speed = 20
@export var lifetime = 5
@export var dmg = 10

func _ready() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	var cam = get_viewport().get_camera_3d()
	if player:
		#rotation = .global_rotation
		position = player.get_node("Body/BulletSpawn").global_position
	var camera_forward = -cam.global_transform.basis.z
	var horizontal_direction = Vector3(camera_forward.x, 0, camera_forward.z).normalized()
	if horizontal_direction == Vector3.ZERO:
		horizontal_direction = -global_transform.basis.z.normalized() # Fallback to shooter's forward

	look_at(global_position - horizontal_direction* 10, Vector3.UP)
	apply_central_impulse(transform.basis.z *  speed)
	await get_tree().create_timer(lifetime).timeout
	queue_free()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("ai"):
		body.take_damage(dmg)
		queue_free()
	else:
		queue_free()
