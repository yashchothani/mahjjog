class_name BoardView
extends Control

## Coordinates the 2D layout, input processing, undo stack, and state updates for the Mahjong board.

signal pairs_changed(remaining_pairs: int)
signal move_made(moves_count: int)
signal board_cleared
signal no_moves_left

const MahjongTileData = preload("res://scripts/data/mahjong_tile_data.gd")
const BoardLayout = preload("res://scripts/board/board_layout.gd")
const BoardGenerator = preload("res://scripts/board/board_generator.gd")
const TileView = preload("res://scripts/board/tile_view.gd")

const STEP_X: float = 28.0
const STEP_Y: float = 37.0
const LAYER_OFFSET_X: float = -4.0
const LAYER_OFFSET_Y: float = -6.0

var active_tiles: Dictionary = {} # Vector3i -> TileView
var initial_tile_map: Dictionary = {} # Vector3i -> MahjongTileData (saved for level restart)
var selected_tile: TileView = null
var undo_stack: Array[Dictionary] = [] # Array of {pos1, data1, pos2, data2}
var moves_count: int = 0
var current_level_id: int = 1
var is_interactive: bool = true
var solution_pairs: Array[Array] = []
var initial_solution_pairs: Array[Array] = []

func _ready() -> void:
	custom_minimum_size = Vector2.ZERO
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_center_board()

func _play_sfx(sound_name: String) -> void:
	var tree = Engine.get_main_loop() as SceneTree
	if tree and tree.root and tree.root.has_node("AudioManager"):
		tree.root.get_node("AudioManager").play_sfx(sound_name)

func setup_level(level_id: int) -> void:
	current_level_id = level_id
	clear_board()
	
	var gen_result = BoardGenerator.generate_level(level_id)
	if not gen_result.success:
		push_error("Failed to generate solvable level %d!" % level_id)
		return
		
	# Save initial layout for restart
	initial_tile_map.clear()
	for pos in gen_result.tile_map.keys():
		initial_tile_map[pos] = MahjongTileData.create_clone(gen_result.tile_map[pos])
		
	solution_pairs = gen_result.solution_pairs.duplicate()
	initial_solution_pairs = gen_result.solution_pairs.duplicate()
	_populate_from_map(gen_result.tile_map)

func restart_level() -> void:
	clear_board()
	if initial_tile_map.is_empty():
		setup_level(current_level_id)
		return
		
	var clone_map: Dictionary = {}
	for pos in initial_tile_map.keys():
		clone_map[pos] = MahjongTileData.create_clone(initial_tile_map[pos])
		
	solution_pairs = initial_solution_pairs.duplicate()
	_populate_from_map(clone_map)

func _populate_from_map(tile_map: Dictionary) -> void:
	# Sort positions by layer z ascending so higher-layer tiles are added on top in tree order
	var sorted_positions = tile_map.keys()
	sorted_positions.sort_custom(func(a, b):
		if a.z != b.z:
			return a.z < b.z # Bottom layers first, top layers last
		if a.y != b.y:
			return a.y < b.y
		return a.x < b.x
	)
	
	for pos in sorted_positions:
		var data = tile_map[pos]
		_spawn_tile(pos, data)
		
	_center_board()
	update_all_tile_states()
	
	moves_count = 0
	undo_stack.clear()
	selected_tile = null
	is_interactive = true
	
	move_made.emit(moves_count)
	pairs_changed.emit(active_tiles.size() / 2)

func _spawn_tile(pos: Vector3i, data: MahjongTileData) -> TileView:
	var tile = TileView.new(pos, data)
	tile.tile_clicked.connect(_on_tile_clicked)
	add_child(tile)
	active_tiles[pos] = tile
	return tile

func _sort_children_by_layer() -> void:
	var children = get_children()
	children.sort_custom(func(a, b):
		if not (a is TileView) or not (b is TileView):
			return false
		if a.grid_pos.z != b.grid_pos.z:
			return a.grid_pos.z < b.grid_pos.z
		if a.grid_pos.y != b.grid_pos.y:
			return a.grid_pos.y < b.grid_pos.y
		return a.grid_pos.x < b.grid_pos.x
	)
	for i in range(children.size()):
		move_child(children[i], i)

func _center_board() -> void:
	if active_tiles.is_empty():
		return
		
	var min_x = 999999.0
	var max_x = -999999.0
	var min_y = 999999.0
	var max_y = -999999.0
	
	for pos in active_tiles.keys():
		var px = pos.x * STEP_X + pos.z * LAYER_OFFSET_X
		var py = pos.y * STEP_Y + pos.z * LAYER_OFFSET_Y
		min_x = min(min_x, px)
		max_x = max(max_x, px + TileView.TILE_WIDTH)
		min_y = min(min_y, py)
		max_y = max(max_y, py + TileView.TILE_HEIGHT)
		
	var board_width = max_x - min_x
	var board_height = max_y - min_y
	
	# Determine scale factor if board exceeds viewable area
	var available_w = max(100.0, size.x - 40.0)
	var available_h = max(100.0, size.y - 40.0)
	var fit_scale = min(1.0, min(available_w / board_width, available_h / board_height))
	
	var target_center_x = size.x * 0.5
	var target_center_y = size.y * 0.5
	var offset_x = target_center_x - ((board_width * fit_scale) * 0.5 + min_x * fit_scale)
	var offset_y = target_center_y - ((board_height * fit_scale) * 0.5 + min_y * fit_scale)
	
	for pos in active_tiles.keys():
		var tile = active_tiles[pos]
		var px = (pos.x * STEP_X + pos.z * LAYER_OFFSET_X) * fit_scale + offset_x
		var py = (pos.y * STEP_Y + pos.z * LAYER_OFFSET_Y) * fit_scale + offset_y
		tile.position = Vector2(px, py)
		tile.set_base_scale(fit_scale)
		tile.z_index = pos.z * 10

