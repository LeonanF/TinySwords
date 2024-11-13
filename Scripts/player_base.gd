extends CharacterBody2D

class_name Player

@export var damage = 10
@export var max_health = 100
@onready var player_sprite = $Sprite
@onready var camera = $Camera
@onready var attacked_timer = get_parent().get_node("AttackedTimer")
@onready var regen_timer = get_parent().get_node("RegenerationTimer")
@onready var game_controller = get_parent().get_parent().get_node("GameController")
@onready var player_eat_audio = $PlayerEatAudio
@onready var player_hitted_audio = $PlayerHittedAudio
@onready var player_walk_audio = $WalkAudio
@export var SPEED = 300.0
@export var wood = 0
@export var meat = 0
@export var gold = 0
@export var eat_amount = 10
@export var eat_health_regen = 20
var health: int = max_health
var health_bar : TextureProgressBar
var meat_banner: CanvasLayer
var wood_banner: CanvasLayer
var gold_banner: CanvasLayer

var invulnerable = false
var is_walking = false

var direction = Vector2.ZERO

signal game_over

func setup_resource_banners(meat_banner, wood_banner, gold_banner):
	self.meat_banner = meat_banner
	self.wood_banner = wood_banner
	self.gold_banner = gold_banner
	update_resource_banners()
	
func setup_health_bar(bar: TextureProgressBar):
	health_bar = bar
	update_health_bar()

func has_wood(cost):
	return wood >= cost

func deduct_wood(amount):
	wood -= amount
	update_resource_banners()

func has_gold(cost):
	return gold >= cost

func deduct_gold(amount):
	gold -= amount
	update_resource_banners()

func has_meat(cost):
	return meat >= cost

func deduct_meat(amount):
	meat -= amount
	update_resource_banners()

func gather_resource(resource_type: String, amount: int):
	match resource_type:
		"meat":
			meat += amount
		"wood":
			wood += amount
		"gold":
			gold += amount
			player_sprite.modulate = Color(1, 0.84, 0)
			await get_tree().create_timer(0.2).timeout
			player_sprite.modulate = Color(1, 1, 1)

	update_resource_banners()

func _ready():
	pass

func _process(delta):
	if regen_timer and attacked_timer and regen_timer.is_stopped() and attacked_timer.is_stopped() and health<max_health:
		health += 1
		regen_timer.start()
		update_health_bar()
	if Input.is_action_just_released("eat"):
		if has_meat(eat_amount) and max_health - health > eat_health_regen:
			eat()
			deduct_meat(eat_amount)
	if not is_walking:
		player_walk_audio.stop()

func eat():
	health+=eat_health_regen
	player_eat_audio.play()
	update_health_bar()
	update_resource_banners()

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
		if not player_walk_audio.playing:
			player_walk_audio.play()
	if Input.is_action_pressed("ui_left"):
		_on_move_left()
		if not player_walk_audio.playing:
			player_walk_audio.play()
	if Input.is_action_pressed("ui_down"):
		_on_move_down()
		if not player_walk_audio.playing:
			player_walk_audio.play()
	if Input.is_action_pressed("ui_up"):
		_on_move_up()
		if not player_walk_audio.playing:
			player_walk_audio.play()

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
	player_walk_audio.stop()

func update_health_bar():
	health_bar.value = health
	
func update_resource_banners():
	if meat_banner:
		meat_banner.get_node("Control").update_resource_value(meat)
	if wood_banner:
		wood_banner.get_node("Control").update_resource_value(wood)
	if gold_banner:
		gold_banner.get_node("Control").update_resource_value(gold)
		
func die():
	game_over.emit($Camera.position, $Camera.zoom)
	queue_free()

func _flash_damage_effect():
	invulnerable = true
	player_sprite.modulate = Color(1, 0, 0)
	
	await get_tree().create_timer(0.2).timeout
	
	player_sprite.modulate = Color(1, 1, 1)
	invulnerable = false

func _on_enemy_attack_received(damage):
	player_hitted_audio.play()
	attacked_timer.stop()
	attacked_timer.start()
	health -= damage
	_flash_damage_effect()
	update_health_bar()
	
	if health <= 0:
		die()
