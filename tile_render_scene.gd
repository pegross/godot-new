extends Node

var tile_paths = [
	"res://tiles/forest.tscn",
	"res://tiles/mountain.tscn",
	"res://tiles/water.tscn",
	"res://tiles/tile.tscn"
]

var current_index = 0
var tile_root: Node3D
var is_busy = false

func _process(delta):
	if is_busy:
		return
	
	if current_index >= tile_paths.size():
		print("All tiles rendered!")
		get_tree().quit()
		return
	
	is_busy = true
	_render_tile(tile_paths[current_index])


func _render_tile(tile_path: String):
	_purge_existing_children()
	
	# Wait 1 frame for the old tile to be fully removed.
	call_deferred("_after_removal", tile_path)

func _after_removal(tile_path: String):
	# Instantiate the new tile
	var tile_scene = load(tile_path) as PackedScene
	var render_root = $SubViewport/RenderRoot3D
	tile_root = tile_scene.instantiate() as Node3D
	render_root.add_child(tile_root)
	
	# Wait a fraction of a second for the tile to appear and be rendered
	# Then capture
	get_tree().create_timer(0.1).timeout.connect(func():
		_capture_and_save_png(tile_path)
	)


func _capture_and_save_png(tile_path: String):
	var tex = $SubViewport.get_texture()
	if tex:
		var img = tex.get_image()
		if img:
			# Derive the output file name from the tile_path
			var base_name = tile_path.get_file().get_basename()  # e.g. 'forest'
			var output_path = "res://icons/" + base_name + "_icon.png"
			
			img.save_png(output_path)
			print("Saved tile icon:", output_path)
	
	# Now that we've captured, we increment index and allow next tile
	current_index += 1
	is_busy = false


func _purge_existing_children():
	var render_root = $SubViewport/RenderRoot3D
	for child in render_root.get_children():
		if child.name not in ["Camera3D", "DirectionalLight3D"]:
			child.queue_free()
