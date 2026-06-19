class_name HouseExteriorLights
extends Polygon2D

@onready var bloom: Node2D = $Bloom

var _is_on := true

func _process(delta: float) -> void:
	if DaySystem.time_left < 130 and not _is_on:
		_flash()
		_is_on = true
	elif DaySystem.time_left > 130 and _is_on:
		_flash(Color(0, 0, 0, 1))
		_is_on = false

func _flash(tgt := Color(1, 1, 1, 1)) -> void:
	var tweener := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC).set_parallel()
	tweener.tween_property(self, "modulate", tgt, 1.0)
	tweener.tween_property(bloom, "modulate", tgt, 1.0)