func update_all_tile_states() -> void:
	var remaining_positions: Array[Vector3i] = []
	for p in active_tiles.keys():
		remaining_positions.append(p)
		
	for pos in active_tiles.keys():
		var tile = active_tiles[pos]
		tile.is_free = BoardLayout.is_tile_free(pos, remaining_positions)
		tile.update_state()

func _on_tile_clicked(tile: TileView) -> void:
	if not is_interactive:
		return
		
	_clear_hints()
	
	if not tile.is_free:
		tile.play_invalid_shake()
		_play_sfx("tile_invalid")
		return
		
	if selected_tile == null:
		selected_tile = tile
		tile.is_selected = true
		tile.update_state()
		_play_sfx("tile_select")
		return
		
	if selected_tile == tile:
		selected_tile.is_selected = false
		selected_tile.update_state()
		selected_tile = null
		_play_sfx("tile_click")
		return
		
	if MahjongTileData.tiles_match(selected_tile.tile_data, tile.tile_data):
		_handle_valid_match(selected_tile, tile)
	else:
		selected_tile.is_selected = false
		selected_tile.update_state()
		
		selected_tile = tile
		tile.is_selected = true
		tile.update_state()
		_play_sfx("tile_select")

func _handle_valid_match(t1: TileView, t2: TileView) -> void:
	undo_stack.append({
		"pos1": t1.grid_pos,
		"data1": t1.tile_data,
		"pos2": t2.grid_pos,
		"data2": t2.tile_data
	})
	
	active_tiles.erase(t1.grid_pos)
	active_tiles.erase(t2.grid_pos)
	selected_tile = null
	
	moves_count += 1
	move_made.emit(moves_count)
	
	_play_sfx("tile_match")
	t1.play_match_animation()
	t2.play_match_animation()
	
	update_all_tile_states()
	pairs_changed.emit(active_tiles.size() / 2)
	
	if active_tiles.is_empty():
		is_interactive = false
		_play_sfx("victory")
		board_cleared.emit()
	else:
		_check_moves_remaining()

func _check_moves_remaining() -> void:
	if find_hint_pair().is_empty():
		no_moves_left.emit()

func find_hint_pair() -> Array[TileView]:
	# 1. Prefer pairs from the proven solution path to guarantee deadlock-free progression
	for pair in solution_pairs:
		var p1: Vector3i = pair[0]
		var p2: Vector3i = pair[1]
		if active_tiles.has(p1) and active_tiles.has(p2):
			var t1: TileView = active_tiles[p1]
			var t2: TileView = active_tiles[p2]
			if t1.is_free and t2.is_free:
				return [t1, t2]

	# 2. General fallback: search any matching free tiles
	var free_tiles: Array[TileView] = []
	for tile in active_tiles.values():
		if tile.is_free:
			free_tiles.append(tile)
			
	for i in range(free_tiles.size()):
		var t1 = free_tiles[i]
		for j in range(i + 1, free_tiles.size()):
			var t2 = free_tiles[j]
			if MahjongTileData.tiles_match(t1.tile_data, t2.tile_data):
				return [t1, t2]
	return []

func request_hint() -> bool:
	_clear_hints()
	var pair = find_hint_pair()
	if pair.size() == 2:
		pair[0].is_hinted = true
		pair[1].is_hinted = true
		pair[0].update_state()
		pair[1].update_state()
		_play_sfx("hint")
		return true
	return false

func _clear_hints() -> void:
	for tile in active_tiles.values():
		if tile.is_hinted:
			tile.is_hinted = false
			tile.update_state()

func undo_move() -> bool:
	if undo_stack.is_empty():
		return false
		
	var last_move = undo_stack.pop_back()
	if selected_tile:
		selected_tile.is_selected = false
		selected_tile.update_state()
		selected_tile = null
		
	_clear_hints()
	
	_spawn_tile(last_move["pos1"], last_move["data1"])
	_spawn_tile(last_move["pos2"], last_move["data2"])
	
	_sort_children_by_layer()
	_center_board()
	update_all_tile_states()
	
	moves_count = max(0, moves_count - 1)
	move_made.emit(moves_count)
	pairs_changed.emit(active_tiles.size() / 2)
	
	_play_sfx("undo")
	return true

func shuffle_remaining_tiles() -> bool:
	if active_tiles.size() < 2:
		return false
		
	_clear_hints()
	if selected_tile:
		selected_tile.is_selected = false
		selected_tile.update_state()
		selected_tile = null
		
	var positions: Array[Vector3i] = []
	var datas: Array[MahjongTileData] = []
	for pos in active_tiles.keys():
		positions.append(pos)
		datas.append(active_tiles[pos].tile_data)
		
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	for i in range(datas.size() - 1, 0, -1):
		var j = rng.randi_range(0, i)
		var tmp = datas[i]
		datas[i] = datas[j]
		datas[j] = tmp
		
	for i in range(positions.size()):
		var p = positions[i]
		active_tiles[p].tile_data = datas[i]
		active_tiles[p]._build_visuals()
		
	update_all_tile_states()
	_play_sfx("shuffle")
	return true

func clear_board() -> void:
	for tile in active_tiles.values():
		if is_instance_valid(tile):
			tile.queue_free()
	for child in get_children():
		if child is TileView and is_instance_valid(child):
			child.queue_free()
	active_tiles.clear()
	undo_stack.clear()
	solution_pairs.clear()
	selected_tile = null
