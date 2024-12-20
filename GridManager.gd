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
	var neighbors = surrounding(tower_tile)
	for key in neighbors:
		if neighbors[key] and neighbors[key].type == 'void':
			var random_tile = tile_factory.make_random_tile()
			replace_tile(neighbors[key], random_tile)


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
	# When replacing a tile, ensure units are properly handled
	# If the old tile had a unit, remove it or handle accordingly
	if old_tile.unit:
		# If you want to keep the unit, you must reassign it.
		# For now, let's just remove it. (Or you could handle differently)
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

# Request that a unit occupies a new tile position
# This should handle freeing the old tile and occupying the new one, if possible.
func request_occupy_tile(unit: Unit, old_pos: Vector2i, new_pos: Vector2i) -> bool:
	var old_tile = get_tile_from_grid(old_pos)
	var new_tile = get_tile_from_grid(new_pos)

	if not new_tile:
		return false

	# Check if the new tile is free (no unit on it)
	if new_tile.unit != null:
		# Tile occupied, can't move here
		return false

	# Mark old tile as free
	if old_tile and old_tile.unit == unit:
		old_tile.unit = null

	# Occupy the new tile
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
