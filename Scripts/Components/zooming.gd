class_name Zooming
extends Node2D

@export var zoomable: Texture2D

@onready var bg: ColorRect = $BG
@onready var item: Sprite2D = $Item
@onready var interactable: Interactable = $Interactable

var item_shown := false

func _ready() -> void:
	bg.modulate = Color(1, 1, 1, 0)
	item.modulate = Color(1, 1, 1, 0)
	item.texture = zoomable
	interactable.interact.connect(_on_interact)

func _process(delta: float) -> void:
	if item_shown and Input.is_action_just_pressed("interact"):
		var tween1 := get_tree().create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		tween1.tween_property(bg, "modulate", Color(1, 1, 1, 0), 0.25)
		tween1.tween_property(item, "modulate", Color(1, 1, 1, 0), 0.5)
		interactable.finish_interact.emit.call_deferred()
		item_shown = false

func _on_interact() -> void:
	
	AudioManager.play_sfx(AudioManager.NOTICE)
	var view := get_viewport()
	var cam := view.get_camera_2d()
	bg.global_position = cam.global_position - bg.size/2
	item.global_position = cam.global_position
	var tween1 := get_tree().create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween1.tween_property(bg, "modulate", Color(1, 1, 1, 1), 0.25)
	tween1.tween_property(item, "modulate", Color(1, 1, 1, 1), 0.5)
	await get_tree().create_timer(0.1).timeout
	item_shown = true
