extends Area3D

@onready var ray: RayCast3D = $RayCast3D
var _items_in_range : Array[Area3D] = []
var _nearest_index : int
var _nearest_distance : float
var _next_distance : float

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
 
func get_nearest_item() -> Node3D:
	if _items_in_range.size() == 0:
		return null
	elif _items_in_range.size() == 1:
		if not obstructed(_items_in_range[0]):
			return _items_in_range[0]
		else:
			return null
	_nearest_index = 0
	_nearest_distance = 5
	for i in _items_in_range.size():
		_next_distance = global_position.distance_squared_to(_items_in_range[i].global_position)
		if _next_distance < _nearest_distance and not obstructed(_items_in_range[i]):
			_nearest_index = i
			_nearest_distance = _next_distance
	return _items_in_range[_nearest_index]
	
func _on_area_entered(area: Area3D):
	_items_in_range.append(area)
	SignalManager.item_seen.emit(true)
	
func _on_area_exited(area: Area3D):
	_items_in_range.erase(area)
	SignalManager.item_seen.emit(false)

func obstructed(item: Node3D) -> bool:
	ray.target_position = item.global_position - ray.global_position
	ray.force_raycast_update() 
	return ray.get_collider() != item 
	
