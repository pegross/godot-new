extends Node
class_name GameStateMachine

var grid_manager
var tile_factory

var battle_state
var purchase_state
var current_state

func _ready():
	# Assume GridManager and TileFactory are siblings or accessible
	grid_manager = $"../GridManager"
	tile_factory = $"../TileFactory"

	# Initialize states
	battle_state = BattleState.new(self)
	purchase_state = PurchaseState.new(self)

	# Start in battle state by default
	current_state = battle_state
	current_state.on_enter()

func handle_tile_click(tile):
	current_state.handle_tile_click(tile)

func set_state_battle():
	current_state.on_exit()
	current_state = battle_state
	current_state.on_enter()

func set_state_purchase():
	current_state.on_exit()
	current_state = purchase_state
	current_state.on_enter()

func is_in_battle_state() -> bool:
	return current_state == battle_state
