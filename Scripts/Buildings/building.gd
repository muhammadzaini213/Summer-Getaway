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
@export var exit_point: Node2D
@export_category("")
@export_file_path("*.tscn") var int_scn_pth: String

func _on_transition_area_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	_enter_building(body)


func _on_interact() -> void:
	#_enter_building(interactable.user)
	AudioManager.play_sfx(AudioManager.OPEN_DOOR)
	GameState.pub_return_position = interactable.user.global_position
	get_tree().change_scene_to_file(int_scn_pth)


func _enter_building(player: Node2D) -> void:
	load_interior()

	if interior_scene:
		if player:
			GameState.set_island_return_position(player.global_position)
		GameEvents.goto_scene(interior_scene)


func _ready() -> void:
	if interactable:
		interactable.interact.connect(_on_interact)

func load_interior() -> void:
	if id in BuildingData.loaded_interiors:
		interior_scene = BuildingData.loaded_interiors[id]
		return

	if random_interior:
		interior_scene = BuildingData.randomize_interior(building_type)
		BuildingData.loaded_interiors[id] = interior_scene
		return
