class_name ColorSelectionMenu
extends CanvasLayer

@export var labeled_color_rect_scene: PackedScene

var _colors: Dictionary = {}

@onready var top_container := $ScrollContainer/MarginContainer/VBoxContainer/TopHBoxContainer
@onready var bottom_container := $ScrollContainer/MarginContainer/VBoxContainer/BottomHBoxContainer


func setup(colors: Dictionary) -> void:
	self._colors.clear()
	for color: Color in colors:
		if is_zero_approx(color.a): continue
		var color_number: int = colors[color].number
		add_color(color, color_number)


func add_color(color: Color, number: int) -> void:
	var labeled_color_rect: LabeledColorRect = labeled_color_rect_scene.instantiate()

	if top_container.get_child_count() > bottom_container.get_child_count():
		bottom_container.add_child(labeled_color_rect)
	else:
		top_container.add_child(labeled_color_rect)

	if not labeled_color_rect.is_node_ready():
		await labeled_color_rect.ready

	labeled_color_rect.setup(color, number)

	self._colors[color] = labeled_color_rect


func _on_color_amount_changed(pixel_color: PixelColor) -> void:
	if pixel_color.pixels_left > 0: return
	self._colors[pixel_color.color].label_text = 0
