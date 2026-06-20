extends Area2D

var player_near := false


func _on_body_entered(body):

	if body.is_in_group("player"):

		player_near = true


func _on_body_exited(body):

	if body.is_in_group("player"):

		player_near = false


func _process(_delta):

	if player_near and Input.is_action_just_pressed("interact"):

		get_tree().change_scene_to_file(
			"res://Scenes/Worlds/Levels/island.tscn"
		)
