class_name PixelArtPainter
extends Node2D


@onready var color_selection_menu := $ColorSelectionMenu
@onready var pixel_art_sprite := $PixelArtSprite2D
@onready var touch_camera := $TouchCamera2D

@onready var pixel_cells := $PixelArtSprite2D/PixelCells


func _ready() -> void:
	# Настраивает цвета для меню выбора цветов.
	var pixelart_image: PixelArtImage = pixel_art_sprite.pixelart_image
	var colors: Dictionary = pixelart_image.colors
	var pixels: Array[Array] = pixelart_image.pixels

	# Настраивает масштаб камеры.
	touch_camera.setup(pixelart_image.display_image.get_size())
	# Добавляет цвета в меню для выбора цветов.
	color_selection_menu.setup(colors)
	# Создаёт ячейки с номерами цветов для пикселей.
	pixel_cells.setup(pixels, colors)

	# Связывает контроллер для раскрашивания с меню для выбора цвета.
	EventBus.active_color_changed.connect(pixel_art_sprite._on_active_color_changed)
	# Связывает меню для выбора цвета с тайлами с номерами цветов.
	EventBus.active_color_changed.connect(pixel_cells._on_active_color_changed)
	# Связывает событие раскрашивания с меню выбора цвета (чтобы отмечать уже раскрашенные цвета).
	pixelart_image.color_pixel_amount_changed.connect(color_selection_menu._on_color_amount_changed)
	# Связывает событие раскрашивания с камерой (чтобы переходить в режим рисования и обратно).
	pixelart_image.color_pixel_amount_changed.connect(touch_camera._on_color_pixel_amount_changed)
	pixelart_image.pixel_state_changed.connect(pixel_cells._on_pixel_state_changed)

	# Обрабатывает событие завершения рисования.
	pixelart_image.picture_painted.connect(self._on_picture_painted)
	pixelart_image.picture_painted.connect(touch_camera._on_pictire_painted)



func _on_picture_painted() -> void:
	await get_tree().create_timer(1.0).timeout
	EventBus.scene_finished.emit()
