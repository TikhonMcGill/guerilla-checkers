extends Node

const MAIN_MENU_PATH := "res://assets/scenes/main_menu/main_menu.tscn"

var game_state : GameState
var game_board : GameBoard

var guerilla_player : Player
var coin_player : Player

@onready var quit_confirmation_dialog = $QuitConfirmationDialog

func _ready():
	game_state = GameState.new()
	game_board = $GameBoard
	
	game_state.game_over.connect(_on_game_state_game_over)
	
	game_board.represent_game_state(game_state)
	
	game_state.guerilla_piece_placed.connect(game_board._on_game_state_guerilla_piece_placed)
	game_state.coin_checker_moved.connect(game_board._on_game_state_coin_checker_moved)
	game_state.guerilla_piece_captured.connect(game_board._on_game_state_guerilla_piece_captured)
	game_state.coin_checker_captured.connect(game_board._on_game_state_coin_checker_captured)

func _unhandled_key_input(event):
	if event.is_action_pressed("escape") == true:
		quit_confirmation_dialog.popup_centered_ratio()

func _on_quit_confirmation_dialog_confirmed():
	get_tree().change_scene_to_file(MAIN_MENU_PATH)

func _process(delta):
	game_board.update_guerilla_piece_left_label(game_state.guerilla_pieces_left)
	game_board.show_current_player(game_state.get_current_player())

func _on_game_state_game_over(winner : GameState.PLAYER):
	if winner == GameState.PLAYER.GUERILLA:
		print("Guerilla Victorious!")
	elif winner == GameState.PLAYER.COIN:
		print("COIN Victorious!")
	elif winner == GameState.PLAYER.NOBODY:
		print("Draw!")
