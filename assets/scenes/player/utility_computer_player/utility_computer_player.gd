extends Player

class_name UtilityComputerPlayer

#Utility Computer Player:
#1. For the Guerilla, +10 if the State after the move has less COIN Checker (i.e. one was taken)
#2. For the Guerilla, -1 for every Guerilla Piece threatened (which means +1 if it’s placed in a diagonal between 2 COIN Checkers, and a -1 if it’s threatened, obviously)
#3. For the Guerilla, +100 if they are Victorious (meaning taking the last Checker gives +100 Utility)
#4. For the Guerilla, +5 for every threatened COIN Checker (by Edge OR Guerilla piece)
#5. For the Counterinsurgent, -1 for every Guerilla Piece present on the board (so that taking it, and it implies that taking it at once is also +1 for each, gives +1 point) 
#6. For the Counterinsurgent, +100 for Victory (which means taking the last piece gives +100 Utility, just as the Guerilla running out of pieces will give +100 points as well, but the COIN player can’t look ahead that far)
#7. For the Counterinsurgent, -5 for every edge-threatened Checker
#8. For the Counterinsurgent, -5 for every Guerilla-threatened Checker
#9. For the Counterinsurgent, -5 for every Checker in a corner
#10. For every possible move, simulate it using GameStateAnalyzer's "simulate_move" method, and assign a utility to it, the sum of the above
#situations
#11. Pick the Move with the highest utility, OR randomly-choose top moves if utilities are tied
#12. The UCP doesn't have a utility for the opposing player winning, because they cannot look into the future

var analyzer : GameStateAnalyzer = GameStateAnalyzer.new()

@onready var timer: Timer = $Timer

func do_move():
	timer.start()
	
	var best_move = choose_best_move()
	
	await timer.timeout
	
	move_taken.emit(choose_best_move())

func choose_best_move() -> Move:
	var best_moves : Array[Move] = []
	var best_move_utility : int = -INF
	
	var possible_moves := game_state.get_possible_moves()
	
	for move : Move in possible_moves:
		var simulated_state := analyzer.simulate_move(game_state,move)
		
		var utility : int
		
		if is_guerilla() == true:
			utility = evaluate_guerilla_utility(simulated_state)
		elif is_coin() == true:
			utility = evaluate_coin_utility(simulated_state)
		
		#If the Utility is greater than the best, discard all previous best moves
		if utility > best_move_utility:
			best_move_utility = utility
			best_moves = [move]
		#If the utility is equal to the Best utility, add it to the best moves
		elif utility == best_move_utility:
			best_moves.append(move)
	
	return best_moves.pick_random()

func evaluate_guerilla_utility(state : GameState) -> int:
	var utility := 0
	
	if analyzer.count_coin_checkers_on_board(state) < analyzer.count_coin_checkers_on_board(game_state):
		utility += 10
	
	utility -= analyzer.count_threatened_guerilla_pieces(state)
	
	if analyzer.is_guerilla_victorious(state) == true:
		utility += 100
	
	utility += (5 * analyzer.count_guerilla_threatened_coin_checkers(state))
	utility += (5 * analyzer.count_edge_threatened_coin_checkers(state))
	
	if analyzer.is_draw(state) == true:
		utility -= 50
	
	return utility

func evaluate_coin_utility(state : GameState) -> int:
	var utility := 0
	
	utility -= analyzer.count_guerilla_pieces_on_board(state)
	
	if analyzer.is_coin_victorious(state) == true:
		utility += 100
	
	utility -= (5 * analyzer.count_edge_threatened_coin_checkers(state))
	utility -= (5 * analyzer.count_guerilla_threatened_coin_checkers(state))
	
	return utility
