extends Button

class_name Corner

signal corner_pressed(corner : Corner)

@onready var color_rect: ColorRect = $ColorRect

func _on_pressed() -> void:
	corner_pressed.emit(self)

func set_color(color : Color):
	color_rect.color = color
