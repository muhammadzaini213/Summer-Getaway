extends Node2D
class_name FinalFightBullet

var direction := Vector2.RIGHT
var speed := 360.0
var damage := 1
var owner_id := ""
var lifetime := 2.2
var size := Vector2(18.0, 6.0)

var _body: ColorRect


func setup(start_position: Vector2, new_direction: Vector2, new_owner_id: String, color: Color) -> void:
	global_position = start_position
	direction = new_direction.normalized()
	owner_id = new_owner_id

	if _body != null:
		_body.color = color
		_body.size = size
		_body.position = -size * 0.5

	rotation = direction.angle()


func _ready() -> void:
	_body = ColorRect.new()
	_body.name = "BulletRect"
	_body.size = size
	_body.position = -size * 0.5
	_body.color = Color.WHITE
	add_child(_body)


func _process(delta: float) -> void:
	global_position += direction * speed * delta
	lifetime -= delta

	if lifetime <= 0.0:
		queue_free()
