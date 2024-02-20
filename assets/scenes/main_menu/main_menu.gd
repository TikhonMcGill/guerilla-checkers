extends Control

const GAME_SCENE_PATH := "res://assets/scenes/game_scene/game_scene.tscn"
const MINIMAX_PROFILE_EDIT_PATH := "res://assets/scenes/minimax_profile_editor/minimax_profile_editor.tscn"

@onready var guerilla_player_select: OptionButton = $PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/GuerillaPlayerSelect
@onready var counterinsurgent_player_select: OptionButton = $PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/CounterinsurgentPlayerSelect

@onready var guerilla_name_edit: LineEdit = $PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/GuerillaNameEdit
@onready var counterinsurgent_name_edit: LineEdit = $PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/CounterinsurgentNameEdit

@onready var guerilla_minimax_profile_select: OptionButton = $PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/GuerillaMinimaxProfileContainer/GuerillaMinimaxProfileSelect
@onready var guerilla_minimax_profile_container: VBoxContainer = $PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/GuerillaMinimaxProfileContainer

@onready var coin_minimax_profile_select: OptionButton = $PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/COINMinimaxProfileContainer/CoinMinimaxProfileSelect
@onready var coin_minimax_profile_container: VBoxContainer = $PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/COINMinimaxProfileContainer

@onready var tournament_check_box: CheckBox = $PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/TournamentCheckBox
@onready var tournament_container: VBoxContainer = $PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/TournamentContainer
@onready var games_spin_box: SpinBox = $PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/TournamentContainer/HBoxContainer/GamesSpinBox
@onready var rapid_play_check_box: CheckBox = $PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/TournamentContainer/RapidPlayCheckBox

func _process(delta: float) -> void:
	tournament_container.visible = tournament_check_box.button_pressed
	rapid_play_check_box.visible = tournament_container.visible == true and _both_players_ais() == true

func _on_play_button_pressed():
	_set_settings()
	
	if guerilla_minimax_profile_container.visible == true:
		if guerilla_minimax_profile_select.selected == -1:
			return
		
		GameManager.guerilla_minimax_profile = GameManager.minimax_profiles[guerilla_minimax_profile_select.selected]
	
	if coin_minimax_profile_container.visible == true:
		if coin_minimax_profile_select.selected == -1:
			return
		
		GameManager.coin_minimax_profile = GameManager.minimax_profiles[coin_minimax_profile_select.selected]
	
	get_tree().change_scene_to_file(GAME_SCENE_PATH)

func _populate_minimax_select(select : OptionButton) -> void:
	select.clear()
	for profile : MinimaxProfile in GameManager.minimax_profiles:
		select.add_item(profile.profile_name)

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
	
	if tournament_container.visible == true:
		GameManager.tournament_games_left = games_spin_box.value
		GameManager.rapid_tournament = rapid_play_check_box.button_pressed
	else:
		GameManager.tournament_games_left = -1

func _on_minimax_profile_edit_pressed() -> void:
	get_tree().change_scene_to_file(MINIMAX_PROFILE_EDIT_PATH)

func _on_guerilla_player_select_item_selected(index: int) -> void:
	if guerilla_player_select.get_item_id(index) == 3:
		guerilla_minimax_profile_container.visible = true
		_populate_minimax_select(guerilla_minimax_profile_select)
	else:
		guerilla_minimax_profile_container.visible = false

func _both_players_ais() -> bool:
	var guerilla_player_id : int = guerilla_player_select.get_item_id(guerilla_player_select.selected)
	var coin_player_id : int = counterinsurgent_player_select.get_item_id(counterinsurgent_player_select.selected)
	
	return guerilla_player_id != 0 and coin_player_id != 0

func _on_counterinsurgent_player_select_item_selected(index: int) -> void:
	if counterinsurgent_player_select.get_item_id(index) == 3:
		coin_minimax_profile_container.visible = true
		_populate_minimax_select(coin_minimax_profile_select)
	else:
		coin_minimax_profile_container.visible = false
