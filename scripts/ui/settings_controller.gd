extends Control

## Controller for the Settings & Accessibility screen.
## Includes player profile quick access, circular audio/haptic toggles, volume sliders, and language options.

@onready var title_label: Label = $CenterContainer/Panel/VBox/Header/Title
@onready var close_top_btn: Button = $CenterContainer/Panel/VBox/Header/CloseTopBtn

@onready var player_name_label: Label = $CenterContainer/Panel/VBox/ProfileCard/HBox/NameVBox/PlayerNameLabel
@onready var avatar_icon: Label = $CenterContainer/Panel/VBox/ProfileCard/HBox/AvatarCircle/AvatarIcon
@onready var edit_profile_btn: Button = $CenterContainer/Panel/VBox/ProfileCard/HBox/EditProfileBtn

@onready var music_toggle_btn: Button = $CenterContainer/Panel/VBox/QuickTogglesBox/MusicToggleBtn
@onready var sfx_toggle_btn: Button = $CenterContainer/Panel/VBox/QuickTogglesBox/SFXToggleBtn
@onready var haptic_toggle_btn: Button = $CenterContainer/Panel/VBox/QuickTogglesBox/HapticToggleBtn

@onready var music_label: Label = $CenterContainer/Panel/VBox/AudioBox/MusicLabel
@onready var music_slider: HSlider = $CenterContainer/Panel/VBox/AudioBox/MusicSlider
@onready var sfx_label: Label = $CenterContainer/Panel/VBox/AudioBox/SFXLabel
@onready var sfx_slider: HSlider = $CenterContainer/Panel/VBox/AudioBox/SFXSlider

@onready var language_label: Label = $CenterContainer/Panel/VBox/LanguageBox/LanguageLabel
@onready var language_option: OptionButton = $CenterContainer/Panel/VBox/LanguageBox/LanguageOption

@onready var dim_check: CheckBox = $CenterContainer/Panel/VBox/AccessBox/DimCheck
@onready var haptic_check: CheckBox = $CenterContainer/Panel/VBox/AccessBox/HapticCheck
@onready var motion_check: CheckBox = $CenterContainer/Panel/VBox/AccessBox/MotionCheck
@onready var privacy_btn: Button = $CenterContainer/Panel/VBox/PrivacyBtn
@onready var back_btn: Button = $CenterContainer/Panel/VBox/BackBtn

@onready var profile_modal: Control = $Modals/ProfileModal

var _languages_data: Array[Dictionary] = []
var _is_initializing: bool = true

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
	_is_initializing = true
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
		
	_setup_language_options()
	_update_localized_texts()
	_update_profile_preview()
	_update_toggle_states()
	
	var lm = _lm()
	if lm and lm.has_signal("language_changed"):
		if not lm.language_changed.is_connected(_on_language_changed_signal):
			lm.language_changed.connect(_on_language_changed_signal)
			
	if profile_modal and profile_modal.has_signal("profile_saved"):
		if not profile_modal.profile_saved.is_connected(_on_profile_saved):
			profile_modal.profile_saved.connect(_on_profile_saved)
			
	var am = _am()
	if am and am.has_method("play_menu_music") and am.get_current_music_track().is_empty():
		am.play_menu_music()
		
	_is_initializing = false

func _update_profile_preview() -> void:
	var sm = _sm()
	if not sm: return
	if player_name_label:
		player_name_label.text = sm.get_player_name()
	if avatar_icon:
		var av_id = sm.get_avatar_id()
		var defs = sm.AVATAR_DEFS
		if av_id >= 0 and av_id < defs.size():
			avatar_icon.text = defs[av_id]["icon"]

