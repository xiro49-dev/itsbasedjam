extends Control
func _ready() -> void:
	hide()
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("unlock_mouse") and not get_tree().paused:
		show()
		get_tree().paused = true
		
	elif Input.is_action_just_pressed("unlock_mouse") and get_tree().paused:
		hide()
		get_tree().paused = false
		


func _on_load_last_checkpoint_pressed() -> void:
	SaveLoad.load_game()
	change_scenes("res://game.tscn")
	
func change_scenes(path : String) -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(path)


func _on_resume_pressed() -> void:
	hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false


func _on_quit_pressed() -> void:
	get_tree().quit()
