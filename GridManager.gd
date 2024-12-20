extends Node3D

@export_range(2, 20) var grid_height := 20
@export_range(2, 20) var grid_width := 20

var grid = []
var tile_factory: Node
var pathfinder: HexPathfinder

signal grid_ready(width, height)

func _ready():
	tile_factory = $"../TileFactory"
	_generate_grid()
	# Initialize pathfinder
	pathfinder = HexPathfinder.new()
	pathfinder.set_grid_manager(self)
	call_deferred("emit_signal", "grid_ready", grid_width, grid_height)

func _generate_grid():
	grid.resize(grid_width)
	for x in range(grid_width):
		grid[x] = []
		for y in range(grid_height):
			grid[x].append(null)

	# Fill with void tiles initially
	for x in range(grid_width):
		for y in range(grid_height):
			var tile = tile_factory.make_tile('void')
			add_to_grid(tile, Vector2i(x, y))
	
	# Place a tower in the middle
	var tower_tile = tile_factory.make_tile('tower')
	var old_tile = grid[grid_width / 2][grid_height / 2]
	replace_tile(old_tile, tower_tile)

	# Immediate neighbors (radius = 1)
	var neighbors = surrounding(tower_tile)
	for key in neighbors:
		if neighbors[key] and neighbors[key].type == 'void':
			var random_tile = tile_factory.make_random_tile()
			replace_tile(neighbors[key], random_tile)

	# Create two extra rings (for example, radius 2 and 3)
	create_additional_rings(tower_tile, 3)

func get_unit_at(pos: Vector2i) -> Unit:
	var tile = get_tile_from_grid(pos)
	if tile and tile.unit:
		return tile.unit
	return null

func add_to_grid(tile: Node3D, pos: Vector2i):
	var cords = HexMath.pos_to_world(pos)
	tile.translate(Vector3(cords.x, 0, cords.y))
	tile.pos = pos
	grid[pos.x][pos.y] = tile
	add_child(tile)

func replace_tile(old_tile, new_tile):
	var cord = old_tile.pos
	if old_tile.unit:
		old_tile.unit = null
	old_tile.queue_free()
	add_to_grid(new_tile, cord)

func get_tile_from_grid(pos: Vector2i):
	if pos.x < 0 or pos.x >= grid_width:
		return null
	if pos.y < 0 or pos.y >= grid_height:
		return null
	return grid[pos.x][pos.y]

func surrounding(tile):
	return {
		"SW": get_tile_from_grid(HexMath.get_neighbor_pos(tile, "SW")),
		"NW": get_tile_from_grid(HexMath.get_neighbor_pos(tile, "NW")),
		"N":  get_tile_from_grid(HexMath.get_neighbor_pos(tile, "N")),
		"NE": get_tile_from_grid(HexMath.get_neighbor_pos(tile, "NE")),
		"SE": get_tile_from_grid(HexMath.get_neighbor_pos(tile, "SE")),
		"S":  get_tile_from_grid(HexMath.get_neighbor_pos(tile, "S"))
	}

func request_occupy_tile(unit: Unit, old_pos: Vector2i, new_pos: Vector2i) -> bool:
	var old_tile = get_tile_from_grid(old_pos)
	var new_tile = get_tile_from_grid(new_pos)

	if not new_tile:
		return false

	if new_tile.unit != null:
		return false

	if old_tile and old_tile.unit == unit:
		old_tile.unit = null

	new_tile.unit = unit
	return true

func remove_unit_from_tile(pos: Vector2i):
	var tile = get_tile_from_grid(pos)
	if tile and tile.unit:
		tile.unit = null

func get_hex_neighbor_positions(pos: Vector2i) -> Array:
	var directions = ["SW","NW","N","NE","SE","S"]
	var neighbors = []
	for d in directions:
		var neighbor_pos = HexMath.get_neighbor_pos({"pos": pos}, d)
		neighbors.append(neighbor_pos)
	return neighbors

func calculate_reachable_tiles_for_unit(unit: Unit) -> Array:
	return pathfinder.calculate_reachable_tiles(unit)


# New functions to create additional rings of random tiles
func create_additional_rings(center_tile, max_radius):
	var center = center_tile.pos
	for radius in range(2, max_radius+1):
		var ring_positions = get_positions_at_radius(center, radius)
		for pos in ring_positions:
			var t = get_tile_from_grid(pos)
			if t and t.type == 'void':
				var random_tile = tile_factory.make_random_tile()
				replace_tile(t, random_tile)

# Use BFS to find all positions exactly 'radius' steps away from center.
func get_positions_at_radius(center: Vector2i, radius: int) -> Array:
	if radius == 0:
		return [center]

	var visited = {}
	var frontier = []
	# Each entry: [pos, distance]
	frontier.append([center, 0])
	visited[center] = 0

	var ring_positions = []

	while frontier.size() > 0:
		var entry = frontier.pop_back()
		var pos = entry[0]
		var dist = entry[1]

		if dist == radius:
			ring_positions.append(pos)
			# Don't continue from tiles at exact radius to avoid going beyond radius
			continue
		if dist > radius:
			continue

		var neighbors = get_hex_neighbor_positions(pos)
		for npos in neighbors:
			if !visited.has(npos):
				visited[npos] = dist + 1
				frontier.append([npos, dist + 1])
	
	return ring_positions
