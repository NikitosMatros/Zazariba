extends TextureButton

const FRAME_WIDTH: int = 13
const FRAME_COUNT: int = 3

var frame_index: int = 0
var direction: int = 1

var atlas_texture: AtlasTexture


func _ready() -> void:
	atlas_texture = texture_normal.duplicate(true) as AtlasTexture
	texture_normal = atlas_texture

	animate_frames()


func animate_frames() -> void:
	while is_inside_tree():
		frame_index += direction

		if frame_index >= FRAME_COUNT - 1 or frame_index <= 0:
			direction = -direction

		atlas_texture.region = Rect2(
			frame_index * FRAME_WIDTH,
			0,
			FRAME_WIDTH,
			atlas_texture.atlas.get_height()
		)

		if frame_index == 0:
			await get_tree().create_timer(0.18).timeout
		else:
			await get_tree().create_timer(0.04).timeout
