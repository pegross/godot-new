extends Node

const TILE_SIZE := sqrt(3) / 2.0 # derived from hexagonal geometry; corresponds to √3/2 ≈ 0.866 for proper hex spacing

func pos_to_world(pos: Vector2i) -> Vector2:
	var offset = 0 if pos.x % 2 == 0 else TILE_SIZE / 2
	return Vector2(pos.x * TILE_SIZE * cos(deg_to_rad(30)), pos.y * TILE_SIZE + offset)

func get_neighbor_pos(tile, direction: String) -> Vector2i:
	var newPos = tile.pos
	var isShort = newPos.x % 2 != 0

	match direction:
		"SW":
			newPos += Vector2i(-1, 1) if isShort else Vector2i(-1, 0)
		"NW":
			newPos += Vector2i(-1, 0) if isShort else Vector2i(-1, -1)
		"N":
			newPos += Vector2i(0, -1)
		"NE":
			newPos += Vector2i(1, 0) if isShort else Vector2i(1, -1)
		"SE":
			newPos += Vector2i(1, 1) if isShort else Vector2i(1, 0)
		"S":
			newPos += Vector2i(0, 1)
	return newPos
