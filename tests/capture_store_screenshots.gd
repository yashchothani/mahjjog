extends SceneTree

var step = 0

func _init():
	print("Starting store screenshot capture pipeline...")
	
	# Bootstrap singletons if running standalone
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
	
	DirAccess.make_dir_recursive_absolute("res://store_assets/")
	_run_pipeline()

func _run_pipeline():
	# Step 1: Main Menu
	print("Capturing 1: Main Menu...")
	var scn1 = load("res://scenes/menus/main_menu.tscn").instantiate()
	root.add_child(scn1)
	await _wait_frames(15)
	_save_viewport("res://store_assets/screenshot_1_main_menu.png")
	root.remove_child(scn1)
	scn1.queue_free()
	await _wait_frames(5)

	# Step 2: Level Select
	print("Capturing 2: Level Select...")
	var scn2 = load("res://scenes/menus/level_select.tscn").instantiate()
	root.add_child(scn2)
	await _wait_frames(15)
	_save_viewport("res://store_assets/screenshot_2_level_select.png")
	root.remove_child(scn2)
	scn2.queue_free()
	await _wait_frames(5)

	# Step 3: Gameplay
	print("Capturing 3: Gameplay...")
	var scn3 = load("res://scenes/gameplay/gameplay.tscn").instantiate()
	root.add_child(scn3)
	if scn3.has_method("start_level"):
		scn3.start_level(1)
	await _wait_frames(25)
	_save_viewport("res://store_assets/screenshot_3_gameplay.png")
	
	# Step 4: Victory Modal
	print("Capturing 4: Victory Modal...")
	if scn3.has_method("_on_board_cleared"):
		scn3._on_board_cleared()
	await _wait_frames(30)
	_save_viewport("res://store_assets/screenshot_4_victory.png")
	root.remove_child(scn3)
	scn3.queue_free()
	await _wait_frames(5)

	# Step 5: Profile Modal
	print("Capturing 5: Profile Modal...")
	var scn5 = load("res://scenes/menus/main_menu.tscn").instantiate()
	root.add_child(scn5)
	var profile = load("res://scenes/dialogs/profile_modal.tscn").instantiate()
	scn5.add_child(profile)
	await _wait_frames(15)
	_save_viewport("res://store_assets/screenshot_5_profile_modal.png")
	root.remove_child(scn5)
	scn5.queue_free()
	await _wait_frames(5)

	# Step 6: 7-Day Streak Journey Modal
	print("Capturing 6: Streak Journey...")
	var scn6 = load("res://scenes/menus/main_menu.tscn").instantiate()
	root.add_child(scn6)
	var streak = load("res://scenes/dialogs/streak_modal.tscn").instantiate()
	scn6.add_child(streak)
	await _wait_frames(15)
	_save_viewport("res://store_assets/screenshot_6_streak_journey.png")
	root.remove_child(scn6)
	scn6.queue_free()
	await _wait_frames(5)

	print("ALL STORE SCREENSHOTS SUCCESSFULLY CAPTURED!")
	quit(0)

func _wait_frames(count: int):
	for i in range(count):
		await process_frame

func _save_viewport(path: String):
	var vp = root.get_viewport()
	var img = vp.get_texture().get_image()
	if img:
		img.resize(1920, 1080, Image.INTERPOLATE_LANCZOS)
		var err = img.save_png(path)
		print("  -> Saved %s (Result: %d, Size: %dx%d)" % [path, err, img.get_width(), img.get_height()])
	else:
		push_error("Failed to get viewport image!")
