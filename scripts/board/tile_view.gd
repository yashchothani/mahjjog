class_name TileView
extends Control

## Visual component representing an interactive Mahjong tile.

signal tile_clicked(tile_view: TileView)

const MahjongTileData = preload("res://scripts/data/mahjong_tile_data.gd")

const TILE_WIDTH: float = 56.0
const TILE_HEIGHT: float = 74.0
const BEVEL_DEPTH: float = 6.0

var grid_pos: Vector3i = Vector3i.ZERO
var tile_data: MahjongTileData
var is_free: bool = true
var is_selected: bool = false
var is_hinted: bool = false

var base_scale: float = 1.0

# Internal nodes
var base_panel: Panel
var face_panel: Panel
var symbol_label: Label
var sub_label: Label
var corner_label: Label
var highlight_border: ReferenceRect
var click_button: Button

func _init(p_grid_pos: Vector3i = Vector3i.ZERO, p_data: MahjongTileData = null):
	grid_pos = p_grid_pos
	tile_data = p_data
	custom_minimum_size = Vector2(TILE_WIDTH + BEVEL_DEPTH, TILE_HEIGHT + BEVEL_DEPTH)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_visuals()
	update_state()

func _ready() -> void:
	update_state()

func set_tile_data(p_pos: Vector3i, p_data: MahjongTileData) -> void:
	grid_pos = p_pos
	tile_data = p_data
	if is_inside_tree():
		_build_visuals()
		update_state()

func set_base_scale(new_scale: float) -> void:
	base_scale = new_scale
	update_state()

func _build_visuals() -> void:
	for child in get_children():
		child.queue_free()
		
	# 1. 3D Depth Base Layer (Dark Jade shadow)
	var base_style = StyleBoxFlat.new()
	base_style.bg_color = Color(0.10, 0.20, 0.15)
	base_style.corner_radius_top_left = 6
	base_style.corner_radius_top_right = 6
	base_style.corner_radius_bottom_left = 6
	base_style.corner_radius_bottom_right = 6
	base_style.shadow_color = Color(0, 0, 0, 0.38)
	base_style.shadow_size = 4
	base_style.shadow_offset = Vector2(2, 4)
	
	base_panel = Panel.new()
	base_panel.position = Vector2(BEVEL_DEPTH * 0.5, BEVEL_DEPTH)
	base_panel.size = Vector2(TILE_WIDTH, TILE_HEIGHT)
	base_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	base_panel.add_theme_stylebox_override("panel", base_style)
	add_child(base_panel)
	
	# 2. Porcelain Face (Warm Ivory)
	var face_style = StyleBoxFlat.new()
	face_style.bg_color = Color(0.98, 0.96, 0.92)
	face_style.border_width_left = 1
	face_style.border_width_top = 1
	face_style.border_width_right = 2
	face_style.border_width_bottom = 2
	face_style.border_color = Color(0.85, 0.78, 0.65)
	face_style.corner_radius_top_left = 5
	face_style.corner_radius_top_right = 5
	face_style.corner_radius_bottom_left = 5
	face_style.corner_radius_bottom_right = 5
	
	face_panel = Panel.new()
	face_panel.position = Vector2.ZERO
	face_panel.size = Vector2(TILE_WIDTH, TILE_HEIGHT)
	face_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	face_panel.add_theme_stylebox_override("panel", face_style)
	add_child(face_panel)
	
	# 3. Inner Gold Inset Hairline Frame
	var inner_box = ReferenceRect.new()
	inner_box.position = Vector2(3, 3)
	inner_box.size = Vector2(TILE_WIDTH - 6, TILE_HEIGHT - 6)
	inner_box.border_color = Color(0.83, 0.68, 0.28, 0.35)
	inner_box.border_width = 1.0
	inner_box.editor_only = false
	inner_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	face_panel.add_child(inner_box)
	
	# 4. Corner helper badge (e.g. "1B", "9C", "E")
	corner_label = Label.new()
	corner_label.position = Vector2(4, 3)
	corner_label.size = Vector2(20, 14)
	corner_label.text = _get_corner_text()
	corner_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	corner_label.add_theme_font_size_override("font_size", 9)
	corner_label.add_theme_color_override("font_color", Color(0.35, 0.35, 0.35, 0.8))
	face_panel.add_child(corner_label)
	
	# 5. Main Glyph / Symbol
	var has_sub = tile_data != null and tile_data.secondary_text != ""
	symbol_label = Label.new()
	if has_sub:
		symbol_label.position = Vector2(2, 9)
		symbol_label.size = Vector2(TILE_WIDTH - 4, 35)
	else:
		# Centered on the tile face
		symbol_label.position = Vector2(2, 10)
		symbol_label.size = Vector2(TILE_WIDTH - 4, TILE_HEIGHT - 20)
		
	symbol_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	symbol_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	symbol_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	symbol_label.text = tile_data.symbol if tile_data else "?"
	
	# Adjust font size according to symbol length for optimal legibility
	var sym_len = symbol_label.text.length()
	var font_sz = 26
	if not has_sub:
		font_sz = 34 if sym_len <= 1 else 24
	elif sym_len > 1:
		font_sz = 20
	symbol_label.add_theme_font_size_override("font_size", font_sz)
	if tile_data:
		symbol_label.add_theme_color_override("font_color", tile_data.primary_color)
	face_panel.add_child(symbol_label)
	
	# 6. Secondary text (e.g. "萬", "竹", "●" for suits with secondary glyphs)
	if has_sub:
		sub_label = Label.new()
		sub_label.position = Vector2(2, 44)
		sub_label.size = Vector2(TILE_WIDTH - 4, 24)
		sub_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		sub_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		sub_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		sub_label.text = tile_data.secondary_text
		var sub_font_sz = 14
		if sub_label.text.length() > 3:
			sub_font_sz = 10
		sub_label.add_theme_font_size_override("font_size", sub_font_sz)
		if tile_data:
			sub_label.add_theme_color_override("font_color", tile_data.secondary_color)
		face_panel.add_child(sub_label)
	else:
		sub_label = null
	
	# 7. Highlight / Selection Border
	highlight_border = ReferenceRect.new()
	highlight_border.position = Vector2(-2, -2)
	highlight_border.size = Vector2(TILE_WIDTH + 4, TILE_HEIGHT + 4)
	highlight_border.border_color = Color(1.0, 0.84, 0.0, 0.0)
	highlight_border.border_width = 3.0
	highlight_border.editor_only = false
	highlight_border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	face_panel.add_child(highlight_border)

	# 8. Interactive Touch / Click Overlay Button
	click_button = Button.new()
	click_button.name = "ClickButton"
	click_button.flat = true
	click_button.position = Vector2.ZERO
	click_button.size = custom_minimum_size
	click_button.focus_mode = Control.FOCUS_NONE
	click_button.mouse_filter = Control.MOUSE_FILTER_STOP
	click_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	var empty_style = StyleBoxEmpty.new()
	click_button.add_theme_stylebox_override("normal", empty_style)
	click_button.add_theme_stylebox_override("pressed", empty_style)
	click_button.add_theme_stylebox_override("hover", empty_style)
	click_button.add_theme_stylebox_override("focus", empty_style)
	click_button.add_theme_stylebox_override("disabled", empty_style)
	
	click_button.pressed.connect(_on_button_pressed)
	add_child(click_button)

