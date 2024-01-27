extends Node2D

@export_color_no_alpha var tile_color_1 = Color.WHITE
@export_color_no_alpha var tile_color_2 = Color.BLACK
@export_color_no_alpha var corner_color = Color.WEB_GRAY

@export var tile_size : int = 48

@onready var tiles = $Tiles
@onready var corners = $Corners

@onready var pieces_left_label = $PiecesLeftLabel

var cells : Array[ColorRect] = []

func _ready():
	_initialize_board()

func _initialize_board():
	_initialize_cells()
	_initialize_label()

func _initialize_cells():
	var col1 = true
	for x in range(8):
		for y in range(8):
			var col: Color = tile_color_1
			if col1 == false:
				col = tile_color_2
			
			_create_tile(col,Vector2i(x,y))
			
			#It is at the second color (the blacks) that the COIN Checkers are placed,
			#So we keep track of those specifically
			if col1 == false:
				cells.append(tiles.get_child(tiles.get_child_count()-1))
			
			col1 = not col1
		col1 = not col1

func _initialize_label():
	pieces_left_label.text = "Guerilla Pieces Left: 66"
	pieces_left_label.add_theme_font_size_override("font_size",tile_size / 2)
	pieces_left_label.position = Vector2i(0,-pieces_left_label.size.y)

func _create_tile(_tile_col : Color,_tile_pos : Vector2i) -> void:
	var new_tile := ColorRect.new()
	new_tile.size = Vector2i(tile_size,tile_size)
	
	new_tile.global_position = _tile_pos * tile_size
	
	new_tile.color = _tile_col
	
	tiles.add_child(new_tile)
