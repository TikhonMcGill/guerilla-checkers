extends ColorRect

class_name Corner

signal mouse_entered_corner(corner : Corner)

func _on_mouse_entered():
	mouse_entered_corner.emit(self)
