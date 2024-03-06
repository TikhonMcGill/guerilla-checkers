extends Player

class_name MinimaxPlayer

##A Minimax Guerilla Checkers player
##
##Minimax is an algorithm that looks several moves ahead, Maximizing the utility from its own moves,
##and minimizing the utility of the Opponent's possible moves.
##There is too much states to exhaustively search until a victory condition in Guerilla Checkers, so we
##use an evaluation function. Since Guerilla Checkers is a Zero-Sum game, the advantage of the Guerilla
##is exactly the disadvantage of the Counterinsurgent. Therefore, we have the evaluation function be 
##from the perspective of the Guerilla, and it is negated if the Minimax player is a COIN.

var profile : MinimaxProfile = preload("res://assets/resources/placeholder_minimax_profile.tres")

var analyzer : GameStateAnalyzer = GameStateAnalyzer.new()

@onready var move_timer: Timer = $MoveTimer

class MinimaxOutput:
	var evaluation : float
	var move : Move
	
	func _init(_evaluation:float,_move:Move) -> void:
		evaluation = _evaluation
		move = _move

##Pick the best move for Minimax
func do_move() -> void:
	move_timer.start()
	
	var output := _minimax(profile.cutoff_depth,true,game_state,-INF,INF,profile.timeout)
	
	#await move_timer.timeout
	
	move_taken.emit(output.move)

##A Method to get the Actions in a State, with sorting of moves
func _get_actions(state : GameState) -> Array[Move]:
	var actions := state.get_possible_moves()
	
	#If no sorting function, just return the possible actions
	if profile.move_sorting == MinimaxProfile.MOVE_SORT.NONE:
		return actions
	
	#If random sorting, shuffle the moves
	if profile.move_sorting == MinimaxProfile.MOVE_SORT.RANDOM_SHUFFLE:
		actions.shuffle()
		return actions
	
	#If End-Take-Other, have three arrays - one for moves that lead to game-ending states, 
	#one for moves that lead to states with less Coin Checkers/Guerilla Pieces, 
	#and one for everything else
	if profile.move_sorting == MinimaxProfile.MOVE_SORT.END_TAKE_OTHER:
		var end_moves : Array[Move] = []
		var take_moves : Array[Move] = []
		var other_moves : Array[Move] = []
		
		var current_guerilla_pieces := analyzer.count_guerilla_pieces_on_board(state)
		var current_coin_checkers := analyzer.count_coin_checkers_on_board(state)
		
		for a in actions:
			var result := _get_result(state,a)
			if analyzer.is_guerilla_victorious(result) == true or analyzer.is_coin_victorious(result) == true or analyzer.is_draw(result) == true:
				end_moves.append(a)
			elif analyzer.count_guerilla_pieces_on_board(result) < current_guerilla_pieces or analyzer.count_coin_checkers_on_board(result) < current_coin_checkers:
				take_moves.append(a)
			else:
				other_moves.append(a)
		
		var moves = end_moves + take_moves + other_moves
		assert(len(moves) == len(actions))
	
	#If sorting by utility, sort moves by their utilities
	if profile.move_sorting == MinimaxProfile.MOVE_SORT.BY_UTILITY:
		#Construct Dictionary of Actions based on Utilities
		var utilities_to_actions : Dictionary = {}
		
		for a in actions:
			var result := _get_result(state,a)
			var utility := _get_state_utility(result)
			
			#If there is an action with equal utility already, append it to that utility's array
			if utilities_to_actions.has(utility) == true:
				utilities_to_actions[utility].append(a)
			#Otherwise, initialize a size-1 array
			else:
				var new_move_array : Array[Move] = []
				new_move_array.append(a)
				utilities_to_actions[utility] = new_move_array
		
		var ordered_utilities := utilities_to_actions.keys()
		ordered_utilities.sort()
		
		var moves := []
		
		for o in ordered_utilities:
			moves += utilities_to_actions[o]
		
		assert(len(moves) == len(actions))
	
	return actions

##A Method to get the result of taking an Action in a state (same reason as above)
func _get_result(state : GameState,action : Move) -> GameState:
	return analyzer.simulate_move(state,action)

##Terminal test - if there are no possible moves, the game is over, so it's a terminal state
func _is_terminal_state(state : GameState) -> bool:
	return len(_get_actions(state)) == 0

