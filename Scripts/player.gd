extends "res://Scripts/player_base.gd"

@onready var attack_cooldown = $AttackCooldown
@onready var attack_range = $AttackRange


var enemy_in_range = false
var is_attacking = false
var on_attack_cooldown = false
var is_double_attacking = false

var enemies = []

signal attack_done(amount, body)

func _ready():
	attack_range.rotation = deg_to_rad(90)
	attack_range.connect("body_entered", Callable(self, "_on_attack_range_entered"))
	attack_range.connect("body_exited", Callable(self, "_on_attack_range_exited"))
	player_sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))
	
	var gameController = get_parent()
	gameController.connect("building_entered", Callable(self, "_on_building_entered"))
	gameController.connect("building_exited", Callable(self, "_on_building_exited"))

func _on_animation_finished():
	var previous_animation = player_sprite.animation
	player_sprite.play("idle")
	
	if previous_animation == "basic_attack" or previous_animation == "basic_attack_up" or previous_animation == "basic_attack_down":
		if is_double_attacking:
			double_attack()
			
		on_attack_cooldown = true
		is_attacking = false
		attack_cooldown.stop()
		attack_cooldown.start()

		await attack_cooldown.timeout
		
		on_attack_cooldown = false
		
	if previous_animation == "double_attack" or previous_animation == "double_attack_up" or previous_animation == "double_attack_down":
		is_double_attacking = false

func _physics_process(delta):
	if Input.is_action_just_released("attack") and not is_attacking and not is_double_attacking:
		attack()
	elif Input.is_action_just_released("attack") and is_attacking:
		is_double_attacking = true
	
	if player_sprite.animation == "idle":
		is_attacking = false
		is_double_attacking = false
	
	if is_attacking or is_double_attacking:
		return
	
	var enemies = get_tree().get_nodes_in_group("Enemies")

	if enemies.size() > 0:
		for enemy in enemies:
			if not enemy.is_connected("attack_done", Callable(self, "_on_enemy_attack_received")):
				enemy.connect("attack_done", Callable(self, "_on_enemy_attack_received"))
	
	move()

func _on_body_entered(body):
	if body.is_in_group("Enemies"):
		enemy_in_range = true
		
func attack():
	if not on_attack_cooldown:
		is_attacking = true
		player_sprite.play("basic_attack")
		
		for enemy in enemies:
			var direction_to_player = enemy.get_node("Sprite").global_position - player_sprite.global_position
			if abs(direction_to_player.x) > abs(direction_to_player.y):
				if direction_to_player.x < 0:
					player_sprite.flip_h = true
				else:
					player_sprite.flip_h = false
			elif direction_to_player.y < 0:
				player_sprite.play("basic_attack_up")
			else:
				player_sprite.play("basic_attack_down")
			
			await get_tree().create_timer(0.3).timeout
				
			if enemy_in_range:
				emit_signal("attack_done", damage, enemy)

func double_attack():
	
	for enemy in enemies:
		var direction_to_enemy = enemy.global_position - global_position
		attack_range.rotation = direction_to_enemy.angle()

		if abs(direction_to_enemy.x) > abs(direction_to_enemy.y):
			if direction_to_enemy.x < 0:
				player_sprite.flip_h = true
				player_sprite.play("double_attack")
			else:
				player_sprite.flip_h = false
				player_sprite.play("double_attack")
		else:
			if direction_to_enemy.y < 0:
				player_sprite.play("double_attack_up")
			else:
				player_sprite.play("double_attack_down")

		await get_tree().create_timer(0.3).timeout
		
		if enemy_in_range:
			emit_signal("attack_done", damage, enemy)
		else:
			is_double_attacking = false
		
	
func _on_attack_range_entered(body):
	if body.is_in_group("Enemies") and body not in enemies:
		enemies.append(body)
		enemy_in_range = true

func _on_attack_range_exited(body):
	if body.is_in_group("Enemies"):
		enemies.erase(body)
		enemy_in_range = enemies.size() > 0
