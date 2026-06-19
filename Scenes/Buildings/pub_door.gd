extends Area2D

@export var interior_scene : PackedScene

var player_near := false


func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body):

	if body.name == "Player":
		player_near = true


func _on_body_exited(body):

	if body.name == "Player":
		player_near = false


func _process(_delta):

	if player_near and Input.is_action_just_pressed("interact"):

		var player = get_tree().get_first_node_in_group("player")

		if player:
			GameState.pub_return_position = player.global_position

		print("[DEBUG] Entering Pub")

		get_tree().change_scene_to_packed(interior_scene)
