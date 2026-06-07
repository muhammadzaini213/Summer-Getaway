extends CanvasLayer

@onready var item_list: VBoxContainer = $Panel/MarginContainer/VBoxContainer/ItemList
@onready var back_button: Button = $Panel/BackButton

var is_open := false

var item_database := [
	{
		"flag": "has_ancient_coin",
		"name": "Ancient Coin",
		"description": "A coin from the old shrine keepers.",
		"icon": preload("res://Assets/placeholder/ancient_coin_placeholder.png")
	}
]


func _ready() -> void:
	visible = false
	back_button.pressed.connect(close_inventory)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("inventory"):
		if is_open:
			close_inventory()
		else:
			open_inventory()


func open_inventory() -> void:
	is_open = true
	visible = true
	refresh_inventory()


func close_inventory() -> void:
	is_open = false
	visible = false


func refresh_inventory() -> void:
	clear_items()

	var found_item := false

	for item in item_database:
		if GameState.has_flag(item["flag"]):
			add_item_row(item)
			found_item = true

	if not found_item:
		var empty_label := Label.new()
		empty_label.text = "Inventory is empty."
		item_list.add_child(empty_label)


func clear_items() -> void:
	for child in item_list.get_children():
		child.queue_free()


func add_item_row(item: Dictionary) -> void:
	var row := HBoxContainer.new()

	var icon := TextureRect.new()
	icon.texture = item.get("icon", null)
	icon.custom_minimum_size = Vector2(48, 48)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	var text_box := VBoxContainer.new()

	var name_label := Label.new()
	name_label.text = item.get("name", "Unknown Item")

	var desc_label := Label.new()
	desc_label.text = item.get("description", "")
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	text_box.add_child(name_label)
	text_box.add_child(desc_label)

	row.add_child(icon)
	row.add_child(text_box)

	item_list.add_child(row)
