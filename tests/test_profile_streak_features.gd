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
	await run_tests(self)
	await create_tween().tween_interval(0.1).finished
	await process_frame
	await process_frame
	quit(0)

static func run_tests(tree: SceneTree) -> void:
	print("====================================================")
	print("    TESTING PROFILE, STREAK & PERCENTILE FEATURES   ")
	print("====================================================")
	
	var created_nodes: Array = []
	
	# Bootstrap singletons if running standalone
	if not tree.root.has_node("SaveManager"):
		var sm_boot = load("res://scripts/save/save_manager.gd").new()
		sm_boot.name = "SaveManager"
		tree.root.add_child(sm_boot)
		created_nodes.append(sm_boot)
	if not tree.root.has_node("GameManager"):
		var gm_boot = load("res://scripts/core/game_manager.gd").new()
		gm_boot.name = "GameManager"
		tree.root.add_child(gm_boot)
		created_nodes.append(gm_boot)
	if not tree.root.has_node("LocalizationManager"):
		var lm_boot = load("res://scripts/core/localization_manager.gd").new()
		lm_boot.name = "LocalizationManager"
		tree.root.add_child(lm_boot)
		created_nodes.append(lm_boot)
	if not tree.root.has_node("AudioManager"):
		var am_boot = load("res://scripts/audio/audio_manager.gd").new()
		am_boot.name = "AudioManager"
		tree.root.add_child(am_boot)
		created_nodes.append(am_boot)
		
	var sm = tree.root.get_node("SaveManager")
	sm.set_setting("sfx_muted", true)
	sm.set_setting("music_muted", true)
	if tree.root.has_node("AudioManager"):
		tree.root.get_node("AudioManager").stop_all()

	# [TEST 1] Player Profile Persistence
	print("[TEST 1] Player Profile Persistence...")
	sm.set_player_name("Master Shifu")
	sm.set_avatar_id(2) # Panda
	sm.set_frame_id(1)  # Jade
	
	assert(sm.get_player_name() == "Master Shifu", "Player name should be Master Shifu")
	assert(sm.get_avatar_id() == 2, "Avatar ID should be 2")
	assert(sm.get_frame_id() == 1, "Frame ID should be 1")
	print("  -> Profile name, avatar, and frame persisted successfully!")
	
	# [TEST 2] Victory Percentile Ranking
	print("[TEST 2] Victory Percentile Ranking...")
	var p1 = sm.calculate_percentile(45.0, 18, 3)
	assert(p1["percentile"] >= 95.0, "Fast 3-star completion should achieve >=95% percentile")
	assert(p1["title"] == "Zen Grandmaster", "Top score should award Zen Grandmaster title")
	print("  -> 3 Stars Percentile: %.1f%% (%s - %s)" % [p1["percentile"], p1["title"], p1["desc"]])
	
	var p2 = sm.calculate_percentile(350.0, 40, 2)
	assert(p2["percentile"] >= 70.0 and p2["percentile"] < 90.0, "2-star completion should have realistic percentile")
	print("  -> 2 Stars Percentile: %.1f%% (%s - %s)" % [p2["percentile"], p2["title"], p2["desc"]])

	# [TEST 3] Milestone Level Chest
	print("[TEST 3] Milestone Level Chest Progress...")
	var m_info1 = sm.get_chest_milestone_info(1)
	assert(m_info1["current"] == 1 and m_info1["goal"] == 5 and not m_info1["is_milestone"], "Level 1 should be 1/5 towards milestone")
	
	var m_info5 = sm.get_chest_milestone_info(5)
	assert(m_info5["current"] == 5 and m_info5["goal"] == 5 and m_info5["is_milestone"], "Level 5 should unlock milestone chest")
	print("  -> Milestone chest progress verified (1/5 to 5/5 ready)!")

	# [TEST 4] 7-Day Streak & Daily Reward
	print("[TEST 4] 7-Day Streak & Daily Reward...")
	sm.progress["last_streak_claimed_date"] = ""
	var streak_before = sm.get_daily_streak()
	var claimed = sm.claim_daily_reward()
	assert(claimed, "First daily claim should succeed")
	assert(sm.is_daily_claimed_today(), "Today should be marked as claimed")
	var streak_after = sm.get_daily_streak()
	assert(streak_after >= 1, "Streak should be at least 1 day")
	
	var claimed_again = sm.claim_daily_reward()
	assert(not claimed_again, "Cannot claim daily reward twice in one day")
	print("  -> Daily streak claim and idempotent protection verified!")

	# [TEST 5] ProfileModal UI & Tabs
	print("[TEST 5] ProfileModal UI & Tabs...")
	var profile_modal = ProfileModal.instantiate()
	tree.root.add_child(profile_modal)
	profile_modal.load_current_profile()
	assert(profile_modal.name_edit.text == "Master Shifu", "ProfileModal name edit should reflect saved name")
	assert(profile_modal.avatar_grid.get_child_count() == sm.AVATAR_DEFS.size(), "ProfileModal should generate avatar choices matching AVATAR_DEFS")
	assert(profile_modal.frame_grid.get_child_count() == 4, "ProfileModal should generate 4 frame choices")
	
	# Select Tiger avatar (id 3) and Cherry frame (id 3)
	profile_modal._on_avatar_selected(3)
	profile_modal._on_frame_selected(3)
	profile_modal._on_save_pressed()
	assert(sm.get_avatar_id() == 3, "Avatar should update to Tiger (3)")
	assert(sm.get_frame_id() == 3, "Frame should update to Cherry (3)")
	
	tree.root.remove_child(profile_modal)
	profile_modal.free()
	print("  -> ProfileModal verified!")

	# [TEST 6] StreakModal UI & 7-Day Nodes
	print("[TEST 6] StreakModal UI & 7-Day Nodes...")
	var streak_modal = StreakModal.instantiate()
	tree.root.add_child(streak_modal)
	streak_modal.refresh_streak_ui()
	assert(streak_modal.days_grid.get_child_count() == 7, "StreakModal should have 7 daily reward cards")
	tree.root.remove_child(streak_modal)
	streak_modal.free()
	print("  -> StreakModal verified!")

	# [TEST 7] Settings Quick Audio Toggles
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
	
	# Test Haptics Toggle
	var haptics_before = sm.get_setting("haptics_enabled", true)
	settings_node._on_haptic_toggle_pressed()
	assert(sm.get_setting("haptics_enabled") == (not haptics_before), "Haptic toggle must flip state")
	
	tree.root.remove_child(settings_node)
	settings_node.free()
	print("  -> Settings quick audio toggles verified!")
	
	if tree.root.has_node("SaveManager"):
		tree.root.get_node("SaveManager").set_setting("sfx_muted", true)
		tree.root.get_node("SaveManager").set_setting("music_muted", true)
	if tree.root.has_node("AudioManager"):
		var am = tree.root.get_node("AudioManager")
		am.stop_all()
	await tree.process_frame
	await tree.process_frame
		
	print("====================================================")
	print(" ALL PROFILE, STREAK & PERCENTILE TESTS PASSED 100% ")
	print("====================================================")
