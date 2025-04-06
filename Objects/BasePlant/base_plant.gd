extends Area3D
@export var stages: Array[PackedScene]
var stage = 0
@onready var timer = $Timer
@export var progress = 0
func _on_timer_timeout() -> void:
	
	for child in $Body.get_children():
		child.queue_free()
	if stage < len(stages):
		$Body.add_child(stages[stage].instantiate())
	stage += 1
	timer.start()
