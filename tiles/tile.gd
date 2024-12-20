extends Node3D

var unit: Unit = null
var pos: Vector2i
var type: String
var purchasable = false

@export var material: Material

func _ready():
	$Mesh.set_surface_override_material(0, material)

func hoverHide():
	$Mesh/StaticBody3D.hoverHide()

func hoverShow():
	$Mesh/StaticBody3D.hoverShow()
