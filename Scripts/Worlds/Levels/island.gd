@tool # TODO: remove
extends Node2D

const TILE_SIZE := 16
const WATER_SOURCE := 0
const GRASS_SOURCE := 1
const SAND_SOURCE := 2
const DIRT_SOURCE := 3

const WATER_FILL_TILE := Vector2i(0, 0)
const GRASS_FILL_TILES := [Vector2i(0, 0)]
const SAND_FILL_TILES := [Vector2i(0, 0)]
const DIRT_FILL_TILES := [Vector2i(0, 0)]

const MAP_MIN_X := -40
const MAP_MAX_X := 44
const MAP_MIN_Y := -20
const MAP_MAX_Y := 20

var intro_dialogue = preload("res://dialogues/intro.dialogue")

func _ready() -> void:
	
	call_deferred("try_intro")
	AudioManager.play_bgm.call_deferred("res://Assets/Audio/mus_gameplay.ogg")
	add_to_group("terrain")

	if not Engine.is_editor_hint():

		_register_murderer_ids()
	
	if not DaySystem.day_system_started:
		DaySystem.activate_day_system()
		DaySystem.day_system_started = true
	
	if GameState.has_island_return_position:

		$Player.global_position = (
			GameState.consume_island_return_position()
		)

	elif GameState.pub_return_position != Vector2.ZERO:

		$Player.global_position = (
			GameState.pub_return_position
		)

		GameState.pub_return_position = Vector2.ZERO

	elif GameState.cave_return_position != Vector2.ZERO:

		$Player.global_position = (
			GameState.cave_return_position
		)

		GameState.cave_return_position = Vector2.ZERO
		



func try_intro():
	if GameState.has_seen_intro:
		return

	GameState.has_seen_intro = true
	DialogueManager.show_dialogue_balloon(intro_dialogue)

func _register_murderer_ids() -> void:
	var houses := []
	var npcs := []

	for child in $Buildings.get_children():
		if child is Building:
			houses.append(child)
	for child in $Characters.get_children():
		npcs.append(child)

	houses.sort_custom(func(a, b): return a.id < b.id)
	npcs.sort_custom(func(a, b): return String(a.name) < String(b.name))

	BuildingData.house_npc_ids.clear()

	var house_ids := []
	for house in houses:
		house.load_interior()
		house_ids.append(house.id)

		var npc = _get_closest_npc(house, npcs)
		if npc:
			BuildingData.house_npc_ids[house.id] = String(npc.name)

	var npc_ids := []
	for npc in npcs:
		npc_ids.append(String(npc.name))

	BuildingData.assign_murderer()

	print("[DEBUG] House IDs found: ", house_ids)
	print("[DEBUG] NPC IDs found: ", npc_ids)
	print("[DEBUG] House -> NPC mapping: ", BuildingData.house_npc_ids)
	print("[DEBUG] Murderer house: ", BuildingData.murderer_house_id)
	print("[DEBUG] Murderer NPC: ", BuildingData.murderer_npc_id)


func _get_closest_npc(house: Building, npcs: Array) -> Node2D:
	var closest_npc: Node2D = null
	var closest_distance := INF

	for npc in npcs:
		var distance := house.global_position.distance_squared_to(_get_npc_world_position(npc))
		if distance < closest_distance:
			closest_distance = distance
			closest_npc = npc

	return closest_npc


func _get_npc_world_position(npc: Node2D) -> Vector2:
	for child in npc.get_children():
		if child is Node2D:
			return child.global_position

	return npc.global_position
