extends Sprite2D

@onready var tween = get_tree().create_tween()

var hammer_height = 10
var duration = 1.0
var move_direction = 1
var elapsed_time = 0.0

func _process(delta):
	elapsed_time += delta
	
	if elapsed_time >= duration / 2:
		move_direction *= -1
		elapsed_time = 0.0
	
	var target_position = position + Vector2(0, -move_direction * hammer_height)
	
	position = position.lerp(target_position, delta / (duration / 2))
