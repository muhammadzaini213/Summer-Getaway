extends Node2D

@export var previous_scene: PackedScene

func _on_exit_transition_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	if previous_scene:
		GameEvents.goto_scene(previous_scene)
