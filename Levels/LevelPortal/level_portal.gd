extends Area3D
@export var target_level:String


func _on_body_entered(body: Node3D) -> void:
	if body.has_method("is_player"):
		if body.is_player():
			owner.change_level(target_level)
			print("change level")
