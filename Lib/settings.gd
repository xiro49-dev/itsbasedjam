extends Resource
class_name Settings

@export var master_volume : float
@export var music_volume : float 
@export var sfx_volume : float
@export var typing_speed : int
@export var rot_mult : float

@export_category("Camera Settings")
@export var camera_invert_y : bool
@export var camera_invert_x : bool
@export var camera_sensitivity: float

@export_category("Player 3d Person")
@export var jump_height: float = 2.0
@export var ground_acceleration: float = 8.0
@export var ground_sprint_acceleration: float = 15.0
@export var air_acceleration: float = 5.0
@export var ground_friction: float = 30
@export var air_friction: float = 2.0
 
func _init() -> void:
	camera_invert_x = false
	camera_invert_y = false
	master_volume = 1.0
	music_volume = 1.0
	sfx_volume = 0.5
	typing_speed = 10
	rot_mult = 1.0
	camera_sensitivity = 0.005
	jump_height = 2.0
	ground_acceleration = 8.0
	ground_sprint_acceleration = 15.0
	air_acceleration = 5.0
	ground_friction = 30
	air_friction = 2.0
