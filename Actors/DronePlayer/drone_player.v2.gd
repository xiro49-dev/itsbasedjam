extends CharacterBody3D
var held_object

@export var move_speed = 20.0
@export var look_sensitivity = 0.005
@export var up_down_speed = 3.0
@export var roll_speed = 10.0 # Degrees per second

@onready var beam_ray: RayCast3D = $TractorBeam/BeamCast
@onready var tractor_beam: TractorBeam = $TractorBeam
@onready var remote: RemoteTransform3D = $TractorBeam/Beam/Remote
var camera_transform_basis = Basis() # Store the initial camera basis
@export var can_move: bool = false
@onready var camera_pivot = $CameraPivotPivot/CameraPivot # Node to handle vertical (pitch) rotation
@onready var camera = $CameraPivotPivot/CameraPivot/SpringArm3D/Camera3D

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	# Movement input
	var input_direction = Vector3.ZERO
	if Input.is_action_pressed("up"):
		input_direction += -transform.basis.z # Forward (negative Z in Godot)
	if Input.is_action_pressed("down"):
		input_direction += transform.basis.z  # Backward
	if Input.is_action_pressed("left"):
		input_direction += -transform.basis.x # Left
	if Input.is_action_pressed("right"):
		input_direction += transform.basis.x  # Right

	input_direction = (camera.global_transform.basis *input_direction).normalized()

	if Input.is_action_pressed("fly_up"):
		input_direction += transform.basis.y  # Up
	if Input.is_action_pressed("fly_down"):
		input_direction += -transform.basis.y # Down

	velocity = input_direction * move_speed

	move_and_slide()
	rotate_body(input_direction, delta)
	
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
		
	
	if Input.is_action_just_pressed("click") and beam_ray.is_colliding():
		var collision = beam_ray.get_collider()
		if collision is RigidBody3D and not remote.remote_path and collision != held_object:
			pickup(collision)

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

func rotate_body(input_direction:Vector3, delta):
	var _angle_difference
	var rotation_speed : float = 5.0 
	_angle_difference = wrapf(atan2(input_direction.x, input_direction.z) - $Body.rotation.y, -PI, PI)
	$Body.rotation.y += clamp(rotation_speed * delta , 0, abs(_angle_difference)) *  sign(_angle_difference)
	
func pickup(collision: Node3D):
	held_object = collision
	tractor_beam.start_retraction()
	remote.remote_path = collision.get_path()
	(collision as RigidBody3D).process_mode = Node.PROCESS_MODE_DISABLED
