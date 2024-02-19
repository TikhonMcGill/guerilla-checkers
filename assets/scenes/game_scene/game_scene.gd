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

@onready var quit_confirmation_dialog : ConfirmationDialog = $QuitConfirmationDialog

@onready var game_over_container = $GameOverContainer
@onready var winner_discussion_label = $GameOverContainer/MarginContainer/VBoxContainer/WinnerDiscussionLabel

@onready var current_game_label: Label = $GameBoard/CurrentGameLabel

func _ready():
	game_state = GameState.new()
	game_board = $GameBoard
	
	game_state.game_over.connect(_on_game_state_game_over)
	
	game_board.represent_game_state(game_state)
	
	var board_rect := game_board.get_board_rect()
	
	current_game_label.position = Vector2(board_rect.end.x,board_rect.position.y)
	
	game_state.guerilla_piece_placed.connect(game_board._on_game_state_guerilla_piece_placed)
	game_state.coin_checker_moved.connect(game_board._on_game_state_coin_checker_moved)
	game_state.guerilla_piece_captured.connect(game_board._on_game_state_guerilla_piece_captured)
	game_state.coin_checker_captured.connect(game_board._on_game_state_coin_checker_captured)
	
	_create_players(GameManager.guerilla_player_type,GameManager.coin_player_type)
	
	guerilla_player.do_move()

func restart_game():
	game_state = GameState.new()
	game_state.game_over.connect(_on_game_state_game_over)
	game_state.guerilla_piece_placed.connect(game_board._on_game_state_guerilla_piece_placed)
	game_state.coin_checker_moved.connect(game_board._on_game_state_coin_checker_moved)
	game_state.guerilla_piece_captured.connect(game_board._on_game_state_guerilla_piece_captured)
	game_state.coin_checker_captured.connect(game_board._on_game_state_coin_checker_captured)
	game_board.represent_game_state(game_state)
	
	if guerilla_player is HumanPlayer:
		guerilla_player.update_interface()
	if coin_player is HumanPlayer:
		coin_player.update_interface()
	
	guerilla_player.do_move()

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
		quit_confirmation_dialog.popup_centered_ratio()

func _on_quit_confirmation_dialog_confirmed():
	get_tree().change_scene_to_file(MAIN_MENU_PATH)

func _process(delta):
	game_board.update_guerilla_piece_left_label(game_state.guerilla_pieces_left)
	game_board.show_current_player(game_state.get_current_player())
	
	if GameManager.is_tournament() == true and GameManager.tournament_games_left > 0:
		current_game_label.visible = true
		current_game_label.text = "Game %d" % current_game

func _on_game_state_game_over(winner : GameState.PLAYER):
	var discussion_string = ""
	
	if winner == GameState.PLAYER.GUERILLA:
		discussion_string = "%s was victorious, succeeding in their struggle against %s!" % [GameManager.guerilla_player_name,GameManager.coin_player_name]
	elif winner == GameState.PLAYER.COIN:
		discussion_string = "%s was victorious, quashing %s!" % [GameManager.coin_player_name,GameManager.guerilla_player_name]
	elif winner == GameState.PLAYER.NOBODY:
		discussion_string = "Neither the %s nor %s was victorious - this Struggle ended in a Stalemate." % [GameManager.guerilla_player_name,GameManager.coin_player_name]
	
	if GameManager.is_tournament() == false:
		show_game_over_container(discussion_string)
	else: 
		current_game += 1
		GameManager.tournament_games_left -= 1
		if GameManager.tournament_games_left == 0:
			show_game_over_container(discussion_string)
		else:
			restart_game()

func show_game_over_container(discussion_string : String) -> void:
	game_over_container.position = Vector2i((game_board.tile_size * 8) + game_board.tile_size,game_board.position.y)
	game_over_container.size.y = game_board.tile_size * 8
	winner_discussion_label.text = discussion_string
	game_over_container.visible = true

func get_current_player() -> Player:
	if game_state.get_current_player() == GameState.PLAYER.GUERILLA:
		return guerilla_player
	elif game_state.get_current_player() == GameState.PLAYER.COIN:
		return coin_player
	return null

func simulate_move(move : Move) -> void:
	var first_player = game_state.get_current_player()
	
	game_state.take_move(move)
	game_board.default_color_board()
	
	if first_player != game_state.get_current_player():
		await game_board.animation_complete
	
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
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
