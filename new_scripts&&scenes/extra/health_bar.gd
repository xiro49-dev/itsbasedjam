extends TextureProgressBar
 
func _ready() -> void:
	value = max_value

func _set_value(percentage : float) -> void:
	value = percentage * max_value
 
