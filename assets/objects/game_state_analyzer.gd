extends Resource

class_name GameStateAnalyzer

##A Class which tracks situations on the board
##
##This is used for the Utility Computer Player and Minimax Player

##Return whether the Guerilla is victorious in this Game State
func is_guerilla_victorious(game_state : GameState) -> bool:
	return game_state.game_state == GameState.STATE.GUERILLA_VICTORY

##Return whether the COIN is victorious in this Game State
func is_coin_victorious(game_state : GameState) -> bool:
	return game_state.game_state == GameState.STATE.COIN_VICTORY

##Get the number of Guerilla Pieces left to place in this Game State
func get_guerilla_pieces_left(game_state : GameState) -> int:
	return game_state.guerilla_pieces_left

##Count the number of Guerilla Pieces on the board in this Game State
func count_guerilla_pieces_on_board(game_state : GameState) -> int:
	return len(game_state.guerilla_piece_positions)

##Count the number of COIN Checkers on the board in this Game State
func count_coin_checkers_on_board(game_state : GameState) -> int:
	return len(game_state.coin_checker_positions)

##Method to return if the game is a draw
func is_draw(game_state : GameState) -> bool:
	return game_state.game_state == GameState.STATE.DRAW

##Count the number of COIN Checkers threatened by Guerilla pieces (2 Corners in a COIN
##Checker's cell, orthogonally adjacent to each other, threaten it) 
func count_guerilla_threatened_coin_checkers(game_state : GameState) -> int:
	var count := 0
	
	for checker in game_state.coin_checker_positions:
		var corners = game_state.get_cell_corners(checker)
		var occupied_corners : Array[int] = []
		for c in corners:
			if game_state.is_corner_occupied(c) == true:
				occupied_corners.append(c)
		#If there are 3 out of 4 corners occupied, then 2 of them are DEFINITELY
		#orthogonally-adjacent, meaning the COIN Checker is threatened, so +1
		if len(occupied_corners) == 3:
			count += 1
		elif len(occupied_corners) == 2:
			#If the two Corners are orthogonally-adjacent, then they threaten the
			#COIN Checker (because in their next turn the Guerilla can place two pieces
			#in the other two corners and capture the Checker)
			var piece1 = occupied_corners[0]
			var piece2 = occupied_corners[1]
			
			if game_state.are_corners_adjacent(piece1,piece2) == true:
				count += 1
		elif len(occupied_corners) == 1 and checker in GameState.EDGE_CELLS:
			#If the COIN Checker is on a cell at the edge (corners don't count here because it would
			#already be captured), then all it takes is one Guerilla Piece to capture it, and since
			#1 is already placed, the Checker is threatened, hence +1 to count
			count += 1
	
	return count

##Count the number of COIN Checkers threatened by Edges of the board
##(+1 if they are also in a Corner)
func count_edge_threatened_coin_checkers(game_state : GameState) -> int:
	var count := 0
	
	for checker in game_state.coin_checker_positions:
		if checker in GameState.EDGE_CELLS:
			count += 1
		if checker in GameState.CORNER_CELLS:
			count += 1
	
	return count

##Count the number of Guerilla Pieces threatened by COIN Checkers - i.e. the number of 
##Guerilla pieces that can be jumped over by a COIN Checker
func count_threatened_guerilla_pieces(game_state : GameState) -> int:
	var count := 0
	
	for checker in game_state.coin_checker_positions:
		var adjacent_cells = game_state.get_adjacent_cells(checker)
		#Go through all adjacent cells, i.e. cells into which a COIN Checker could go after
		#jumping over and capturing the Guerilla Piece
		for cell in adjacent_cells:
			#If the adjacent cell is unoccupied, that means the COIN Checker would be able to jump
			#over a piece in that corner
			if game_state.is_cell_occupied(cell) == false:
				#Thus, if the corner between the Checker and an empty cell is occupied, i.e. a Guerilla
				#piece is present there, then it can be captured, meaning it's threatened, so +1 to the
				#count
				var shared_corner = game_state.get_corner_between_cells(checker,cell)
				if game_state.is_corner_occupied(shared_corner) == true:
					count += 1
	
	return count

##Method to simulate a move in the current game state, returning a game state AFTER the move has been
##taken
func simulate_move(game_state : GameState,move : Move) -> GameState:
	var new_state : GameState = game_state.duplicate()
	
	new_state.take_move(move)
	
	return new_state
