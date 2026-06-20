class_name MurdererFinalFight
extends CharacterBody2D

const GUNTIME := 0.75

@export var player: PlayerFinalFight

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var health_bar: ProgressBar = $HealthBar
@onready var view_cast: RayCast2D = $ViewCast

var health := 3
var gun_timer := 0.0
var bullet_fab: PackedScene = preload("uid://dn4cqyeqdqngr")

func _ready() -> void:
	health_bar.modulate = Color(1, 1, 1, 0)

func _physics_process(delta: float) -> void:
	if gun_timer > 0.0:
		gun_timer -= delta
		return
	_brains()
	position.y = clamp(position.y, -69, 69)

func _brains() -> void:
	if not is_instance_valid(player): return
	var target_dir_raw := position.direction_to(player.position)
	var ref_dir := Vector2(0, 1)
	var target_dir := Vector2(0, ref_dir.dot(target_dir_raw))
	if target_dir.y > 0.05:
		sprite.animation = "walk_down"
	elif target_dir.y < -0.05:
		sprite.animation = "walk_down"
	else:
		sprite.animation = "idle"
	velocity = target_dir * 160.0
	
	if view_cast.is_colliding() and view_cast.get_collider() is PlayerFinalFight and gun_timer <= 0.0:
		_spawn_bullet()
		gun_timer = GUNTIME
	
	move_and_slide()

func _spawn_bullet() -> void:
	var bullet: BulletFinalFight = bullet_fab.instantiate()
	bullet.set_param(Vector2(-1, 0), player)
	bullet.position = view_cast.global_position
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
		queue_free()
		$"../Won".show()
