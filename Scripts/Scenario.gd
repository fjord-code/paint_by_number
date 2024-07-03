extends Node


var current_scene: Enums.SCENES = Enums.SCENES.PAINT_PEARL
var texture: Texture2D

var _active_scene_name = 'PixelArtPainter'


func _ready() -> void:
	self.texture = preload("res://Assets/Images/pearl_01b.png")
	EventBus.scene_finished.connect(self._change_scene)


func _load_pixel_art_painter(new_texture: Texture2D) -> void:
	get_node("/root/" + self._active_scene_name).call_deferred('free')

	var pixel_art_painter: PixelArtPainter = preload("res://Scenes/PixelArtPainter.tscn").instantiate()
	self.texture = new_texture
	get_tree().root.add_child(pixel_art_painter)
	self._active_scene_name = pixel_art_painter.name


func _change_scene() -> void:
	if current_scene == Enums.SCENES.PAINT_PEARL:
		self._load_pixel_art_painter(preload("res://Assets/Images/gift_01a.png"))
		current_scene = Enums.SCENES.PAINT_GIFT

	elif current_scene == Enums.SCENES.PAINT_GIFT:
		self._load_pixel_art_painter(preload("res://Assets/Images/Cat-2-Sitting.png"))
		current_scene = Enums.SCENES.PAINT_LUNA
