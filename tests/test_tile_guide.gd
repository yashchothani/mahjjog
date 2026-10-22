extends SceneTree

func _init() -> void:
	_run_standalone.call_deferred()

func _run_standalone() -> void:
	run_tests(self)
	await process_frame
	quit(0)

static func run_tests(tree: SceneTree) -> void:
	print("--- TESTING VISUAL TILE GUIDE MODAL ---")
	var packed = load("res://scenes/dialogs/tutorial_modal.tscn")
	assert(packed != null, "Failed to load tutorial_modal.tscn")
	
	var modal = packed.instantiate()
	tree.root.add_child(modal)
	
	# Verify that nodes are ready
	assert(modal.char_grid != null, "char_grid must be initialized")
	assert(modal.bamboo_grid != null, "bamboo_grid must be initialized")
	assert(modal.dots_grid != null, "dots_grid must be initialized")
	assert(modal.winds_grid != null, "winds_grid must be initialized")
	assert(modal.dragons_grid != null, "dragons_grid must be initialized")
	assert(modal.flowers_grid != null, "flowers_grid must be initialized")
	assert(modal.seasons_grid != null, "seasons_grid must be initialized")
	
	# Verify tile counts in each grid
	print("Character cards: %d" % modal.char_grid.get_child_count())
	assert(modal.char_grid.get_child_count() == 9, "Characters should have 9 cards")
	
	print("Bamboo cards: %d" % modal.bamboo_grid.get_child_count())
	assert(modal.bamboo_grid.get_child_count() == 9, "Bamboo should have 9 cards")
	
	print("Dots cards: %d" % modal.dots_grid.get_child_count())
	assert(modal.dots_grid.get_child_count() == 9, "Dots should have 9 cards")
	
	print("Winds cards: %d" % modal.winds_grid.get_child_count())
	assert(modal.winds_grid.get_child_count() == 4, "Winds should have 4 cards")
	
	print("Dragons cards: %d" % modal.dragons_grid.get_child_count())
	assert(modal.dragons_grid.get_child_count() == 3, "Dragons should have 3 cards")
	
	print("Flowers cards: %d" % modal.flowers_grid.get_child_count())
	assert(modal.flowers_grid.get_child_count() == 4, "Flowers should have 4 cards")
	
	print("Seasons cards: %d" % modal.seasons_grid.get_child_count())
	assert(modal.seasons_grid.get_child_count() == 4, "Seasons should have 4 cards")
	
	# Test Tab switching
	for tab_idx in range(7):
		modal.select_tab(tab_idx)
		assert(modal.current_tab_index == tab_idx, "Tab index should be %d" % tab_idx)
	print("Tab switching: Verified 7/7 tabs!")
	
	tree.root.remove_child(modal)
	modal.free()
	print("--- TILE GUIDE MODAL TEST PASSED! ---")
