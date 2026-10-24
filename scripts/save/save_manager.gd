extends Node

## Manages local persistence for settings, level progress, stars, and daily streaks.

const SAVE_PATH = "user://zen_mahjong_save.json"
const SAVE_VERSION = 1

signal settings_changed
signal progress_updated

var settings = {
	"language": "en",
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
	"tutorial_completed": false,
	"player_name": "Zen Explorer",
	"avatar_id": 0,
	"avatar_frame": "gold",
	"streak_claimed_days": [],
	"last_streak_claimed_date": "",
	"milestone_chests_opened": 0
}

func _init() -> void:
	load_save_data()

func _ready() -> void:
	load_save_data()

func reset_to_defaults() -> void:
	settings = {
		"language": "en",
		"music_volume": 0.8,
		"sfx_volume": 1.0,
		"music_muted": false,
		"sfx_muted": false,
		"haptics_enabled": true,
		"reduced_motion": false,
		"dim_blocked_tiles": true,
		"highlight_free_tiles": false
	}
	progress = {
		"current_level": 1,
		"max_unlocked_level": 1,
		"completed_levels": {},
		"selected_theme": "jade",
		"unlocked_themes": ["jade"],
		"daily_streak": 0,
		"last_daily_date": "",
		"daily_completed_today": false,
		"hints_remaining": 5,
		"shuffles_remaining": 3,
		"tutorial_completed": false,
		"player_name": "Zen Explorer",
		"avatar_id": 0,
		"avatar_frame": "gold",
		"streak_claimed_days": [],
		"last_streak_claimed_date": "",
		"milestone_chests_opened": 0
	}
	save_data()
	progress_updated.emit()
	settings_changed.emit()

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

# --- PROFILE CUSTOMIZATION ---

const AVATAR_DEFS = [
	{ "id": 0, "name": "Zen Sage", "icon": "🧘", "color": Color(0.18, 0.44, 0.30) },
	{ "id": 1, "name": "Dragon Sovereign", "icon": "👑", "color": Color(0.85, 0.68, 0.25) },
	{ "id": 2, "name": "Bamboo Nomad", "icon": "🎋", "color": Color(0.20, 0.55, 0.32) },
	{ "id": 3, "name": "Lotus Maiden", "icon": "🌸", "color": Color(0.80, 0.30, 0.55) },
	{ "id": 4, "name": "Crane Scholar", "icon": "🦅", "color": Color(0.25, 0.45, 0.70) },
	{ "id": 5, "name": "Wind Hermit", "icon": "🍃", "color": Color(0.35, 0.65, 0.40) },
	{ "id": 6, "name": "Wave Seeker", "icon": "🌊", "color": Color(0.15, 0.50, 0.75) },
	{ "id": 7, "name": "Mountain Hermit", "icon": "🪨", "color": Color(0.55, 0.45, 0.35) }
]

const FRAME_DEFS = [
	{ "id": "gold", "name": "Imperial Gold", "color": Color(0.96, 0.86, 0.52) },
	{ "id": "jade", "name": "Deep Jade", "color": Color(0.22, 0.65, 0.42) },
	{ "id": "lotus", "name": "Lotus Blossom", "color": Color(0.92, 0.55, 0.72) },
	{ "id": "obsidian", "name": "Black Obsidian", "color": Color(0.35, 0.38, 0.42) }
]

func get_player_name() -> String:
	return str(progress.get("player_name", "Zen Explorer"))

func set_player_name(val: String) -> void:
	var clean_val = val.strip_edges()
	if clean_val == "":
		clean_val = "Zen Explorer"
	progress["player_name"] = clean_val
	save_data()
	progress_updated.emit()

func get_avatar_id() -> int:
	return int(progress.get("avatar_id", 0))

func set_avatar_id(val: int) -> void:
	progress["avatar_id"] = clampi(val, 0, AVATAR_DEFS.size() - 1)
	save_data()
	progress_updated.emit()

