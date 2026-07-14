extends Area2D

var index: int = -1
var occupied: bool = false

var cell_size: Vector2 = Vector2.ZERO

@onready var sprite2d: Sprite2D = $Sprite2D
@onready var collishape: CollisionShape2D = $CollisionShape2D


func init_cell(_index: int, piece_size: Vector2) -> void:
	index = _index
	cell_size = piece_size
	z_index = -1

	var rect_shape := collishape.shape as RectangleShape2D
	if rect_shape:
		rect_shape.size = piece_size

	sprite2d.scale = Vector2(
		piece_size.x / sprite2d.texture.get_width(),
		piece_size.y / sprite2d.texture.get_height()
	)
	
	queue_redraw()

func _draw() -> void:
	if cell_size == Vector2.ZERO:
		return

	var rect := Rect2(-cell_size * 0.5, cell_size)

	draw_rect(rect, Color(0.05, 0.05, 0.05, 0.12), true)

	draw_rect(
		rect,
		Color(0.85, 0.85, 0.85, 0.75),
		false,
		2.0,
		true
	)	

func is_free() -> bool:
	return not occupied


func occupy() -> void:
	occupied = true


func unoccupy() -> void:
	occupied = false
