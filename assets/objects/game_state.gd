extends Object

class_name GameState

##Class representing the Game State of Guerilla Checkers
##
##This Class provides helper functions to get possible moves, and to take moves

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

##The State of the Game - used for determining possible moves in [code]get_possible_moves()[/code]
enum STATE{
	FIRST_TURN, ##It is the first Turn, and the Guerilla can place their first piece in ANY corner
	FIRST_GUERILLA_PIECE, ##The Guerilla places their first piece - it has to be in a corner adjacent to one where a Guerilla Piece was already placed
	SECOND_GUERILLA_PIECE, ##The Guerilla places their second piece - it has to be in a corner adjacent to the first piece placed
	COIN_TURN, ##It is the COIN Player's turn (entered after SECOND_GUERILLA_PIECE)
	COIN_TOOK_PIECE, ##This State is entered when the COIN Player takes a Guerilla's Piece, and is only left when there are no more Pieces to Place
	GUERILLA_VICTORY, ##The Guerilla is victorious - no more COIN Checkers remain
	COIN_VICTORY ##The Counterinsurgent is victorious - either the Guerilla ran out of Pieces to place, or the COIN player took all Guerilla Pieces on the board
} 

##Enum representing types of players, used in the [code]get_current_player()[/code] method
enum PLAYER{
	GUERILLA, ##The Guerilla
	COIN, ##The Counterinsurgent (COIN)
	GAME_OVER ##The Game is over
} 

#region Constants
##All of the Cells on the board into which COIN Checkers may be moved
const CELLS : Array[int] = [
	0,1,2,3,4,5,6,7,8,9,10,11,12,
	13,14,15,16,17,18,19,20,21,22,
	23,24,25,26,27,28,29,30,31
]

##All Corners in which Guerilla Pieces may be placed
const CORNERS : Array[int] = [
	0,1,2,3,4,5,6,7,8,9,10,11,12,
	13,14,15,16,17,18,19,20,21,22,
	23,24,25,26,27,28,29,30,31,32,
	33,34,35,36,37,38,39,40,41,42,
	43,44,45,46,47,48
]

##The corners of every cell
const CELL_CORNERS : Array[Array] = [
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
const CELL_ADJACENCIES : Array[Array] = [
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
const CORNER_ADJACENCIES : Array[Array] = [
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
const EDGE_CELLS : Array[int] = []

##Corner cells of the board (the Guerilla need place only 1 piece to capture a COIN Checker in those cells)
const CORNER_CELLS : Array[int] = []

#endregion

##The current game state - initially, the First Turn
var game_state : STATE = STATE.FIRST_TURN

##The number of pieces the Guerilla has left to place - initially, 66
var guerilla_pieces_left : int = 66

##The corner into which the Guerilla has placed their first piece - saved so that the Game State knows next to which corner next piece must be placed
var first_placed_piece_corner : int = -1

##The cell in which the COIN Checker which has taken a Guerilla Piece is present - saved so that the Game State knows, per the rules of Guerilla Checkers, which Checker will have to take all pieces it can
var attacking_checker_cell : int = -1

##The positions of the COIN Checkers - initially they are in positions corresponding to the diagram on https://www.di.fc.ul.pt/~jpn/gv/guerrilla.htm
var coin_checker_positions : Array[int] = [9, 13, 14, 17, 18, 22]

##The corners in which the Guerilla Pieces are present - initially, none are on the board
var guerilla_piece_positions : Array[int] = []

##Get the diagonally-adjacent Cells to this cell
func get_adjacent_cells(cell : int) -> Array[int]:
	assert(cell >= 0 and cell <= 31,"Cell must be between 0 and 31")
	return CELL_ADJACENCIES[cell]

##Get the Orthogonally-adjacent Corners to this corner
func get_adjacent_corners(corner : int) -> Array[int]:
	assert(corner >= 0 and corner <= 48,"The Corner must be between 0 and 48")
	return CORNER_ADJACENCIES[corner]

##Get the Corners in this Cell
func get_cell_corners(cell : int) -> Array[int]:
	assert(cell >= 0 and cell <= 31,"Cell must be between 0 and 31")
	return CELL_CORNERS[cell]
