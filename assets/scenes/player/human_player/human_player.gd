extends Player

class_name HumanPlayer

var game_board : GameBoard

var selected_tile : Tile = null

var can_move = true

var _first_corner_clicked = -1 ##The index of the first corner clicked, if the player is a Guerilla
var _second_corner_clicked = -1 ##The index of the second corner clicked, if the player is a Guerilla

var _first_clicked_corner : Corner = null ##The object representing the first corner clicked, if the player is a Guerilla
var _second_clicked_corner : Corner = null ##The object representing the second corner clicked, if the player is a Guerilla

func do_move() -> void:
	can_move = true
	update_interface()

func update_interface():
	prepare_graphics()
	if is_coin() == true:
		_clear_coin_grid_selections()
		if game_state.game_state == GameState.STATE.COIN_TOOK_PIECE:
			
			var possible_tile = game_board.cells[game_state.taking_coin_checker]
			
			_select_tile(possible_tile)

func _clear_coin_grid_selections():
	for tile : Tile in game_board.cells:
		tile.set_color(game_board.tile_color_2)

func prepare_graphics():
	if game_state.get_current_player() == my_type:
		if is_guerilla() == true:
			setup_guerilla_graphics()
		elif is_coin() == true:
			setup_coin_graphics()

func setup_guerilla_graphics():
	_first_corner_clicked = -1
	_second_corner_clicked = -1
	
	if _first_clicked_corner:
		_first_clicked_corner.set_color(game_board.corner_color)
		_first_clicked_corner = null
	if _second_clicked_corner:
		_second_clicked_corner.set_color(game_board.corner_color)
		_second_clicked_corner = null
	
	
	var placeable_corners = []
	
	for g in game_state.get_possible_corner_pairs():
		var corner = g[0]
		if placeable_corners.has(corner) == false:
			placeable_corners.append(corner)
	
	_paint_placeable_corners(placeable_corners)

func _paint_placeable_corners(placeable_corners : Array) -> void:
	for g in range(len(game_board.corners.get_children())):
		var corner : Corner = game_board.corners.get_child(g)
		if g in placeable_corners:
			corner.set_color(game_board.placeable_corner_color)
		else:
			corner.set_color(game_board.corner_color)

func _select_tile(tile : Tile) -> void:
	if can_move == false:
		return
	
	selected_tile = tile
	var moveable_cells = game_state.get_moveable_cells(game_board.cells.find(tile))
	
	for m in moveable_cells:
		var painted_tile := game_board.get_cell_tile(m)
		painted_tile.set_color(game_board.moveable_cell_color)

func setup_coin_graphics():
	if game_state.game_state == GameState.STATE.COIN_TOOK_PIECE:
		selected_tile = game_board.get_cell_tile(game_state.taking_coin_checker)

func setup_ui(_board : GameBoard):
	game_board = _board
	
	if is_guerilla() == true:
		game_board.corner_pressed.connect(_click_on_corner)
		update_interface()
	elif is_coin() == true:
		game_board.tile_pressed.connect(_click_on_tile)

func _click_on_corner(corner : Corner):
	if is_my_turn() == true and can_move == true and corner:
		var index = game_board.get_corner_index(corner)
		
		if _first_corner_clicked == -1:
			_first_corner_clicked = index
			_first_clicked_corner = corner
			_handle_second_placeable_corner()
			return
		elif _second_corner_clicked == -1:
			_second_corner_clicked = index
			_second_clicked_corner = corner
			_second_clicked_corner.set_color(game_board.placeable_corner_color.inverted())
			var move = GuerillaPiecePlacementMove.new(_first_corner_clicked,_second_corner_clicked)
			move_taken.emit(move)
			can_move = false

func _handle_second_placeable_corner() -> void:
	var second_placeables = []
	for c in game_state.get_adjacent_corners(_first_corner_clicked):
		if game_state.is_corner_occupied(c) == false:
			second_placeables.append(c)
	
	#If there are no second corners to place, it's a draw
	if len(second_placeables) == 0:
		var move = GuerillaPiecePlacementMove.new(_first_corner_clicked,-1)
		move_taken.emit(move)
		can_move = false
		return
	
	_paint_placeable_corners(second_placeables)
	_first_clicked_corner.set_color(game_board.placeable_corner_color.inverted())

func _click_on_tile(tile : Tile):
	if is_my_turn() == false or tile == selected_tile or game_board.cells.has(tile) == false or can_move == false:
		return
	
	var clicked_index = game_board.get_tile_cell(tile)
	
	if selected_tile != tile and game_state.is_cell_occupied(clicked_index) == true:
		if game_state.game_state == GameState.STATE.COIN_TOOK_PIECE:
			return
		_clear_coin_grid_selections()
		_select_tile(tile)
	else:
		
		var selected_index = game_board.get_tile_cell(selected_tile)
		
		if selected_index == -1 or game_state.get_moveable_cells(selected_index).has(clicked_index) == false:
			return
		
		selected_tile = null
		var move = COINCheckerMovementMove.new(selected_index,clicked_index)
		move_taken.emit(move)
		can_move = false
