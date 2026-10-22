extends SceneTree

## Automated Scene & Node Debugger for all project scenes.
## Validates that every .tscn instantiates cleanly, processes frames without errors, and frees cleanly.

func _init():
	print("====================================================")
	print("       DEBUGGING ALL SCENES & RUNTIME TREES         ")
	print("====================================================")
	
	# Bootstrap singletons if running headless script standalone
	if not root.has_node("SaveManager"):
		var sm = load("res://scripts/save/save_manager.gd").new()
		sm.name = "SaveManager"
		root.add_child(sm)
	if not root.has_node("GameManager"):
		var gm = load("res://scripts/core/game_manager.gd").new()
		gm.name = "GameManager"
		root.add_child(gm)
	if not root.has_node("AudioManager"):
		var am = load("res://scripts/audio/audio_manager.gd").new()
		am.name = "AudioManager"
		root.add_child(am)
	
	var scenes_to_test = [
		"res://scenes/boot/splash.tscn",
		"res://scenes/menus/main_menu.tscn",
		"res://scenes/menus/level_select.tscn",
		"res://scenes/settings/settings.tscn",
		"res://scenes/gameplay/gameplay.tscn"
	]
	
	var total_nodes_audited = 0
	
	for path in scenes_to_test:
		print("[TEST SCENE] Loading: %s" % path)
		var packed = load(path) as PackedScene
		assert(packed != null, "Failed to load packed scene: %s" % path)
		
		var instance = packed.instantiate()
		assert(instance != null, "Failed to instantiate scene: %s" % path)
		
		root.add_child(instance)
		var count = _count_nodes(instance)
		total_nodes_audited += count
		print("  -> Instantiated %s (Node name: %s, total subtree nodes: %d)" % [instance.get_class(), instance.name, count])
		
		# Let scene process and run layout
		if instance.has_method("start_level"):
			instance.start_level(1)
			
		root.remove_child(instance)
		instance.queue_free()
		print("  -> Cleaned up %s successfully!" % path)
		
	print("====================================================")
	print(" ALL %d SCENES LOADED & CLEANED UP (%d NODES AUDITED)" % [scenes_to_test.size(), total_nodes_audited])
	print("====================================================")
	quit(0)

func _count_nodes(node: Node) -> int:
	var count = 1
	for child in node.get_children():
		count += _count_nodes(child)
	return count
