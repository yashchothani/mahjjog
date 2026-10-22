extends Control

## Controls HUD, timer, level state, and modals in the gameplay scene.

@onready var board_view: BoardView = $BoardContainer/BoardView
@onready var level_label: Label = $TopBar/HBox/LevelTitle
@onready var timer_label: Label = $TopBar/HBox/TimerLabel
@onready var pairs_label: Label = $TopBar/HBox/PairsLabel
@onready var moves_label: Label = $TopBar/HBox/MovesLabel

# Dialogs
@onready var pause_modal: PanelContainer = $Modals/PauseModal
@onready var victory_modal: PanelContainer = $Modals/VictoryModal
@onready var no_moves_modal: PanelContainer = $Modals/NoMovesModal

# Victory dialog labels
@onready var victory_time_label: Label = $Modals/VictoryModal/VBox/StatsBox/TimeVal
@onready var victory_moves_label: Label = $Modals/VictoryModal/VBox/StatsBox/MovesVal
@onready var star_label: Label = $Modals/VictoryModal/VBox/StarLabel

var elapsed_time: float = 0.0
var is_game_active: bool = false
var moves_count: int = 0

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
	
	var bv = _get_board_view()
	if bv:
		bv.pairs_changed.connect(_on_pairs_changed)
		bv.move_made.connect(_on_move_made)
		bv.board_cleared.connect(_on_board_cleared)
		bv.no_moves_left.connect(_on_no_moves_left)
	
	var gm = _gm()
	var level_id = gm.active_level_id if gm else 1
	start_level(level_id)

func _process(delta: float) -> void:
	if is_game_active:
		elapsed_time += delta
		var minutes = int(elapsed_time) / 60
		var seconds = int(elapsed_time) % 60
		var t_lbl = timer_label if timer_label != null else get_node_or_null("TopBar/HBox/TimerLabel") as Label
		if t_lbl:
			t_lbl.text = "%02d:%02d" % [minutes, seconds]

func start_level(level_id: int) -> void:
	elapsed_time = 0.0
	moves_count = 0
	is_game_active = true
	
	var p_modal = _get_modal("Modals/PauseModal")
	if p_modal: p_modal.hide()
	var v_modal = _get_modal("Modals/VictoryModal")
	if v_modal: v_modal.hide()
	var n_modal = _get_modal("Modals/NoMovesModal")
	if n_modal: n_modal.hide()
	
	var bv = _get_board_view()
	if bv:
		bv.setup_level(level_id)
	
	var layout_name = BoardLayout.get_layout_by_id(level_id).name
	var l_lbl = level_label if level_label != null else get_node_or_null("TopBar/HBox/LevelTitle") as Label
	if l_lbl:
		l_lbl.text = "Level %d: %s" % [level_id, layout_name]
	var t_lbl = timer_label if timer_label != null else get_node_or_null("TopBar/HBox/TimerLabel") as Label
	if t_lbl:
		t_lbl.text = "00:00"

func _on_pairs_changed(remaining: int) -> void:
	var p_lbl = pairs_label if pairs_label != null else get_node_or_null("TopBar/HBox/PairsLabel") as Label
	if p_lbl:
		p_lbl.text = "%d Pairs Left" % remaining

func _on_move_made(moves: int) -> void:
	moves_count = moves
	var m_lbl = moves_label if moves_label != null else get_node_or_null("TopBar/HBox/MovesLabel") as Label
	if m_lbl:
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
		v_modal.show()
		v_modal.modulate.a = 0.0
		var tw = create_tween()
		tw.tween_property(v_modal, "modulate:a", 1.0, 0.3)

func _on_no_moves_left() -> void:
	var am = _am()
	if am:
		am.play_sfx("tile_invalid")
	var n_modal = _get_modal("Modals/NoMovesModal")
	if n_modal:
		n_modal.show()
		n_modal.modulate.a = 0.0
		var tw = create_tween()
		tw.tween_property(n_modal, "modulate:a", 1.0, 0.25)

# --- Button Handlers ---

func _on_undo_pressed() -> void:
	var am = _am()
	if am:
		am.play_sfx("button_click")
	var bv = _get_board_view()
	if bv:
		bv.undo_move()

func _on_hint_pressed() -> void:
	var am = _am()
	if am:
		am.play_sfx("button_click")
	var bv = _get_board_view()
	if bv and not bv.request_hint():
		var n_modal = _get_modal("Modals/NoMovesModal")
		if n_modal:
			n_modal.show()

func _on_shuffle_pressed() -> void:
	var am = _am()
	if am:
		am.play_sfx("button_click")
	var bv = _get_board_view()
	if bv:
		bv.shuffle_remaining_tiles()
	var n_modal = _get_modal("Modals/NoMovesModal")
	if n_modal:
		n_modal.hide()

func _on_restart_pressed() -> void:
	var am = _am()
	if am:
		am.play_sfx("button_click")
	elapsed_time = 0.0
	moves_count = 0
	is_game_active = true
	var p_modal = _get_modal("Modals/PauseModal")
	if p_modal: p_modal.hide()
	var v_modal = _get_modal("Modals/VictoryModal")
	if v_modal: v_modal.hide()
	var n_modal = _get_modal("Modals/NoMovesModal")
	if n_modal: n_modal.hide()
	var t_lbl = timer_label if timer_label != null else get_node_or_null("TopBar/HBox/TimerLabel") as Label
	if t_lbl:
		t_lbl.text = "00:00"
	var bv = _get_board_view()
	if bv:
		bv.restart_level()

func _on_pause_pressed() -> void:
	var am = _am()
	if am:
		am.play_sfx("button_click")
	is_game_active = false
	var p_modal = _get_modal("Modals/PauseModal")
	if p_modal:
		p_modal.show()

func _on_resume_pressed() -> void:
	var am = _am()
	if am:
		am.play_sfx("button_click")
	var p_modal = _get_modal("Modals/PauseModal")
	if p_modal:
		p_modal.hide()
	is_game_active = true

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
