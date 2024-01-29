extends ColorRect

class_name Tile

signal mouse_entered_tile(tile : Tile)

func _on_mouse_entered():
	mouse_entered_tile.emit(self)
