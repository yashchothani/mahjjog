class_name BoardLayout
extends RefCounted

## Manages 3D grid layouts for Mahjong Solitaire boards.
## Each tile occupies a 2x2 footprint in x and y, and 1 unit in z.

var name: String = ""
var positions: Array[Vector3i] = []
var tier: String = "Novice"

func _init(p_name: String = "", p_positions: Array[Vector3i] = [], p_tier: String = "Novice"):
	name = p_name
	positions = p_positions
	tier = p_tier

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

static func get_layout_by_id(id: int) -> BoardLayout:
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
			return create_master_layout(id)

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
	# 34 tiles - stepped jade pyramid
	var pos: Array[Vector3i] = []
	# Layer 0 (6x4 = 24 tiles base)
	for y in range(0, 8, 2):
		for x in range(0, 12, 2):
			pos.append(Vector3i(x, y, 0))
	# Layer 1 (4x2 = 8 tiles step)
	for y in range(2, 6, 2):
		for x in range(2, 10, 2):
			pos.append(Vector3i(x, y, 1))
	# Layer 2 (2 tiles peak)
	pos.append(Vector3i(4, 3, 2))
	pos.append(Vector3i(6, 3, 2))
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
	pos.append(Vector3i(-4, 7, 0))
	pos.append(Vector3i(30, 7, 0))
	if pos.size() % 2 != 0:
		pos.pop_back()
	return BoardLayout.new("Classic Turtle", pos, "Novice")

# ========================================================
# 80-LEVEL SYSTEM & HIGH-IQ GRANDMASTER BUILDERS
# ========================================================

const LEVEL_NAMES = [
	"", # 0
	# --- TIER 1: NOVICE ZEN (Levels 1 - 20) ---
	"Mini Turtle", "Jade Pyramid", "Champagne Diamond", "Golden Cross", "Garden Gateway",
	"Twin Peaks", "Jade Fortress", "Emerald Butterfly", "Misty Pagoda", "Classic Turtle",
	"Zen Courtyard", "Bamboo Grove", "Lotus Pond", "Stone Lantern", "River Bridge",
	"Crane Pavilion", "Pine Terrace", "Wind Chime", "Autumn Gate", "Spring Meadow",
	# --- TIER 2: ADEPT TEMPLE (Levels 21 - 40) ---
	"Bronze Bell", "Stepped Ziggurat", "Silver Fortress", "Phoenix Wing", "Dragon Gate",
	"Mountain Pass", "Triple Pagoda", "Golden Mandala", "Tiger Keep", "Cloud Spire",
	"Moon Gate", "Solar Altar", "Shadow Labyrinth", "Cedar Forest", "Jade Dragon",
	"Crystal Palace", "Mystic Hourglass", "Serene Sanctuary", "Thunder Bastion", "Emperor's Terrace",
	# --- TIER 3: MASTER SANCTUARY (Levels 41 - 60) ---
	"Great Wall Fortress", "Twin Monoliths", "Celestial Astrolabe", "Spiral of Wisdom", "Dragon's Spine",
	"Imperial Citadel", "Temple of Heavens", "Maze of Silence", "Iron Bastion", "Golden Phoenix",
	"Five Sacred Peaks", "Obsidian Castle", "Crescent Citadel", "Grand Pagoda", "Star of the Orient",
	"Dragon's Eye", "Labyrinth of the Mind", "Sunken Temple", "Lotus Throne", "Celestial Wheel",
	# --- TIER 4: HIGH-IQ GRANDMASTER (Levels 61 - 80) ---
	"The Mind Labyrinth", "Ziggurat of Babel", "Double Dragon Claws", "The Forbidden City", "Yin-Yang Master",
	"Monolith of Eternity", "Imperial Dragon Altar", "Crown of the Sage", "The Grand Fortress", "Dragon's Cavern",
	"The Infinite Knot", "High-IQ Mind Trap", "Tower of Babel 144", "Master of the Winds 144", "Emperor's Grand Court 144",
	"Dragon & Tiger Clash 144", "Celestial Palace 144", "The Ultimate Labyrinth 144", "Nirvana Ascension 144", "Supreme Grandmaster 144"
]

static func get_tier_for_level(level_id: int) -> String:
	if level_id <= 20: return "Novice"
	if level_id <= 40: return "Adept"
	if level_id <= 60: return "Master"
	return "Grandmaster"

static func get_level_name(level_id: int) -> String:
	if level_id >= 1 and level_id < LEVEL_NAMES.size():
		return LEVEL_NAMES[level_id]
	return "Garden Level %d" % level_id

