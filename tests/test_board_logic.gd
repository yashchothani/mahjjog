extends SceneTree

const MahjongTileData = preload("res://scripts/data/mahjong_tile_data.gd")
const BoardLayout = preload("res://scripts/board/board_layout.gd")
const BoardGenerator = preload("res://scripts/board/board_generator.gd")

func _init() -> void:
	_run_standalone.call_deferred()

func _run_standalone() -> void:
	run_tests()
	await process_frame
	quit(0)

static func run_tests() -> void:
	print("--- BEGINNING MAHJONG SOLITAIRE CORE LOGIC TESTS ---")
	test_tile_matching()
	test_free_tile_detection()
	test_solvable_level_generation()
	print("--- ALL CORE TESTS COMPLETED SUCCESSFULLY ---")

static func test_tile_matching() -> void:
	print("[TEST] 1. Tile Matching Rules...")
	var b1a = MahjongTileData.new("bamboo", "1", "鳥")
	var b1b = MahjongTileData.new("bamboo", "1", "鳥")
	var b2 = MahjongTileData.new("bamboo", "2", "2")
	var d1 = MahjongTileData.new("dots", "1", "①")
	
	assert(MahjongTileData.tiles_match(b1a, b1b), "Identical bamboo tiles must match")
	assert(!MahjongTileData.tiles_match(b1a, b2), "Different values must not match")
	assert(!MahjongTileData.tiles_match(b1a, d1), "Different suits must not match")
	
	# Flowers match any other flower
	var f1 = MahjongTileData.new("flowers", "plum", "梅")
	var f2 = MahjongTileData.new("flowers", "orchid", "蘭")
	assert(MahjongTileData.tiles_match(f1, f2), "Different flowers must match each other")
	
	# Seasons match any other season
	var s1 = MahjongTileData.new("seasons", "spring", "春")
	var s2 = MahjongTileData.new("seasons", "winter", "冬")
	assert(MahjongTileData.tiles_match(s1, s2), "Different seasons must match each other")
	print("  -> Passed tile matching assertions!")

static func test_free_tile_detection() -> void:
	print("[TEST] 2. Free Tile Detection Rules...")
	var tiles: Array[Vector3i] = [
		Vector3i(0, 0, 0),
		Vector3i(2, 0, 0),
		Vector3i(4, 0, 0)
	]
	
	# Left tile has right blocked by Center, but left is OPEN -> FREE
	assert(BoardLayout.is_tile_free(Vector3i(0, 0, 0), tiles) == true, "Left tile must be free")
	# Right tile has left blocked by Center, but right is OPEN -> FREE
	assert(BoardLayout.is_tile_free(Vector3i(4, 0, 0), tiles) == true, "Right tile must be free")
	# Center tile has BOTH left and right blocked -> NOT FREE
	assert(BoardLayout.is_tile_free(Vector3i(2, 0, 0), tiles) == false, "Center tile must NOT be free")
	
	# Tile blocked from above:
	tiles.append(Vector3i(2, 0, 1))
	assert(BoardLayout.is_tile_free(Vector3i(2, 0, 0), tiles) == false, "Tile under layer 1 must NOT be free")
	assert(BoardLayout.is_tile_free(Vector3i(2, 0, 1), tiles) == true, "Top layer tile must be free")
	
	print("  -> Passed free tile detection assertions!")

static func test_solvable_level_generation() -> void:
	print("[TEST] 3. Solvable Level Generation across all 30 layouts...")
	for lvl in range(1, 31):
		var res = BoardGenerator.generate_level(lvl)
		assert(res.success, "Generation must succeed for level %d (%s)" % [lvl, res.layout_name])
		assert(res.tile_map.size() > 0, "Tile map must not be empty")
		assert(res.tile_map.size() % 2 == 0, "Tile map must have an even number of tiles")
		assert(res.solution_pairs.size() == res.tile_map.size() / 2, "Solution pairs count must equal half tile count")
		assert(BoardGenerator.solver_can_solve(res.tile_map), "Level %d must be proven solvable by solver" % lvl)
		print("  -> Level %02d: %-22s (%d tiles, %d solution pairs) - Proven Solvable" % [lvl, res.layout_name, res.tile_map.size(), res.solution_pairs.size()])
		
	print("  -> Passed all 30 solvable level generation assertions!")
