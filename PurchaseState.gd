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

	var tile_factory = state_machine.tile_factory
	var new_tile = tile_factory.make_random_tile()
	grid_manager.replace_tile(tile, new_tile)
	# No unit actions here
