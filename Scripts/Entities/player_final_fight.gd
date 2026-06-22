class_name PlayerFinalFight
extends CharacterBody2D

const GUNTIME := 0.75
const bullet_fab := preload("uid://dn4cqyeqdqngr")

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var health_bar: ProgressBar = $HealthBar
@export var enemy: MurdererFinalFight

var health := 3
var gun_timer := 0.0

func _ready() -> void:
	health_bar.modulate = Color(1, 1, 1, 0)

func _physics_process(delta: float) -> void:
	if gun_timer > 0.0:
		gun_timer -= delta
		return
	
	if Input.is_action_just_pressed("shoot"):
		_spawn_bullet()
		gun_timer = GUNTIME
	
	var dir := Vector2(0.0, Input.get_axis("walk_up", "walk_down"))
	if dir.y > 0.0:
		sprite.animation = "walk_down"
	elif dir.y < 0.0:
		sprite.animation = "walk_down"
	else:
		sprite.animation = "idle"
	velocity = dir * 40.0
	move_and_slide()
	
	position.y = clamp(position.y, -69, 69)

func _spawn_bullet() -> void:
	var bullet: BulletFinalFight = bullet_fab.instantiate()
	bullet.set_param(Vector2(1, 0), enemy)
	bullet.position = global_position
	get_tree().current_scene.add_child(bullet)

func is_hit() -> void:
	var entities := get_tree().get_nodes_in_group("fight_entities")
	var tweener := get_tree().create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	
	for entty in entities:
		entty.process_mode = Node.PROCESS_MODE_DISABLED
	sprite.material["shader_parameter/flash"] = true
	tweener.tween_property(health_bar, "modulate", Color(1, 1, 1, 1), 0.125)
	
	await get_tree().create_timer(0.125).timeout
	
	for entty in entities:
		entty.process_mode = Node.PROCESS_MODE_INHERIT
	sprite.material["shader_parameter/flash"] = false
	
	health -= 1
	
	tweener.stop()
	tweener.tween_property(health_bar, "value", float(health), 0.125)
	tweener.play()
	
	await get_tree().create_timer(0.125).timeout
	
	tweener.stop()
	tweener.tween_property(health_bar, "modulate", Color(1, 1, 1, 0), 0.125)
	tweener.play()
	
	if health <= 0:

		AudioManager.stop_bgm()
		get_tree().change_scene_to_file("uid://dju0leywqnskg")

		queue_free()
