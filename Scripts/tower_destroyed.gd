extends StaticBody2D

@onready var map = get_parent().get_parent().get_node("Map")
@onready var tower_scene = preload("res://Scenes/TowerConstruction.tscn")

func restore():
	var tower_instace = tower_scene.instantiate()
	tower_instace.position = position

	map.add_child(tower_instace)

	queue_free()
