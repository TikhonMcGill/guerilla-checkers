extends Node2D

const TILE_SCENE := preload("res://assets/scenes/game_board/tile/tile.tscn")
const CORNER_SCENE := preload("res://assets/scenes/game_board/corner/corner.tscn")

signal mouse_over_tile(tile : Tile)
signal mouse_over_corner(corner : Corner)

@export_color_no_alpha var tile_color_1 = Color.WHITE
@export_color_no_alpha var tile_color_2 = Color.BLACK
@export_color_no_alpha var corner_color = Color.DIM_GRAY

@export_color_no_alpha var coin_checker_color = Color.BLUE
@export_color_no_alpha var guerilla_piece_color = Color.RED

@export var tile_size : int = 48
@export var label_cells : bool = false
@export var label_corners : bool = false

@onready var tiles = $Tiles
@onready var corners = $Corners

@onready var pieces_left_label = $PiecesLeftLabel

var cells : Array[Tile] = []

func _ready():
	_initialize_board()

func _initialize_board():
	_initialize_cells()
	_initialize_corners()
	_initialize_label()

##Place all Cells of the Board in an 8-by-8 grid
func _initialize_cells():
	var col1 = true
	for y in range(8):
		for x in range(8):
			var col: Color = tile_color_1
			if col1 == false:
				col = tile_color_2
			
			var tile = _create_tile(col,Vector2i(x,y))
			
			#It is at the second color (e.g. the blacks) that the COIN Checkers are placed,
			#So we keep track of those specifically
			if col1 == false:
				cells.append(tile)
				if label_cells == true:
					tile.get_node("Label").text = str(len(cells)-1)
			
			col1 = not col1
		col1 = not col1

##Place all corners of the board
func _initialize_corners():
	#The idea is to place a corner into the bottom-right of every
	#cell which HAS a cell below it and to the right of it
	#
	#This means the bottom 8 cells are not suitable, as they have
	#nothing below them (hence iterating through 56)
	#
	#As for the remaining 56 cells, if the Cell is a multiple of 8,
	#it is at the end of the row, meaning there is nothing to the right
	#of it, so we do NOT create a corner in its bottom-right corner
	for cell in range(56):
		if cell % 8 != 0:
			#Admittedly, this position offset was determined experimentally
			var tile : Tile = tiles.get_child(cell)
			var placement_position : Vector2i = tile.global_position
			placement_position.x -= tile.size.x
			
			#Subtract half of the Corner's size, so that it is in the middle of
			#the corner
			placement_position -= Vector2i(tile_size,tile_size)/8
			
			var corner := _create_corner(placement_position)
			
			if label_corners == true:
				corner.get_node("Label").text = str(corner.get_index())

func _initialize_label():
	pieces_left_label.text = "Guerilla Pieces Left: 66"
	pieces_left_label.add_theme_font_size_override("font_size",tile_size / 2)
	pieces_left_label.position = Vector2i(0,-pieces_left_label.size.y)

##Create a Tile representing a cell with the selected color at the selected position
func _create_tile(_tile_col : Color,_tile_pos : Vector2i) -> Tile:
	var new_tile : Tile = TILE_SCENE.instantiate()
	new_tile.size = Vector2i(tile_size,tile_size)
	
	new_tile.global_position = _tile_pos * tile_size
	
	new_tile.color = _tile_col
	
	new_tile.mouse_entered_tile.connect(handle_mouse_tile_enter)
	
	tiles.add_child(new_tile)
	
	return new_tile

##Create a Corner at the selected position, its color dictated by the export variable
func _create_corner(_corner_pos : Vector2i) -> Corner:
	var new_corner : Corner = CORNER_SCENE.instantiate()
	new_corner.size = Vector2i(tile_size/4,tile_size/4)
	
	#Set the Corner's pivot to be in the center
	new_corner.pivot_offset = new_corner.size/2
	
	new_corner.global_position = _corner_pos
	
	new_corner.color = corner_color
	
	new_corner.mouse_entered_corner.connect(handle_mouse_corner_enter)
	
	corners.add_child(new_corner)
	
	return new_corner

func handle_mouse_tile_enter(tile : Tile):
	mouse_over_tile.emit(tile)

func handle_mouse_corner_enter(corner : Corner):
	mouse_over_corner.emit(corner)

func get_cell_tile(cell : int) -> Tile:
	return cells[cell]
