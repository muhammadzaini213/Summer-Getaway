extends Area2D

@export var item_flag := "has_ancient_coin"

var player_near := false


func _ready() -> void:
	if GameState.has_flag(item_flag):
		queue_free()


func _process(_delta: float) -> void:
	if player_near and Input.is_action_just_pressed("interact"):	
		GameState.set_flag(item_flag)
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_near = true


func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_near = false
