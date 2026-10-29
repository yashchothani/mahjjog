extends Control

## Controller for the Level Selection screen (Levels 1 to 80).
## Includes category tier filtering (Novice, Adept, Master, High-IQ Grandmaster) and rich button stats.

@onready var grid_container: GridContainer = $ScrollContainer/Center/VBox/GridContainer
@onready var back_btn: Button = $TopBar/HBox/BackBtn
@onready var title_label: Label = $TopBar/HBox/Title

@onready var tier_btn_all: Button = $ScrollContainer/Center/VBox/TierBar/TierBtnAll
@onready var tier_btn_novice: Button = $ScrollContainer/Center/VBox/TierBar/TierBtnNovice
@onready var tier_btn_adept: Button = $ScrollContainer/Center/VBox/TierBar/TierBtnAdept
@onready var tier_btn_master: Button = $ScrollContainer/Center/VBox/TierBar/TierBtnMaster
@onready var tier_btn_grandmaster: Button = $ScrollContainer/Center/VBox/TierBar/TierBtnGrandmaster

var current_tier_filter: String = "all" # "all", "novice", "adept", "master", "grandmaster"

func _get_autoload(autoload_name: String) -> Node:
	var tree = Engine.get_main_loop() as SceneTree
	if tree and tree.root and tree.root.has_node(autoload_name):
		return tree.root.get_node(autoload_name)
	return null

func _sm() -> Node:
	return _get_autoload("SaveManager")

func _gm() -> Node:
	return _get_autoload("GameManager")

func _am() -> Node:
	return _get_autoload("AudioManager")

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

func _ready() -> void:
	_setup_tier_buttons()
	_update_localized_headers()
	_style_tier_tabs()
	_populate_levels()
	
	var am = _am()
	if am and am.has_method("play_menu_music"):
		am.play_menu_music()
	
	var lm = _lm()
	if lm and lm.has_signal("language_changed"):
		if not lm.language_changed.is_connected(_on_language_changed_signal):
			lm.language_changed.connect(_on_language_changed_signal)

func _setup_tier_buttons() -> void:
	var b_all = tier_btn_all if tier_btn_all != null else get_node_or_null("ScrollContainer/Center/VBox/TierBar/TierBtnAll") as Button
	if b_all and not b_all.pressed.is_connected(_on_tier_all_pressed):
		b_all.pressed.connect(_on_tier_all_pressed)
		
	var b_novice = tier_btn_novice if tier_btn_novice != null else get_node_or_null("ScrollContainer/Center/VBox/TierBar/TierBtnNovice") as Button
	if b_novice and not b_novice.pressed.is_connected(_on_tier_novice_pressed):
		b_novice.pressed.connect(_on_tier_novice_pressed)
		
	var b_adept = tier_btn_adept if tier_btn_adept != null else get_node_or_null("ScrollContainer/Center/VBox/TierBar/TierBtnAdept") as Button
	if b_adept and not b_adept.pressed.is_connected(_on_tier_adept_pressed):
		b_adept.pressed.connect(_on_tier_adept_pressed)
		
	var b_master = tier_btn_master if tier_btn_master != null else get_node_or_null("ScrollContainer/Center/VBox/TierBar/TierBtnMaster") as Button
	if b_master and not b_master.pressed.is_connected(_on_tier_master_pressed):
		b_master.pressed.connect(_on_tier_master_pressed)
		
	var b_gm = tier_btn_grandmaster if tier_btn_grandmaster != null else get_node_or_null("ScrollContainer/Center/VBox/TierBar/TierBtnGrandmaster") as Button
	if b_gm and not b_gm.pressed.is_connected(_on_tier_grandmaster_pressed):
		b_gm.pressed.connect(_on_tier_grandmaster_pressed)

func _on_tier_all_pressed() -> void: _set_tier_filter("all")
func _on_tier_novice_pressed() -> void: _set_tier_filter("novice")
func _on_tier_adept_pressed() -> void: _set_tier_filter("adept")
func _on_tier_master_pressed() -> void: _set_tier_filter("master")
func _on_tier_grandmaster_pressed() -> void: _set_tier_filter("grandmaster")

func _set_tier_filter(filter_key: String) -> void:
	var am = _am()
	if am: am.play_sfx("button_click")
	current_tier_filter = filter_key
	_style_tier_tabs()
	_populate_levels()

