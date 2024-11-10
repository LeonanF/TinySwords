extends Control

@onready var start_button = $VBoxContainer/NewGame
@onready var exit_button = $VBoxContainer/Exit

func _ready():
	start_button.connect("pressed", Callable(self, "_on_start_pressed"))
	exit_button.connect("pressed", Callable(self, "_on_exit_pressed"))
	
func _on_start_pressed():
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")
	
func _on_exit_pressed():
	get_tree().quit()
