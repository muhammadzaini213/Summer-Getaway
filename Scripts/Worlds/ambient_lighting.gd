class_name AmbientLightingSystem
extends CanvasModulate

@export var day_night_gradient: Gradient

func _process(_delta: float) -> void:
	color = day_night_gradient.sample(1.0 - DaySystem.time_left/DaySystem.day_length_seconds)
