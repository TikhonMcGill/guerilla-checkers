extends Object

class_name GameState

##Class representing the Game State of Guerilla Checkers
##
##This Class provides helper functions to get possible moves, and to take moves
##Note - the term "COIN" and "Counterinsurgent" is used interchangeably, and means the
##Player that is playing using Checkers.

##Emitted when the Guerilla Places a piece - used for animation
signal guerilla_piece_placed(corner : int)

##Emitted when the COIN Player moves a piece - used for animation
signal coin_checker_moved(cell_from : int,cell_to : int)

##Emitted when the COIN Player captures a Guerilla piece - used for animation
signal guerilla_piece_captured(corner : int)

##Emitted when the Guerilla Player captures a COIN piece - used for animation
signal coin_checker_captured(cell : int)

##Emitted when the Game State changes - used to determine whose turn it is in the Game Scene
signal game_state_changed

##Emitted when the Game is over (i.e. a Player wins)
signal game_over(winner : PLAYER)

##The State of the Game - used for determining possible moves in [code]get_possible_moves()[/code]
enum STATE{
	FIRST_TURN, ##It is the first Turn, and the Guerilla can place their first piece in ANY corner
	FIRST_GUERILLA_PIECE, ##The Guerilla places their first piece - it has to be in a corner adjacent to one where a Guerilla Piece was already placed
	SECOND_GUERILLA_PIECE, ##The Guerilla places their second piece - it has to be in a corner adjacent to the first piece placed
	COIN_TURN, ##It is the COIN Player's turn (entered after SECOND_GUERILLA_PIECE)
	COIN_TOOK_PIECE, ##This State is entered when the COIN Player takes a Guerilla's Piece, and is only left when there are no more Pieces to Place
	GUERILLA_VICTORY, ##The Guerilla is victorious - no more COIN Checkers remain
	COIN_VICTORY, ##The Counterinsurgent is victorious - either the Guerilla ran out of Pieces to place, or the COIN player took all Guerilla Pieces on the board
	DRAW ##Nobody won - this state is reached when the Guerilla Places their first piece in a corner whcih has no free corners adjacent to it, rendering them unable to place the second piece
} 

##Enum representing types of players, used in the [code]get_current_player()[/code] method, and emitted with the "game_over" signal
enum PLAYER{
	GUERILLA, ##The Guerilla
	COIN, ##The Counterinsurgent (COIN)
	NOBODY, ##Nobody - either the Game is Over, so it's nobody's turn, or it's a draw, and this is emitted when the game is over in a Draw
} 

#region Constants
##All of the Cells on the board into which COIN Checkers may be moved
const CELLS = [
	0,1,2,3,4,5,6,7,8,9,10,11,12,
	13,14,15,16,17,18,19,20,21,22,
	23,24,25,26,27,28,29,30,31
]

##All Corners in which Guerilla Pieces may be placed
const CORNERS = [
	0,1,2,3,4,5,6,7,8,9,10,11,12,
	13,14,15,16,17,18,19,20,21,22,
	23,24,25,26,27,28,29,30,31,32,
	33,34,35,36,37,38,39,40,41,42,
	43,44,45,46,47,48
]

##The corners of every cell
const CELL_CORNERS = [
	[0,1],
	[2,3],
	[4,5],
	[6],
	[0,7],
	[1,2,8,9],
	[3,4,10,11],
	[5,6,12,13],
	[7,8,14,15],
	[9,10,16,17],
	[11,12,18,19],
	[13,20],
	[14,21],
	[15,16,22,23],
	[17,18,24,25],
	[19,20,26,27],
	[21,22,28,29],
	[23,24,30,31],
	[25,26,32,33],
	[27,34],
	[28,35],
	[29,30,36,37],
	[31,32,38,39],
	[33,34,40,41],
	[35,36,42,43],
	[37,38,44,45],
	[39,40,46,47],
	[41,48],
	[42],
	[43,44],
	[45,46],
	[47,48],
]

##The cells adjacent to every cell
const CELL_ADJACENCIES = [
	[4,5],
	[5,6],
	[6,7],
	[7],
	[0,8],
	[0,1,8,9],
	[1,2,9,10],
	[2,3,10,11],
	[4,5,12,13],
	[5,6,13,14],
	[6,7,14,15],
	[7,15],
	[8,16],
	[8,9,16,17],
	[9,10,17,18],
	[10,11,18,19],
	[12,13,20,21],
	[13,14,21,22],
	[14,15,22,23],
	[15,23],
	[16,24],
	[16,17,24,25],
	[17,18,25,26],
	[18,19,26,27],
	[20,21,28,29],
	[21,22,29,30],
	[22,23,30,31],
	[23,31],
	[24],
	[24,25],
	[25,26],
	[26,27]
]

