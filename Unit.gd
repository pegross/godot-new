extends Node3D
class_name Unit

signal unit_moved(new_pos: Vector2i)
signal unit_damaged(amount: int)
signal unit_died()

@export var max_health: int = 10
@export var attack_power: int = 3
@export var defense: int = 1
@export var movement_points: int = 3
@export var team_id: int = 0

var current_health: int
var current_movement: int
var tile_pos: Vector2i

func _ready():
	current_health = max_health
	current_movement = movement_points
	get_node("AnimatedSprite3D").play("idle")

func start_new_turn():
	current_movement = movement_points

func end_turn():
	pass

func can_move_to(target_pos: Vector2i) -> bool:
	var distance = abs(target_pos.x - tile_pos.x) + abs(target_pos.y - tile_pos.y)
	return distance <= current_movement

func move_to_tile(target_pos: Vector2i):
	if not can_move_to(target_pos):
		return

	var grid_manager = get_node("/root/Main/HexGrid/GridManager")
	if grid_manager.request_occupy_tile(self, tile_pos, target_pos):
		tile_pos = target_pos
		current_movement -= 1
		var world_pos = HexMath.pos_to_world(tile_pos)
		global_transform.origin = Vector3(world_pos.x, global_transform.origin.y, world_pos.y)

		emit_signal("unit_moved", tile_pos)
		get_node("AnimatedSprite3D").play("move")

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
	print("hello")
	pass

func deselect_unit():
	print("bye")
	pass
