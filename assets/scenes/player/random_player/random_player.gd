extends Player

class_name RandomPlayer

func do_move():
	if game_state.get_current_player() != my_type:
		return
	
	var possible_moves = game_state.get_possible_moves()
	
	if len(possible_moves) == 0:
		return
	
	var move = possible_moves.pick_random()
	
	move_taken.emit(move)
