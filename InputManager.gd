extends Node

var camera: Camera3D
var grid_manager: Node
var raycast_helper: Node

func _ready():
	camera = $"../Camera3D"
	grid_manager = $"../GridManager"
	raycast_helper = $"../RaycastHelper"

func _physics_process(delta):
	# Hide hover for all tiles
	for x in range(grid_manager.grid_width):
		for y in range(grid_manager.grid_height):
			var tile = grid_manager.grid[x][y]
			if tile:
				tile.hoverHide()
	
	# Show hover on tile under cursor
	var hovered_collider = raycast_helper.raycast(get_viewport().get_mouse_position(), camera)
	if hovered_collider:
		hovered_collider.hoverShow()

func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		var clicked_collider = raycast_helper.raycast(get_viewport().get_mouse_position(), camera)
		if clicked_collider:
			var pos = clicked_collider.root().pos
			var tile = grid_manager.get_tile_from_grid(pos)
			handle_tile_click(tile)

func handle_tile_click(tile):
	if tile.type != 'void':
		return
	if not tile.purchasable:
		return
	
	var tile_factory = $"../TileFactory"
	var new_tile = tile_factory.make_random_tile()
	grid_manager.replace_tile(tile, new_tile)

	var neighbors = grid_manager.surrounding(new_tile)
	for key in neighbors:
		if neighbors[key] and neighbors[key].type == 'void':
			neighbors[key].purchasable = true
