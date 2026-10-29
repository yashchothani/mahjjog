extends Control

## Controller for the Zen Mahjong Main Menu.
## Manages navigation, top bar player profile and daily streak widgets, and modal dialogs.

@onready var profile_widget_btn: Button = get_node_or_null("TopBar/ProfileWidgetBtn") as Button
@onready var streak_widget_btn: Button = get_node_or_null("TopBar/StreakWidgetBtn") as Button

@onready var continue_btn: Button = $CenterContainer/VBox/MenuButtons/ContinueBtn
@onready var level_select_btn: Button = $CenterContainer/VBox/MenuButtons/LevelSelectBtn
@onready var daily_btn: Button = $CenterContainer/VBox/MenuButtons/DailyBtn
@onready var tutorial_btn: Button = $CenterContainer/VBox/MenuButtons/TutorialBtn
@onready var settings_btn: Button = $CenterContainer/VBox/MenuButtons/SettingsBtn
@onready var streak_label: Label = $CenterContainer/VBox/StreakLabel
@onready var title_label: Label = $CenterContainer/VBox/LogoPanel/LogoVBox/Title
@onready var subtitle_label: Label = $CenterContainer/VBox/LogoPanel/LogoVBox/Subtitle
@onready var version_label: Label = $VersionLabel

@onready var tutorial_modal: PanelContainer = $Modals/TutorialModal
@onready var profile_modal: Control = get_node_or_null("Modals/ProfileModal") as Control
@onready var streak_modal: Control = get_node_or_null("Modals/StreakModal") as Control

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

func _get_tutorial_modal() -> PanelContainer:
	if tutorial_modal != null:
		return tutorial_modal
	return get_node_or_null("Modals/TutorialModal") as PanelContainer

func _ready() -> void:
	var tut_modal = _get_tutorial_modal()
	if tut_modal:
		tut_modal.hide()
		if tut_modal.has_signal("closed"):
			if not tut_modal.closed.is_connected(_on_tutorial_close_pressed):
				tut_modal.closed.connect(_on_tutorial_close_pressed)
				
	if profile_modal:
		profile_modal.hide()
		if profile_modal.has_signal("profile_saved"):
			if not profile_modal.profile_saved.is_connected(_update_ui_state):
				profile_modal.profile_saved.connect(_update_ui_state)
				
	if streak_modal:
		streak_modal.hide()
		if streak_modal.has_signal("reward_claimed"):
			if not streak_modal.reward_claimed.is_connected(func(_hints): _update_ui_state()):
				streak_modal.reward_claimed.connect(func(_hints): _update_ui_state())
				
	_update_ui_state()
	
	var am = _am()
	if am and am.has_method("play_menu_music"):
		am.play_menu_music()
	
	var lm = _lm()
	if lm and lm.has_signal("language_changed"):
		if not lm.language_changed.is_connected(_on_language_changed_signal):
			lm.language_changed.connect(_on_language_changed_signal)

