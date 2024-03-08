extends Control

const GAME_SCENE_PATH := "res://assets/scenes/game_scene/game_scene.tscn"
const MINIMAX_PROFILE_EDIT_PATH := "res://assets/scenes/menus/minimax_profile_editor/minimax_profile_editor.tscn"
const TOURNAMENT_STARTING_SETTINGS_PATH := "res://assets/scenes/menus/tournament_starting_settings/starting_tournament_settings.tscn"

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

@onready var random_seed: SpinBox = $PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/RandomSeed

func _ready() -> void:
	_populate_minimax_select(guerilla_minimax_profile_select)
	_populate_minimax_select(coin_minimax_profile_select)
	
	_load_settings()

func _process(delta: float) -> void:
	tournament_container.visible = tournament_check_box.button_pressed
	rapid_play_check_box.visible = tournament_container.visible == true and _both_players_ais() == true
	guerilla_minimax_profile_container.visible = guerilla_player_select.selected == 3
	coin_minimax_profile_container.visible = counterinsurgent_player_select.selected == 3
	
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

func _load_settings():
	var saved_selections : SavedSelections = GameManager.saved_selections
	
	guerilla_name_edit.text = saved_selections.guerilla_player_name
	counterinsurgent_name_edit.text = saved_selections.coin_player_name
	
	_load_guerilla_select(saved_selections)
	_load_coin_select(saved_selections)
	
	tournament_check_box.button_pressed = saved_selections.tournament
	games_spin_box.value = saved_selections.tournament_games
	rapid_play_check_box.button_pressed = saved_selections.rapid_tournament
	
	random_seed.value = saved_selections.random_seed

func _save_settings():
	var saved_settings : SavedSelections = GameManager.saved_selections
	
	saved_settings.guerilla_player_name = guerilla_name_edit.text
	saved_settings.coin_player_name = counterinsurgent_name_edit.text
	
	saved_settings.random_seed = random_seed.value
	
	_save_guerilla_select()
	_save_coin_select()
	
	saved_settings.tournament = tournament_check_box.button_pressed
	saved_settings.tournament_games = games_spin_box.value
	saved_settings.rapid_tournament = rapid_play_check_box.button_pressed
	
	GameManager.save_settings()

func _set_settings():
	_save_settings()
	
	seed(random_seed.value)
	
	if guerilla_player_select.selected == 0:
		GameManager.guerilla_player_type = GameManager.PLAYER_TYPE.HUMAN
	elif guerilla_player_select.selected == 1:
		GameManager.guerilla_player_type = GameManager.PLAYER_TYPE.RANDOM
	elif guerilla_player_select.selected == 2:
		GameManager.guerilla_player_type = GameManager.PLAYER_TYPE.UTILITY
	elif guerilla_player_select.selected == 3:
		if len(GameManager.minimax_profiles) == 0:
			return
		GameManager.guerilla_player_type = GameManager.PLAYER_TYPE.MINIMAX
	
	if counterinsurgent_player_select.selected == 0:
		GameManager.coin_player_type = GameManager.PLAYER_TYPE.HUMAN
	elif counterinsurgent_player_select.selected == 1:
		GameManager.coin_player_type = GameManager.PLAYER_TYPE.RANDOM
	elif counterinsurgent_player_select.selected == 2:
		GameManager.coin_player_type = GameManager.PLAYER_TYPE.UTILITY
	elif counterinsurgent_player_select.selected == 3:
		if len(GameManager.minimax_profiles) == 0:
			return
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

func _select_guerilla_player(index : int):
	guerilla_player_select.selected = index
	if guerilla_player_select.get_item_id(index) == 3:
		guerilla_minimax_profile_container.visible = true
	else:
		guerilla_minimax_profile_container.visible = false

func _select_coin_player(index : int):
	counterinsurgent_player_select.selected = index
	if counterinsurgent_player_select.get_item_id(index) == 3:
		coin_minimax_profile_container.visible = true
	else:
		coin_minimax_profile_container.visible = false

func _on_guerilla_player_select_item_selected(index: int) -> void:
	_select_guerilla_player(index)

