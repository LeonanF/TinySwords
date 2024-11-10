extends Node2D

@onready var camera = get_parent().get_node("Camera")
@onready var building_queue = $BuildingQueue
@onready var map = get_parent().get_node("Map")

var WarriorScene = preload("res://Scenes/Warrior.tscn")
var EnemyScene = preload("res://Scenes/Enemy.tscn")
var GameOverScreenScene = preload("res://Scenes/GameOverScreen.tscn")
var HouseConstructionScene = preload("res://Scenes/HouseConstruction.tscn")
var TowerConstructionScene = preload("res://Scenes/TowerConstruction.tscn")
var HealthBarScene = preload("res://Scenes/HealthBar.tscn")
var ConstructionModeScene = preload("res://Scenes/ConstructionMode.tscn")
var PawnScene = preload("res://Scenes/Pawn.tscn")

var on_building_mode = false

var player
var playerType = "Warrior"
var is_switching = false
var last_position= Vector2(-600,600)
var last_health = 100

var health_bar
var enemies = []
var game_over_screen
var construction_mode

signal building_entered
signal building_exited

func _ready():
	
	health_bar = HealthBarScene.instantiate()
	add_child(health_bar)
	
	setup_warrior()
	
	for i in range(1):
		var enemy = EnemyScene.instantiate()
		map.add_child(enemy)
		enemies.append(enemy)
	
	game_over_screen = GameOverScreenScene.instantiate()
	add_child(game_over_screen)
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
	
	player.position = last_position
	player.health = last_health
	
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
	
	player.position = last_position
	player.health = last_health
	
	player.setup_health_bar(health_bar.get_node("HealthBar"))
	
	for enemy in enemies:
		player.connect("attack_done", Callable(enemy, "_on_player_attack_received"))	
	
	await get_tree().create_timer(2).timeout
	
	is_switching = false

func sync_character_state():
	last_health = player.health
	last_position = player.position

"""""
func _process(_delta):
	if Input.is_action_just_released("enter_building_mode") and not on_building_mode:
		enter_building_mode()
	if Input.is_action_just_released("exit_building_mode") and on_building_mode:
		exit_building_mode()

func add_building_to_queue(building_type, b_position):
	building_queue.add_to_queue(building_type, b_position)
	var construction
	if building_type=="House":
		construction = HouseConstructionScene.instantiate()
		add_child(construction)
	if building_type=="Tower":
		construction = TowerConstructionScene.instantiate()
		add_child(construction)	
	construction.position = b_position
	
func enter_building_mode():
	on_building_mode = true
	if not construction_mode:
		building_entered.emit()
		construction_mode = ConstructionModeScene.instantiate()
		add_child(construction_mode)

func exit_building_mode():
	on_building_mode = false
	if construction_mode:
		building_exited.emit()
		construction_mode.queue_free()
		construction_mode = null
"""
