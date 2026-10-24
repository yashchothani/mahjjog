extends SceneTree

func _init() -> void:
	print("====================================================")
	print("       AUDITING & COMPILING ALL GDSCRIPT FILES       ")
	print("====================================================")
	
	var scripts = [
		"res://scripts/audio/audio_manager.gd",
		"res://scripts/board/board_generator.gd",
		"res://scripts/board/board_layout.gd",
		"res://scripts/board/board_view.gd",
		"res://scripts/board/tile_view.gd",
		"res://scripts/core/game_manager.gd",
		"res://scripts/core/localization_manager.gd",
		"res://scripts/data/mahjong_tile_data.gd",
		"res://scripts/gameplay/gameplay_controller.gd",
		"res://scripts/save/save_manager.gd",
		"res://scripts/ui/level_select_controller.gd",
		"res://scripts/ui/main_menu_controller.gd",
		"res://scripts/ui/settings_controller.gd",
		"res://scripts/ui/splash_controller.gd",
		"res://scripts/ui/tutorial_modal_controller.gd",
		"res://tests/test_board_logic.gd",
		"res://tests/test_gameplay_flow.gd",
		"res://tests/test_full_game_loop.gd",
		"res://tests/test_localization.gd",
		"res://tests/test_tile_guide.gd",
		"res://tests/test_save_persistence.gd",
		"res://tests/test_responsive_layouts.gd",
		"res://tests/test_interactive_clicks.gd",
		"res://tests/test_viewport_clicks.gd",
		"res://tests/test_tile_button.gd",
		"res://tests/test_tile_click.gd",
		"res://tests/test_all_30_levels.gd",
		"res://tests/test_play_level1.gd",
		"res://tests/debug_layouts_initial_free.gd",
		"res://tests/debug_all_scenes.gd",
		"res://tests/test_modal_z_ordering.gd"
	]
	
	var failed: int = 0
	for path in scripts:
		var sc = load(path)
		if sc == null:
			printerr("  [FAIL] Failed to load/compile: %s" % path)
			failed += 1
		else:
			print("  [OK] Successfully compiled: %s" % path)
			
	print("====================================================")
	if failed == 0:
		print(" ALL %d GDSCRIPT FILES COMPILED CLEANLY (0 ERRORS) " % scripts.size())
	else:
		printerr(" %d GDSCRIPT FILES FAILED COMPILATION! " % failed)
	print("====================================================")
	quit(failed)
