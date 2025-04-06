extends Area3D

@export var resource: Item

@onready var label_3d: Label3D = $Label3D

func _ready() -> void:
	SignalManager.item_seen.connect(on_item_seen)
	
func on_item_seen(visible: bool) -> void:
	label_3d.visible = visible
	
