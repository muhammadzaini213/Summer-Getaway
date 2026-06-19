extends Node2D

@onready var interactable: Interactable = $Interactable

var dialogue_resource: DialogueResource = preload("uid://cx54c2ghpijbt")
var dialogue_id := "Mayor"


func _ready() -> void:

	if interactable == null:
		interactable = $Interactable

	interactable.interact.connect(_on_interact)


func _on_interact() -> void:

	DialogueManager.dialogue_ended.connect(
		_on_dialogue_finished,
		CONNECT_ONE_SHOT
	)

	DialogueManager.show_dialogue_balloon(
		dialogue_resource,
		dialogue_id
	)


func _on_dialogue_finished(_resource: DialogueResource) -> void:

	interactable.finish_interact.emit()
