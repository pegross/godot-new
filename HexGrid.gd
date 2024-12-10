extends Node3D

const TILE_SIZE := 0.866 # magic number go brr
const HEX_TILE = preload("res://tiles/tile.tscn")
const FOREST_TILE = preload("res://tiles/Forest.tscn")
const MOUNTAIN_TILE = preload("res://tiles/Mountain.tscn")
const WATER_TILE = preload("res://tiles/Water.tscn")
const VOID_TILE = preload("res://tiles/Void.tscn")
const TOWER_TILE = preload("res://tiles/tower.tscn")
const RAY_LENGTH = 1000

@export_range(2, 20) var grid_height := 20
@export_range(2, 20) var grid_width := 20

var grid = []

# Called when the node enters the scene tree for the first time.
func _ready():
	grid = _generate_grid()
	get_parent().get_node("Camera3D").move(posToWorld(Vector2i(grid_width / 2, - grid_height / 2)))

var lastPos;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# hover effect
	var tiles := get_children()
	for tile in tiles:
		tile.hoverHide()
		
	var node = raycast(get_viewport().get_mouse_position())
	if node:
		node.hoverShow()
		var pos = node.get_parent().get_parent().pos
		if !lastPos or lastPos != pos:
			pass
		lastPos = pos
	
func raycast(pos):
	var space_state = get_world_3d().direct_space_state
	var cam = get_parent().get_node("Camera3D")
	
	var origin = cam.project_ray_origin(pos)
	var end = origin + cam.project_ray_normal(pos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	var result = space_state.intersect_ray(query)
	return result.get('collider')

func makeTile(type: String):
	var tile
	match type:
		'forest':
			tile = FOREST_TILE.instantiate()
		'mountain':
			tile = MOUNTAIN_TILE.instantiate()
		'water':
			tile = WATER_TILE.instantiate()
		'void':
			tile = VOID_TILE.instantiate()
		'grass':
			tile = HEX_TILE.instantiate()
		'tower':
			tile = TOWER_TILE.instantiate()
	
	if !tile:
		tile = HEX_TILE.instantiate()
		type = 'grass'
		
	tile.type = type
	return tile
	
	
func makeRandomTile():
	return makeTile(['forest', 'mountain', 'water', 'grass'].pick_random())
		
	
func _generate_grid():		
	# pregenerate
	for x in grid_width:
		grid.append([])
		for y in grid_height:
			grid[x].append(0)
	
	# all void
	for x in grid_width:
		for y in grid_height:
			var tile
			tile = makeTile('void')
			addToGrid(tile, Vector2i(x, y))
	
	var tile = makeTile('tower')
	var old = grid[grid_width / 2][grid_height / 2]
	replaceTile(old, tile)
	var neighbors = surrounding(tile)
	print(neighbors)
	for key in neighbors:
		if neighbors[key].type == 'void':
			neighbors[key].purchasable = true
			
	return grid
	
func addToGrid(tile: Node3D, pos: Vector2i):
	var cords = posToWorld(pos)
	tile.translate(Vector3(cords.x, 0, cords.y))
	tile.setPos(Vector2i(pos.x, pos.y))
	grid[pos.x][pos.y] = tile
	add_child(tile)
	
func posToWorld(pos: Vector2i):
	var offset = 0 if pos.x % 2 == 0 else TILE_SIZE / 2
	return Vector2(pos.x * TILE_SIZE * cos(deg_to_rad(30)), pos.y * TILE_SIZE + offset)
	
func replaceTile(old, new):
	var cord = old.pos
	old.queue_free()
	addToGrid(new, cord)

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			var collider = raycast(get_viewport().get_mouse_position())
			if !collider:
				return
			var cord = collider.root().pos
			var tile = grid[cord.x][cord.y]
			print(cord)
		
			if !tile.type == 'void':
				return
			
			if !tile.purchasable:
				return
				
			var newTile = makeRandomTile()
			replaceTile(tile, newTile)
			var surrounding = surrounding(tile)
			
			print('newTile.pos', newTile.pos)
			for key in surrounding:
				if !surrounding[key]:
					continue
				if surrounding[key].type == 'void':
					print('=', key, surrounding[key].pos)
					surrounding[key].purchasable = true 
	
func surrounding(tile):
	var neighbors = {
		"SW": southwest(tile),
		"NW": northwest(tile),
		"N": north(tile),
		"NE": northeast(tile),
		"SE": southeast(tile),
		"S": south(tile)
	}
	return neighbors
	
# Helper function to retrieve a tile from the grid
func get_tile_from_grid(pos):
	if pos.x >= grid_width or pos.x < 0:
		return false
	if pos.y >= grid_height or pos.y < 0:
		return false
	return grid[pos.x][pos.y]

# Adjusted direction functions to handle short rows

func get_neighbor_pos(tile, direction):
	var newPos = tile.pos
	var isShort = newPos.x % 2 != 0

	match direction:
		"SW":
			newPos += Vector2i(-1, 1) if isShort else Vector2i(-1, 0)
		"NW":
			newPos += Vector2i(-1, 0) if isShort else Vector2i(-1, -1)
		"N":
			newPos += Vector2i(0, -1)
		"NE":
			newPos += Vector2i(1, 0) if isShort else Vector2i(1, -1)
		"SE":
			newPos += Vector2i(1, 1) if isShort else Vector2i(1, 0)
		"S":
			newPos += Vector2i(0, 1)
	return newPos

func southwest(tile):
	return get_tile_from_grid(get_neighbor_pos(tile, "SW"))

func northwest(tile):
	return get_tile_from_grid(get_neighbor_pos(tile, "NW"))

func north(tile):
	return get_tile_from_grid(get_neighbor_pos(tile, "N"))

func northeast(tile):
	return get_tile_from_grid(get_neighbor_pos(tile, "NE"))

func southeast(tile):
	return get_tile_from_grid(get_neighbor_pos(tile, "SE"))

func south(tile):
	return get_tile_from_grid(get_neighbor_pos(tile, "S"))
