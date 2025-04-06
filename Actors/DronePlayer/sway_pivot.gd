extends Marker3D

@export var sway_amount_lateral: float = 0.05
@export var sway_amount_forward: float = 0.05
@export var sway_amount_vertical: float = 0.02
@export var sway_recovery_speed: float = 8.0
@export var rotation_amount_yaw_degrees: float = 2.0   # Rotation around local Y-axis (yaw)
@export var rotation_amount_pitch_degrees: float = 1.0 # Rotation around local X-axis (pitch)
@export var rotation_amount_roll_degrees: float = 1.0  # Rotation around local Z-axis (roll)
@export var rotation_recovery_speed: float = 8.0
@export var stop_threshold_linear: float = 0.05
@export var stop_threshold_angular: float = 0.05
@export var max_roll_degrees: float = 20.0
@export var max_pitch_degrees: float = 20.0
@export var max_yaw_degrees: float = 45.0

var initial_position: Vector3
var initial_rotation_degrees: Vector3
var target_offset: Vector3 = Vector3.ZERO
var target_rotation_degrees: Vector3

var previous_rotation: float # Store previous Y-axis rotation for yaw calculation

func _ready():
	initial_position = position
	initial_rotation_degrees = rotation_degrees
	target_rotation_degrees = initial_rotation_degrees
	previous_rotation = owner.rotation.y if is_instance_valid(owner) else 0.0

func _process(delta: float) -> void:
	if not is_instance_valid(owner):
		return

	var velocity = owner.velocity
	var current_rotation_y = owner.rotation.y
	var estimated_angular_velocity_y = (current_rotation_y - previous_rotation) / delta
	previous_rotation = current_rotation_y

	# --- Position Sway ---
	var sway_input_lateral = velocity.x
	target_offset.x = -sway_input_lateral * sway_amount_lateral

	var sway_input_forward = velocity.z
	target_offset.z = -sway_input_forward * sway_amount_forward

	var sway_input_vertical = velocity.y
	target_offset.y = sway_input_vertical * sway_amount_vertical # Positive for up

	if abs(velocity.x) < stop_threshold_linear:
		position.x = lerp(position.x, initial_position.x + target_offset.x, sway_recovery_speed * delta)
		target_offset.x = lerp(target_offset.x, 0.0, sway_recovery_speed * delta)
	else:
		position.x = initial_position.x + target_offset.x

	if abs(velocity.z) < stop_threshold_linear:
		position.z = lerp(position.z, initial_position.z + target_offset.z, sway_recovery_speed * delta)
		target_offset.z = lerp(target_offset.z, 0.0, sway_recovery_speed * delta)
	else:
		position.z = initial_position.z + target_offset.z

	if abs(velocity.y) < stop_threshold_linear:
		position.y = lerp(position.y, initial_position.y + target_offset.y, sway_recovery_speed * delta)
		target_offset.y = lerp(target_offset.y, 0.0, sway_recovery_speed * delta)
	else:
		position.y = initial_position.y + target_offset.y


	# --- Rotation ---
	# Yaw (Y-axis) based on estimated angular velocity around Y
	var yaw_input = estimated_angular_velocity_y
	var yaw_angle_degrees = yaw_input * rotation_amount_yaw_degrees
	target_rotation_degrees.y = clampf(initial_rotation_degrees.y + yaw_angle_degrees, initial_rotation_degrees.y - max_yaw_degrees, initial_rotation_degrees.y + max_yaw_degrees)

	# Pitch (X-axis) based on forward/backward velocity
	var pitch_input = velocity.z
	var pitch_angle_degrees = pitch_input * rotation_amount_pitch_degrees
	target_rotation_degrees.x = clampf(initial_rotation_degrees.x - pitch_angle_degrees, initial_rotation_degrees.x - max_pitch_degrees, initial_rotation_degrees.x + max_pitch_degrees) # Negative for natural feel

	# Roll (Z-axis) based on lateral velocity
	var roll_input = velocity.x
	var roll_angle_degrees = -roll_input * rotation_amount_roll_degrees
	target_rotation_degrees.z = clampf(initial_rotation_degrees.z + roll_angle_degrees, initial_rotation_degrees.z - max_roll_degrees, initial_rotation_degrees.z + max_roll_degrees)

	if abs(estimated_angular_velocity_y) < stop_threshold_angular:
		rotation_degrees.y = lerp(rotation_degrees.y, target_rotation_degrees.y, rotation_recovery_speed * delta)
		# target_rotation_degrees.y = lerp(target_rotation_degrees.y, initial_rotation_degrees.y, rotation_recovery_speed * delta)
	else:
		rotation_degrees.y = target_rotation_degrees.y

	if abs(velocity.z) < stop_threshold_angular:
		rotation_degrees.x = lerp(rotation_degrees.x, target_rotation_degrees.x, rotation_recovery_speed * delta)
		# target_rotation_degrees.x = lerp(target_rotation_degrees.x, initial_rotation_degrees.x, rotation_recovery_speed * delta)
	else:
		rotation_degrees.x = target_rotation_degrees.x

	if abs(velocity.x) < stop_threshold_angular:
		rotation_degrees.z = lerp(rotation_degrees.z, target_rotation_degrees.z, rotation_recovery_speed * delta)
		# target_rotation_degrees.z = lerp(target_rotation_degrees.z, initial_rotation_degrees.z, rotation_recovery_speed * delta)
	else:
		rotation_degrees.z = target_rotation_degrees.z
