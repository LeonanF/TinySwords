extends Node2D

var building_position = Vector2()
var grid_size = 4
var can_place_building = true

var house_texture = preload("res://Textures/Constructions/House_Construction.png")
var build_radius = 300
var player

@onready var building_sprite = $BuildingSprite
@onready var building_area = $BuildingSprite/BuildingArea
@onready var house_collision = building_area.get_node("HouseCollision")
@onready var gamecontroller = get_parent()


var costs = {
	"House" : 20
}

func _ready():
	$BuildingSprite.texture = house_texture

func setup_building_mode(player_ref):
	self.player = player_ref
	building_position = player.position + Vector2(0, -50)
	$BuildingSprite.position = building_position
	
func _process(_delta):
	
	if is_instance_valid(player):
		move_building_mold()
	
		can_place_building = building_area.can_place_building

		if Input.is_action_just_released("confirm_building"):
			confirm_building()
	else:
		queue_free()

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

func confirm_building():
	if not can_place_building:
		flash_red()
		return
	
	var cost = costs["House"]
	
	if(player.has_wood(cost)):
		player.deduct_wood(cost)
		var house_scene = preload("res://Scenes/HouseConstruction.tscn")
		var new_house = house_scene.instantiate()
		
		new_house.position = building_position
		
		gamecontroller.add_child(new_house)
		player.exit_building_mode()
		queue_free()
	else:
		flash_red()


func flash_red():
	building_sprite.modulate = Color(1,0,0)
	await get_tree().create_timer(0.1).timeout
	building_sprite.modulate = Color(1,1,1)
