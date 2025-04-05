extends NavigationRegion3D
class_name Level
@export var level_name:String
@export var player_type: Enums.PlayerTypes
@export var enemies: Array[EnemyRes]
signal change(level_name)

func change_level(lvl_name: String):
	change.emit(lvl_name)
