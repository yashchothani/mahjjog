extends SceneTree

## Full Gameplay Test for Level 80 (Supreme Grandmaster 144 - Hardest High-IQ Level).

const BoardView = preload("res://scripts/board/board_view.gd")
const BoardLayout = preload("res://scripts/board/board_layout.gd")

func _init() -> void:
	print("====================================================")
	print("  TESTING FULL PLAYTHROUGH: LEVEL 80 GRANDMASTER   ")
	print("====================================================")
	
	if not root.has_node("SaveManager"):
		var sm = load("res://scripts/save/save_manager.gd").new()
		sm.name = "SaveManager"
		root.add_child(sm)
	if not root.has_node("LocalizationManager"):
		var lm = load("res://scripts/core/localization_manager.gd").new()
		lm.name = "LocalizationManager"
		root.add_child(lm)
		
	var gameplay_scene = load("res://scenes/gameplay/gameplay.tscn").instantiate()
	root.add_child(gameplay_scene)
	gameplay_scene.start_level(80)
	
	var bv = gameplay_scene.get_node("BoardContainer/BoardView") as BoardView
	assert(bv != null, "BoardView must exist")
	print("  -> Level 80 initialized with %d tiles (%d pairs)!" % [bv.active_tiles.size(), bv.active_tiles.size() / 2])
	assert(bv.active_tiles.size() >= 120, "Level 80 must have at least 120 tiles for high-IQ grandmaster challenge")
	
	var cleared_pairs = 0
	while bv.active_tiles.size() > 0:
		var hint = bv.find_hint_pair()
		assert(hint.size() == 2, "Solver must find a valid free pair without deadlocking (remaining: %d)" % bv.active_tiles.size())
		var t1 = hint[0]
		var t2 = hint[1]
		
		# Simulate clicking both tiles
		bv._on_tile_clicked(t1)
		bv._on_tile_clicked(t2)
		cleared_pairs += 1
		
	print("  -> Cleared all %d pairs in Level 80 Supreme Grandmaster!" % cleared_pairs)
	assert(bv.active_tiles.is_empty(), "All tiles in Level 80 must be cleared")
	
	root.remove_child(gameplay_scene)
	gameplay_scene.free()
	
	print("====================================================")
	print(" LEVEL 80 HIGH-IQ GRANDMASTER PLAYTHROUGH: 100% PASS ")
	print("====================================================")
	quit(0)
