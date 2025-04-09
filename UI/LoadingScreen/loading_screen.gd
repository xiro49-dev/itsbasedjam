extends Control
var loading = false
var _scene
signal done

func _ready() -> void:
	hide()
	set_process(false)

func start_loading(scene:String, cb: Callable):
	_scene = scene
	ResourceLoader.load_threaded_request(scene)
	loading = true
	set_process(true)
	show()
	
func _process(delta: float) -> void:
	if not loading:
		return 

	var progress = [] 
	ResourceLoader.load_threaded_get_status(_scene, progress)
	$ColorRect/ProgressBar.value = progress[0] * 100
	if progress[0] * 100>= 100:
		handle_loading()
		hide()
		done.emit()
		set_process(false)

func handle_loading():
	var s: PackedScene = ResourceLoader.load_threaded_get(_scene)
	var _s = s.instantiate()
	print(owner)
	owner.add_child(_s)
	owner.current_lvl = _s as Level
