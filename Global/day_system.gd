extends CanvasLayer

signal day_started(day: int)
signal day_ended(day: int)

const DEFAULT_DAY_LENGTH_SECONDS := 390.0
const END_MESSAGE := "It's getting late, detective. Let's continue tomorrow."

var current_day := 1
var day_length_seconds := DEFAULT_DAY_LENGTH_SECONDS
var time_left := DEFAULT_DAY_LENGTH_SECONDS
var timer_running := true
var transition_running := false

var _timer_label: Label
var _fade: ColorRect
var _message_box: PanelContainer
var _message_label: Label


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	_start_day(current_day)


func _process(delta: float) -> void:
	if not timer_running or transition_running:
		return

	time_left = maxf(time_left - delta, 0.0)
	_update_timer_label()

	if time_left <= 0.0:
		_end_day()


func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return

	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F6:
		force_end_day()


func pause_timer() -> void:
	timer_running = false


func resume_timer() -> void:
	if transition_running:
		return

	timer_running = true


func start_next_day() -> void:
	current_day += 1
	_start_day(current_day)


func force_end_day() -> void:
	if transition_running:
		return

	time_left = 0.0
	_end_day()


func set_day_length(seconds: float) -> void:
	day_length_seconds = maxf(seconds, 1.0)
	time_left = minf(time_left, day_length_seconds)
	_update_timer_label()


func _start_day(day: int) -> void:
	time_left = day_length_seconds
	timer_running = true
	transition_running = false
	get_tree().paused = false
	_set_players_can_move(true)
	_fade.modulate.a = 0.0
	_fade.visible = false
	_message_box.visible = false
	_update_timer_label()
	day_started.emit(day)


func _end_day() -> void:
	timer_running = false
	transition_running = true
	get_tree().paused = true
	_set_players_can_move(false)
	day_ended.emit(current_day)

	_fade.visible = true
	_message_box.visible = true
	_message_label.text = END_MESSAGE

	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(_fade, "modulate:a", 0.85, 0.7)
	tween.parallel().tween_property(_message_box, "modulate:a", 1.0, 0.4)
	tween.tween_interval(2.6)
	tween.tween_property(_message_box, "modulate:a", 0.0, 0.3)
	tween.tween_property(_fade, "modulate:a", 0.0, 0.5)
	await tween.finished

	start_next_day()


func _set_players_can_move(can_move: bool) -> void:
	for node in get_tree().get_nodes_in_group("player"):
		if node.get("can_move") != null:
			node.set("can_move", can_move)


func _update_timer_label() -> void:
	if _timer_label == null:
		return

	var minutes := floori(time_left / 60.0)
	var seconds := int(time_left) % 60
	_timer_label.text = "Day %d  %02d:%02d" % [current_day, minutes, seconds]


func _build_ui() -> void:
	_timer_label = Label.new()
	_timer_label.name = "TimerLabel"
	_timer_label.top_level = false
	_timer_label.text = ""
	_timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_timer_label.add_theme_font_size_override("font_size", 18)
	_timer_label.add_theme_color_override("font_color", Color(1.0, 0.96, 0.82))
	_timer_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.8))
	_timer_label.add_theme_constant_override("shadow_offset_x", 2)
	_timer_label.add_theme_constant_override("shadow_offset_y", 2)
	_timer_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_timer_label.offset_left = -190.0
	_timer_label.offset_top = 12.0
	_timer_label.offset_right = -12.0
	_timer_label.offset_bottom = 44.0
	add_child(_timer_label)

	_fade = ColorRect.new()
	_fade.name = "Fade"
	_fade.color = Color.BLACK
	_fade.visible = false
	_fade.modulate.a = 0.0
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_fade)

	_message_box = PanelContainer.new()
	_message_box.name = "EndDayMessage"
	_message_box.visible = false
	_message_box.modulate.a = 0.0
	_message_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_message_box.set_anchors_preset(Control.PRESET_CENTER)
	_message_box.offset_left = -230.0
	_message_box.offset_top = -44.0
	_message_box.offset_right = 230.0
	_message_box.offset_bottom = 44.0
	add_child(_message_box)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 12)
	_message_box.add_child(margin)

	_message_label = Label.new()
	_message_label.name = "MessageLabel"
	_message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_message_label.add_theme_font_size_override("font_size", 20)
	_message_label.text = END_MESSAGE
	margin.add_child(_message_label)
