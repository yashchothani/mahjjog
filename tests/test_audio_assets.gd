extends SceneTree

func _init() -> void:
	print("====================================================")
	print("       VERIFYING ZEN MAHJONG AUDIO ASSETS           ")
	print("====================================================")
	
	var files = {
		"tile_select": "res://assets/audio/tile_select.wav",
		"tile_match": "res://assets/audio/tile_match.wav",
		"tile_invalid": "res://assets/audio/tile_invalid.wav",
		"hint": "res://assets/audio/hint.wav",
		"shuffle": "res://assets/audio/shuffle.wav",
		"undo": "res://assets/audio/undo.wav",
		"level_complete": "res://assets/audio/level_complete.wav",
		"button_press": "res://assets/audio/button_press.wav",
		"tile_click": "res://assets/audio/tile_click.wav"
	}
	
	var all_ok = true
	for key in files.keys():
		var path = files[key]
		var stream = load(path) as AudioStream
		if stream != null:
			print("  [OK] %-15s -> %s (Length: %.3fs)" % [key, path, stream.get_length()])
			assert(stream.get_length() > 0.05, "Audio file should have valid duration")
		else:
			printerr("  [FAIL] Failed to load: %s" % path)
			all_ok = false
			
	print("====================================================")
	if all_ok:
		print(" ALL 9 ORIGINAL ZEN AUDIO FILES VERIFIED & LOADED!  ")
	else:
		printerr(" AUDIO ASSETS FAILED LOAD VERIFICATION! ")
	print("====================================================")
	quit(0 if all_ok else 1)
