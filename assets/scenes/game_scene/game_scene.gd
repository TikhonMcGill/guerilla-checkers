extends Node

const MAIN_MENU_PATH := "res://assets/scenes/menus/main_menu/main_menu.tscn"

#Scenes for Different Player Types
const HUMAN_PLAYER_SCENE := preload("res://assets/scenes/player/human_player/human_player.tscn")
const RANDOM_PLAYER_SCENE := preload("res://assets/scenes/player/random_player/random_player.tscn")
const UTILITY_PLAYER_SCENE := preload("res://assets/scenes/player/utility_computer_player/utility_computer_player.tscn")
const MINIMAX_PLAYER_SCENE := preload("res://assets/scenes/player/minimax_player/minimax_player.tscn")

signal move_simulated

var game_state : GameState
var game_board : GameBoard

var guerilla_player : Player
var coin_player : Player

var current_game : int = 1

@onready var move_timer: Timer = $MoveTimer

@onready var quit_confirmation_dialog : ConfirmationDialog = $QuitConfirmationDialog

@onready var winner_discussion_label: Label = $GameOverWindow/GameOverContainer/MarginContainer/VBoxContainer/WinnerDiscussionLabel

@onready var end_game_container: HBoxContainer = $GameOverWindow/GameOverContainer/MarginContainer/VBoxContainer/EndGameContainer
@onready var tournament_game_container: HBoxContainer = $GameOverWindow/GameOverContainer/MarginContainer/VBoxContainer/TournamentGameContainer

@onready var current_game_label: Label = $GameBoard/CurrentGameLabel

@onready var game_over_window: Window = $GameOverWindow

@onready var rapid_game_panel: PanelContainer = $RapidGamePanel
@onready var current_rapid_game_label: Label = $RapidGamePanel/MarginContainer/VBoxContainer/CurrentRapidGameLabel
@onready var current_guerilla_wins_label: Label = $RapidGamePanel/MarginContainer/VBoxContainer/CurrentGuerillaWinsLabel
@onready var current_coin_wins_label: Label = $RapidGamePanel/MarginContainer/VBoxContainer/CurrentCOINWinsLabel
@onready var current_draws_label: Label = $RapidGamePanel/MarginContainer/VBoxContainer/CurrentDrawsLabel
@onready var rapid_play_back_to_menu_button: Button = $RapidGamePanel/MarginContainer/VBoxContainer/RapidPlayBackToMenuButton
@onready var rapid_game_time_taken_label: Label = $RapidGamePanel/MarginContainer/VBoxContainer/RapidGameTimeTakenLabel
@onready var rapid_game_turns_per_game_label: Label = $RapidGamePanel/MarginContainer/VBoxContainer/RapidGameTurnsPerGameLabel
@onready var save_rapid_play_results_button = $RapidGamePanel/MarginContainer/VBoxContainer/SaveRapidPlayResultsButton

var guerilla_victories : int = 0
var coin_victories : int = 0
var draws : int = 0

var coin_capture_victories : int = 0
var coin_runout_victories : int = 0

var rapid_tournament_start_time : int

var turns_in_game : float = 0
var total_turns : float = 0

var total_guerilla_win_turns : float = 0
var total_coin_win_turns : float = 0
var total_draw_turns : float = 0

var total_win_coin_checkers_left : float = 0
var total_draw_coin_checkers_left : float = 0

var total_possible_guerilla_moves : float = 0
var total_possible_coin_moves : float = 0

var total_guerilla_moves_taken : float = 0
var total_coin_moves_taken : float = 0

var current_player : GameState.PLAYER = GameState.PLAYER.GUERILLA

var rapid_time_taken : int = 0

