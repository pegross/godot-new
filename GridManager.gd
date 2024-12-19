extends Node3D

@export_range(2, 20) var grid_height := 20
@export_range(2, 20) var grid_width := 20

var grid = []
var tile_factory: Node

signal grid_ready(width, height)

func _ready():
	tile_factory = $"../TileFactory"
	_generate_grid()
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
			neighbors[key].purchasable = true

func add_to_grid(tile: Node3D, pos: Vector2i):
	var cords = HexMath.pos_to_world(pos)
	tile.translate(Vector3(cords.x, 0, cords.y))
	tile.setPos(pos)
	grid[pos.x][pos.y] = tile
	add_child(tile)

func replace_tile(old_tile, new_tile):
	var cord = old_tile.pos
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
