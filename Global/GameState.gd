extends Node


var flags := {}
var island_return_position := Vector2.ZERO
var has_island_return_position := false
var pub_return_position : Vector2 = Vector2.ZERO

func set_island_return_position(position: Vector2) -> void:
	island_return_position = position
	has_island_return_position = true


func consume_island_return_position() -> Vector2:
	has_island_return_position = false
	return island_return_position

func set_flag(flag_name: String, value: bool = true) -> void:
	if not FlagRegistry.is_valid_flag(flag_name):
		push_error("Trying to set unknown flag: " + flag_name)
		return

	flags[flag_name] = value


func has_flag(flag_name: String) -> bool:
	if not FlagRegistry.is_valid_flag(flag_name):
		push_error("Trying to check unknown flag: " + flag_name)
		return false

	return flags.get(flag_name, false)


func remove_flag(flag_name: String) -> void:
	if not FlagRegistry.is_valid_flag(flag_name):
		push_error("Trying to remove unknown flag: " + flag_name)
		return

	flags.erase(flag_name)
