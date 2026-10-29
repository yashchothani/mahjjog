class_name ProfileModalController
extends PanelContainer

## Controller for the Player Profile and Avatar Customization Modal.
## Allows players to customize their nickname, select from 8 Zen avatars, and customize frames.

signal closed
signal profile_saved

var current_tab: int = 0
var selected_avatar_id: int = 0
var selected_frame_id: String = "gold"

@onready var title_label: Label = %TitleLabel
@onready var close_btn: Button = %CloseBtn
@onready var tab_avatar_btn: Button = %TabAvatarBtn
@onready var tab_frame_btn: Button = %TabFrameBtn

@onready var preview_icon: Label = %PreviewIcon
@onready var preview_frame: Panel = %PreviewFrame
@onready var name_input: LineEdit = %NameInput
var name_edit: LineEdit:
	get:
		return name_input if is_instance_valid(name_input) else get_node_or_null("%NameInput")

func _on_avatar_selected(id: int) -> void:
	selected_avatar_id = id
	_update_preview()
	_refresh_avatar_grid_selection()

func _on_frame_selected(id) -> void:
	if id is int:
		var sm = _sm()
		var frames = sm.FRAME_DEFS if sm else []
		if id >= 0 and id < frames.size():
			selected_frame_id = frames[id]["id"]
	else:
		selected_frame_id = str(id)
	_update_preview()
	_refresh_frame_grid_selection()

@onready var avatar_panel: Control = %AvatarPanel
@onready var avatar_grid: GridContainer = %AvatarGrid

@onready var frame_panel: Control = %FramePanel
@onready var frame_grid: GridContainer = %FrameGrid

@onready var save_btn: Button = %SaveBtn

func _get_autoload(autoload_name: String) -> Node:
	var tree = Engine.get_main_loop() as SceneTree
	if tree and tree.root and tree.root.has_node(autoload_name):
		return tree.root.get_node(autoload_name)
	return null

func _sm() -> Node:
	return _get_autoload("SaveManager")

func _lm() -> Node:
	return _get_autoload("LocalizationManager")

func _am() -> Node:
	return _get_autoload("AudioManager")

func _ready() -> void:
	_connect_events()
	load_current_profile()
	_build_avatar_grid()
	_build_frame_grid()
	_select_tab(0)
	_update_localized_strings()

func _connect_events() -> void:
	if close_btn and not close_btn.pressed.is_connected(_on_close_pressed):
		close_btn.pressed.connect(_on_close_pressed)
	if tab_avatar_btn and not tab_avatar_btn.pressed.is_connected(func(): _select_tab(0)):
		tab_avatar_btn.pressed.connect(func(): _select_tab(0))
	if tab_frame_btn and not tab_frame_btn.pressed.is_connected(func(): _select_tab(1)):
		tab_frame_btn.pressed.connect(func(): _select_tab(1))
	if save_btn and not save_btn.pressed.is_connected(_on_save_pressed):
		save_btn.pressed.connect(_on_save_pressed)

func load_current_profile() -> void:
	var sm = _sm()
	if sm:
		selected_avatar_id = sm.get_avatar_id()
		selected_frame_id = sm.get_avatar_frame()
		if name_input:
			name_input.text = sm.get_player_name()
	else:
		selected_avatar_id = 0
		selected_frame_id = "gold"
		if name_input:
			name_input.text = "Zen Explorer"
	_update_preview()

func _select_tab(index: int) -> void:
	current_tab = index
	var am = _am()
	if am and is_inside_tree() and visible:
		am.play_sfx("button_click")
		
	if avatar_panel: avatar_panel.visible = (index == 0)
	if frame_panel: frame_panel.visible = (index == 1)
	
	_style_tab_btn(tab_avatar_btn, index == 0)
	_style_tab_btn(tab_frame_btn, index == 1)

func _style_tab_btn(btn: Button, is_active: bool) -> void:
	if not btn: return
	var style = StyleBoxFlat.new()
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left = 16.0
	style.content_margin_right = 16.0
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
		btn.add_theme_color_override("font_color", Color(0.78, 0.76, 0.70, 0.8))
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style)
	btn.add_theme_stylebox_override("pressed", style)

