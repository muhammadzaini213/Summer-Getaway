extends Node

const FLAGS :={
	# NPC / dialogue flags
	"old_man_requested_rock": true,
	"rock_removed": true,
	# World state flags
	
	# Inventory flags
	"has_ancient_coin": true
}

func is_valid_flag(flag_name: String) -> bool:
	return FLAGS.has(flag_name)


func get_all_flags() -> Array:
	return FLAGS.keys()
