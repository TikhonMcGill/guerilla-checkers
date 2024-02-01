extends Player

class_name RandomPlayer

@onready var wait_timer = $WaitTimer

func do_move():
	if game_state.get_current_player() != my_type:
		return
	
	wait_timer.start()
	
	await wait_timer.timeout
	
	var possible_moves = game_state.get_possible_moves()
	
	if len(possible_moves) == 0:
		return
	
	var move = possible_moves.pick_random()
	
	move_taken.emit(move)
