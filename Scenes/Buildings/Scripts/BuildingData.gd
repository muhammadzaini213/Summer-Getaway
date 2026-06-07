extends Node

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
	if not interior_scenes.has(type):
		push_error("no type")
		return null

	var layouts = interior_scenes[type]
	var keys = layouts.keys()
	var random_key = keys.pick_random()

	return layouts[random_key]
