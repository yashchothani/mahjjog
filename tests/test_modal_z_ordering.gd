class_name TestModalZOrdering
extends RefCounted

func _init() -> void:
	var main_loop = Engine.get_main_loop()
	if main_loop and main_loop.get_script() == null:
		if main_loop is SceneTree:
			run_tests(main_loop as SceneTree)
			(main_loop as SceneTree).quit(0)

static func run_tests(tree: SceneTree) -> void:
	print("--- TESTING MODAL Z-ORDERING & PAUSE OVERLAY FIX ---")
	
	var gameplay_scene = load("res://scenes/gameplay/gameplay.tscn")
	assert(gameplay_scene != null, "gameplay.tscn must load")
	
	var gp = gameplay_scene.instantiate()
	tree.root.add_child(gp)
	
	var modals_node = gp.get_node("Modals") as Control
	assert(modals_node != null, "Modals node must exist")
	assert(modals_node.z_index == 100, "Modals z_index must be 100")
	assert(modals_node.z_as_relative == false, "Modals z_as_relative must be false so it stays above board tiles")
	
	var board_container = gp.get_node("BoardContainer") as Control
	assert(board_container != null, "BoardContainer must exist")
	assert(board_container.z_index == 1, "BoardContainer z_index must be 1")
	assert(board_container.z_as_relative == false, "BoardContainer z_as_relative must be false")
	
	var backdrop = gp.get_node("Modals/ModalBackdrop") as ColorRect
	assert(backdrop != null, "ModalBackdrop must exist")
	assert(backdrop.visible == false, "ModalBackdrop should start hidden")
	
	var pause_modal = gp.get_node("Modals/PauseModal") as Control
	assert(pause_modal != null, "PauseModal must exist")
	assert(pause_modal.visible == false, "PauseModal should start hidden")
	
	# Simulate opening pause modal
	gp._on_pause_pressed()
	
	assert(backdrop.visible == true, "ModalBackdrop must be visible when paused")
	assert(pause_modal.visible == true, "PauseModal must be visible when paused")
	var bv = gp._get_board_view()
	assert(bv != null, "BoardView should exist")
	assert(bv.is_interactive == false, "BoardView interaction must be disabled when modal is open")
	print("  -> Verified Pause modal displayed with backdrop and disabled board clicks")
	
	# Simulate clicking resume
	gp._on_resume_pressed()
	
	assert(backdrop.visible == false, "ModalBackdrop must be hidden after resuming")
	assert(pause_modal.visible == false, "PauseModal must be hidden after resuming")
	assert(bv.is_interactive == true, "BoardView interaction must be re-enabled after resuming")
	print("  -> Verified Resume restores board interactivity and hides backdrop")
	
	tree.root.remove_child(gp)
	gp.free()
	
	print("--- MODAL Z-ORDERING & OVERLAY TEST PASSED 100%! ---")
