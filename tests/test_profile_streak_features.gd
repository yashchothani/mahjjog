extends SceneTree

## Unit & Integration test for Player Profile, Settings Toggles, 7-Day Streak, and Victory Percentile Ranking.

const SaveManager = preload("res://scripts/save/save_manager.gd")
const ProfileModal = preload("res://scenes/dialogs/profile_modal.tscn")
const StreakModal = preload("res://scenes/dialogs/streak_modal.tscn")
const GameplayScene = preload("res://scenes/gameplay/gameplay.tscn")
const SettingsScene = preload("res://scenes/settings/settings.tscn")

func _init() -> void:
	_run_standalone.call_deferred()

func _run_standalone() -> void:
	run_tests(self)
	await process_frame
	await process_frame
	quit(0)

static func run_tests(tree: SceneTree) -> void:
	print("====================================================")
	print("    TESTING PROFILE, STREAK & PERCENTILE FEATURES   ")
	print("====================================================")
	
	var created_nodes: Array = []
	if not tree.root.has_node("SaveManager"):
		var sm_inst = SaveManager.new()
		sm_inst.name = "SaveManager"
		tree.root.add_child(sm_inst)
		created_nodes.append(sm_inst)
	if not tree.root.has_node("LocalizationManager"):
		var lm_inst = load("res://scripts/core/localization_manager.gd").new()
		lm_inst.name = "LocalizationManager"
		tree.root.add_child(lm_inst)
		created_nodes.append(lm_inst)
		
	var sm = tree.root.get_node("SaveManager") as SaveManager
	sm.set_setting("sfx_muted", true)
	
	# Test 1: Player Profile Persistence
	print("[TEST 1] Player Profile Persistence...")
	sm.set_player_name("Master Bamboo")
	assert(sm.get_player_name() == "Master Bamboo", "Player name must be persisted")
	sm.set_avatar_id(3) # Lotus Maiden
	assert(sm.get_avatar_id() == 3, "Avatar ID must be persisted")
	sm.set_avatar_frame("lotus")
	assert(sm.get_avatar_frame() == "lotus", "Avatar frame must be persisted")
	print("  -> Profile name, avatar, and frame persisted successfully!")
	
	# Test 2: Percentile Ranking Calculation
	print("[TEST 2] Victory Percentile Ranking...")
	var p3 = sm.calculate_percentile(45.0, 17, 3)
	assert(p3["percentile"] >= 90.0 and p3["percentile"] <= 99.0, "3 stars must yield >= 90% percentile")
	print("  -> 3 Stars Percentile: %s (%s - %s)" % [p3["percentile_str"], p3["title"], p3["desc"]])
	
	var p2 = sm.calculate_percentile(120.0, 24, 2)
	assert(p2["percentile"] >= 75.0 and p2["percentile"] < 90.0, "2 stars must yield 75-89% percentile")
	print("  -> 2 Stars Percentile: %s (%s - %s)" % [p2["percentile_str"], p2["title"], p2["desc"]])
	
	# Test 3: Milestone Chest Info
	print("[TEST 3] Milestone Level Chest Progress...")
	var c1 = sm.get_chest_milestone_info(1)
	assert(c1["current"] == 1 and c1["goal"] == 5 and c1["is_milestone"] == false, "Level 1 must be 1/5")
	var c5 = sm.get_chest_milestone_info(5)
	assert(c5["current"] == 5 and c5["goal"] == 5 and c5["is_milestone"] == true, "Level 5 must be milestone chest!")
	print("  -> Milestone chest progress verified (1/5 to 5/5 ready)!")
	
	# Test 4: 7-Day Streak Logic
	print("[TEST 4] 7-Day Streak & Daily Reward...")
	sm.progress["daily_streak"] = 0
	sm.progress["last_streak_claimed_date"] = ""
	var hints_before = sm.progress.get("hints_remaining", 5)
	
	var s_res = sm.claim_daily_streak()
	assert(s_res["success"] == true, "First claim must succeed")
	assert(s_res["streak"] == 1, "Streak must now be 1")
	assert(s_res["hints_awarded"] == 2, "Daily reward must grant 2 hints")
	assert(sm.progress["hints_remaining"] == hints_before + 2, "Hints count must increase by 2")
	
	# Claiming again on same day
	var s_res2 = sm.claim_daily_streak()
	assert(s_res2["success"] == false, "Same day claim must not duplicate reward")
	print("  -> Daily streak claim and idempotent protection verified!")
	
	# Test 5: ProfileModal Instantiation & Interaction
	print("[TEST 5] ProfileModal UI & Tabs...")
	var prof_modal = ProfileModal.instantiate()
	tree.root.add_child(prof_modal)
	assert(prof_modal.avatar_grid.get_child_count() == 8, "Avatar grid must have 8 avatars")
	assert(prof_modal.frame_grid.get_child_count() == 4, "Frame grid must have 4 frames")
	
	# Select tab 1 (Frame)
	prof_modal._select_tab(1)
	assert(prof_modal.current_tab == 1, "Frame tab must be selected")
	prof_modal._select_tab(0)
	assert(prof_modal.current_tab == 0, "Avatar tab must be selected")
	
	tree.root.remove_child(prof_modal)
	prof_modal.free()
	print("  -> ProfileModal verified!")
	
	# Test 6: StreakModal Instantiation & Track Nodes
	print("[TEST 6] StreakModal UI & 7-Day Nodes...")
	var stk_modal = StreakModal.instantiate()
	tree.root.add_child(stk_modal)
	assert(stk_modal.track_container.get_child_count() == 7, "StreakModal must display 7 milestone nodes")
	tree.root.remove_child(stk_modal)
	stk_modal.free()
	print("  -> StreakModal verified!")
	
	# Test 7: Upgraded Settings Quick Toggles
	print("[TEST 7] Settings Quick Audio Toggles...")
	var settings_node = SettingsScene.instantiate()
	tree.root.add_child(settings_node)
	
	# Test Music Toggle
	var m_muted_before = sm.get_setting("music_muted", false)
	settings_node._on_music_toggle_pressed()
	assert(sm.get_setting("music_muted") == (not m_muted_before), "Music toggle must flip state")
	
	# Test SFX Toggle
	var sfx_muted_before = sm.get_setting("sfx_muted", true)
	settings_node._on_sfx_toggle_pressed()
	assert(sm.get_setting("sfx_muted") == (not sfx_muted_before), "SFX toggle must flip state")
	sm.set_setting("sfx_muted", true)
	
	# Test Haptics Toggle
	var haptics_before = sm.get_setting("haptics_enabled", true)
	settings_node._on_haptic_toggle_pressed()
	assert(sm.get_setting("haptics_enabled") == (not haptics_before), "Haptic toggle must flip state")
	
	tree.root.remove_child(settings_node)
	settings_node.free()
	print("  -> Settings quick audio toggles verified!")
	
	for n in created_nodes:
		if is_instance_valid(n):
			tree.root.remove_child(n)
			n.free()
			
	if tree.root.has_node("AudioManager"):
		var am = tree.root.get_node("AudioManager")
		am.stop_all()
	if tree.root.has_node("SaveManager"):
		tree.root.get_node("SaveManager").set_setting("sfx_muted", true)
		
	print("====================================================")
	print(" ALL PROFILE, STREAK & PERCENTILE TESTS PASSED 100% ")
	print("====================================================")
