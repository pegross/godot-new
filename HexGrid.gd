extends Node3D

func _ready():
	var grid_manager = $GridManager
	grid_manager.grid_ready.connect(_on_grid_ready)

func _on_grid_ready(width: int, height: int):
	var unit_factory = preload("res://Unit.tscn")
	var unit = unit_factory.instantiate() as Unit

	var start_pos = Vector2i(width / 2, (height / 2) + 1)
	var tile = $GridManager.get_tile_from_grid(start_pos)
	if tile:
		# Add the unit to the scene tree
		add_child(unit)
		
		# Update unit and tile references
		unit.tile_pos = start_pos
		tile.unit = unit
		
		# Move the unit's position to match the tile
		var world_pos = HexMath.pos_to_world(start_pos)
		unit.global_transform.origin = Vector3(world_pos.x, unit.global_transform.origin.y, world_pos.y)
