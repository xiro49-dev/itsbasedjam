class_name Counter extends Control
 
@onready var _icon: TextureRect = $icon
@onready var _counter: Label = $counter
@onready var _auto_hide: Timer = $auto_hide
 
@export var _trans_type: Tween.TransitionType 
@export var _on_screen_position : Vector2
@export var _off_screen_position : Vector2

var _tween : Tween
var is_open: bool
var _stay_open : bool
 
func _ready() -> void:
	SignalManager.coins_updated.connect(set_value)
	_auto_hide.timeout.connect(on_auto_hide_timeout)
	_counter.text = str(clamp(SaveLoad.progress.coins, 0, 99999))
 
func open(stay_open: bool = true) -> Signal:
	_stay_open = stay_open
	await _tween_position(_on_screen_position, Tween.EASE_IN)
	is_open = true
	return _tween.finished

func set_value(value: int):
	if !is_open:
		await open(false)
	await _pulse()
	_counter.text = str(clamp(value, 0, 99999))
	if not _stay_open:
		_auto_hide.start()
	
func close() -> Signal:
	is_open = false
	_tween_position(_off_screen_position, Tween.EASE_OUT)
	return _tween.finished

func _pulse() -> Signal:
	if _tween and _tween.is_running():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_icon, "custom_minimum_size:y", 46, 0.1)
	_tween.tween_property(_icon, "custom_minimum_size:y", 42, 0.1)
	return _tween.finished
	
func _tween_position(new_position: Vector2, ease_type: Tween.EaseType) -> Signal:
	if _tween and _tween.is_running():
		_tween.kill()
	_tween = create_tween().set_trans(_trans_type).set_ease(ease_type)
	_tween.tween_property(self, "position", new_position, 0.2)
	return _tween.finished
 
func on_auto_hide_timeout() -> void:
	close()

 
