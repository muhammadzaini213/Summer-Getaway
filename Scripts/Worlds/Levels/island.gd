@tool # TODO: remove
extends Node2D

const TILE_SIZE := 16
const WATER_SOURCE := 0
const GRASS_SOURCE := 1
const SAND_SOURCE := 2
const DIRT_SOURCE := 3

const WATER_FILL_TILE := Vector2i(0, 0)
const GRASS_FILL_TILES := [Vector2i(0, 0)]
const SAND_FILL_TILES := [Vector2i(0, 0)]
const DIRT_FILL_TILES := [Vector2i(0, 0)]

const MAP_MIN_X := -40
const MAP_MAX_X := 44
const MAP_MIN_Y := -20
const MAP_MAX_Y := 20

@export var auto_generate_if_empty := true

@onready var _water_map: TileMapLayer = $WaterMap
@onready var _ground_map: TileMapLayer = $GroundMap
@onready var _detail_tiles: Node2D = $DetailTiles
@onready var _water_blockers: StaticBody2D = $WaterBlockers

var _land_cells: Dictionary = {}


func _ready() -> void:
	add_to_group("terrain")
	
	if auto_generate_if_empty:
		_clean_old_generated_fill_tiles()
	
	_rebuild_land_cells_from_maps_or_template()
	
	if auto_generate_if_empty and _ground_map.get_used_cells().is_empty():
		_generate_tilemaps()
	
	if not Engine.is_editor_hint():
		_add_tree_details()

	_build_water_blockers()


func is_walkable_world_position(world_position: Vector2) -> bool:
	var cell := Vector2i(
		roundi(world_position.x / TILE_SIZE),
		roundi(world_position.y / TILE_SIZE)
	)
	return _land_cells.has(cell)


func _generate_tilemaps() -> void:
	_build_template_land_cells()
	_water_map.clear()
	_ground_map.clear()

	for y in range(MAP_MIN_Y, MAP_MAX_Y + 1):
		for x in range(MAP_MIN_X, MAP_MAX_X + 1):
			_water_map.set_cell(Vector2i(x, y), WATER_SOURCE, WATER_FILL_TILE)

	for cell in _land_cells.keys():
		if _is_shore(cell):
			_ground_map.set_cell(cell, SAND_SOURCE, _pick_tile(SAND_FILL_TILES, cell))
		elif _is_soil_patch(cell):
			_ground_map.set_cell(cell, DIRT_SOURCE, _pick_tile(DIRT_FILL_TILES, cell))
		else:
			_ground_map.set_cell(cell, GRASS_SOURCE, _pick_tile(GRASS_FILL_TILES, cell))


func _clean_old_generated_fill_tiles() -> void:
	for cell in _ground_map.get_used_cells():
		var source_id: int = _ground_map.get_cell_source_id(cell)
		var atlas_cell: Vector2i = _ground_map.get_cell_atlas_coords(cell)

		if source_id == GRASS_SOURCE and atlas_cell in [Vector2i(1, 7), Vector2i(2, 7)]:
			_ground_map.set_cell(cell, GRASS_SOURCE, Vector2i(0, 0))
		elif source_id == SAND_SOURCE and atlas_cell in [Vector2i(0, 7), Vector2i(1, 7)]:
			_ground_map.set_cell(cell, SAND_SOURCE, Vector2i(0, 0))
		elif source_id == DIRT_SOURCE and atlas_cell in [Vector2i(0, 7), Vector2i(1, 7)]:
			_ground_map.set_cell(cell, DIRT_SOURCE, Vector2i(0, 0))


func _rebuild_land_cells_from_maps_or_template() -> void:
	_land_cells.clear()

	for cell in _ground_map.get_used_cells():
		_land_cells[cell] = true

	if _land_cells.is_empty():
		_build_template_land_cells()


func _build_template_land_cells() -> void:
	_land_cells.clear()
	for y in range(MAP_MIN_Y, MAP_MAX_Y + 1):
		for x in range(MAP_MIN_X, MAP_MAX_X + 1):
			var cell := Vector2i(x, y)
			if _is_template_land(cell) and not _is_cutaway(cell):
				_land_cells[cell] = true


func _is_template_land(cell: Vector2i) -> bool:
	var hotel_land: bool = _is_in_ellipse(cell, Vector2(-31, -1), Vector2(8, 12))
	var main_route: bool = _is_in_rect(cell, -27, 9, -4, 4)
	var cliff_neck: bool = _is_in_rect(cell, -4, 3, -12, -4)
	var cliff_land: bool = _is_in_ellipse(cell, Vector2(0, -14), Vector2(9, 5))
	var pub_land: bool = _is_in_ellipse(cell, Vector2(14, 0), Vector2(9, 7))
	var dock_neck: bool = _is_in_rect(cell, 8, 13, 4, 10)
	var dock_land: bool = _is_in_ellipse(cell, Vector2(10, 13), Vector2(12, 5))
	var east_route: bool = _is_in_rect(cell, 21, 30, -2, 2)
	var cave_land: bool = _is_in_ellipse(cell, Vector2(36, 0), Vector2(8, 9))

	return (
		hotel_land
		or main_route
		or cliff_neck
		or cliff_land
		or pub_land
		or dock_neck
		or dock_land
		or east_route
		or cave_land
	)


