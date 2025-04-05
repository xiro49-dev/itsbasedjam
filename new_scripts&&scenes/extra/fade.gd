extends ColorRect

@export var _duration := 1.0
const CLEAR : Color = Color(0, 0, 0, 0)
var _tween : Tween

func _ready() -> void:
	visible = true

func to_clear(duration : float = _duration) -> Signal:
	return _to_colour(CLEAR, duration)
	
func to_black(duration : float = _duration) -> Signal: 
	return _to_colour(Color.BLACK, duration)

func _to_colour(new_colour: Color, duration : float) -> Signal:
	if _tween && _tween.is_running():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "color", new_colour, duration)
	return _tween.finished
