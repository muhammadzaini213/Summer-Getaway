extends Area2D

var interactables: Array[Interactable] = []

var user: CharacterBody2D


func _ready() -> void:

	user = get_parent()

	user.interact.connect(_signal_interactable)


func _signal_interactable() -> void:

	if interactables.is_empty():
		return

	get_node("/root/InteractionUI").press_e()

	for interactable in interactables:

		if interactable.monitorable:

			interactable.user = user

			interactable.start_interaction()

			var ui = get_node_or_null("/root/InteractionUI")

			if ui:
				ui.hide_prompt()

			return


func _on_area_entered(area: Area2D) -> void:

	if not area is Interactable:
		return

	if area in interactables:
		return

	interactables.append(area)

	get_node("/root/InteractionUI").show_e()


func _on_area_exited(area: Area2D) -> void:

	if not area is Interactable:
		return

	if not area in interactables:
		return

	interactables.erase(area)

	if interactables.is_empty():

		get_node("/root/InteractionUI").hide_prompt()
		
