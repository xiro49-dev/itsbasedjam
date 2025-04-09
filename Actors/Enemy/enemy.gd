extends CharacterBody3D
class_name Enemy
var target_point: Vector3 
@onready var nav_agent = $Agent
@export var speed: int = 8
@export var wait_duration = 0.5
@export var attack_range: float = 2.0
@export var attack_dmg: float = 5.0
@export var attack_interval: float = 1.0
@export var avoidance_radius: float = 5
@export var avoidance_strength: float = 5
@export var can_attack:bool = true
var last_attack_time: float = 0.0
var is_waiting: bool = false
var wait_timer: float = 0.0

@export var type: Enums.EnemyTypes = Enums.EnemyTypes.Random

#region new_variables
signal died
@onready var audio_stream_player: AudioStreamPlayer3D = $AudioStreamPlayer
@onready var health_bar: TextureProgressBar = $healthbar3d/SubViewport/TextureProgressBar
@onready var en_movment: Timer = $en_movment
@onready var animation_tree: AnimationTree = $AnimationTree
@export var max_health : int = 100
@onready var current_health : int = max_health
var blend_amount: float = 0.1
var blend_speed : float = 4.0
var blend_node : AnimationNodeBlend2
var locomo_state : AnimationNodeStateMachinePlayback 
var action_state : AnimationNodeStateMachinePlayback 
var hit_state : AnimationNodeStateMachinePlayback 
var root : AnimationNodeStateMachinePlayback
var can_move
#endregion
 
func _ready() -> void:
	blend_node = animation_tree.tree_root.get_node("Hit").get_node("BlendTree").get_node("Blend2")
	locomo_state = animation_tree["parameters/Hit/BlendTree/Locomotion/playback"]
	action_state = animation_tree["parameters/Hit/BlendTree/Action/playback"]
	hit_state = animation_tree["parameters/Hit/playback"]
	root = animation_tree["parameters/playback"]
	en_movment.timeout.connect(on_enable_movment_timoeout)
	died.connect(on_died)

func _process(delta: float) -> void:
	if action_state.get_current_node() == "A_idle":
		blend_amount = move_toward(blend_amount, 0.1, delta * blend_speed)
	else:
		blend_amount = move_toward(blend_amount, 0.99, delta * blend_speed)
	animation_tree.set("parameters/Hit/BlendTree/Blend2/blend_amount", blend_amount)

func handle_wait(delta: float):
	if is_waiting:
		wait_timer += delta
		if wait_timer >= wait_duration:
			is_waiting = false
			wait_timer = 0.0
			return false
		else:
			velocity = Vector3.ZERO
			move_and_slide()
			return true
			
func _physics_process(delta: float) -> void:
	if can_move == false:
		return
	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta * 20
	var player = get_tree().get_first_node_in_group("Player")
	
	if handle_wait(delta):
		return
	if not player:
		return
	match type:
		Enums.EnemyTypes.Random:
			random_walker(delta, player)
		Enums.EnemyTypes.Chase:
			chase(delta, player)
	animation_tree.set("parameters/Hit/BlendTree/Locomotion/movement/blend_position", velocity.length() / speed * 2) 
	handle_filters(velocity != Vector3.ZERO)
	 
func attack(delta: float):
	if Time.get_unix_time_from_system() - last_attack_time >= attack_interval:
		action_state.travel("A_shoot_no_aim")
		get_parent().shuffle()

func pick_random_point():
	target_point = NavigationServer3D.map_get_random_point(nav_agent.get_navigation_map(), 1, false)
	nav_agent.set_target_position(target_point)
	while not nav_agent.is_target_reachable():
		target_point = NavigationServer3D.map_get_random_point(nav_agent.get_navigation_map(), 1, false)
		nav_agent.set_target_position(target_point)

func random_walker(delta:float, player: Node3D):
	if not player:
		return
	if not target_point:
		pick_random_point()
	if player and global_position.distance_to(player.global_position) <= attack_range and can_attack:
		attack(delta)
	var next_nav_point = nav_agent.get_next_path_position()
	velocity = (next_nav_point - global_transform.origin).normalized() * speed
	rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * ProjectSettings.get_setting("physics/3d/default_gravity"))
	move_and_slide()
	
func chase(delta:float, player: Node3D):
	if not player:
		return
	if player and global_position.distance_to(player.global_position) <= attack_range and can_attack:
		attack(delta)
	nav_agent.set_target_position(player.global_position)
	var avoidance_vector = calculate_avoidance()
	var next_nav_point = nav_agent.get_next_path_position()
	velocity = ((next_nav_point - global_transform.origin).normalized() + avoidance_vector) * speed
	rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * ProjectSettings.get_setting("physics/3d/default_gravity"))
	move_and_slide()
	
func _on_agent_navigation_finished() -> void:
	pick_random_point()

func _on_agent_target_reached() -> void:
	pick_random_point()

func _on_hurt_area_body_entered(body: Node3D) -> void:
	if body.has_method("is_player"):
		if body.is_player():
			var knockback_direction = (body.global_position - global_position).normalized()
			#body.velocity += knockback_direction * knockback_strength
			body.take_damage(attack_dmg)
			last_attack_time = Time.get_unix_time_from_system()
			is_waiting = true
			print("Player Hit")

func _on_eyes_spotted(posistion: Vector3) -> void:
	target_point = posistion
	nav_agent.set_target_position(target_point)

func clear_velocity():
	velocity = Vector3.ZERO
	
func calculate_avoidance():
	var avoidance_vector = Vector3.ZERO
	var agents = get_tree().get_nodes_in_group("ai") 
	for agent in agents:
		if agent != self and agent.has_node("Agent"):
			var distance = global_position.distance_to(agent.global_position)
			if distance < avoidance_radius:
				var avoidance_direction = (global_position - agent.global_position).normalized()
				avoidance_vector += avoidance_direction * (1.0 - distance / avoidance_radius) * avoidance_strength
	if can_attack:
		return Vector3.ZERO
	return avoidance_vector

func take_damage(amount: int, direction : Vector3 = Vector3.ZERO) -> void:
	#if action_state.get_current_node() == "A_block" and direction.dot(body.global_basis.z) > 0.5:
		#amount = max(amount - damage_reduction, 0)
		#if amount == 0:
			#return
	current_health = max(current_health - amount, 0)
	health_bar._set_value(float(current_health) / max_health)
	#var _from_behind = direction.dot(body.global_basis.z) < 0
	if current_health == 0: 
		restrict_movement(4.0)
		root.travel("A_die")
		died.emit()
		collision_layer = 0
		collision_mask = 1
	else:
		restrict_movement(2.3)
		hit_state.travel("A_hit")
		
func restrict_movement(time: float) -> void:
	can_move = false
	en_movment.wait_time = time
	en_movment.start()
 
func on_enable_movment_timoeout() -> void:
	can_move = true
 
func on_died() -> void:
	await get_tree().create_timer(3).timeout
	queue_free()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		SaveLoad.progress.coins += 10
		Music.play_sfx(audio_stream_player, Music.TEST_SFX)

func handle_filters(is_moving: bool) -> void:
	blend_node.filter_enabled = is_moving
