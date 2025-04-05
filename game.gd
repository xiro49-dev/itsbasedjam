extends Node3D

var current_lvl : Level
@export var player_scenes: Dictionary[Enums.PlayerTypes, PackedScene] = {
	
}
@onready var enemy_queue: Marker3D = $EnemyQueue
@onready var dialog: Control = $UI/Dialog
@export var test_music : AudioStream

func _ready()->void:
	Music.play_track(test_music)
	load_level()

func toggle_inventory() -> void:
	pass

func load_level():
	if current_lvl:
		SaveLoad.save_game()
		await get_tree().create_timer(0.5).timeout
		current_lvl.queue_free()
		get_tree().get_first_node_in_group("Player").queue_free()
		for child in enemy_queue.get_children():
			child.queue_free()
		
	current_lvl = load("res://Levels/"+ SaveLoad.progress.level_name + ".tscn").instantiate()
	add_child(current_lvl)
	current_lvl.change.connect(_on_change_request)
	var player = player_scenes.get(current_lvl.player_type).instantiate()
	add_child(player)
	player.global_position = SaveLoad.progress.level_posistion
	spawn_enemies(current_lvl.enemies)

func _on_change_request(level_name:String):
	if current_lvl:
		SaveLoad.save_game()
		await get_tree().create_timer(0.5).timeout
		current_lvl.queue_free()
		get_tree().get_first_node_in_group("Player").queue_free()
		for child in enemy_queue.get_children():
			child.queue_free()
		
	current_lvl = load("res://Levels/"+ level_name +".tscn").instantiate()
	add_child(current_lvl)
	current_lvl.change.connect(_on_change_request)
	var player = player_scenes.get(current_lvl.player_type).instantiate()
	add_child(player)
	player.global_position = current_lvl.get_node("SpawnPoint").global_position
	spawn_enemies(current_lvl.enemies)
	
func spawn_enemies(enemies: Array[EnemyRes]):
	for enemy in enemies:
		var _e = enemy.scene.instantiate()
		enemy_queue.add_child(_e)
		_e.global_position = enemy.position
		_e.type = enemy.type
	enemy_queue.init()
	
