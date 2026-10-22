extends SceneTree

const MahjongTileData = preload("res://scripts/data/mahjong_tile_data.gd")
const BoardView = preload("res://scripts/board/board_view.gd")
const TileView = preload("res://scripts/board/tile_view.gd")

func _init():
	print("--- TESTING INTERACTIVE TILE PICKUP AND MATCH IN REAL SCENE ---")
	if not root.has_node("SaveManager"):
		var sm = load("res://scripts/save/save_manager.gd").new()
		sm.name = "SaveManager"
		root.add_child(sm)
	if not root.has_node("GameManager"):
		var gm = load("res://scripts/core/game_manager.gd").new()
		gm.name = "GameManager"
		root.add_child(gm)
	if not root.has_node("AudioManager"):
		var am = load("res://scripts/audio/audio_manager.gd").new()
		am.name = "AudioManager"
		root.add_child(am)
		
	var gameplay_scene = load("res://scenes/gameplay/gameplay.tscn").instantiate()
	root.add_child(gameplay_scene)
	gameplay_scene.start_level(1)
	
	var bv = gameplay_scene.get_node("BoardContainer/BoardView") as BoardView
	assert(bv != null, "BoardView should be found")
	print("BoardView active tiles: %d" % bv.active_tiles.size())
	
	var hint_pair = bv.find_hint_pair()
	assert(hint_pair.size() == 2, "There must be a matching free pair")
	var t1 = hint_pair[0] as TileView
	var t2 = hint_pair[1] as TileView
	print("Found free pair: %s at %s AND %s at %s" % [t1.tile_data.display_name, str(t1.grid_pos), t2.tile_data.display_name, str(t2.grid_pos)])
	
	print("t1 is_inside_tree: %s, children count: %d" % [str(t1.is_inside_tree()), t1.get_child_count()])
	for c in t1.get_children():
		print("  t1 child: %s" % c.name)
		
	var btn1 = t1.click_button
	assert(btn1 != null, "Tile 1 must have click_button property")
	print("Found t1.click_button: %s, pressing it..." % str(btn1))
	btn1.emit_signal("pressed")
	
	assert(bv.selected_tile == t1, "t1 must now be selected on the board")
	assert(t1.is_selected == true, "t1.is_selected must be true")
	print("SUCCESS: Tile 1 picked up / selected! is_selected = %s" % str(t1.is_selected))
	
	# Simulate clicking t2's button (the matching tile)
	var btn2 = t2.get_node("ClickButton") as Button
	assert(btn2 != null, "Tile 2 must have ClickButton")
	print("Clicking matching tile 2 ClickButton...")
	btn2.emit_signal("pressed")
	
	assert(bv.selected_tile == null, "Selection must be cleared after match")
	assert(not bv.active_tiles.has(t1.grid_pos), "Tile 1 must be removed from active tiles")
	assert(not bv.active_tiles.has(t2.grid_pos), "Tile 2 must be removed from active tiles")
	assert(bv.moves_count == 1, "Moves count must be 1")
	print("SUCCESS: Matching pair successfully removed! Moves: %d, Remaining tiles: %d" % [bv.moves_count, bv.active_tiles.size()])
	
	gameplay_scene.queue_free()
	print("--- INTERACTIVE PICKUP TEST PASSED 100% ---")
	quit(0)
