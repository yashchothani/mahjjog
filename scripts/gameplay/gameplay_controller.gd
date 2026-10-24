extends Control

## Controls HUD, timer, level state, and modals in the gameplay scene.

@onready var board_view: BoardView = $BoardContainer/BoardView
@onready var level_label: Label = $TopBar/HBox/LevelTitle
@onready var timer_label: Label = $TopBar/HBox/TimerLabel
@onready var pairs_label: Label = $TopBar/HBox/PairsLabel
@onready var moves_label: Label = $TopBar/HBox/MovesLabel
@onready var pause_btn: Button = $TopBar/HBox/PauseBtn

# Bottom Bar
@onready var undo_btn: Button = $BottomBar/HBox/UndoBtn
@onready var hint_btn: Button = $BottomBar/HBox/HintBtn
@onready var shuffle_btn: Button = $BottomBar/HBox/ShuffleBtn
@onready var restart_btn: Button = $BottomBar/HBox/RestartBtn

# Dialogs
@onready var pause_modal: PanelContainer = $Modals/PauseModal
@onready var victory_modal: PanelContainer = $Modals/VictoryModal
@onready var no_moves_modal: PanelContainer = $Modals/NoMovesModal
@onready var tutorial_modal: PanelContainer = $Modals/TutorialModal

# Victory dialog labels
@onready var victory_time_label: Label = $Modals/VictoryModal/VBox/StatsBox/TimeVal
@onready var victory_moves_label: Label = $Modals/VictoryModal/VBox/StatsBox/MovesVal
@onready var star_label: Label = $Modals/VictoryModal/VBox/StarLabel

var elapsed_time: float = 0.0
var is_game_active: bool = false
var moves_count: int = 0
var remaining_pairs: int = 0
var current_level_id: int = 1

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

func _get_board_view() -> BoardView:
	if board_view != null:
		return board_view
	return get_node_or_null("BoardContainer/BoardView") as BoardView

func _get_modal(path: String) -> PanelContainer:
	return get_node_or_null(path) as PanelContainer

func _ready() -> void:
	var p_modal = _get_modal("Modals/PauseModal")
	if p_modal: p_modal.hide()
	var v_modal = _get_modal("Modals/VictoryModal")
	if v_modal: v_modal.hide()
	var n_modal = _get_modal("Modals/NoMovesModal")
	if n_modal: n_modal.hide()
	var t_modal = _get_modal("Modals/TutorialModal")
	if t_modal:
		t_modal.hide()
		if t_modal.has_signal("closed") and not t_modal.closed.is_connected(_on_tutorial_closed):
			t_modal.closed.connect(_on_tutorial_closed)
	var backdrop = get_node_or_null("Modals/ModalBackdrop") as Control
	if backdrop: backdrop.hide()
	
	var bv = _get_board_view()
	if bv:
		if not bv.pairs_changed.is_connected(_on_pairs_changed):
			bv.pairs_changed.connect(_on_pairs_changed)
		if not bv.move_made.is_connected(_on_move_made):
			bv.move_made.connect(_on_move_made)
		if not bv.board_cleared.is_connected(_on_board_cleared):
			bv.board_cleared.connect(_on_board_cleared)
		if not bv.no_moves_left.is_connected(_on_no_moves_left):
			bv.no_moves_left.connect(_on_no_moves_left)
	
	var gm = _gm()
	var level_id = gm.active_level_id if gm else 1
	start_level(level_id)
	
	_update_localized_strings()
	
	var lm = _lm()
	if lm and lm.has_signal("language_changed"):
		if not lm.language_changed.is_connected(_on_language_changed_signal):
			lm.language_changed.connect(_on_language_changed_signal)

func _process(delta: float) -> void:
	if is_game_active:
		elapsed_time += delta
		var minutes = int(elapsed_time) / 60
		var seconds = int(elapsed_time) % 60
		var t_lbl = timer_label if timer_label != null else get_node_or_null("TopBar/HBox/TimerLabel") as Label
		if t_lbl:
			t_lbl.text = "%02d:%02d" % [minutes, seconds]

