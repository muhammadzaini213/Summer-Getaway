extends Node

var flags := {}


func set_flag(flag_name: String, value: bool = true) -> void:
	flags[flag_name] = value


func has_flag(flag_name: String) -> bool:
	return flags.get(flag_name, false)


func remove_flag(flag_name: String) -> void:
	flags.erase(flag_name)
