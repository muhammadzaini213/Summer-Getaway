extends Node


@export var fisherman: Node2D


func _ready() -> void:

	DaySystem.day_started.connect(
		_on_day_started
	)

	_on_day_started(
		DaySystem.current_day
	)


func _on_day_started(day: int) -> void:

	if fisherman == null:
		return

	var unlocked := day >= 0

	fisherman.visible = unlocked

	fisherman.process_mode = (
		Node.PROCESS_MODE_INHERIT
		if unlocked
		else
		Node.PROCESS_MODE_DISABLED
	)

	print(
		"[DEBUG] Fisherman unlocked:",
		unlocked
	)
