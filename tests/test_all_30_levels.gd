extends SceneTree

const BoardGenerator = preload("res://scripts/board/board_generator.gd")

func _init():
	print("--- TESTING GENERATION FOR ALL 30 LEVELS ---")
	var success_count = 0
	for lvl in range(1, 31):
		var res = BoardGenerator.generate_level(lvl)
		if not res.success:
			print("FAIL: Level %d failed to generate!" % lvl)
			quit(1)
			return
		assert(res.tile_map.size() % 2 == 0, "Tile count must be even")
		assert(res.solution_pairs.size() == res.tile_map.size() / 2, "Solution pairs must match half tile count")
		var solvable = BoardGenerator.solver_can_solve(res.tile_map)
		assert(solvable, "Level %d must be solvable by solver!" % lvl)
		print("Level %02d: %-22s (%d tiles, %d solution pairs) - SOLVABLE: YES" % [lvl, res.layout_name, res.tile_map.size(), res.solution_pairs.size()])
		success_count += 1
		
	print("SUCCESS: All %d levels generated successfully with valid pairs!" % success_count)
	quit(0)
