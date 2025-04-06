extends Resource
class_name Progress

@export var level_posistion: Vector3 = Vector3(0, 2.0, 0)
@export var level_name: String = "Test_Level"
 
@export var coins : int:
	set(new_value):
		if !coins == new_value:
			coins = new_value
			SignalManager.coins_updated.emit(coins)
			
func _init()-> void:
	coins = 1000
 
func save_level_progess(level_name: String, player_position:Vector3):
	pass
	
