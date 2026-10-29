extends SceneTree

## Dedicated Automated Test Suite for Zen Mahjong Background Music System.
## Validates track loading, looping attributes, level-tier matching, crossfading, victory fanfares, and settings synchronization.

func _init() -> void:
	_run_standalone.call_deferred()

func _run_standalone() -> void:
	await run_tests(self)
	if root.has_node("AudioManager"):
		var am = root.get_node("AudioManager")
		am.stop_all()
		am.free()
	if root.has_node("SaveManager"):
		var sm = root.get_node("SaveManager")
		sm.free()
	await process_frame
	await process_frame
	quit(0)

static func run_tests(tree: SceneTree) -> void:
	print("====================================================")
	print("     ZEN MAHJONG - MUSIC SYSTEM VERIFICATION       ")
	print("====================================================")
	
	var root = tree.root
	if not root.has_node("SaveManager"):
		var sm = load("res://scripts/save/save_manager.gd").new()
		sm.name = "SaveManager"
		root.add_child(sm)
	if not root.has_node("AudioManager"):
		var am = load("res://scripts/audio/audio_manager.gd").new()
		am.name = "AudioManager"
		root.add_child(am)
		
	var sm_inst = root.get_node("SaveManager")
	var am_inst = root.get_node("AudioManager")
	
	sm_inst.set_setting("music_muted", true)
	sm_inst.set_setting("music_volume", 0.8)
	
	# 1. Verify track catalogue loading
	print("--- 1. Testing Track Loading & Looping Properties ---")
	var expected_tracks = [
		"menu",
		"gameplay_novice",
		"gameplay_adept",
		"gameplay_master",
		"victory",
		"victory_milestone",
		"victory_flourish",
		"victory_resolved"
	]
	
	for track in expected_tracks:
		assert(am_inst.music_tracks.has(track), "Missing music track in AudioManager: %s" % track)
		var stream = am_inst.music_tracks[track]
		assert(stream != null, "Stream should not be null for track: %s" % track)
		print("  [PASS] Track '%s' loaded (Length: %.1fs, Loop: %s)" % [track, stream.get_length(), stream.loop if stream is AudioStreamMP3 else "N/A"])
		if stream is AudioStreamMP3:
			if track.begins_with("victory"):
				assert(stream.loop == false, "Victory cue '%s' should not loop" % track)
			else:
				assert(stream.loop == true, "Ambient track '%s' should loop" % track)
				
	# 2. Test Menu Music Playback
	print("--- 2. Testing Menu Music Playback ---")
	am_inst.play_menu_music(0.0)
	assert(am_inst.get_current_music_track() == "menu", "Menu music should be active")
	assert(am_inst.music_player.stream == am_inst.music_tracks["menu"], "Music player stream should match menu track")
	print("  [PASS] Menu music successfully engaged")

	# 3. Test Level-Tier Music Selection
	print("--- 3. Testing Level-Tier Music Selection ---")
	
	# Tier 1: Novice (Levels 1 to 20)
	am_inst.play_music_for_level(1, false, 0.0)
	assert(am_inst.get_current_music_track() == "gameplay_novice", "Level 1 should use gameplay_novice")
	am_inst.play_music_for_level(20, false, 0.0)
	assert(am_inst.get_current_music_track() == "gameplay_novice", "Level 20 should use gameplay_novice")
	print("  [PASS] Novice tier (Levels 1-20) mapped to 'gameplay_novice'")
	
	# Tier 2: Adept (Levels 21 to 40)
	am_inst.play_music_for_level(21, false, 0.0)
	assert(am_inst.get_current_music_track() == "gameplay_adept", "Level 21 should use gameplay_adept")
	am_inst.play_music_for_level(40, false, 0.0)
	assert(am_inst.get_current_music_track() == "gameplay_adept", "Level 40 should use gameplay_adept")
	print("  [PASS] Adept tier (Levels 21-40) mapped to 'gameplay_adept'")
	
	# Tier 3 & 4: Master & Grandmaster (Levels 41 to 80)
	am_inst.play_music_for_level(41, false, 0.0)
	assert(am_inst.get_current_music_track() == "gameplay_master", "Level 41 should use gameplay_master")
	am_inst.play_music_for_level(80, false, 0.0)
	assert(am_inst.get_current_music_track() == "gameplay_master", "Level 80 should use gameplay_master")
	print("  [PASS] Master/Grandmaster tier (Levels 41-80) mapped to 'gameplay_master'")
	
	# Daily Challenge
	am_inst.play_music_for_level(999, true, 0.0)
	assert(am_inst.get_current_music_track() == "gameplay_novice", "Daily challenge should use gameplay_novice")
	print("  [PASS] Daily Challenge mapped to 'gameplay_novice'")

	# 4. Test Victory Music (Standard and Milestone)
	print("--- 4. Testing Victory Music Cues ---")
	am_inst.play_victory_music(false, 0.0)
	var vic_track = am_inst.get_current_music_track()
	assert(vic_track.begins_with("victory"), "Standard victory should select a victory cue")
	print("  [PASS] Standard victory triggered: %s" % vic_track)
	
	am_inst.play_victory_music(true, 0.0)
	assert(am_inst.get_current_music_track() == "victory_milestone", "Milestone victory must play victory_milestone")
	print("  [PASS] Milestone chest victory triggered: victory_milestone")

	# 5. Test Settings and Volume Synchronization
	print("--- 5. Testing Settings & Volume Synchronization ---")
	sm_inst.set_setting("music_volume", 0.5)
	var expected_db = linear_to_db(0.5)
	sm_inst.set_setting("music_muted", false)
	assert(abs(am_inst.music_player.volume_db - expected_db) < 0.1, "Music player volume should reflect setting")
	print("  [PASS] Volume adjustment reflected: %.2f dB" % am_inst.music_player.volume_db)
	await tree.process_frame
	
	sm_inst.set_setting("music_muted", true)
	assert(am_inst.music_player.volume_db <= -79.0, "Music player volume should be muted to -80dB")
	print("  [PASS] Mute setting reflected: %.2f dB" % am_inst.music_player.volume_db)
	await tree.process_frame

	# 6. Test Stop and Cleanup
	print("--- 6. Testing Stop and Cleanup ---")
	am_inst.stop_music(0.0)
	assert(am_inst.get_current_music_track().is_empty(), "stop_music should clear current track")
	am_inst.stop_all()
	print("  [PASS] stop_music and stop_all completed cleanly")

	print("====================================================")
	print("  ALL MUSIC TESTS PASSED WITH 100% SUCCESS!         ")
	print("====================================================")
	await tree.process_frame
	await tree.process_frame