func get_avatar_frame() -> String:
	return str(progress.get("avatar_frame", "gold"))

func set_avatar_frame(val: String) -> void:
	progress["avatar_frame"] = val
	save_data()
	progress_updated.emit()

# --- DAILY STREAK ---

func get_daily_streak() -> int:
	return int(progress.get("daily_streak", 0))

func is_streak_claimed_today() -> bool:
	var today_str = Time.get_date_string_from_system()
	return progress.get("last_streak_claimed_date", "") == today_str

func claim_daily_streak() -> Dictionary:
	var today_str = Time.get_date_string_from_system()
	var current_streak = int(progress.get("daily_streak", 0))
	var already_claimed = (progress.get("last_streak_claimed_date", "") == today_str)
	
	if not already_claimed:
		current_streak += 1
		progress["daily_streak"] = current_streak
		progress["last_streak_claimed_date"] = today_str
		
		# 1 to 7 day cycle
		var cycle_day = ((current_streak - 1) % 7) + 1
		var bonus_hints = 5 if cycle_day == 7 else 2
		progress["hints_remaining"] = int(progress.get("hints_remaining", 5)) + bonus_hints
		
		var claimed_days = progress.get("streak_claimed_days", [])
		if cycle_day == 1:
			claimed_days = [1]
		else:
			if not claimed_days.has(cycle_day):
				claimed_days.append(cycle_day)
		progress["streak_claimed_days"] = claimed_days
		
		save_data()
		progress_updated.emit()
		return {
			"success": true,
			"streak": current_streak,
			"cycle_day": cycle_day,
			"hints_awarded": bonus_hints,
			"is_chest": (cycle_day == 7)
		}
	else:
		var cycle_day = max(1, ((current_streak - 1) % 7) + 1)
		return {
			"success": false,
			"streak": current_streak,
			"cycle_day": cycle_day,
			"hints_awarded": 0,
			"is_chest": (cycle_day == 7)
		}

# --- VICTORY PERCENTILE & MILESTONES ---

func calculate_percentile(time_seconds: float, moves_count: int, stars: int) -> Dictionary:
	var base_pct: float = 70.0
	var max_bonus: float = 15.0
	
	if stars >= 3:
		base_pct = 90.0
		max_bonus = 8.9 # 90.0% to 98.9%
	elif stars == 2:
		base_pct = 76.0
		max_bonus = 12.5 # 76.0% to 88.5%
	else:
		base_pct = 55.0
		max_bonus = 18.0 # 55.0% to 73.0%
		
	var speed_factor = clamp(1.0 - (time_seconds / 150.0), 0.1, 1.0)
	var final_pct = base_pct + (max_bonus * speed_factor)
	final_pct = round(final_pct * 10.0) / 10.0
	
	var title = "Breezy Master"
	var desc = "Smooth on the surface, all skill underneath!"
	if final_pct >= 95.0:
		title = "Zen Grandmaster"
		desc = "Flawless clarity and unmatched speed!"
	elif final_pct >= 90.0:
		title = "Breezy Master"
		desc = "Smooth on the surface, all skill underneath!"
	elif final_pct >= 80.0:
		title = "Tranquil Adept"
		desc = "Patient, focused, and steady moves."
	else:
		title = "Mindful Seeker"
		desc = "A journey well begun. Keep practicing!"
		
	return {
		"percentile": final_pct,
		"percentile_str": "%.1f%%" % final_pct,
		"title": title,
		"desc": desc
	}

func get_chest_milestone_info(level_id: int) -> Dictionary:
	var tier_size: int = 5
	var tier_index = int((level_id - 1) / tier_size) + 1
	var current_step = ((level_id - 1) % tier_size) + 1
	var is_milestone = (current_step == tier_size)
	var milestone_level = tier_index * tier_size
	
	return {
		"current": current_step,
		"goal": tier_size,
		"is_milestone": is_milestone,
		"milestone_level": milestone_level,
		"chest_ready": is_milestone
	}
