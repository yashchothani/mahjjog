extends SceneTree

func _init() -> void:
	var BoardGenerator = preload("res://scripts/board/board_generator.gd")
	var BoardLayout = preload("res://scripts/board/board_layout.gd")
	var MahjongTileData = preload("res://scripts/data/mahjong_tile_data.gd")
	
	print("====================================================")
	print(" VERIFYING SOLUTION PATH CLEARANCE FOR ALL 80 LEVELS")
	print("====================================================")
	
	for lvl in range(1, 81):
		var res = BoardGenerator.generate_level(lvl)
		var current_positions: Array[Vector3i] = []
		for p in res.tile_map.keys():
			current_positions.append(p)
			
		for pair_idx in range(res.solution_pairs.size()):
			var pair = res.solution_pairs[pair_idx]
			var p1: Vector3i = pair[0]
			var p2: Vector3i = pair[1]
			var free1 = BoardLayout.is_tile_free(p1, current_positions)
			var free2 = BoardLayout.is_tile_free(p2, current_positions)
			if not free1 or not free2:
				print("Level %d, step %d failed! p1(%s) free=%s, p2(%s) free=%s" % [lvl, pair_idx, p1, free1, p2, free2])
				quit(1)
				return
			current_positions.erase(p1)
			current_positions.erase(p2)
			
		if not current_positions.is_empty():
			print("Level %d has remaining positions after solution path!" % lvl)
			quit(1)
			return
			
	print("SUCCESS: ALL 80 LEVELS PROVEN 100% CLEARABLE ALONG SOLUTION PATH!")
	quit(0)
