extends CanvasLayer

signal accusation_started
signal accusation_finished(suspect_id: String, was_correct: bool)
signal accusation_closed

const MAYOR_ICON_PATH := "res://icon.svg"
const FALLBACK_MAYOR_ICON_PATH := "res://Assets/Assets/placeholder_human.png"
const FINAL_FIGHT_SCENE_PATH := "res://Scenes/Worlds/Levels/final_fight.tscn"

var correct_suspect_id := "suspect_03"
var suspects: Array[Dictionary] = [
	{"id": "suspect_01", "display_name": "Suspect 1"},
	{"id": "suspect_02", "display_name": "Suspect 2"},
	{"id": "suspect_03", "display_name": "Suspect 3"},
	{"id": "suspect_04", "display_name": "Suspect 4"},
]

var _panel: PanelContainer
var _portrait: TextureRect
var _choices: VBoxContainer
var _result_label: Label
var _close_button: Button
var _accusation_active := false


func _ready() -> void:
	layer = 90
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	hide_accusation()


func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return

	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F7:
		open_default_accusation()


func configure_suspects(new_suspects: Array[Dictionary], new_correct_suspect_id: String) -> void:
	suspects = new_suspects
	correct_suspect_id = new_correct_suspect_id


func open_default_accusation() -> void:
	open_accusation(suspects, correct_suspect_id)


func open_accusation(new_suspects: Array[Dictionary], new_correct_suspect_id: String) -> void:
	configure_suspects(new_suspects, new_correct_suspect_id)
	_set_day_timer_paused(true)
	_set_players_can_move(false)
	_accusation_active = true
	visible = true
	_result_label.text = ""
	_close_button.visible = false
	_rebuild_choices()
	accusation_started.emit()


func hide_accusation() -> void:
	visible = false
	_clear_choices()

	if _accusation_active:
		_accusation_active = false
		_set_day_timer_paused(false)
		_set_players_can_move(true)
		accusation_closed.emit()


func _choose_suspect(suspect_id: String) -> void:
	var was_correct := suspect_id == correct_suspect_id

	_clear_choices()
	_close_button.visible = true

	if was_correct:
		GameState.set_flag("killer_identified")
		GameState.set_flag("final_fight_started")
		_result_label.text = "That's the killer. The final fight begins."
		_start_final_fight()
	else:
		GameState.set_flag("wrong_accusation")
		GameState.set_flag("game_lost")
		_result_label.text = "Wrong suspect. The real killer got away."

	accusation_finished.emit(suspect_id, was_correct)


func _start_final_fight() -> void:
	await get_tree().create_timer(1.2).timeout
	hide_accusation()
	get_tree().change_scene_to_file(FINAL_FIGHT_SCENE_PATH)


func _rebuild_choices() -> void:
	_clear_choices()

	for suspect in suspects:
		var suspect_id: String = suspect.get("id", "")
		var display_name: String = suspect.get("display_name", suspect_id)

		var button := Button.new()
		button.text = display_name
		button.custom_minimum_size = Vector2(220.0, 36.0)
		button.set_meta("suspect_id", suspect_id)
		button.pressed.connect(_on_suspect_button_pressed.bind(button))
		_choices.add_child(button)


func _on_suspect_button_pressed(button: Button) -> void:
	_choose_suspect(button.get_meta("suspect_id", ""))


func _clear_choices() -> void:
	if _choices == null:
		return

	for child in _choices.get_children():
		child.queue_free()


func _set_day_timer_paused(paused: bool) -> void:
	var day_system := get_node_or_null("/root/DaySystem")
	if day_system == null:
		return

	if paused:
		day_system.pause_timer()
	else:
		day_system.resume_timer()


func _set_players_can_move(can_move: bool) -> void:
	for node in get_tree().get_nodes_in_group("player"):
		if node.get("can_move") != null:
			node.set("can_move", can_move)


func _load_mayor_texture() -> Texture2D:
	if ResourceLoader.exists(MAYOR_ICON_PATH):
		return load(MAYOR_ICON_PATH)

	if ResourceLoader.exists(FALLBACK_MAYOR_ICON_PATH):
		return load(FALLBACK_MAYOR_ICON_PATH)

	return null


func _build_ui() -> void:
	var fade := ColorRect.new()
	fade.name = "DimBackground"
	fade.color = Color(0.0, 0.0, 0.0, 0.55)
	fade.mouse_filter = Control.MOUSE_FILTER_STOP
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(fade)

	_panel = PanelContainer.new()
	_panel.name = "AccusationPanel"
	_panel.set_anchors_preset(Control.PRESET_CENTER)
	_panel.offset_left = -260.0
	_panel.offset_top = -180.0
	_panel.offset_right = 260.0
	_panel.offset_bottom = 180.0
	add_child(_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	_panel.add_child(margin)

	var layout := VBoxContainer.new()
	layout.alignment = BoxContainer.ALIGNMENT_CENTER
	layout.add_theme_constant_override("separation", 10)
	margin.add_child(layout)

	var header := HBoxContainer.new()
	header.alignment = BoxContainer.ALIGNMENT_CENTER
	header.add_theme_constant_override("separation", 12)
	layout.add_child(header)

	_portrait = TextureRect.new()
	_portrait.custom_minimum_size = Vector2(80.0, 80.0)
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait.texture = _load_mayor_texture()
	header.add_child(_portrait)

	var prompt := VBoxContainer.new()
	prompt.add_theme_constant_override("separation", 4)
	header.add_child(prompt)

	var name_label := Label.new()
	name_label.text = "Mayor"
	name_label.add_theme_font_size_override("font_size", 20)
	prompt.add_child(name_label)

	var question_label := Label.new()
	question_label.text = "Who is the killer?"
	question_label.add_theme_font_size_override("font_size", 24)
	prompt.add_child(question_label)

	_choices = VBoxContainer.new()
	_choices.alignment = BoxContainer.ALIGNMENT_CENTER
	_choices.add_theme_constant_override("separation", 6)
	layout.add_child(_choices)

	_result_label = Label.new()
	_result_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_result_label.add_theme_font_size_override("font_size", 18)
	layout.add_child(_result_label)

	_close_button = Button.new()
	_close_button.text = "Close"
	_close_button.custom_minimum_size = Vector2(120.0, 34.0)
	_close_button.pressed.connect(hide_accusation)
	layout.add_child(_close_button)
