extends "res://Scripts/player_base.gd"

var is_building_mode = false
var is_collecting = false
@onready var tree_map_layer = get_parent().get_node("Trees")

func _physics_process(delta):
	var enemies = get_tree().get_nodes_in_group("Enemies")

	if enemies.size() > 0:
		for enemy in enemies:
			if not enemy.is_connected("attack_done", Callable(self, "_on_enemy_attack_received")):
				enemy.connect("attack_done", Callable(self, "_on_enemy_attack_received"))
	
	if Input.is_action_just_released("pawn_collect"):
		collect()
	
	if player_sprite.animation!="collecting":
		is_collecting=false
	
	move()

func not_moving():
	if not is_collecting:
		velocity = Vector2.ZERO
		player_sprite.play("idle")
	else:
		velocity = Vector2.ZERO
		player_sprite.play("collecting")

func collect():
	is_collecting = true
	player_sprite.play("collecting")

func _on_building_entered():
	is_building_mode = true
	
func _on_building_exited():
	is_building_mode = false
