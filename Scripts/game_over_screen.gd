extends CanvasLayer

@onready var vbox_container = $VBoxContainer

func _ready():
	visible = false

func show_game_over():
	visible = true
	var retry_button = get_node("VBoxContainer/RetryButton")
	var menu_button = get_node("VBoxContainer/MenuButton")
	var game_over_label = get_node("VBoxContainer/GameOverLabel")
	retry_button.connect("pressed", Callable(self, "_on_retry_pressed"))
	menu_button.connect("pressed", Callable(self, "_on_menu_pressed"))

func _on_retry_pressed():
	get_tree().reload_current_scene()
	
func _on_menu_pressed():
	get_tree().change_scene_to_file("res://Scenes/Menu.tscn")
