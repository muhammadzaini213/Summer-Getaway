extends Area2D


@export var dialogue_manager: CanvasLayer
@export var json_data_path: String

func on_interact() -> void:
	var data = dialogue_manager.load_dialogue_json(json_data_path)
	dialogue_manager.start_dialogue(data)
