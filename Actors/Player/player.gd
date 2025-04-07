class_name Player
extends CharacterBody3D
 
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var ground_acceleration: float = 8.0
@export var drone: PackedScene
@export_category("Movement")
@export var jump_height: float = 2.0
@export var walk_speed = 8.0
@export var run_speed = 15.0
@export var air_acceleration: float = 5.0
@export var ground_friction: float = 30
@export var air_friction: float = 2.0
var current_gravity_direction = Vector3.DOWN
@export_category("Camera")
@export_enum("t", "f") var camera_mode = "t"
@export var third_p_arm_position:Vector3 = Vector3(0.0, 3.0, 0.0) 
@export var third_p_arm_length: float = -3
@export var first_p_arm_position:Vector3 = Vector3(0.0, 2.0, 0.0) #adjust to player height
@export var first_p_arm_length: float = 0
@export_category("animation")
#region new_variables
signal died
@onready var item_picker: Area3D = $Item_picker
@onready var can_move_timer: Timer = $Timers/can_move_timer
@onready var dodging_timer: Timer = $Timers/dodging_timer
@onready var attacking_timer: Timer = $Timers/attacking_timer
@onready var jumping_timer: Timer = $Timers/jumping_timer
@onready var health_bar: TextureProgressBar = $HealthBar
@onready var equip_sockets: Array[BoneAttachment3D] = [$right_hand, $left_hand]
@export var max_health : int = 100
@onready var current_health : int = max_health
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var body: Marker3D = $Body
@export var can_move : bool = true
var nearest_item: Node3D
var _main_hand : Node3D
var _off_hand : Node3D
var _has_shield_equipped : bool
var damage_reduction : int = 0
var blend_amount: float = 0.1
var blend_speed : float = 4.0
var blend_node : AnimationNodeBlend2 
var locomo_state : AnimationNodeStateMachinePlayback 
var action_state : AnimationNodeStateMachinePlayback 
var hit_state : AnimationNodeStateMachinePlayback 
var root : AnimationNodeStateMachinePlayback
var dodge_direction: Vector3 = Vector3.ZERO
var dodge_force: float = 10.0
var _direction := Vector3.ZERO
@export var is_jumping: bool
@export var is_dodging: bool
@export var is_attacking: bool
@export var interrupted: bool
#endregion
 
func _ready() -> void:
	blend_node = animation_tree.tree_root.get_node("Hit").get_node("BlendTree").get_node("Blend2")
	locomo_state = animation_tree["parameters/Hit/BlendTree/Locomotion/playback"]
	action_state = animation_tree["parameters/Hit/BlendTree/Action/playback"]
	hit_state = animation_tree["parameters/Hit/playback"]
	root = animation_tree["parameters/playback"]
	can_move_timer.timeout.connect(on_can_move_timer_timeout)
	dodging_timer.timeout.connect(on_dodging_timer_timeout)
	attacking_timer.timeout.connect(on_attacking_timer_timeout)
	jumping_timer.timeout.connect(on_jumping_timer_timeout)
	#test_dialog()
	
 
func _process(delta: float) -> void:
	if action_state.get_current_node() == "A_idle":
		blend_amount = move_toward(blend_amount, 0.1, delta * blend_speed)
	else:
		blend_amount = move_toward(blend_amount, 0.99, delta * blend_speed)
	animation_tree.set("parameters/Hit/BlendTree/Blend2/blend_amount", blend_amount)

func _physics_process(delta: float) -> void:
	if can_move == false:
		return
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	var direction: Vector3 = Vector3.ZERO
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	direction.z = Input.get_action_strength("down") - Input.get_action_strength("up")
	direction = direction.normalized()
	var camera:Camera3D = get_viewport().get_camera_3d()
	direction = (camera.global_transform.basis * transform.basis * direction).normalized()
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
			
	animation_tree.set("parameters/Hit/BlendTree/Locomotion/movement/blend_position", velocity.length() / run_speed) 
	_direction = direction
	handle_filters(velocity != Vector3.ZERO)
	
	move_and_slide()
	# Rotate Body
	if velocity.length_squared() > 0 and not global_position.is_equal_approx(global_position + Vector3(velocity.x, 0, -velocity.z).normalized()):
		var target_rotation:Transform3D = transform.looking_at(global_position + Vector3(velocity.x, 0, -velocity.z).normalized(), Vector3.UP)
		get_node("Body").rotation.y = -target_rotation.basis.get_euler().y

func is_player():
	return true

 
#region anim-tree

func handle_filters(is_moving: bool) -> void:
	blend_node.filter_enabled = is_moving
 
func dodge_velocity() -> void:
	if _direction == Vector3.ZERO:
		dodge_direction = body.global_basis.z 
	else:
		dodge_direction = _direction.normalized()
	velocity = dodge_direction * dodge_force
 
func interrupt_actions() -> void:
	interrupted = true
	is_jumping = false
	is_dodging = false
	is_attacking = false
	await get_tree().create_timer(1).timeout
	interrupted = false
	#deactivate_all_hit_boxes()
 
