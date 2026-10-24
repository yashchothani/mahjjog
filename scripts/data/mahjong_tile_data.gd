class_name MahjongTileData
extends RefCounted

## Represents the logical identity, symbols, and rules of a Mahjong tile.

enum Suit {
	BAMBOO,
	DOTS,
	CHARACTERS,
	WINDS,
	DRAGONS,
	FLOWERS,
	SEASONS
}

var suit: String = ""
var value: String = ""
var display_name: String = ""
var symbol: String = ""
var secondary_text: String = ""
var primary_color: Color = Color(0.1, 0.45, 0.25)
var secondary_color: Color = Color(0.8, 0.15, 0.15)

func _init(p_suit: String = "", p_value: String = "", p_symbol: String = "", p_name: String = "", p_sub: String = ""):
	suit = p_suit
	value = p_value
	symbol = p_symbol
	display_name = p_name if p_name != "" else "%s %s" % [p_suit.capitalize(), p_value]
	secondary_text = p_sub
	_setup_styling()

func _setup_styling() -> void:
	match suit:
		"characters":
			primary_color = Color(0.80, 0.16, 0.16) # Vermilion red
			secondary_color = Color(0.12, 0.15, 0.18) # Dark stone ink
			if secondary_text == "":
				secondary_text = "萬"
		"bamboo":
			primary_color = Color(0.08, 0.50, 0.28) # Imperial jade green
			secondary_color = Color(0.78, 0.16, 0.16)
			if secondary_text == "":
				secondary_text = "竹" if value != "1" else "鳥"
		"dots":
			primary_color = Color(0.14, 0.42, 0.70) # Cobalt navy blue
			secondary_color = Color(0.80, 0.16, 0.16) # Ruby red dot center
			if secondary_text == "":
				secondary_text = "●"
		"winds":
			primary_color = Color(0.14, 0.18, 0.22) # Calligraphy ink
			secondary_color = Color(0.75, 0.60, 0.22) # Gold touch
			# Winds display centered calligraphy symbol without bottom name text
		"dragons":
			match value:
				"red":
					primary_color = Color(0.82, 0.14, 0.14) # Vermilion
					secondary_color = Color(0.75, 0.60, 0.22)
				"green":
					primary_color = Color(0.07, 0.54, 0.26) # Deep Jade
					secondary_color = Color(0.75, 0.60, 0.22)
				"white":
					primary_color = Color(0.16, 0.44, 0.72) # Cobalt Frame
					secondary_color = Color(0.75, 0.60, 0.22)
		"flowers":
			primary_color = Color(0.70, 0.25, 0.58) # Plum blossom purple
			secondary_color = Color(0.85, 0.68, 0.25)
		"seasons":
			primary_color = Color(0.82, 0.48, 0.14) # Amber gold
			secondary_color = Color(0.12, 0.45, 0.28)

static func tiles_match(a, b) -> bool:
	if a == null or b == null:
		return false
	# Flowers match any other flower
	if a.suit == "flowers" and b.suit == "flowers":
		return true
	# Seasons match any other season
	if a.suit == "seasons" and b.suit == "seasons":
		return true
	# Regular tiles match exact suit and value
	return a.suit == b.suit and a.value == b.value

static func get_full_144_set() -> Array:
	var tiles: Array = []
	
	# 1. Characters (Wan) 1-9 x 4 copies = 36 tiles
	var char_kanji = ["一", "二", "三", "四", "五", "六", "七", "八", "九"]
	for i in range(1, 10):
		for _copy in range(4):
			tiles.append(MahjongTileData.new("characters", str(i), char_kanji[i - 1], "%s of Characters" % str(i), "萬"))
			
	# 2. Bamboo (Tiao) 1-9 x 4 copies = 36 tiles
	# 1 Bamboo is traditionally the Sparrow / Bird (鳥)
	var bamboo_symbols = ["鳥", "2", "3", "4", "5", "6", "7", "8", "9"]
	var bamboo_subs = ["竹", "竹", "竹", "竹", "竹", "竹", "竹", "竹", "竹"]
	for i in range(1, 10):
		for _copy in range(4):
			tiles.append(MahjongTileData.new("bamboo", str(i), bamboo_symbols[i - 1], "%s of Bamboo" % str(i), bamboo_subs[i - 1]))
			
	# 3. Dots (Tong) 1-9 x 4 copies = 36 tiles
	var dot_symbols = ["①", "②", "③", "④", "⑤", "⑥", "⑦", "⑧", "⑨"]
	for i in range(1, 10):
		for _copy in range(4):
			tiles.append(MahjongTileData.new("dots", str(i), dot_symbols[i - 1], "%s of Dots" % str(i), "●"))
			
	# 4. Winds: East, South, West, North x 4 copies = 16 tiles
	var winds = [["east", "東"], ["south", "南"], ["west", "西"], ["north", "北"]]
	for w in winds:
		for _copy in range(4):
			tiles.append(MahjongTileData.new("winds", w[0], w[1], "%s Wind" % w[0].capitalize(), ""))
			
	# 5. Dragons: Red (中), Green (發), White (白) x 4 copies = 12 tiles
	var dragons = [
		["red", "中", "Red Dragon"],
		["green", "發", "Green Dragon"],
		["white", "白", "White Dragon"]
	]
	for d in dragons:
		for _copy in range(4):
			tiles.append(MahjongTileData.new("dragons", d[0], d[1], d[2], ""))
			
	# 6. Flowers: Plum (梅), Orchid (蘭), Bamboo (竹), Chrysanthemum (菊) = 4 tiles
	var flowers = [
		["plum", "梅", "Plum Blossom"],
		["orchid", "蘭", "Orchid"],
		["bamboo", "竹", "Bamboo Blossom"],
		["chrysanthemum", "菊", "Chrysanthemum"]
	]
	for f in flowers:
		tiles.append(MahjongTileData.new("flowers", f[0], f[1], f[2], ""))
		
	# 7. Seasons: Spring (春), Summer (夏), Autumn (秋), Winter (冬) = 4 tiles
	var seasons = [
		["spring", "春", "Spring Season"],
		["summer", "夏", "Summer Season"],
		["autumn", "秋", "Autumn Season"],
		["winter", "冬", "Winter Season"]
	]
	for s in seasons:
		tiles.append(MahjongTileData.new("seasons", s[0], s[1], s[2], ""))
		
	return tiles

static func create_clone(other):
	return MahjongTileData.new(other.suit, other.value, other.symbol, other.display_name, other.secondary_text)
