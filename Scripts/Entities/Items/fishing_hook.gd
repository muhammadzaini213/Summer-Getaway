class_name FishingHook
extends Node2D

var shadow_dist_delta := 0.0:
	set(sdd):
		shadow_dist_delta = clamp(sdd, 0.0, 1.0)

@onready var _shadow := $Hook/Shadow
@onready var _fish := $Fish

func _process(_delta: float) -> void:
	_shadow.position = Vector2(0, shadow_dist_delta * 200.0)

func show_fish() -> void:
	_fish.show()