func _style_tier_tabs() -> void:
	var tabs = {
		"all": tier_btn_all if tier_btn_all != null else get_node_or_null("ScrollContainer/Center/VBox/TierBar/TierBtnAll"),
		"novice": tier_btn_novice if tier_btn_novice != null else get_node_or_null("ScrollContainer/Center/VBox/TierBar/TierBtnNovice"),
		"adept": tier_btn_adept if tier_btn_adept != null else get_node_or_null("ScrollContainer/Center/VBox/TierBar/TierBtnAdept"),
		"master": tier_btn_master if tier_btn_master != null else get_node_or_null("ScrollContainer/Center/VBox/TierBar/TierBtnMaster"),
		"grandmaster": tier_btn_grandmaster if tier_btn_grandmaster != null else get_node_or_null("ScrollContainer/Center/VBox/TierBar/TierBtnGrandmaster")
	}
	
	for key in tabs.keys():
		var btn = tabs[key] as Button
		if btn == null: continue
		var is_active = (current_tier_filter == key)
		var sb = StyleBoxFlat.new()
		sb.corner_radius_top_left = 6
		sb.corner_radius_top_right = 6
		sb.corner_radius_bottom_right = 6
		sb.corner_radius_bottom_left = 6
		
		if is_active:
			sb.bg_color = Color(0.20, 0.40, 0.28, 0.95) if key != "grandmaster" else Color(0.35, 0.15, 0.45, 0.95)
			sb.border_width_left = 2
			sb.border_width_top = 2
			sb.border_width_right = 2
			sb.border_width_bottom = 2
			sb.border_color = Color(0.96, 0.85, 0.40, 1.0)
			btn.add_theme_color_override("font_color", Color(1.0, 0.95, 0.80))
		else:
			sb.bg_color = Color(0.06, 0.14, 0.10, 0.8)
			sb.border_width_left = 1
			sb.border_width_top = 1
			sb.border_width_right = 1
			sb.border_width_bottom = 1
			sb.border_color = Color(0.5, 0.5, 0.5, 0.3)
			btn.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
			
		btn.add_theme_stylebox_override("normal", sb)

func _update_localized_headers() -> void:
	var lm = _lm()
	var b_btn = back_btn if back_btn != null else get_node_or_null("TopBar/HBox/BackBtn") as Button
	var t_lbl = title_label if title_label != null else get_node_or_null("TopBar/HBox/Title") as Label
	if lm:
		if b_btn: b_btn.text = lm.get_text("BTN_BACK_MENU", "◀ Return to Main Menu")
		if t_lbl: t_lbl.text = lm.get_text("LEVEL_SELECT_TITLE", "Select Garden Level (1 - 80)")
		
		var b_all = tier_btn_all if tier_btn_all != null else get_node_or_null("ScrollContainer/Center/VBox/TierBar/TierBtnAll") as Button
		if b_all: b_all.text = lm.get_text("TIER_ALL", "All (1 - 80)")
		var b_novice = tier_btn_novice if tier_btn_novice != null else get_node_or_null("ScrollContainer/Center/VBox/TierBar/TierBtnNovice") as Button
		if b_novice: b_novice.text = lm.get_text("TIER_NOVICE", "🌿 Novice (1-20)")
		var b_adept = tier_btn_adept if tier_btn_adept != null else get_node_or_null("ScrollContainer/Center/VBox/TierBar/TierBtnAdept") as Button
		if b_adept: b_adept.text = lm.get_text("TIER_ADEPT", "🎋 Adept (21-40)")
		var b_master = tier_btn_master if tier_btn_master != null else get_node_or_null("ScrollContainer/Center/VBox/TierBar/TierBtnMaster") as Button
		if b_master: b_master.text = lm.get_text("TIER_MASTER", "🥋 Master (41-60)")
		var b_gm = tier_btn_grandmaster if tier_btn_grandmaster != null else get_node_or_null("ScrollContainer/Center/VBox/TierBar/TierBtnGrandmaster") as Button
		if b_gm: b_gm.text = lm.get_text("TIER_GRANDMASTER", "🧠 High IQ (61-80)")

func _on_language_changed_signal(_new_code: String) -> void:
	_update_localized_headers()
	_populate_levels()

