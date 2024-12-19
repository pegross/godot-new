extends Node3D

func _ready():
	var grid_manager = $GridManager
	var tile_factory = $TileFactory
	var hex_math = $HexMath
	var input_manager = $InputManager
	var raycast_helper = $RaycastHelper
	var camera = $Camera3D
	
	# If further initialization is needed, do it here.
	# Otherwise, this script remains minimal as a container for these managers.