func _update_ui_state() -> void:
	var sm = _sm()
	var lm = _lm()
	
	var c_btn = continue_btn if continue_btn != null else get_node_or_null("CenterContainer/VBox/MenuButtons/ContinueBtn") as Button
	var ls_btn = level_select_btn if level_select_btn != null else get_node_or_null("CenterContainer/VBox/MenuButtons/LevelSelectBtn") as Button
	var d_btn = daily_btn if daily_btn != null else get_node_or_null("CenterContainer/VBox/MenuButtons/DailyBtn") as Button
	var tut_btn = tutorial_btn if tutorial_btn != null else get_node_or_null("CenterContainer/VBox/MenuButtons/TutorialBtn") as Button
	var set_btn = settings_btn if settings_btn != null else get_node_or_null("CenterContainer/VBox/MenuButtons/SettingsBtn") as Button
	var s_lbl = streak_label if streak_label != null else get_node_or_null("CenterContainer/VBox/StreakLabel") as Label
	var t_lbl = title_label if title_label != null else get_node_or_null("CenterContainer/VBox/LogoPanel/LogoVBox/Title") as Label
	var sub_lbl = subtitle_label if subtitle_label != null else get_node_or_null("CenterContainer/VBox/LogoPanel/LogoVBox/Subtitle") as Label
	var v_lbl = version_label if version_label != null else get_node_or_null("VersionLabel") as Label
	
	var p_widget = profile_widget_btn if profile_widget_btn != null else get_node_or_null("TopBar/ProfileWidgetBtn") as Button
	var s_widget = streak_widget_btn if streak_widget_btn != null else get_node_or_null("TopBar/StreakWidgetBtn") as Button
	
	var max_lvl = sm.progress.get("max_unlocked_level", 1) if sm else 1
	var streak = sm.get_daily_streak() if sm else 0
	
	# Profile widget
	if p_widget and sm:
		var p_name = sm.get_player_name()
		var av_id = sm.get_avatar_id()
		var defs = sm.AVATAR_DEFS
		var av_icon = defs[av_id]["icon"] if (av_id >= 0 and av_id < defs.size()) else "🧘"
		p_widget.text = "%s %s ✏️" % [av_icon, p_name]
		
	# Streak widget
	if s_widget:
		if streak > 0:
			s_widget.text = "🔥 %d Day Streak 🎁" % streak
		else:
			s_widget.text = "🔥 Day Streak 🎁"
	
	if lm:
		if t_lbl: t_lbl.text = lm.get_text("APP_TITLE", "ZEN MAHJONG")
		if sub_lbl: sub_lbl.text = lm.get_text("APP_SUBTITLE", "A TRANQUIL SOLITAIRE EXPERIENCE")
		if ls_btn: ls_btn.text = lm.get_text("BTN_LEVEL_SELECT", "🏯  Level Selection")
		if d_btn: d_btn.text = lm.get_text("BTN_DAILY", "📅  Daily Challenge")
		if tut_btn: tut_btn.text = lm.get_text("BTN_TUTORIAL", "📖  How to Play")
		if set_btn: set_btn.text = lm.get_text("BTN_SETTINGS", "⚙  Settings & Audio")
		if v_lbl: v_lbl.text = lm.get_text("VERSION", "Zen Mahjong v1.0.0")
		
		if c_btn:
			if max_lvl > 1:
				c_btn.text = lm.format_text("BTN_CONTINUE", [max_lvl])
			else:
				c_btn.text = lm.get_text("BTN_PLAY", "▶  Play")
				
		if s_lbl:
			if streak > 0:
				s_lbl.text = lm.format_text("DAILY_STREAK", [streak])
			else:
				s_lbl.text = lm.get_text("DAILY_STREAK_ZERO", "🌿 Tranquil Garden")
	else:
		if c_btn:
			c_btn.text = "▶  Continue (Level %d)" % max_lvl if max_lvl > 1 else "▶  Play"
		if s_lbl:
			s_lbl.text = "🌿 Tranquil Garden • Daily Streak: %d Days" % streak if streak > 0 else "🌿 Tranquil Garden"

func _on_language_changed_signal(_new_code: String) -> void:
	_update_ui_state()

func _on_profile_pressed() -> void:
	var am = _am()
	if am: am.play_sfx("button_click")
	if profile_modal:
		profile_modal.load_current_profile()
		profile_modal.show()
		profile_modal.modulate.a = 0.0
		var tw = create_tween()
		tw.tween_property(profile_modal, "modulate:a", 1.0, 0.25)

func _on_streak_pressed() -> void:
	var am = _am()
	if am: am.play_sfx("button_click")
	if streak_modal:
		streak_modal.refresh_streak_ui()
		streak_modal.show()
		streak_modal.modulate.a = 0.0
		var tw = create_tween()
		tw.tween_property(streak_modal, "modulate:a", 1.0, 0.25)

func _on_continue_pressed() -> void:
	var am = _am()
	if am:
		am.play_sfx("button_click")
	var sm = _sm()
	var target_lvl = sm.progress.get("max_unlocked_level", 1) if sm else 1
	var gm = _gm()
	if gm:
		gm.start_level(target_lvl)
	else:
		get_tree().change_scene_to_file("res://scenes/gameplay/gameplay.tscn")

func _on_level_select_pressed() -> void:
	var am = _am()
	if am:
		am.play_sfx("button_click")
	var gm = _gm()
	if gm:
		gm.open_level_select()
	else:
		get_tree().change_scene_to_file("res://scenes/menus/level_select.tscn")

func _on_daily_pressed() -> void:
	# Opening Daily Challenge also lets players view and claim their streak journey!
	_on_streak_pressed()

func _on_settings_pressed() -> void:
	var am = _am()
	if am:
		am.play_sfx("button_click")
	var gm = _gm()
	if gm:
		gm.open_settings()
	else:
		get_tree().change_scene_to_file("res://scenes/settings/settings.tscn")

func _on_tutorial_pressed() -> void:
	var am = _am()
	if am:
		am.play_sfx("button_click")
	var modal = _get_tutorial_modal()
	if modal:
		modal.show()
		modal.modulate.a = 0.0
		var tw = create_tween()
		tw.tween_property(modal, "modulate:a", 1.0, 0.25)

func _on_tutorial_close_pressed() -> void:
	var am = _am()
	if am:
		am.play_sfx("button_click")
	var modal = _get_tutorial_modal()
	if modal:
		modal.hide()
