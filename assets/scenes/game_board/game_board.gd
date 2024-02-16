extends Node2D

class_name GameBoard

const TILE_SCENE := preload("res://assets/scenes/game_board/tile/tile.tscn")
const CORNER_SCENE := preload("res://assets/scenes/game_board/corner/corner.tscn")

const COIN_CHECKER_SCENE := preload("res://assets/scenes/game_board/coin_checker/coin_checker.tscn")
const GUERILLA_PIECE_SCENE := preload("res://assets/scenes/game_board/guerilla_piece/guerilla_piece.tscn")

signal tile_pressed(tile : Tile)

signal corner_pressed(corner : Corner)

signal animation_complete

@export_color_no_alpha var tile_color_1 = Color.LIGHT_GRAY
@export_color_no_alpha var tile_color_2 = Color.BLACK
@export_color_no_alpha var corner_color = Color.DIM_GRAY

@export_color_no_alpha var placeable_corner_color = Color.LIGHT_GREEN
@export_color_no_alpha var moveable_cell_color = Color.GREEN

@export_color_no_alpha var coin_checker_color = Color.DODGER_BLUE
@export_color_no_alpha var guerilla_piece_color = Color.ORANGE

@export_color_no_alpha var selected_coin_checker_color = Color.CYAN

@export var tile_size : int = 48
@export var label_cells : bool = false
@export var label_corners : bool = false

@onready var tiles = $Tiles
@onready var corners = $Corners

@onready var coin_checkers = $COINCheckers
@onready var guerilla_pieces = $GuerillaPieces

@onready var pieces_left_label = $PiecesLeftLabel
@onready var current_player_label = $CurrentPlayerLabel

var cells : Array[Tile] = []

func _ready():
	_initialize_board()

func _initialize_board():
	_initialize_cells()
	_initialize_corners()
	_initialize_labels()

##Clear all pieces present on the board
func _clear_pieces() -> void:
	#Clear all COIN Checkers
	for checker in coin_checkers.get_children():
		checker.queue_free()
	
	#Clear all Guerilla Pieces
	for piece in guerilla_pieces.get_children():
		piece.queue_free()

##Represent a Game State
func represent_game_state(_game_state : GameState) -> void:
	_clear_pieces()
	#Place the COIN Checkers based on their Cell positions in the Game State
	for checker in _game_state.coin_checker_positions:
		_create_coin_checker(checker)
	
	#Place the Guerilla Pieces based on their Corner positions in the Game State
	for piece in _game_state.guerilla_piece_positions:
		_create_guerilla_piece(piece)
	
	pieces_left_label.text = "Guerilla Pieces Left: %d" % _game_state.guerilla_pieces_left
	show_current_player(_game_state.get_current_player())
	
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
				tile.tile_pressed.connect(handle_tile_pressed)
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

func update_guerilla_piece_left_label(amount : int):
	pieces_left_label.text = "Guerilla Pieces Left: %d" % amount

func _initialize_labels():
	update_guerilla_piece_left_label(66)
	pieces_left_label.add_theme_font_size_override("font_size",tile_size / 2)
	pieces_left_label.position = Vector2i(0,-pieces_left_label.size.y)
	
	current_player_label.text = "Current Player: Guerilla"
	current_player_label.add_theme_font_size_override("font_size",tile_size/2)
	current_player_label.position = Vector2i(0,8 * tile_size)

##Method to write in the label which player's turn it is
func show_current_player(player : GameState.PLAYER):
	if player == GameState.PLAYER.COIN:
		current_player_label.text = "Current Player: %s (COIN)" % GameManager.coin_player_name
	elif player == GameState.PLAYER.GUERILLA:
		current_player_label.text = "Current Player: %s (Guerilla)" % GameManager.guerilla_player_name
	else:
		current_player_label.text = "Game Over"

##Create a Tile representing a cell with the selected color at the selected position
func _create_tile(_tile_col : Color,_tile_pos : Vector2i) -> Tile:
	var new_tile : Tile = TILE_SCENE.instantiate()
	new_tile.size = Vector2i(tile_size,tile_size)
	
	new_tile.global_position = _tile_pos * tile_size
	
	tiles.add_child(new_tile)
	
	new_tile.set_color(_tile_col)
	
	return new_tile

