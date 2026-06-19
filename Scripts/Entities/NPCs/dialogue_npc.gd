extends Node2D

@export var dialogue_id: String
@export var dialogue_resource: DialogueResource = preload("res://dialogues/npc_dialogues.dialogue")
@export var interactable: Interactable


func _ready() -> void:
	if interactable == null:
		interactable = get_node_or_null("Interactable")

	if interactable:
		interactable.interact.connect(_on_interact)


func _on_interact() -> void:
	print("[DEBUG] Opening dialogue:", dialogue_id)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended, CONNECT_ONE_SHOT)
	DialogueManager.show_dialogue_balloon(dialogue_resource, dialogue_id)


func _on_dialogue_ended(_resource: DialogueResource) -> void:
	if interactable:
		interactable.finish_interact.emit()
