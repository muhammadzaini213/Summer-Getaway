extends Area2D


@export var dialogue_manager: CanvasLayer
@export var json_data_path: String
@export var interactable: Area2D

func _ready() -> void:
	interactable.interact.connect(on_interact)
	dialogue_manager.finish_dialogue.connect(finish_interaction)

func on_interact() -> void:
	var data = dialogue_manager.load_dialogue_json(json_data_path)
	dialogue_manager.start_dialogue(data)


func finish_interaction() -> void:
	interactable.finish_interact.emit()