##The corners adjacent to every corner
const CORNER_ADJACENCIES = [
	[1,7],
	[0,2,8],
	[1,3,9],
	[2,4,10],
	[3,5,11],
	[4,6,12],
	[5,13],
	
	[0,8,14],
	[1,7,9,15],
	[2,8,10,16],
	[3,9,11,17],
	[4,10,12,18],
	[5,11,13,19],
	[6,12,20],
	
	[7,15,21],
	[8,14,16,22],
	[9,15,17,23],
	[10,16,18,24],
	[11,17,19,25],
	[12,18,20,26],
	[13,19,27],
	
	[14,22,28],
	[15,21,23,29],
	[16,22,24,30],
	[17,23,25,31],
	[18,24,26,32],
	[19,25,27,33],
	[20,26,34],
	
	[21,29,35],
	[22,28,30,36],
	[23,29,31,37],
	[24,30,32,38],
	[25,31,33,39],
	[26,32,34,40],
	[27,33,41],
	
	[28,36,42],
	[29,35,37,43],
	[30,36,38,44],
	[31,37,39,45],
	[32,38,40,46],
	[33,39,41,47],
	[34,40,48],
	
	[35,43],
	[36,42,44],
	[37,43,45],
	[38,44,46],
	[39,45,47],
	[40,46,48],
	[41,47],
]

##Cells that are on the edge of the board (the Guerilla need place only 2 pieces to capture COIN Checkers in those cells)
const EDGE_CELLS : Array[int] = [
	0,1,2,3,
	4,11,12,
	19,20,27,
	28,29,30,31
]

##Corner cells of the board (the Guerilla need place only 1 piece to capture a COIN Checker in those cells)
const CORNER_CELLS : Array[int] = [
	3,28
]

#endregion

##The current game state - initially, the First Turn
var game_state : STATE = STATE.FIRST_TURN : set = _set_state

##The number of pieces the Guerilla has left to place - initially, 66
var guerilla_pieces_left : int = 66

##The corner into which the Guerilla has placed their first piece - saved so that the Game State knows next to which corner next piece must be placed
var first_placed_piece_corner : int = -1

##The COIN Checker that took a Guerilla Piece - this one will have to take all other available pieces
var taking_coin_checker : int = -1

##The positions of the COIN Checkers - initially they are in positions corresponding to the diagram on https://www.di.fc.ul.pt/~jpn/gv/guerrilla.htm
var coin_checker_positions : Array[int] = [9, 13, 14, 17, 18, 22]

##The corners in which the Guerilla Pieces are present - initially, none are on the board
var guerilla_piece_positions : Array[int] = []

##Get the diagonally-adjacent Cells to this cell
func get_adjacent_cells(cell : int):
	assert(cell >= 0 and cell <= 31,"Cell to get adjacencies of must be between 0 and 31")
	return CELL_ADJACENCIES[cell]

##Get the Orthogonally-adjacent Corners to this corner
func get_adjacent_corners(corner : int):
	assert(corner >= 0 and corner <= 48,"Corner to get adjacencies of must be between 0 and 48")
	return CORNER_ADJACENCIES[corner]

##Get the Corners in this Cell
func get_cell_corners(cell : int):
	assert(cell >= 0 and cell <= 31,"Cell to get Corners of must be between 0 and 31")
	return CELL_CORNERS[cell]

##Check if the Cell is occupied (i.e. the Counterinsurgent has a Checker present there)
func is_cell_occupied(cell : int) -> bool:
	assert(cell >= 0 and cell <= 31,"Cell to check for Occupation must be between 0 and 31")
	return cell in coin_checker_positions

##Check if the Corner is occupied (i.e. the Guerilla has a Piece placed there)
func is_corner_occupied(corner : int) -> bool:
	assert(corner >= 0 and corner <= 48,"Corner to check for Occupation must be between 0 and 48")
	return corner in guerilla_piece_positions