func restrict_movement(time: float) -> void:
	can_move = false
	can_move_timer.wait_time = time
	can_move_timer.start()
	
func on_can_move_timer_timeout() -> void:
	can_move = true

func on_dodging_timer_timeout() -> void:
	is_dodging = false
	
func on_attacking_timer_timeout() -> void:
	is_attacking = false

func on_jumping_timer_timeout() -> void:
	is_jumping = false
	
#endregion 

func _unhandled_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("jump"):
		if is_jumping == false and is_on_floor():
			is_jumping = true
			locomo_state.travel("A_jump")
			velocity.y = sqrt(2 * gravity * jump_height)
			jumping_timer.start()
			
	elif event.is_action_pressed("dodge"):
		if is_dodging == false:
			is_dodging = true
			locomo_state.travel("A_dodge")
			dodging_timer.start()
			await get_tree().create_timer(0.3).timeout
			dodge_velocity()
		
	elif event.is_action_pressed("right_click"):
		action_state.travel("A_aim")
 
	elif event.is_action_released("right_click"):
		action_state.travel("A_idle")
		
	elif event.is_action_pressed("click") and is_attacking == false and action_state.get_current_node() == "A_aim" :
		is_attacking = true
		action_state.travel("A_shoot")
		attacking_timer.start
 
	elif event.is_action_pressed("reload"):
		action_state.travel("A_reload")
		
	elif event.is_action_pressed("interact"):
		nearest_item = item_picker.get_nearest_item()
		if nearest_item:
			#$/root/Game.inventory.add_item(nearest_item.resource)
			doff(0)
			don(nearest_item.resource)
			nearest_item.queue_free()
		#else:
			#interact()
	elif event.is_action_pressed("inventory"):
		$/root/Game.toggle_inventory()
		
	elif event.is_action_pressed("toggle_camera"):
		toggle_camera()
	elif event.is_action_pressed("enter_drone") and get_tree().get_first_node_in_group("Drone") == null:
		activate_drone()
		
func take_damage(amount: int, direction : Vector3 = Vector3.ZERO) -> void:
	if is_dodging:
		return
	#if action_state.get_current_node() == "A_block" and direction.dot(body.global_basis.z) > 0.5:
		#amount = max(amount - damage_reduction, 0)
		#if amount == 0:
			#return
	current_health = max(current_health - amount, 0)
	interrupt_actions()
	health_bar._set_value(float(current_health) / max_health)
	var _from_behind = direction.dot(body.global_basis.z) < 0
	if current_health == 0: 
		died.emit()
		root.travel("A_die")
		collision_layer = 0
		collision_mask = 1
	else:
		restrict_movement(2.3)
		hit_state.travel("A_hit")
 
func toggle_camera():
	if camera_mode == "t":
		$CameraPivotPivot/CameraPivot.position = first_p_arm_position
		$CameraPivotPivot/CameraPivot/SpringArm3D.spring_length = first_p_arm_length
		$Body.visible = false
		camera_mode = "f"
	else:
		$CameraPivotPivot/CameraPivot.position = third_p_arm_position
		$CameraPivotPivot/CameraPivot/SpringArm3D.spring_length = third_p_arm_length
		$Body.visible = true
		camera_mode = "t"
		
func activate_drone():
	var _drone = drone.instantiate()
	get_parent().add_child(_drone)
	_drone.global_position = self.global_position + Vector3(0.0, 10, 0.0)
	_drone.activate()
	deactivate()
	
func activate():
	add_to_group("Player")
	remove_from_group("PlayerDeactive")
	can_move = true
	$CameraPivotPivot/CameraPivot/SpringArm3D/Camera3D.current = true
	get_tree().get_first_node_in_group("Drone").queue_free()
	
	
func deactivate():
	remove_from_group("Player")
	add_to_group("PlayerDeactive")
	can_move = false
	
func test_dialog() -> void:
	await get_tree().create_timer(5).timeout
	var choice : int = await $/root/Game.dialog.display_options("This is to test dialog system",
	["tell me more",
	"take player control for 5 sec",
	"skip"
	])
	match choice:
		0:
			await $/root/Game.dialog.display_line("dialog boxes can be used for different purposes", "speaker")

		1:
			can_move = false
			await get_tree().create_timer(5).timeout
			can_move = true

		2:
			pass
 
func don(item: Item) -> void:
	var instance : Node3D = load(item.scene).instantiate()
	equip_sockets[item.type].add_child(instance)
	#instance.freeze = true
 
func doff(socket: int) -> void:
	if socket == Enums.EquipmentType.MAIN_HAND:
		_main_hand = null
 
	elif socket == Enums.EquipmentType.OFF_HAND:
		_off_hand = null
 
	if equip_sockets[socket].get_child_count() > 0:
		equip_sockets[socket].get_child(0).queue_free()
 
