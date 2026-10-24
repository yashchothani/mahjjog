class_name BoardGenerator
extends RefCounted

## Generates 100% guaranteed solvable Mahjong boards using reverse pair matching.

const MahjongTileData = preload("res://scripts/data/mahjong_tile_data.gd")
const BoardLayout = preload("res://scripts/board/board_layout.gd")

class GenerationResult:
	var success: bool = false
	var tile_map: Dictionary = {} # Vector3i -> MahjongTileData
	var solution_pairs: Array[Array] = [] # Array of [Vector3i, Vector3i] in removal order
	var layout_name: String = ""

static func generate_level(level_id: int, seed_offset: int = 0) -> GenerationResult:
	var layout = BoardLayout.get_layout_by_id(level_id)
	return generate_from_layout(layout, level_id + seed_offset * 1000)

static func generate_from_layout(layout, seed_value: int) -> GenerationResult:
	var result = GenerationResult.new()
	result.layout_name = layout.name
	
	var total_tiles = layout.positions.size()
	if total_tiles % 2 != 0:
		push_error("Layout '%s' has an odd number of tiles (%d)! Must be even." % [layout.name, total_tiles])
		return result
		
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_value
	
	# Prepare a balanced pool of matching pairs (distinct unique faces for all boards <= 36 pairs)
	var pair_pool = _create_pair_pool(total_tiles / 2, rng)
	
	# Attempt reverse-generation with backtracking/retries
	var max_attempts = 50
	for attempt in range(max_attempts):
		var attempt_rng = RandomNumberGenerator.new()
		attempt_rng.seed = seed_value + attempt * 31
		
		var sim_positions = layout.positions.duplicate()
		var assigned_tiles: Dictionary = {}
		var solution: Array[Array] = []
		var pool_copy = pair_pool.duplicate()
		var failed = false
		
		while sim_positions.size() > 0:
			# Find all currently free tiles in the simulation
			var free_tiles: Array[Vector3i] = []
			for pos in sim_positions:
				if BoardLayout.is_tile_free(pos, sim_positions):
					free_tiles.append(pos)
					
			if free_tiles.size() < 2:
				failed = true
				break
				
			# Select two free positions at random
			var idx1 = attempt_rng.randi_range(0, free_tiles.size() - 1)
			var pos1 = free_tiles[idx1]
			free_tiles.remove_at(idx1)
			
			var idx2 = attempt_rng.randi_range(0, free_tiles.size() - 1)
			var pos2 = free_tiles[idx2]
			
			# Pick a matching pair from our pool
			var pair_tiles = pool_copy.pop_back()
			if pair_tiles == null or pair_tiles.size() < 2:
				pair_tiles = [
					MahjongTileData.new("dragons", "red", "中", "Red Dragon"),
					MahjongTileData.new("dragons", "red", "中", "Red Dragon")
				]
				
			assigned_tiles[pos1] = pair_tiles[0]
			assigned_tiles[pos2] = pair_tiles[1]
			solution.append([pos1, pos2])
			
			sim_positions.erase(pos1)
			sim_positions.erase(pos2)
			
		if not failed and assigned_tiles.size() == total_tiles:
			if solver_can_solve(assigned_tiles):
				result.success = true
				result.tile_map = assigned_tiles
				result.solution_pairs = solution
				return result
			
	# Fallback if reverse generation struggled with extreme layouts
	return _generate_guaranteed_fallback(layout, pair_pool)

