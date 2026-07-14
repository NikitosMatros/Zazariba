extends Node

var cells = []
var pieces = []
var dragging = false
var score = 0
var game_over = false
var top_piece_z: int = 10
var selected_image_index: int = 0
var play_return_transition := false

var base_url := "https://collectionapi.metmuseum.org/public/collection/v1"

signal game_won

const images = [
	"res://images/1.jpg",
	"res://images/2.png",
	"res://images/3.jpg",
	"res://images/4.png",
]

enum DIFFICULTY {
	EASY,
	MEDIUM,
	HARD,
	LUNATIC
}

const DIFFICULTY_VALUES = {
	DIFFICULTY.EASY: 3,
	DIFFICULTY.MEDIUM: 4,
	DIFFICULTY.HARD: 5,
	DIFFICULTY.LUNATIC: 10,
}

var chosen_difficulty = DIFFICULTY.EASY	
var grid_size = Vector2i(
	DIFFICULTY_VALUES[chosen_difficulty],
	DIFFICULTY_VALUES[chosen_difficulty]
)

var board_origin: Vector2 = Vector2.ZERO

#func get_image():
	#randomize()
	#var image = Image.load_from_file(images.pick_random())
#	return image
func get_image() -> Image:
	var texture: Texture2D = load(images[selected_image_index])
	return texture.get_image()

func find_cell(index: int):
	for cell in cells:
		if cell.index == index:
			return cell


func set_difficulty(new_difficulty: DIFFICULTY) -> void:
	chosen_difficulty = new_difficulty

	var grid_value: int = int(DIFFICULTY_VALUES[chosen_difficulty])

	grid_size = Vector2i(grid_value, grid_value)

func check_win():
	for piece in pieces:
		if piece.index != piece.cell_index:
			return
	score = score + 1
	game_over = true
	game_won.emit()
