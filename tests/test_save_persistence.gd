extends SceneTree

const SaveManager = preload("res://scripts/save/save_manager.gd")

func _init() -> void:
	_run_standalone.call_deferred()

func _run_standalone() -> void:
	run_tests(self)
	await process_frame
	quit(0)

static func run_tests(tree: SceneTree) -> void:
	print("====================================================")
	print("       TESTING SAVE PERSISTENCE & RECOVERY          ")
	print("====================================================")
	
	var sm = SaveManager.new()
	tree.root.add_child(sm)
	
	# Test 1: Initial Default State
	print("[SAVE TEST 1] Initial default state...")
	sm.reset_to_defaults()
	assert(sm.is_level_unlocked(1) == true, "Level 1 must be unlocked by default")
	assert(sm.is_level_unlocked(2) == false, "Level 2 must be locked initially")
	assert(sm.get_level_stars(1) == 0, "Level 1 starts with 0 stars")
	assert(sm.get_setting("dim_blocked_tiles") == true, "dim_blocked_tiles default is true")
	assert(sm.get_setting("language") == "en", "language default is en")
	print("  -> Passed initial defaults!")
	
	# Test 2: Recording Level Completion
	print("[SAVE TEST 2] Recording level completions...")
	sm.record_level_completion(1, 45.2, 18, 3)
	assert(sm.is_level_unlocked(2) == true, "Level 2 must unlock after completing Level 1")
	assert(sm.get_level_stars(1) == 3, "Level 1 must have 3 stars")
	
	# Complete with slower time, ensure best time is preserved
	sm.record_level_completion(1, 60.0, 20, 2)
	var rec = sm.progress["completed_levels"]["1"]
	assert(rec["best_time"] <= 45.2, "Best time must be preserved")
	assert(rec["stars"] == 3, "Best stars must be preserved")
	print("  -> Passed record progression and best stats retention!")
	
	# Test 3: Reloading from Disk
	print("[SAVE TEST 3] Reloading save file from disk...")
	var sm2 = SaveManager.new()
	tree.root.add_child(sm2)
	assert(sm2.is_level_unlocked(2) == true, "Persisted unlocked level 2 must reload")
	assert(sm2.get_level_stars(1) == 3, "Persisted stars must reload")
	print("  -> Passed disk reload verification!")
	
	# Test 4: Corrupted JSON recovery
	print("[SAVE TEST 4] Corrupted JSON file recovery...")
	var file = FileAccess.open(SaveManager.SAVE_PATH, FileAccess.WRITE)
	file.store_string("THIS IS NOT JSON {{{ corrupt")
	file.close()
	
	var sm3 = SaveManager.new()
	tree.root.add_child(sm3)
	assert(sm3.settings.has("music_volume"), "Corrupted file must safely fallback to valid defaults")
	assert(sm3.progress.has("max_unlocked_level"), "Corrupted file must safely initialize progress defaults")
	print("  -> Passed corrupted JSON graceful fallback!")
	
	# Cleanup
	tree.root.remove_child(sm)
	tree.root.remove_child(sm2)
	tree.root.remove_child(sm3)
	sm.free()
	sm2.free()
	sm3.free()
	print("====================================================")
	print(" SAVE PERSISTENCE & CORRUPTION RECOVERY: 100% PASS  ")
	print("====================================================")
