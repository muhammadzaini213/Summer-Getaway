class_name BulletFinalFight
extends Node2D

var _ref := Vector2(1, 0)
var dir := Vector2(1, 0)
var target: CharacterBody2D

func _ready() -> void:
	$BulletArea.body_entered.connect(on_body_entered)

func _physics_process(delta: float) -> void:
	position += dir * delta * 100.0
	var angle := acos(_ref.dot(dir))
	rotation = angle

func set_param(direc: Vector2, tgt: CharacterBody2D) -> void:
	dir = direc
	target = tgt

func on_body_entered(body: Node2D) -> void:
	if body == target:
		target.is_hit()
		queue_free()
