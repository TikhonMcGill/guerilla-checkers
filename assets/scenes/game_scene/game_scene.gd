extends Node

const MAIN_MENU_PATH := "res://assets/scenes/main_menu/main_menu.tscn"

var game_state : GameState

@onready var quit_confirmation_dialog = $QuitConfirmationDialog
@onready var game_board = $GameBoard

@onready var adjacency_test_timer = $AdjacencyTestTimer

func _ready():
	game_state = GameState.new()

func _unhandled_key_input(event):
	if event.is_action_pressed("escape") == true:
		quit_confirmation_dialog.popup_centered_ratio()

func _on_quit_confirmation_dialog_confirmed():
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
