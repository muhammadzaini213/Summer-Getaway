extends Node2D

const TILE_SIZE := 16
const WATER_FILL_TILE := Vector2i(0, 0)
const GRASS_FILL_TILE := Vector2i(0, 0)
const SAND_FILL_TILE := Vector2i(0, 0)
const DIRT_FILL_TILE := Vector2i(0, 0)

const MAP_MIN_X := -36
const MAP_MAX_X := 38
const MAP_MIN_Y := -20
const MAP_MAX_Y := 20

const LAND_ROWS := {
	-15: [-27, -24],
	-14: [-28, -23],
	-13: [-29, -22],
	-12: [-30, -21],
	-11: [-31, -20],
	-10: [-32, -18],
	-9: [-33, 1],
	-8: [-33, 4],
	-7: [-32, 7],
	-6: [-32, 10],
	-5: [-31, 13],
	-4: [-30, 16],
	-3: [-28, 20],
	-2: [-26, 24],
	-1: [-24, 28],
	0: [-21, 31],
	1: [-18, 33],
	2: [-15, 34],
	3: [-12, 35],
	4: [-9, 35],
	5: [-7, 34],
	6: [-5, 32],
	7: [-4, 29],
	8: [-4, 25],
	9: [-5, 20],
	10: [-6, 13],
	11: [-7, 8],
	12: [-6, 4],
	13: [-4, 2],
	14: [-2, 1],
}

@onready var _water_tiles: Node2D = $WaterTiles
@onready var _land_tiles: Node2D = $LandTiles
@onready var _detail_tiles: Node2D = $DetailTiles
@onready var _water_blockers: StaticBody2D = $WaterBlockers

var _land_cells: Dictionary = {}


func _ready() -> void:
	add_to_group("terrain")
	_build_land_cells()
	_paint_water()
	_paint_land()
	_add_tree_details()
	_build_water_blockers()


func is_walkable_world_position(world_position: Vector2) -> bool:
	var cell := Vector2i(
		roundi(world_position.x / TILE_SIZE),
		roundi(world_position.y / TILE_SIZE)
	)
	return _land_cells.has(cell)


func _build_land_cells() -> void:
	for y in LAND_ROWS.keys():
		var row: Array = LAND_ROWS[y]
		for x in range(row[0], row[1] + 1):
			var cell := Vector2i(x, y)
			if not _is_cutaway(cell):
				_land_cells[cell] = true


func _is_cutaway(cell: Vector2i) -> bool:
	var left_cove: bool = cell.x < -24 and cell.y > -5
	var lower_right_bite: bool = cell.x > 27 and cell.y > 6
	var south_inlet: bool = cell.x > 1 and cell.x < 8 and cell.y > 9
	var north_channel: bool = cell.x > 3 and cell.x < 10 and cell.y < -5
	return left_cove or lower_right_bite or south_inlet or north_channel


func _paint_water() -> void:
	for y in range(MAP_MIN_Y, MAP_MAX_Y + 1):
		for x in range(MAP_MIN_X, MAP_MAX_X + 1):
			_add_tile(_water_tiles, preload("res://Assets/WaterTiles01-Sheet.png"), WATER_FILL_TILE, Vector2i(x, y))


func _paint_land() -> void:
	for cell in _land_cells.keys():
		var texture: Texture2D
		var atlas_cell: Vector2i
		if _is_shore(cell):
			texture = preload("res://Assets/SandTiles01-Sheet.png")
			atlas_cell = SAND_FILL_TILE
		elif _is_soil_patch(cell):
			texture = preload("res://Assets/DirtTiles01-Sheet.png")
			atlas_cell = DIRT_FILL_TILE
		else:
			texture = preload("res://Assets/GrassTiles01-Sheet.png")
			atlas_cell = GRASS_FILL_TILE

		_add_tile(_land_tiles, texture, atlas_cell, cell)


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
	var central_path: bool = abs(cell.y) <= 1 and cell.x > -22 and cell.x < 30
	var dock_ground: bool = cell.x >= -7 and cell.x <= 5 and cell.y >= 8
	var cliff_patch: bool = cell.x >= -5 and cell.x <= 4 and cell.y <= -7
	var soft_noise: bool = int(abs(cell.x * 31 + cell.y * 17)) % 23 == 0
	return central_path or dock_ground or cliff_patch or soft_noise


func _add_tile(parent: Node2D, atlas: Texture2D, atlas_cell: Vector2i, cell: Vector2i) -> void:
	var atlas_texture := AtlasTexture.new()
	atlas_texture.atlas = atlas
	atlas_texture.region = Rect2(
		Vector2(atlas_cell.x * TILE_SIZE, atlas_cell.y * TILE_SIZE),
		Vector2(TILE_SIZE, TILE_SIZE)
	)

	var sprite := Sprite2D.new()
	sprite.texture = atlas_texture
	sprite.position = Vector2(cell.x * TILE_SIZE, cell.y * TILE_SIZE)
	parent.add_child(sprite)


func _add_tree_details() -> void:
	var tree_cells := [
		Vector2i(-28, -8), Vector2i(-26, -5), Vector2i(-18, -6),
		Vector2i(-10, -3), Vector2i(-4, -10), Vector2i(7, -3),
		Vector2i(13, 4), Vector2i(19, 2), Vector2i(24, -1),
		Vector2i(29, 3), Vector2i(-4, 7), Vector2i(-1, 11),
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
