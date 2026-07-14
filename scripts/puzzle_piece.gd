extends Area2D
# Puzzle Piece

var index = -1
var cell_index = -1
var size

var dragging = false
var drag_offset = Vector2.ZERO

@onready var sprite2d: Sprite2D = $Sprite2D
@onready var collishape: CollisionShape2D = $CollisionShape2D
@onready var pickup_sound: AudioStreamPlayer = $SelectClick
@onready var drop_sound: AudioStreamPlayer = $Select

func init_piece(
	_index: int,
	texture: ImageTexture,
	pos: Vector2,
	piece_size: Vector2
):
	index = _index
	sprite2d.texture = texture
	position = pos
	collishape.shape.set("size", piece_size)
	size = piece_size

func _process(_delta: float) -> void:
	if dragging:
		var new_pos: Vector2 = get_global_mouse_position() + drag_offset
		global_position = new_pos

		if sprite2d.material:
			sprite2d.material.set(
				"shader_parameter/mouse_screen_pos",
				new_pos
			)


func _on_input_event(
	_viewport: Node,
	event: InputEvent,
	_shape_idx: int
) -> void:
	if G.game_over:
		return

	if not (event is InputEventMouseButton):
		return

	if event.button_index != MOUSE_BUTTON_LEFT:
		return

	if not event.pressed:
		return

	if G.dragging and not dragging:
		return

	if not dragging:
		pick_up()
	else:
		drop_down()

	get_viewport().set_input_as_handled()
	


func pick_up() -> void:
	if cell_index != -1:
		var old_cell = G.find_cell(cell_index)

		if old_cell:
			old_cell.unoccupy()

		cell_index = -1

	G.dragging = true
	dragging = true
	#z_index = 100
	G.top_piece_z += 1
	z_index = G.top_piece_z

	drag_offset = Vector2.ZERO
	global_position = get_global_mouse_position()
	pickup_sound.play()
	if sprite2d.material:
		sprite2d.material.set(
			"shader_parameter/shadow_offset",
			Vector2(10, -10)
		)


func drop_down() -> void:
	G.dragging = false
	dragging = false
	#z_index = 0

	if sprite2d.material:
		sprite2d.material.set(
			"shader_parameter/shadow_offset",
			Vector2.ZERO
		)

	drop_piece()
	G.check_win()
	
func drop_piece() -> void:
	var local_pos: Vector2 = global_position - G.board_origin

	var col: int = roundi(local_pos.x / size.x)
	var row: int = roundi(local_pos.y / size.y)

	if col < 0 or col >= G.grid_size.x:
		return

	if row < 0 or row >= G.grid_size.y:
		return

	var target_index: int = row * G.grid_size.x + col
	var cell = G.find_cell(target_index)

	if cell == null or not cell.is_free():
		return

	var snap_distance: float = minf(size.x, size.y) * 0.25
	var distance: float = global_position.distance_to(cell.global_position)

	if distance > snap_distance:
		return

	cell_index = cell.index
	cell.occupy()
	global_position = cell.global_position

	if cell_index == index:
		input_pickable = false
		drop_sound.play()
		#sprite2d.modulate = Color(0.85, 1.0, 0.85, 1.0)
	else:
		pass
func handle_drag_animation():
	if sprite2d.material:
		sprite2d.material.set("shader_parameter/shadow_offset", Vector2(10, -10))