func _update_rapid_game_labels() -> void:
	current_rapid_game_label.text = "Current Game: %d" % current_game
	current_guerilla_wins_label.text = "Victories by Guerilla (%s): %d" % [GameManager.guerilla_player_name,guerilla_victories]
	current_coin_wins_label.text = "Victories by The Counterinsurgent (%s): %d\n(%d by Taking all Guerilla Pieces, %d by Guerilla running out of Pieces)" % [GameManager.coin_player_name,coin_victories,coin_capture_victories,coin_runout_victories]
	current_draws_label.text = "Draws: %d" % draws
	
	if GameManager.tournament_games_left < 1:
		rapid_time_taken = Time.get_ticks_msec() - rapid_tournament_start_time
		rapid_game_time_taken_label.text = "The Rapid Tournament took %d Milliseconds" % rapid_time_taken
		rapid_game_time_taken_label.visible = true
		
		var turns_text := "Mean no. Turns per Game: %.2f" % get_average_turns()
		
		if guerilla_victories > 0:
			turns_text += "\nMean Turn of Guerilla Victory: %.2f" % get_average_guerilla_win_turns()
		if coin_victories > 0:
			turns_text += "\nMean Turn of COIN Victory: %.2f" % get_average_coin_win_turns()
			turns_text += "\nThere were %.2f COIN Checkers left in a COIN Victory on average" % get_win_average_coin_checkers()
		if draws > 0:
			turns_text += "\nMean Turn of Draw: %.2f" % get_average_draw_turns()
			turns_text += "\nThere were %.2f COIN Checkers left in a Draw on average" % get_draw_average_coin_checkers()
		
		rapid_game_turns_per_game_label.text = turns_text
		rapid_game_turns_per_game_label.visible = true
	
	rapid_play_back_to_menu_button.visible = GameManager.tournament_games_left < 1
	save_rapid_play_results_button.visible = GameManager.tournament_games_left < 1
	
func _ready():
	game_state = GameState.new()
	game_board = $GameBoard
	
	game_state.game_over.connect(_on_game_state_game_over)
	
	if GameManager.rapid_tournament == false:
		game_board.represent_game_state(game_state)
		var board_rect := game_board.get_board_rect()
		current_game_label.position = Vector2(board_rect.end.x,board_rect.position.y)
		game_state.guerilla_piece_placed.connect(game_board.animate_corner_placement)
		game_state.coin_checker_moved.connect(game_board._on_game_state_coin_checker_moved)
		game_state.guerilla_piece_captured.connect(game_board._on_game_state_guerilla_piece_captured)
		game_state.coin_checker_captured.connect(game_board._on_game_state_coin_checker_captured)
	else:
		rapid_tournament_start_time = Time.get_ticks_msec()
		rapid_game_panel.visible = true
		_update_rapid_game_labels()
		game_board.visible = false
	
	_create_players(GameManager.guerilla_player_type,GameManager.coin_player_type)
	
	current_game_label.visible = GameManager.is_tournament()
	
	await get_tree().process_frame
	
	total_possible_guerilla_moves += len(game_state.get_possible_moves())
	guerilla_player.do_move()

func restart_game():
	game_state = GameState.new()
	game_state.game_over.connect(_on_game_state_game_over)
	
	guerilla_player.game_state = game_state
	coin_player.game_state = game_state
	
	if GameManager.rapid_tournament == false:
		game_state.guerilla_piece_placed.connect(game_board.animate_corner_placement)
		game_state.coin_checker_moved.connect(game_board._on_game_state_coin_checker_moved)
		game_state.guerilla_piece_captured.connect(game_board._on_game_state_guerilla_piece_captured)
		game_state.coin_checker_captured.connect(game_board._on_game_state_coin_checker_captured)
		
		game_board.represent_game_state(game_state)
	
		if guerilla_player is HumanPlayer:
			guerilla_player.update_interface()
		if coin_player is HumanPlayer:
			coin_player.update_interface()
	
	guerilla_player.do_move()
	current_game_label.visible = GameManager.is_tournament()