static func create_master_layout(level_id: int) -> BoardLayout:
	var lvl_name = get_level_name(level_id)
	var tier = get_tier_for_level(level_id)
	
	# Grandmaster 144-tile apex challenges (Levels 73 to 80)
	if level_id >= 73:
		return _build_grandmaster_144(lvl_name, level_id - 73)
		
	var target_pairs = 20
	var max_z = 3
	if level_id <= 20:
		target_pairs = 20 + (level_id - 10) * 1
		max_z = 3
	elif level_id <= 40:
		target_pairs = 34 + (level_id - 20) * 1
		max_z = 4
	elif level_id <= 60:
		target_pairs = 48 + int((level_id - 40) * 0.7)
		max_z = 5
	else:
		target_pairs = 60 + int((level_id - 60) * 0.8)
		max_z = 5 if level_id <= 68 else 6
		
	var style_idx = level_id % 4
	match style_idx:
		0: return _build_pyramid(lvl_name, tier, target_pairs, max_z)
		1: return _build_pagoda(lvl_name, tier, target_pairs, max_z)
		2: return _build_diamond(lvl_name, tier, target_pairs, max_z)
		_: return _build_spires(lvl_name, tier, target_pairs, max_z)

static func _add_pos_pair(pos_array: Array[Vector3i], p1: Vector3i, p2: Vector3i) -> void:
	if p1 != p2 and not pos_array.has(p1) and not pos_array.has(p2):
		pos_array.append(p1)
		pos_array.append(p2)

static func _build_pyramid(p_name: String, p_tier: String, target_pairs: int, max_z: int, cx: int = 12, cy: int = 6) -> BoardLayout:
	var pos: Array[Vector3i] = []
	var base_rx = int(clamp(sqrt(target_pairs / 4.0), 2.0, 5.0))
	for z in range(max_z):
		var rx = max(1, base_rx - z)
		var ry = max(1, rx - 1)
		for dy in range(-ry, ry + 1):
			var cur_w = max(1, rx - abs(dy))
			for dx in range(1, cur_w + 1):
				if pos.size() < target_pairs * 2:
					_add_pos_pair(pos, Vector3i(cx - dx * 2, cy + dy * 2, z), Vector3i(cx + dx * 2, cy + dy * 2, z))
			if dy > 0 and pos.size() < target_pairs * 2:
				_add_pos_pair(pos, Vector3i(cx, cy - dy * 2, z), Vector3i(cx, cy + dy * 2, z))
	var wing = base_rx + 1
	while pos.size() < target_pairs * 2 and wing <= 12:
		_add_pos_pair(pos, Vector3i(cx - wing * 2, cy, 0), Vector3i(cx + wing * 2, cy, 0))
		wing += 1
	return BoardLayout.new(p_name, pos, p_tier)

static func _build_pagoda(p_name: String, p_tier: String, target_pairs: int, max_z: int, cx: int = 12, cy: int = 6) -> BoardLayout:
	var pos: Array[Vector3i] = []
	var base_w = int(clamp(sqrt(target_pairs / 4.5), 2.0, 5.0))
	for z in range(max_z):
		var is_eave = (z % 2 == 0)
		var ew = max(1, base_w - int(z / 2) + (1 if is_eave else 0))
		var eh = max(1, base_w - int(z / 2))
		for dy in range(-eh, eh + 1):
			for dx in range(1, ew + 1):
				if pos.size() < target_pairs * 2:
					_add_pos_pair(pos, Vector3i(cx - dx * 2, cy + dy * 2, z), Vector3i(cx + dx * 2, cy + dy * 2, z))
			if dy > 0 and pos.size() < target_pairs * 2:
				_add_pos_pair(pos, Vector3i(cx, cy - dy * 2, z), Vector3i(cx, cy + dy * 2, z))
	var wing = base_w + 1
	while pos.size() < target_pairs * 2 and wing <= 12:
		_add_pos_pair(pos, Vector3i(cx - wing * 2, cy, 0), Vector3i(cx + wing * 2, cy, 0))
		wing += 1
	return BoardLayout.new(p_name, pos, p_tier)

