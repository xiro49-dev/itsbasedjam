extends CharacterBody3D
 
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var ground_acceleration: float = 8.0
var held_object
@export_category("Movement")
@export var jump_height: float = 2.0
@export var walk_speed = 8.0
@export var run_speed = 15.0
@export var engine_off = false
@export var air_acceleration: float = 5.0
@export var ground_friction: float = 30
@export var air_friction: float = 2.0

@export_category("Camera")
@export_enum("t", "f") var camera_mode = "t"
@export var third_p_arm_position:Vector3 = Vector3(0.0, 2.0, -3.0) 
@export var third_p_arm_length: float = -4
@export var first_p_arm_position:Vector3 = Vector3(0.0, 2.0, 0.0) #adjust to player height
@export var first_p_arm_length: float = 0

signal died

@onready var beam_ray: ShapeCast3D = $Body/TractorBeam/ShapeCast3D
@onready var remote: RemoteTransform3D = $Body/TractorBeam/Beam/Remote

func _ready() -> void:
	pass
	#test_dialog()
	
 
func _process(delta):
	if Input.is_action_just_pressed("click"):
		if held_object:
			(held_object as Node).process_mode = Node.PROCESS_MODE_DISABLED
		remote.remote_path = NodePath("")
		
	if beam_ray.is_colliding():
		for i in range(beam_ray.get_collision_count() - 1):
			var collision = beam_ray.get_collider(i)
			if collision is Enemy and not remote.remote_path:
				held_object = collision
				remote.remote_path = collision.get_path()
				(collision as Node).process_mode = Node.PROCESS_MODE_DISABLED
				
func _physics_process(delta: float) -> void:

	# Apply gravity
	if Input.is_action_pressed("fly_down"):
		velocity.y = lerp(velocity.y, (Vector3.DOWN*air_acceleration).y, air_acceleration * delta)
	elif Input.is_action_pressed("fly_up"):
		velocity.y = lerp(velocity.y, (Vector3.UP*air_acceleration).y, air_acceleration*delta)
	else:
		velocity.y = lerp(velocity.y, 0.0, air_friction * delta)
	var direction: Vector3 = Vector3.ZERO
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	direction.z = Input.get_action_strength("down") - Input.get_action_strength("up")
	direction = direction.normalized()
	var camera:Camera3D = get_viewport().get_camera_3d()
	direction = (camera.global_transform.basis * transform.basis * direction).normalized()
	if direction:
		var target_velocity: Vector3 = direction * ground_acceleration  # Adjust speed as needed
		target_velocity.y = velocity.y
		ground_acceleration = run_speed
		velocity.x = lerp(velocity.x, target_velocity.x, ground_acceleration * delta)
		velocity.z = lerp(velocity.z, target_velocity.z, ground_acceleration * delta)

	else:
		velocity.x = lerp(velocity.x, 0.0, ground_friction * delta)
		velocity.z = lerp(velocity.z, 0.0, ground_friction * delta)
	

	

	
	move_and_slide()
	# Rotate Body
	if velocity.length_squared() > 0 and not global_position.is_equal_approx(global_position + Vector3(velocity.x, 0, -velocity.z).normalized()):
		var target_rotation:Transform3D = transform.looking_at(global_position + Vector3(velocity.x, 0, -velocity.z).normalized(), Vector3.UP)
		get_node("Body").rotation.y = -target_rotation.basis.get_euler().y
 
func is_player():
	return true

 


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_camera"):
		toggle_camera()
		

func toggle_camera():
	if camera_mode == "t":
		$CameraPivot.position = first_p_arm_position
		$CameraPivot/SpringArm3D.spring_length = first_p_arm_length
		$Body.visible = false
		camera_mode = "f"
	else:
		$CameraPivot.position = third_p_arm_position
		$CameraPivot/SpringArm3D.spring_length = third_p_arm_length
		$Body.visible = true
		camera_mode = "t"


 
