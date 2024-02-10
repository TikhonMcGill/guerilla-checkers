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

##Pick the best move for Minmax
func do_move() -> void:
	timer.start()
	
	var move := _get_minmax_move(game_state,4,true)
	
	await timer.timeout
	
	move_taken.emit(move)

##A Method to get the best move using MinMax
func _get_minmax_move(state:GameState,depth : int,maximizing : bool) -> Move:
	if depth == 0 or len(state.get_possible_moves()) == 0:
		if maximizing == true:
			return _get_best_move(state)
		else:
			return _get_worst_move(state)
	
	if maximizing == true:
		var best_utility := -INF
		var best_moves = []
		
		var moves = state.get_possible_moves()
		
		for m : Move in moves:
			var child_state = analyzer.simulate_move(state,m)
			var child_utility = _get_minmax_utility(child_state,depth-1,_is_my_hypothetical_turn(child_state))
			
			if child_utility > best_utility:
				best_moves = [m]
				best_utility = child_utility
			elif child_utility == best_utility:
				best_moves.append(m)
		
		return best_moves.pick_random()
	else:
		var worst_utility := INF
		var worst_moves = []
		
		var moves = state.get_possible_moves()
		for m : Move in moves:
			var child_state = analyzer.simulate_move(state,m)
			var child_utility = _get_minmax_utility(child_state,depth-1,not _is_my_hypothetical_turn(child_state))
			
			if child_utility < worst_utility:
				worst_moves = [m]
				worst_utility = child_utility
			elif child_utility == worst_utility:
				worst_moves.append(m)
		
		return worst_moves.pick_random()

##A method to get the utility of a state, by constructing the tree
func _get_minmax_utility(state : GameState,depth : int,maximizing : bool) -> int:
	if depth == 0 or len(state.get_possible_moves()) == 0:
		return _evaluate_state(state)
	
	if maximizing == true:
		var best_utility := -INF
		
		var moves = state.get_possible_moves()
		for m : Move in moves:
			var child_state = analyzer.simulate_move(state,m)
			var child_utility = _get_minmax_utility(child_state,depth-1,_is_my_hypothetical_turn(child_state))
			best_utility = max(best_utility, child_utility)
		
		return best_utility
	else:
		var worst_utility := INF
		
		var moves = state.get_possible_moves()
		for m : Move in moves:
			var child_state = analyzer.simulate_move(state,m)
			var child_utility = _get_minmax_utility(child_state,depth-1,not _is_my_hypothetical_turn(child_state))
			worst_utility = min(worst_utility,child_utility)
		
		return worst_utility

##A method to check if the player in the game_state is different from this Player
func _is_different_player(state : GameState) -> bool:
	if is_coin() == true and state.get_current_player() == GameState.PLAYER.GUERILLA:
		return true
	if is_guerilla() == true and state.get_current_player() == GameState.PLAYER.COIN:
		return true
	
	return false

##Evaluate this state
func _evaluate_state(state : GameState) -> int:
	var guerilla_utility := analyzer.count_guerilla_pieces_on_board(state)
	var checkers_utility := analyzer.count_coin_checkers_on_board(state) * 11
	var utility = guerilla_utility - checkers_utility
	
	guerilla_utility += 100 * int(analyzer.is_guerilla_victorious(state))
	
	#If the player is the Counterinsurgent, the utility is the negation of the Guerilla's utility
	if is_coin() == true:
		utility = -utility
	
	return utility
	
##Evaluate this move by simulating it in the State
func _evaluate_move(move : Move,state : GameState) -> int:
	#Simulate the Move
	var next_game_state := state.duplicate()
	next_game_state.take_move(move)
	
	#Get the Utility of the Move
	var utility := _evaluate_state(next_game_state)
	
	return utility

##Get the Best Possible move for the Player - the one with the highest utility.
##If there are several best-utility moves, pick randomly among them
func _get_best_move(state : GameState) -> Move:
	var highest_utility : int = -INF
	var best_moves : Array[Move] = []
	
	for move : Move in state.get_possible_moves():
		var utility := _evaluate_move(move,state)
		if utility > highest_utility:
			highest_utility = utility
			best_moves = [move]
		elif utility == highest_utility:
			best_moves.append(move)
	
	if len(best_moves) == 0:
		pass
	
	return best_moves.pick_random()

##Get the Worst Possible move for the Player - the one with the highest utility for the Opponent.
##If there are several worst-utility moves, pick randomly among them
func _get_worst_move(state : GameState) -> Move:
	var lowest_utility : int = INF
	var worst_moves : Array[Move] = []
	
	for move : Move in state.get_possible_moves():
		var utility := _evaluate_move(move,state)
		if utility < lowest_utility:
			lowest_utility = utility
			worst_moves = [move]
		elif utility == lowest_utility:
			worst_moves.append(move)
	
	return worst_moves.pick_random()

##Check if it's the MinMax Player's turn in a HYPOTHETICAL Game State
func _is_my_hypothetical_turn(state : GameState) -> bool:
	return state.get_current_player() == my_type
