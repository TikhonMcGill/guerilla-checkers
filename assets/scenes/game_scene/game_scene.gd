extends Node

const MAIN_MENU_PATH := "res://assets/scenes/main_menu/main_menu.tscn"

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
@onready var rapid_tournament_time_taken_label: Label = $RapidGamePanel/MarginContainer/VBoxContainer/RapidTournamentTimeTakenLabel

var guerilla_victories : int = 0
var coin_victories : int = 0
var draws : int = 0

var rapid_start_time := Time.get_ticks_msec()

func _update_rapid_game_labels() -> void:
	current_rapid_game_label.text = "Current Game: %d" % current_game
	current_guerilla_wins_label.text = "Victories by Guerilla (%s): %d" % [GameManager.guerilla_player_name,guerilla_victories]
	current_coin_wins_label.text = "Victories by The Counterinsurgent (%s): %d" % [GameManager.coin_player_name,coin_victories]
	current_draws_label.text = "Draws: %d" % draws
	
	rapid_play_back_to_menu_button.visible = GameManager.tournament_games_left == 0
	rapid_tournament_time_taken_label.visible = GameManager.tournament_games_left == 0
	
	if rapid_tournament_time_taken_label.visible == true:
		var end_time := Time.get_ticks_msec()
		var total_time : float = float(end_time - rapid_start_time) / 1000
		rapid_tournament_time_taken_label.text = "The Tournament took %.1f seconds to run" % total_time

func _ready():
	game_state = GameState.new()
	game_board = $GameBoard
	
	game_state.game_over.connect(_on_game_state_game_over)
	
	if GameManager.rapid_tournament == false:
		game_board.represent_game_state(game_state)
		var board_rect := game_board.get_board_rect()
		current_game_label.position = Vector2(board_rect.end.x,board_rect.position.y)
		game_state.guerilla_piece_placed.connect(game_board._on_game_state_guerilla_piece_placed)
		game_state.coin_checker_moved.connect(game_board._on_game_state_coin_checker_moved)
		game_state.guerilla_piece_captured.connect(game_board._on_game_state_guerilla_piece_captured)
		game_state.coin_checker_captured.connect(game_board._on_game_state_coin_checker_captured)
	else:
		rapid_game_panel.visible = true
		_update_rapid_game_labels()
		game_board.visible = false
	
	_create_players(GameManager.guerilla_player_type,GameManager.coin_player_type)
	
	current_game_label.visible = GameManager.is_tournament()
	
	guerilla_player.do_move()

func restart_game():
	var old_game_state = game_state
	
	game_state = GameState.new()
	game_state.game_over.connect(_on_game_state_game_over)
	
	guerilla_player.game_state = game_state
	coin_player.game_state = game_state
	
	if GameManager.rapid_tournament == false:
		game_state.guerilla_piece_placed.connect(game_board._on_game_state_guerilla_piece_placed)
		game_state.coin_checker_moved.connect(game_board._on_game_state_coin_checker_moved)
		game_state.guerilla_piece_captured.connect(game_board._on_game_state_guerilla_piece_captured)
		game_state.coin_checker_captured.connect(game_board._on_game_state_coin_checker_captured)
		
		game_board.represent_game_state(game_state)
	
		if guerilla_player is HumanPlayer:
			guerilla_player.update_interface()
		if coin_player is HumanPlayer:
			coin_player.update_interface()
	
	old_game_state.call_deferred("free")
	
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

func _process(delta):
	game_board.update_guerilla_piece_left_label(game_state.guerilla_pieces_left)
	game_board.show_current_player(game_state.get_current_player())
	
	if GameManager.is_tournament() == true and GameManager.tournament_games_left > 0:
		current_game_label.text = "Game %d" % current_game

func _increment_winner(winner : GameState.PLAYER) -> void:
	if winner == GameState.PLAYER.GUERILLA:
		guerilla_victories += 1
	elif winner == GameState.PLAYER.COIN:
		coin_victories += 1
	elif winner == GameState.PLAYER.NOBODY:
		draws += 1

func _on_game_state_game_over(winner : GameState.PLAYER):
	_increment_winner(winner)
	
	if GameManager.rapid_tournament == false:
		current_game_label.visible = false
		
		var discussion_string = ""
		
		if winner == GameState.PLAYER.GUERILLA:
			discussion_string = "%s was victorious, succeeding in their struggle against %s!" % [GameManager.guerilla_player_name,GameManager.coin_player_name]
		elif winner == GameState.PLAYER.COIN:
			discussion_string = "%s was victorious, quashing %s!" % [GameManager.coin_player_name,GameManager.guerilla_player_name]
		elif winner == GameState.PLAYER.NOBODY:
			discussion_string = "Neither the %s nor %s was victorious - this Struggle ended in a Stalemate." % [GameManager.guerilla_player_name,GameManager.coin_player_name]
		
		show_game_over_window(discussion_string)
	else:
		GameManager.tournament_games_left -= 1
		_update_rapid_game_labels()
		
		if GameManager.tournament_games_left > 0:
			_next_tournament_game()

func show_game_over_window(discussion_string : String) -> void:
	if GameManager.is_tournament() == true:
		if GameManager.rapid_tournament == true:
			return
		
		GameManager.tournament_games_left -= 1
		if GameManager.tournament_games_left == 0:
			discussion_string += "\n\nThe Tournament has come to an end, and here's the final Tally after %d games:\nVictories by %s: %d\nVictories by %s: %d\nDraws: %d" % [current_game,GameManager.guerilla_player_name,guerilla_victories,GameManager.coin_player_name,coin_victories,draws]
	
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
	move_timer.start()
	
	game_state.take_move(move)
	game_board.default_color_board()
	
	if GameManager.rapid_tournament == false:
		await game_board.animation_complete
	else:
		await get_tree().process_frame
	
	move_simulated.emit()
	
	next_move()

func next_move() -> void:
	if game_state.get_current_player() == GameState.PLAYER.GUERILLA:
		guerilla_player.do_move()
	elif game_state.get_current_player() == GameState.PLAYER.COIN:
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
