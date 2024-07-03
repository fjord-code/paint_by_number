class_name Pixel
extends Resource

# Класс представляет собой 1 пиксель.
var position: Vector2i
var color: Color
var state: Enums.PIXEL_STATEMENT


func _init(new_position: Vector2i, new_color: Color, new_state: Enums.PIXEL_STATEMENT) -> void:
	self.position = new_position
	self.color = new_color
	self.state = new_state
