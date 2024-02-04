extends Button

class_name Tile

signal tile_pressed(tile : Tile)

@onready var color_rect = $ColorRect

func set_color(col : Color):
	color_rect.color = col

func _on_pressed():
	print("Pressed!")
	tile_pressed.emit(self)
