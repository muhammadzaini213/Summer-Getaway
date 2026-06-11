extends Control

@export var game_scene_path := "res://Scenes/Worlds/Levels/island.tscn"

@onready var play_button: Button = $CenterContainer/VBoxContainer/PlayButton
@onready var credits_button: Button = $CenterContainer/VBoxContainer/CreditsButton
@onready var exit_button: Button = $CenterContainer/VBoxContainer/ExitButton
@onready var credits_label: Label = $CenterContainer/VBoxContainer/CreditsLabel
@onready var music_player: AudioStreamPlayer = $AudioStreamPlayer


func _ready() -> void:

	credits_label.visible = false

	if music_player.stream != null:
		music_player.play()


func _on_play_button_pressed() -> void:
	
	get_tree().change_scene_to_file(game_scene_path)


func _on_credit_button_pressed() -> void:
	credits_label.visible = not credits_label.visible


func _on_exit_button_pressed() -> void:
	get_tree().quit()
