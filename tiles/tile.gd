extends Node3D

@onready var highlight_mesh = $HighlightMesh # The ring/plane mesh
var unit: Unit = null
var pos: Vector2i
var type: String
var purchasable = false
var show_purchase_icons = true

@export var material: Material
@export var movement_cost: int = 1

func _ready():
	$Mesh.set_surface_override_material(0, material)
	# Ensure highlight is off initially
	highlight_mesh.visible = false

func hoverHide():
	highlight_mesh.visible = false

func hoverShow():
	highlight_mesh.visible = true

func set_reachable_highlight(value: bool):
	if value:
		highlight_mesh.visible = true
		# Optionally, you can differentiate reachability highlight 
		# by changing the highlight_mesh material's color.
	else:
		highlight_mesh.visible = false
