extends Node2D

@onready var camera = get_parent().get_node("Camera")
@onready var building_queue = $BuildingQueue
@onready var map = get_parent().get_node("Map")

var WarriorScene = preload("res://Scenes/Warrior.tscn")
var EnemyScene = preload("res://Scenes/Enemy.tscn")
var GameOverScreenScene = preload("res://Scenes/GameOverScreen.tscn")
var HealthBarScene = preload("res://Scenes/HealthBar.tscn")
var ConstructionModeScene = preload("res://Scenes/ConstructionMode.tscn")
var PawnScene = preload("res://Scenes/Pawn.tscn")
var meat_banner_scene: PackedScene = preload("res://Scenes/ResourceBanner.tscn")
var wood_banner_scene: PackedScene = preload("res://Scenes/ResourceBanner.tscn")
var gold_banner_scene: PackedScene = preload("res://Scenes/ResourceBanner.tscn")

var on_building_mode = false

var player : Player
var playerType = "Warrior"
var is_switching = false
var last_position= Vector2(-600,600)
var last_health = 100
var last_wood = 0
var last_meat = 0
var last_gold = 0

var health_bar
var wood_banner
var meat_banner
var gold_banner
var game_over_screen
var construction_mode

signal building_entered
signal building_exited

func _ready():
	
	health_bar = HealthBarScene.instantiate()
	add_child(health_bar)
	
	meat_banner = meat_banner_scene.instantiate()
	wood_banner = wood_banner_scene.instantiate()
	gold_banner = gold_banner_scene.instantiate()
	add_child(meat_banner)
	add_child(wood_banner)
	add_child(gold_banner)
	
	meat_banner.get_node("Control").set_resource("meat")
	wood_banner.get_node("Control").set_resource("wood")
	gold_banner.get_node("Control").set_resource("gold")
	
	setup_warrior()
		
	game_over_screen = GameOverScreenScene.instantiate()
	camera.add_child(game_over_screen)
	game_over_screen.visible = false

func _process(_delta):
	swap_characters()

func swap_characters():
	if Input.is_action_just_released("swap_character") and not is_switching:
		is_switching = true
		if playerType == "Pawn":
			setup_warrior()
		elif playerType == "Warrior":
			setup_pawn()

func setup_pawn():

	playerType = "Pawn"
	
	if player:
		sync_character_state()
		player.queue_free()
	
	player = PawnScene.instantiate()
	map.add_child(player)
	
	player.connect("game_over", Callable(self, "_on_game_over"))
	player.position = last_position
	player.health = last_health
	player.meat = last_meat
	player.wood = last_wood
	player.gold = last_gold
	
	player.setup_resource_banners(meat_banner, wood_banner, gold_banner)
	player.setup_health_bar(health_bar.get_node("HealthBar"))
	
	await get_tree().create_timer(2).timeout
	is_switching = false
	

func setup_warrior():
	
	playerType = "Warrior"
	
	if player:
		sync_character_state()
		player.queue_free()
	
	player = WarriorScene.instantiate()
	map.add_child(player)
	
	player.connect("game_over", Callable(self, "_on_game_over"))
	player.position = last_position
	player.health = last_health
	player.meat = last_meat
	player.wood = last_wood
	player.gold = last_gold
	
	player.setup_resource_banners(meat_banner, wood_banner, gold_banner)
	player.setup_health_bar(health_bar.get_node("HealthBar"))
	
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		player.connect("attack_done", Callable(enemy, "_on_player_attack_received"))
	
	await get_tree().create_timer(2).timeout
	
	is_switching = false

func sync_character_state():
	last_health = player.health
	last_position = player.position
	last_wood = player.wood
	last_meat = player.meat
	last_gold = player.gold

func _on_game_over(p_camera_position, p_camera_zoom):
	camera.enabled = true
	camera.zoom = Vector2i(0.75,0.75)
	game_over_screen.show_game_over()
