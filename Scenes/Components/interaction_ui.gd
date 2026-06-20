extends CanvasLayer

@onready var prompt = $Prompt

@export var e_texture: Texture2D
@export var e_pressed_texture: Texture2D

@export var z_texture: Texture2D
@export var z_pressed_texture: Texture2D


func _ready() -> void:
	hide()


func show_e() -> void:
	show()
	prompt.texture = e_texture


func show_z() -> void:
	show()
	prompt.texture = z_texture


func hide_prompt() -> void:
	hide()


func press_e() -> void:
	prompt.texture = e_pressed_texture

	await get_tree().create_timer(0.12).timeout

	prompt.texture = e_texture


func press_z() -> void:
	prompt.texture = z_pressed_texture

	await get_tree().create_timer(0.12).timeout

	prompt.texture = z_texture
