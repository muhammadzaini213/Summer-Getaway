extends Control


func _ready() -> void:
	
	AudioManager.play_bgm("res://Assets/Audio/mus_menu.ogg")
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_play_button_pressed() -> void:
	
	AudioManager.play_sfx(AudioManager.CLICK)

	get_tree().change_scene_to_file(
		"res://Scenes/Worlds/prologue.tscn"
	)


func _on_credits_button_pressed() -> void:
	
	AudioManager.play_sfx(AudioManager.CLICK)

	print("Credits")


func _on_quit_button_pressed() -> void:
	
	AudioManager.play_sfx(AudioManager.CLICK)

	get_tree().quit()