func _update_toggle_states() -> void:
	var sm = _sm()
	if not sm: return
	var music_muted = sm.get_setting("music_muted", false)
	var sfx_muted = sm.get_setting("sfx_muted", false)
	var haptic_on = sm.get_setting("haptics_enabled", true)
	
	if music_toggle_btn:
		music_toggle_btn.text = "🔇" if music_muted else "🎵"
		music_toggle_btn.modulate = Color(0.8, 0.4, 0.4) if music_muted else Color(1, 1, 1)
	if sfx_toggle_btn:
		sfx_toggle_btn.text = "🔇" if sfx_muted else "🔊"
		sfx_toggle_btn.modulate = Color(0.8, 0.4, 0.4) if sfx_muted else Color(1, 1, 1)
	if haptic_toggle_btn:
		haptic_toggle_btn.text = "📴" if not haptic_on else "📳"
		haptic_toggle_btn.modulate = Color(0.8, 0.4, 0.4) if not haptic_on else Color(1, 1, 1)

func _exit_tree() -> void:
	var lm = _lm()
	if lm and lm.has_signal("language_changed") and lm.language_changed.is_connected(_on_language_changed_signal):
		lm.language_changed.disconnect(_on_language_changed_signal)
	if profile_modal and profile_modal.has_signal("profile_saved") and profile_modal.profile_saved.is_connected(_on_profile_saved):
		profile_modal.profile_saved.disconnect(_on_profile_saved)

func _setup_language_options() -> void:
	var lang_opt = language_option if language_option != null else get_node_or_null("CenterContainer/Panel/VBox/LanguageBox/LanguageOption") as OptionButton
	if not lang_opt:
		return
		
	lang_opt.clear()
	var lm = _lm()
	if lm:
		_languages_data = lm.get_available_languages()
		var current_code = lm.get_current_language()
		var selected_idx = 0
		
		for i in range(_languages_data.size()):
			var item = _languages_data[i]
			var display_str = "%s (%s)" % [item["native"], item["name"]]
			lang_opt.add_item(display_str, i)
			if item["code"] == current_code:
				selected_idx = i
		lang_opt.selected = selected_idx

func _update_localized_texts() -> void:
	var lm = _lm()
	if not lm:
		return
		
	var t_lbl = title_label if title_label != null else get_node_or_null("CenterContainer/Panel/VBox/Header/Title") as Label
	if t_lbl: t_lbl.text = lm.get_text("SETTINGS_TITLE", "Settings & Accessibility")
	
	var m_lbl = music_label if music_label != null else get_node_or_null("CenterContainer/Panel/VBox/AudioBox/MusicLabel") as Label
	if m_lbl: m_lbl.text = lm.get_text("MUSIC_VOLUME", "Music Volume")
	
	var s_lbl = sfx_label if sfx_label != null else get_node_or_null("CenterContainer/Panel/VBox/AudioBox/SFXLabel") as Label
	if s_lbl: s_lbl.text = lm.get_text("SFX_VOLUME", "Sound Effects Volume")
	
	var l_lbl = language_label if language_label != null else get_node_or_null("CenterContainer/Panel/VBox/LanguageBox/LanguageLabel") as Label
	if l_lbl: l_lbl.text = lm.get_text("LANGUAGE_LABEL", "Language")
	
	var d_ck = dim_check if dim_check != null else get_node_or_null("CenterContainer/Panel/VBox/AccessBox/DimCheck") as CheckBox
	if d_ck: d_ck.text = lm.get_text("DIM_BLOCKED", "Dim blocked tiles (visual assistance)")
	
	var h_ck = haptic_check if haptic_check != null else get_node_or_null("CenterContainer/Panel/VBox/AccessBox/HapticCheck") as CheckBox
	if h_ck: h_ck.text = lm.get_text("HAPTIC_FEEDBACK", "Enable haptic feedback on touch")
	
	var mo_ck = motion_check if motion_check != null else get_node_or_null("CenterContainer/Panel/VBox/AccessBox/MotionCheck") as CheckBox
	if mo_ck: mo_ck.text = lm.get_text("REDUCED_MOTION", "Reduced motion (softer transitions)")
	
	var p_btn = privacy_btn if privacy_btn != null else get_node_or_null("CenterContainer/Panel/VBox/PrivacyBtn") as Button
	if p_btn: p_btn.text = lm.get_text("BTN_PRIVACY_POLICY", "📜  Privacy Policy")
	
	var b_btn = back_btn if back_btn != null else get_node_or_null("CenterContainer/Panel/VBox/BackBtn") as Button
	if b_btn: b_btn.text = lm.get_text("BTN_BACK_MENU", "◀ Return to Main Menu")
	
	if edit_profile_btn:
		edit_profile_btn.text = lm.get_text("SETTINGS_EDIT_PROFILE", "✏️ Edit Profile")

