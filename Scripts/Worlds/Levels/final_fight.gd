extends Node2D

const BULLET_SCRIPT := preload("res://Scripts/Worlds/Levels/final_fight_bullet.gd")
const PLAYER_TEXTURE := preload("res://Assets/Assets/placeholder_human.png")
const KILLER_TEXTURE := preload("res://Screenshot 2026-06-07 182336.png")

const PLAYER_ID := "player"
const KILLER_ID := "killer"
const MAX_HEALTH := 3
const PLAYER_SPEED := 170.0
const KILLER_SPEED := 125.0
const PLAYER_RELOAD_SECONDS := 2.0
const KILLER_SHOT_SECONDS := 1.35
const HIT_RADIUS := 40.0
const ARENA_RECT := Rect2(Vector2(40.0, 70.0), Vector2(1080.0, 560.0))

var player_health := MAX_HEALTH
var killer_health := MAX_HEALTH
var player_reload_left := 0.0
var killer_shot_left := 0.8
var fight_over := false

var _player: Node2D
var _killer: Node2D
var _bullets: Node2D
var _player_health_label: Label
var _killer_health_label: Label
var _reload_label: Label
var _status_label: Label


func _ready() -> void:
	get_tree().paused = false
	_hide_story_systems()
	_build_arena()
	_build_fighters()
	_build_ui()
	_update_ui()


func _process(delta: float) -> void:
	if fight_over:
		return

	player_reload_left = maxf(player_reload_left - delta, 0.0)
	killer_shot_left = maxf(killer_shot_left - delta, 0.0)

	_update_player(delta)
	_update_killer(delta)
	_check_bullet_hits()
	_update_ui()


func _unhandled_input(event: InputEvent) -> void:
	if fight_over:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_try_player_shoot()

	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		_try_player_shoot()

func _hide_story_systems() -> void:
	var day_system := get_node_or_null("/root/DaySystem")
	if day_system != null:
		day_system.pause_timer()
		day_system.visible = false

	var accusation_system := get_node_or_null("/root/AccusationSystem")
	if accusation_system != null:
		accusation_system.visible = false


func _build_arena() -> void:
	var background := ColorRect.new()
	background.name = "ArenaBackground"
	background.color = Color(0.11, 0.13, 0.14)
	background.size = Vector2(1160.0, 700.0)
	add_child(background)

	var floor := ColorRect.new()
	floor.name = "FightFloor"
	floor.color = Color(0.19, 0.22, 0.22)
	floor.position = ARENA_RECT.position
	floor.size = ARENA_RECT.size
	add_child(floor)

	var divider := ColorRect.new()
	divider.name = "CenterLine"
	divider.color = Color(0.55, 0.51, 0.42)
	divider.position = Vector2(ARENA_RECT.get_center().x - 2.0, ARENA_RECT.position.y)
	divider.size = Vector2(4.0, ARENA_RECT.size.y)
	add_child(divider)

	_bullets = Node2D.new()
	_bullets.name = "Bullets"
	add_child(_bullets)


func _build_fighters() -> void:
	_player = _make_fighter("Player", PLAYER_TEXTURE, Vector2(260.0, 350.0), Vector2(2.5, 2.5))
	_killer = _make_fighter("Killer", KILLER_TEXTURE, Vector2(900.0, 350.0), Vector2(0.34, 0.34))


func _make_fighter(node_name: String, texture: Texture2D, start_position: Vector2, sprite_scale: Vector2) -> Node2D:
	var fighter := Node2D.new()
	fighter.name = node_name
	fighter.global_position = start_position
	add_child(fighter)

	var shadow := ColorRect.new()
	shadow.name = "Shadow"
	shadow.color = Color(0.0, 0.0, 0.0, 0.35)
	shadow.position = Vector2(-15.0, 18.0)
	shadow.size = Vector2(30.0, 7.0)
	fighter.add_child(shadow)

	var sprite := Sprite2D.new()
	sprite.name = "Sprite2D"
	sprite.texture = texture
	sprite.scale = sprite_scale
	fighter.add_child(sprite)

	return fighter


func _build_ui() -> void:
	var ui := CanvasLayer.new()
	ui.name = "FightUI"
	add_child(ui)

	var top_bar := HBoxContainer.new()
	top_bar.name = "TopBar"
	top_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_bar.offset_left = 18.0
	top_bar.offset_top = 12.0
	top_bar.offset_right = -18.0
	top_bar.offset_bottom = 52.0
	top_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	top_bar.add_theme_constant_override("separation", 64)
	ui.add_child(top_bar)

	_player_health_label = Label.new()
	_player_health_label.add_theme_font_size_override("font_size", 22)
	top_bar.add_child(_player_health_label)

	_reload_label = Label.new()
	_reload_label.add_theme_font_size_override("font_size", 18)
	top_bar.add_child(_reload_label)

	_killer_health_label = Label.new()
	_killer_health_label.add_theme_font_size_override("font_size", 22)
	top_bar.add_child(_killer_health_label)

	_status_label = Label.new()
	_status_label.name = "StatusLabel"
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status_label.add_theme_font_size_override("font_size", 34)
	_status_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.74))
	_status_label.set_anchors_preset(Control.PRESET_CENTER)
	_status_label.offset_left = -260.0
	_status_label.offset_top = -70.0
	_status_label.offset_right = 260.0
	_status_label.offset_bottom = 70.0
	ui.add_child(_status_label)


