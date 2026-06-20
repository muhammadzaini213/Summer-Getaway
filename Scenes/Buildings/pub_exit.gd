extends Area2D

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

		print("[DEBUG] Leaving Pub")
		
		AudioManager.play_sfx(AudioManager.CLOSE_DOOR)

		get_tree().change_scene_to_file(
			"res://Scenes/Worlds/Levels/island.tscn"
		)
