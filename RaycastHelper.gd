extends Node

const RAY_LENGTH = 1000

func raycast(screen_pos: Vector2, camera: Camera3D) -> Node:
	var space_state = get_viewport().get_world_3d().direct_space_state
	var origin = camera.project_ray_origin(screen_pos)
	var endpoint = origin + camera.project_ray_normal(screen_pos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, endpoint)
	query.collide_with_areas = true
	var result = space_state.intersect_ray(query)
	return result.get('collider') if result.has('collider') else null
