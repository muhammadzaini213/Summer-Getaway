class_name FishingGame
extends Node2D

const FISHINGLINE_SWING_SPEED := 0.5
const FISHINGLINE_PWR_SPEED := 0.25
const FISHINGLINE_CAUGHT_RADIUS := 10

@export var interactable: Interactable
@onready var _game_cam: Camera2D = $GameCam
@onready var _fishing_dir: Line2D = $FishingDir
@onready var _fishing_power: Range = $FishingStrength
var _fishing_line: Line2D
@onready var _missed_text: Label = $MissedText
@onready var _fishing_pos: Node2D = $FishingPos
@onready var _fishing_rod: Node2D = $FishingRod

var _fishing_hook_scene := preload("uid://cap3amrc2k4q0")
var _fish_scene := preload("uid://dahv468a0kgar")
var _dialogue_resource: DialogueResource = preload("uid://d2oy26xh7v5pn")

signal FishGameRelease

enum {IDLE, BRINGPLAYER, GAMEIDLE, GAMEAIM, THROWING, LAND, OUTPUT, GAMEOVER}
var _scratchpad := {}
var _dialogue_state := {
	"game": false,
	"fishies": 0
}

func _ready() -> void:
	if interactable == null:
		interactable = get_node_or_null("Interactable")

	if interactable:
		interactable.interact.connect(_on_interact)
	
	DialogueManager.dialogue_ended.connect(_on_dialogue_finished)
	
	# Couldn't get this particular Line2D to play ball the normal way, so had to add it by code :P
	_fishing_line = Line2D.new()
	_fishing_line.width = 1
	_fishing_line.default_color = Color(0,0,0,1)
	_fishing_line.points = PackedVector2Array([])
	get_tree().current_scene.add_child.call_deferred(_fishing_line)
	
	_missed_text.hide()

func _process(delta: float) -> void:
	if not _scratchpad.has('game_state'):
		return
	
	match _scratchpad.game_state:
		IDLE:
			_scratchpad.game_state = BRINGPLAYER
		BRINGPLAYER:
			# Animate player walking toward the PlayPlace™
			_scratchpad.ply_ctr.position = _scratchpad.ply_ctr.position.move_toward(_fishing_pos.global_position, delta * _scratchpad.ply_ctr.speed)
			if _scratchpad.ply_ctr.position.distance_to(_fishing_pos.global_position) < 0.1:
				var tweener := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(true)
				tweener.tween_property(_fishing_dir, "modulate", Color(1, 1, 1, 1), 0.25)
				tweener.tween_property(_fishing_dir, "rotation", deg_to_rad(-160.0), 0.25)
				_scratchpad.time_elapsed = 0.0
				_scratchpad.fish_time = randf_range(0.5, 2.0)
				_spawn_fish()
				_scratchpad.game_state = GAMEIDLE
		GAMEIDLE:
			# Animate the direction indicator
			_fishing_dir.rotation = ((sin(_scratchpad.time_elapsed * PI * FISHINGLINE_SWING_SPEED) + 1.0)/2.0) * (deg_to_rad(-140)) + deg_to_rad(-20.0)
			_scratchpad.time_elapsed += delta
			
			# FISH SPAWNING
			_scratchpad.fish_time -= delta
			if _scratchpad.fish_time < 0.0:
				_scratchpad.fish_time = randf_range(0.5, 2.0)
				_spawn_fish()
			
			# Proceed to GAMEAIM state
			if Input.is_action_just_pressed("shoot"):
				var tweener := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(true)
				tweener.tween_property(_fishing_power, "modulate", Color(1, 1, 1, 1), 0.25)
				_scratchpad.time_elapsed = 0.0
				_pause_fishes()
				_scratchpad.game_state = GAMEAIM
			
			# Leave minigame
			if Input.is_action_just_pressed("cancel_interact"):
				_end_game.call_deferred()
		GAMEAIM:
			# Animate the power indicator
			_fishing_power.value = ((sin(_scratchpad.time_elapsed * PI * FISHINGLINE_PWR_SPEED) + 1.0)/2.0)
			_scratchpad.time_elapsed += delta
			
			# Throw hook
			if Input.is_action_just_pressed("shoot"):
				_scratchpad.time_elapsed = 0.0
				_scratchpad.hook_inst = _fishing_hook_scene.instantiate()
				get_tree().current_scene.add_child(_scratchpad.hook_inst)
				_scratchpad.hook_inst.position = _fishing_rod.global_position
				_scratchpad.hook_tgt = _fishing_rod.global_position + (Vector2(cos(_fishing_dir.rotation), sin(_fishing_dir.rotation)) * -144 * _fishing_power.value)
				_scratchpad.hook_tgt_dist = _fishing_rod.global_position.distance_to(_scratchpad.hook_tgt)
				var tweener := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(true)
				tweener.tween_property(_fishing_power, "modulate", Color(1, 1, 1, 0), 0.25)
				tweener.tween_property(_fishing_dir, "modulate", Color(1, 1, 1, 0), 0.25)
				_fishing_line.points = PackedVector2Array([_fishing_pos.global_position, _scratchpad.hook_inst.position])
				_scratchpad.game_state = THROWING
			
			# Go back to GAMEIDLE State
			if Input.is_action_just_pressed("cancel_interact"):
				var tweener := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(true)
				tweener.tween_property(_fishing_power, "modulate", Color(1, 1, 1, 0), 0.25)
				_fishing_power.value = 0.0
				tweener.tween_property(_fishing_dir, "modulate", Color(1, 1, 1, 1), 0.25)
				_pause_fishes(false)
				_scratchpad.game_state = GAMEIDLE
		THROWING:
			# Over engineered throwing hook animation.
			_fishing_line.points = PackedVector2Array([_fishing_rod.global_position, _scratchpad.hook_inst.position])
			_scratchpad.hook_inst.position = _scratchpad.hook_inst.position.move_toward(_scratchpad.hook_tgt, delta * 100)
			var hook_delta_raw: float = _scratchpad.hook_inst.position.distance_to(_scratchpad.hook_tgt)/_scratchpad.hook_tgt_dist
			var hook_delta: float = 1 - abs(hook_delta_raw * 2 - 1)
			_scratchpad.hook_inst.shadow_dist_delta = hook_delta
			if (_scratchpad.hook_inst.position.distance_to(_scratchpad.hook_tgt) < 0.1):
				_scratchpad.hit_a_fish = _hit_a_fish()
				_scratchpad.land_timer = 0.25
				_scratchpad.game_state = LAND
		LAND:
			# Reel back animation
			if _scratchpad.hit_a_fish:
				_scratchpad.hook_inst.show_fish()
				_fishing_line.points = PackedVector2Array([_fishing_rod.global_position, _scratchpad.hook_inst.position])
				_scratchpad.hook_inst.position = _scratchpad.hook_inst.position.move_toward(_fishing_rod.global_position, delta * 150)
				if (_scratchpad.hook_inst.position.distance_to(_fishing_rod.global_position) < 0.1):
					_scratchpad.hook_inst.queue_free()
					_scratchpad.hook_inst = null
					_pause_fishes(false)
					_scratchpad.game_state = OUTPUT
			else: 
				# Let the player repent in silence
				_scratchpad.land_timer -= delta
				if _scratchpad.land_timer < 0.0:
					_scratchpad.hook_inst.queue_free()
					_scratchpad.hook_inst = null
					_pause_fishes(false)
					_scratchpad.game_state = OUTPUT
		OUTPUT:
			# Self-explanatory
			if _scratchpad.hit_a_fish:
				print("Caught a fish!")
			else:
				_show_missed_text(_scratchpad.hook_tgt)
			
			# Reset stuff
			_fishing_line.points = PackedVector2Array([])
			var tweener := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(true)
			tweener.tween_property(_fishing_dir, "modulate", Color(1, 1, 1, 1), 0.25)
			_fishing_power.value = 0.0
			_scratchpad.game_state = GAMEIDLE

