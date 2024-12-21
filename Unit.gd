extends Node3D
class_name Unit

signal unit_moved(new_pos: Vector2i)
signal unit_damaged(amount: int)
signal unit_died()

@export var max_health: int = 10
@export var attack_power: int = 3
@export var defense: int = 1
@export var movement_points: int = 5
@export var team_id: int = 0

var current_health: int
var current_movement: int
var tile_pos: Vector2i
var facing_left = false  # Track current facing direction

var grid_manager

func _ready():
	current_health = max_health
	current_movement = movement_points
	get_node("AnimatedSprite3D").play("idle")
	grid_manager = get_node("/root/Main/HexGrid/GridManager")

func start_new_turn():
	current_movement = movement_points

func end_turn():
	pass

func can_move_to(target_pos: Vector2i) -> bool:
	var hex_pathfinder = grid_manager.pathfinder	
	var path_cost = hex_pathfinder.calculate_path_cost(self, target_pos)
	if path_cost == -1:
		return false
	if path_cost > current_movement:
		return false
	return true

func move_to_tile(target_pos: Vector2i):
	var grid_manager = get_node("/root/Main/HexGrid/GridManager")
	var hex_pathfinder = grid_manager.pathfinder

	var path = hex_pathfinder.calculate_path(self, target_pos)
	if path.size() == 0:
		return

	var total_cost = 0
	for i in range(path.size()):
		if i > 0:
			var tile = grid_manager.get_tile_from_grid(path[i])
			total_cost += tile.movement_cost

	if total_cost > current_movement:
		return

	if not grid_manager.request_occupy_tile(self, tile_pos, target_pos):
		return

	tile_pos = target_pos
	current_movement -= total_cost
	print("move points: " + str(current_movement))

	var sprite = get_node("AnimatedSprite3D")

	# Start animating from the second tile in the path (index 1)
	_animate_next_step(1, path, sprite, grid_manager)

func _animate_next_step(index: int, path: Array, sprite: AnimatedSprite3D, grid_manager):
	if index >= path.size():
		emit_signal("unit_moved", tile_pos)
		sprite.play("move")
		return

	var next_tile = grid_manager.get_tile_from_grid(path[index])
	var tile_world_pos = HexMath.pos_to_world(path[index])
	var end_pos = Vector3(tile_world_pos.x, global_position.y, tile_world_pos.y)

	if end_pos.x < global_position.x:
		facing_left = true
		flip_sprite(facing_left)
	elif end_pos.x > global_position.x:
		facing_left = false
		flip_sprite(facing_left)

	var segment_duration = 0.3 * next_tile.movement_cost
	var tween = create_tween()
	tween.tween_property(self, "global_position", end_pos, segment_duration)

	var on_tween_finished = func():
		_animate_next_step(index + 1, path, sprite, grid_manager)

	tween.finished.connect(on_tween_finished)
	

func flip_sprite(is_left: bool):
	var sprite = get_node("AnimatedSprite3D")
	sprite.flip_h = is_left

func take_damage(amount: int):
	var dmg = max(amount - defense, 0)
	if dmg <= 0:
		return

	current_health = max(current_health - dmg, 0)
	emit_signal("unit_damaged", dmg)
	get_node("AnimatedSprite3D").play("hurt")

	if current_health <= 0:
		die()

func die():
	emit_signal("unit_died")
	var grid_manager = get_node("/root/Main/HexGrid/GridManager")
	grid_manager.remove_unit_from_tile(tile_pos)
	queue_free()

func attack(target: Node):
	if target is Unit:
		target.take_damage(attack_power)
		get_node("AnimatedSprite3D").play("attack")

func select_unit():
	print("selected, move points: ", current_movement)

func deselect_unit():
	print("deselected")
