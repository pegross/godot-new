extends Node

var camera: Camera3D
var grid_manager: Node
var raycast_helper: Node
var selected_unit: Unit = null
var currently_highlighted_tiles: Array = []
var game_state_machine


func _ready():
	camera = $"../Camera3D"
	grid_manager = $"../GridManager"
	raycast_helper = $"../RaycastHelper"
	game_state_machine = $"../GameStateMachine"


func _physics_process(delta):
	pass


func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		var clicked_collider = raycast_helper.raycast(get_viewport().get_mouse_position(), camera)
		if clicked_collider:
			var pos = clicked_collider.root().pos
			var tile = grid_manager.get_tile_from_grid(pos)
			if tile:
				handle_tile_click(tile)

	if event is InputEventKey and event.is_pressed():
		# Press 'F' to end turn (or handle turn logic)
		if event.keycode == KEY_F:
			var turn_manager = $"/root/Main/TurnManager"
			turn_manager.start_new_turn()

		# Press SPACE to toggle between battle and purchase states
		elif event.keycode == KEY_SPACE:
			if game_state_machine.is_in_battle_state():
				game_state_machine.set_state_purchase()
			else:
				game_state_machine.set_state_battle()

func handle_tile_click(tile):
	# Forward to the state machine, no logic here
	game_state_machine.handle_tile_click(tile)

func highlight_reachable_tiles(positions: Array):
	clear_reachable_highlights()
	for pos in positions:
		var tile = grid_manager.get_tile_from_grid(pos)
		if tile:
			tile.set_reachable_highlight(true)
	currently_highlighted_tiles = positions


func clear_reachable_highlights():
	for pos in currently_highlighted_tiles:
		var tile = grid_manager.get_tile_from_grid(pos)
		if tile:
			tile.set_reachable_highlight(false)
	currently_highlighted_tiles.clear()