func _create_players(guerilla_type : GameManager.PLAYER_TYPE,coin_type : GameManager.PLAYER_TYPE):
	if guerilla_type == GameManager.PLAYER_TYPE.HUMAN:
		var new_human_guerilla := HUMAN_PLAYER_SCENE.instantiate()
		add_child(new_human_guerilla)
		guerilla_player = new_human_guerilla
	elif guerilla_type == GameManager.PLAYER_TYPE.RANDOM:
		var new_random_guerilla := RANDOM_PLAYER_SCENE.instantiate()
		add_child(new_random_guerilla)
		guerilla_player = new_random_guerilla
	elif guerilla_type == GameManager.PLAYER_TYPE.UTILITY:
		var new_utility_guerilla := UTILITY_PLAYER_SCENE.instantiate()
		add_child(new_utility_guerilla)
		guerilla_player = new_utility_guerilla
	elif guerilla_type == GameManager.PLAYER_TYPE.MINIMAX:
		var new_minimax_guerilla : MinimaxPlayer = MINIMAX_PLAYER_SCENE.instantiate()
		add_child(new_minimax_guerilla)
		new_minimax_guerilla.profile = GameManager.guerilla_minimax_profile
		guerilla_player = new_minimax_guerilla
		
	
	if coin_type == GameManager.PLAYER_TYPE.HUMAN:
		var new_human_coin := HUMAN_PLAYER_SCENE.instantiate()
		add_child(new_human_coin)
		coin_player = new_human_coin
	elif coin_type == GameManager.PLAYER_TYPE.RANDOM:
		var new_random_coin := RANDOM_PLAYER_SCENE.instantiate()
		add_child(new_random_coin)
		coin_player = new_random_coin
	elif coin_type == GameManager.PLAYER_TYPE.UTILITY:
		var new_utility_coin := UTILITY_PLAYER_SCENE.instantiate()
		add_child(new_utility_coin)
		coin_player = new_utility_coin
	elif coin_type == GameManager.PLAYER_TYPE.MINIMAX:
		var new_minimax_coin : MinimaxPlayer = MINIMAX_PLAYER_SCENE.instantiate()
		add_child(new_minimax_coin)
		new_minimax_coin.profile = GameManager.coin_minimax_profile
		coin_player = new_minimax_coin
	
	guerilla_player.game_state = game_state
	coin_player.game_state = game_state
	
	guerilla_player.my_type = GameState.PLAYER.GUERILLA
	coin_player.my_type = GameState.PLAYER.COIN
	
	guerilla_player.move_taken.connect(simulate_move)
	coin_player.move_taken.connect(simulate_move)
	
	if guerilla_player is HumanPlayer:
		guerilla_player.setup_ui(game_board)
		move_simulated.connect(guerilla_player.update_interface)
	
	if coin_player is HumanPlayer:
		coin_player.setup_ui(game_board)
		move_simulated.connect(coin_player.update_interface)

func _unhandled_key_input(event):
	if event.is_action_pressed("escape") == true:
		quit_confirmation_dialog.dialog_text = "Are you sure you want to return to the Main Menu?"
		
		if GameManager.is_tournament() == true:
			quit_confirmation_dialog.dialog_text += "\nVictories by Guerilla: %d\nVictories by COIN: %d\nDraws: %d" % [guerilla_victories,coin_victories,draws]
		
		quit_confirmation_dialog.popup_centered_ratio()

func _on_quit_confirmation_dialog_confirmed():
	get_tree().change_scene_to_file(MAIN_MENU_PATH)

func _process(_delta):
	game_board.update_guerilla_piece_left_label(game_state.guerilla_pieces_left)
	game_board.show_current_player(game_state.get_current_player())
	
	if GameManager.is_tournament() == true and GameManager.tournament_games_left > 0:
		current_game_label.text = "Game %d" % current_game

func _increment_winner(winner : GameState.PLAYER) -> void:
	if winner == GameState.PLAYER.GUERILLA:
		guerilla_victories += 1
		total_guerilla_win_turns += turns_in_game
	elif winner == GameState.PLAYER.COIN:
		coin_victories += 1
		total_coin_win_turns += turns_in_game
	elif winner == GameState.PLAYER.NOBODY:
		draws += 1
		total_draw_turns += turns_in_game
	turns_in_game = 0

