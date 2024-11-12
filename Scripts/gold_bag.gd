extends Area2D

@onready var bag_sprite = $Sprite
var bag_value : int

signal collected

func _ready():
	bag_value = randf_range(2,5)
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("Players"):
		body.gather_resource("gold", bag_value)
		collected.emit()
		queue_free()
