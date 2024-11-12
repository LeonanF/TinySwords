extends StaticBody2D

@onready var map = get_parent().get_parent().get_node("Map")
@onready var castle_scene = preload("res://Scenes/CastleConstruction.tscn")

func restore():
	var castle_instance = castle_scene.instantiate()
	castle_instance.position = position

	map.add_child(castle_instance)

	queue_free()
