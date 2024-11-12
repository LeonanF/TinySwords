extends StaticBody2D

@onready var map = get_parent().get_parent().get_node("Map")
@onready var gold_mine_scene = preload("res://Scenes/GoldMine.tscn")
@onready var mine_sprite = $Sprite

@export var restore_cost : int = 100

func restore(body : Player):
	
	if body.has_gold(restore_cost):
		body.deduct_gold(restore_cost)
		var gold_mine_instance = gold_mine_scene.instantiate()
		gold_mine_instance.position = position

		map.add_child(gold_mine_instance)

		queue_free()
	else:
		mine_sprite.modulate = Color(1,0,0)
		await get_tree().create_timer(0.1).timeout
		mine_sprite.modulate = Color(1,1,1)
