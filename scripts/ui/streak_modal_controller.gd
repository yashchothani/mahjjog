class_name StreakModalController
extends PanelContainer

## Controller for the 7-Day Streak & Daily Reward Modal.
## Displays the player's current streak, 7-day milestone track, and awards bonus hints.

signal closed
signal reward_claimed(hints_awarded: int)

@onready var close_btn: Button = %CloseBtn
@onready var streak_num_label: Label = %StreakNumLabel
@onready var title_label: Label = %TitleLabel
@onready var subtitle_label: Label = %SubtitleLabel
@onready var track_container: HBoxContainer = %TrackContainer
@onready var reward_desc_label: Label = %RewardDescLabel
@onready var claim_btn: Button = %ClaimBtn

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
	if close_btn and not close_btn.pressed.is_connected(_on_close_pressed):
		close_btn.pressed.connect(_on_close_pressed)
	if claim_btn and not claim_btn.pressed.is_connected(_on_claim_pressed):
		claim_btn.pressed.connect(_on_claim_pressed)
	refresh_streak_ui()

func refresh_streak_ui() -> void:
	var sm = _sm()
	var lm = _lm()
	var streak = sm.get_daily_streak() if sm else 1
	var cycle_day = max(1, ((streak - 1) % 7) + 1)
	var already_claimed = sm.is_streak_claimed_today() if sm else false
	
	if streak_num_label:
		streak_num_label.text = str(max(1, streak))
	if title_label and lm:
		title_label.text = lm.get_text("STREAK_TITLE", "Day Streak")
	if subtitle_label and lm:
		subtitle_label.text = lm.get_text("STREAK_SUBTITLE", "Tranquil focus, great job!")
		
	# Populate 7-day nodes
	if track_container:
		for child in track_container.get_children():
			child.queue_free()
			
		for d in range(1, 8):
			var node_panel = PanelContainer.new()
			node_panel.custom_minimum_size = Vector2(40, 48)
			
			var style = StyleBoxFlat.new()
			style.corner_radius_top_left = 8
			style.corner_radius_top_right = 8
			style.corner_radius_bottom_left = 8
			style.corner_radius_bottom_right = 8
			
			var lbl = Label.new()
			lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
			
			if d < cycle_day:
				# Completed
				style.bg_color = Color(0.18, 0.44, 0.28, 0.95)
				style.border_color = Color(0.96, 0.86, 0.52, 0.8)
				style.border_width_left = 1
				style.border_width_top = 1
				style.border_width_right = 1
				style.border_width_bottom = 1
				lbl.text = "✓"
				lbl.add_theme_color_override("font_color", Color(0.96, 0.86, 0.52))
				lbl.add_theme_font_size_override("font_size", 16)
			elif d == cycle_day:
				# Current Active Day
				style.bg_color = Color(0.25, 0.55, 0.35, 1.0)
				style.border_color = Color(0.3, 0.95, 0.55, 1.0)
				style.border_width_left = 2
				style.border_width_top = 2
				style.border_width_right = 2
				style.border_width_bottom = 2
				if d == 7:
					lbl.text = "🎁"
					lbl.add_theme_font_size_override("font_size", 20)
				else:
					lbl.text = str(d)
					lbl.add_theme_color_override("font_color", Color(1, 1, 1))
					lbl.add_theme_font_size_override("font_size", 16)
			else:
				# Upcoming
				style.bg_color = Color(0.06, 0.14, 0.1, 0.8)
				style.border_color = Color(0.83, 0.68, 0.28, 0.25)
				style.border_width_left = 1
				style.border_width_top = 1
				style.border_width_right = 1
				style.border_width_bottom = 1
				if d == 7:
					lbl.text = "🎁"
					lbl.add_theme_font_size_override("font_size", 18)
				else:
					lbl.text = str(d)
					lbl.add_theme_color_override("font_color", Color(0.65, 0.65, 0.6))
					lbl.add_theme_font_size_override("font_size", 14)
					
			node_panel.add_theme_stylebox_override("panel", style)
			node_panel.add_child(lbl)
			track_container.add_child(node_panel)
			
	# Reward description
	if reward_desc_label and lm:
		if cycle_day == 7:
			reward_desc_label.text = lm.get_text("STREAK_CHEST_REWARD", "Day 7 Grand Reward: +5 Hints & Golden Chest!")
		else:
			reward_desc_label.text = lm.get_text("STREAK_DAILY_REWARD", "Daily Reward: +2 Bonus Hints!")
			
	# Claim button
	if claim_btn and lm:
		if already_claimed:
			claim_btn.text = lm.get_text("STREAK_CLAIMED_BTN", "Claimed Today ✓")
			claim_btn.disabled = true
			claim_btn.modulate = Color(0.7, 0.7, 0.7, 0.9)
		else:
			claim_btn.text = lm.get_text("STREAK_CLAIM_BTN", "Claim Reward")
			claim_btn.disabled = false
			claim_btn.modulate = Color(1, 1, 1, 1)

func _on_claim_pressed() -> void:
	var am = _am()
	if am: am.play_sfx("button_click")
	
	var sm = _sm()
	if sm:
		var res = sm.claim_daily_streak()
		if res["success"]:
			reward_claimed.emit(res["hints_awarded"])
			
	refresh_streak_ui()
	
	# Auto close modal after brief delay or user click
	var tw = create_tween()
	tw.tween_interval(0.6)
	tw.tween_callback(func():
		_on_close_pressed()
	)

func _on_close_pressed() -> void:
	var am = _am()
	if am: am.play_sfx("button_click")
	closed.emit()
	visible = false
