extends Node
class_name PurchaseState

var state_machine
var grid_manager

func _init(sm):
	state_machine = sm
	grid_manager = sm.grid_manager

func on_enter():
	# Show the purchase banner when entering purchase phase
	grid_manager.set_purchase_icons_visible(true)
	# On entering purchase mode, no selected units (handled by battle on_exit)
	pass

func on_exit():
	# Nothing special on exit for now
	pass

func handle_tile_click(tile):
	# In purchase state, we only buy tiles if void and purchasable
	if tile.type != 'void':
		return
	if not tile.purchasable:
		return
	 
	_show_tile_choice_overlay(tile)

	# No unit actions here

func _show_tile_choice_overlay(tile):
	var overlay = load("res://ui/TileChoiceOverlay.tscn").instantiate()
	print("instantiate tilechoice")
	# If it's a canvas layer, add it as a child of /root or your main UI node
	state_machine.get_tree().root.add_child(overlay)

	# Optionally, set which tiles are available:
	overlay.available_tiles = ["forest", "mountain", "water"] # Or read from data

	# Connect the tile_chosen signal:
	overlay.tile_chosen.connect(func(tile_type: String):
		_on_tile_chosen(tile, tile_type)
		overlay.queue_free()
	)

func _on_tile_chosen(tile, tile_type: String):
	var tile_factory = state_machine.tile_factory
	var new_tile = tile_factory.make_tile(tile_type)
	grid_manager.replace_tile(tile, new_tile)
