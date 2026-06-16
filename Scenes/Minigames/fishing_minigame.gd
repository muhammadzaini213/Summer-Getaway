extends Control

enum FishingState {
	IDLE,
	AIMING,
	CASTING,
	CATCHING,
	COMPLETE
}

@export var target_fish_count := 5
@export var required_hold_time := 4.0
@export var hook_speed := 700.0
@export var fish_radius := 32.0
@export var hook_start_offset := Vector2(0, -240)

@onready var background: ColorRect = $Background
@onready var fish_target: TextureRect = $FishTarget
@onready var hook: TextureRect = $Hook
@onready var line: Line2D = $Line
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var counter_label: Label = $CounterLabel
@onready var instruction_label: Label = $InstructionLabel
@onready var exit_button: Button = $ExitButton

var state: FishingState = FishingState.IDLE

var caught_fish_count := 0
var hold_time := 0.0

var hook_start_position := Vector2.ZERO
var hook_target_position := Vector2.ZERO
var hook_direction := Vector2.ZERO


func _ready() -> void:
	visible = false


	hook.visible = false
	fish_target.visible = false
	progress_bar.value = 0

	line.clear_points()
	start_minigame()

func start_minigame() -> void:
	visible = true
	state = FishingState.AIMING

	caught_fish_count = 0
	hold_time = 0.0

	progress_bar.value = 0
	hook.visible = true
	fish_target.visible = true

	hook_start_position = get_viewport_rect().size / 2.0 + hook_start_offset
	hook.global_position = hook_start_position

	spawn_fish()
	update_ui()

	instruction_label.text = "Aim with mouse. Press LMB to cast."


func _process(delta: float) -> void:
	if state == FishingState.IDLE:
		return

	update_line()

	match state:
		FishingState.AIMING:
			handle_aiming()

		FishingState.CASTING:
			handle_casting(delta)

		FishingState.CATCHING:
			handle_catching(delta)

		FishingState.COMPLETE:
			pass


func handle_aiming() -> void:
	hook.global_position = hook_start_position

	if Input.is_action_just_pressed("mouse_left"):
		hook_target_position = get_global_mouse_position()
		hook_direction = hook_start_position.direction_to(hook_target_position)

		if hook_direction == Vector2.ZERO:
			return

		state = FishingState.CASTING
		instruction_label.text = "Casting..."


func handle_casting(delta: float) -> void:
	hook.global_position += hook_direction * hook_speed * delta

	if hook_hits_fish():
		state = FishingState.CATCHING
		hold_time = 0.0
		progress_bar.value = 0
		instruction_label.text = "Fish hooked! Hold LMB for 4 seconds."
		return

	if hook.global_position.distance_to(hook_start_position) > hook_start_position.distance_to(hook_target_position):
		reset_cast("Missed! Try again.")


func handle_catching(delta: float) -> void:
	if Input.is_action_pressed("mouse_left"):
		hold_time += delta
		progress_bar.value = (hold_time / required_hold_time) * 100.0

		if hold_time >= required_hold_time:
			catch_fish()
	else:
		reset_cast("Fish escaped! Cast again.")


func hook_hits_fish() -> bool:
	var fish_center := fish_target.global_position + fish_target.size / 2.0
	var hook_center := hook.global_position + hook.size / 2.0

	return hook_center.distance_to(fish_center) <= fish_radius


func catch_fish() -> void:
	caught_fish_count += 1
	hold_time = 0.0
	progress_bar.value = 0

	if caught_fish_count >= target_fish_count:
		complete_minigame()
	else:
		spawn_fish()
		reset_cast("Caught! Cast again.")


func spawn_fish() -> void:
	var viewport_size := get_viewport_rect().size
	var margin := 400.0

	var x := randf_range(margin, viewport_size.x - margin)
	var y := randf_range(margin, viewport_size.y - margin)

	fish_target.global_position = Vector2(x, y)


func reset_cast(message: String) -> void:
	state = FishingState.AIMING
	hook.global_position = hook_start_position
	hold_time = 0.0
	progress_bar.value = 0
	instruction_label.text = message
	update_ui()


func complete_minigame() -> void:
	state = FishingState.COMPLETE

	instruction_label.text = "You caught 5 fish! The fisherman gives you a clue."
	counter_label.text = "Fish caught: %d / %d" % [caught_fish_count, target_fish_count]

	fish_target.visible = false
	hook.visible = false
	line.clear_points()

	GameState.set_flag("fisherman_clue_unlocked")

	await get_tree().create_timer(1.5).timeout
	close_minigame()


func close_minigame() -> void:
	visible = false
	state = FishingState.IDLE
	line.clear_points()
	progress_bar.value = 0


func update_ui() -> void:
	counter_label.text = "Fish caught: %d / %d" % [caught_fish_count, target_fish_count]


func update_line() -> void:
	line.clear_points()

	if not hook.visible:
		return

	line.add_point(hook_start_position)
	line.add_point(hook.global_position)