##Get the corner between two Cells (useful for checking if a Guerilla piece is taken by a COIN Checker)
func get_corner_between_cells(cell1: int, cell2: int) -> int:
	assert(cell1 >= 0 and cell1 <= 31,"Cell1 to get Corner between it and Cell2 must be between 0 and 31")
	assert(cell2 >= 0 and cell2 <= 31,"Cell2 to get Corner between it and Cell1 must be between 0 and 31")
	var cell_1_corners = get_cell_corners(cell1)
	var cell_2_corners = get_cell_corners(cell2)
	
	for corner in cell_1_corners:
		if corner in cell_2_corners:
			#Since there's only one color of cell used, two cells can only share one corner,
			#meaning if the two cells share a common corner, that's the one between them
			return corner
	
	return -1

##Get the Possible Corners into which the Guerilla Player can place their pieces
func get_placeable_corners():
	#If it's the first turn, the Guerilla can place their piece anywhere, so return all corners
	if game_state == STATE.FIRST_TURN:
		return CORNERS
	#If it's not the Guerilla's First Turn, they can place their first piece in any corner orthogonally-adjacent to
	#an existing piece, so we must go through all pieces and get empty adjacent corners, ensuring no duplicates
	elif game_state == STATE.FIRST_GUERILLA_PIECE:
		var result : Array[int] = []
		for occupied_corner in guerilla_piece_positions:
			var occupied_corner_neighbors = get_adjacent_corners(occupied_corner)
			for neighbor in occupied_corner_neighbors:
				if is_corner_occupied(neighbor) == false and result.has(neighbor) == false:
					result.append(neighbor)
		
		return result
	#When the Guerilla places their second piece, it must be adjacent to the one initially-placed
	elif game_state == STATE.SECOND_GUERILLA_PIECE:
		var result : Array[int] = []
		var first_piece_neighbors = get_adjacent_corners(first_placed_piece_corner)
		for neighbor in first_piece_neighbors:
			if is_corner_occupied(neighbor) == false:
				result.append(neighbor)
		
		return result
	
	#In any other Game State, it's not the Guerilla's Turn (or they have won/lost), 
	#so they can't place any pieces, so return empty array
	return []

##Get the Possible Cells into which the COIN Player can move their Checker
func get_moveable_cells(from_cell : int):
	assert(from_cell >= 0 and from_cell <= 31,"Cell to get Moveable cells of must be between 0 and 31")
	
	#If the cell is not occupied, there's no checker to check movement of, so return empty
	if is_cell_occupied(from_cell) == false:
		print("From cell not occupied!")
		return []
	
	#If it's the COIN Player's turn and they haven't taken a piece, the Checker can move to any unoccupied
	#diagonally-adjacent Cell
	if game_state == STATE.COIN_TURN:
		var movement_options = get_adjacent_cells(from_cell)
		var result = []
		
		for m in movement_options:
			if is_cell_occupied(m) == false:
				result.append(m)
		
		return result
	#If the COIN Player took 1 or more pieces, then they can only move to an adjacent cell if it means taking another
	#Guerilla Piece (per the rules of Guerilla Checkers)
	elif game_state == STATE.COIN_TOOK_PIECE:
		var movement_options = get_adjacent_cells(taking_coin_checker)
		var result = []
		
		for m in movement_options:
			#Get the corner between the current Cell and the possible one to move to
			var shared_corner := get_corner_between_cells(taking_coin_checker,m)
			
			#Can only move there if the next Cell is not occupied already by a Checker, and
			#There exists a Guerilla piece in the corner between the 2 cells that can be taken
			#(i.e. it's occupied)
			if is_cell_occupied(m) == false and is_corner_occupied(shared_corner) == true:
				result.append(m)
		
		return result
	
	#In any other Game State, it's not the COIN's Turn (or they have won/lost), 
	#so they can't move any checkers, so return empty array
	print("Not Coin's turn!")
	return []

##Get the Current player (i.e. the one whose turn it is)
func get_current_player() -> PLAYER:
	if game_state == STATE.FIRST_TURN or game_state == STATE.FIRST_GUERILLA_PIECE or game_state == STATE.SECOND_GUERILLA_PIECE:
		return PLAYER.GUERILLA
	elif game_state == STATE.COIN_TURN or game_state == STATE.COIN_TOOK_PIECE:
		return PLAYER.COIN
	else:
		return PLAYER.NOBODY

