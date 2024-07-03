class_name PixelCell
extends Sprite2D


@onready var label := $Label
var color: Color

var label_text: int:
	set(value):
		label.text = str(value)
