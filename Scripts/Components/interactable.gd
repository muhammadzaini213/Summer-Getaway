class_name Interactable extends Area2D

signal interact
signal finish_interact

@export var can_interact: bool = true
@export var lock_player: bool = false
var user: CharacterBody2D


func _ready() -> void:
	finish_interact.connect(finish_interaction)
	
	if can_interact:
		activate()
	else:
		deactivate()
	
	user = get_tree().get_first_node_in_group("player")

func start_interaction() -> void:
	interact.emit()
	deactivate()

	if lock_player:
		user.can_move = false


func finish_interaction() -> void:
	if lock_player:
		user.can_move = true
		
	activate()


func activate() -> void:
	monitorable = true


func deactivate() -> void:
	monitorable = false
