extends Node2D

@onready var interactable: Interactable = $Interactable


func _ready() -> void:

	interactable.interact.connect(_on_interact)


func _on_interact() -> void:
	GameState.pub_return_position = interactable.user.global_position
	get_tree().change_scene_to_file(
		"res://Scenes/Worlds/cave.tscn"
	)

	interactable.finish_interact.emit()
