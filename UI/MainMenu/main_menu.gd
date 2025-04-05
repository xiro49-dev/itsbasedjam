extends Node

@onready var newgame: Button = $VBoxContainer/Newgame
@onready var _continue: Button = $VBoxContainer/Continue
@onready var settings: Button = $VBoxContainer/Settings
@onready var exit: Button = $VBoxContainer/Exit
@onready var v_box_container: VBoxContainer = $VBoxContainer
@onready var settings_menu: PanelContainer = $SettingsMenu

func _ready() -> void:
	newgame.pressed.connect(_on_new_game_pressed)
	_continue.pressed.connect(_on_contine_pressed)
	settings.pressed.connect(_on_settings_pressed)
	exit.pressed.connect(_on_exit_pressed)
	FadeScreen.unfade()
	await FadeScreen.finished
	v_box_container.open()
	if SaveLoad.save_file_exists():
		_continue.disabled = false
		_continue.grab_focus()

func _on_new_game_pressed() -> void:
	SaveLoad.new_game()
	change_scenes("res://game.tscn")

func _on_contine_pressed() -> void:
	SaveLoad.load_game()
	change_scenes("res://game.tscn")

func _on_settings_pressed() -> void:
	settings_menu.open(v_box_container)
 
func _on_exit_pressed() -> void:
	FadeScreen.fade()
	await FadeScreen.finished
	get_tree().quit()

func change_scenes(path : String) -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(path)
