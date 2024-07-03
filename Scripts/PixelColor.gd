class_name PixelColor
extends Resource


var color: Color
var pixels_left: int = 0
var number: int


func _init(new_color: Color, new_number: int) -> void:
	self.color = new_color
	self.number = new_number