func _update_player(delta: float) -> void:
	var input_dir := Vector2.ZERO

	if Input.is_action_pressed("walk_right"):
		input_dir.x += 1.0
	if Input.is_action_pressed("walk_left"):
		input_dir.x -= 1.0

	if player_reload_left <= 0.0:
		if Input.is_action_pressed("walk_down"):
			input_dir.y += 1.0
		if Input.is_action_pressed("walk_up"):
			input_dir.y -= 1.0

	if input_dir != Vector2.ZERO:
		input_dir = input_dir.normalized()

	_player.global_position += input_dir * PLAYER_SPEED * delta
	_player.global_position = _clamp_to_arena(_player.global_position)


func _update_killer(delta: float) -> void:
	var to_player: Vector2 = _player.global_position - _killer.global_position
	var move_dir: Vector2 = Vector2.ZERO
	var incoming: FinalFightBullet = _get_nearest_incoming_player_bullet()

	if incoming != null and incoming.global_position.distance_to(_killer.global_position) < 165.0:
		var dodge_dir: Vector2 = incoming.direction.orthogonal()
		var preferred_y := -1.0 if _killer.global_position.y > ARENA_RECT.get_center().y else 1.0
		if signf(dodge_dir.y) != preferred_y:
			dodge_dir = -dodge_dir
		move_dir = dodge_dir.normalized()
	elif absf(to_player.y) > 45.0:
		move_dir.y = signf(to_player.y)
	else:
		move_dir.y = sin(Time.get_ticks_msec() * 0.003)

	_killer.global_position += move_dir * KILLER_SPEED * delta
	_killer.global_position = _clamp_to_arena(_killer.global_position)

	if killer_shot_left <= 0.0:
		_killer_shoot()
		killer_shot_left = KILLER_SHOT_SECONDS


func _try_player_shoot() -> void:
	if player_reload_left > 0.0:
		return

	var shot_direction: Vector2 = _killer.global_position - _player.global_position

	if shot_direction == Vector2.ZERO:
		shot_direction = Vector2.RIGHT

	_spawn_bullet(
		_player.global_position + shot_direction.normalized() * 24.0,
		shot_direction,
		PLAYER_ID,
		Color(0.35, 0.85, 1.0)
	)

	player_reload_left = PLAYER_RELOAD_SECONDS


func _killer_shoot() -> void:
	var shot_direction := _player.global_position - _killer.global_position
	if shot_direction == Vector2.ZERO:
		shot_direction = Vector2.LEFT

	_spawn_bullet(_killer.global_position + shot_direction.normalized() * 24.0, shot_direction, KILLER_ID, Color(1.0, 0.25, 0.18))


func _spawn_bullet(start_position: Vector2, direction: Vector2, owner_id: String, color: Color) -> void:
	var bullet: FinalFightBullet = BULLET_SCRIPT.new()
	_bullets.add_child(bullet)
	bullet.setup(start_position, direction, owner_id, color)


func _check_bullet_hits() -> void:
	for bullet in _bullets.get_children():

		if bullet.owner_id == PLAYER_ID:
			var d: float = bullet.global_position.distance_to(_killer.global_position)

			if d < 32.0:
				bullet.queue_free()
				_damage_killer()

		elif bullet.owner_id == KILLER_ID:
			var d: float = bullet.global_position.distance_to(_player.global_position)

			if d < 32.0:
				bullet.queue_free()
				_damage_player()


func _damage_player() -> void:
	print("PLAYER HIT")
	if fight_over:
		return

	player_health -= 1
	if player_health <= 0:
		_end_fight(false)


func _damage_killer() -> void:
	print("KILLER HIT")
	if fight_over:
		return

	killer_health -= 1
	if killer_health <= 0:
		_end_fight(true)


func _end_fight(player_won: bool) -> void:
	fight_over = true
	_clear_bullets()

	if player_won:
		GameState.set_flag("game_won")
		_status_label.text = "You won.\nThe killer is defeated."
	else:
		GameState.set_flag("game_lost")
		_status_label.text = "You lost.\nThe killer escaped."

	_update_ui()


func _clear_bullets() -> void:
	for bullet in _bullets.get_children():
		bullet.queue_free()


func _get_nearest_incoming_player_bullet() -> FinalFightBullet:
	var nearest: FinalFightBullet = null
	var nearest_distance: float = INF

	for bullet in _bullets.get_children():
		if bullet.owner_id != PLAYER_ID:
			continue

		var distance: float = bullet.global_position.distance_to(_killer.global_position)
		if distance < nearest_distance:
			nearest = bullet
			nearest_distance = distance

	return nearest


func _clamp_to_arena(position: Vector2) -> Vector2:
	return Vector2(
		clampf(position.x, ARENA_RECT.position.x + 16.0, ARENA_RECT.end.x - 16.0),
		clampf(position.y, ARENA_RECT.position.y + 16.0, ARENA_RECT.end.y - 16.0)
	)


func _update_ui() -> void:
	_player_health_label.text = "Player HP: %d/%d" % [maxi(player_health, 0), MAX_HEALTH]
	_killer_health_label.text = "Killer HP: %d/%d" % [maxi(killer_health, 0), MAX_HEALTH]

	if fight_over:
		_reload_label.text = ""
	elif player_reload_left > 0.0:
		_reload_label.text = "Reloading %.1fs - AD only" % player_reload_left
	else:
		_reload_label.text = "LMB Shoot"
