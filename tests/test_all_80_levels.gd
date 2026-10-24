extends SceneTree

## Automated Solver & Verification Test across all 80 Zen Mahjong Levels.

const BoardGenerator = preload("res://scripts/board/board_generator.gd")
const BoardLayout = preload("res://scripts/board/board_layout.gd")

func _init() -> void:
	print("====================================================")
	print("   TESTING SOLVABILITY FOR ALL 80 MAHJONG LEVELS    ")
	print("====================================================")
	var success_count = 0
	
	for lvl in range(1, 81):
		var res = BoardGenerator.generate_level(lvl)
		if not res.success:
			print("FAIL: Level %d failed to generate!" % lvl)
			quit(1)
			return
			
		assert(res.tile_map.size() % 2 == 0, "Tile count must be even for level %d" % lvl)
		assert(res.solution_pairs.size() == res.tile_map.size() / 2, "Solution pairs must match half tile count for level %d" % lvl)
		
		var solvable = BoardGenerator.solver_can_solve(res.tile_map)
		assert(solvable, "Level %d must be solvable by solver!" % lvl)
		
		var tier = BoardLayout.get_tier_for_level(lvl)
		print("Level %02d [%-11s]: %-25s (%d tiles, %d solution pairs) - SOLVABLE: YES" % [lvl, tier, res.layout_name, res.tile_map.size(), res.solution_pairs.size()])
		success_count += 1
		
	print("====================================================")
	print(" SUCCESS: ALL %d LEVELS GENERATED & SOLVED (100%%)   " % success_count)
	print("====================================================")
	quit(0)
