extends Node

var camera: Camera3D
var grid_manager: Node
var raycast_helper: Node
var selected_unit: Unit = null
var currently_highlighted_tiles: Array = []


func _ready():
	camera = $"../Camera3D"
	grid_manager = $"../GridManager"
	raycast_helper = $"../RaycastHelper"


func _physics_process(delta):
	pass


func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		var clicked_collider = raycast_helper.raycast(get_viewport().get_mouse_position(), camera)
		if clicked_collider:
			var pos = clicked_collider.root().pos
			var tile = grid_manager.get_tile_from_grid(pos)
			if tile:
				handle_tile_click(tile)

	# Check if spacebar is pressed
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_SPACE:
			var turn_manager = $"../TurnManager"
			turn_manager.start_new_turn()


func handle_tile_click(tile):
	var unit_on_tile = grid_manager.get_unit_at(tile.pos)
	
	if selected_unit == null:
		# If no unit is currently selected
		if unit_on_tile:
			# Select this unit
			selected_unit = unit_on_tile
			selected_unit.select_unit()
			clear_reachable_highlights()
			var reachable_positions = grid_manager.calculate_reachable_tiles_for_unit(selected_unit)
			highlight_reachable_tiles(reachable_positions)
			return
		# No unit to select, continue to tile logic
	else:
		# A unit is currently selected
		if unit_on_tile:
			# If we clicked the currently selected unit, deselect it
			if unit_on_tile == selected_unit:
				selected_unit.deselect_unit()
				selected_unit = null
				clear_reachable_highlights()
				return
			else:
				# Switch selection to the new unit
				selected_unit.deselect_unit()
				clear_reachable_highlights()
				selected_unit = unit_on_tile
				selected_unit.select_unit()
				var reachable_positions = grid_manager.calculate_reachable_tiles_for_unit(selected_unit)
				highlight_reachable_tiles(reachable_positions)
				return
		else:
			# Clicked on an empty tile: try to move the selected unit
			if selected_unit.can_move_to(tile.pos):
				selected_unit.move_to_tile(tile.pos)
				# After moving, recalculate and re-highlight reachable tiles
				clear_reachable_highlights()
				var reachable_positions = grid_manager.calculate_reachable_tiles_for_unit(selected_unit)
				highlight_reachable_tiles(reachable_positions)
				return
			# Can't move there, continue to tile logic

	# If we reach this point, no unit action was taken.
	# Proceed with the existing tile purchase logic.

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


func highlight_reachable_tiles(positions: Array):
	clear_reachable_highlights()
	for pos in positions:
		var tile = grid_manager.get_tile_from_grid(pos)
		if tile:
			tile.set_reachable_highlight(true)
	currently_highlighted_tiles = positions


func clear_reachable_highlights():
	for pos in currently_highlighted_tiles:
		var tile = grid_manager.get_tile_from_grid(pos)
		if tile:
			tile.set_reachable_highlight(false)
	currently_highlighted_tiles.clear()
