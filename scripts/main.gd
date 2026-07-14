extends Node2D

@onready var cells = $Cells
@onready var cell_scene = preload("res://scenes/Cell.tscn")

@onready var pieces = $Pieces
@onready var piece_scene = preload("res://scenes/PuzzlePiece.tscn")
@onready var easybtn = $easy
@onready var medbtn = $medium
@onready var hardbtn = $hard
@onready var lunaticbtn = $lunatic
@onready var winsound = $Win
@onready var start = $Start



@onready var http: HTTPRequest

@onready var win_label: Label = $WIN
#@onready var left_bar: TextureRect = $Bar
#@onready var right_bar: TextureRect = $Bar2

@onready var background: Control = $Background
@onready var circle_template: TextureRect = $Background	/TextureRect

var circles_running := true
var rng := RandomNumberGenerator.new()

var win_animation_played := false
var left_bar_rest_pos: Vector2
var right_bar_rest_pos: Vector2

var image: Image = null
var object_ids = []
var difficulty_buttons = []

#var piece_size: Vector2 = Vector2.ZERO
var piece_size: Vector2 = Vector2(100, 100)
#@onready var preview: TextureRect = $ImagePreview
#@onready var loader = $Control2
#@onready var score_label = $ScoreLabel

func _ready():
	http = HTTPRequest.new()
	add_child(http)
	G.game_won.connect(game_won)
	difficulty_buttons = [
		easybtn,
		medbtn,
		hardbtn,
		lunaticbtn
	]
	
	#left_bar_rest_pos = left_bar.position
	#right_bar_rest_pos = right_bar.position

	win_label.hide()
	#left_bar.hide()
	#right_bar.hide()
	#black_fade.modulate = Color(1,1,1,0)
	#var blur_mat := blur_rect.material as ShaderMaterial
	#blur_rect.modulate = Color(1, 1, 1, 0)
	#blur_mat.set_shader_parameter("blur_amount", 0.0)
	#blur_overlay.modulate = Color(1, 1, 1, 0)

	#var blur_mat := blur_overlay.material as ShaderMaterial
	#blur_mat.set_shader_parameter("blur_amount", 0.0)
	#blur_mat.set_shader_parameter("dark_amount", 0.0)
	
	rng.randomize()
	circle_template.hide()
	circles_running = true
	spawn_circles()
	
	init_game()


func spawn_circles() -> void:
	while circles_running:
		spawn_one_circle()
		if not is_inside_tree():
			return
			
		await get_tree().create_timer(0.4).timeout
		
		
				
func init_game(reload := false) -> void:
	win_animation_played = false
	
	win_label.hide()
	#left_bar.hide()
	#right_bar.hide()
	#left_bar.position = left_bar_rest_pos
	#right_bar.position = right_bar_rest_pos
	win_label.modulate = Color(1, 1, 1, 1)
	free_stuff()
	G.game_over = false
	G.top_piece_z = 10

	if reload or not image:
		image = G.get_image()

	image = scale_image(image)

	var texture: ImageTexture = ImageTexture.create_from_image(image)

	piece_size = Vector2(
		texture.get_width() / G.grid_size.x,
		texture.get_height() / G.grid_size.y
	)

	draw_cells()

	if G.cells.size() > 0:
		G.board_origin = G.cells[0].global_position

	generate_pieces()
	start.play()
	
func spawn_one_circle() -> void:
	var clone_circle: TextureRect = circle_template.duplicate()
	background.add_child(clone_circle)
	clone_circle.scale = Vector2(0.3, 0.3)
	clone_circle.show()
	

	var screen_size: Vector2 = get_viewport_rect().size

	var start_x: float = rng.randf_range(0.0, screen_size.x)
	var start_y: float = screen_size.y + 40.0

	clone_circle.position = Vector2(start_x, start_y)
	clone_circle.modulate = Color(1, 1, 1, 1)

	var drift_x: float = rng.randf_range(-40.0, 40.0)
	var end_y: float = start_y - screen_size.y * 0.5

	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CIRC)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(clone_circle, "position:x", start_x + drift_x, 15.0)
	tween.tween_property(clone_circle, "position:y", end_y, 15.0)
	tween.tween_property(clone_circle, "modulate:a", 0.0, 15.0)

	await tween.finished
	clone_circle.queue_free()
	
func free_stuff():
	for cell in G.cells:
		cell.queue_free()
	for piece in G.pieces:
		piece.queue_free()
	G.cells = []
	G.pieces = []

#func draw_cells():
	#for i in range(G.grid_size.x):
		#for j in range(G.grid_size.y):
			#add_cell(i, j)
			
func draw_cells() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size

	var board_size: Vector2 = Vector2(
		piece_size.x * G.grid_size.x,
		piece_size.y * G.grid_size.y
	)

	var board_top_left: Vector2 = (viewport_size - board_size) * 0.5

	for i in range(G.grid_size.x):
		for j in range(G.grid_size.y):
			add_cell(i, j, board_top_left)
			


func play_win_animation() -> void:
	
	win_label.show()
	#left_bar.show()
	#right_bar.show()

	win_label.modulate = Color(1, 1, 1, 0)

	var center_x: float = (left_bar_rest_pos.x + right_bar_rest_pos.x) * 0.5

	#left_bar.position = left_bar_rest_pos
	#right_bar.position = right_bar_rest_pos

	#left_bar.position.x = center_x
	#right_bar.position.x = center_x

	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(win_label, "modulate:a", 1.0, 0.20)
	winsound.play()
	#tween.tween_property(left_bar, "position:x", left_bar_rest_pos.x, 0.45)
	#tween.tween_property(right_bar, "position:x", right_bar_rest_pos.x, 0.45)

