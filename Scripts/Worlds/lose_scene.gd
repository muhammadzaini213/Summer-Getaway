extends Control

func _ready() -> void:
	$Back.pressed.connect(_to_menu)

func _to_menu() -> void:
	get_tree().change_scene_to_file("uid://do8nfjmx7pw2m")
