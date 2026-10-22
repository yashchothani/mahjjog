extends Control

## Controller for the Settings & Accessibility screen.

@onready var music_slider: HSlider = $CenterContainer/Panel/VBox/AudioBox/MusicSlider
@onready var sfx_slider: HSlider = $CenterContainer/Panel/VBox/AudioBox/SFXSlider
@onready var dim_check: CheckBox = $CenterContainer/Panel/VBox/AccessBox/DimCheck
@onready var haptic_check: CheckBox = $CenterContainer/Panel/VBox/AccessBox/HapticCheck
@onready var motion_check: CheckBox = $CenterContainer/Panel/VBox/AccessBox/MotionCheck

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
	var sm = _sm()
	var m_sl = music_slider if music_slider != null else get_node_or_null("CenterContainer/Panel/VBox/AudioBox/MusicSlider") as HSlider
	var s_sl = sfx_slider if sfx_slider != null else get_node_or_null("CenterContainer/Panel/VBox/AudioBox/SFXSlider") as HSlider
	var d_ck = dim_check if dim_check != null else get_node_or_null("CenterContainer/Panel/VBox/AccessBox/DimCheck") as CheckBox
	var h_ck = haptic_check if haptic_check != null else get_node_or_null("CenterContainer/Panel/VBox/AccessBox/HapticCheck") as CheckBox
	var mo_ck = motion_check if motion_check != null else get_node_or_null("CenterContainer/Panel/VBox/AccessBox/MotionCheck") as CheckBox
	
	if sm:
		if m_sl: m_sl.value = sm.get_setting("music_volume", 0.8)
		if s_sl: s_sl.value = sm.get_setting("sfx_volume", 1.0)
		if d_ck: d_ck.button_pressed = sm.get_setting("dim_blocked_tiles", true)
		if h_ck: h_ck.button_pressed = sm.get_setting("haptics_enabled", true)
		if mo_ck: mo_ck.button_pressed = sm.get_setting("reduced_motion", false)

func _on_music_slider_value_changed(value: float) -> void:
	var sm = _sm()
	if sm:
		sm.set_setting("music_volume", value)

func _on_sfx_slider_value_changed(value: float) -> void:
	var sm = _sm()
	if sm:
		sm.set_setting("sfx_volume", value)

func _on_sfx_drag_ended(value_changed: bool) -> void:
	if value_changed:
		var am = _am()
		if am:
			am.play_sfx("tile_click")

func _on_dim_check_toggled(toggled_on: bool) -> void:
	var am = _am()
	if am:
		am.play_sfx("button_click")
	var sm = _sm()
	if sm:
		sm.set_setting("dim_blocked_tiles", toggled_on)

func _on_haptic_check_toggled(toggled_on: bool) -> void:
	var am = _am()
	if am:
		am.play_sfx("button_click")
	var sm = _sm()
	if sm:
		sm.set_setting("haptics_enabled", toggled_on)

func _on_motion_check_toggled(toggled_on: bool) -> void:
	var am = _am()
	if am:
		am.play_sfx("button_click")
	var sm = _sm()
	if sm:
		sm.set_setting("reduced_motion", toggled_on)

func _on_back_pressed() -> void:
	var am = _am()
	if am:
		am.play_sfx("button_click")
	var gm = _gm()
	if gm:
		gm.return_to_main_menu()
	else:
		get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
