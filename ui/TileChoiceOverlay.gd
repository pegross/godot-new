extends Control
class_name TileChoiceOverlay

signal tile_chosen(tile_type: String)

var available_tiles: Array = ["plains", "forest", "mountain", "water"]

func _ready():
	# Suppose you have buttons or icons for each tile
	# You might create them dynamically or have them in the scene already.
	# For demonstration, say we have a Button node for forest, mountain, water:
	$PlainsButton.visible = "plains" in available_tiles
	$PlainsButton.pressed.connect(_on_plains_pressed)

	$ForestButton.visible = "forest" in available_tiles
	$ForestButton.pressed.connect(_on_forest_pressed)

	$MountainButton.visible = "mountain" in available_tiles
	$MountainButton.pressed.connect(_on_mountain_pressed)

	$WaterButton.visible = "water" in available_tiles
	$WaterButton.pressed.connect(_on_water_pressed)

func _on_plains_pressed():
	emit_signal("tile_chosen", "plains")

func _on_forest_pressed():
	emit_signal("tile_chosen", "forest")

func _on_mountain_pressed():
	emit_signal("tile_chosen", "mountain")

func _on_water_pressed():
	emit_signal("tile_chosen", "water")
