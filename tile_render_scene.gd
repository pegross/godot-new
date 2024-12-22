extends Node3D

func _ready():
	# Possibly wait a frame so the viewport has time to render.
	await RenderingServer.frame_post_draw

	var vp = $SubViewport
	var tex = vp.get_texture().get_image().save_png("res://forest_icon.png")
