extends Node2D

@export_category("Options")
@export var random_interior: bool = false
@export_category("Data")
@export var id: int = 000
@export var building_type: BuildingData.BuildingTypes
@export var exterior_sprite: Sprite2D
@export var interior_scene: PackedScene
@export var transition_area: Area2D
@export var exit_point: Node2D

func _on_transition_area_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	if interior_scene:
		GameEvents.goto_scene(interior_scene)


func _ready() -> void:
	load_interior()

func load_interior() -> void:
	if id in BuildingData.loaded_interiors:
		interior_scene = BuildingData.loaded_interiors[id]
		return

	if random_interior:
		interior_scene = BuildingData.randomize_interior(building_type)
		BuildingData.loaded_interiors[id] = interior_scene
		return
