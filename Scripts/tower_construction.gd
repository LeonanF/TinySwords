extends StaticBody2D

@onready var building_sprite = $Sprite
@onready var progress_bar = $TextureProgressBar
@onready var gamecontroller = get_parent()
@onready var map = get_parent().get_parent().get_node("Map")
@onready var tower_scene = preload("res://Scenes/Tower.tscn")

var needeed_steps = 10
var steps_remaining = 10
var build_speed = 1

func _ready():
	progress_bar.max_value = needeed_steps
	progress_bar.value = 0

func _process(delta):
	if steps_remaining > 0:
		progress_bar.value = needeed_steps - steps_remaining
	
	if steps_remaining <= 0:
		complete_construction()

func build():
	if steps_remaining > 0:
		steps_remaining -= build_speed
		progress_bar.value +=1

func complete_construction():

	var tower_instance = tower_scene.instantiate()
	tower_instance.position = position

	map.add_child(tower_instance)

	queue_free()
