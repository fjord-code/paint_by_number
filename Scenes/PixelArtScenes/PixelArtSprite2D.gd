extends Sprite2D


@onready var pixelart_image := PixelArtImage.new(Scenario.texture)

var active_color: Color


func _ready() -> void:
	self.texture = self.pixelart_image.get_texture()

	self.pixelart_image.connect("texture_changed", _on_texture_changed)


func _input(event: InputEvent) -> void:
	# Обработка кликов.
	# Проверяет, можно ли интерпретировать событие как раскрашивание.
	if (
		not (event is InputEventMouseButton or event is InputEventMouseMotion)
		or not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
		):
		return

	var local_mouse_position := get_local_mouse_position()
	var sprite_rect := self.get_rect()

	# Проверяет, попала ли мышь в границы изображения.
	if not sprite_rect.has_point(local_mouse_position): return

	var pixel_position := Vector2i(local_mouse_position)
	self.pixelart_image.paint_pixel_with_color(pixel_position, active_color)


func _on_texture_changed(new_texture: Texture2D) -> void:
	self.texture = new_texture


func _on_active_color_changed(color: Color) -> void:
	self.active_color = color
