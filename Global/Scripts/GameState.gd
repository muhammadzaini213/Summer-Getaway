extends Node


var flags := {}

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
