extends Node3D

var current_lvl : Level
@export var player_scenes: Dictionary[Enums.PlayerTypes, PackedScene] = {
	
}
@onready var enemy_queue: Marker3D = $EnemyQueue
@onready var dialog: Control = $UI/Dialog
@onready var loading_screen: Control = $UI/LoadingScreen

@export var test_music : AudioStream
@export var should_spawn_enemeies = false
@export var should_spawn_player = false
func _ready()->void:
	Music.play_track(test_music)
	load_level()

func toggle_inventory() -> void:
	pass

	
func load_level():
	FadeScreen.fade()
	clean_up()
	loading_screen.start_loading("res://Levels/"+ SaveLoad.progress.level_name + ".tscn", func(): print("hello"))
	await loading_screen.done
	current_lvl.change.connect(_on_change_request)

	if should_spawn_player:
		var player = player_scenes.get(current_lvl.player_type).instantiate()
		add_child(player)
		player.global_position = SaveLoad.progress.level_posistion
	spawn_enemies(current_lvl.enemies)
	FadeScreen.unfade()
	
func clean_up():
	if not current_lvl:
		return
	SaveLoad.save_game()
	await get_tree().create_timer(0.5).timeout
	current_lvl.queue_free()
	get_tree().get_first_node_in_group("Player").queue_free()
	for child in enemy_queue.get_children():
		child.queue_free()
		
func _on_change_request(level_name:String):
	FadeScreen.fade()
	clean_up()
	loading_screen.start_loading("res://Levels/"+ level_name + ".tscn", func(): print("hello"))
	await loading_screen.done
	current_lvl.change.connect(_on_change_request)
	if should_spawn_player:
		var player = player_scenes.get(current_lvl.player_type).instantiate()
		add_child(player)
		player.global_position = current_lvl.get_node("SpawnPoint").global_position
	spawn_enemies(current_lvl.enemies)
	FadeScreen.unfade()
	
func spawn_enemies(enemies: Array[EnemyRes]):
	if not should_spawn_enemeies:
		return
	for enemy in enemies:
		var _e = enemy.scene.instantiate()
		enemy_queue.add_child(_e)
		_e.global_position = enemy.position
		_e.type = enemy.type
	enemy_queue.init()
	
func spawn_player():
	if not should_spawn_player:
		return
	
