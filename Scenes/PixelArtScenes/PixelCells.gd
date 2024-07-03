class_name PixelCells
extends TileMap

var cells: Dictionary = {}
@export var accent_color: Color


func _ready() -> void:
	# Устанавливает размеры тайлов равными размеру пикселя.
	self.scale = Vector2(0.015625, 0.015625)
	self.clear_layer(0)


func setup(pixels: Array[Array], colors: Dictionary) -> void:
	# Создаёт ячейки для номеров.
	for column: Array in pixels:
		for pixel: Pixel in column:
			self.set_cell(0, pixel.position, 0, Vector2i.ZERO, 1)

	# Заставляет добавленные тайлы инициализироваться.
	self.update_internals()

	# Связывает ячейки с их координатами и инициализирует их значениями.
	cells = {}
	# Цикл по добавленным ячейкам.
	for cell: PixelCell in self.get_children():
		# Ожидает, пока ячейка станет редактируемой.
		if not cell.is_node_ready():
			await cell.ready

		# Получает координаты пикселя.
		var cell_position := self.local_to_map(cell.position)
		# Получает данные о пикселе по координатам.
		var pixel: Pixel = pixels[cell_position.x][cell_position.y]
		var cell_state: Enums.PIXEL_STATEMENT = pixel.state
		var pixel_color: PixelColor = colors[pixel.color]
		var cell_number: int = pixel_color.number

		cell.label_text = cell_number
		cell.color = pixel.color

		if (
			cell_state == Enums.PIXEL_STATEMENT.PAINTED
			or cell_state == Enums.PIXEL_STATEMENT.NONE):
			cell.hide()

		cells[cell_position] = cell


# Прячет закрашенные пиксели.
func _on_pixel_state_changed(pixel: Pixel) -> void:
	if pixel.state == Enums.PIXEL_STATEMENT.UNPAINTED: return

	var cell: PixelCell = cells[pixel.position]
	cell.hide()


# Подсвечивает пиксели, соответствующие выбранному цвету.
func _on_active_color_changed(color: Color) -> void:
	for cell: PixelCell in cells.values():
		if cell.color == color:
			cell.modulate = self.accent_color
		else:
			cell.modulate = Color.WHITE