##Create a Corner at the selected position, its color dictated by the export variable
func _create_corner(_corner_pos : Vector2i) -> Corner:
	var new_corner : Corner = CORNER_SCENE.instantiate()
	new_corner.size = Vector2i(tile_size/4,tile_size/4)
	
	new_corner.global_position = _corner_pos
	
	
	new_corner.corner_pressed.connect(handle_corner_pressed)
	
	corners.add_child(new_corner)
	new_corner.set_color(corner_color)
	
	return new_corner

##Function to color the board by default
func default_color_board():
	for corner : Corner in corners.get_children():
		corner.set_color(corner_color)
	
	for cell_tile : Tile in cells:
		cell_tile.set_color(tile_color_2)

##Function to get the index of the Corner from the board
func get_corner_index(corner : Corner) -> int:
	return corner.get_index()

##Function to create a COIN Checker at a specific cell
func _create_coin_checker(cell : int) -> CoinChecker:
	var new_coin_checker : CoinChecker = COIN_CHECKER_SCENE.instantiate()
	
	new_coin_checker.my_cell = cell
	
	var cell_tile = get_cell_tile(cell)
	
	new_coin_checker.size = cell_tile.size
	
	new_coin_checker.modulate = coin_checker_color
	
	new_coin_checker.position = cell_tile.position
	
	coin_checkers.add_child(new_coin_checker)
	
	return new_coin_checker

##Function to create a Guerilla Piece at a specific corner
func _create_guerilla_piece(corner : int,piece_visible:bool=true) -> GuerillaPiece:
	var new_guerilla_piece : GuerillaPiece = GUERILLA_PIECE_SCENE.instantiate()
	
	new_guerilla_piece.my_corner = corner
	
	var graphical_corner = corners.get_child(corner)
	
	new_guerilla_piece.modulate = guerilla_piece_color
	
	#If the Piece is not set to visible, make it hidden - useful for instantiating a piece
	#and animating its appearance
	if piece_visible == false:
		new_guerilla_piece.modulate.a = 0
	
	new_guerilla_piece.position = graphical_corner.position
	new_guerilla_piece.size = graphical_corner.size
	
	guerilla_pieces.add_child(new_guerilla_piece)
	
	return new_guerilla_piece

##Get the Checker Graphic at the Cell, if it exists
func get_checker_at_cell(cell : int) -> CoinChecker:
	for checker : CoinChecker in coin_checkers.get_children():
		if checker.my_cell == cell:
			return checker
	push_warning("Checker not found at cell %d" % cell)
	return null

##Get the Guerilla Piece in the Corner, if it exists
func get_piece_in_corner(corner : int) -> GuerillaPiece:
	for piece : GuerillaPiece in guerilla_pieces.get_children():
		if piece.my_corner == corner:
			return piece
	push_warning("Piece not found in corner %d" % corner)
	return null

func handle_tile_pressed(tile : Tile):
	tile_pressed.emit(tile)

func handle_corner_pressed(corner : Corner):
	corner_pressed.emit(corner)

func get_cell_tile(cell : int) -> Tile:
	return cells[cell]

func get_graphical_corner(corner : int) -> Corner:
	return corners.get_child(corner)

func _on_game_state_guerilla_piece_placed(corner : int):
	var new_piece := _create_guerilla_piece(corner,false)
	var tween := get_tree().create_tween()
	
	tween.tween_property(new_piece,"modulate:a",1.0,0.5)
	
	await tween.finished
	animation_complete.emit()

func _on_game_state_coin_checker_moved(cell_from : int, cell_to : int):
	var coin_checker := get_checker_at_cell(cell_from)
	coin_checker.my_cell = cell_to
	
	var tween = create_tween()
	tween.tween_property(coin_checker,"position",get_cell_tile(cell_to).position,0.25)
	
	await tween.finished
	animation_complete.emit()

func _on_game_state_guerilla_piece_captured(corner : int):
	var captured_piece := get_piece_in_corner(corner)
	
	var tween := get_tree().create_tween()
	
	tween.tween_property(captured_piece,"modulate:a",0,0.5)
	tween.tween_callback(captured_piece.queue_free)

func _on_game_state_coin_checker_captured(cell : int):
	var captured_checker := get_checker_at_cell(cell)
	
	var tween := get_tree().create_tween()
	
	tween.tween_property(captured_checker,"modulate:a",0,0.5)
	tween.tween_callback(captured_checker.queue_free)

func get_tile_cell(tile : Tile) -> int:
	return cells.find(tile)
