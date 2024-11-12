extends Node2D

@export var active_sprite: Texture
@export var inactive_sprite: Texture
@export var gold_bag_scene: PackedScene
@export var gold_spawn_position: Vector2
@export var gold_bag_group_name: String = "GoldBags"

@onready var map = get_parent()
@onready var mine_sprite = $Sprite
@onready var coin_sprite = $Coin

var is_active = false
var has_gold_bag = false

func _ready():
	_set_inactive()

func _set_inactive():
	is_active = false
	mine_sprite.texture = inactive_sprite
	coin_sprite.visible = true
	if not has_gold_bag:
		start_timer()

func start_timer():
	await get_tree().create_timer(5.0).timeout
	activate_mine()

func activate_mine():
	coin_sprite.visible = true
	
	is_active = true
	mine_sprite.texture = active_sprite
	await get_tree().create_timer(3.0).timeout
	generate_gold_bag()

func generate_gold_bag():
	if gold_bag_scene and not has_gold_bag:
		var gold_bag = gold_bag_scene.instantiate()
		gold_bag.position = position + gold_spawn_position
		map.add_child(gold_bag)
		gold_bag.add_to_group(gold_bag_group_name)
		gold_bag.connect("collected", Callable(self, "_on_gold_bag_collected"))
		has_gold_bag = true
		coin_sprite.visible = false

func _on_gold_bag_collected():
	has_gold_bag = false
	_set_inactive()
