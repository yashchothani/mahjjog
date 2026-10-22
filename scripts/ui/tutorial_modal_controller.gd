class_name TutorialModalController
extends PanelContainer

## Controller for the comprehensive visual "How to Play & Tile Guide" modal.
## Displays interactive porcelain tile showcases for Characters, Bamboo, Dots,
## Winds, Dragons, Flowers, and Seasons, complete with localized names and matching rules.

signal closed

const MahjongTileData = preload("res://scripts/data/mahjong_tile_data.gd")
const TileView = preload("res://scripts/board/tile_view.gd")

# Tab navigation buttons
@onready var tab_rules_btn: Button = %TabRulesBtn
@onready var tab_char_btn: Button = %TabCharBtn
@onready var tab_bamboo_btn: Button = %TabBambooBtn
@onready var tab_dots_btn: Button = %TabDotsBtn
@onready var tab_winds_btn: Button = %TabWindsBtn
@onready var tab_dragons_btn: Button = %TabDragonsBtn
@onready var tab_special_btn: Button = %TabSpecialBtn

# Tab panels
@onready var content_scroll: ScrollContainer = %ContentScroll
@onready var panel_rules: Control = %PanelRules
@onready var panel_characters: Control = %PanelCharacters
@onready var panel_bamboo: Control = %PanelBamboo
@onready var panel_dots: Control = %PanelDots
@onready var panel_winds: Control = %PanelWinds
@onready var panel_dragons: Control = %PanelDragons
@onready var panel_special: Control = %PanelSpecial

# Header & Footer
@onready var title_label: Label = %TitleLabel
@onready var close_btn_top: Button = %CloseBtnTop
@onready var close_btn_bottom: Button = %CloseBtnBottom

# Card Containers
@onready var char_grid: Container = %CharGrid
@onready var bamboo_grid: Container = %BambooGrid
@onready var dots_grid: Container = %DotsGrid
@onready var winds_grid: Container = %WindsGrid
@onready var dragons_grid: Container = %DragonsGrid
@onready var flowers_grid: Container = %FlowersGrid
@onready var seasons_grid: Container = %SeasonsGrid

# Info text labels for dynamic localization
@onready var rules_free_title: Label = %RulesFreeTitle
@onready var rules_free_desc: RichTextLabel = %RulesFreeDesc
@onready var rules_match_title: Label = %RulesMatchTitle
@onready var rules_match_desc: RichTextLabel = %RulesMatchDesc
@onready var rules_tools_title: Label = %RulesToolsTitle
@onready var rules_tools_desc: RichTextLabel = %RulesToolsDesc
@onready var rules_goal_title: Label = %RulesGoalTitle
@onready var rules_goal_desc: RichTextLabel = %RulesGoalDesc

@onready var char_desc: RichTextLabel = %CharDesc
@onready var bamboo_desc: RichTextLabel = %BambooDesc
@onready var dots_desc: RichTextLabel = %DotsDesc
@onready var winds_desc: RichTextLabel = %WindsDesc
@onready var dragons_desc: RichTextLabel = %DragonsDesc
@onready var special_desc: RichTextLabel = %SpecialDesc

var current_tab_index: int = 0
var _tiles_initialized: bool = false
var _tile_label_refs: Dictionary = {} # tile_key -> Label

func _get_autoload(autoload_name: String) -> Node:
	var tree = Engine.get_main_loop() as SceneTree
	if tree and tree.root and tree.root.has_node(autoload_name):
		return tree.root.get_node(autoload_name)
	return null

func _lm() -> Node:
	var node = _get_autoload("LocalizationManager")
	if node:
		return node
	var tree = Engine.get_main_loop() as SceneTree
	if tree and tree.root:
		if tree.root.has_node("FallbackLocalizationManager"):
			return tree.root.get_node("FallbackLocalizationManager")
		var sc = load("res://scripts/core/localization_manager.gd")
		if sc:
			var inst = sc.new()
			inst.name = "FallbackLocalizationManager"
			tree.root.add_child(inst)
			return inst
	return null

func _am() -> Node:
	return _get_autoload("AudioManager")

func _ready() -> void:
	_connect_tab_buttons()
	_build_all_tile_cards()
	_update_localized_content()
	select_tab(0)
	
	var lm = _lm()
	if lm and lm.has_signal("language_changed"):
		if not lm.language_changed.is_connected(_on_language_changed):
			lm.language_changed.connect(_on_language_changed)

