extends Button

class_name Corner

signal corner_pressed(corner : Corner)

func _on_pressed() -> void:
	corner_pressed.emit(self)

func set_color(color : Color):
	self_modulate = color
