class_name BoardLayout
extends RefCounted

## Manages 3D grid layouts for Mahjong Solitaire boards.
## Each tile occupies a 2x2 footprint in x and y, and 1 unit in z.

var name: String = ""
var positions: Array[Vector3i] = []

func _init(p_name: String = "", p_positions: Array[Vector3i] = []):
	name = p_name
	positions = p_positions

static func is_blocked_above(pos: Vector3i, all_positions: Array[Vector3i]) -> bool:
	for other in all_positions:
		if other.z > pos.z:
			# Must overlap in 2D footprint (width 2, height 2)
			if abs(other.x - pos.x) < 2 and abs(other.y - pos.y) < 2:
				return true
	return false

static func is_blocked_left(pos: Vector3i, all_positions: Array[Vector3i]) -> bool:
	for other in all_positions:
		if other.z == pos.z:
			# Touching left edge: other.x is 2 units to the left, and overlapping in y
			if other.x == pos.x - 2 and abs(other.y - pos.y) < 2:
				return true
	return false

static func is_blocked_right(pos: Vector3i, all_positions: Array[Vector3i]) -> bool:
	for other in all_positions:
		if other.z == pos.z:
			# Touching right edge: other.x is 2 units to the right, and overlapping in y
			if other.x == pos.x + 2 and abs(other.y - pos.y) < 2:
				return true
	return false

static func is_tile_free(pos: Vector3i, all_positions: Array[Vector3i]) -> bool:
	if is_blocked_above(pos, all_positions):
		return false
	var left_blocked = is_blocked_left(pos, all_positions)
	var right_blocked = is_blocked_right(pos, all_positions)
	return (not left_blocked) or (not right_blocked)

# ========================================================
# LAYOUT DEFINITIONS
# ========================================================

static func get_layout_by_id(id: int):
	match id:
		1: return create_mini_turtle()
		2: return create_pyramid_small()
		3: return create_diamond()
		4: return create_cross()
		5: return create_garden_gateway()
		6: return create_twin_peaks()
		7: return create_fortress()
		8: return create_butterfly()
		9: return create_pagoda()
		10: return create_classic_turtle()
		_:
			return create_generated_layout(id)

static func create_mini_turtle():
	# 36 tiles - Fast, elegant tutorial and quick play layout
	var pos: Array[Vector3i] = []
	# Layer 0 (26 tiles)
	# Center 4x4 grid of 2x2 tiles
	for y in [2, 4, 6]:
		for x in [4, 6, 8, 10]:
			pos.append(Vector3i(x, y, 0)) # 12 tiles
	for y in [0, 8]:
		for x in [6, 8]:
			pos.append(Vector3i(x, y, 0)) # 4 tiles
	# Wing tiles on left and right
	pos.append(Vector3i(0, 4, 0))
	pos.append(Vector3i(2, 4, 0))
	pos.append(Vector3i(12, 4, 0))
	pos.append(Vector3i(14, 4, 0))
	# Flipper feet
	pos.append(Vector3i(2, 2, 0))
	pos.append(Vector3i(2, 6, 0))
	pos.append(Vector3i(12, 2, 0))
	pos.append(Vector3i(12, 6, 0))
	# Layer 1 (6 tiles)
	pos.append(Vector3i(6, 3, 1))
	pos.append(Vector3i(8, 3, 1))
	pos.append(Vector3i(6, 5, 1))
	pos.append(Vector3i(8, 5, 1))
	pos.append(Vector3i(4, 4, 1))
	pos.append(Vector3i(10, 4, 1))
	# Layer 2 (4 tiles)
	pos.append(Vector3i(6, 4, 2))
	pos.append(Vector3i(8, 4, 2))
	pos.append(Vector3i(7, 3, 2))
	pos.append(Vector3i(7, 5, 2))
	return BoardLayout.new("Mini Turtle", pos)

static func create_pyramid_small():
	# 30 tiles - stepped pyramid
	var pos: Array[Vector3i] = []
	# Layer 0 (4x4 = 16 tiles)
	for y in range(0, 8, 2):
		for x in range(0, 8, 2):
			pos.append(Vector3i(x, y, 0))
	# Layer 1 (3x3 = 9 tiles)
	for y in range(1, 7, 2):
		for x in range(1, 7, 2):
			pos.append(Vector3i(x, y, 1))
	# Layer 2 (2x2 = 4 tiles)
	for y in range(2, 6, 2):
		for x in range(2, 6, 2):
			pos.append(Vector3i(x, y, 2))
	# Layer 3 (1 tile top peak) -> 16+9+4+1 = 30 tiles
	pos.append(Vector3i(3, 3, 3))
	return BoardLayout.new("Jade Pyramid", pos)

