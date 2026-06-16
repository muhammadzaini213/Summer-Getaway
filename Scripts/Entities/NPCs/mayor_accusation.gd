extends Node2D

@export var interactable: Interactable
@export var correct_suspect_id := "suspect_03"
@export var suspects: Array[Dictionary] = [
	{"id": "suspect_01", "display_name": "Suspect 1"},
	{"id": "suspect_02", "display_name": "Suspect 2"},
	{"id": "suspect_03", "display_name": "Suspect 3"},
	{"id": "suspect_04", "display_name": "Suspect 4"},
]


func _ready() -> void:
	if interactable == null:
		interactable = $Interactable

	interactable.interact.connect(_on_interact)
	AccusationSystem.accusation_closed.connect(_on_accusation_closed)


func _on_interact() -> void:
	AccusationSystem.open_accusation(suspects, correct_suspect_id)


func _on_accusation_closed() -> void:
	interactable.finish_interact.emit()
