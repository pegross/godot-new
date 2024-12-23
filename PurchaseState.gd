extends Node
class_name PurchaseState

var state_machine
var grid_manager

var selected_tile_type = null
var tile_inventory  # We'll store a reference to the UI

func _init(sm):
	state_machine = sm
	grid_manager = sm.grid_manager

func on_enter():
	# Show purchase visuals
	grid_manager.set_purchase_icons_visible(true)
	
	# Grab the TileInventory from the scene tree (where you instantiated it).
	# For example, if you have it at /root/Main/TileInventory:
	tile_inventory = grid_manager.get_tree().get_root().get_node("Main/UI/TileInventory") 
	tile_inventory.visible = true
	
	# Connect the tile_chosen signal so we know which tile type is selected
	tile_inventory.tile_chosen.connect(_on_inventory_tile_chosen)

	# Clear any previous selection
	selected_tile_type = null

func on_exit():
	# Hide purchase icons & inventory
	grid_manager.set_purchase_icons_visible(false)
	if tile_inventory:
		tile_inventory.visible = false

func handle_tile_click(tile):
	# Only purchase if tile is void & purchasable
	if tile.type != 'void':
		print("not void")
		return
	if not tile.purchasable:
		print("not purchasable")
		return
	
	# If we have no selected tile type from the UI, do nothing
	if selected_tile_type == null:
		print("no tile selected")
		return
	
	# Place the selected tile type
	var tile_factory = state_machine.tile_factory
	var new_tile = tile_factory.make_tile(selected_tile_type)
	grid_manager.replace_tile(tile, new_tile)


func _on_inventory_tile_chosen(tile_type: String):
	selected_tile_type = tile_type
	print("PurchaseState: Player selected tile type =", tile_type)
