extends CharacterBody2D

class_name Player

@export var damage = 10
@export var max_health = 100
var health: int = max_health
@export var SPEED = 300.0
@export var trees = 100
var health_bar : TextureProgressBar
@onready var player_sprite = $Sprite
var invulnerable = false
var is_walking = false

var direction = Vector2.ZERO

signal game_over


func setup_health_bar(bar: TextureProgressBar):
	health_bar = bar
	update_health_bar()

func has_trees(cost):
	return trees >= cost

func deduct_trees(amount):
	trees -= amount



func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_move_right():
	direction.x += 1
	
func _on_move_left():
	direction.x -= 1

func _on_move_up():
	direction.y -= 1

func _on_move_down():
	direction.y += 1

func move():
	if Input.is_action_pressed("ui_right"):
		_on_move_right()
	if Input.is_action_pressed("ui_left"):
		_on_move_left()
	if Input.is_action_pressed("ui_down"):
		_on_move_down()
	if Input.is_action_pressed("ui_up"):
		_on_move_up()

	if direction != Vector2.ZERO:
		is_walking = true
		velocity = direction.normalized() * SPEED
		player_sprite.play("walk")
		flip()
	else:
		not_moving()

	move_and_slide()
	direction = Vector2.ZERO

func flip():
	if direction.x > 0:
		player_sprite.flip_h = false
	elif direction.x < 0:
		player_sprite.flip_h = true

func not_moving():
	velocity = Vector2.ZERO
	player_sprite.play("idle")

func update_health_bar():
	health_bar.value = health

func die():
	game_over.emit()
	queue_free()

func _flash_damage_effect():
	invulnerable = true
	player_sprite.modulate = Color(1, 0, 0)
	
	await get_tree().create_timer(0.2).timeout
	
	player_sprite.modulate = Color(1, 1, 1)
	invulnerable = false

func _qon_enemy_attack_received(damage):
	health -= damage
	_flash_damage_effect()
	update_health_bar()
	
	if health <= 0:
		die()