func start_level(level_id: int) -> void:
	current_level_id = level_id
	elapsed_time = 0.0
	moves_count = 0
	is_game_active = true
	
	var p_modal = _get_modal("Modals/PauseModal")
	if p_modal: p_modal.hide()
	var v_modal = _get_modal("Modals/VictoryModal")
	if v_modal: v_modal.hide()
	var n_modal = _get_modal("Modals/NoMovesModal")
	if n_modal: n_modal.hide()
	var t_modal = _get_modal("Modals/TutorialModal")
	if t_modal: t_modal.hide()
	var backdrop = get_node_or_null("Modals/ModalBackdrop") as Control
	if backdrop: backdrop.hide()
	
	var bv = _get_board_view()
	if bv:
		bv.setup_level(level_id)
	
	var lm = _lm()
	var layout_name = BoardLayout.get_layout_by_id(level_id).name
	var l_lbl = level_label if level_label != null else get_node_or_null("TopBar/HBox/LevelTitle") as Label
	if l_lbl:
		var prefix = lm.format_text("LEVEL_LABEL", [level_id]) if lm else "Level %d" % level_id
		l_lbl.text = "%s: %s" % [prefix, layout_name]
	var t_lbl = timer_label if timer_label != null else get_node_or_null("TopBar/HBox/TimerLabel") as Label
	if t_lbl:
		t_lbl.text = "00:00"
		
	_update_localized_strings()

func _update_localized_strings() -> void:
	var lm = _lm()
	if not lm:
		return
		
	var p_btn = pause_btn if pause_btn != null else get_node_or_null("TopBar/HBox/PauseBtn") as Button
	if p_btn: p_btn.text = lm.get_text("HUD_PAUSE", "⏸ Menu")
	
	var u_btn = undo_btn if undo_btn != null else get_node_or_null("BottomBar/HBox/UndoBtn") as Button
	if u_btn: u_btn.text = lm.get_text("HUD_UNDO", "↶ Undo")
	
	var h_btn = hint_btn if hint_btn != null else get_node_or_null("BottomBar/HBox/HintBtn") as Button
	if h_btn: h_btn.text = lm.get_text("HUD_HINT", "💡 Hint")
	
	var s_btn = shuffle_btn if shuffle_btn != null else get_node_or_null("BottomBar/HBox/ShuffleBtn") as Button
	if s_btn: s_btn.text = lm.get_text("HUD_SHUFFLE", "🔀 Shuffle")
	
	var r_btn = restart_btn if restart_btn != null else get_node_or_null("BottomBar/HBox/RestartBtn") as Button
	if r_btn: r_btn.text = lm.get_text("HUD_RESTART", "🔄 Restart")
	
	# Pause Modal
	var pt = get_node_or_null("Modals/PauseModal/VBox/Title") as Label
	if pt: pt.text = lm.get_text("PAUSE_TITLE", "Game Paused")
	var res_btn = get_node_or_null("Modals/PauseModal/VBox/ResumeBtn") as Button
	if res_btn: res_btn.text = lm.get_text("BTN_RESUME", "▶ Resume")
	var rst_btn = get_node_or_null("Modals/PauseModal/VBox/RestartLevelBtn") as Button
	if rst_btn: rst_btn.text = lm.get_text("BTN_RESTART_LEVEL", "🔄 Restart Level")
	var guide_btn = get_node_or_null("Modals/PauseModal/VBox/GuideBtn") as Button
	if guide_btn: guide_btn.text = lm.get_text("BTN_HOW_TO_PLAY", "📖 Tile Guide & Rules")
	var p_menu_btn = get_node_or_null("Modals/PauseModal/VBox/MenuBtn") as Button
	if p_menu_btn: p_menu_btn.text = lm.get_text("BTN_RETURN_MENU", "🏠 Return to Menu")
	
	# Victory Modal
	var vt = get_node_or_null("Modals/VictoryModal/VBox/Title") as Label
	if vt: vt.text = lm.get_text("VICTORY_TITLE", "🌸 Garden Cleared! 🌸")
	var nxt_btn = get_node_or_null("Modals/VictoryModal/VBox/NextLevelBtn") as Button
	if nxt_btn: nxt_btn.text = lm.get_text("BTN_NEXT_LEVEL", "Next Level ▶")
	var v_menu_btn = get_node_or_null("Modals/VictoryModal/VBox/VicMenuBtn") as Button
	if v_menu_btn: v_menu_btn.text = lm.get_text("BTN_RETURN_MENU", "🏠 Return to Menu")
	
	# No Moves Modal
	var nmt = get_node_or_null("Modals/NoMovesModal/VBox/Title") as Label
	if nmt: nmt.text = lm.get_text("NO_MOVES_TITLE", "No Moves Remaining")
	var nmd = get_node_or_null("Modals/NoMovesModal/VBox/Desc") as Label
	if nmd: nmd.text = lm.get_text("NO_MOVES_DESC")
	var smb = get_node_or_null("Modals/NoMovesModal/VBox/ShuffleModalBtn") as Button
	if smb: smb.text = lm.get_text("BTN_SHUFFLE_BOARD", "🔀 Shuffle Board")
	var umb = get_node_or_null("Modals/NoMovesModal/VBox/UndoModalBtn") as Button
	if umb: umb.text = lm.get_text("BTN_UNDO_MOVE", "↶ Undo Move")
	
	# Counters
	var p_lbl = pairs_label if pairs_label != null else get_node_or_null("TopBar/HBox/PairsLabel") as Label
	if p_lbl:
		p_lbl.text = lm.format_text("HUD_PAIRS_LEFT", [remaining_pairs])
		
	var m_lbl = moves_label if moves_label != null else get_node_or_null("TopBar/HBox/MovesLabel") as Label
	if m_lbl:
		m_lbl.text = lm.format_text("HUD_MOVES", [moves_count])

