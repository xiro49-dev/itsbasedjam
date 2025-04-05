extends Area3D
class_name CheckPoint

func _on_body_entered(body: Node3D) -> void:
	if body.has_method("is_player"):
		if body.is_player():
			SaveLoad.progress.level_name = owner.level_name
			SaveLoad.progress.level_posistion = get_tree().get_first_node_in_group("Player").global_position
			SaveLoad.save_game()
			print("Save")
