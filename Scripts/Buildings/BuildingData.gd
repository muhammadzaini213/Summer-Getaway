extends Node


var used_layouts := {}

enum BuildingTypes {
	CABIN,
	HOTEL,
}

var interior_scenes: Dictionary = {

	BuildingTypes.CABIN: {

		"house_1": preload("res://Scenes/Buildings/Cabin/Interiors/house_1.tscn"),

		"house_2": preload("res://Scenes/Buildings/Cabin/Interiors/house_2.tscn"),

		"house_3": preload("res://Scenes/Buildings/Cabin/Interiors/house_3.tscn"),

		"house_4": preload("res://Scenes/Buildings/Cabin/Interiors/house_4.tscn"),

		"house_5": preload("res://Scenes/Buildings/Cabin/Interiors/house_5.tscn"),

		"house_6": preload("res://Scenes/Buildings/Cabin/Interiors/house_6.tscn"),

		"house_7": preload("res://Scenes/Buildings/Cabin/Interiors/house_7.tscn"),

		"house_8": preload("res://Scenes/Buildings/Cabin/Interiors/house_8.tscn"),

		"house_9": preload("res://Scenes/Buildings/Cabin/Interiors/house_9.tscn")
	}
}


var loaded_interiors: Dictionary = {
}

var house_npc_ids: Dictionary = {}
var murderer_house_id: int = -1
var murderer_npc_id: String = ""
var murderer_interior_key: StringName = &"house_5"



func randomize_interior(type: BuildingTypes) -> PackedScene:
	var layouts = interior_scenes[type]

	if !used_layouts.has(type):
		used_layouts[type] = []

	var available_keys = []

	for key in layouts.keys():
		if key not in used_layouts[type]:
			available_keys.append(key)

	# If all layouts have been used, allow reuse(only for testing 
	#purpose, as if we do not have enough interiors, this is just for safety btw
	if available_keys.is_empty():
		available_keys = layouts.keys()

	var chosen_key = available_keys.pick_random()

	if chosen_key not in used_layouts[type]:
		used_layouts[type].append(chosen_key)

	return layouts[chosen_key]


func assign_murderer() -> void:
	murderer_house_id = -1
	murderer_npc_id = ""

	var house_ids := loaded_interiors.keys()
	house_ids.sort()

	for house_id in house_ids:
		if _is_murderer_interior(loaded_interiors[house_id]):
			murderer_house_id = int(house_id)
			murderer_npc_id = String(house_npc_ids.get(house_id, ""))
			return


func is_correct_accusation(accused_npc_id) -> bool:
	return str(accused_npc_id) == murderer_npc_id


func _is_murderer_interior(interior_scene: PackedScene) -> bool:
	for type in interior_scenes.keys():
		var layouts = interior_scenes[type]
		if layouts.has(murderer_interior_key) and layouts[murderer_interior_key] == interior_scene:
			return true

	return false
