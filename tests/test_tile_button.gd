extends SceneTree

const TileView = preload("res://scripts/board/tile_view.gd")
const MahjongTileData = preload("res://scripts/data/mahjong_tile_data.gd")

func _init():
	print("--- TESTING TILE BUTTON CLICK ---")
	var root_ctrl = Control.new()
	root_ctrl.size = Vector2(1280, 720)
	root.add_child(root_ctrl)
	
	var data = MahjongTileData.new("characters", "1", "一", "1 Characters")
	var tile = TileView.new(Vector3i(0, 0, 0), data)
	tile.position = Vector2(200, 200)
	root_ctrl.add_child(tile)
	tile._ready()
	
	var clicked = [false]
	tile.tile_clicked.connect(func(t):
		print("SUCCESS: tile_clicked emitted!")
		clicked[0] = true
	)
	
	# Check all children and their mouse filter
	for c in tile.get_children():
		print("Child %s: filter=%d" % [c.name, c.mouse_filter])
		for gc in c.get_children():
			print("  Grandchild %s: filter=%d" % [gc.name, gc.mouse_filter])
			
	# Test clicking the ClickButton
	var btn = tile.get_node_or_null("ClickButton") as Button
	assert(btn != null, "ClickButton must exist")
	print("ClickButton exists, mouse_filter = %d" % btn.mouse_filter)
	
	btn.emit_signal("pressed")
	assert(clicked[0] == true, "tile_clicked should be emitted when button is pressed")
	print("TEST PASSED: Button emit_signal('pressed') correctly triggered tile_clicked!")
	
	clicked[0] = false
	var ev = InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = true
	tile._gui_input(ev)
	assert(clicked[0] == true, "tile_clicked should be emitted by _gui_input")
	print("TEST PASSED: Direct _gui_input correctly triggered tile_clicked!")
	
	tile.queue_free()
	root_ctrl.queue_free()
	quit(0)
