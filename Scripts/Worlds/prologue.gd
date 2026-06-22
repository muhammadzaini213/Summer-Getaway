extends Control

@onready var slides: Array[Control] = [$Slide1, $Slide2, $Slide3, $Slide4, $Slide5, $Slide6]
var slide_counter := -1

func _ready() -> void:
	_initialize.call_deferred()

func _advance() -> void:
	var last := slides[slide_counter]
	slide_counter += 1
	if slide_counter >= slides.size():
		get_tree().change_scene_to_file("uid://biv4rplw8i0h2")
		return
	var next := slides[slide_counter]
	var tweener := get_tree().create_tween().set_parallel()
	tweener.tween_property(last, "modulate", Color(1, 1, 1, 0), 1.0)
	tweener.tween_property(next, "modulate", Color(1, 1, 1, 1), 1.0)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("shoot"):
		_advance()

func _initialize() -> void:
	for slide: Control in slides:
		slide.modulate = Color(1, 1, 1, 0)
	slide_counter += 1
	var next := slides[slide_counter]
	var tweener := get_tree().create_tween().set_parallel()
	tweener.tween_property(next, "modulate", Color(1, 1, 1, 1), 1.0)