func _on_language_changed_signal(_new_code: String) -> void:
	_update_localized_strings()
	var lm = _lm()
	var layout_name = BoardLayout.get_layout_by_id(current_level_id).name
	var l_lbl = level_label if level_label != null else get_node_or_null("TopBar/HBox/LevelTitle") as Label
	if l_lbl:
		var prefix = lm.format_text("LEVEL_LABEL", [current_level_id]) if lm else "Level %d" % current_level_id
		l_lbl.text = "%s: %s" % [prefix, layout_name]

func _on_pairs_changed(remaining: int) -> void:
	remaining_pairs = remaining
	var lm = _lm()
	var p_lbl = pairs_label if pairs_label != null else get_node_or_null("TopBar/HBox/PairsLabel") as Label
	if p_lbl:
		if lm:
			p_lbl.text = lm.format_text("HUD_PAIRS_LEFT", [remaining])
		else:
			p_lbl.text = "%d Pairs Left" % remaining

func _on_move_made(moves: int) -> void:
	moves_count = moves
	var lm = _lm()
	var m_lbl = moves_label if moves_label != null else get_node_or_null("TopBar/HBox/MovesLabel") as Label
	if m_lbl:
		if lm:
			m_lbl.text = lm.format_text("HUD_MOVES", [moves])
		else:
			m_lbl.text = "Moves: %d" % moves

func _on_board_cleared() -> void:
	is_game_active = false
	var minutes = int(elapsed_time) / 60
	var seconds = int(elapsed_time) % 60
	var vt_lbl = victory_time_label if victory_time_label != null else get_node_or_null("Modals/VictoryModal/VBox/StatsBox/TimeVal") as Label
	if vt_lbl: vt_lbl.text = "%02d:%02d" % [minutes, seconds]
	var vm_lbl = victory_moves_label if victory_moves_label != null else get_node_or_null("Modals/VictoryModal/VBox/StatsBox/MovesVal") as Label
	if vm_lbl: vm_lbl.text = str(moves_count)
	
	var stars = 3
	if elapsed_time > 300:
		stars = 2
	if elapsed_time > 600:
		stars = 1
	var s_lbl = star_label if star_label != null else get_node_or_null("Modals/VictoryModal/VBox/StarLabel") as Label
	if s_lbl: s_lbl.text = "★".repeat(stars) + "☆".repeat(3 - stars)
	
	var sm = _sm()
	var bv = _get_board_view()
	if sm and bv:
		sm.record_level_completion(bv.current_level_id, elapsed_time, moves_count, stars)
		
	var v_modal = _get_modal("Modals/VictoryModal")
	if v_modal:
		_show_modal(v_modal)
		v_modal.modulate.a = 0.0
		var tw = create_tween()
		tw.tween_property(v_modal, "modulate:a", 1.0, 0.3)

func _on_no_moves_left() -> void:
	var am = _am()
	if am:
		am.play_sfx("tile_invalid")
	var n_modal = _get_modal("Modals/NoMovesModal")
	if n_modal:
		_show_modal(n_modal)
		n_modal.modulate.a = 0.0
		var tw = create_tween()
		tw.tween_property(n_modal, "modulate:a", 1.0, 0.25)

# --- Modal Management ---