func _build_avatar_grid() -> void:
	if not avatar_grid: return
	for child in avatar_grid.get_children():
		avatar_grid.remove_child(child)
		child.queue_free()
		
	var sm = _sm()
	var defs = sm.AVATAR_DEFS if sm else [
		{ "id": 0, "name": "Zen Sage", "icon": "🧘", "color": Color(0.18, 0.44, 0.30) },
		{ "id": 1, "name": "Dragon Sovereign", "icon": "👑", "color": Color(0.85, 0.68, 0.25) },
		{ "id": 2, "name": "Bamboo Nomad", "icon": "🎋", "color": Color(0.20, 0.55, 0.32) },
		{ "id": 3, "name": "Lotus Maiden", "icon": "🌸", "color": Color(0.80, 0.30, 0.55) },
		{ "id": 4, "name": "Crane Scholar", "icon": "🦅", "color": Color(0.25, 0.45, 0.70) },
		{ "id": 5, "name": "Wind Hermit", "icon": "🍃", "color": Color(0.35, 0.65, 0.40) },
		{ "id": 6, "name": "Wave Seeker", "icon": "🌊", "color": Color(0.15, 0.50, 0.75) },
		{ "id": 7, "name": "Mountain Hermit", "icon": "🪨", "color": Color(0.55, 0.45, 0.35) }
	]
	
	for d in defs:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(80, 80)
		btn.focus_mode = Control.FOCUS_NONE
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		var vbox = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
		
		var icon_lbl = Label.new()
		icon_lbl.text = d["icon"]
		icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		icon_lbl.add_theme_font_size_override("font_size", 28)
		vbox.add_child(icon_lbl)
		
		var name_lbl = Label.new()
		name_lbl.text = d["name"]
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_lbl.add_theme_font_size_override("font_size", 9)
		name_lbl.add_theme_color_override("font_color", Color(0.85, 0.85, 0.75))
		vbox.add_child(name_lbl)
		
		btn.add_child(vbox)
		
		var av_id = int(d["id"])
		btn.pressed.connect(func():
			selected_avatar_id = av_id
			var am = _am()
			if am: am.play_sfx("button_click")
			_update_preview()
			_refresh_avatar_grid_selection()
		)
		avatar_grid.add_child(btn)
		
	_refresh_avatar_grid_selection()

func _refresh_avatar_grid_selection() -> void:
	if not avatar_grid: return
	var children = avatar_grid.get_children()
	for i in range(children.size()):
		var btn = children[i] as Button
		if not btn: continue
		var is_sel = (i == selected_avatar_id)
		
		var style = StyleBoxFlat.new()
		style.corner_radius_top_left = 12
		style.corner_radius_top_right = 12
		style.corner_radius_bottom_left = 12
		style.corner_radius_bottom_right = 12
		style.content_margin_left = 6.0
		style.content_margin_right = 6.0
		style.content_margin_top = 6.0
		style.content_margin_bottom = 6.0
		
		if is_sel:
			style.bg_color = Color(0.18, 0.44, 0.30, 0.95)
			style.border_color = Color(0.3, 0.95, 0.55, 1.0) # Vibrant green border
			style.border_width_left = 3
			style.border_width_top = 3
			style.border_width_right = 3
			style.border_width_bottom = 3
		else:
			style.bg_color = Color(0.06, 0.15, 0.11, 0.85)
			style.border_color = Color(0.83, 0.68, 0.28, 0.35)
			style.border_width_left = 1
			style.border_width_top = 1
			style.border_width_right = 1
			style.border_width_bottom = 1
			
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		btn.add_theme_stylebox_override("pressed", style)

func _build_frame_grid() -> void:
	if not frame_grid: return
	for child in frame_grid.get_children():
		frame_grid.remove_child(child)
		child.queue_free()
		
	var sm = _sm()
	var frames = sm.FRAME_DEFS if sm else [
		{ "id": "gold", "name": "Imperial Gold", "color": Color(0.96, 0.86, 0.52) },
		{ "id": "jade", "name": "Deep Jade", "color": Color(0.22, 0.65, 0.42) },
		{ "id": "lotus", "name": "Lotus Blossom", "color": Color(0.92, 0.55, 0.72) },
		{ "id": "obsidian", "name": "Black Obsidian", "color": Color(0.35, 0.38, 0.42) }
	]
	
	for f in frames:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(84, 70)
		btn.focus_mode = Control.FOCUS_NONE
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		var vbox = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
		
		var circle = ColorRect.new()
		circle.custom_minimum_size = Vector2(28, 28)
		circle.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		circle.color = f["color"]
		vbox.add_child(circle)
		
		var name_lbl = Label.new()
		name_lbl.text = f["name"]
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_lbl.add_theme_font_size_override("font_size", 9)
		name_lbl.add_theme_color_override("font_color", Color(0.85, 0.85, 0.75))
		vbox.add_child(name_lbl)
		
		btn.add_child(vbox)
		
		var fid = str(f["id"])
		btn.pressed.connect(func():
			selected_frame_id = fid
			var am = _am()
			if am: am.play_sfx("button_click")
			_update_preview()
			_refresh_frame_grid_selection()
		)
		frame_grid.add_child(btn)
		
	_refresh_frame_grid_selection()