func _on_game_state_game_over(winner : GameState.PLAYER):
	_increment_winner(winner)
	#Increment no. Types of COIN Victories, dependent on the situation
	if winner == GameState.PLAYER.COIN:
		total_win_coin_checkers_left += len(game_state.coin_checker_positions)
		if game_state.guerilla_pieces_left == 0:
			coin_runout_victories += 1
		else:
			coin_capture_victories += 1
	
	if winner == GameState.PLAYER.NOBODY:
		total_draw_coin_checkers_left += len(game_state.coin_checker_positions)
	
	if GameManager.rapid_tournament == false:
		current_game_label.visible = false
		
		var discussion_string = ""
		
		if winner == GameState.PLAYER.GUERILLA:
			discussion_string = "%s was victorious, succeeding in their struggle against %s!" % [GameManager.guerilla_player_name,GameManager.coin_player_name]
		elif winner == GameState.PLAYER.COIN:
			discussion_string = "%s was victorious, quashing %s!" % [GameManager.coin_player_name,GameManager.guerilla_player_name]
		elif winner == GameState.PLAYER.NOBODY:
			discussion_string = "Neither %s nor %s was victorious - this Struggle ended in a Stalemate." % [GameManager.guerilla_player_name,GameManager.coin_player_name]
			
		show_game_over_window(discussion_string)
	else:
		GameManager.tournament_games_left -= 1
		_update_rapid_game_labels()
		
		if GameManager.tournament_games_left > 0:
			_next_tournament_game()

func get_average_guerilla_win_turns() -> float:
	if guerilla_victories == 0:
		return -1.0
	
	return total_guerilla_win_turns / guerilla_victories

func get_average_coin_win_turns() -> float:
	if coin_victories == 0:
		return -1.0
	
	return total_coin_win_turns / coin_victories

func get_win_average_coin_checkers() -> float:
	if coin_victories == 0:
		return -1.0
	
	return total_win_coin_checkers_left / coin_victories

func get_draw_average_coin_checkers() -> float:
	if draws == 0:
		return -1.0
	
	return total_draw_coin_checkers_left / draws

func get_mean_guerilla_branching_factor() -> float:
	return total_possible_guerilla_moves / total_guerilla_moves_taken

func get_mean_coin_branching_factor() -> float:
	return total_possible_coin_moves / total_coin_moves_taken

func get_average_draw_turns() -> float:
	if draws == 0:
		return -1.0
	
	return total_draw_turns / draws

func get_average_turns() -> float:
	return total_turns / current_game

func show_game_over_window(discussion_string : String) -> void:
	if GameManager.is_tournament() == true:
		if GameManager.rapid_tournament == true:
			return
		
		GameManager.tournament_games_left -= 1
		if GameManager.tournament_games_left == 0:
			discussion_string += "\n\nThe Tournament has come to an end, and here's the final Tally after %d games:\nVictories by %s: %d \nVictories by %s: %d(%d by Capturing all pieces, %d by letting %s run out of pieces)\nDraws: %d" % [current_game,GameManager.guerilla_player_name,guerilla_victories,GameManager.coin_player_name,coin_victories,coin_capture_victories,coin_runout_victories,GameManager.guerilla_player_name,draws]
			discussion_string += "\nOn average, it took %.2f Turns for %s to win, %.2f Turns for %s to win, and %.2f Turns for a Draw.\nThe mean number of turns per game is %.2f." % [get_average_guerilla_win_turns(),GameManager.guerilla_player_name,get_average_coin_win_turns(),GameManager.coin_player_name,get_average_draw_turns(),get_average_turns()]
			
	if GameManager.is_tournament() == true and GameManager.tournament_games_left > 0:
		end_game_container.visible = false
		tournament_game_container.visible = true
	else:
		tournament_game_container.visible = false
		end_game_container.visible = true
	
	winner_discussion_label.text = discussion_string
	game_over_window.popup_centered_ratio()

func get_current_player() -> Player:
	if game_state.get_current_player() == GameState.PLAYER.GUERILLA:
		return guerilla_player
	elif game_state.get_current_player() == GameState.PLAYER.COIN:
		return coin_player
	return null

