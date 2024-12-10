extends Camera3D

# Define the edge threshold (in pixels)
var edge_threshold: int = 125
# Camera movement speed
var camera_speed: float = 5.0
var tilt_angle_degrees: float = 90
var tilt_angle_radians = deg_to_rad(tilt_angle_degrees)

func _process(delta):	
	var viewport_size = get_viewport().size
	var grid = get_parent().get_node("HexGrid")	
	var mouse_position = get_viewport().get_mouse_position()
	var amount = camera_speed * delta
	
	# Check if mouse is within the viewport bounds
	if mouse_position.x >= 0 and mouse_position.x <= viewport_size.x and mouse_position.y >= 0 and mouse_position.y <= viewport_size.y:
		# Check for left edge
		if mouse_position.x < edge_threshold and position.x > 0:
			move(Vector2(-amount, 0))
		# Check for right edge
		elif mouse_position.x > viewport_size.x - edge_threshold and position.x < grid.grid_width * grid.TILE_SIZE - 3:
			move(Vector2(amount, 0))
		# Check for top edge
		if mouse_position.y < edge_threshold and position.z > 0:
			move(Vector2(0, amount))
		# Check for bottom edge
		elif mouse_position.y > viewport_size.y - edge_threshold and position.z < grid.grid_height * grid.TILE_SIZE:
			move(Vector2(0, -amount))
	
			
func move(direction: Vector2):
	# Tilt angle from the horizontal
	tilt_angle_degrees = 90 + rotation_degrees.x
	# Convert tilt angle to radians for Godot's trig functions
	tilt_angle_radians = deg_to_rad(tilt_angle_degrees)
	
	# Calculate the Z adjustment dynamically based on vertical movement and tilt angle
	var z_adjustment = 0
	z_adjustment = tan(tilt_angle_radians) * direction.y
	translate(Vector3(direction.x, direction.y, -z_adjustment))
	#translate(Vector3(direction.x, direction.y, z_adjustment))

	


func _input(event):
	const maxZoom = 4
	const minZoom = 2
	
	if event is InputEventMouseButton:
		if event.is_pressed():
			# zoom in
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				position.y = clampf(position.y - 0.05, minZoom, maxZoom)
				
			# zoom out
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				position.y = clampf(position.y + 0.05, minZoom, maxZoom)
				
	#if event is InputEventMouseMotion:

