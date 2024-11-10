extends CharacterBody2D

const SPEED = 100.0
@export var damage: int = 10
@export var health: int = 50
@export var attackCooldown: float = 1.5

var direction = Vector2.LEFT

var player_in_perception_range = false

var player = null
var is_attacking = false

@onready var enemy_sprite = $Sprite
@onready var perception_range = $PerceptionRange

signal attack_done(damage_amount)

func _ready():
	var players = get_tree().get_nodes_in_group("Players")
	
	for Player in players:
		Player.connect("attack_done", Callable(self, "_on_player_attack_received"))
		
	perception_range.connect("body_entered", Callable(self, "_on_body_entered"))
	perception_range.connect("body_exited", Callable(self, "_on_body_exited"))
	enemy_sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))

func _on_animation_finished():
	enemy_sprite.play("idle")

func _physics_process(_delta):
	
	if not player_in_perception_range:
		velocity = direction * SPEED
		enemy_sprite.play("walk")
		move_and_slide()

		if is_on_wall():
			direction *= -1

		if direction.x < 0:
			enemy_sprite.flip_h = true
		else:
			enemy_sprite.flip_h = false
	elif not is_attacking:
		attack()

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
	if player and not is_attacking:
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
		
		await get_tree().create_timer(0.45).timeout
		
		if player_in_perception_range:
			attack_done.emit(damage)
			
		await enemy_sprite.animation_finished
		await get_tree().create_timer(attackCooldown).timeout
		
		is_attacking = false
	
func face_player():
	if player:
		var direction_to_player = (player.get_node("Sprite").global_position - get_node("Sprite").global_position)

		if direction_to_player.x < 0:
			enemy_sprite.flip_h = true
		else:
			enemy_sprite.flip_h = false

func _on_player_attack_received(damage_amount):
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
	
