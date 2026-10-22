extends Node

## Manages local persistence for settings, level progress, stars, and daily streaks.

const SAVE_PATH = "user://zen_mahjong_save.json"
const SAVE_VERSION = 1

signal settings_changed
signal progress_updated

var settings = {
	"music_volume": 0.8,
	"sfx_volume": 1.0,
	"music_muted": false,
	"sfx_muted": false,
	"haptics_enabled": true,
	"reduced_motion": false,
	"dim_blocked_tiles": true,
	"highlight_free_tiles": false
}

var progress = {
	"current_level": 1,
	"max_unlocked_level": 1,
	"completed_levels": {}, # level_id (str) -> {"stars": int, "best_time": float, "best_moves": int}
	"selected_theme": "jade",
	"unlocked_themes": ["jade"],
	"daily_streak": 0,
	"last_daily_date": "",
	"daily_completed_today": false,
	"hints_remaining": 5,
	"shuffles_remaining": 3,
	"tutorial_completed": false
}

func _ready() -> void:
	load_save_data()

func save_data() -> bool:
	var payload = {
		"version": SAVE_VERSION,
		"settings": settings,
		"progress": progress
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open save file for writing: %s" % FileAccess.get_open_error())
		return false
	var json_str = JSON.stringify(payload, "\t")
	file.store_string(json_str)
	file.close()
	return true

func load_save_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		save_data()
		return
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_warning("Could not read save file, initializing defaults.")
		return
		
	var json_str = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_str)
	if error != OK:
		push_warning("Save file corrupted, backing up and creating fresh state.")
		save_data()
		return
		
	var data = json.get_data()
	if typeof(data) == TYPE_DICTIONARY:
		if data.has("settings") and typeof(data["settings"]) == TYPE_DICTIONARY:
			for key in data["settings"].keys():
				settings[key] = data["settings"][key]
		if data.has("progress") and typeof(data["progress"]) == TYPE_DICTIONARY:
			for key in data["progress"].keys():
				progress[key] = data["progress"][key]

func record_level_completion(level_id: int, time_seconds: float, moves_count: int, stars: int = 3) -> void:
	var str_id = str(level_id)
	var prev_record = progress["completed_levels"].get(str_id, {})
	var best_time = time_seconds
	var best_moves = moves_count
	var best_stars = stars
	
	if prev_record.size() > 0:
		best_time = min(best_time, prev_record.get("best_time", time_seconds))
		best_moves = min(best_moves, prev_record.get("best_moves", moves_count))
		best_stars = max(best_stars, prev_record.get("stars", stars))
		
	progress["completed_levels"][str_id] = {
		"stars": best_stars,
		"best_time": best_time,
		"best_moves": best_moves
	}
	
	var next_level = level_id + 1
	if next_level > progress["max_unlocked_level"]:
		progress["max_unlocked_level"] = next_level
		
	save_data()
	progress_updated.emit()

func is_level_unlocked(level_id: int) -> bool:
	return level_id <= progress.get("max_unlocked_level", 1)

func get_level_stars(level_id: int) -> int:
	var rec = progress["completed_levels"].get(str(level_id), {})
	return rec.get("stars", 0)

func set_setting(key: String, value) -> void:
	settings[key] = value
	save_data()
	settings_changed.emit()

func get_setting(key: String, default_val = null):
	return settings.get(key, default_val)
