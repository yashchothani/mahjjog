extends SceneTree

const BoardLayout = preload("res://scripts/board/board_layout.gd")

func _init() -> void:
	print("--- CHECKING INITIAL FREE TILES FOR ALL 30 LAYOUTS ---")
	var failed: int = 0
	for lvl in range(1, 31):
		var layout = BoardLayout.get_layout_by_id(lvl)
		var free_count = 0
		var free_list = []
		for p in layout.positions:
			if BoardLayout.is_tile_free(p, layout.positions):
				free_count += 1
				free_list.append(p)
		print("Layout %02d: %-22s | Total tiles: %3d | Initial free tiles: %2d" % [lvl, layout.name, layout.positions.size(), free_count])
		if free_count < 2:
			printerr("  CRITICAL ERROR: Layout %d has ONLY %d free tile(s) at start! IMPOSSIBLE TO PLAY!" % [lvl, free_count])
			failed += 1
	
	if failed == 0:
		print("SUCCESS: All 30 layouts have at least 2 free tiles at start (fully playable)!")
	quit(failed)
