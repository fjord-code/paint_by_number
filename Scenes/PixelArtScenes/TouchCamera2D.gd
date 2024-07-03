# Скрипт для управления камерой.
extends Camera2D

enum DRAG_MODES {MOVE, PAINT}

const MAGNIFY_GESTURE_THRESHOLD := 1e-3

@export var max_zoom: float = 55.75

var pan_speed := 1
var pan_steering_factor := 12.0
var zoom_speed := 0.1
var zoom_steering_factor := 6.0

var _initial_image_size := Vector2i.ONE
var control_enabled := true

# Тип действия при зажиме мышкой.
var drag_mode := DRAG_MODES.MOVE

@onready var target_zoom := Vector2.ONE
@onready var target_position := self.position
@onready var viewport := get_viewport()


func _process(delta: float) -> void:
	# Ограничивает величину максимального приближения.
	if self.target_zoom.x > self.max_zoom:
		self.target_zoom = Vector2.ONE * self.max_zoom

	# Плавное увеличение в ту область, куда указывает курсор мыши.
	var zoom_steering_vector := target_zoom - self.zoom
	if zoom_steering_vector.length() > 1e-1:
		# Получает предыдущее положение курсора мыши.
		var old_mouse_position := get_local_mouse_position()
		# Применяет увеличение.
		self.zoom += zoom_steering_vector * zoom_steering_factor * delta
		# Получает новое положение курсора мыши.
		var new_mouse_position := get_local_mouse_position()
		# Вычисляет смещение курсора мыши.
		var mouse_shift := new_mouse_position - old_mouse_position
		# Компенсирует смещение курсора мыши, перемещая камеру в противоположну сторону.
		target_position -= mouse_shift
		position -= mouse_shift # Убирает скачки камеры при увеличении.

	# Плавное перемещение камеры.
	var pan_steering_vector := target_position - self.position
	self.position += pan_steering_vector * pan_steering_factor * delta


func _unhandled_input(event: InputEvent) -> void:
	if not self.control_enabled: return

	# Обработка события масштабирования на сенсорном экране.
	if (event is InputEventMagnifyGesture):
		var magnify_event := event as InputEventMagnifyGesture

		if abs(event.factor - 1.0) <= MAGNIFY_GESTURE_THRESHOLD: return

		self.target_zoom *= magnify_event.factor
		self.zoom *= magnify_event.factor

	if (event is InputEventPanGesture):
		var pan_event := event as InputEventPanGesture
		self.target_position += pan_event.delta / self.zoom.x

	# Обработка прокрутки колёсика мыши.
	elif (event is InputEventMouseButton):
		var mouse_event := event as InputEventMouseButton
		var zoom_factor := 1.0

		if mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_factor += zoom_speed
		elif mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_factor -= zoom_speed
		elif mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.is_released():
			self.drag_mode = DRAG_MODES.MOVE

		self.target_zoom *= zoom_factor

	# Обработка перетягивания камеры при нажатии на левую кнопку мыши.
	elif (
		event is InputEventMouseMotion
		and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
		and self.drag_mode == DRAG_MODES.MOVE
		):
		var mouse_motion_event := event as InputEventMouseMotion
		self.target_position -= mouse_motion_event.relative * pan_speed / self.zoom.x


func _on_color_pixel_amount_changed(pixel_color: PixelColor) -> void:
	# Если закрасился пиксель, то камера переходит в режим раскрашивания.
	# Если все пиксели закрашены, то камера переходит в режим перетаскивания.
	self.drag_mode = DRAG_MODES.PAINT if pixel_color.pixels_left > 0 else DRAG_MODES.MOVE


func setup(image_size: Vector2i, immediate_transition: bool = true) -> void:
	self._initial_image_size = image_size

	self.target_zoom = Vector2.ONE * (432.0 / image_size.x)
	if immediate_transition: self.zoom = self.target_zoom

	self.target_position = image_size * 0.5
	if immediate_transition: self.position = self.target_position


func _on_pictire_painted() -> void:
	self.control_enabled = false
	self.setup(self._initial_image_size, false)
