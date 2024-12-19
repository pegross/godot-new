extends Node3D

func _ready():
	var grid_manager = $GridManager
	var tile_factory = $TileFactory
	var hex_math = $HexMath
	var input_manager = $InputManager
	var raycast_helper = $RaycastHelper
	var camera = $Camera3D
