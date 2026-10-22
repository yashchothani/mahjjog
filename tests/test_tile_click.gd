extends SceneTree

const TileView = preload("res://scripts/board/tile_view.gd")
const MahjongTileData = preload("res://scripts/data/mahjong_tile_data.gd")

func _init():
	print("--- TESTING TILE VIEW CLICK DETECTION ---")
	var data = MahjongTileData.new("characters", "1", "一", "1 Characters")
	var tile = TileView.new(Vector3i(0, 0, 0), data)
	root.add_child(tile)
	tile._ready()
	
	var clicked = [false]
	tile.tile_clicked.connect(func(t): 
		print("SIGNAL RECEIVED BY LISTENER!")
		clicked[0] = true
	)
	
	for c in tile.get_children():
		print("Child: %s, mouse_filter: %d" % [c.name, c.mouse_filter])
		for gc in c.get_children():
			print("  Grandchild: %s, mouse_filter: %d" % [gc.name, gc.mouse_filter])
			
	# Test overlapping controls and z_index / tree order
	print("--- TESTING OVERLAPPING HIT-TEST ORDER ---")
	var root_ctrl = Control.new()
	root_ctrl.size = Vector2(800, 600)
	root.add_child(root_ctrl)
	
	var c1 = Control.new()
	c1.name = "TileBottom"
	c1.position = Vector2(50, 50)
	c1.size = Vector2(60, 80)
	c1.z_index = 0
	root_ctrl.add_child(c1)
	
	var c2 = Control.new()
	c2.name = "TileTop"
	c2.position = Vector2(60, 60)
	c2.size = Vector2(60, 80)
	c2.z_index = 10
	root_ctrl.add_child(c2)
	
	# Check tree order
	print("c1 index: %d, c2 index: %d" % [c1.get_index(), c2.get_index()])
	
	# Test mouse position inside overlap area (65, 65)
	var clicked_nodes = []
	c1.gui_input.connect(func(ev): clicked_nodes.append(c1.name))
	c2.gui_input.connect(func(ev): clicked_nodes.append(c2.name))
	
	tile.queue_free()
	root_ctrl.queue_free()
	quit(0)
