extends Control

const GAME_SCENE_PATH := "res://assets/scenes/game_scene/game_scene.tscn"

@onready var guerilla_player_select = $PanelContainer/MarginContainer/VBoxContainer/GuerillaPlayerSelect
@onready var counterinsurgent_player_select = $PanelContainer/MarginContainer/VBoxContainer/CounterinsurgentPlayerSelect

@onready var guerilla_name_edit = $PanelContainer/MarginContainer/VBoxContainer/GuerillaNameEdit
@onready var counterinsurgent_name_edit = $PanelContainer/MarginContainer/VBoxContainer/CounterinsurgentNameEdit

func _on_play_button_pressed():
	_set_settings()
	get_tree().change_scene_to_file(GAME_SCENE_PATH)

func _set_settings():
	if guerilla_player_select.selected == 0:
		GameManager.guerilla_player_type = GameManager.PLAYER_TYPE.HUMAN
	elif guerilla_player_select.selected == 1:
		GameManager.guerilla_player_type = GameManager.PLAYER_TYPE.RANDOM
	elif guerilla_player_select.selected == 2:
		GameManager.guerilla_player_type = GameManager.PLAYER_TYPE.UTILITY
	elif guerilla_player_select.selected == 3:
		GameManager.guerilla_player_type = GameManager.PLAYER_TYPE.MINIMAX
	
	if counterinsurgent_player_select.selected == 0:
		GameManager.coin_player_type = GameManager.PLAYER_TYPE.HUMAN
	elif counterinsurgent_player_select.selected == 1:
		GameManager.coin_player_type = GameManager.PLAYER_TYPE.RANDOM
	elif counterinsurgent_player_select.selected == 2:
		GameManager.coin_player_type = GameManager.PLAYER_TYPE.UTILITY
	elif counterinsurgent_player_select.selected == 3:
		GameManager.coin_player_type = GameManager.PLAYER_TYPE.MINIMAX
	
	if guerilla_name_edit.text == "":
		guerilla_name_edit.text = "The Guerilla"
	if counterinsurgent_name_edit.text == "":
		counterinsurgent_name_edit.text = "The Counterinsurgent"
	
	GameManager.guerilla_player_name = guerilla_name_edit.text
	GameManager.coin_player_name = counterinsurgent_name_edit.text
