extends CanvasLayer

signal finish_dialogue

@onready var portrait: TextureRect = $DialogueBox/Portrait
@onready var name_label: Label = $DialogueBox/NameLabel
@onready var text_label: RichTextLabel = $DialogueBox/DialogueText
@onready var choices_container: VBoxContainer = $DialogueBox/ChoicesContainer

@export var type_speed := 0.03

var dialogue_data := {}
var current_id := ""
var current_text := ""
var typing := false
var can_continue := false
var input_locked := false
var dialogue_active := false

func _ready() -> void:
	hide_dialogue()

func _process(_delta: float) -> void:
	if not visible:
		return
		
	if input_locked:
			return
			
	if Input.is_action_just_pressed("interact"):
		handle_continue_input()
	
func load_dialogue_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)

	if file == null:
		push_error("Could not open dialogue file: " + path)
		return {}

	var text := file.get_as_text()
	var result = JSON.parse_string(text)

	if typeof(result) != TYPE_DICTIONARY:
		push_error("Dialogue JSON is not a dictionary: " + path)
		return {}

	return result
	
func start_dialogue_from_file(path: String) -> void:
	var data := load_dialogue_json(path)
	validate_dialogue_flags(data, path)
	
	if data.is_empty():
		return

	var start_id := get_start_node(data)

	dialogue_data = data.get("nodes", {})
	current_id = start_id
	visible = true
	dialogue_active = true
	_set_day_timer_paused(true)
	
	input_locked = true
	show_dialogue_node(current_id)
	call_deferred("unlock_dialogue_input")

func unlock_dialogue_input() -> void:
	await get_tree().create_timer(0.1).timeout
	input_locked = false
	
func validate_dialogue_flags(data: Dictionary, file_path: String) -> void:
	if data.has("states"):
		for state in data["states"]:
			if state.has("required_flag"):
				validate_flag_name(state["required_flag"], file_path)

	if data.has("nodes"):
		for node_id in data["nodes"].keys():
			var node: Dictionary = data["nodes"][node_id]

			if node.has("set_flag"):
				validate_flag_name(node["set_flag"], file_path)

			if node.has("remove_flag"):
				validate_flag_name(node["remove_flag"], file_path)

			if node.has("choices"):
				for choice in node["choices"]:
					if choice.has("required_flag"):
						validate_flag_name(choice["required_flag"], file_path)


func validate_flag_name(flag_name: String, file_path: String) -> void:
	if not FlagRegistry.is_valid_flag(flag_name):
		push_error("Unknown flag '" + flag_name + "' in " + file_path)
		

func show_dialogue_node(id: String) -> void:
	clear_choices()

	if not dialogue_data.has(id):
		hide_dialogue()
		return

	var node: Dictionary = dialogue_data[id]
	
	if node.has("set_flag"):
		GameState.set_flag(node["set_flag"])

	if node.has("remove_flag"):
		GameState.remove_flag(node["remove_flag"])
	
	if node.has("end") and node["end"] == true:
		hide_dialogue()
		return

	current_id = id
	name_label.text = node.get("speaker", "")

	var portrait_path: String = node.get("portrait", "")
	if portrait_path != "":
		portrait.texture = load(portrait_path)
	else:
		portrait.texture = null

	current_text = node.get("text", "")
	text_label.text = ""

	can_continue = false
	typing = true

	type_text(current_text)


func type_text(full_text: String) -> void:
	for i in full_text.length():
		if not typing:
			text_label.text = full_text
			break

		text_label.text += full_text[i]
		await get_tree().create_timer(type_speed).timeout

	text_label.text = full_text
	typing = false
	can_continue = true

	var node: Dictionary = dialogue_data[current_id]

	if node.has("choices"):
		show_choices(node["choices"])


func handle_continue_input() -> void:
	if typing:
		typing = false
		text_label.text = current_text
		can_continue = true

		var node: Dictionary = dialogue_data[current_id]
		if node.has("choices"):
			show_choices(node["choices"])
		return

	if not can_continue:
		return

	var node: Dictionary = dialogue_data[current_id]

	if node.has("choices"):
		return

	if node.has("next"):
		show_dialogue_node(node["next"])
	else:
		hide_dialogue()

func show_choices(choices: Array) -> void:
	clear_choices()

	for choice in choices:
		var button := Button.new()
		button.text = choice.get("text", "Choice")
		button.pressed.connect(func():
			show_dialogue_node(choice.get("next", "end"))
		)

		choices_container.add_child(button)


func clear_choices() -> void:
	if choices_container == null:
		return
		
	for child in choices_container.get_children():
		child.queue_free()


func hide_dialogue() -> void:
	if dialogue_active:
		finish_dialogue.emit()
		_set_day_timer_paused(false)

	visible = false
	clear_choices()
	typing = false
	can_continue = false
	dialogue_active = false

func get_start_node(data: Dictionary) -> String:
	for state in data.get("states", []):
		var flag = state.get("required_flag")
		if not flag or GameState.has_flag(flag):
			return state.get("start", "start")
	return "start"


func _set_day_timer_paused(paused: bool) -> void:
	var day_system := get_node_or_null("/root/DaySystem")
	if day_system == null:
		return

	if paused:
		day_system.pause_timer()
	else:
		day_system.resume_timer()
