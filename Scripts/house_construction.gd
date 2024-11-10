extends Node2D

@export var construction_time: float = 5.0

var house_ready_scene = preload("res://Scenes/HouseReady.tscn")

@onready var progress_bar = $ProgressBar
@onready var house_area = $HouseArea
@onready var building_queue = get_parent().get_node("BuildingQueue")

var timer: float = 0.0
var is_constructing: bool = false
var pawn_body

func _ready():
	progress_bar.max_value = construction_time
	progress_bar.value = 0.0
	house_area.connect("body_entered", Callable(self, "_on_body_entered"))


func _on_body_entered(body):
	if body.is_in_group("Pawns"):
		body.is_constructing = true
		start_construction()
		pawn_body = body

func _process(delta):
	if is_constructing:
		timer += delta
		progress_bar.value = timer

		if timer >= construction_time:
			finish_construction()

func start_construction():
	is_constructing = true
	timer = 0.0

func finish_construction():
	if pawn_body:
		building_queue.complete_task(pawn_body.current_task)
		pawn_body.finished_constructing()
		pawn_body = null
		var house_ready = house_ready_scene.instantiate()
		get_parent().add_child(house_ready)
		house_ready.global_position = global_position
		queue_free()
