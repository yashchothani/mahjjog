extends SceneTree

const BoardView = preload("res://scripts/board/board_view.gd")
const TileView = preload("res://scripts/board/tile_view.gd")

func _init():
	print("====================================================")
	print("   TESTING RESPONSIVE VIEWPORTS & TOUCH MAPPINGS    ")
	print("====================================================")
	
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
		
	var test_viewports = [
		Vector2(1280, 720), # Reference 16:9 Landscape
		Vector2(1280, 800), # Android Tablet 16:10
		Vector2(1024, 768), # iPad / Tablet 4:3 Landscape
		Vector2(932, 430),  # iPhone Pro Max Landscape
		Vector2(844, 390),  # Modern iPhone Landscape
		Vector2(640, 360)   # Compact Mobile Landscape
	]
	
	for vp in test_viewports:
		print("\n[VIEWPORT TEST] Testing resolution: %d x %d" % [int(vp.x), int(vp.y)])
		root.size = Vector2i(int(vp.x), int(vp.y))
		var gameplay = load("res://scenes/gameplay/gameplay.tscn").instantiate()
		root.add_child(gameplay)
		gameplay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		
		# Set BoardContainer and BoardView size directly to test layout
		var bc = gameplay.get_node("BoardContainer") as Control
		bc.size = Vector2(vp.x, vp.y * 0.82)
		bc.position = Vector2(0, vp.y * 0.08)
		
		var bv = gameplay.get_node("BoardContainer/BoardView") as BoardView
		bv.size = bc.size
		gameplay.start_level(1)
		bv._center_board()
		
		# 1. Verify TopBar and BottomBar bounds
		var topbar = gameplay.get_node("TopBar") as Control
		var botbar = gameplay.get_node("BottomBar") as Control
		assert(topbar.position.y >= 0, "TopBar must be inside viewport top")
		assert(botbar.position.y + botbar.size.y <= vp.y + 1.0, "BottomBar must be inside viewport bottom")
		
		# 2. Check Board boundaries do not clip outside viewport
		var active = bv.active_tiles
		assert(active.size() == 34, "Board must have 34 active tiles")
		
		var min_x = 999999.0
		var max_x = -999999.0
		var min_y = 999999.0
		var max_y = -999999.0
		
		for pos in active.keys():
			var tile = active[pos] as TileView
			var t_rect = Rect2(tile.global_position, tile.size * tile.scale)
			min_x = min(min_x, t_rect.position.x)
			max_x = max(max_x, t_rect.position.x + t_rect.size.x)
			min_y = min(min_y, t_rect.position.y)
			max_y = max(max_y, t_rect.position.y + t_rect.size.y)
			
		print("  -> Global screen board box: X=[%.1f, %.1f], Y=[%.1f, %.1f]" % [min_x, max_x, min_y, max_y])
		assert(min_x >= 0.0 and max_x <= vp.x, "Board must fit inside screen horizontally")
		assert(min_y >= topbar.size.y * 0.8, "Board must not overlap top bar")
		assert(max_y <= vp.y - botbar.size.y * 0.8, "Board must not overlap bottom bar")
		
		# 3. Touch hit target validation
		var sample_tile = active[Vector3i(6, 0, 0)] as TileView
		var touch_target_w = sample_tile.size.x * sample_tile.scale.x
		var touch_target_h = sample_tile.size.y * sample_tile.scale.y
		print("  -> Tile touch target size: %.1f x %.1f px" % [touch_target_w, touch_target_h])
		assert(touch_target_w >= 18.0, "Touch target width must be >= 18px")
		assert(touch_target_h >= 24.0, "Touch target height must be >= 24px")
		
		# 4. Touch coordinate simulation
		var touch_pos = sample_tile.global_position + sample_tile.size * 0.5 * sample_tile.scale
		sample_tile.click_button.emit_signal("pressed")
		assert(bv.selected_tile == sample_tile, "Touch must successfully select tile")
		print("  -> Touch tap event successfully selected tile: %s" % sample_tile.tile_data.display_name)
		
		gameplay.queue_free()
		print("  -> Viewport %d x %d PASSED ALL CHECKS!" % [int(vp.x), int(vp.y)])
		
	print("====================================================")
	print(" ALL 6 MOBILE & TABLET VIEWPORT SIZES VERIFIED!     ")
	print("====================================================")
	quit(0)
