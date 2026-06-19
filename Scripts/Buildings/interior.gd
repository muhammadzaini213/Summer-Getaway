extends Node2D

@export_file_path("*.tscn") var previous_scene: String

@onready var _player: CharacterBody2D = $Player
@onready var _interactable: Interactable = $Interactable

func _ready() -> void:
	_interactable.interact.connect(_on_interact)

func _on_interact() -> void:
	get_tree().change_scene_to_file(previous_scene)
	_interactable.finish_interact.emit()
