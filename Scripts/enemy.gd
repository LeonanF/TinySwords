extends CharacterBody2D

const SPEED = 200
@export var damage: int = 15
@export var health: int = 75
@export var detection_range: float = 200
@export var gold_value: int = 10

var patrol_radius: float = 100
var patrol_timer = 0.0
var is_patrolling = false
var can_search_player = false
var patrol_center: Vector2
var patrol_direction = Vector2()

var direction = Vector2.LEFT

var player_in_perception_range = false

var player = null
var is_attacking = false

signal enemy_killed(gold_amount)

@onready var attackCooldown = $AttackCooldown
@onready var enemy_sprite = $Sprite
@onready var perception_range = $PerceptionRange
@onready var nav_agent = $NavigationEnemy
@onready var start_patrolling = $StartPatrolling
@onready var attack_audio = $AttackAudio
@onready var enemy_hitted_audio = $EnemyHittedAudio

signal attack_done(damage_amount)

func _ready():
	gold_value = randf_range(8, 15)
	patrol_center = global_position
	var players = get_tree().get_nodes_in_group("Players")
	
	for player in players:
		player.connect("attack_done", Callable(self, "_on_player_attack_received"))
		
	perception_range.connect("body_entered", Callable(self, "_on_body_entered"))
	perception_range.connect("body_exited", Callable(self, "_on_body_exited"))
	enemy_sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))
	enemy_sprite.connect("animation_changed", Callable(self, "_on_animation_changed"))

func _on_animation_changed(old_name, _new_name):
	if old_name == "attack" or old_name =="attack_up" or old_name == "attack_down":
		attackCooldown.stop()
		is_attacking = false
		attackCooldown.start()

func _on_animation_finished():
	if enemy_sprite.animation=="attack" or enemy_sprite.animation == "attack_down" or enemy_sprite.animation=="attack_up":
		if player_in_perception_range:
			attack_done.emit(damage)
		is_attacking = false
		attackCooldown.stop()
		attackCooldown.start()
	enemy_sprite.play("idle")
	

func _physics_process(delta):
	for player_actual in get_tree().get_nodes_in_group("Players"):
		player = player_actual
	
	if not is_instance_valid(player):
		enemy_sprite.play("idle")
		return
		
	if player_in_perception_range and not is_attacking:
		attack()
		return
	
	if start_patrolling.is_stopped():
		can_search_player = true
		start_patrolling.start()
	
	if not player_in_perception_range:
		enemy_sprite.flip_h = false if velocity.x >= 0 else true
		if global_position.distance_to(player.global_position) <= detection_range and can_search_player and not has_collided_with_wall():
			nav_agent.target_position = player.global_position
			var current_agent_position = global_position
			var next_path_position = nav_agent.get_next_path_position()
			velocity = current_agent_position.direction_to(next_path_position) * SPEED
			enemy_sprite.play("walk")
			
			move_and_slide()
			
			if has_collided_with_wall():
				can_search_player = false
				start_patrolling.start()
		else:
			patrol(delta)
			
	

func patrol(delta):
	
	if not is_patrolling:
		start_patrolling.stop()
		start_patrolling.start()
		patrol_timer+=delta
		if patrol_timer>=0.1:
			is_patrolling = true
			patrol_timer = 0
			
	if is_patrolling:
		if patrol_timer <= 0:
			choose_new_patrol_direction()
			patrol_timer = 2.0
		if has_collided_with_wall():
			on_collide_patrol_direction()
			patrol_timer = 2.0

		velocity = patrol_direction * SPEED
		move_and_slide()
		enemy_sprite.play("walk")

func has_collided_with_wall() -> bool:
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision and collision.get_normal().dot(patrol_direction) < 0:
			return true
	return false

func on_collide_patrol_direction():

	var angle = randf_range(0, 2 * PI)
	patrol_direction = Vector2(cos(angle), sin(angle)).normalized()
	
	var target_position = patrol_center + (patrol_direction * patrol_radius)
	if patrol_center.distance_to(target_position) > patrol_radius:
		patrol_direction *= -1

func choose_new_patrol_direction():
	var angle = randf_range(0, 2 * PI)
	patrol_direction = Vector2(cos(angle), sin(angle)).normalized()
	
	var target_position = patrol_center + (patrol_direction * patrol_radius)
	if patrol_center.distance_to(target_position) > patrol_radius:
		patrol_direction *= -1

func _on_body_entered(body):
	if is_instance_valid(body) and body.is_in_group("Players"):
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(global_position, body.global_position)
		query.exclude = [self, body]
		
		var result = space_state.intersect_ray(query)
		
		if not result:
			player_in_perception_range = true
			player = body
			face_player()
		else:
			player_in_perception_range = false
			player = null

func _on_body_exited(body):
	if body.is_in_group("Players"):
		player_in_perception_range = false
		is_attacking = false
		player = null

func attack():
	if is_instance_valid(player) and not is_attacking and attackCooldown.is_stopped():
		
		is_attacking = true
		
		var direction_to_player = get_node("Sprite").global_position - player.get_node("Sprite").global_position 
		
		if abs(direction_to_player.x) > abs(direction_to_player.y):
			if direction_to_player.x > 0:
				enemy_sprite.flip_h = true
			else:
				enemy_sprite.flip_h = false
			enemy_sprite.play("attack")
		elif direction_to_player.y > 0:
			enemy_sprite.play("attack_up")
		else:
			enemy_sprite.play("attack_down")
		
		await get_tree().create_timer(0.3).timeout
		attack_audio.play()

func face_player():
	if player:
		var direction_to_player = (player.get_node("Sprite").global_position - get_node("Sprite").global_position)
		
		if direction_to_player.x < 0:
			enemy_sprite.flip_h = true
		else:
			enemy_sprite.flip_h = false


func _on_player_attack_received(damage_amount, body):
	if body == self:
		enemy_hitted_audio.play()
		health -= damage_amount
		
		_flash_damage_effect()

		if health <= 0:
			die()

func die():
	enemy_killed.emit(gold_value)
	queue_free()

func _flash_damage_effect():
	
	enemy_sprite.modulate = Color(1, 0, 0)

	await get_tree().create_timer(0.2).timeout
	
	enemy_sprite.modulate = Color(1, 1, 1)
	