func _on_button_pressed() -> void:
	tile_clicked.emit(self)

func _get_corner_text() -> String:
	if tile_data == null:
		return ""
	match tile_data.suit:
		"bamboo": return "%sB" % tile_data.value
		"dots": return "%sD" % tile_data.value
		"characters": return "%sC" % tile_data.value
		"winds": return tile_data.value.substr(0, 1).to_upper()
		"dragons": return tile_data.value.substr(0, 1).to_upper()
		"flowers": return "FL"
		"seasons": return "SN"
	return ""

func _is_dimming_enabled() -> bool:
	var tree = Engine.get_main_loop() as SceneTree
	if tree and tree.root and tree.root.has_node("SaveManager"):
		return tree.root.get_node("SaveManager").get_setting("dim_blocked_tiles", true)
	return true

func update_state() -> void:
	if face_panel == null:
		return
		
	var dim_blocked = _is_dimming_enabled()
	
	if not is_free and dim_blocked:
		modulate = Color(0.70, 0.70, 0.70, 0.88)
	else:
		modulate = Color(1.0, 1.0, 1.0, 1.0)
		
	if click_button:
		click_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if is_free else Control.CURSOR_ARROW
		
	if is_selected:
		face_panel.position = Vector2(0, -BEVEL_DEPTH)
		if highlight_border:
			highlight_border.border_color = Color(1.0, 0.84, 0.0, 1.0)
		scale = Vector2(base_scale * 1.05, base_scale * 1.05)
		z_index = grid_pos.z * 10 + 5
	elif is_hinted:
		face_panel.position = Vector2.ZERO
		if highlight_border:
			highlight_border.border_color = Color(0.2, 0.9, 0.4, 0.95)
		scale = Vector2(base_scale * 1.02, base_scale * 1.02)
		z_index = grid_pos.z * 10 + 2
	else:
		face_panel.position = Vector2.ZERO
		if highlight_border:
			highlight_border.border_color = Color(1.0, 0.84, 0.0, 0.0)
		scale = Vector2(base_scale, base_scale)
		z_index = grid_pos.z * 10

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		tile_clicked.emit(self)
		accept_event()
	elif event is InputEventScreenTouch and event.pressed:
		tile_clicked.emit(self)
		accept_event()

func play_match_animation() -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(base_scale * 1.2, base_scale * 1.2), 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(queue_free)

func play_invalid_shake() -> void:
	var orig_x = position.x
	var tween = create_tween()
	tween.tween_property(self, "position:x", orig_x - 5, 0.04)
	tween.tween_property(self, "position:x", orig_x + 5, 0.04)
	tween.tween_property(self, "position:x", orig_x, 0.04)
