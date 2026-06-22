extends Node

var murderer_sprite_frame := -1
var murderer_sprite_table := {
	'npc1': 3,
	'npc2': 2,
	'npc3': 1,
	'npc4': 6,
	'npc5': 0,
	'npc6': 5,
	'npc7': 8,
	'npc8': 4,
	'npc9': 7
}


func check_accusation(accused_npc_id: String) -> void:
	if accused_npc_id == BuildingData.murderer_npc_id:
		murderer_sprite_frame = murderer_sprite_table[accused_npc_id]
		print("WIN")

		get_tree().change_scene_to_file("res://Scenes/Worlds/Levels/final_fight.tscn")

	else:

		print("LOSE")

		get_tree().change_scene_to_file("uid://dju0leywqnskg")
