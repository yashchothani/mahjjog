extends SceneTree

## Full End-to-End Game Loop Integration Debugger.
## Simulates a complete player session across Splash, Menu, Gameplay, Level Select, and Settings.

func _init() -> void:
	_run_standalone.call_deferred()

func _run_standalone() -> void:
	run_tests(self)
	await process_frame
	quit(0)

static func run_tests(tree: SceneTree) -> void:
	print("--- STARTING FULL E2E SESSION INTEGRATION TEST ---")
	
	# 1. Main Menu Initialization
	print("[STEP 1] Testing Main Menu Scene...")
	var menu_scene = load("res://scenes/menus/main_menu.tscn").instantiate()
	tree.root.add_child(menu_scene)
	menu_scene._ready()
	
	assert(menu_scene.has_node("CenterContainer/VBox/MenuButtons/ContinueBtn"), "Menu must have Play button")
	assert(menu_scene.has_node("CenterContainer/VBox/MenuButtons/LevelSelectBtn"), "Menu must have Level Select button")
	assert(menu_scene.has_node("CenterContainer/VBox/MenuButtons/DailyBtn"), "Menu must have Daily Challenge button")
	assert(menu_scene.has_node("CenterContainer/VBox/MenuButtons/SettingsBtn"), "Menu must have Settings button")
	assert(menu_scene.has_node("Modals/TutorialModal"), "Menu must have Tutorial modal")
	
	menu_scene._on_tutorial_pressed()
	assert(menu_scene.get_node("Modals/TutorialModal").visible == true, "Tutorial should be visible")
	menu_scene._on_tutorial_close_pressed()
	assert(menu_scene.get_node("Modals/TutorialModal").visible == false, "Tutorial should close")
	print("  -> Main Menu UI elements and tutorial modal verified!")
	tree.root.remove_child(menu_scene)
	menu_scene.free()
	
	# 2. Level Select Screen
	print("[STEP 2] Testing Level Selection Scene...")
	var ls_scene = load("res://scenes/menus/level_select.tscn").instantiate()
	tree.root.add_child(ls_scene)
	ls_scene._ready()
	
	var grid = ls_scene.get_node("ScrollContainer/Center/VBox/GridContainer")
	assert(grid.get_child_count() == 80, "Level grid must have all 80 level buttons (found %d)" % grid.get_child_count())
	ls_scene._set_tier_filter("grandmaster")
	assert(grid.get_child_count() == 20, "Grandmaster tier must have 20 high-IQ buttons (found %d)" % grid.get_child_count())
	ls_scene._set_tier_filter("all")
	assert(grid.get_child_count() == 80, "All filter must restore 80 level buttons")
	print("  -> Verified all 80 level buttons and Grandmaster tier filtering created!")
	tree.root.remove_child(ls_scene)
	ls_scene.free()
	
	# 3. Settings Screen
	print("[STEP 3] Testing Settings & Accessibility Scene...")
	var settings_scene = load("res://scenes/settings/settings.tscn").instantiate()
	tree.root.add_child(settings_scene)
	settings_scene._ready()
	
	var music_sl = settings_scene.get_node("CenterContainer/Panel/VBox/AudioBox/MusicSlider")
	var sfx_sl = settings_scene.get_node("CenterContainer/Panel/VBox/AudioBox/SFXSlider")
	var dim_chk = settings_scene.get_node("CenterContainer/Panel/VBox/AccessBox/DimCheck")
	var lang_opt = settings_scene.get_node("CenterContainer/Panel/VBox/LanguageBox/LanguageOption")
	assert(lang_opt != null, "Settings must have LanguageOption")
	assert(lang_opt.item_count == 7, "LanguageOption must have 7 languages (found %d)" % lang_opt.item_count)
	settings_scene._on_language_selected(1) # Switch to zh
	settings_scene._on_language_selected(0) # Switch back to en
	settings_scene._on_music_slider_value_changed(0.5)
	settings_scene._on_sfx_slider_value_changed(0.7)
	settings_scene._on_dim_check_toggled(false)
	print("  -> Settings slider, language option, and checkbox events tested!")
	tree.root.remove_child(settings_scene)
	settings_scene.free()
	
	# 4. Gameplay Scene & Board Interaction
	print("[STEP 4] Testing Gameplay Scene & Controls...")
	var gp_scene = load("res://scenes/gameplay/gameplay.tscn").instantiate()
	tree.root.add_child(gp_scene)
	gp_scene._ready()
	
	var bv = gp_scene.get_node("BoardContainer/BoardView")
	assert(bv != null, "Gameplay must have BoardView")
	
	# Pause / Resume / Tile Guide flow
	gp_scene._on_pause_pressed()
	assert(gp_scene.get_node("Modals/PauseModal").visible == true, "Pause modal should show")
	gp_scene._on_guide_pressed()
	assert(gp_scene.get_node("Modals/TutorialModal").visible == true, "In-game tutorial modal should show")
	gp_scene.get_node("Modals/TutorialModal").hide()
	gp_scene._on_resume_pressed()
	assert(gp_scene.get_node("Modals/PauseModal").visible == false, "Pause modal should hide on resume")
	
	# Hint / Undo / Restart (No shuffle button)
	assert(gp_scene.get_node_or_null("BottomBar/HBox/ShuffleBtn") == null, "Shuffle button must not exist on BottomBar")
	gp_scene._on_hint_pressed()
	gp_scene._on_undo_pressed()
	gp_scene._on_restart_pressed()
	print("  -> Gameplay HUD (Undo/Hint/Restart), tile guide modal, and in-game modal actions verified!")
	
	tree.root.remove_child(gp_scene)
	gp_scene.free()
	print("--- FULL E2E SESSION INTEGRATION TEST COMPLETED SUCCESSFULLY ---")