func _populate_levels() -> void:
	var grid = grid_container if grid_container != null else get_node_or_null("ScrollContainer/Center/VBox/GridContainer") as GridContainer
	if grid == null:
		return
		
	for child in grid.get_children():
		grid.remove_child(child)
		child.queue_free()
		
	var sm = _sm()
	var lm = _lm()
	var max_unlocked = sm.progress.get("max_unlocked_level", 1) if sm else 1
	var completed_dict = sm.progress.get("completed_levels", {}) if sm else {}
	
	var start_lvl = 1
	var end_lvl = 80
	match current_tier_filter:
		"novice":
			start_lvl = 1
			end_lvl = 20
		"adept":
			start_lvl = 21
			end_lvl = 40
		"master":
			start_lvl = 41
			end_lvl = 60
		"grandmaster":
			start_lvl = 61
			end_lvl = 80
			
	for lvl in range(start_lvl, end_lvl + 1):
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(175, 100)
		
		var is_unlocked = lvl <= max_unlocked
		var layout = BoardLayout.get_layout_by_id(lvl)
		var record = completed_dict.get(str(lvl), {})
		var stars = record.get("stars", 0)
		var best_time = record.get("best_time", 0.0)
		
		var star_str = ""
		for s in range(3):
			star_str += "★" if s < stars else "☆"
			
		var time_str = ""
		if best_time > 0:
			var m = int(best_time) / 60
			var sec = int(best_time) % 60
			time_str = "%02d:%02d" % [m, sec]
			
		var lvl_prefix = lm.format_text("LEVEL_LABEL", [lvl]) if lm else "Level %d" % lvl
		var tier_badge = ""
		match layout.tier:
			"Novice": tier_badge = "🌿 Novice"
			"Adept": tier_badge = "🎋 Adept"
			"Master": tier_badge = "🥋 Master"
			"Grandmaster": tier_badge = "🧠 High IQ"
			
		if is_unlocked:
			btn.text = "%s • %s\n%s (%d tiles)\n%s %s" % [lvl_prefix, tier_badge, layout.name, layout.positions.size(), star_str, time_str]
			btn.pressed.connect(func(): _on_level_selected(lvl))
		else:
			btn.text = "%s • %s\n🔒 Locked" % [lvl_prefix, tier_badge]
			btn.disabled = true
			
		_style_level_button(btn, is_unlocked, stars > 0, layout.tier)
		grid.add_child(btn)

func _style_level_button(btn: Button, is_unlocked: bool, is_completed: bool, tier_name: String) -> void:
	var style = StyleBoxFlat.new()
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	
	if is_completed:
		if tier_name == "Grandmaster":
			style.bg_color = Color(0.25, 0.12, 0.35, 0.95)
			style.border_color = Color(0.96, 0.85, 0.40, 1.0)
		elif tier_name == "Master":
			style.bg_color = Color(0.22, 0.18, 0.10, 0.95)
			style.border_color = Color(0.92, 0.80, 0.35, 0.9)
		else:
			style.bg_color = Color(0.12, 0.32, 0.22, 0.95)
			style.border_color = Color(0.92, 0.82, 0.45, 0.9)
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
	elif is_unlocked:
		if tier_name == "Grandmaster":
			style.bg_color = Color(0.18, 0.08, 0.26, 0.9)
			style.border_color = Color(0.75, 0.45, 0.85, 0.7)
		elif tier_name == "Master":
			style.bg_color = Color(0.16, 0.12, 0.08, 0.9)
			style.border_color = Color(0.85, 0.65, 0.25, 0.6)
		else:
			style.bg_color = Color(0.08, 0.22, 0.15, 0.9)
			style.border_color = Color(0.83, 0.68, 0.28, 0.5)
		style.border_width_left = 1
		style.border_width_top = 1
		style.border_width_right = 1
		style.border_width_bottom = 1
	else:
		style.bg_color = Color(0.06, 0.10, 0.08, 0.7)
		style.border_width_left = 1
		style.border_width_top = 1
		style.border_width_right = 1
		style.border_width_bottom = 1
		style.border_color = Color(0.3, 0.3, 0.3, 0.4)
		
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_color_override("font_color", Color(0.95, 0.93, 0.88) if is_unlocked else Color(0.5, 0.5, 0.5))

func _on_level_selected(lvl: int) -> void:
	var am = _am()
	if am:
		am.play_sfx("button_click")
	var gm = _gm()
	if gm:
		gm.start_level(lvl)
	else:
		get_tree().change_scene_to_file("res://scenes/gameplay/gameplay.tscn")

func _on_back_pressed() -> void:
	var am = _am()
	if am:
		am.play_sfx("button_click")
	var gm = _gm()
	if gm:
		gm.return_to_main_menu()
	else:
		get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