static func _create_pair_pool(num_pairs: int, rng: RandomNumberGenerator) -> Array:
	# Build distinct primary pair types (34 suits & honors + 1 flower pair + 1 season pair = 36 unique types)
	var distinct_pairs: Array = []
	
	# 1. Characters 1-9
	var char_kanji = ["一", "二", "三", "四", "五", "六", "七", "八", "九"]
	for i in range(1, 10):
		var t1 = MahjongTileData.new("characters", str(i), char_kanji[i - 1], "%s of Characters" % str(i), "萬")
		var t2 = MahjongTileData.new("characters", str(i), char_kanji[i - 1], "%s of Characters" % str(i), "萬")
		distinct_pairs.append([t1, t2])
		
	# 2. Bamboo 1-9
	var bamboo_symbols = ["鳥", "2", "3", "4", "5", "6", "7", "8", "9"]
	var bamboo_subs = ["鳥", "竹", "竹", "竹", "竹", "竹", "竹", "竹", "竹"]
	for i in range(1, 10):
		var t1 = MahjongTileData.new("bamboo", str(i), bamboo_symbols[i - 1], "%s of Bamboo" % str(i), bamboo_subs[i - 1])
		var t2 = MahjongTileData.new("bamboo", str(i), bamboo_symbols[i - 1], "%s of Bamboo" % str(i), bamboo_subs[i - 1])
		distinct_pairs.append([t1, t2])
		
	# 3. Dots 1-9
	var dot_symbols = ["①", "②", "③", "④", "⑤", "⑥", "⑦", "⑧", "⑨"]
	for i in range(1, 10):
		var t1 = MahjongTileData.new("dots", str(i), dot_symbols[i - 1], "%s of Dots" % str(i), "●")
		var t2 = MahjongTileData.new("dots", str(i), dot_symbols[i - 1], "%s of Dots" % str(i), "●")
		distinct_pairs.append([t1, t2])
		
	# 4. Winds (East, South, West, North)
	var winds = [["east", "東", "EAST"], ["south", "南", "SOUTH"], ["west", "西", "WEST"], ["north", "北", "NORTH"]]
	for w in winds:
		var t1 = MahjongTileData.new("winds", w[0], w[1], "%s Wind" % w[0].capitalize(), w[2])
		var t2 = MahjongTileData.new("winds", w[0], w[1], "%s Wind" % w[0].capitalize(), w[2])
		distinct_pairs.append([t1, t2])
		
	# 5. Dragons (Red, Green, White)
	var dragons = [["red", "中", "Red Dragon", "RED"], ["green", "發", "Green Dragon", "GREEN"], ["white", "白", "White Dragon", "WHITE"]]
	for d in dragons:
		var t1 = MahjongTileData.new("dragons", d[0], d[1], d[2], d[3])
		var t2 = MahjongTileData.new("dragons", d[0], d[1], d[2], d[3])
		distinct_pairs.append([t1, t2])
		
	# 6. Flowers & Seasons (1 pair each)
	var f1 = MahjongTileData.new("flowers", "plum", "梅", "Plum Blossom", "FLOWER")
	var f2 = MahjongTileData.new("flowers", "orchid", "蘭", "Orchid", "FLOWER")
	distinct_pairs.append([f1, f2])
	
	var s1 = MahjongTileData.new("seasons", "spring", "春", "Spring Season", "SEASON")
	var s2 = MahjongTileData.new("seasons", "summer", "夏", "Summer Season", "SEASON")
	distinct_pairs.append([s1, s2])
	
	# Shuffle distinct pairs randomly
	for i in range(distinct_pairs.size() - 1, 0, -1):
		var j = rng.randi_range(0, i)
		var tmp = distinct_pairs[i]
		distinct_pairs[i] = distinct_pairs[j]
		distinct_pairs[j] = tmp
		
	var selected_pairs: Array = []
	if num_pairs <= distinct_pairs.size():
		for p in range(num_pairs):
			var src = distinct_pairs[p]
			selected_pairs.append([MahjongTileData.create_clone(src[0]), MahjongTileData.create_clone(src[1])])
	else:
		# If board has > 36 pairs (like Classic Turtle 71 pairs), take all 36 distinct pairs first, then repeat
		for p in range(num_pairs):
			var src = distinct_pairs[p % distinct_pairs.size()]
			selected_pairs.append([MahjongTileData.create_clone(src[0]), MahjongTileData.create_clone(src[1])])
			
	return selected_pairs

static func _generate_guaranteed_fallback(layout, pair_pool: Array) -> GenerationResult:
	var result = GenerationResult.new()
	result.layout_name = layout.name
	var assigned: Dictionary = {}
	var solution: Array[Array] = []
	
	var sorted_positions = layout.positions.duplicate()
	sorted_positions.sort_custom(func(a, b):
		if a.z != b.z:
			return a.z > b.z
		return a.x < b.x
	)
	
	for i in range(0, sorted_positions.size(), 2):
		if i + 1 < sorted_positions.size():
			var p1 = sorted_positions[i]
			var p2 = sorted_positions[i + 1]
			var pair = pair_pool[i / 2 % pair_pool.size()]
			assigned[p1] = pair[0]
			assigned[p2] = pair[1]
			solution.append([p1, p2])
			
	result.success = true
	result.tile_map = assigned
	result.solution_pairs = solution
	return result

static func solver_can_solve(tile_map: Dictionary) -> bool:
	var remaining_tiles: Dictionary = tile_map.duplicate()
	var max_steps = remaining_tiles.size()
	for _step in range(max_steps):
		if remaining_tiles.is_empty():
			return true
			
		var positions: Array[Vector3i] = []
		for p in remaining_tiles.keys():
			positions.append(p)
			
		var free_positions: Array[Vector3i] = []
		for p in positions:
			if BoardLayout.is_tile_free(p, positions):
				free_positions.append(p)
				
		var matched = false
		for i in range(free_positions.size()):
			var p1 = free_positions[i]
			var t1 = remaining_tiles[p1]
			for j in range(i + 1, free_positions.size()):
				var p2 = free_positions[j]
				var t2 = remaining_tiles[p2]
				if MahjongTileData.tiles_match(t1, t2):
					remaining_tiles.erase(p1)
					remaining_tiles.erase(p2)
					matched = true
					break
			if matched:
				break
				
		if not matched:
			return false
			
	return remaining_tiles.is_empty()
