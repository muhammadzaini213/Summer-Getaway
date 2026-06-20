extends Node2D

var player_near_exit := false


func _ready() -> void:
	$ExitRocks/Area2D.body_entered.connect(_on_enter)
	$ExitRocks/Area2D.body_exited.connect(_on_exit)

	var player = get_tree().get_first_node_in_group("player")

	if player:
		player.global_position = $PlayerSpawn.global_position


func _process(_delta: float) -> void:
	if player_near_exit and Input.is_action_just_pressed("interact"):
		get_tree().change_scene_to_file(
			"res://Scenes/Worlds/Levels/island.tscn"
		)


func _on_enter(body) -> void:
	if body.is_in_group("player"):
		player_near_exit = true


func _on_exit(body) -> void:
	if body.is_in_group("player"):
		player_near_exit = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