func _is_cutaway(cell: Vector2i) -> bool:
	var hotel_top_chip: bool = cell.x < -34 and cell.y < -8
	var hotel_bottom_chip: bool = cell.x < -35 and cell.y > 6
	var cliff_left_notch: bool = cell.x < -4 and cell.y < -15
	var cliff_right_notch: bool = cell.x > 5 and cell.y < -15
	var pub_north_bite: bool = cell.x > 18 and cell.y < -5
	var dock_river_bite: bool = cell.x > 16 and cell.y > 13
	var cave_top_chip: bool = cell.x > 39 and cell.y < -5
	var cave_bottom_chip: bool = cell.x > 40 and cell.y > 5
	return (
		hotel_top_chip
		or hotel_bottom_chip
		or cliff_left_notch
		or cliff_right_notch
		or pub_north_bite
		or dock_river_bite
		or cave_top_chip
		or cave_bottom_chip
	)


func _is_in_rect(cell: Vector2i, left: int, right: int, top: int, bottom: int) -> bool:
	return cell.x >= left and cell.x <= right and cell.y >= top and cell.y <= bottom


func _is_in_ellipse(cell: Vector2i, center: Vector2, radius: Vector2) -> bool:
	var offset: Vector2 = Vector2(cell.x, cell.y) - center
	var normalized: Vector2 = Vector2(offset.x / radius.x, offset.y / radius.y)
	return normalized.length_squared() <= 1.0


func _is_shore(cell: Vector2i) -> bool:
	for direction in [
		Vector2i.LEFT,
		Vector2i.RIGHT,
		Vector2i.UP,
		Vector2i.DOWN,
		Vector2i(-1, -1),
		Vector2i(1, -1),
		Vector2i(-1, 1),
		Vector2i(1, 1),
	]:
		if not _land_cells.has(cell + direction):
			return true
	return false


func _is_soil_patch(cell: Vector2i) -> bool:
	var central_path: bool = cell.x >= -25 and cell.x <= 30 and abs(cell.y) <= 1
	var hotel_ground: bool = cell.x >= -35 and cell.x <= -27 and cell.y >= -4 and cell.y <= 4
	var pub_ground: bool = cell.x >= 9 and cell.x <= 18 and cell.y >= -3 and cell.y <= 3
	var dock_ground: bool = cell.x >= 5 and cell.x <= 15 and cell.y >= 9
	var cliff_patch: bool = cell.x >= -4 and cell.x <= 4 and cell.y <= -10
	var soft_noise: bool = int(abs(cell.x * 31 + cell.y * 17)) % 23 == 0
	return central_path or hotel_ground or pub_ground or dock_ground or cliff_patch or soft_noise


func _pick_tile(options: Array, cell: Vector2i) -> Vector2i:
	var index: int = int(abs(cell.x * 19 + cell.y * 37)) % options.size()
	return options[index]


func _add_tree_details() -> void:
	for child in _detail_tiles.get_children():
		child.queue_free()

	var tree_cells := [
		Vector2i(-35, -5), Vector2i(-33, 5), Vector2i(-24, -3),
		Vector2i(-15, -5), Vector2i(-6, -12), Vector2i(5, -13),
		Vector2i(7, -3), Vector2i(18, 5), Vector2i(23, -2),
		Vector2i(32, -5), Vector2i(38, 4), Vector2i(2, 12),
	]

	for cell in tree_cells:
		if not _land_cells.has(cell):
			continue

		var tree := Sprite2D.new()
		tree.texture = preload("res://Assets/BigTree01.png")
		tree.position = Vector2(cell.x * TILE_SIZE, cell.y * TILE_SIZE) + Vector2(0, -24)
		tree.z_index = 2
		_detail_tiles.add_child(tree)


func _build_water_blockers() -> void:
	for child in _water_blockers.get_children():
		child.queue_free()

	for y in range(MAP_MIN_Y, MAP_MAX_Y + 1):
		var run_start := MAP_MIN_X
		var in_water_run := false

		for x in range(MAP_MIN_X, MAP_MAX_X + 2):
			var is_water: bool = x <= MAP_MAX_X and not _land_cells.has(Vector2i(x, y))

			if is_water and not in_water_run:
				run_start = x
				in_water_run = true
			elif not is_water and in_water_run:
				_add_water_blocker(run_start, x - 1, y)
				in_water_run = false


func _add_water_blocker(start_x: int, end_x: int, y: int) -> void:
	var shape := RectangleShape2D.new()
	var run_length := end_x - start_x + 1
	shape.size = Vector2(run_length * TILE_SIZE, TILE_SIZE)

	var collision := CollisionShape2D.new()
	collision.shape = shape
	collision.position = Vector2((start_x + end_x) * TILE_SIZE * 0.5, y * TILE_SIZE)
	_water_blockers.add_child(collision)