static func create_diamond():
	# 32 tiles diamond
	var pos: Array[Vector3i] = []
	var rows = [
		[6],
		[4, 6, 8],
		[2, 4, 6, 8, 10],
		[0, 2, 4, 6, 8, 10, 12],
		[2, 4, 6, 8, 10],
		[4, 6, 8],
		[6]
	]
	var y = 0
	for row in rows:
		for x in row:
			pos.append(Vector3i(x, y, 0))
		y += 2
	# Layer 1
	pos.append(Vector3i(6, 4, 1))
	pos.append(Vector3i(4, 6, 1))
	pos.append(Vector3i(6, 6, 1))
	pos.append(Vector3i(8, 6, 1))
	pos.append(Vector3i(6, 8, 1))
	pos.append(Vector3i(6, 6, 2)) # Layer 2 center
	pos.append(Vector3i(6, 2, 1))
	return BoardLayout.new("Champagne Diamond", pos)

static func create_cross():
	# 24 tiles
	var pos: Array[Vector3i] = []
	for x in range(0, 16, 2):
		pos.append(Vector3i(x, 6, 0))
	for y in [0, 2, 4, 8, 10, 12]:
		pos.append(Vector3i(6, y, 0))
		pos.append(Vector3i(8, y, 0))
	pos.append(Vector3i(6, 5, 1))
	pos.append(Vector3i(8, 5, 1))
	pos.append(Vector3i(6, 7, 1))
	pos.append(Vector3i(8, 7, 1))
	return BoardLayout.new("Golden Cross", pos)

static func create_garden_gateway():
	# 36 tiles Torii gate structure
	var pos: Array[Vector3i] = []
	for y in range(0, 12, 2):
		pos.append(Vector3i(2, y, 0))
		pos.append(Vector3i(10, y, 0))
	for x in range(0, 16, 2):
		pos.append(Vector3i(x, 0, 1))
	for x in range(2, 14, 2):
		pos.append(Vector3i(x, 2, 1))
	pos.append(Vector3i(0, 10, 0))
	pos.append(Vector3i(4, 10, 0))
	pos.append(Vector3i(8, 10, 0))
	pos.append(Vector3i(12, 10, 0))
	pos.append(Vector3i(2, 0, 2))
	pos.append(Vector3i(4, 0, 2))
	pos.append(Vector3i(6, 0, 2))
	pos.append(Vector3i(8, 0, 2))
	pos.append(Vector3i(10, 0, 2))
	pos.append(Vector3i(12, 0, 2))
	return BoardLayout.new("Garden Gateway", pos)

static func create_twin_peaks():
	# 40 tiles
	var pos: Array[Vector3i] = []
	for peak_offset in [0, 8]:
		for y in range(0, 6, 2):
			for x in range(0, 6, 2):
				pos.append(Vector3i(x + peak_offset, y, 0))
		for y in range(1, 5, 2):
			for x in range(1, 5, 2):
				pos.append(Vector3i(x + peak_offset, y, 1))
		pos.append(Vector3i(2 + peak_offset, 2, 2))
	for x in range(4, 10, 2):
		pos.append(Vector3i(x, 6, 0))
		pos.append(Vector3i(x, 8, 0))
	return BoardLayout.new("Twin Peaks", pos)

static func create_fortress():
	# 40 tiles
	var pos: Array[Vector3i] = []
	for x in range(0, 14, 2):
		pos.append(Vector3i(x, 0, 0))
		pos.append(Vector3i(x, 10, 0))
	for y in range(2, 10, 2):
		pos.append(Vector3i(0, y, 0))
		pos.append(Vector3i(12, y, 0))
	pos.append(Vector3i(0, 0, 1))
	pos.append(Vector3i(2, 0, 1))
	pos.append(Vector3i(10, 0, 1))
	pos.append(Vector3i(12, 0, 1))
	pos.append(Vector3i(0, 10, 1))
	pos.append(Vector3i(2, 10, 1))
	pos.append(Vector3i(10, 10, 1))
	pos.append(Vector3i(12, 10, 1))
	pos.append(Vector3i(4, 4, 0))
	pos.append(Vector3i(6, 4, 0))
	pos.append(Vector3i(8, 4, 0))
	pos.append(Vector3i(4, 6, 0))
	pos.append(Vector3i(6, 6, 0))
	pos.append(Vector3i(8, 6, 0))
	pos.append(Vector3i(6, 4, 1))
	pos.append(Vector3i(6, 6, 1))
	return BoardLayout.new("Jade Fortress", pos)

