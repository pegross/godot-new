extends StaticBody3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func root():
	return get_parent().get_parent()
	
func hoverShow():
	get_parent().get_node("HoverLight").visible = true

func hoverHide():
	get_parent().get_node("HoverLight").visible = false
