extends Node3D
var pos: Vector2i
var type: String
var purchasable = false

@export var material: Material

# Called when the node enters the scene tree for the first time.
func _ready():
	$Mesh.set_surface_override_material(0, material)
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func setPos(val):
	pos = val
	
func setType(val):
	type = val
	
func hoverHide():
	$Mesh/StaticBody3D.hoverHide()
	
func hoverShow():
	$Mesh/StaticBody3D.hoverShow()
	for child in $Mesh/Objects.get_children():
		print('p: ' + child.render_priority)
