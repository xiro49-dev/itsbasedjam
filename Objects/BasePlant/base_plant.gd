extends Area3D
@export var stages: Array[PackedScene]
var current_stage = 0
@onready var timer = $Timer
@export var grow_rate = 2.5
@export var progress = 0
@export var max_scale:Vector3 = Vector3.ONE
@export var drop: Item
@export var item_trigger: PackedScene
func _ready() -> void:
	$Body.add_child(stages[current_stage].instantiate())
	
func _process(delta):
	progress += grow_rate * delta
	scale += scale * grow_rate * delta / 100
	scale = clamp(scale, Vector3.ONE, max_scale)
func _on_timer_timeout() -> void:
	if progress >= 100.0:
		upgrade()

	timer.start()

func upgrade():
	progress = 0
	scale = Vector3.ONE
	if current_stage < len(stages)-1:
		current_stage += 1
		for child in $Body.get_children():
			child.queue_free()
		$Body.add_child(stages[current_stage].instantiate())
	else:
		grow_rate = 0
		var _drop = item_trigger.instantiate()
		get_tree().get_first_node_in_group("Level").add_child(_drop)
		_drop.global_position = self.global_position
		_drop.resource = drop
		_drop.add_child(CSGBox3D.new())
		self.queue_free()
