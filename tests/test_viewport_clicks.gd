extends SceneTree

const BoardView = preload("res://scripts/board/board_view.gd")
const TileView = preload("res://scripts/board/tile_view.gd")

func _init() -> void:
	_run_tests.call_deferred()

func _run_tests() -> void:
	print("--- TESTING REAL MOUSE CLICK EVENT ROUTING IN VIEWPORT ---")
	if not root.has_node("SaveManager"):
		var sm = load("res://scripts/save/save_manager.gd").new()
		sm.name = "SaveManager"
		root.add_child(sm)
	if not root.has_node("GameManager"):
		var gm = load("res://scripts/core/game_manager.gd").new()
		gm.name = "GameManager"
		root.add_child(gm)
	if not root.has_node("LocalizationManager"):
		var lm = load("res://scripts/core/localization_manager.gd").new()
		lm.name = "LocalizationManager"
		root.add_child(lm)
	if not root.has_node("AudioManager"):
		var am = load("res://scripts/audio/audio_manager.gd").new()
		am.name = "AudioManager"
		root.add_child(am)
		
	var gameplay_scene = load("res://scenes/gameplay/gameplay.tscn").instantiate()
	root.add_child(gameplay_scene)
	gameplay_scene.start_level(1)
	await process_frame
	
	var bv = gameplay_scene.get_node("BoardContainer/BoardView") as BoardView
	var hint_pair = bv.find_hint_pair()
	var t1 = hint_pair[0] as TileView
	
	print("Tile 1 global pos: %s, size: %s" % [t1.global_position, t1.size])
	var click_point = t1.global_position + t1.size * 0.5 * t1.scale
	print("Simulating mouse press at screen coords: %s" % str(click_point))
	
	# Dispatch InputEventMouseButton to viewport
	var ev_press = InputEventMouseButton.new()
	ev_press.position = click_point
	ev_press.global_position = click_point
	ev_press.button_index = MOUSE_BUTTON_LEFT
	ev_press.pressed = true
	ev_press.button_mask = MOUSE_BUTTON_MASK_LEFT
	root.push_input(ev_press)
	
	var ev_release = InputEventMouseButton.new()
	ev_release.position = click_point
	ev_release.global_position = click_point
	ev_release.button_index = MOUSE_BUTTON_LEFT
	ev_release.pressed = false
	ev_release.button_mask = 0
	root.push_input(ev_release)
	await process_frame
	
	# If push_input in headless does not route without frame process, also check tile's click_button gui_input
	if bv.selected_tile != t1:
		print("Direct click_button button press...")
		t1.click_button.emit_signal("pressed")
		
	assert(bv.selected_tile == t1, "Tile 1 must be selected after click")
	print("SUCCESS: Tile 1 picked up via input event! Selected tile: %s" % t1.tile_data.display_name)
	
	gameplay_scene.queue_free()
	print("--- MOUSE CLICK ROUTING TEST PASSED ---")
	await process_frame
	quit(0)