func _both_players_ais() -> bool:
	var guerilla_player_id : int = guerilla_player_select.get_item_id(guerilla_player_select.selected)
	var coin_player_id : int = counterinsurgent_player_select.get_item_id(counterinsurgent_player_select.selected)
	
	return guerilla_player_id != 0 and coin_player_id != 0

func _on_counterinsurgent_player_select_item_selected(index: int) -> void:
	_select_coin_player(index)

func _load_guerilla_select(saved : SavedSelections) -> void:
	if saved.guerilla_player_type == saved.HUMAN_PLAYER:
		guerilla_player_select.selected = 0
	elif saved.guerilla_player_type == saved.RANDOM_PLAYER:
		guerilla_player_select.selected = 1
	elif saved.guerilla_player_type == saved.UTILITY_PLAYER:
		guerilla_player_select.selected = 2
	elif saved.guerilla_player_type.begins_with(saved.MINIMAX_PLAYER):
		var profile_name := saved.guerilla_player_type.trim_prefix(saved.MINIMAX_PLAYER)
		guerilla_minimax_profile_container.visible = true
		guerilla_player_select.selected = 3
		guerilla_minimax_profile_select.selected = GameManager.get_minimax_name_index(profile_name)

func _save_guerilla_select() -> void:
	if guerilla_player_select.selected == 0:
		GameManager.saved_selections.guerilla_player_type = SavedSelections.HUMAN_PLAYER
	elif guerilla_player_select.selected == 1:
		GameManager.saved_selections.guerilla_player_type = SavedSelections.RANDOM_PLAYER
	elif guerilla_player_select.selected == 2:
		GameManager.saved_selections.guerilla_player_type = SavedSelections.UTILITY_PLAYER
	elif guerilla_player_select.selected == 3:
		GameManager.saved_selections.guerilla_player_type = SavedSelections.MINIMAX_PLAYER + GameManager.minimax_profiles[guerilla_minimax_profile_select.selected].profile_name

func _load_coin_select(saved : SavedSelections) -> void:
	if saved.coin_player_type == saved.HUMAN_PLAYER:
		counterinsurgent_player_select.selected = 0
	elif saved.coin_player_type == saved.RANDOM_PLAYER:
		counterinsurgent_player_select.selected = 1
	elif saved.coin_player_type == saved.UTILITY_PLAYER:
		counterinsurgent_player_select.selected = 2
	elif saved.coin_player_type.begins_with(saved.MINIMAX_PLAYER):
		coin_minimax_profile_container.visible = true
		var profile_name := saved.coin_player_type.trim_prefix(saved.MINIMAX_PLAYER)
		counterinsurgent_player_select.selected = 3
		coin_minimax_profile_select.selected = GameManager.get_minimax_name_index(profile_name)

func _save_coin_select() -> void:
	if counterinsurgent_player_select.selected == 0:
		GameManager.saved_selections.coin_player_type = SavedSelections.HUMAN_PLAYER
	elif counterinsurgent_player_select.selected == 1:
		GameManager.saved_selections.coin_player_type = SavedSelections.RANDOM_PLAYER
	elif counterinsurgent_player_select.selected == 2:
		GameManager.saved_selections.coin_player_type = SavedSelections.UTILITY_PLAYER
	elif counterinsurgent_player_select.selected == 3:
		GameManager.saved_selections.coin_player_type = SavedSelections.MINIMAX_PLAYER + GameManager.minimax_profiles[coin_minimax_profile_select.selected].profile_name

func _on_swap_players_button_pressed():
	var guerilla_selection := guerilla_player_select.selected
	var guerilla_minimax_selection := guerilla_minimax_profile_select.selected
	var coin_selection := counterinsurgent_player_select.selected
	var coin_minimax_selection := coin_minimax_profile_select.selected
	
	guerilla_player_select.selected = coin_selection
	guerilla_minimax_profile_select.selected = coin_minimax_selection
	counterinsurgent_player_select.selected = guerilla_selection
	coin_minimax_profile_select.selected = guerilla_minimax_selection
	
	var guerilla_name := guerilla_name_edit.text
	var coin_name := counterinsurgent_name_edit.text
	
	guerilla_name_edit.text = coin_name.replacen("COIN","Guerilla")
	counterinsurgent_name_edit.text = guerilla_name.replacen("Guerilla","COIN")
