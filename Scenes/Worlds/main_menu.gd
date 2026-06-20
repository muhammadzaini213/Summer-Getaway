extends Control


func _ready() -> void:

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_play_button_pressed() -> void:

	get_tree().change_scene_to_file(
		"res://Scenes/Worlds/Levels/island.tscn"
	)


func _on_credits_button_pressed() -> void:

	print("Credits")


func _on_quit_button_pressed() -> void:

	get_tree().quit()
