extends Node2D

var construction_queue = []

func add_to_queue(building_type, b_position):
	construction_queue.append({"type": building_type, "position": b_position})
	get_parent().spawn_pawns(b_position)
	check_for_available_pawn()

func check_for_available_pawn():
	var pawn = find_available_pawn()
	if pawn and construction_queue.size() > 0:
		var next_task = construction_queue.pop_front()
		pawn.assign_task(next_task)

func find_available_pawn():
	for pawn in get_tree().get_nodes_in_group("Pawns"):
		if pawn.is_available():
			return pawn
	return get_tree().get_nodes_in_group("Pawns").front()

func has_task():
	return construction_queue.size() > 0

func get_next_task():
	if has_task():
		return construction_queue[0]
	return null

func complete_task(task):
	if construction_queue.size() > 0:
		construction_queue.pop_front()
