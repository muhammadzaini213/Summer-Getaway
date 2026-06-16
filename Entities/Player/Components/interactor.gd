extends Area2D

var interactables: Array[Interactable] = []
var user: CharacterBody2D


func _ready() -> void:
	user = get_parent()
	user.interact.connect(_signal_interactable)


func _signal_interactable() -> void:
	if interactables.is_empty():
		return
	
	var _target_interactable = interactables[0]

	for interactable in interactables:
		if _target_interactable.monitorable:
			_target_interactable.user = user
			_target_interactable.start_interaction()
			return
	
func _on_area_entered(area: Area2D) -> void:
	if not area is Interactable:
		return
	if area in interactables:
		return

	interactables.append(area)

func _on_area_exited(area: Area2D) -> void:
	if not area is Interactable:
		return
	if not area in interactables:
		return

	interactables.erase(area)