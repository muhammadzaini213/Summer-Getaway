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


func _ready() -> void:
	hide_dialogue()

func _process(_delta: float) -> void:
	if not visible:
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

	if data.is_empty():
		return

	var start_id := get_start_node(data)

	dialogue_data = data.get("nodes", {})
	current_id = start_id
	visible = true

	show_dialogue_node(current_id)


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
	finish_dialogue.emit()
	visible = false
	clear_choices()
	typing = false
	can_continue = false

func get_start_node(data: Dictionary) -> String:
	if not data.has("states"):
		return "start"

	for state in data["states"]:
		if state.has("required_flag"):
			if GameState.has_flag(state["required_flag"]):
				return state.get("start", "start")
		else:
			return state.get("start", "start")

	return "start"
