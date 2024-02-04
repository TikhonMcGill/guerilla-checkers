extends Player

class_name HumanPlayer

var game_board : GameBoard

var selected_corner : Corner = null

var selected_tile : Tile = null

func update_interface():
	prepare_graphics()
	if is_coin() == true:
		_clear_coin_grid_selections()

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
	var placeable_corners = game_state.get_placeable_corners()
	
	for g in range(len(game_board.corners.get_children())):
		var corner : Corner = game_board.corners.get_child(g)
		if g in placeable_corners:
			corner.set_color(game_board.placeable_corner_color)
		else:
			corner.set_color(game_board.corner_color)

func _select_tile(tile : Tile) -> void:
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
	if is_my_turn() == true and corner != null:
		var index = game_board.get_corner_index(corner)
		var move = GuerillaPiecePlacementMove.new(index)
		move_taken.emit(move)

func _click_on_tile(tile : Tile):
	if is_my_turn() == false:
		return
	
	var clicked_index = game_board.get_tile_cell(tile)
	
	if selected_tile != tile and game_state.is_cell_occupied(clicked_index) == true:
		_clear_coin_grid_selections()
		_select_tile(tile)
	else:
		var selected_index = game_board.get_tile_cell(selected_tile)
		
		if selected_index == -1:
			return
		
		var move = COINCheckerMovementMove.new(selected_index,clicked_index)
		move_taken.emit(move)
		selected_tile = null

func _select_corner(corner : Corner):
	if corner.color == game_board.placeable_corner_color:
		selected_corner = corner

func _deselect_corner():
	if selected_corner != null:
		selected_corner = null
