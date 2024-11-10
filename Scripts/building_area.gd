extends Area2D

var can_place_building = true

func _ready():
	connect("body_entered", Callable(self, "_on_BuildingArea_body_entered"))
	connect("body_exited", Callable(self, "_on_BuildingArea_body_exited"))

func _on_BuildingArea_body_entered(body):
	can_place_building = false


func _on_BuildingArea_body_exited(body):
	can_place_building = true
