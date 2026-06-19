extends Node


func check_accusation(accused_npc_id: String) -> void:

	if accused_npc_id == BuildingData.murderer_npc_id:

		print("WIN")

		get_tree().change_scene_to_file("res://Scenes/Worlds/Levels/final_fight.tscn")

	else:

		print("LOSE")

		get_tree().change_scene_to_file("res://Scenes/Buildings/pub_interior.tscn")
