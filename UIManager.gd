extends CanvasLayer

@onready var turn_label = $TurnLabel

func _ready():
	get_parent().get_node("HexGrid/TurnManager").turn_started.connect(_on_turn_started)

func set_turn_message(text: String):
	turn_label.text = text

func _on_turn_started(turn: int):
	set_turn_message("Turn: " + str(turn))
