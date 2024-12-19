extends Camera3D

var edge_threshold: int = 125
var camera_speed: float = 5.0

var grid_manager
var hex_math

func _ready():
	# Get references to the managers
	grid_manager = $"../GridManager"
	hex_math = $"../HexMath"
	grid_manager.grid_ready.connect(_on_grid_ready)

func _on_grid_ready(width: int, height: int):
	var hex_math = $"../HexMath"
	var tower_pos = Vector2i(width / 2, height / 2)
	var world_pos = hex_math.pos_to_world(tower_pos)
	var current_height = position.y
	global_transform.origin = Vector3(world_pos.x, current_height, world_pos.y)
	
func _process(delta):
	var viewport_size = get_viewport().size
	var mouse_position = get_viewport().get_mouse_position()
	var amount = camera_speed * delta

	# Check for left/right movement
	if mouse_position.x < edge_threshold and position.x > 0:
		move(Vector2(-amount, 0))
	elif mouse_position.x > viewport_size.x - edge_threshold and position.x < (grid_manager.grid_width * hex_math.TILE_SIZE) - 3:
		move(Vector2(amount, 0))

	# Check for up/down movement
	if mouse_position.y < edge_threshold and position.z > 0:
		move(Vector2(0, amount))
	elif mouse_position.y > viewport_size.y - edge_threshold and position.z < (grid_manager.grid_height * hex_math.TILE_SIZE):
		move(Vector2(0, -amount))

func move(direction: Vector2):
	var tilt_angle_degrees = 90 + rotation_degrees.x
	var tilt_angle_radians = deg_to_rad(tilt_angle_degrees)
	var z_adjustment = tan(tilt_angle_radians) * direction.y
	translate(Vector3(direction.x, direction.y, -z_adjustment))

func _input(event):
	const maxZoom = 4
	const minZoom = 2

	if event is InputEventMouseButton and event.is_pressed():
		# zoom in/out logic
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			position.y = clampf(position.y - 0.05, minZoom, maxZoom)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			position.y = clampf(position.y + 0.05, minZoom, maxZoom)
