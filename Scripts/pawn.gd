extends "res://Scripts/player_base.gd"

var is_building_mode = false
var is_collecting = false
@onready var tree_map_layer = get_parent().get_node("Trees")
@onready var axe_area = $AxeArea

func _ready():
	player_sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))
	var tree_nodes = get_tree().get_nodes_in_group("Trees")
	for tree in tree_nodes:
		tree.connect("tree_collected", Callable(self, "gather_trees"))

func _physics_process(delta):
	var enemies = get_tree().get_nodes_in_group("Enemies")

	if enemies.size() > 0:
		for enemy in enemies:
			if not enemy.is_connected("attack_done", Callable(self, "_on_enemy_attack_received")):
				enemy.connect("attack_done", Callable(self, "_on_enemy_attack_received"))
	
	if Input.is_action_just_released("pawn_collect"):
		collect()
	
	if is_collecting:
		return
	
	move()
	
func _on_animation_finished():
	if(player_sprite.animation=="collecting"):
		test_collect()
		is_collecting=false
		player_sprite.play("idle")


func flip():
	if direction.x > 0:
		player_sprite.flip_h = false
		axe_area.scale.x = 1
	elif direction.x < 0:
		player_sprite.flip_h = true
		axe_area.scale.x = -1
	
func not_moving():
	if not is_collecting:
		velocity = Vector2.ZERO
		player_sprite.play("idle")
	else:
		velocity = Vector2.ZERO
		player_sprite.play("collecting")

func collect():	
	if not is_collecting:
		is_collecting = true
		player_sprite.play("collecting")
		
func test_collect():
	var overlapping_bodies = axe_area.get_overlapping_bodies()
	for body in overlapping_bodies:
		if body.is_in_group("Trees"):
			body.collect()

func gather_trees(amount):
	gather_resource("wood", amount)

func _on_building_entered():
	is_building_mode = true
	
func _on_building_exited():
	is_building_mode = false
