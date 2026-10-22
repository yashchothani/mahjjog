extends Control

## Controller for the Level Selection screen (Levels 1 to 30).

@onready var grid_container: GridContainer = $ScrollContainer/Center/VBox/GridContainer

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

func _ready() -> void:
	_populate_levels()

func _populate_levels() -> void:
	var grid = grid_container if grid_container != null else get_node_or_null("ScrollContainer/Center/VBox/GridContainer") as GridContainer
	if grid == null:
		return
		
	for child in grid.get_children():
		child.queue_free()
		
	var sm = _sm()
	var max_unlocked = sm.progress.get("max_unlocked_level", 1) if sm else 1
	var completed_dict = sm.progress.get("completed_levels", {}) if sm else {}
	
	for lvl in range(1, 31):
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(170, 95)
		
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
			
		if is_unlocked:
			btn.text = "Level %d\n%s\n%s %s" % [lvl, layout.name, star_str, time_str]
			btn.pressed.connect(func(): _on_level_selected(lvl))
		else:
			btn.text = "Level %d\n🔒 Locked" % lvl
			btn.disabled = true
			
		_style_level_button(btn, is_unlocked, stars > 0)
		grid.add_child(btn)

func _style_level_button(btn: Button, is_unlocked: bool, is_completed: bool) -> void:
	var style = StyleBoxFlat.new()
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	
	if is_completed:
		style.bg_color = Color(0.12, 0.32, 0.22, 0.95)
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
		style.border_color = Color(0.92, 0.82, 0.45, 0.9)
	elif is_unlocked:
		style.bg_color = Color(0.08, 0.22, 0.15, 0.9)
		style.border_width_left = 1
		style.border_width_top = 1
		style.border_width_right = 1
		style.border_width_bottom = 1
		style.border_color = Color(0.83, 0.68, 0.28, 0.5)
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