func _connect_tab_buttons() -> void:
	var tab_buttons = [tab_rules_btn, tab_char_btn, tab_bamboo_btn, tab_dots_btn, tab_winds_btn, tab_dragons_btn, tab_special_btn]
	for i in range(tab_buttons.size()):
		var btn = tab_buttons[i]
		if btn:
			for conn in btn.pressed.get_connections():
				btn.pressed.disconnect(conn.callable)
			btn.pressed.connect(func(): select_tab(i))
	
	if close_btn_top and not close_btn_top.pressed.is_connected(_on_close_pressed):
		close_btn_top.pressed.connect(_on_close_pressed)
	if close_btn_bottom and not close_btn_bottom.pressed.is_connected(_on_close_pressed):
		close_btn_bottom.pressed.connect(_on_close_pressed)

func select_tab(index: int) -> void:
	current_tab_index = index
	var am = _am()
	if am and is_inside_tree() and visible:
		am.play_sfx("button_click")
		
	var panels = [
		panel_rules, panel_characters, panel_bamboo,
		panel_dots, panel_winds, panel_dragons, panel_special
	]
	var buttons = [
		tab_rules_btn, tab_char_btn, tab_bamboo_btn,
		tab_dots_btn, tab_winds_btn, tab_dragons_btn, tab_special_btn
	]
	
	for i in range(panels.size()):
		if panels[i]:
			panels[i].visible = (i == index)
		if buttons[i]:
			_style_tab_button(buttons[i], i == index)
			
	if content_scroll:
		content_scroll.scroll_vertical = 0

func _style_tab_button(btn: Button, is_active: bool) -> void:
	var style = StyleBoxFlat.new()
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	
	if is_active:
		style.bg_color = Color(0.18, 0.44, 0.30, 0.95)
		style.border_color = Color(0.96, 0.86, 0.52, 1.0)
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
		btn.add_theme_color_override("font_color", Color(0.98, 0.95, 0.88, 1))
	else:
		style.bg_color = Color(0.08, 0.18, 0.13, 0.8)
		style.border_color = Color(0.83, 0.68, 0.28, 0.3)
		style.border_width_left = 1
		style.border_width_top = 1
		style.border_width_right = 1
		style.border_width_bottom = 1
		btn.add_theme_color_override("font_color", Color(0.78, 0.76, 0.70, 0.9))
		
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style)
	btn.add_theme_stylebox_override("pressed", style)
	btn.add_theme_stylebox_override("focus", style)

