extends Control

@onready var preview: TextureRect = $Preview
#@onready var previous_button: Button = $PreviousButton
#@onready var next_button: Button = $NextButton
@onready var start_button: Button = $StartButton
@onready var left_arrow: TextureButton = $LeftArrow
@onready var right_arrow: TextureButton = $RightArrow
@onready var page_turn: AudioStreamPlayer = $PageTurn
@onready var fx_layer: CanvasLayer = $CanvasLayer
@onready var black_fade: ColorRect = $CanvasLayer/ScreenFade
@onready var blur_rect: ColorRect = $CanvasLayer/BlurOverlay
@onready var start_label: Label = $StartButton/Label

@onready var difficulty_menu: Control = $DiffMenu
@onready var insanr: AudioStreamPlayer = $InsanR



#@onready var easy_button: Button = $DiffMenu/DiffButtons/easy
#@onready var medium_button: Button = $DiffMenu/DiffButtons/medium
#@onready var hard_button: Button = $DiffMenu/DiffButtons/hard
#@onready var lunatic_button: Button = $DiffMenu/DiffButtons/lunatic


var current_index: int = 0


func _ready() -> void:
	current_index = G.selected_image_index

	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	center_preview()
	get_viewport().size_changed.connect(center_preview)
	
	difficulty_menu.hide()
	update_preview()
	if G.play_return_transition:
		G.play_return_transition = false
		play_return_transition()


func center_preview() -> void:
	var max_preview_size: Vector2 = Vector2(550, 550)
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var gap: float = 25.0
	var arrow_size: Vector2 = Vector2(52, 52)

	var image_texture: Texture2D = load(G.images[current_index])
	var image_size: Vector2 = image_texture.get_size()

	var scale_factor: float = minf(
		max_preview_size.x / image_size.x,
		max_preview_size.y / image_size.y
	)

	var displayed_size: Vector2 = image_size * scale_factor

	preview.size = displayed_size
	preview.position = (viewport_size - displayed_size) * 0.5

	left_arrow.size = arrow_size
	right_arrow.size = arrow_size

	left_arrow.position = preview.position + Vector2(
		-gap - arrow_size.x,
		displayed_size.y * 0.5 - arrow_size.y * 0.5
	)

	right_arrow.position = preview.position + Vector2(
		displayed_size.x + gap,
		displayed_size.y * 0.5 - arrow_size.y * 0.5
	)
	
	
func update_preview() -> void:
	var image_texture: Texture2D = load(G.images[current_index])
	preview.texture = image_texture

	center_preview()
		
func _on_previous_button_pressed() -> void:
	current_index -= 1

	if current_index < 0:
		current_index = G.images.size() - 1

	update_preview()

func start_game(difficulty: G.DIFFICULTY) -> void:
	G.selected_image_index = current_index
	G.set_difficulty(difficulty)
	
	
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
	
func _on_next_button_pressed() -> void:
	current_index += 1

	if current_index >= G.images.size():
		current_index = 0

	update_preview()
	
func play_return_transition() -> void:
	black_fade.show()
	blur_rect.show()

	black_fade.modulate = Color(1, 1, 1, 1)
	blur_rect.modulate = Color(1, 1, 1, 1)

	var blur_mat := blur_rect.material as ShaderMaterial
	blur_mat.set_shader_parameter("blur_amount", 4.0)

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(black_fade, "modulate:a", 0.0, 3.15)
	tween.tween_property(blur_rect, "modulate:a", 0.0, 3.15)
	tween.tween_method(
		func(v): blur_mat.set_shader_parameter("blur_amount", v),
		4.0,
		0.0,
		2.75
	)
	insanr.play()

#func _on_start_button_pressed() -> void:
	#G.selected_image_index = current_index
	#get_tree().change_scene_to_file("res://scenes/Main.tscn")
func _on_start_button_pressed() -> void:
	G.selected_image_index = current_index

	preview.hide()
	left_arrow.hide()
	right_arrow.hide()
	$StartButton.hide()

	difficulty_menu.show()


func _on_right_arrow_pressed() -> void:
	page_turn.play()
	_on_next_button_pressed()


func _on_left_arrow_pressed() -> void:
	page_turn.play()
	_on_previous_button_pressed()
	


func _on_easy_pressed() -> void:
	start_game(G.DIFFICULTY.EASY)

func _on_medium_pressed() -> void:
	start_game(G.DIFFICULTY.MEDIUM)

func _on_hard_pressed() -> void:
	start_game(G.DIFFICULTY.HARD)


func _on_lunatic_pressed() -> void:
	start_game(G.DIFFICULTY.LUNATIC)
	
	


func _on_start_button_mouse_entered() -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		start_label,
		"modulate",
		Color(1.4, 1.4, 1.4, 1.0),
		0.15
	)
	



func _on_start_button_mouse_exited() -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		start_label,
		"modulate",
		Color(1, 1, 1, 1),
		0.15
	)
