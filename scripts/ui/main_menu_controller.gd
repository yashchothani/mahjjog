extends Control

## Controller for the Zen Mahjong Main Menu.

@onready var continue_btn: Button = $CenterContainer/VBox/MenuButtons/ContinueBtn
@onready var daily_btn: Button = $CenterContainer/VBox/MenuButtons/DailyBtn
@onready var streak_label: Label = $CenterContainer/VBox/StreakLabel
@onready var tutorial_modal: PanelContainer = $Modals/TutorialModal

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

func _get_tutorial_modal() -> PanelContainer:
	if tutorial_modal != null:
		return tutorial_modal
	return get_node_or_null("Modals/TutorialModal") as PanelContainer

func _ready() -> void:
	var modal = _get_tutorial_modal()
	if modal:
		modal.hide()
	_update_ui_state()

func _update_ui_state() -> void:
	var sm = _sm()
	var c_btn = continue_btn if continue_btn != null else get_node_or_null("CenterContainer/VBox/MenuButtons/ContinueBtn") as Button
	var s_lbl = streak_label if streak_label != null else get_node_or_null("CenterContainer/VBox/StreakLabel") as Label
	
	if sm:
		var max_lvl = sm.progress.get("max_unlocked_level", 1)
		if c_btn:
			c_btn.text = "▶  Continue (Level %d)" % max_lvl if max_lvl > 1 else "▶  Play"
		var streak = sm.progress.get("daily_streak", 0)
		if s_lbl:
			s_lbl.text = "🌿 Tranquil Garden • Daily Streak: %d Days" % streak
	else:
		if c_btn:
			c_btn.text = "▶  Play"
		if s_lbl:
			s_lbl.text = "🌿 Tranquil Garden"

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
	var am = _am()
	if am:
		am.play_sfx("button_click")
	var gm = _gm()
	if gm:
		gm.start_daily_challenge()
	else:
		get_tree().change_scene_to_file("res://scenes/gameplay/gameplay.tscn")

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
