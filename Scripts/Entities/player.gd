# This is the main player script. It handles movement, basic state management, and interactions.
extends CharacterBody2D

signal interact()

#region Enums
enum PlayerState {
	IDLE,
	WALK,
	INTERACT
}
#endregion

#region Variables
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export_category("Movement")
@export_subgroup("Speed")
@export var base_speed := 80.0
@export var min_speed: float = 40.0
@export var max_speed: float = 160.0

var speed: float = base_speed
var facing_direction: String = "down"
var can_move: bool = true

@export_category("Player State")
@export var current_state: PlayerState = PlayerState.IDLE
#endregion


func _ready() -> void:

	if get_tree().current_scene.name == "Island":

		if GameState.has_island_return_position:

			global_position = GameState.consume_island_return_position()

	facing_direction = "down"

	animated_sprite_2d.play("idle_down")


func _physics_process(_delta: float) -> void:

	_handle_movement()

	if Input.is_action_just_pressed("interact"):

		interact.emit()


func _handle_movement() -> void:

	var input_dir = Input.get_vector(
		"walk_left",
		"walk_right",
		"walk_up",
		"walk_down"
	)

	if not can_move or input_dir == Vector2.ZERO:

		idle_player()

		return

	facing_direction = Helpers.movement_direction_to_string(input_dir)

	var effective_speed = speed

	if OS.has_feature("editor") and Input.is_key_pressed(KEY_SHIFT):

		effective_speed *= 2

	velocity = input_dir * effective_speed

	move_and_slide()

	if velocity.length_squared() > 1.0:

		current_state = PlayerState.WALK

		_play_direction_animation("walk")

	else:

		idle_player()


func idle_player() -> void:

	# Allow idle animation to play even if already idle
	current_state = PlayerState.IDLE

	_play_direction_animation("idle")


func _play_direction_animation(prefix: String) -> void:

	animated_sprite_2d.flip_h = false

	if prefix == "walk":

		match facing_direction:

			"left":

				animated_sprite_2d.flip_h = true

				animated_sprite_2d.play("walk_side")

			"right":

				animated_sprite_2d.play("walk_side")

			"up":

				animated_sprite_2d.play("walk_up")

			_:

				animated_sprite_2d.play("walk_down")

	else:

		var animation_direction := facing_direction

		if animation_direction == "left":

			animation_direction = "right"

			animated_sprite_2d.flip_h = true

		elif animation_direction == "":

			animation_direction = "down"

		var animation_name := "%s_%s" % [prefix, animation_direction]

		if animated_sprite_2d.animation != animation_name:

			animated_sprite_2d.play(animation_name)
