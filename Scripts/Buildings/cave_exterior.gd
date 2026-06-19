class_name CaveExterior
extends Node2D

@onready var interactable: Interactable = $Interactable

func _ready() -> void:
	interactable.interact.connect(_interact_start)
	

func _interact_start() -> void:
	get_tree().change_scene_to_file("uid://cd20bqb84q7v1")
	interactable.finish_interact.emit.call_deferred()
