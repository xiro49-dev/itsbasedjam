extends Node

const SETTINGS_PATH: String = "user://settings.res"
const SAVE_PATH: String = "user://save.res"

var settings: Settings
var progress: Progress

func _ready() -> void:
	if ResourceLoader.exists(SETTINGS_PATH):
		settings = ResourceLoader.load(SETTINGS_PATH)
	else:
		settings = Settings.new()
		ResourceSaver.save(settings, SETTINGS_PATH)

func save_settings() -> void:
	ResourceSaver.save(settings, SETTINGS_PATH)

func save_file_exists() -> bool:
	return ResourceLoader.exists(SAVE_PATH)

func new_game() -> void:
	progress = Progress.new()
	settings = Settings.new()
	save_settings()
	save_game()

func save_game() -> void:
	ResourceSaver.save(progress, SAVE_PATH)

func load_game() -> void:
	progress = ResourceLoader.load(SAVE_PATH)
