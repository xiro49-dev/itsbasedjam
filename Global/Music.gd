extends AudioStreamPlayer 

@export var _duration : float = 1  
var _tween : Tween

const TEST_SFX = "TEST_SFX"

var Sounds : Dictionary = {
	TEST_SFX : preload("res://new_scripts&&scenes/test_sfx.WAV") 
}

func play_sfx(player: AudioStreamPlayer3D, clip_key: String) -> void:
	if Sounds.has(clip_key) == false:
		return
	player.stream = Sounds[clip_key]
	player.play()
	 

func _ready() -> void:
	bus = "Music"
	set_linear_volume(0)
	process_mode = Node.PROCESS_MODE_ALWAYS
	
func set_linear_volume(linear_volume : float) -> void:
	volume_db = linear_to_db(linear_volume) 
	
	
func _fade_volume(target_volume: float, duration : float = _duration) -> Signal:
	if _tween && _tween.is_running():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_method(set_linear_volume, db_to_linear(volume_db) , target_volume, duration)
	return _tween.finished
	

func play_track(track : AudioStream, duration : float = _duration) -> Signal:
	if playing:
		if stream == track:
			return  _fade_volume(0.5, duration)
		await _fade_volume(0, duration)
	stream = track
	play()
	return _fade_volume(0.5, duration)
	 
func fade_out(duration : float = _duration) -> void:
	await _fade_volume(0, duration) 
	stop()
	stream = null