static func _build_diamond(p_name: String, p_tier: String, target_pairs: int, max_z: int, cx: int = 12, cy: int = 6) -> BoardLayout:
	var pos: Array[Vector3i] = []
	var base_r = int(clamp(sqrt(target_pairs / 3.5), 2.0, 5.0))
	for z in range(max_z):
		var r = max(1, base_r - z)
		for dy in range(-r, r + 1):
			var max_dx = max(1, r - abs(dy))
			for dx in range(1, max_dx + 1):
				if pos.size() < target_pairs * 2:
					_add_pos_pair(pos, Vector3i(cx - dx * 2, cy + dy * 2, z), Vector3i(cx + dx * 2, cy + dy * 2, z))
			if dy > 0 and pos.size() < target_pairs * 2:
				_add_pos_pair(pos, Vector3i(cx, cy - dy * 2, z), Vector3i(cx, cy + dy * 2, z))
	var wing = base_r + 1
	while pos.size() < target_pairs * 2 and wing <= 12:
		_add_pos_pair(pos, Vector3i(cx - wing * 2, cy, 0), Vector3i(cx + wing * 2, cy, 0))
		wing += 1
	return BoardLayout.new(p_name, pos, p_tier)

static func _build_spires(p_name: String, p_tier: String, target_pairs: int, max_z: int, cx: int = 12, cy: int = 6) -> BoardLayout:
	var pos: Array[Vector3i] = []
	var sep = 3
	var sw = max(1, int(clamp(sqrt(target_pairs / 10.0), 1.0, 3.0)))
	for dx in range(1, sep + sw + 2):
		if pos.size() < target_pairs * 2:
			_add_pos_pair(pos, Vector3i(cx + dx * 2, cy, 0), Vector3i(cx - dx * 2, cy, 0))
	for sx in [sep + sw]:
		for z in range(1, max_z):
			var rz = max(1, sw - z + 1)
			for dy in range(-rz, rz + 1):
				for dx in range(1, rz + 1):
					if pos.size() < target_pairs * 2:
						_add_pos_pair(pos, Vector3i(cx + sx * 2 + dx * 2, cy + dy * 2, z), Vector3i(cx - (sx * 2 + dx * 2), cy + dy * 2, z))
	var wing = sep + sw + 2
	while pos.size() < target_pairs * 2 and wing <= 12:
		_add_pos_pair(pos, Vector3i(cx - wing * 2, cy, 0), Vector3i(cx + wing * 2, cy, 0))
		wing += 1
	return BoardLayout.new(p_name, pos, p_tier)

static func _build_grandmaster_144(p_name: String, variant: int, cx: int = 12, cy: int = 7) -> BoardLayout:
	var pos: Array[Vector3i] = []
	# Layer 0 Base (84 tiles)
	for x in range(cx - 10, cx + 12, 2):
		for y in range(cy - 6, cy + 8, 2):
			if abs(x - cx) + abs(y - cy) <= 12:
				if not pos.has(Vector3i(x, y, 0)):
					pos.append(Vector3i(x, y, 0))
	# Layer 0 Outer Wings (4 tiles)
	_add_pos_pair(pos, Vector3i(cx - 14, cy, 0), Vector3i(cx + 14, cy, 0))
	_add_pos_pair(pos, Vector3i(cx - 12, cy, 0), Vector3i(cx + 12, cy, 0))
	
	# Layer 1 (36 tiles: 6x6 grid)
	for x in range(cx - 6, cx + 6, 2):
		for y in range(cy - 6, cy + 6, 2):
			if not pos.has(Vector3i(x, y, 1)):
				pos.append(Vector3i(x, y, 1))
			
	# Layer 2 (16 tiles: 4x4 grid)
	for x in range(cx - 4, cx + 4, 2):
		for y in range(cy - 4, cy + 4, 2):
			if not pos.has(Vector3i(x, y, 2)):
				pos.append(Vector3i(x, y, 2))
			
	# Layer 3 (4 tiles: 2x2 grid)
	for x in [cx - 2, cx]:
		for y in [cy - 2, cy]:
			if not pos.has(Vector3i(x, y, 3)):
				pos.append(Vector3i(x, y, 3))
			
	# Layer 4 Pinnacle Cap (2 tiles)
	_add_pos_pair(pos, Vector3i(cx - 1, cy - 1, 4), Vector3i(cx - 1, cy + 1, 4))
	
	# Layer 5 Monolith Spire for variant >= 1 (2 tiles)
	if variant >= 1:
		_add_pos_pair(pos, Vector3i(cx - 1, cy, 5), Vector3i(cx - 1, cy - 2, 5))
		
	if pos.size() % 2 != 0:
		pos.pop_back()
		
	return BoardLayout.new(p_name, pos, "Grandmaster")