func _build_all_tile_cards() -> void:
	if _tiles_initialized:
		return
	_tiles_initialized = true
	_tile_label_refs.clear()
	
	# 1. Characters: 1C to 9C
	var char_kanji = ["一", "二", "三", "四", "五", "六", "七", "八", "九"]
	if char_grid:
		for i in range(1, 10):
			var tile_data = MahjongTileData.new("characters", str(i), char_kanji[i - 1], "%s of Characters" % str(i), "萬")
			var card = _create_tile_card("TILE_%dC" % i, tile_data, "%dC • 萬" % i)
			char_grid.add_child(card)
			
	# 2. Bamboo: 1B (Bird) to 9B
	var bamboo_symbols = ["鳥", "2", "3", "4", "5", "6", "7", "8", "9"]
	var bamboo_subs = ["鳥", "竹", "竹", "竹", "竹", "竹", "竹", "竹", "竹"]
	if bamboo_grid:
		for i in range(1, 10):
			var tile_data = MahjongTileData.new("bamboo", str(i), bamboo_symbols[i - 1], "%s of Bamboo" % str(i), bamboo_subs[i - 1])
			var sub_badge = "1B • 鳥 (Bird)" if i == 1 else "%dB • 竹" % i
			var card = _create_tile_card("TILE_%dB" % i, tile_data, sub_badge)
			bamboo_grid.add_child(card)
			
	# 3. Dots: 1D to 9D
	var dot_symbols = ["①", "②", "③", "④", "⑤", "⑥", "⑦", "⑧", "⑨"]
	if dots_grid:
		for i in range(1, 10):
			var tile_data = MahjongTileData.new("dots", str(i), dot_symbols[i - 1], "%s of Dots" % str(i), "●")
			var card = _create_tile_card("TILE_%dD" % i, tile_data, "%dD • ●" % i)
			dots_grid.add_child(card)
			
	# 4. Winds: East, South, West, North
	var winds = [
		["east", "東", "EAST", "TILE_EAST", "E • 東"],
		["south", "南", "SOUTH", "TILE_SOUTH", "S • 南"],
		["west", "西", "WEST", "TILE_WEST", "W • 西"],
		["north", "北", "NORTH", "TILE_NORTH", "N • 北"]
	]
	if winds_grid:
		for w in winds:
			var tile_data = MahjongTileData.new("winds", w[0], w[1], "%s Wind" % w[0].capitalize(), w[2])
			var card = _create_tile_card(w[3], tile_data, w[4])
			winds_grid.add_child(card)
			
	# 5. Dragons: Red, Green, White
	var dragons = [
		["red", "中", "Red Dragon", "RED", "TILE_RED", "R • 中 (Red)"],
		["green", "發", "Green Dragon", "GREEN", "TILE_GREEN", "G • 發 (Green)"],
		["white", "白", "White Dragon", "WHITE", "TILE_WHITE", "W • 白 (White)"]
	]
	if dragons_grid:
		for d in dragons:
			var tile_data = MahjongTileData.new("dragons", d[0], d[1], d[2], d[3])
			var card = _create_tile_card(d[4], tile_data, d[5])
			dragons_grid.add_child(card)
			
	# 6. Flowers: Plum, Orchid, Bamboo, Chrysanthemum
	var flowers = [
		["plum", "梅", "Plum Blossom", "TILE_PLUM", "FL • 梅"],
		["orchid", "蘭", "Orchid", "TILE_ORCHID", "FL • 蘭"],
		["bamboo", "竹", "Bamboo Blossom", "TILE_BAMBOO_FLOWER", "FL • 竹"],
		["chrysanthemum", "菊", "Chrysanthemum", "TILE_CHRYSANTHEMUM", "FL • 菊"]
	]
	if flowers_grid:
		for f in flowers:
			var tile_data = MahjongTileData.new("flowers", f[0], f[1], f[2], "FLOWER")
			var card = _create_tile_card(f[3], tile_data, f[4])
			flowers_grid.add_child(card)
			
	# 7. Seasons: Spring, Summer, Autumn, Winter
	var seasons = [
		["spring", "春", "Spring Season", "TILE_SPRING", "SN • 春"],
		["summer", "夏", "Summer Season", "TILE_SUMMER", "SN • 夏"],
		["autumn", "秋", "Autumn Season", "TILE_AUTUMN", "SN • 秋"],
		["winter", "冬", "Winter Season", "TILE_WINTER", "SN • 冬"]
	]
	if seasons_grid:
		for s in seasons:
			var tile_data = MahjongTileData.new("seasons", s[0], s[1], s[2], "SEASON")
			var card = _create_tile_card(s[3], tile_data, s[4])
			seasons_grid.add_child(card)

func _create_tile_card(translation_key: String, tile_data: MahjongTileData, badge_text: String) -> PanelContainer:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(86, 126)
	
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color(0.06, 0.15, 0.11, 0.85)
	card_style.border_color = Color(0.83, 0.68, 0.28, 0.45)
	card_style.border_width_left = 1
	card_style.border_width_top = 1
	card_style.border_width_right = 1
	card_style.border_width_bottom = 1
	card_style.corner_radius_top_left = 8
	card_style.corner_radius_top_right = 8
	card_style.corner_radius_bottom_left = 8
	card_style.corner_radius_bottom_right = 8
	card_style.content_margin_left = 6.0
	card_style.content_margin_top = 8.0
	card_style.content_margin_right = 6.0
	card_style.content_margin_bottom = 8.0
	card.add_theme_stylebox_override("panel", card_style)
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 5)
	card.add_child(vbox)
	
	# Visual porcelain tile
	var tile_center = CenterContainer.new()
	var tv = TileView.new(Vector3i.ZERO, tile_data)
	tv.custom_minimum_size = Vector2(58, 76)
	
	# Interactive tap bounce
	if tv.click_button:
		tv.click_button.pressed.connect(func():
			var am = _am()
			if am: am.play_sfx("tile_click")
			var tw = tv.create_tween()
			tw.tween_property(tv, "scale", Vector2(1.1, 1.1), 0.1)
			tw.tween_property(tv, "scale", Vector2(1.0, 1.0), 0.1)
		)
		
	tile_center.add_child(tv)
	vbox.add_child(tile_center)
	
	# Tile Localized Name
	var name_label = Label.new()
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.add_theme_font_size_override("font_size", 11)
	name_label.add_theme_color_override("font_color", Color(0.96, 0.92, 0.82, 1))
	name_label.text = _get_tr(translation_key, tile_data.display_name)
	vbox.add_child(name_label)
	_tile_label_refs[translation_key] = name_label
	
	# Badge / Notation subtext
	var badge_label = Label.new()
	badge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge_label.add_theme_font_size_override("font_size", 9)
	badge_label.add_theme_color_override("font_color", Color(0.85, 0.72, 0.40, 0.85))
	badge_label.text = badge_text
	vbox.add_child(badge_label)
	
	return card

