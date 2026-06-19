extends Node

func print_garbage() -> void:
	print("Nyaaaaa~ *fucking dies*")

func goto_scene(scene: PackedScene) -> void:
	call_deferred("_change_scene", scene)

func _change_scene(scene: PackedScene) -> void:
	get_tree().change_scene_to_packed(scene)