static func create_butterfly():
	# 48 tiles
	var pos: Array[Vector3i] = []
	var wing_shapes = [
		[2, 4],
		[0, 2, 4, 6],
		[0, 2, 4, 6],
		[2, 4]
	]
	var y = 0
	for row in wing_shapes:
		for x in row:
			pos.append(Vector3i(x, y, 0))
			pos.append(Vector3i(18 - x, y, 0))
		y += 2
	for body_y in range(0, 8, 2):
		pos.append(Vector3i(8, body_y, 0))
		pos.append(Vector3i(10, body_y, 0))
	pos.append(Vector3i(2, 2, 1))
	pos.append(Vector3i(4, 2, 1))
	pos.append(Vector3i(2, 4, 1))
	pos.append(Vector3i(4, 4, 1))
	pos.append(Vector3i(14, 2, 1))
	pos.append(Vector3i(16, 2, 1))
	pos.append(Vector3i(14, 4, 1))
	pos.append(Vector3i(16, 4, 1))
	pos.append(Vector3i(6, 0, 1))
	pos.append(Vector3i(12, 0, 1))
	pos.append(Vector3i(6, 6, 1))
	pos.append(Vector3i(12, 6, 1))
	return BoardLayout.new("Emerald Butterfly", pos)

static func create_pagoda():
	# 50 tiles
	var pos: Array[Vector3i] = []
	for x in range(2, 12, 2):
		for y in [6, 8]:
			pos.append(Vector3i(x, y, 0))
	for x in range(0, 14, 2):
		pos.append(Vector3i(x, 6, 1))
	for x in range(3, 11, 2):
		for y in [4, 6]:
			pos.append(Vector3i(x, y, 1))
	for x in range(1, 13, 2):
		pos.append(Vector3i(x, 4, 2))
	for x in range(4, 10, 2):
		for y in [2, 4]:
			pos.append(Vector3i(x, y, 2))
	for x in range(3, 13, 2):
		pos.append(Vector3i(x, 2, 3))
	pos.append(Vector3i(6, 0, 3))
	pos.append(Vector3i(7, 0, 3))
	pos.append(Vector3i(6, 1, 4))
	pos.append(Vector3i(7, 1, 4))
	pos.append(Vector3i(0, 8, 0))
	pos.append(Vector3i(12, 8, 0))
	pos.append(Vector3i(4, 10, 0))
	pos.append(Vector3i(8, 10, 0))
	return BoardLayout.new("Misty Pagoda", pos)

static func create_classic_turtle():
	# The legendary 144-tile Turtle layout!
	var pos: Array[Vector3i] = []
	for x in range(4, 24, 2):
		pos.append(Vector3i(x, 0, 0))
	for x in range(6, 22, 2):
		pos.append(Vector3i(x, 2, 0))
	for x in range(4, 24, 2):
		pos.append(Vector3i(x, 4, 0))
	pos.append(Vector3i(-2, 7, 0))
	pos.append(Vector3i(0, 7, 0))
	for x in range(2, 26, 2):
		pos.append(Vector3i(x, 6, 0))
	pos.append(Vector3i(26, 7, 0))
	pos.append(Vector3i(28, 7, 0))
	for x in range(2, 26, 2):
		pos.append(Vector3i(x, 8, 0))
	for x in range(4, 24, 2):
		pos.append(Vector3i(x, 10, 0))
	for x in range(6, 22, 2):
		pos.append(Vector3i(x, 12, 0))
	for x in range(4, 24, 2):
		pos.append(Vector3i(x, 14, 0))
	# Layer 1 (36 tiles): 6x6 grid in center
	for y in range(4, 16, 2):
		for x in range(8, 20, 2):
			pos.append(Vector3i(x, y, 1))
	# Layer 2 (16 tiles): 4x4 grid in center
	for y in range(6, 14, 2):
		for x in range(10, 18, 2):
			pos.append(Vector3i(x, y, 2))
	# Layer 3 (4 tiles): 2x2 grid in center
	for y in [8, 10]:
		for x in [12, 14]:
			pos.append(Vector3i(x, y, 3))
	# Layer 4 (Top cap)
	pos.append(Vector3i(13, 9, 4))
	pos.append(Vector3i(13, 9, 0))
	return BoardLayout.new("Classic Turtle", pos)

static func create_generated_layout(level_id: int):
	var base_counts = [32, 36, 40, 44, 48, 52, 56, 60]
	var target_count = base_counts[(level_id * 3) % base_counts.size()]
	var pos: Array[Vector3i] = []
	var rng = RandomNumberGenerator.new()
	rng.seed = level_id * 7919
	
	var pairs_to_add = target_count / 2
	var added = 0
	while added < pairs_to_add:
		var x = rng.randi_range(0, 7) * 2
		var y = rng.randi_range(0, 6) * 2
		var z = 0
		if rng.randf() > 0.6:
			z = 1
		var pos_left = Vector3i(x, y, z)
		var pos_right = Vector3i(16 - x, y, z)
		if not pos.has(pos_left) and not pos.has(pos_right):
			pos.append(pos_left)
			pos.append(pos_right)
			added += 1
			
	return BoardLayout.new("Zen Garden %d" % level_id, pos)
