extends Area2D

var can_place_building = true
var overlapping_bodies = []

func _ready():
	connect("body_entered", Callable(self, "_on_BuildingArea_body_entered"))
	connect("body_exited", Callable(self, "_on_BuildingArea_body_exited"))

func _process(delta):
	can_place_building = check_for_body_collisions()

func _on_BuildingArea_body_entered(body):
	if body not in overlapping_bodies:
		overlapping_bodies.append(body)


func _on_BuildingArea_body_exited(body):
	if body in overlapping_bodies:
		overlapping_bodies.erase(body)

func check_for_body_collisions() -> bool:
	return overlapping_bodies.size() == 0
