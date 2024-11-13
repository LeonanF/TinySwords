extends CharacterBody2D

@export var speed: float = 100
@export var random_change_interval: float = 2.0
@export var stop_duration: float = 1.0
@export var move_duration: float = 3.0
@export var health = 50

@onready var sheep_sprite = $Sprite

var meat_value : int
var patrol_direction: Vector2 = Vector2(1, 0)
var change_direction_timer: float = 0.0
var move_timer: float = 0.0
var stop_timer: float = 0.0
var is_moving: bool = true

signal sheep_killed(meat_value)

func _ready():
	meat_value = randf_range(2,10)
	change_direction_timer = random_change_interval
	move_timer = move_duration
	stop_timer = stop_duration

func _physics_process(delta):
	
	var players = get_tree().get_nodes_in_group("Players")
	
	for player in players:
		if player is Warrior and not player.is_connected("attack_done", Callable(self, "_on_player_attack_received")):
			player.connect("attack_done", Callable(self, "_on_player_attack_received"))
	
	if is_moving:
		move_timer -= delta
		if move_timer <= 0:
			is_moving = false
			move_timer = move_duration
			stop_timer = stop_duration

		velocity = patrol_direction * speed
		
		move_and_slide()

		if sheep_sprite.animation != "bouncing":
			sheep_sprite.play("bouncing")
		
		if patrol_direction.x < 0:
			sheep_sprite.flip_h = true
		else:
			sheep_sprite.flip_h = false
	else:
		stop_timer -= delta
		if stop_timer <= 0:
			is_moving = true
			stop_timer = stop_duration

		if sheep_sprite.animation != "idle":
			sheep_sprite.play("idle")

	if change_direction_timer <= 0 and is_moving:
		choose_new_patrol_direction()
		change_direction_timer = random_change_interval + randf_range(-random_change_interval, random_change_interval)

	if get_slide_collision_count() > 0:
		patrol_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()

func choose_new_patrol_direction():
	patrol_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	
func _on_player_attack_received(damage, body):
	if body == self:
		flash_red()
		health -= damage
		if health <= 0:
			sheep_killed.emit(meat_value)
			queue_free()
			

func flash_red():
	sheep_sprite.modulate = Color(1,0,0)
	await get_tree().create_timer(0.2).timeout
	sheep_sprite.modulate = Color(1,1,1)
