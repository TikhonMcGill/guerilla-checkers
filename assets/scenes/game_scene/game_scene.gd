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

@onready var quit_confirmation_dialog : ConfirmationDialog = $QuitConfirmationDialog

@onready var game_over_container = $GameOverContainer
@onready var winner_discussion_label = $GameOverContainer/MarginContainer/VBoxContainer/WinnerDiscussionLabel

func _ready():
	game_state = GameState.new()
	game_board = $GameBoard
	
	game_state.game_over.connect(_on_game_state_game_over)
	
	game_board.represent_game_state(game_state)
	
	game_state.guerilla_piece_placed.connect(game_board._on_game_state_guerilla_piece_placed)
	game_state.coin_checker_moved.connect(game_board._on_game_state_coin_checker_moved)
	game_state.guerilla_piece_captured.connect(game_board._on_game_state_guerilla_piece_captured)
	game_state.coin_checker_captured.connect(game_board._on_game_state_coin_checker_captured)
	
	_create_players(GameManager.guerilla_player_type,GameManager.coin_player_type)
	
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
		var new_minimax_guerilla := MINIMAX_PLAYER_SCENE.instantiate()
		add_child(new_minimax_guerilla)
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
		var new_minimax_coin := MINIMAX_PLAYER_SCENE.instantiate()
		add_child(new_minimax_coin)
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

func _on_game_state_game_over(winner : GameState.PLAYER):
	var discussion_string = ""
	
	if winner == GameState.PLAYER.GUERILLA:
		discussion_string = "%s (Guerilla) was victorious, succeeding in their struggle against %s!" % [GameManager.guerilla_player_name,GameManager.coin_player_name]
	elif winner == GameState.PLAYER.COIN:
		discussion_string = "%s (COIN) was victorious, quashing %s!" % [GameManager.coin_player_name,GameManager.guerilla_player_name]
	elif winner == GameState.PLAYER.NOBODY:
		discussion_string = "Neither the %s(Guerilla) nor %s(COIN) was victorious - this Game ended in a Draw." % [GameManager.guerilla_player_name,GameManager.coin_player_name]
	
	game_over_container.position = Vector2i((game_board.tile_size * 8) + game_board.tile_size,game_board.position.y)
	game_over_container.size.y = game_board.tile_size * 8
	winner_discussion_label.text = discussion_string
	game_over_container.visible = true

func simulate_move(move : Move) -> void:
	game_state.take_move(move)
	game_board.default_color_board()
	
	move_simulated.emit()
	
	await game_board.animation_complete
	
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
