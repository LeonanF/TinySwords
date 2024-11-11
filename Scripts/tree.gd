extends StaticBody2D

@onready var tree_sprite = $TreeSprite
@onready var trunk_sprite = $TrunkSprite

var tree_health = 100
var tree_value = 2
var trunk_value = 20

signal tree_collected(value)

func _ready():
	trunk_sprite.visible = false
	tree_sprite.visible = true

func collect():
	if tree_health > 0:
		tree_sprite.play("being_collected")
		tree_health -= 10
		
		tree_collected.emit(tree_value)
		
	if tree_health==0:
		if trunk_sprite.visible == true:
			queue_free()
			tree_collected.emit(trunk_value)
		
		tree_sprite.visible = false
		trunk_sprite.visible = true
