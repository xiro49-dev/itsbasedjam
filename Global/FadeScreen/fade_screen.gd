extends CanvasLayer
signal finished

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func fade():
	visible = true
	$AnimationPlayer.play("fade")
	
func unfade():
	visible = true
	$AnimationPlayer.play("unfade")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	visible = false
	finished.emit() # Replace with function body.
