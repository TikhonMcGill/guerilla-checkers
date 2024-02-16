extends Resource

class_name MinimaxProfile

##Resource for holding configurations of Minimax Players
##
##Note - the Utility values are looked at from the perspective of a Guerilla Player.
##Guerilla Checkers is a zero-sum game, meaning that the advantage of the Guerilla is exactly
##the disadvantage of the COIN, therefore, for the COIN, we can just take the negative of the
##evaluation function.

enum MOVE_SORT{
	NONE, ##Do not sort possible moves
	END_TAKE_OTHER, ##Place moves ending the game at the beginning, then moves that capture pieces, and all others at the end
	BY_UTILITY, ##Order pieces in descending order of their utility
	RANDOM_SHUFFLE ##Randomly shuffle the moves
} ##Move sorting algorithm to use

#Base Values
@export var profile_name : String = "" ##Name of the Minimax Profile
@export var cutoff_depth : int = 0 ##How deep the search tree is cutoff (cutoff of 0 = look no moves ahead, i.e. take the best move in the present)
@export var move_sorting : MOVE_SORT = MOVE_SORT.NONE ##The Type of Move Sorting Algorithm to use (how moves are ordered before being analyzed by Minimax)
@export var timeout : float = 0 ##The Timeout in milliseconds - after timeout is over, even if Minimax has not finished, the current best move will be selected

#Evaluation Function Values
@export var victory_utility : float = 1.0 ##How much utility will be added to a Game State if, from the perspective of the Guerilla, they win (i.e. no more COIN Pieces remain)
@export var defeat_utility : float = -1.0 ##How much utility will be added to a Game State if, from the perspective of the Guerilla, they lose (no more pieces on the board or no more pieces left to place)
@export var draw_utility : float = 0.0 ##How much utility will be added to a Game State it, from the perspective of the Guerilla, the game is a draw (i.e. they place their first piece in a corner with no available adjacent corners)

@export var pieces_left_utility : float = 1.0 ##Multiply the number of pieces the Guerilla has left to place by this value, and add it to the Utility
@export var pieces_on_board_utility : float = 1.0 ##Multiply the number of Guerilla pieces present on the board by this value, and add to total Utility
@export var checkers_utility : float = -1.0 ##Multiply the number of COIN Checkers present on the board by this amount, and add it to Utility
@export var guerilla_threatened_checkers_utility : float = 1.0 ##Multiply the number of COIN Checkers threatened by Guerilla Pieces by this amount, and add to total Utility
@export var edge_threatened_checkers_utility : float = 1.0 ##Multiply the number of COIN Checkers present on Edge (and Corner) Cells by this amount, add to total Utility
@export var threatened_guerilla_pieces_utility : float = -1.0 ##Multiply the number of Guerilla Pieces threatened by COIN Checkers by this amount, add to total Utility