##A Method to check how much corners of a Cell have been occupied by Checkers (used for captures by Guerilla)
func count_threatening_corners(cell : int) -> int:
	assert(cell >= 0 and cell <= 31,"Cell to count Threats of must be between 0 and 31")
	var threats = 0
	#If the cell is in the Corner of the board, it requires at most 2 Guerilla Pieces to take it,
	#So add 2 to the threats
	if cell in EDGE_CELLS:
		threats += 2
	#If the cell is also a Corner cell, add +1 Threat, since then it will only require 1 Guerilla Piece
	#to take it
	if cell in CORNER_CELLS:
		threats += 1
	
	#Count the Occupied Corners of the Cell, and add them to threats
	for corner in get_cell_corners(cell):
		if is_corner_occupied(corner) == true:
			threats += 1
	
	return threats

##A Method to check if any of the COIN Player's Checkers have been captured
func check_coin_checker_capture():
	var checkers_to_capture : Array[int] = []
	
	#Get the Checkers that will be captured - these must be surrounded on all 4 corners
	#by either Guerilla Pieces or empty space (when they're on edge/corner cells of the board)
	for checker in coin_checker_positions:
		if count_threatening_corners(checker) == 4:
			checkers_to_capture.append(checker)
	
	#Godot does not support erasing in an array while iterating, so iterate through the "checkers_to_capture"
	#Array and remove it from Coin Checker Positions, also emitting the corresponding signal
	for captive in checkers_to_capture:
		coin_checker_positions.erase(captive)
		coin_checker_captured.emit(captive)

##A Method to check if the Guerilla is victorious (no more COIN Checkers remain)
func is_guerilla_victorious() -> bool:
	return len(coin_checker_positions) == 0

##A Method to check if the COIN Player is victorious (Guerilla has no more pieces to place, 
##or no more pieces left on the board)
func is_coin_victorious() -> bool:
	return len(guerilla_piece_positions) == 0 or guerilla_pieces_left == 0

##A Method to place a Guerilla Piece, updating the Game State accordingly
func place_guerilla_piece(corner : int) -> void:
	var placeable_corners = get_placeable_corners()
	
	assert(corner >= 0 and corner <= 48,"Corner to place into must be between 0 and 48")
	assert(corner in placeable_corners,"Corner to place into must be valid")
	
	#Decrement number of pieces left by 1, since a Piece was placed
	guerilla_pieces_left -= 1
	
	#Place the Piece in the corner
	guerilla_piece_positions.append(corner)
	
	#Emit the signal that the piece was placed
	guerilla_piece_placed.emit(corner)
	
	#Check if any COIN Checkers were captured after the Guerilla Placed their piece
	check_coin_checker_capture()
	
	#Update the Game State based on the situation
	
	#If the Guerilla is victorious (i.e. no more COIN Pieces remain), switch to the Guerilla Victory Game State
	if is_guerilla_victorious() == true:
		game_state = STATE.GUERILLA_VICTORY
	#If the Guerilla has placed the first piece (be it in the first turn or otherwise), switch to the Second Piece State
	#Also, set the first piece placed variable, since we need to know to which first piece the second piece must be
	#adjacent
	elif game_state == STATE.FIRST_TURN or game_state == STATE.FIRST_GUERILLA_PIECE:
		game_state = STATE.SECOND_GUERILLA_PIECE
		first_placed_piece_corner = corner
	elif game_state == STATE.SECOND_GUERILLA_PIECE:
		#If the Guerilla still has more pieces to place, it is now the COIN's Turn
		if guerilla_pieces_left > 0:
			game_state = STATE.COIN_TURN
		#If the Guerilla has no more pieces to place, per the rules, the COIN is victorious
		else:
			game_state = STATE.COIN_VICTORY

