extends Node2D

@onready var house_area = $HouseArea

var player_in_area = null

signal construction_started

func _ready():
	house_area.connect("body_entered", Callable(self, "_on_body_entered"))
	house_area.connect("body_exited", Callable(self, "_on_body_exited"))
	
func _process(delta):
	if player_in_area and Input.is_action_just_pressed("construction_key"):
		construction_started.emit()

func _on_body_entered(body):
	if body.name=="Player":
		player_in_area = true

func _on_body_exited(body):
	if body.name=="Player":
		player_in_area = false