func add_cell(
	i: int,
	j: int,
	board_top_left: Vector2
) -> void:
	var cell = cell_scene.instantiate()

	cells.add_child(cell)
	G.cells.append(cell)

	cell.global_position = board_top_left + Vector2(
		piece_size.x * i + piece_size.x * 0.5,
		piece_size.y * j + piece_size.y * 0.5
	)

	var idx: int = j * G.grid_size.x + i
	cell.init_cell(idx, piece_size)
	
func generate_pieces() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var half_piece: Vector2 = piece_size * 0.5

	var board_size: Vector2 = Vector2(
		piece_size.x * G.grid_size.x,
		piece_size.y * G.grid_size.y
	)

	var board_rect: Rect2 = Rect2(
		G.board_origin - half_piece,
		board_size
	)

	var forbidden_rect: Rect2 = board_rect.grow(15.0)

	for i in range(G.grid_size.x):
		for j in range(G.grid_size.y):
			var piece = piece_scene.instantiate()
			pieces.add_child(piece)
			G.pieces.append(piece)

			var region: Rect2 = Rect2(
				i * piece_size.x,
				j * piece_size.y,
				piece_size.x,
				piece_size.y
			)

			var sub_image: Image = image.get_region(
				Rect2i(region.position, region.size)
			)

			var sub_tex: ImageTexture = ImageTexture.create_from_image(sub_image)

			var index: int = j * G.grid_size.x + i

			var pos: Vector2 = Vector2.ZERO
			var attempts: int = 0
			const MAX_SPAWN_ATTEMPTS: int = 200

			while attempts < MAX_SPAWN_ATTEMPTS:
				var candidate: Vector2 = Vector2(
					randf_range(half_piece.x, viewport_size.x - half_piece.x),
					randf_range(half_piece.y, viewport_size.y - half_piece.y)
				)

				var candidate_piece_rect: Rect2 = Rect2(
					candidate - half_piece,
					piece_size
				)

				if not candidate_piece_rect.intersects(forbidden_rect, true):
					pos = candidate
					break

				attempts += 1

			if pos == Vector2.ZERO:
				pos = Vector2(
					half_piece.x + 10.0,
					half_piece.y + 10.0
				)

			piece.init_piece(
				index,
				sub_tex,
				pos,
				piece_size
			)
			
#this code is so shit sweet mother jesus
func scale_image(image: Image):
	var new_image = Image.new()
	new_image.copy_from(image)
	var original_size = image.get_size()
	var max_size: Vector2 = Vector2(550, 550)
	var scale_factor = min(
		max_size.x / original_size.x,
		max_size.y / original_size.y
	)
	var new_size = (original_size * scale_factor).floor()
	new_image.resize(new_size.x, new_size.y, Image.INTERPOLATE_LANCZOS)
	return new_image



func hide_difficulty_buttons() -> void:
	for button: Button in difficulty_buttons:
		button.hide()
		
func show_difficulty_buttons() -> void:
	for button: Button in difficulty_buttons:
		button.show()
				

	
#var win_animation_played := false
func play_post_win_screen_effect() -> void:
	#black_fade.show()
	#blur_rect.show()

	#black_fade.modulate = Color(1, 1, 1, 1)
	#blur_rect.modulate = Color(1, 1, 1, 1)

	#var blur_mat := blur_rect.material as ShaderMaterial
	#blur_mat.set_shader_parameter("blur_amount", 4.0)

	var tween := create_tween()
	tween.set_parallel(true)

	#tween.tween_property(black_fade, "modulate:a", 0.0, 3.15)
	#tween.tween_property(blur_rect, "modulate:a", 0.0, 3.15)
	#tween.tween_method(
	#	func(v): blur_mat.set_shader_parameter("blur_amount", v),
	#	4.0,
	#	0.0,
	#	2.75
	#)
	
func game_won():
	if win_animation_played:
		return
	
	win_animation_played = true
	#print("game won yay")
	#score_label.text = "Score: " + str(G.score)
	#pass
	play_win_animation()
	
	
	await get_tree().create_timer(3.0).timeout
	
	#play_post_win_screen_effect()
	#await get_tree().create_timer(3.2).timeout
	G.play_return_transition = true
	circles_running = false
	G.game_over = false
	G.cells = []
	G.pieces = []
	get_tree().change_scene_to_file("res://scenes/PuzzleSelect.tscn")
	#play_post_win_screen_effect()
	
func change_difficulty(new_difficulty: int) -> void:
	G.set_difficulty(new_difficulty)
	hide_difficulty_buttons()
	init_game(false)

func _on_easy_pressed() -> void:
	change_difficulty(G.DIFFICULTY.EASY) 


func _on_medium_pressed() -> void:
	change_difficulty(G.DIFFICULTY.MEDIUM)


func _on_hard_pressed() -> void:
	change_difficulty(G.DIFFICULTY.HARD)


func _on_lunatic_pressed() -> void:
	change_difficulty(G.DIFFICULTY.LUNATIC)