func _get_tr(key: String, fallback: String = "") -> String:
	var lm = _lm()
	if lm:
		return lm.get_text(key, fallback)
	return fallback if fallback != "" else key

func _update_localized_content() -> void:
	if title_label: title_label.text = _get_tr("GUIDE_TITLE", "How to Play & Tile Guide")
	if close_btn_bottom: close_btn_bottom.text = _get_tr("BTN_CLOSE", "Close")
	
	# Tabs
	if tab_rules_btn: tab_rules_btn.text = _get_tr("TAB_RULES", "📜 Game Rules")
	if tab_char_btn: tab_char_btn.text = _get_tr("TAB_CHARACTERS", "一 Characters")
	if tab_bamboo_btn: tab_bamboo_btn.text = _get_tr("TAB_BAMBOO", "竹 Bamboo")
	if tab_dots_btn: tab_dots_btn.text = _get_tr("TAB_DOTS", "● Dots")
	if tab_winds_btn: tab_winds_btn.text = _get_tr("TAB_WINDS", "🀀 Winds")
	if tab_dragons_btn: tab_dragons_btn.text = _get_tr("TAB_DRAGONS", "🀄 Dragons")
	if tab_special_btn: tab_special_btn.text = _get_tr("TAB_FLOWERS_SEASONS", "🌸 Flowers & Seasons")
	
	# Rules Tab Descriptions
	if rules_free_title: rules_free_title.text = _get_tr("RULES_FREE_TITLE")
	if rules_free_desc: rules_free_desc.text = _get_tr("RULES_FREE_DESC")
	if rules_match_title: rules_match_title.text = _get_tr("RULES_MATCH_TITLE")
	if rules_match_desc: rules_match_desc.text = _get_tr("RULES_MATCH_DESC")
	if rules_tools_title: rules_tools_title.text = _get_tr("RULES_TOOLS_TITLE")
	if rules_tools_desc: rules_tools_desc.text = _get_tr("RULES_TOOLS_DESC")
	if rules_goal_title: rules_goal_title.text = _get_tr("RULES_GOAL_TITLE")
	if rules_goal_desc: rules_goal_desc.text = _get_tr("RULES_GOAL_DESC")
	
	# Suit Descriptions
	if char_desc: char_desc.text = _get_tr("SUIT_CHARACTERS_DESC")
	if bamboo_desc: bamboo_desc.text = _get_tr("SUIT_BAMBOO_DESC")
	if dots_desc: dots_desc.text = _get_tr("SUIT_DOTS_DESC")
	if winds_desc: winds_desc.text = _get_tr("HONOR_WINDS_DESC")
	if dragons_desc: dragons_desc.text = _get_tr("HONOR_DRAGONS_DESC")
	if special_desc: special_desc.text = _get_tr("SPECIAL_FLOWERS_SEASONS_DESC")
	
	# Tile names in cards
	for key in _tile_label_refs.keys():
		var lbl = _tile_label_refs[key] as Label
		if lbl:
			lbl.text = _get_tr(key, lbl.text)

func _on_language_changed(_new_code: String) -> void:
	_update_localized_content()

func _on_close_pressed() -> void:
	var am = _am()
	if am:
		am.play_sfx("button_click")
	hide()
	closed.emit()
