class_name Interactable extends Area2D
# This scripts main scene should be put as a child to the object that is to be interacted with.
# The object just needs an on_interaction() function to work.

var user: CharacterBody2D
var interaction_object

func _ready():
	interaction_object = get_parent()


func _on_body_entered(body: Node2D) -> void:
	if user == body:
		return

	if !body.is_in_group("player"):
		return

	user = body
	if interaction_object:
		user.interact.connect(pass_interaciton)

func _on_body_exited(body: Node2D) -> void:
	if user != body:
		return

	if !body.is_in_group("player"):
		return

	if interaction_object:
		user.interact.disconnect(pass_interaciton)

	user = null
	

func pass_interaciton() -> void:
	if not interaction_object:
		return

	interaction_object.on_interact()