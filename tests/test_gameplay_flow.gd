extends SceneTree

const MahjongTileData = preload("res://scripts/data/mahjong_tile_data.gd")
const BoardView = preload("res://scripts/board/board_view.gd")
const BoardGenerator = preload("res://scripts/board/board_generator.gd")

func _init() -> void:
	_run_standalone.call_deferred()

func _run_standalone() -> void:
	run_tests(self)
	await process_frame
	quit(0)

static func run_tests(tree: SceneTree) -> void:
	print("--- STARTING COMPREHENSIVE GAMEPLAY FLOW TEST ---")
	
	print("[FLOW 1] Creating and initializing BoardView...")
	var board = BoardView.new()
	tree.root.add_child(board)
	board.size = Vector2(1280, 720)
	
	# Setup Level 1
	board.setup_level(1)
	var initial_tile_count = board.active_tiles.size()
	print("  -> Board initialized with %d tiles (%d pairs)" % [initial_tile_count, initial_tile_count / 2])
	assert(initial_tile_count > 0, "Board should contain tiles")
	assert(initial_tile_count % 2 == 0, "Tile count must be even")
	
	print("[FLOW 2] Testing Hint Discovery...")
	var hint_pair = board.find_hint_pair()
	assert(hint_pair.size() == 2, "There must be at least one free matching pair at the start")
	var t1 = hint_pair[0]
	var t2 = hint_pair[1]
	print("  -> Hint found: %s at %s AND %s at %s" % [t1.tile_data.display_name, str(t1.grid_pos), t2.tile_data.display_name, str(t2.grid_pos)])
	assert(t1.is_free and t2.is_free, "Hinted tiles must both be free")
	assert(MahjongTileData.tiles_match(t1.tile_data, t2.tile_data), "Hinted tiles must match")
	
	print("[FLOW 3] Testing Selection & Pair Matching...")
	board._on_tile_clicked(t1)
	assert(board.selected_tile == t1, "First tile should be selected")
	assert(t1.is_selected == true, "Tile visual state should be selected")
	
	board._on_tile_clicked(t2)
	assert(board.selected_tile == null, "Selection should clear after match")
	assert(board.active_tiles.size() == initial_tile_count - 2, "Two tiles should be removed")
	assert(board.moves_count == 1, "Moves count should increment to 1")
	print("  -> Tiles matched and removed successfully! Remaining: %d" % board.active_tiles.size())
	
	print("[FLOW 4] Testing Undo Operation...")
	var undo_success = board.undo_move()
	assert(undo_success == true, "Undo should succeed")
	assert(board.active_tiles.size() == initial_tile_count, "Tile count should be fully restored")
	assert(board.moves_count == 0, "Moves count should be decremented to 0")
	assert(board.active_tiles.has(t1.grid_pos), "Tile 1 position should be restored")
	assert(board.active_tiles.has(t2.grid_pos), "Tile 2 position should be restored")
	print("  -> Undo successfully restored previous board state!")
	
	print("[FLOW 5] Testing Solvable Generation Assurance...")
	assert(BoardGenerator.solver_can_solve(board.initial_tile_map), "Board must be proven 100% solvable without shuffle")
	print("  -> Solvable board verified with zero shuffle reliance!")
	
	print("[FLOW 6] Testing Level Restart Operation...")
	var pair_to_match = board.find_hint_pair()
	if pair_to_match.size() == 2:
		board._on_tile_clicked(pair_to_match[0])
		board._on_tile_clicked(pair_to_match[1])
	assert(board.active_tiles.size() == initial_tile_count - 2, "Pair should be removed before restart")
	board.restart_level()
	assert(board.active_tiles.size() == initial_tile_count, "Restart should restore initial tile count")
	assert(board.moves_count == 0, "Restart should reset moves count to 0")
	print("  -> Level restart successfully restored exact initial board!")
	
	print("[FLOW 7] Testing Full Clearance / Victory (No Shuffle Needed)...")
	var tracker = {"cleared": false}
	board.board_cleared.connect(func(): tracker["cleared"] = true)
	
	var max_steps = initial_tile_count * 2
	while board.active_tiles.size() > 0 and max_steps > 0:
		var pair = board.find_hint_pair()
		assert(pair.size() == 2, "Level must provide continuous matching pairs without shuffle")
		board._on_tile_clicked(pair[0])
		board._on_tile_clicked(pair[1])
		max_steps -= 1
		
	print("  -> Final active tiles count: %d" % board.active_tiles.size())
	assert(board.active_tiles.size() == 0, "Board should be completely cleared without shuffle")
	assert(tracker["cleared"] == true, "board_cleared signal must have fired")
	print("  -> Victory signal verified successfully with 0 shuffles!")
	
	board.clear_board()
	tree.root.remove_child(board)
	board.free()
	print("--- GAMEPLAY FLOW TEST COMPLETED WITH 100% SUCCESS ---")
