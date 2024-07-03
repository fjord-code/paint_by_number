class_name  PixelArtImage
extends Resource


signal texture_changed(Texture2D)
signal color_pixel_amount_changed(PixelColor)
signal pixel_state_changed(Pixel)
signal picture_painted

# Исходное изображение.
var source_image: Image
# Изображение, которое отображается для игрока.
var display_image: Image
# Словарь частотности встречающихся цветов.
var _colors: Dictionary
# Список пикселей с их состоянием, координаты пикселя определяются в порядке (x, y).
var _pixels: Array[Array]

var colors: Dictionary:
	get:
		return self._colors

var pixels: Array[Array]:
	get:
		return self._pixels

var pixels_left := 0


func _init(texture: Texture2D) -> void:
	self._load_from_texture(texture)


# Строит изображение по текстуре.
func _load_from_texture(texture: Texture2D) -> void:
	self.source_image = texture.get_image()
	self.display_image = texture.get_image()

	# Цикл по пикселям изображения.
	self._pixels = []
	self._colors = {}
	var color_number = 1
	for x: int in range(source_image.get_width()):
		var pixel_column: Array[Pixel] = []

		for y: int in range(source_image.get_height()):
			# Составляет массив состояний пикселей изображения.
			var pixel_color := source_image.get_pixel(x, y)
			var statement := Enums.PIXEL_STATEMENT.NONE if is_zero_approx(pixel_color.a) else Enums.PIXEL_STATEMENT.UNPAINTED
			var pixel_position := Vector2i(x, y)

			var new_pixel := Pixel.new(pixel_position, pixel_color, statement)

			pixel_column.append(new_pixel)

			# Составляет словарь частотностей цветов.
			if not self._colors.has(pixel_color):
				# Определяет номер цвета.
				var actual_color_number: int = color_number

				if is_zero_approx(pixel_color.a):
					actual_color_number = 0
				else:
					color_number += 1

				var pixel_color_data := PixelColor.new(pixel_color, actual_color_number)

				self._colors[pixel_color] = pixel_color_data

			if not is_zero_approx(pixel_color.a):
				self.pixels_left += 1

			self._colors[pixel_color].pixels_left += 1

			# Создаёт изображение для раскраски.
			var grayed_color := get_grayscale_from(pixel_color)
			self.display_image.set_pixel(x, y, grayed_color)

		self._pixels.append(pixel_column)


# Возвращает текстуру раскраски.
func get_texture() -> Texture2D:
	return ImageTexture.create_from_image(display_image)


# Закрашивает пиксель переданным цветом.
func _force_paint_pixel(pixel_position: Vector2i, color: Color) -> void:
	var pixel: Pixel = self._pixels[pixel_position.x][pixel_position.y]
	pixel.state = Enums.PIXEL_STATEMENT.PAINTED
	self.display_image.set_pixelv(pixel_position, color)
	self.colors[color].pixels_left -= 1
	self.pixels_left -= 1

	self.texture_changed.emit(self.get_texture())
	self.color_pixel_amount_changed.emit(self.colors[color])
	self.pixel_state_changed.emit(pixel)

	if self.pixels_left == 0:
		self.picture_painted.emit()


# Закрашивает пиксель его исходным цветом.
func paint_pixel(pixel_position: Vector2i) -> void:
	# Закрашивает пиксель с переданными координатами.
	if not self._pixels[pixel_position.x][pixel_position.y].state == Enums.PIXEL_STATEMENT.UNPAINTED:
		return

	var original_color := self.source_image.get_pixelv(pixel_position)

	self._force_paint_pixel(pixel_position, original_color)


# Закрашивает пиксель переданным цветом, если это можно сделать.
func paint_pixel_with_color(pixel_position: Vector2i, color: Color) -> void:
	# Проверяет, закрашен ли пиксель.
	if not self._pixels[pixel_position.x][pixel_position.y].state == Enums.PIXEL_STATEMENT.UNPAINTED:
		return

	# Проверяет, совпадают ли цвета пикселей.
	var original_color := self.source_image.get_pixelv(pixel_position)
	if color != original_color:
		return

	# Закрашивает пиксель.
	self._force_paint_pixel(pixel_position, color)


func get_grayscale_from(color: Color) -> Color:
	# Преобразует цвет в оттенок серого.
	var grayscale_shade := (0.2989 * color.r + 0.5870 * color.g + 0.1140 * color.b)
	var grayscale_color := Color(grayscale_shade, grayscale_shade, grayscale_shade, color.a)
	return grayscale_color

