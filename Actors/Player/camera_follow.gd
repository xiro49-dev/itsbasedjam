extends Camera3D
@export var lerp_pwr = 1.0
@onready var camera_mark: Marker3D = $"../CameraPivot/SpringArm3D/CameraMark"

func _process(delta: float) -> void:
	global_position = lerp(global_position, camera_mark.global_position, delta*lerp_pwr)
	global_rotation = lerp(global_rotation, camera_mark.global_rotation, delta*lerp_pwr)
