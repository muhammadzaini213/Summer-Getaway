extends Area2D


@export var dialogue_manager: CanvasLayer
@export var json_data_path: String
@export var interactable: Area2D

func _ready() -> void:
	interactable.interact.connect(on_interact)
	dialogue_manager.finish_dialogue.connect(finish_interaction)

func on_interact() -> void:
	dialogue_manager.start_dialogue_from_file(json_data_path)


func finish_interaction() -> void:
	interactable.finish_interact.emit()
