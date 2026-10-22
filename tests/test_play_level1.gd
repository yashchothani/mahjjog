extends SceneTree

const BoardView = preload("res://scripts/board/board_view.gd")
const TileView = preload("res://scripts/board/tile_view.gd")

func _init():
	print("--- FULL PLAYTHROUGH TEST: LEVEL 1 MINI TURTLE ---")
	if not root.has_node("SaveManager"):
		var sm = load("res://scripts/save/save_manager.gd").new()
		sm.name = "SaveManager"
		root.add_child(sm)
	if not root.has_node("GameManager"):
		var gm = load("res://scripts/core/game_manager.gd").new()
		gm.name = "GameManager"
		root.add_child(gm)
	if not root.has_node("LocalizationManager"):
		var lm = load("res://scripts/core/localization_manager.gd").new()
		lm.name = "LocalizationManager"
		root.add_child(lm)
	if not root.has_node("AudioManager"):
		var am = load("res://scripts/audio/audio_manager.gd").new()
		am.name = "AudioManager"
		root.add_child(am)
		
	var gameplay = load("res://scenes/gameplay/gameplay.tscn").instantiate()
	root.add_child(gameplay)
	gameplay.start_level(1)
	
	var bv = gameplay.get_node("BoardContainer/BoardView") as BoardView
	var pairs_cleared = 0
	
	print("Initial tiles: %d (%d pairs)" % [bv.active_tiles.size(), bv.active_tiles.size() / 2])
	
	while bv.active_tiles.size() > 0:
		var hint = bv.find_hint_pair()
		if hint.size() < 2:
			print("No moves left, shuffling...")
			bv.shuffle_remaining_tiles()
			hint = bv.find_hint_pair()
			assert(hint.size() == 2, "Shuffle must provide playable moves")
			
		var t1 = hint[0] as TileView
		var t2 = hint[1] as TileView
		
		# Click first tile via its ClickButton
		t1.click_button.emit_signal("pressed")
		assert(bv.selected_tile == t1, "t1 must be selected")
		assert(t1.is_selected == true, "t1.is_selected must be true")
		
		# Click matching tile via its ClickButton
		t2.click_button.emit_signal("pressed")
		assert(bv.selected_tile == null, "Selection must clear on match")
		
		pairs_cleared += 1
		print("  Matched pair %d: %s (%d tiles left)" % [pairs_cleared, t1.tile_data.display_name, bv.active_tiles.size()])
		
	assert(bv.active_tiles.is_empty(), "All tiles must be cleared")
	assert(pairs_cleared == 17, "Exactly 17 pairs should be cleared for Level 1 Mini Turtle")
	print("--- LEVEL 1 PLAYTHROUGH 100% SUCCESSFUL! ALL 17 PAIRS CLEARED VIA BUTTON CLICKS ---")
	gameplay.queue_free()
	quit(0)
