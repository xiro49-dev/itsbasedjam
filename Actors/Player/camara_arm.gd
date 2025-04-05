extends SpringArm3D
@export var mouse_sen = 0.003
@export_range(-90.0, 0.0, 0.1, "radians_as_degrees") var min_vert_angle = -PI/2
@export_range(0.0, 90.0, 0.1, "radians_as_degrees") var max_vert_angle = PI/4
@onready var camera_pivot: Marker3D = $".."

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if SaveLoad.settings:
		mouse_sen = SaveLoad.settings.camera_sensitivity

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED :
		if SaveLoad.settings.camera_invert_x:
			camera_pivot.rotation.y += event.relative.x * mouse_sen
		else:
			camera_pivot.rotation.y -= event.relative.x * mouse_sen
			
		if SaveLoad.settings.camera_invert_y:
			camera_pivot.rotation.x += -event.relative.y * mouse_sen
		else:
			camera_pivot.rotation.x -= -event.relative.y * mouse_sen
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, min_vert_angle, max_vert_angle)

	if event.is_action_pressed("unlock_mouse"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
