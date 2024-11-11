extends Control

class_name ResourceBanner

@onready var resource_icon = $Icon
@onready var resource_value = $Value
@onready var resource_banner = $Banner

var resource_type : String = ""
var resource_amount : int = 0

func _ready():
	update_resource_value(0)

func setup_position(s_position):
	resource_icon.position = s_position
	resource_value.position = s_position + Vector2i(50,0)
	
func update_resource_value(amount):
	resource_amount = amount
	resource_value.text = str(resource_amount)
	
func set_resource(resource_type: String):
	self.resource_type = resource_type
	match resource_type:
		"meat":
			resource_icon.texture = preload("res://Textures/Resources/Resources/M_Idle_(NoShadow).png")
			setup_position(Vector2i(900,20))
		"wood":
			resource_icon.texture = preload("res://Textures/Resources/Resources/W_Idle_(NoShadow).png")
			setup_position(Vector2i(800,20))
		"gold":
			resource_icon.texture = preload("res://Textures/Resources/Resources/G_Idle_(NoShadow).png")
			setup_position(Vector2i(700,20))
