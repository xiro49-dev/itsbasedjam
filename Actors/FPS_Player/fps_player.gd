extends CharacterBody3D
class_name FpsPlayer

@export var jump_height: float = 2.0
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var walk_speed = 8.0
@export var run_speed = 15.0
var ground_acceleration: float = 8.0
@export var air_acceleration: float = 5.0
@export var ground_friction: float = 30
@export var air_friction: float = 2.0
@onready var head: Marker3D = $Head
@onready var camera: Camera3D = $Head/Camera

var is_jumping: bool = false
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
func move_camera(event: InputEventMouseMotion):
	if SaveLoad.settings.camera_invert_y:
		camera.rotate_x(event.relative.y * SaveLoad.settings.camera_sensitivity)
	else:
		camera.rotate_x(-event.relative.y * SaveLoad.settings.camera_sensitivity)
	if SaveLoad.settings.camera_invert_x:
		head.rotate_y(event.relative.x * SaveLoad.settings.camera_sensitivity )
	else:
		head.rotate_y(-event.relative.x * SaveLoad.settings.camera_sensitivity )
	camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		move_camera(event)
	if event.is_action_pressed("unlock_mouse"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump input
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		start_jump()
	if is_on_wall() and Input.is_action_just_pressed("jump"):
		start_jump()
	# Handle movement input
	var direction: Vector3
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	direction.z = Input.get_action_strength("down") - Input.get_action_strength("up")
	direction = direction.normalized()
	var camera:Camera3D = get_viewport().get_camera_3d()
	direction = (camera.global_transform.basis* transform.basis * direction).normalized()
	if direction:
		var target_velocity: Vector3 = direction * ground_acceleration  # Adjust speed as needed
		target_velocity.y = velocity.y
		if is_on_floor():
			if Input.is_action_pressed("run"):
				ground_acceleration = run_speed
			else:
				ground_acceleration = walk_speed
			velocity.x = lerp(velocity.x, target_velocity.x, ground_acceleration * delta)
			velocity.z = lerp(velocity.z, target_velocity.z, ground_acceleration * delta)
		else:
			velocity.x = lerp(velocity.x, target_velocity.x, air_acceleration * delta)
			velocity.z = lerp(velocity.z, target_velocity.z, air_acceleration * delta)
	else:
		if is_on_floor():
			velocity.x = lerp(velocity.x, 0.0, ground_friction * delta)
			velocity.z = lerp(velocity.z, 0.0, ground_friction * delta)

		else:
			velocity.x = lerp(velocity.x, 0.0, air_friction * delta)
			velocity.z = lerp(velocity.z, 0.0, air_friction * delta)

	# Move the character
	move_and_slide()
	# Rotate Body
	if velocity.length_squared() > 0 and not global_position.is_equal_approx(global_position + Vector3(velocity.x, 0, -velocity.z).normalized()):
		var target_rotation:Transform3D = transform.looking_at(global_position + Vector3(velocity.x, 0, -velocity.z).normalized(), Vector3.UP)
		get_node("Body").rotation.y = -target_rotation.basis.get_euler().y

	# Reset jumping flag when landing
	if is_jumping and is_on_floor():
		is_jumping = false

func start_jump() -> void:
	if is_on_floor():
		# Calculate the initial upward velocity required to reach the target jump height
		# Using the kinematic equation: v_f^2 = v_i^2 + 2ad
		# Where:
		# v_f = 0 (velocity at the peak of the jump)
		# v_i = initial upward velocity (what we want to find)
		# a = -gravity (acceleration due to gravity, negative because it's downwards)
		# d = jump_height (the desired jump height)

		# 0 = v_i^2 - 2 * gravity * jump_height
		# v_i^2 = 2 * gravity * jump_height
		# v_i = sqrt(2 * gravity * jump_height)

		velocity.y = sqrt(2 * gravity * jump_height)
		is_jumping = true

func is_player():
	return true
