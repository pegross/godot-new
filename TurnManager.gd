# TurnManager.gd
extends Node

signal turn_started
signal turn_ended

# Reference to GridManager (adjust the path if needed)
var grid_manager
var turn_count = 0

func _ready():
	# Assume TurnManager and GridManager are siblings under Main
	grid_manager = get_node("../GridManager")
	

func start_new_turn():
	turn_count += 1
	# Iterate over all tiles to find units
	for x in range(grid_manager.grid_width):
		for y in range(grid_manager.grid_height):
			var tile = grid_manager.grid[x][y]
			if tile and tile.unit:
				tile.unit.start_new_turn()
	emit_signal("turn_started", turn_count)
	print("New turn started.")
