extends Node
class_name HexPathfinder

var grid_manager

func set_grid_manager(gm: Node):
	grid_manager = gm
	
func calculate_reachable_tiles(unit: Unit) -> Array:
	var start = unit.tile_pos
	var max_cost = unit.current_movement

	var frontier = []
	_insert_frontier_sorted(frontier, 0, start)

	var visited = {}
	visited[start] = 0

	var reachable = []

	while frontier.size() > 0:
		var entry = frontier[0]
		frontier.remove_at(0)
		var current_cost = entry[0]
		var current_pos = entry[1]

		if visited[current_pos] < current_cost:
			continue

		if current_cost <= max_cost:
			reachable.append(current_pos)
		else:
			continue

		var neighbor_positions = grid_manager.get_hex_neighbor_positions(current_pos)
		for next_pos in neighbor_positions:
			var tile = grid_manager.get_tile_from_grid(next_pos)
			if tile == null:
				continue
			if tile.type == "void":
				continue

			var new_cost = current_cost + tile.movement_cost
			if new_cost <= max_cost and (not visited.has(next_pos) or new_cost < visited[next_pos]):
				visited[next_pos] = new_cost
				_insert_frontier_sorted(frontier, new_cost, next_pos)

	return reachable

func _insert_frontier_sorted(frontier: Array, cost: int, pos: Vector2i):
	var entry = [cost, pos]
	for i in range(frontier.size()):
		if frontier[i][0] > cost:
			frontier.insert(i, entry)
			return
	frontier.append(entry)
	
# Add to HexPathfinder.gd
func calculate_path_cost(unit: Unit, target_pos: Vector2i) -> int:
	# Similar to calculate_reachable_tiles, but we stop when target_pos is found
	var start = unit.tile_pos
	var max_cost = unit.current_movement

	var frontier = []
	_insert_frontier_sorted(frontier, 0, start)

	var visited = {}
	visited[start] = 0

	while frontier.size() > 0:
		var entry = frontier[0]
		frontier.remove_at(0)
		var current_cost = entry[0]
		var current_pos = entry[1]

		if visited[current_pos] < current_cost:
			continue

		# If we reached the target, return the cost immediately
		if current_pos == target_pos:
			return current_cost

		# If cost already exceeds max_cost, no need to continue
		if current_cost > max_cost:
			continue

		var neighbor_positions = grid_manager.get_hex_neighbor_positions(current_pos)
		for next_pos in neighbor_positions:
			var tile = grid_manager.get_tile_from_grid(next_pos)
			if tile == null:
				continue
			if tile.type == "void":
				continue

			var new_cost = current_cost + tile.movement_cost
			if (not visited.has(next_pos) or new_cost < visited[next_pos]):
				visited[next_pos] = new_cost
				_insert_frontier_sorted(frontier, new_cost, next_pos)

	# If we never reached the target_pos, return -1 indicating no path
	return -1
