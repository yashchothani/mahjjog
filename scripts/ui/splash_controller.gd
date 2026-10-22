extends Control

## Splash screen with elegant fade transition into the main menu.

@onready var content_box: VBoxContainer = $CenterContainer/VBox

func _ready() -> void:
	content_box.modulate.a = 0.0
	
	var tween = create_tween()
	# Fade in logo
	tween.tween_property(content_box, "modulate:a", 1.0, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.6)
	# Fade out
	tween.tween_property(content_box, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(_go_to_menu)

var _has_transitioned: bool = false

func _go_to_menu() -> void:
	if _has_transitioned:
		return
	_has_transitioned = true
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")

func _gui_input(event: InputEvent) -> void:
	# Tap to skip splash
	if (event is InputEventMouseButton and event.pressed) or (event is InputEventScreenTouch and event.pressed):
		_go_to_menu()
