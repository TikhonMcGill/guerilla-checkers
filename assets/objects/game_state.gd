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
const CELL_CORNERS : Array[Array] = []

##The cells adjacent to every cell
const CELL_ADJACENCIES : Array[Array] = []

##The corners adjacent to every corner
const CORNER_ADJACENCIES : Array[Array] = []

##Cells that are on the edge of the board (the Guerilla need place only 2 pieces to capture COIN Checkers in those cells)
const EDGE_CELLS : Array[int] = []

##Corner cells of the board (the Guerilla need place only 1 piece to capture a COIN Checker in those cells)
const CORNER_CELLS : Array[int] = []

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
