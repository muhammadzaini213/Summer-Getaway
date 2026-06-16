extends Node

var used_layouts := {}

enum BuildingTypes {
	CABIN,
	HOTEL,
}
var interior_scenes: Dictionary = {

	BuildingTypes.CABIN: {
		"layout_one": preload("uid://bcgg5bk68tkih"),
		"layout_two": preload("uid://b3k2d5sojvah6"),
	}

}


var loaded_interiors: Dictionary = {


}

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