func _show_missed_text(pos: Vector2) -> void:
	# For flashing "Missed!" at a specfied position
	_missed_text.global_position = pos
	_missed_text.show()
	var _missed_text_tweener := get_tree().create_tween().set_parallel()
	_missed_text_tweener.tween_property(_missed_text, "global_position", pos + Vector2(0, -25), 0.5)
	_missed_text_tweener.tween_property(_missed_text, "modulate", Color(1, 1, 1, 0), 0.5)
	await get_tree().create_timer(1.0).timeout
	_missed_text.modulate = Color(1, 1, 1, 1)
	_missed_text.hide()

func _hit_a_fish() -> bool:
	# Returns whether a fish is hit. If true, delete the fish as well
	var fishies := get_tree().get_nodes_in_group("fish")
	for fish: Fish in fishies:
		if _scratchpad.hook_inst.position.distance_to(fish.position) < FISHINGLINE_CAUGHT_RADIUS:
			fish.queue_free()
			_dialogue_state.fishies += 1
			return true
	return false

func _pause_fishes(can_pause: bool = true) -> void:
	# Toggles the process mode while aiming and throwing fishing hook
	var fishies := get_tree().get_nodes_in_group("fish")
	for fish: Fish in fishies:
		fish.process_mode = Node.PROCESS_MODE_DISABLED if can_pause else Node.PROCESS_MODE_INHERIT

func _spawn_fish() -> void:
	# Spawns fishes while the minigame runs
	var new_fish := _fish_scene.instantiate()
	get_tree().current_scene.add_child(new_fish)
	var rand_angle := deg_to_rad(randf_range(-20.0, -160.0))
	var rand_pwr := randf_range(0.4, 1)
	new_fish.position = _fishing_rod.global_position + (Vector2(cos(rand_angle), sin(rand_angle)) * -144 * rand_pwr)

func _on_interact() -> void:
	#if _dialogue_state.game:
		#_start_fishing_game()
		#return
	#if _dialogue_state.offered: pass
	DialogueManager.show_dialogue_balloon(_dialogue_resource, "fisherman")

func _on_dialogue_finished(_resource: DialogueResource) -> void:
	interactable.finish_interact.emit()

func _start_fishing_game() -> void:
	# These 1. store the player camera and player controller reference
	#       2. create a variable to store the game state
	#       3. Change the camera and start the game
	_scratchpad.ply_cam = get_viewport().get_camera_2d()
	_game_cam.make_current()
	_scratchpad.ply_ctr = _scratchpad.ply_cam.get_parent()
	_scratchpad.game_state = IDLE
	
	# A single signal dismantles everything
	await FishGameRelease
	_scratchpad.ply_cam.make_current()
	_scratchpad = {}
	interactable.finish_interact.emit()

func _end_game() -> void:
	_fishing_dir.modulate = Color(1, 1, 1, 0)
	_fishing_power.modulate = Color(1, 1, 1, 0)
	_fishing_line.points = PackedVector2Array([])
	_fishing_power.value = 0.0
	FishGameRelease.emit()
