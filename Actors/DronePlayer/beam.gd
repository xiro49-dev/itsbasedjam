extends SpringArm3D
class_name BeamArm
@export var retraction_rate: float = 2.0 # Units per second (adjust as needed)
@export var target_length: float = 0.5 # The desired fully retracted length
var is_retracting: bool = false
var starting_length: float
@export var sway_amount_lateral: float = 0.02
@export var sway_amount_forward: float = 0.01
@export var bounce_amount_vertical: float = 0.005
@export var recovery_speed: float = 5.0
var initial_position: Vector3

var target_offset: Vector3 = Vector3.ZERO
func _ready():
	starting_length = spring_length # Store the initial length
	initial_position = position # Store the initial local position

func start_retraction():
	is_retracting = true

func stop_retraction():
	is_retracting = false

func reset_length():
	spring_length = starting_length
	is_retracting = false

func _process(delta):
	var velocity = get_parent().owner.velocity
	var current_offset: Vector3 = position - initial_position

	# Sway based on lateral movement (owner's local X-axis)
	var sway_input_lateral = velocity.x
	target_offset.x = -sway_input_lateral * sway_amount_lateral

	# Sway based on forward/backward movement (owner's local Z-axis)
	var sway_input_forward = velocity.z
	target_offset.z = -sway_input_forward * sway_amount_forward

	# Subtle "Bounce" based on vertical velocity
	var bounce_input_vertical = velocity.y
	target_offset.y = bounce_input_vertical * bounce_amount_vertical

	# Smoothly move towards the target offset
	position = position.lerp(initial_position + target_offset, recovery_speed * delta)
	if is_retracting and spring_length > target_length:
		var amount_to_retract = retraction_rate * delta
		spring_length -= amount_to_retract
		if spring_length < target_length:
			spring_length = target_length
			is_retracting = false
			print("SpringArm fully retracted")
