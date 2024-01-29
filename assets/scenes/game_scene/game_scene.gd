extends Node

const MAIN_MENU_PATH := "res://assets/scenes/main_menu/main_menu.tscn"

var game_state : GameState
var game_board : GameBoard

@onready var quit_confirmation_dialog = $QuitConfirmationDialog

func _ready():
	game_state = GameState.new()
	game_board = $GameBoard
	
	game_board.represent_game_state(game_state)

func _unhandled_key_input(event):
	if event.is_action_pressed("escape") == true:
		quit_confirmation_dialog.popup_centered_ratio()

func _on_quit_confirmation_dialog_confirmed():
	get_tree().change_scene_to_file(MAIN_MENU_PATH)

func _on_game_test_timer_timeout():
	var moves := game_state.get_possible_moves()
	
	if len(moves) == 0:
		return
	
	var move : Move = moves.pick_random()
	game_state.take_move(move)
	game_board.represent_game_state(game_state)
