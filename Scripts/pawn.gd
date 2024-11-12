extends "res://Scripts/player_base.gd"

var is_building_mode = false
var is_collecting = false
var is_constructing = false
@onready var building_mode_scene = preload("res://Scenes/ConstructionMode.tscn")
var building_mode_instance: Node2D = null
@onready var axe_area = $AxeArea
@onready var hammer_area = $HammerArea
@onready var build_audio = $BuildAudio
@onready var chop_audio = $ChopAudio

func _ready():
	player_sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))

func _input(_event):
	if Input.is_action_just_released("enter_building_mode"):
		enter_building_mode()
	if Input.is_action_just_released("exit_building_mode") and is_building_mode:
		exit_building_mode()

func enter_building_mode():
	if not is_building_mode:
		is_building_mode = true
		player_sprite.play("idle")
		building_mode_instance = building_mode_scene.instantiate()
		building_mode_instance.setup_building_mode(self)
		game_controller.add_child(building_mode_instance)

func exit_building_mode():
	if is_building_mode:
		is_building_mode = false
		if building_mode_instance:
			building_mode_instance.queue_free()
			building_mode_instance = null
	

func _physics_process(delta):
	
	if is_building_mode:
		return
	
	var enemies = get_tree().get_nodes_in_group("Enemies")

	if enemies.size() > 0:
		for enemy in enemies:
			if not enemy.is_connected("attack_done", Callable(self, "_on_enemy_attack_received")):
				enemy.connect("attack_done", Callable(self, "_on_enemy_attack_received"))
	
	
	var trees = get_tree().get_nodes_in_group("Trees")

	if trees.size() > 0:
		for tree in trees:
			if not tree.is_connected("tree_collected", Callable(self, "gather_trees")):
				tree.connect("tree_collected", Callable(self, "gather_trees"))
	
	
	if Input.is_action_just_released("pawn_collect"):
		collect()
	if Input.is_action_just_released("pawn_construct"):
		construct()
		
	if is_collecting or is_constructing:
		return
	
	move()
	
func _on_animation_finished():
	if(player_sprite.animation=="collecting"):
		test_collect()
		is_collecting=false
		player_sprite.play("idle")
	if(player_sprite.animation=="constructing"):
		test_construct()
		is_constructing=false
		player_sprite.play("idle")

func flip():
	if direction.x > 0:
		player_sprite.flip_h = false
		axe_area.scale.x = 1
		hammer_area.scale.x = 1
	elif direction.x < 0:
		player_sprite.flip_h = true
		axe_area.scale.x = -1
		hammer_area.scale.x = -1
	
func not_moving():
	if not is_collecting:
		velocity = Vector2.ZERO
		player_sprite.play("idle")
	else:
		velocity = Vector2.ZERO
		player_sprite.play("collecting")

func collect():	
	if not is_collecting and not is_constructing:
		chop_audio.play()
		is_collecting = true
		player_sprite.play("collecting")
		
func test_collect():
	var overlapping_bodies = axe_area.get_overlapping_bodies()
	for body in overlapping_bodies:
		if body.is_in_group("Trees"):
			body.collect()

func construct():
	if not is_constructing and not is_collecting:
		build_audio.play()
		is_constructing = true
		player_sprite.play("constructing")

func test_construct():
	var overlapping_bodies = hammer_area.get_overlapping_bodies()
	for body in overlapping_bodies:
		if body.is_in_group("Buildings"):
			body.build()
		if body.is_in_group("Destroyed"):
			body.restore()
		if body.is_in_group("MineDestroyed"):
			body.restore(self)

			
func gather_trees(amount):
	gather_resource("wood", amount)

func _on_building_entered():
	is_building_mode = true
	
func _on_building_exited():
	is_building_mode = false