func _refresh_frame_grid_selection() -> void:
	if not frame_grid: return
	var sm = _sm()
	var frames = sm.FRAME_DEFS if sm else []
	var children = frame_grid.get_children()
	for i in range(min(children.size(), frames.size())):
		var btn = children[i] as Button
		var f = frames[i]
		var is_sel = (f["id"] == selected_frame_id)
		
		var style = StyleBoxFlat.new()
		style.corner_radius_top_left = 10
		style.corner_radius_top_right = 10
		style.corner_radius_bottom_left = 10
		style.corner_radius_bottom_right = 10
		style.content_margin_left = 6.0
		style.content_margin_right = 6.0
		style.content_margin_top = 6.0
		style.content_margin_bottom = 6.0
		
		if is_sel:
			style.bg_color = Color(0.18, 0.44, 0.30, 0.95)
			style.border_color = Color(0.3, 0.95, 0.55, 1.0)
			style.border_width_left = 2
			style.border_width_top = 2
			style.border_width_right = 2
			style.border_width_bottom = 2
		else:
			style.bg_color = Color(0.06, 0.15, 0.11, 0.85)
			style.border_color = Color(0.83, 0.68, 0.28, 0.35)
			style.border_width_left = 1
			style.border_width_top = 1
			style.border_width_right = 1
			style.border_width_bottom = 1
			
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		btn.add_theme_stylebox_override("pressed", style)

func _update_preview() -> void:
	var sm = _sm()
	var defs = sm.AVATAR_DEFS if sm else []
	var icon_text = "🧘"
	if selected_avatar_id >= 0 and selected_avatar_id < defs.size():
		icon_text = defs[selected_avatar_id]["icon"]
	if preview_icon:
		preview_icon.text = icon_text
		
	var frame_color = Color(0.96, 0.86, 0.52)
	var frames = sm.FRAME_DEFS if sm else []
	for f in frames:
		if f["id"] == selected_frame_id:
			frame_color = f["color"]
			break
			
	if preview_frame:
		var f_style = StyleBoxFlat.new()
		f_style.bg_color = Color(0.08, 0.18, 0.13, 0.95)
		f_style.border_color = frame_color
		f_style.border_width_left = 3
		f_style.border_width_top = 3
		f_style.border_width_right = 3
		f_style.border_width_bottom = 3
		f_style.corner_radius_top_left = 36
		f_style.corner_radius_top_right = 36
		f_style.corner_radius_bottom_left = 36
		f_style.corner_radius_bottom_right = 36
		preview_frame.add_theme_stylebox_override("panel", f_style)

func _update_localized_strings() -> void:
	var lm = _lm()
	if not lm: return
	if title_label: title_label.text = lm.get_text("PROFILE_TITLE", "Player Profile")
	if tab_avatar_btn: tab_avatar_btn.text = lm.get_text("PROFILE_AVATAR", "Avatar")
	if tab_frame_btn: tab_frame_btn.text = lm.get_text("PROFILE_FRAME", "Frame")
	if save_btn: save_btn.text = lm.get_text("BTN_SAVE_PROFILE", "Save Profile")
	if name_input: name_input.placeholder_text = lm.get_text("PROFILE_NAME_LABEL", "Player Name")

func _on_save_pressed() -> void:
	var am = _am()
	if am: am.play_sfx("button_click")
	
	var sm = _sm()
	if sm:
		var p_name = name_input.text.strip_edges() if name_input else "Zen Explorer"
		sm.set_player_name(p_name)
		sm.set_avatar_id(selected_avatar_id)
		sm.set_avatar_frame(selected_frame_id)
		
	profile_saved.emit()
	_on_close_pressed()

func _on_close_pressed() -> void:
	var am = _am()
	if am: am.play_sfx("button_click")
	closed.emit()
	visible = false
