extends Node2D

@export var interactable: Interactable

func on_interact() -> void:
	print(self , " interacted with")
	await Helpers.wait(0.50)
	interactable.on_finish()
