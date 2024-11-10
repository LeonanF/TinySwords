extends CanvasLayer

@onready var vbox_container = $VBoxContainer
var camera

func _ready():
	visible = false
	camera = get_parent().get_parent().get_node("Camera")

func show_game_over():
	visible = true
	var retry_button = get_node("VBoxContainer/RetryButton")
	var menu_button = get_node("VBoxContainer/MenuButton")
	var game_over_label = get_node("VBoxContainer/GameOverLabel")
	retry_button.connect("pressed", Callable(self, "_on_retry_pressed"))
	menu_button.connect("pressed", Callable(self, "_on_menu_pressed"))
	vbox_container.position = camera.position - vbox_container.size/2

func _on_retry_pressed():
	get_tree().reload_current_scene()
	
func _on_menu_pressed():
	get_tree().change_scene_to_file("res://Scenes/Menu.tscn")
