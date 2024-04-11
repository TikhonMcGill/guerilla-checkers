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
		if _is_cell_threatening(game_state,checker) == true:
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

##Method to count the number of Guerilla Pieces in Corners between COIN Checkers
func count_guerilla_pieces_between_coin_checkers(game_state : GameState) -> int:
	var count := 0
	
	var existing_pairs := []
	
	for checker in game_state.coin_checker_positions:
		for neighbor in game_state.get_adjacent_cells(checker):
			if game_state.is_cell_occupied(neighbor) == true:
				var possible_guerilla_corner = game_state.get_corner_between_cells(checker,neighbor)
				if game_state.is_corner_occupied(possible_guerilla_corner) == true and existing_pairs.has([checker,neighbor]) == false:
					count += 1
					
					#Append both combinations to existing pairs to prevent recounting
					existing_pairs.append([checker,neighbor])
					existing_pairs.append([neighbor,checker])
	
	return count

##Method to count the number of "Blocked" COIN Checker Movements
##A COIN Checker movement is considered "Blocked" if:
##1. The COIN Checker is on the edge of the board (+2 blocks - can only move in 2 directions)
##2. The COIN Checker is in the corner of the board (+3 blocks - can only move in 1 direction)
##3. The COIN Checker is diagonally-adjacent to another COIN Checker (+1 for each COIN Checker - cannot move into another one)
##4. The COIN Checker would move into a tile which has 2/3 ADJACENT guerilla pieces, which would mean the Checker would be taken next turn
func count_blocked_coin_checker_movements(game_state : GameState) -> int:
	var count := 0
	
	for checker in game_state.coin_checker_positions:
		if checker in game_state.CORNER_CELLS:
			count += 3
		elif checker in game_state.EDGE_CELLS:
			count += 2
		else:
			for adjacent_cell in game_state.get_adjacent_cells(checker):
				if game_state.is_cell_occupied(adjacent_cell) == true:
					count += 1
				elif _is_cell_threatening(game_state,adjacent_cell) == true:
					count += 1
	
	return count

##Method to check if the Guerilla Pieces present in a cell are threatening to a COIN Piece
##For them to be threatening, there must be either 3 or 2 Guerilla Pieces, and if there are 2 they
##must be next to each other (so that, in the next move, the Guerilla can place 2 more pieces and capture
##the COIN checker)
func _is_cell_threatening(game_state : GameState,cell : int) -> bool:
	var corners = game_state.get_cell_corners(cell)
	var occupied_corners : Array[int] = []
	for c in corners:
		if game_state.is_corner_occupied(c) == true:
			occupied_corners.append(c)
	#If there are 3 out of 4 corners occupied, then 2 of them are DEFINITELY
	#orthogonally-adjacent, meaning the COIN Checker is threatened, so +1
	if len(occupied_corners) == 3:
		return true
	elif len(occupied_corners) == 2:
		#If the two Corners are orthogonally-adjacent, then they threaten the
		#COIN Checker (because in their next turn the Guerilla can place two pieces
		#in the other two corners and capture the Checker)
		var piece1 = occupied_corners[0]
		var piece2 = occupied_corners[1]
		
		if game_state.are_corners_adjacent(piece1,piece2) == true:
			return true
	elif len(occupied_corners) == 1 and cell in GameState.EDGE_CELLS:
		#If the COIN Checker is on a cell at the edge (corners don't count here because it would
		#already be captured), then all it takes is one Guerilla Piece to capture it, and since
		#1 is already placed, the Checker is threatened, hence +1 to count
		return true
	
	return false

##Method to count the number of COIN Checkers taken
func count_coin_checkers_taken(game_state : GameState) -> int:
	return 6 - len(game_state.coin_checker_positions)

##Method to simulate a move in the current game state, returning a game state AFTER the move has been
##taken
func simulate_move(game_state : GameState,move : Move) -> GameState:
	var new_state : GameState = game_state.duplicate()
	
	new_state.take_move(move)
	
	return new_state