##A Method to move a COIN Checker, updating the Game State accordingly
func move_coin_checker(from_cell : int,to_cell : int) -> void:
	assert(is_cell_occupied(from_cell),"Cell to move from must be occupied")
	assert(from_cell >= 0 and from_cell <= 31,"Cell to move from must be between 0 and 31")
	assert(to_cell >= 0 and to_cell <= 31,"Cell to move to must be between 0 and 31")
	assert(to_cell in get_adjacent_cells(from_cell),"Cell to move to must be adjacent to cell to move from")
	
	var moveable_cells = get_moveable_cells(from_cell)
	
	assert(to_cell in moveable_cells,"Cell to move to must be valid")
	
	#Update the Position of the Checker, and emit the corresponding signal
	coin_checker_positions.erase(from_cell)
	coin_checker_positions.append(to_cell)
	coin_checker_moved.emit(from_cell,to_cell)
	
	#Check if, by moving, the COIN Player jumped over and took a Guerilla Piece
	#If it did, we will need to update the Game State to "Coin Took Piece"
	var corner_between = get_corner_between_cells(from_cell,to_cell)
	if is_corner_occupied(corner_between) == true:
		guerilla_piece_positions.erase(corner_between)
		guerilla_piece_captured.emit(corner_between)
		game_state = STATE.COIN_TOOK_PIECE
		taking_coin_checker = to_cell
	
	#Update the Game State
	
	#If the COIN Player is victorious (no Guerilla Pieces left on the board in this case), update the Game State
	#to COIN Victory
	if is_coin_victorious() == true:
		game_state = STATE.COIN_VICTORY
	#If the COIN Player moved their Checker without taking anything, it becomes the Guerilla's Turn
	elif game_state == STATE.COIN_TURN:
		game_state = STATE.FIRST_GUERILLA_PIECE
	elif game_state == STATE.COIN_TOOK_PIECE:
		#Get the Possible Cells the COIN could move to after it moved to the position 
		#(since the State is "Coin Took Piece", these are the Cells which have a Guerilla Piece between them
		#and the Cell the COIN Player just moved to, meaning it can be taken)
		var movable_positions = get_moveable_cells(to_cell)
		
		#If there are no movable positions (i.e. the COIN Player can take no more Guerilla Pieces), it's now
		#the Guerilla's Turn
		if len(movable_positions) == 0:
			game_state = STATE.FIRST_GUERILLA_PIECE
		else:
			#If there ARE movable positions (i.e. the COIN Player can take more pieces), it's still the COIN Player's
			#turn, since, per the rules of Guerilla Checkers, while taking the first piece is optional, if the COIN
			#chose to do so, it will have to take all possible pieces
			game_state = STATE.COIN_TOOK_PIECE

##Method to get all possible moves, dependent on the Game, as an Array of special "Move" objects
func get_possible_moves() -> Array[Move]:
	var current_player = get_current_player()
	
	var moves : Array[Move] = []
	
	if current_player == PLAYER.GUERILLA:
		var placeable_corners = get_placeable_corners()
		for p in placeable_corners:
			moves.append(GuerillaPiecePlacementMove.new(p))
		
		#If it's the Second Piece of the Guerilla to place, and they have no pieces
		#to place in, then it's a draw
		if len(moves) == 0 and game_state == STATE.SECOND_GUERILLA_PIECE:
			game_state = STATE.DRAW
		
	elif current_player == PLAYER.COIN:
		if game_state == STATE.COIN_TURN:
			for checker in coin_checker_positions:
				var moveable_cells = get_moveable_cells(checker)
				for m in moveable_cells:
					moves.append(COINCheckerMovementMove.new(checker,m))
		elif game_state == STATE.COIN_TOOK_PIECE:
			var moveable_cells = get_moveable_cells(taking_coin_checker)
			for m in moveable_cells:
				moves.append(COINCheckerMovementMove.new(taking_coin_checker,m))
	
	return moves

##Method to take a specific move, given by the Move class
func take_move(move : Move) -> void:
	if move is GuerillaPiecePlacementMove:
		place_guerilla_piece(move.corner)
	elif move is COINCheckerMovementMove:
		move_coin_checker(move.cell_from,move.cell_to)

##Setter method for setting the State (namely to emit the "state_changed" signal and write less lines of code)
##This method also checks if the Game State is a victory and, if it is, emits the "game_over" signal
##with the winner's Player Type
func _set_state(state : STATE) -> void:
	game_state = state
	game_state_changed.emit()
	
	if game_state == STATE.GUERILLA_VICTORY:
		game_over.emit(PLAYER.GUERILLA)
	elif game_state == STATE.COIN_VICTORY:
		game_over.emit(PLAYER.COIN)
	elif game_state == STATE.DRAW:
		game_over.emit(PLAYER.NOBODY)

##Method to check if two corners are adjacent
func are_corners_adjacent(corner1: int, corner2: int) -> bool:
	return get_adjacent_corners(corner1).has(corner2)

##Method to duplicate the Game State
func duplicate() -> GameState:
	var new_state := GameState.new()
	
	new_state.coin_checker_positions = coin_checker_positions.duplicate()
	new_state.guerilla_piece_positions = guerilla_piece_positions.duplicate()
	new_state.guerilla_pieces_left = guerilla_pieces_left
	new_state.game_state = game_state
	
	new_state.first_placed_piece_corner = first_placed_piece_corner
	new_state.taking_coin_checker = taking_coin_checker
	
	return new_state