func _show_modal(modal: Control) -> void:
	var backdrop = get_node_or_null("Modals/ModalBackdrop") as Control
	if backdrop:
		backdrop.show()
	if modal:
		modal.show()
	var bv = _get_board_view()
	if bv:
		bv.is_interactive = false

func _hide_modal(modal: Control) -> void:
	if modal:
		modal.hide()
	var p_modal = _get_modal("Modals/PauseModal")
	var v_modal = _get_modal("Modals/VictoryModal")
	var n_modal = _get_modal("Modals/NoMovesModal")
	var t_modal = _get_modal("Modals/TutorialModal")
	var any_open = (p_modal and p_modal.visible) or (v_modal and v_modal.visible) or (n_modal and n_modal.visible) or (t_modal and t_modal.visible)
	if not any_open:
		var backdrop = get_node_or_null("Modals/ModalBackdrop") as Control
		if backdrop:
			backdrop.hide()
		var bv = _get_board_view()
		if bv and is_game_active:
			bv.is_interactive = true

func _on_tutorial_closed() -> void:
	var t_modal = _get_modal("Modals/TutorialModal")
	_hide_modal(t_modal)

# --- Button Handlers ---

func _on_undo_pressed() -> void:
	var am = _am()
	if am:
		am.play_sfx("button_click")
	var bv = _get_board_view()
	if bv:
		bv.undo_move()
	var n_modal = _get_modal("Modals/NoMovesModal")
	if n_modal and n_modal.visible:
		_hide_modal(n_modal)

func _on_hint_pressed() -> void:
	var am = _am()
	if am:
		am.play_sfx("button_click")
	var bv = _get_board_view()
	if bv and not bv.request_hint():
		var n_modal = _get_modal("Modals/NoMovesModal")
		if n_modal:
			_show_modal(n_modal)

func _on_shuffle_pressed() -> void:
	var am = _am()
	if am:
		am.play_sfx("button_click")
	var bv = _get_board_view()
	if bv:
		bv.shuffle_remaining_tiles()
	var n_modal = _get_modal("Modals/NoMovesModal")
	if n_modal:
		_hide_modal(n_modal)

func _on_restart_pressed() -> void:
	var am = _am()
	if am:
		am.play_sfx("button_click")
	elapsed_time = 0.0
	moves_count = 0
	is_game_active = true
	var p_modal = _get_modal("Modals/PauseModal")
	if p_modal: _hide_modal(p_modal)
	var v_modal = _get_modal("Modals/VictoryModal")
	if v_modal: _hide_modal(v_modal)
	var n_modal = _get_modal("Modals/NoMovesModal")
	if n_modal: _hide_modal(n_modal)
	var t_modal = _get_modal("Modals/TutorialModal")
	if t_modal: _hide_modal(t_modal)
	var backdrop = get_node_or_null("Modals/ModalBackdrop") as Control
	if backdrop: backdrop.hide()
	var t_lbl = timer_label if timer_label != null else get_node_or_null("TopBar/HBox/TimerLabel") as Label
	if t_lbl:
		t_lbl.text = "00:00"
	var bv = _get_board_view()
	if bv:
		bv.restart_level()
		bv.is_interactive = true

func _on_pause_pressed() -> void:
	var am = _am()
	if am:
		am.play_sfx("button_click")
	is_game_active = false
	var p_modal = _get_modal("Modals/PauseModal")
	if p_modal:
		_show_modal(p_modal)

func _on_resume_pressed() -> void:
	var am = _am()
	if am:
		am.play_sfx("button_click")
	is_game_active = true
	var p_modal = _get_modal("Modals/PauseModal")
	if p_modal:
		_hide_modal(p_modal)

func _on_guide_pressed() -> void:
	var am = _am()
	if am:
		am.play_sfx("button_click")
	var t_modal = _get_modal("Modals/TutorialModal")
	if t_modal:
		_show_modal(t_modal)
		t_modal.modulate.a = 0.0
		var tw = create_tween()
		tw.tween_property(t_modal, "modulate:a", 1.0, 0.2)

func _on_next_level_pressed() -> void:
	var am = _am()
	if am:
		am.play_sfx("button_click")
	var bv = _get_board_view()
	var next_id = (bv.current_level_id + 1) if bv else 2
	var gm = _gm()
	if gm:
		gm.active_level_id = next_id
	start_level(next_id)

func _on_menu_pressed() -> void:
	var am = _am()
	if am:
		am.play_sfx("button_click")
	var gm = _gm()
	if gm:
		gm.return_to_main_menu()
	else:
		get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
