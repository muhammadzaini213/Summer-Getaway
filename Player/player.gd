class_name Player extends CharacterBody2D
# This is the main player script. It handles movement, basic state management, and interactions.

#region Enums
enum PlayerState {
	IDLE,
	WALK,
	INTERACT
}
#endregion

#region Variables
@export_category("Attributes")
@export var speed = 200.0
@export_category("Player State")
@export var current_state: PlayerState = PlayerState.IDLE

var moving_direction: Vector2
var facing_direction: String
var moving: bool

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
#endregion


func _physics_process(_delta: float) -> void:
	moving_direction = Vector2.ZERO

# This section checks for player input and updates the moving direction accordingly. It also sets the moving flag based on whether there is any input.
	if Input.is_action_pressed("walk_right"):
		moving_direction.x += 1

	if Input.is_action_pressed("walk_left"):
		moving_direction.x -= 1

	if Input.is_action_pressed("walk_down"):
		moving_direction.y += 1

	if Input.is_action_pressed("walk_up"):
		moving_direction.y -= 1

	moving = moving_direction != Vector2.ZERO

# This section checks if the player is moving and calls the appropriate function to handle movement or idle state.
	if moving:
		move_player()
	else:
		idle_player()


# This function handles player movement. It normalizes the movement direction, calculates velocity, and updates the facing direction based on input.
func move_player() -> void:
	current_state = PlayerState.WALK
	moving_direction = moving_direction.normalized()
	velocity = moving_direction * speed
	facing_direction = Helpers.movement_direction_to_string(moving_direction)

	animated_sprite_2d.play("walk_" + facing_direction)
	move_and_slide()

# This function handles the player idle state. It sets the current state to IDLE, resets velocity, and plays the appropriate idle animation based on the facing direction.
func idle_player() -> void:
	if current_state == PlayerState.IDLE:
		return

	current_state = PlayerState.IDLE
	velocity = Vector2.ZERO
	animated_sprite_2d.play("idle_" + facing_direction)
