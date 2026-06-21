extends Node2D

class_name Building

@export_category("Options")
@export var random_interior: bool = false

@export_category("Data")
@export var id: int = 000
@export var building_type: BuildingData.BuildingTypes

@export var exterior_sprite: Sprite2D
@export var interior_scene: PackedScene

@export var transition_area: Area2D
@export var interactable: Interactable

# This should point to the player's spawn position INSIDE the house
@export var exit_point: Node2D


func _ready() -> void:

	if interactable:

		interactable.interact.connect(_on_interact)


func _on_transition_area_body_entered(body: Node2D) -> void:

	if not body.is_in_group("player"):

		return

	_enter_building(body)


func _on_interact() -> void:

	AudioManager.play_sfx(
		AudioManager.OPEN_DOOR
	)

	_enter_building(
		interactable.user
	)


func _enter_building(player: Node2D) -> void:

	load_interior()

	if not interior_scene:

		return

	GameState.set_island_return_position(
		player.global_position
	)

	GameEvents.goto_scene(
		interior_scene
	)


func load_interior() -> void:

	# House already has an assigned interior
	if id in BuildingData.loaded_interiors:

		interior_scene = BuildingData.loaded_interiors[id]

		return


	# Randomly assign one
	if random_interior:

		interior_scene = BuildingData.randomize_interior(
			building_type
		)

		BuildingData.loaded_interiors[id] = interior_scene