func _on_language_changed_signal(_new_code: String) -> void:
	_update_localized_texts()

func _on_edit_profile_pressed() -> void:
	var am = _am()
	if am: am.play_sfx("button_click")
	if profile_modal:
		profile_modal.load_current_profile()
		profile_modal.visible = true

func _on_profile_saved() -> void:
	_update_profile_preview()

func _on_music_toggle_pressed() -> void:
	var am = _am()
	if am: am.play_sfx("button_click")
	var sm = _sm()
	if sm:
		var current = sm.get_setting("music_muted", false)
		sm.set_setting("music_muted", not current)
		_update_toggle_states()

func _on_sfx_toggle_pressed() -> void:
	var am = _am()
	if am: am.play_sfx("button_click")
	var sm = _sm()
	if sm:
		var current = sm.get_setting("sfx_muted", false)
		sm.set_setting("sfx_muted", not current)
		_update_toggle_states()

func _on_haptic_toggle_pressed() -> void:
	var am = _am()
	if am: am.play_sfx("button_click")
	var sm = _sm()
	if sm:
		var current = sm.get_setting("haptics_enabled", true)
		sm.set_setting("haptics_enabled", not current)
		if haptic_check:
			haptic_check.button_pressed = not current
		_update_toggle_states()

func _on_language_selected(index: int) -> void:
	var am = _am()
	if am: am.play_sfx("button_click")
		
	if index >= 0 and index < _languages_data.size():
		var target_code = _languages_data[index]["code"]
		var lm = _lm()
		if lm: lm.set_language(target_code)

func _on_music_slider_value_changed(value: float) -> void:
	if _is_initializing:
		return
	var sm = _sm()
	if sm:
		sm.set_setting("music_volume", value)
		if value > 0.01 and sm.get_setting("music_muted", false):
			sm.set_setting("music_muted", false)
			_update_toggle_states()

func _on_sfx_slider_value_changed(value: float) -> void:
	if _is_initializing:
		return
	var sm = _sm()
	if sm:
		sm.set_setting("sfx_volume", value)
		if value > 0.01 and sm.get_setting("sfx_muted", false):
			sm.set_setting("sfx_muted", false)
			_update_toggle_states()

func _on_sfx_drag_ended(value_changed: bool) -> void:
	if _is_initializing:
		return
	if value_changed:
		var am = _am()
		if am: am.play_sfx("tile_click")

func _on_dim_check_toggled(toggled_on: bool) -> void:
	if _is_initializing:
		return
	var am = _am()
	if am: am.play_sfx("button_click")
	var sm = _sm()
	if sm: sm.set_setting("dim_blocked_tiles", toggled_on)

func _on_haptic_check_toggled(toggled_on: bool) -> void:
	if _is_initializing:
		return
	var am = _am()
	if am: am.play_sfx("button_click")
	var sm = _sm()
	if sm:
		sm.set_setting("haptics_enabled", toggled_on)
		_update_toggle_states()

func _on_motion_check_toggled(toggled_on: bool) -> void:
	if _is_initializing:
		return
	var am = _am()
	if am: am.play_sfx("button_click")
	var sm = _sm()
	if sm: sm.set_setting("reduced_motion", toggled_on)

func _on_privacy_pressed() -> void:
	var am = _am()
	if am: am.play_sfx("button_click")
	OS.shell_open("https://yashchothani.github.io/mahjjog/privacy_policy.html")

func _on_back_pressed() -> void:
	var am = _am()
	if am: am.play_sfx("button_click")
	var gm = _gm()
	if gm:
		gm.return_to_main_menu()
	else:
		get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
