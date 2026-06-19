extends CanvasLayer

signal accusation_started
signal accusation_finished(suspect_id: String, was_correct: bool)
signal accusation_closed

const MAYOR_ICON_PATH := "res://icon.svg"
const FALLBACK_MAYOR_ICON_PATH := "res://Assets/Assets/placeholder_human.png"

var correct_suspect_id := ""
var suspects: Array[Dictionary] = []

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

	if event is InputEventKey \
	and event.pressed \
	and not event.echo \
	and event.keycode == KEY_F7:

		open_default_accusation()


func configure_suspects(
	new_suspects: Array[Dictionary],
	new_correct_suspect_id: String
) -> void:

	suspects = new_suspects
	correct_suspect_id = new_correct_suspect_id


func open_default_accusation() -> void:

	open_accusation(
		suspects,
		correct_suspect_id
	)


func open_accusation(
	new_suspects: Array[Dictionary],
	new_correct_suspect_id: String
) -> void:

	configure_suspects(
		new_suspects,
		new_correct_suspect_id
	)

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

	var was_correct := BuildingData.is_correct_accusation(
		suspect_id
	)

	print("[DEBUG] Player chose:", suspect_id)

	print("[DEBUG] Actual killer:", BuildingData.murderer_npc_id)

	print("[DEBUG] Result:", was_correct)

	_clear_choices()

	hide_accusation()

	accusation_finished.emit(
		suspect_id,
		was_correct
	)

	if was_correct:

		print("[DEBUG] Correct accusation")

		get_tree().change_scene_to_file(
			"res://Scenes/Worlds/Levels/final_fight.tscn"
		)

	else:

		print("[DEBUG] Wrong accusation")

		get_tree().change_scene_to_file(
			"res://Scenes/main_menu.tscn"
		)


func _rebuild_choices() -> void:

	_clear_choices()

	for suspect in suspects:

		var suspect_id: String = suspect.get(
			"id",
			""
		)

		var display_name: String = suspect.get(
			"display_name",
			suspect_id
		)

		var button := Button.new()

		button.text = display_name

		button.custom_minimum_size = Vector2(
			220.0,
			36.0
		)

		button.set_meta(
			"suspect_id",
			suspect_id
		)

		button.pressed.connect(
			_on_suspect_button_pressed.bind(
				button
			)
		)

		_choices.add_child(button)


func _on_suspect_button_pressed(
	button: Button
) -> void:

	_choose_suspect(
		button.get_meta(
			"suspect_id",
			""
		)
	)


func _clear_choices() -> void:

	if _choices == null:
		return

	for child in _choices.get_children():

		child.queue_free()


func _set_day_timer_paused(
	paused: bool
) -> void:

	var day_system := get_node_or_null(
		"/root/DaySystem"
	)

	if day_system == null:
		return

	if paused:

		day_system.pause_timer()

	else:

		day_system.resume_timer()


func _set_players_can_move(
	can_move: bool
) -> void:

	for node in get_tree().get_nodes_in_group(
		"player"
	):

		if node.get(
			"can_move"
		) != null:

			node.set(
				"can_move",
				can_move
			)


func _load_mayor_texture() -> Texture2D:

	if ResourceLoader.exists(
		MAYOR_ICON_PATH
	):

		return load(
			MAYOR_ICON_PATH
		)

	if ResourceLoader.exists(
		FALLBACK_MAYOR_ICON_PATH
	):

		return load(
			FALLBACK_MAYOR_ICON_PATH
		)

	return null


func _build_ui() -> void:

	var fade := ColorRect.new()

	fade.name = "DimBackground"

	fade.color = Color(
		0,
		0,
		0,
		0.55
	)

	fade.mouse_filter = Control.MOUSE_FILTER_STOP

	fade.set_anchors_preset(
		Control.PRESET_FULL_RECT
	)

	add_child(fade)


	_panel = PanelContainer.new()

	_panel.name = "AccusationPanel"

	_panel.set_anchors_preset(
		Control.PRESET_CENTER
	)

	_panel.offset_left = -260

	_panel.offset_top = -180

	_panel.offset_right = 260

	_panel.offset_bottom = 180

	add_child(
		_panel
	)


	var margin := MarginContainer.new()

	margin.add_theme_constant_override(
		"margin_left",
		18
	)

	margin.add_theme_constant_override(
		"margin_top",
		18
	)

	margin.add_theme_constant_override(
		"margin_right",
		18
	)

	margin.add_theme_constant_override(
		"margin_bottom",
		18
	)

	_panel.add_child(
		margin
	)


	var layout := VBoxContainer.new()

	layout.alignment = BoxContainer.ALIGNMENT_CENTER

	layout.add_theme_constant_override(
		"separation",
		10
	)

	margin.add_child(
		layout
	)


	var header := HBoxContainer.new()

	header.alignment = BoxContainer.ALIGNMENT_CENTER

	header.add_theme_constant_override(
		"separation",
		12
	)

	layout.add_child(
		header
	)


	_portrait = TextureRect.new()

	_portrait.custom_minimum_size = Vector2(
		80,
		80
	)

	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE

	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	_portrait.texture = _load_mayor_texture()

	header.add_child(
		_portrait
	)


	var prompt := VBoxContainer.new()

	header.add_child(
		prompt
	)


	var name_label := Label.new()

	name_label.text = "Mayor"

	name_label.add_theme_font_size_override(
		"font_size",
		20
	)

	prompt.add_child(
		name_label
	)


	var question_label := Label.new()

	question_label.text = "Who is the killer?"

	question_label.add_theme_font_size_override(
		"font_size",
		24
	)

	prompt.add_child(
		question_label
	)


	_choices = VBoxContainer.new()

	_choices.add_theme_constant_override(
		"separation",
		6
	)

	layout.add_child(
		_choices
	)


	_result_label = Label.new()

	layout.add_child(
		_result_label
	)


	_close_button = Button.new()

	_close_button.text = "Close"

	_close_button.visible = false

	_close_button.pressed.connect(
		hide_accusation
	)

	layout.add_child(
		_close_button
	)
