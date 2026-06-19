extends Node2D

@export var dialogue_resource: DialogueResource = preload("res://dialogues/bartender.dialogue")
@export var interactable: Interactable


func _ready() -> void:
	if interactable == null:
		interactable = get_node_or_null("Interactable")

	if interactable:
		interactable.interact.connect(_on_interact)


func _on_interact() -> void:
	print("[DEBUG] Bartender dialogue opened")
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended, CONNECT_ONE_SHOT)
	DialogueManager.show_dialogue_balloon(dialogue_resource, dialogue_resource.first_cue)


func _on_dialogue_ended(_resource: DialogueResource) -> void:
	print("[DEBUG] Bartender dialogue closed")

	if interactable:
		interactable.finish_interact.emit()
