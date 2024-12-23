extends Control
class_name TileInventory

var forest_button: TextureButton
var mountain_button: TextureButton
var water_button: TextureButton
var plains_button: TextureButton

var selected_button: TextureButton = null

signal tile_chosen(tile_type: String)

func _ready():
	forest_button = $GridContainer/ForestButton
	mountain_button = $GridContainer/MountainButton
	water_button = $GridContainer/WaterButton
	plains_button = $GridContainer/PlainsButton

	forest_button.pressed.connect(func():
		_on_button_pressed(forest_button, "forest")
	)
	mountain_button.pressed.connect(func():
		_on_button_pressed(mountain_button, "mountain")
	)
	water_button.pressed.connect(func():
		_on_button_pressed(water_button, "water")
	)
	plains_button.pressed.connect(func():
		_on_button_pressed(plains_button, "plains")
	)

	visible = false

func _on_button_pressed(button: TextureButton, tile_type: String):
	# Turn off glow for previously selected button
	if selected_button:
		var old_glow = selected_button.get_node("GlowRect")
		if old_glow:
			old_glow.visible = false

	# Turn on glow for this newly selected button
	selected_button = button
	var glow = button.get_node("GlowRect")
	if glow:
		glow.visible = true

	emit_signal("tile_chosen", tile_type)
	print("tile_chosen:", tile_type)
