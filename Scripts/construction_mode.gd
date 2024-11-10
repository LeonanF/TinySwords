extends Node2D

var selected_building_type = "House"
var building_position = Vector2()
var grid_size = 4
var can_place_building = true

var house_texture = preload("res://Textures/Constructions/House_Construction.png")
var tower_texture = preload("res://Textures/Constructions/Tower_Construction.png")
var build_radius = 300

@onready var building_sprite = $BuildingSprite
@onready var building_area = $BuildingSprite/BuildingArea
@onready var player = get_node("../Player")
@onready var house_collision = building_area.get_node("HouseCollision")
@onready var tower_collision = building_area.get_node("TowerCollision")
@onready var gamecontroller = get_parent()

var costs = {
	"House" : 20,
	"Tower" : 50
}

func _ready():
	$BuildingSprite.texture = house_texture
	building_position = player.position + Vector2(0, -50)
	$BuildingSprite.position = building_position
	
	house_collision.disabled = (selected_building_type != "House")
	tower_collision.disabled = (selected_building_type != "Tower")

func _process(_delta):
	if Input.is_action_just_released("switch_building"):
		switch_building_type()
		
	move_building_mold()
	
	can_place_building = building_area.can_place_building

	if Input.is_action_just_released("confirm_building"):
		confirm_building()

func move_building_mold():
	var movement = Vector2()
	if Input.is_action_pressed("ui_right"):
		movement.x += 1
	elif Input.is_action_pressed("ui_left"):
		movement.x -= 1
	if Input.is_action_pressed("ui_down"):
		movement.y += 1
	elif Input.is_action_pressed("ui_up"):
		movement.y -= 1

	building_position += movement * grid_size
	
	if (building_position - player.position).length() > build_radius:
		var direction = (building_position - player.position).normalized()
		building_position = player.position + direction * build_radius

	$BuildingSprite.position = building_position

func switch_building_type():
	if selected_building_type == "House":
		selected_building_type = "Tower"
		$BuildingSprite.texture = tower_texture
	else:
		selected_building_type = "House"
		$BuildingSprite.texture = house_texture
	update_collision_shape()

func update_collision_shape():
	house_collision.disabled = (selected_building_type != "House")
	tower_collision.disabled = (selected_building_type != "Tower")

func confirm_building():
	if not can_place_building:
		flash_red()
		return
	
	var cost = costs[selected_building_type]
	
	if(player.has_trees(cost)):
		player.deduct_trees(cost)
		gamecontroller.add_building_to_queue(selected_building_type, building_position)


func flash_red():
	building_sprite.modulate = Color(1,0,0)
	await get_tree().create_timer(0.1).timeout
	building_sprite.modulate = Color(1,1,1)
