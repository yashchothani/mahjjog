extends Node

## Global Game Controller coordinating scene changes, active level state, and transitions.

signal level_started(level_id: int)
signal level_completed(level_id: int, time_taken: float, moves: int)

var active_level_id: int = 1
var is_daily_challenge: bool = false
var daily_date_string: String = ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func start_level(level_id: int) -> void:
	active_level_id = level_id
	is_daily_challenge = false
	get_tree().change_scene_to_file("res://scenes/gameplay/gameplay.tscn")
	level_started.emit(level_id)

func start_daily_challenge() -> void:
	is_daily_challenge = true
	var date_dict = Time.get_date_dict_from_system()
	daily_date_string = "%04d-%02d-%02d" % [date_dict.year, date_dict.month, date_dict.day]
	active_level_id = (date_dict.year * 365 + date_dict.month * 31 + date_dict.day) % 10 + 1
	get_tree().change_scene_to_file("res://scenes/gameplay/gameplay.tscn")
	level_started.emit(active_level_id)

func return_to_main_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")

func open_level_select() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/level_select.tscn")

func open_settings() -> void:
	get_tree().change_scene_to_file("res://scenes/settings/settings.tscn")