func simulate_move(move : Move) -> void:
	if move == null:
		return
	
	if game_state.get_current_player() == GameState.PLAYER.GUERILLA:
		total_guerilla_moves_taken += 1
	elif game_state.get_current_player() == GameState.PLAYER.COIN:
		total_coin_moves_taken += 1
	
	if move is GuerillaPiecePlacementMove and move.second_corner == -1:
		print(move.first_corner)
	
	game_state.take_move(move)
	game_board.default_color_board()
	
	if game_state.get_current_player() != current_player:
		turns_in_game += 1
		total_turns += 1
		current_player = game_state.get_current_player()
	
	if GameManager.rapid_tournament == false:
		await game_board.animation_complete
		await get_tree().process_frame
	else:
		await get_tree().process_frame
	
	move_simulated.emit()
	
	next_move()

func next_move() -> void:
	if game_state.get_current_player() == GameState.PLAYER.GUERILLA:
		total_possible_guerilla_moves += len(game_state.get_possible_moves())
		guerilla_player.do_move()
	elif game_state.get_current_player() == GameState.PLAYER.COIN:
		total_possible_coin_moves += len(game_state.get_possible_moves())
		coin_player.do_move()

func _on_replay_button_pressed():
	get_tree().reload_current_scene()

func _on_back_to_menu_button_pressed():
	_back_to_menu()

func _back_to_menu() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_PATH)

func _next_tournament_game() -> void:
	current_game += 1
	game_over_window.hide()
	restart_game()

func _on_next_game_button_pressed() -> void:
	_next_tournament_game()

func _on_game_over_window_close_requested() -> void:
	if GameManager.is_tournament() == false or GameManager.tournament_games_left == 0:
		_back_to_menu()
	else:
		_next_tournament_game()

func _on_save_rapid_play_results_button_pressed():
	var printed_string : String = ""
	printed_string += "Guerilla: %s\nCOIN: %s" % [GameManager.guerilla_player_name,GameManager.coin_player_name]
	printed_string += "\nTotal no. Games: %d" % current_game
	printed_string += "\nTotal Time taken for Tournament: %dms (%.2fms per game)" % [rapid_time_taken, float(rapid_time_taken)/current_game]
	printed_string += "\nMean no. Turns per Game: %.2f" % get_average_turns()
	
	printed_string += "\nGuerilla Victories: %d" % guerilla_victories
	printed_string += "\nTotal COIN Victories: %d" % coin_victories
	printed_string += "\nCOIN Victories by Capturing: %d" % coin_capture_victories
	printed_string += "\nCOIN Victories by Guerilla Running out of Pieces: %d" % coin_runout_victories
	printed_string += "\nDraws: %d" % draws
	
	printed_string += "\nMean Branching Factor for Guerilla: %.2f" % get_mean_guerilla_branching_factor()
	printed_string += "\nMean Branching Factor for COIN: %.2f" % get_mean_coin_branching_factor()
	
	if guerilla_victories > 0:
		printed_string += "\nMean Turn of Guerilla Victory: %.2f" % get_average_guerilla_win_turns()
	if coin_victories > 0:
		printed_string += "\nMean Turn of COIN Victory: %.2f" % get_average_coin_win_turns()
		printed_string += "\nMean no. COIN Checkers left per COIN Victory: %.2f" % get_win_average_coin_checkers()
	if draws > 0:
		printed_string += "\nMean Turn of Draw: %.2f" % get_average_draw_turns()
		printed_string += "\nMean no. COIN Checkers left per Draw: %.2f" % get_draw_average_coin_checkers()
	
	var guerilla_part := GameManager.guerilla_player_name.validate_filename().replace("_","").to_lower().replace(" ","_")
	var coin_part := GameManager.coin_player_name.validate_filename().replace("_","").to_lower().replace(" ","_")
	
	var file_name := guerilla_part+"_vs_"+coin_part+".txt"
	var new_file := FileAccess.open("user://tournament_results/"+file_name,FileAccess.WRITE)
	new_file.store_string(printed_string)
	new_file.close()
	
	save_rapid_play_results_button.disabled = true
