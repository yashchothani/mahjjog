extends SceneTree

func _init() -> void:
	print("====================================================")
	print("       VERIFYING ZEN MAHJONG MUSIC TRACKS           ")
	print("====================================================")
	
	var tracks = {
		"menu": "res://music/Zen Mahjong Menu Theme.mp3",
		"gameplay_novice": "res://music/Zen Mahjong Main Theme.mp3",
		"gameplay_adept": "res://music/Jade Garden Solitaire.mp3",
		"gameplay_master": "res://music/Sunrise Over the Tile Garden.mp3",
		"victory": "res://music/Zen Mahjong - Peaceful Victory.mp3",
		"victory_milestone": "res://music/Zen Mahjong - Level Complete Jingle.mp3",
		"victory_flourish": "res://music/Board Cleared Flourish.mp3",
		"victory_resolved": "res://music/Tiles Resolved Victory Cue.mp3"
	}
	
	var all_ok = true
	for key in tracks.keys():
		var path = tracks[key]
		var stream = load(path)
		if stream != null:
			print("  [OK] %-18s -> %s (Length: %.1fs, Class: %s)" % [key, path, stream.get_length(), stream.get_class()])
			if stream is AudioStreamMP3:
				stream.loop = true
				print("       Loop set: %s" % stream.loop)
		else:
			printerr("  [FAIL] Failed to load: %s" % path)
			all_ok = false
			
	print("====================================================")
	if all_ok:
		print(" ALL 8 MUSIC TRACKS LOADED & VERIFIED!             ")
	else:
		printerr(" MUSIC ASSETS FAILED LOAD VERIFICATION! ")
	print("====================================================")
	quit(0 if all_ok else 1)