##A Method to get the Utility of a State
func _get_state_utility(state : GameState) -> float:
	var utility := 0.0
	
	if is_equal_approx(profile.victory_utility,0) == false and analyzer.is_guerilla_victorious(state) == true:
		utility += profile.victory_utility
	
	if is_equal_approx(profile.defeat_utility,0) == false and analyzer.is_coin_victorious(state) == true:
		utility += profile.defeat_utility
	
	if is_equal_approx(profile.draw_utility,0) == false and analyzer.is_draw(state) == true:
		utility += profile.draw_utility
	
	if is_equal_approx(profile.pieces_left_utility,0) == false:
		utility += (state.guerilla_pieces_left * profile.pieces_left_utility)
	
	if is_equal_approx(profile.pieces_on_board_utility,0) == false:
		utility += (analyzer.count_guerilla_pieces_on_board(state) * profile.pieces_on_board_utility)
	
	if is_equal_approx(profile.checkers_utility,0) == false:
		utility += (analyzer.count_coin_checkers_on_board(state) * profile.checkers_utility)
	
	if is_equal_approx(profile.guerilla_threatened_checkers_utility,0) == false:
		utility += (analyzer.count_guerilla_threatened_coin_checkers(state) * profile.guerilla_threatened_checkers_utility)
	
	if is_equal_approx(profile.edge_threatened_checkers_utility,0) == false:
		utility += (analyzer.count_edge_threatened_coin_checkers(state) * profile.edge_threatened_checkers_utility)
	
	if is_equal_approx(profile.threatened_guerilla_pieces_utility,0) == false:
		utility += (analyzer.count_threatened_guerilla_pieces(state) * profile.threatened_guerilla_pieces_utility)
	
	#Since the Utility is from the perspective of the Guerilla, if the Player is a Counterinsurgent,
	#we negate the utility (the advantage of the guerilla is the disadvantage of the COIN, and vice versa)
	
	if is_coin() == true:
		utility = -utility
	
	return utility

##A Method to check if it's this player's turn in a State
func _is_my_turn_in_state(state : GameState) -> bool:
	return state.get_current_player() == my_type

##A Method to get the cutoff (either 0 or 1) based on if the Minimax Player is using Turn-based Lookahead or not
func _get_cutoff(state : GameState) -> int:
	#If not looking ahead by turns, cut off 1 with each move by default
	if profile.turn_lookahed == false:
		return 1
	
	#If it's still my turn, return 0 - we don't cut off
	if _is_my_turn_in_state(state) == true:
		return 0
	
	#Otherwise, cut off by 1 - no longer Minimax's turn
	return 1

##A Function running the Minimax algorithm, with cutoff - getting the Utility of a state and the best move
func _minimax(depth:int,maximizing:bool,start_state : GameState,alpha:float,beta:float,time_left:int) -> MinimaxOutput:
	if _is_terminal_state(start_state) == true or depth == 0:
		return MinimaxOutput.new(_get_state_utility(start_state),null)
	
	var start_time := Time.get_ticks_msec()
	
	var best_moves : Array[Move] = []
	
	if maximizing == true:
		var best_evaluation : float = -INF
		
		var actions := _get_actions(start_state)
		
		if len(actions) == 1:
			var new_state := _get_result(start_state, actions[0])
			var result := _get_state_utility(new_state)
			return MinimaxOutput.new(result,actions[0])
		
		for a in _get_actions(start_state):
			var end_time := Time.get_ticks_msec()
			
			var time_taken := end_time - start_time
			time_left -= time_taken
			
			var result := _get_result(start_state,a)
			var cutoff := _get_cutoff(result)
			
			var evaluation : float = _minimax(depth-cutoff,_is_my_turn_in_state(result),result,alpha,beta,time_left).evaluation
			
			if evaluation > best_evaluation:
				best_evaluation = evaluation
				best_moves = [a]
			elif is_equal_approx(evaluation,best_evaluation) == true:
				best_moves.append(a)
			
			alpha = max(alpha,evaluation)
			
			if beta <= alpha or time_left <= 0:
				return MinimaxOutput.new(evaluation,best_moves.pick_random())
		
		return MinimaxOutput.new(best_evaluation,best_moves.pick_random())
	else:
		var worst_evaluation : float = INF
		
		var actions := _get_actions(start_state)
		
		if len(actions) == 1:
			var new_state := _get_result(start_state, actions[0])
			var result := _get_state_utility(new_state)
			return MinimaxOutput.new(result,actions[0])
		
		for a in _get_actions(start_state):
			var end_time := Time.get_ticks_msec()
			
			var time_taken := end_time - start_time
			time_left -= time_taken
			
			var result := _get_result(start_state,a)
			var cutoff := _get_cutoff(result)
			
			var evaluation : int = _minimax(depth-cutoff,_is_my_turn_in_state(result),result,alpha,beta,time_left).evaluation
			
			if evaluation < worst_evaluation:
				worst_evaluation = evaluation
				best_moves = [a]
			elif is_equal_approx(evaluation,worst_evaluation) == true:
				best_moves.append(a)
			
			beta = min(beta,evaluation)
			
			if beta <= alpha or time_left <= 0:
				return MinimaxOutput.new(evaluation,best_moves.pick_random())
		
		return MinimaxOutput.new(worst_evaluation,best_moves.pick_random())
