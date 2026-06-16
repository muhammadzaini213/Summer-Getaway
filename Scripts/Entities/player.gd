# This is the main player script. It handles movement, basic state management, and interactions.
extends CharacterBody2D

@warning_ignore("unused_signal")
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
@export var base_speed := 50.0
@export var min_speed: float = 25.0
@export var max_speed: float = 100.0
var speed: float = base_speed
var moving_direction: Vector2
var facing_direction: String
var is_moving: bool = false
var can_move: bool = true
var target_position: Vector2

@export_category("Player State")
@export var current_state: PlayerState = PlayerState.IDLE
#endregion


func _ready() -> void:
	target_position = global_position


func _physics_process(delta: float) -> void:
	if is_moving:
		move_to_target(delta)
	else:
		check_for_new_move()


func _input(_event) -> void:
	if Input.is_action_just_pressed("interact"):
		interact.emit()

# Checks for new movement input and starts moving if any is detected. If no input is detected, the player will idle.
func check_for_new_move() -> void:
	var input_dir = Vector2.ZERO

	if Input.is_action_pressed("walk_right"):
		input_dir = Vector2.RIGHT
		$AnimatedSprite2D.play("walk_right")
	elif Input.is_action_pressed("walk_left"):
		input_dir = Vector2.LEFT
		$AnimatedSprite2D.play("walk_right")
	elif Input.is_action_pressed("walk_down"):
		input_dir = Vector2.DOWN
		$AnimatedSprite2D.play("walk_right")
	elif Input.is_action_pressed("walk_up"):
		input_dir = Vector2.UP
		$AnimatedSprite2D.play("walk_right")
	
	if input_dir == Vector2.ZERO:
		idle_player()
		return
	
	if can_move:
		start_move(input_dir)


# Starts the movement process
func start_move(direction: Vector2) -> void:
	moving_direction = direction
	facing_direction = Helpers.movement_direction_to_string(direction)

	target_position = global_position + direction
	if not _can_walk_to(target_position):
		target_position = global_position
		idle_player()
		return

	is_moving = true

	current_state = PlayerState.WALK

	_play_direction_animation("walk")


# Moves the player towards the target position on a grid.
# Player may need to be starting in the center of a tile for this to work properly
func move_to_target(delta: float) -> void:
	global_position = global_position.move_toward(
		target_position,
		speed * delta
	)

	if global_position == target_position:
		is_moving = false

		check_for_new_move()


func idle_player() -> void:
	if current_state == PlayerState.IDLE or current_state == PlayerState.INTERACT:
		return

	current_state = PlayerState.IDLE
	_play_direction_animation("idle")


func _can_walk_to(world_position: Vector2) -> bool:
	for terrain in get_tree().get_nodes_in_group("terrain"):
		if terrain.has_method("is_walkable_world_position"):
			return terrain.is_walkable_world_position(world_position)

	return true


func _play_direction_animation(prefix: String) -> void:
	var animation_direction := facing_direction
	animated_sprite_2d.flip_h = false

	if animation_direction == "left":
		animation_direction = "right"
		animated_sprite_2d.flip_h = true
	elif animation_direction == "":
		animation_direction = "down"

	var animation_name := "%s_%s" % [prefix, animation_direction]
	if animated_sprite_2d.animation != animation_name:
		animated_sprite_2d.play(animation_name)
