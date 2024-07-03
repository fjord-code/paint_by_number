class_name LabeledColorRect
extends Button


const FINISHED_MARK := '✓'

@onready var color_rect := $ColorRect
@onready var label := $ColorRect/Label


var label_text: int:
	set(value):
		label.text = str(value) if value > 0 else FINISHED_MARK


var color: Color:
	get:
		return color_rect.color
	set(value):
		color_rect.color = value


func _ready() -> void:
	self.connect('pressed', _on_button_pressed)


func setup(new_color: Color, number: int) -> void:
	self.color = new_color
	self.label_text = number


func _on_button_pressed():
	EventBus.active_color_changed.emit(self.color)
