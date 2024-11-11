extends CharacterBody2D

const SPEED = 200
@export var damage: int = 10
@export var health: int = 50
@export var detection_range: float = 200

var patrol_radius: float = 100
var patrol_timer = 0.0
var is_patrolling = false
var patrol_center: Vector2
var patrol_direction = Vector2()

var direction = Vector2.LEFT

var player_in_perception_range = false

var player = null
var is_attacking = false

@onready var attackCooldown = $AttackCooldown
@onready var enemy_sprite = $Sprite
@onready var perception_range = $PerceptionRange
@onready var nav_agent = $NavigationEnemy
@onready var start_patrolling = $StartPatrolling

signal attack_done(damage_amount)

func _ready():
	patrol_center = global_position
	var players = get_tree().get_nodes_in_group("Players")
	
	for player in players:
		player.connect("attack_done", Callable(self, "_on_player_attack_received"))
		
	perception_range.connect("body_entered", Callable(self, "_on_body_entered"))
	perception_range.connect("body_exited", Callable(self, "_on_body_exited"))
	enemy_sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))
	enemy_sprite.connect("animation_changed", Callable(self, "_on_animation_changed"))

func _on_animation_changed(old_name, new_name):
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
	
	if is_instance_valid(player) and position.distance_to(player.global_position) <= detection_range and not is_attacking and not player_in_perception_range and start_patrolling.is_stopped():
			nav_agent.target_position = player.global_position
			
			var current_agent_position = global_position
			var next_path_position = nav_agent.get_next_path_position()
			velocity = current_agent_position.direction_to(next_path_position) * SPEED
		
			enemy_sprite.play("walk")
			
			move_and_slide()
			if has_collided_with_wall():
				on_collide_patrol_direction()
				
	elif not player_in_perception_range and not is_attacking:
		patrol(delta)
		
	enemy_sprite.flip_h = false if velocity.x >= 0 else true
	

func patrol(delta):
	if not is_patrolling:
		patrol_timer += delta
		if patrol_timer >= 0.1:
			is_patrolling = true
			patrol_timer = 0.0

	if is_patrolling:
		if patrol_timer <= 0 or has_collided_with_wall():
			choose_new_patrol_direction()
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
	start_patrolling.stop()
	start_patrolling.start()

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
	if body.is_in_group("Players"):
		player_in_perception_range = true
		player = body
		face_player()

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
		

func face_player():
	if player:
		var direction_to_player = (player.get_node("Sprite").global_position - get_node("Sprite").global_position)

		if direction_to_player.x < 0:
			enemy_sprite.flip_h = true
		else:
			enemy_sprite.flip_h = false

func _on_player_attack_received(damage_amount, body):
	if body == self:
		health -= damage_amount
		
		_flash_damage_effect()

		if health <= 0:
			die()

func die():
	queue_free()

func _flash_damage_effect():
	
	enemy_sprite.modulate = Color(1, 0, 0)

	await get_tree().create_timer(0.2).timeout
	
	enemy_sprite.modulate = Color(1, 1, 1)
	
