class_name Fish
extends Node2D

@onready var sprite: Node2D = $Sprite
@onready var tweener: Tween = create_tween().bind_node(self).set_parallel()

var fade_time := randf_range(1.0, 2.0)

func _ready() -> void:
	sprite.modulate = Color(1, 1, 1, 0)
	_flash.call_deferred()

func _process(delta: float) -> void:
	position += Vector2(1, 0) * delta * 10

func _flash() -> void:
	tweener.tween_property(sprite, "modulate", Color(1, 1, 1, 1), fade_time)
	await tweener.finished
	tweener.stop()
	tweener.tween_property(sprite, "modulate", Color(1, 1, 1, 0), fade_time)
	tweener.play()
	await tweener.finished#get_tree().create_timer(fade_time).timeout
	queue_free()
