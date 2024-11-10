extends Area2D

func _ready():
	self.connect("body_entered", Callable(self, "_on_body_entered"))
	self.connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	if body is not TileMapLayer:
		body.z_index = 0

func _on_body_exited(body):
	if body is not TileMapLayer:
		body.z_index = 1
