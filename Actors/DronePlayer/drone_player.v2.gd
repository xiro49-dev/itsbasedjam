extends CharacterBody3D
var held_object

@export var move_speed = 20.0
@export var look_sensitivity = 0.005
@export var up_down_speed = 3.0
@export var roll_speed = 10.0 # Degrees per second
var target_length: float = 0.0 # The fully retracted length
var current_length: float = 20.0 # The current extended length
var retraction_rate: float = 1.5 # Units per second
var is_retracting: bool = false
@onready var beam_ray: RayCast3D = $TractorBeam/BeamCast
@onready var beam_arm: BeamArm = $TractorBeam/Beam
@onready var remote: RemoteTransform3D = $TractorBeam/Beam/Remote
var camera_transform_basis = Basis() # Store the initial camera basis

@onready var camera_pivot = $CameraPivotPivot/CameraPivot # Node to handle vertical (pitch) rotation
@onready var camera = $CameraPivotPivot/CameraPivot/SpringArm3D/Camera3D

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera_transform_basis = camera.transform.basis

func _physics_process(delta):
	# Movement input
	var input_direction = Vector3.ZERO
	if Input.is_action_pressed("up"):
		input_direction += -transform.basis.z # Forward (negative Z in Godot)
	if Input.is_action_pressed("down"):
		input_direction += transform.basis.z  # Backward
	#if Input.is_action_pressed("left"):
		#input_direction += -transform.basis.x # Left
	#if Input.is_action_pressed("right"):
		#input_direction += transform.basis.x  # Right
	if Input.is_action_pressed("fly_up"):
		input_direction += transform.basis.y  # Up
	if Input.is_action_pressed("fly_down"):
		input_direction += -transform.basis.y # Down

	input_direction = (camera.global_transform.basis *input_direction).normalized()

	# Apply movement
	velocity = input_direction * move_speed

	# Roll control (optional)
	#var roll_input = 0
	#if Input.is_action_pressed("roll_left"):
		#roll_input = 1
	#if Input.is_action_pressed("roll_right"):
		#roll_input = -1
	#rotate_z(deg_to_rad(roll_input * roll_speed * delta))

	# Apply gravity (if needed - remove or adjust for pure drone flight)
	# if not is_on_floor():
	# 	velocity.y -= gravity * delta

	move_and_slide()
	if velocity.length_squared() > 0 and not global_position.is_equal_approx(global_position + Vector3(velocity.x, 0, -velocity.z).normalized()):
		var target_rotation:Transform3D = transform.looking_at(global_position + Vector3(velocity.x, 0, -velocity.z).normalized(), Vector3.UP)
		get_node("Body").rotation.y = -target_rotation.basis.get_euler().y
 

# Optional: Reset roll to level over time
func _process(delta):
		
	if Input.is_action_just_pressed("click"):
		if held_object:
			(held_object as RigidBody3D).sleeping = false
			(held_object as RigidBody3D).process_mode = Node.PROCESS_MODE_INHERIT
			beam_arm.reset_length()
		remote.remote_path = NodePath("")
		
	if beam_ray.is_colliding():
		var collision = beam_ray.get_collider()
		if collision is RigidBody3D and not remote.remote_path and collision != held_object:
			held_object = collision
			held_object.picked_up()
			beam_arm.is_retracting = true
			remote.remote_path = collision.get_path()
			(collision as RigidBody3D).sleeping = true
			(collision as RigidBody3D).process_mode = Node.PROCESS_MODE_DISABLED
				
