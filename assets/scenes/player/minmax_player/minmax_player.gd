extends Player

class_name MinMaxPlayer

##A MinMax Guerilla Checkers player
##
##MinMax is an algorithm that looks several moves ahead, Maximizing the utility from its own moves,
##and minimizing the utility of the Opponent's possible moves.
##There is too much states to exhaustively search until a victory condition in Guerilla Checkers, so we
##use an evaluation function. Since Guerilla Checkers is a Zero-Sum game, the advantage of the Guerilla
##is exactly the disadvantage of the Counterinsurgent. Therefore, we have the evaluation function be 
##from the perspective of the Guerilla, and it is negated if the MinMax player is a COIN.

@onready var timer: Timer = $Timer

var profile : MinMaxProfile = null

var analyzer : GameStateAnalyzer = GameStateAnalyzer.new()

class MinMaxOutput:
	var evaluation : float
	var move : Move
	
	func _init(_evaluation:float,_move:Move) -> void:
		evaluation = _evaluation
		move = _move

##Pick the best move for Minmax
func do_move() -> void:
	timer.start()
	
	var start_time := Time.get_ticks_msec()
	
	var output := _minmax(5,true,game_state,-INF,INF)
	
	var end_time := Time.get_ticks_msec()
	
	await timer.timeout
	
	move_taken.emit(output.move)

##A Method to get the Actions in a State (just to have similar notation to Russell, Norvig pseudocode)
func _get_actions(state : GameState) -> Array[Move]:
	return state.get_possible_moves()

##A Method to get the result of taking an Action in a state (same reason as above)
func _get_result(state : GameState,action : Move) -> GameState:
	return analyzer.simulate_move(state,action)

##Terminal test - if there are no possible moves, the game is over, so it's a terminal state
func _is_terminal_state(state : GameState) -> bool:
	return len(_get_actions(state)) == 0

##A Method to get the Utility of a State
func _get_state_utility(state : GameState) -> float:
	var utility := 0.0
	
	var guerilla_piece_utility = analyzer.count_guerilla_pieces_on_board(state)
	var coin_checker_utility = analyzer.count_coin_checkers_on_board(state) * 11
	
	utility = guerilla_piece_utility - coin_checker_utility
	
	#Since the Utility is from the perspective of the Guerilla, if the Player is a Counterinsurgent,
	#we negate the utility (the advantage of the guerilla is the disadvantage of the COIN, and vice versa)
	if is_coin() == true:
		utility = -utility
	
	return utility

##A Method to check if it's this player's turn in a State
func _is_my_turn_in_state(state : GameState) -> bool:
	return state.get_current_player() == my_type

##A Function running the MinMax algorithm, with cutoff - getting the Utility of a state and the best move
func _minmax(depth:int,maximizing:bool,start_state : GameState,alpha:float,beta:float) -> MinMaxOutput:
	if _is_terminal_state(start_state) == true or depth == 0:
		return MinMaxOutput.new(_get_state_utility(start_state),null)
	
	var best_moves : Array[Move] = []
	
	if maximizing == true:
		var best_evaluation : float = -INF
		
		var actions := _get_actions(start_state)
		if len(actions) == 1:
			return MinMaxOutput.new(_get_state_utility(_get_result(start_state,actions[0])),actions[0])
		
		
		for a in _get_actions(start_state):
			var result := _get_result(start_state,a)
			var evaluation = _minmax(depth-1,_is_my_turn_in_state(result),result,alpha,beta).evaluation
			
			if evaluation > best_evaluation:
				best_evaluation = evaluation
				best_moves = [a]
			elif evaluation == best_evaluation:
				best_moves.append(a)
			
			if evaluation >= beta:
				return MinMaxOutput.new(evaluation,best_moves.pick_random())
			
			alpha = max(alpha,evaluation)
		
		return MinMaxOutput.new(best_evaluation,best_moves.pick_random())
	else:
		var worst_evaluation : float = INF
		
		var actions := _get_actions(start_state)
		if len(actions) == 1:
			return MinMaxOutput.new(_get_state_utility(_get_result(start_state,actions[0])),actions[0])
		
		for a in _get_actions(start_state):
			var result := _get_result(start_state,a)
			var evaluation = _minmax(depth-1,_is_my_turn_in_state(result),result,alpha,beta).evaluation
			
			if evaluation < worst_evaluation:
				worst_evaluation = evaluation
				best_moves = [a]
			elif evaluation == worst_evaluation:
				best_moves.append(a)
			
			if evaluation <= alpha:
				return MinMaxOutput.new(evaluation,best_moves.pick_random())
			
			beta = min(beta,evaluation)
		
		return MinMaxOutput.new(worst_evaluation,best_moves.pick_random())
