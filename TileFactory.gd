extends Node

const HEX_TILE = preload("res://tiles/tile.tscn")
const FOREST_TILE = preload("res://tiles/Forest.tscn")
const MOUNTAIN_TILE = preload("res://tiles/Mountain.tscn")
const WATER_TILE = preload("res://tiles/Water.tscn")
const VOID_TILE = preload("res://tiles/Void.tscn")
const TOWER_TILE = preload("res://tiles/tower.tscn")

func make_tile(type: String) -> Node3D:
	var tile
	match type:
		'forest': tile = FOREST_TILE.instantiate()
		'mountain': tile = MOUNTAIN_TILE.instantiate()
		'water': tile = WATER_TILE.instantiate()
		'void': tile = VOID_TILE.instantiate()
		'grass': tile = HEX_TILE.instantiate()
		'tower': tile = TOWER_TILE.instantiate()
		_:
			tile = HEX_TILE.instantiate()
			type = 'grass'
	tile.type = type
	return tile

func make_random_tile() -> Node3D:
	return make_tile(['forest', 'mountain', 'water', 'grass', 'grass'].pick_random())
