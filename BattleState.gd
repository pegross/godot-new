extends Node
class_name BattleState

var state_machine
var grid_manager
var selected_unit = null
var currently_highlighted_tiles = []

func _init(sm):
	state_machine = sm
	grid_manager = sm.grid_manager

func on_enter():
	# Nothing special on enter for now
	pass

func on_exit():
	# Deselect unit and clear highlights if any
	if selected_unit:
		selected_unit.deselect_unit()
		selected_unit = null
	clear_reachable_highlights()

func handle_tile_click(tile):
	var unit_on_tile = grid_manager.get_unit_at(tile.pos)

	if selected_unit == null:
		# Try selecting a unit
		if unit_on_tile:
			selected_unit = unit_on_tile
			selected_unit.select_unit()
			clear_reachable_highlights()
			var reachable_positions = grid_manager.calculate_reachable_tiles_for_unit(selected_unit)
			highlight_reachable_tiles(reachable_positions)
		# If no unit_on_tile, do nothing else in battle state
	else:
		# A unit is already selected
		if unit_on_tile:
			# If clicked the same unit, deselect
			if unit_on_tile == selected_unit:
				selected_unit.deselect_unit()
				selected_unit = null
				clear_reachable_highlights()
			else:
				# Switch selection to another unit
				selected_unit.deselect_unit()
				clear_reachable_highlights()
				selected_unit = unit_on_tile
				selected_unit.select_unit()
				var reachable_positions = grid_manager.calculate_reachable_tiles_for_unit(selected_unit)
				highlight_reachable_tiles(reachable_positions)
		else:
			# Try moving the selected unit
			if selected_unit.can_move_to(tile.pos):
				selected_unit.move_to_tile(tile.pos)
				clear_reachable_highlights()
				var reachable_positions = grid_manager.calculate_reachable_tiles_for_unit(selected_unit)
				highlight_reachable_tiles(reachable_positions)
			# If can't move, no purchase in battle state, do nothing

func highlight_reachable_tiles(positions: Array):
	clear_reachable_highlights()
	for pos in positions:
		var t = grid_manager.get_tile_from_grid(pos)
		if t:
			t.set_reachable_highlight(true)
	currently_highlighted_tiles = positions

func clear_reachable_highlights():
	for pos in currently_highlighted_tiles:
		var t = grid_manager.get_tile_from_grid(pos)
		if t:
			t.set_reachable_highlight(false)
	currently_highlighted_tiles.clear()
