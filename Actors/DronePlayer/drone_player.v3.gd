extends CharacterBody3D
var held_object

# Can't fly below this speed
var min_flight_speed = 10
# Maximum airspeed
var max_flight_speed = 30
# Turn rate
var turn_speed = 0.75
# Climb/dive rate
var pitch_speed = 0.5
# Wings "autolevel" speed
var level_speed = 3.0
# Throttle change speed
var throttle_delta = 30
# Acceleration/deceleration
var acceleration = 6.0

# Current speed
var forward_speed:float = 0
# Throttle input speed
var target_speed = 0
# Lets us disable certain things when grounded
var grounded = false
var turn_input = 0
var pitch_input = 0
@onready var beam_ray: RayCast3D = $TractorBeam/BeamCast
@onready var tractor_beam: TractorBeam = $TractorBeam
@onready var remote: RemoteTransform3D = $TractorBeam/Beam/Remote
var camera_transform_basis = Basis() # Store the initial camera basis
@export var can_move: bool = false
@onready var camera_pivot = $CameraPivotPivot/CameraPivot # Node to handle vertical (pitch) rotation
@onready var camera = $CameraPivotPivot/CameraPivot/SpringArm3D/Camera3D
func _physics_process(delta):
	get_input(delta)
	# Rotate the transform based on the input values
	transform.basis = transform.basis.rotated(transform.basis.x, pitch_input * pitch_speed * delta)
	transform.basis = transform.basis.rotated(Vector3.UP, turn_input * turn_speed * delta)
	# If on the ground, don't roll the body
	if grounded:
		$Body.rotation.y = 0
	else:
		# Roll the body based on the turn input
		$Body.rotation.y = lerp($Body.rotation.y, float(turn_input), level_speed * delta)
	# Accelerate/decelerate
	forward_speed = lerp(forward_speed, float(target_speed), acceleration * delta)
	# Movement is always forward
	velocity = -transform.basis.z * forward_speed
	# Handle landing/taking off
	if is_on_floor():
		if not grounded:
			rotation.x = 0
		velocity.y -= 1
		grounded = true
	else:
		grounded = false

	move_and_slide()

func get_input(delta):
	# Throttle input
	if Input.is_action_pressed("up"):
		target_speed = min(forward_speed + throttle_delta * delta, max_flight_speed)
	if Input.is_action_pressed("down"):
		var limit = 0 if grounded else min_flight_speed
		target_speed = max(forward_speed - throttle_delta * delta, limit)
	# Turn (roll/yaw) input
	turn_input = 0
	if forward_speed > 0.5:
		turn_input -= Input.get_action_strength("right")
		turn_input += Input.get_action_strength("left")
	# Pitch (climb/dive) input
	pitch_input = 0
	if not grounded:
		pitch_input -= Input.get_action_strength("fly_up")
	if forward_speed >= min_flight_speed:
		pitch_input += Input.get_action_strength("fly_down")
func _process(delta):
		
	if Input.is_action_just_pressed("click") and held_object != null:
		(held_object as RigidBody3D).process_mode = Node.PROCESS_MODE_INHERIT
		#(held_object as RigidBody3D).sleeping = false
		tractor_beam.reset_length()
		$Timers/PickupTimer.start()
		remote.remote_path = NodePath("")
	if Input.is_action_just_pressed("exit_drone"):
		var player = get_tree().get_first_node_in_group("PlayerDeactive")
		remove_from_group("Player")
		player.activate()
		deactivate()
		

	if beam_ray.is_colliding():
		var collision = beam_ray.get_collider()
		if collision is RigidBody3D and not remote.remote_path:
			if collision != held_object:
				held_object = collision
				tractor_beam.start_retraction()
				remote.remote_path = collision.get_path()
				(collision as RigidBody3D).process_mode = Node.PROCESS_MODE_DISABLED

func activate():
	camera.current = true
	can_move = true
	self.add_to_group("Player")

func deactivate():
	camera.current = false
	can_move = false
	self.remove_from_group("Player")
	
func _on_pickup_timer_timeout() -> void:
	held_object = null# Replace with function body.
