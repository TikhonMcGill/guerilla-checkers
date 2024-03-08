extends Control

const MAIN_MENU_SCENE_PATH := "res://assets/scenes/menus/main_menu/main_menu.tscn"

@onready var minimax_list: VBoxContainer = $PanelContainer/MarginContainer/MinimaxList
@onready var minimax_editor: VBoxContainer = $PanelContainer/MarginContainer/MinimaxEditor

var edited_profile : MinimaxProfile = null

func _ready() -> void:
	_hide_minimax_editor()
	_show_minimax_list()

func _show_minimax_list() -> void:
	minimax_list.populate()
	minimax_list.visible = true

func _hide_minimax_list() -> void:
	minimax_list.visible = false

func _show_minimax_editor() -> void:
	minimax_editor.visible = true

func _hide_minimax_editor() -> void:
	minimax_editor.visible = false

func _on_create_new_profile_button_pressed() -> void:
	edited_profile = null
	_hide_minimax_list()
	minimax_editor.clear()
	_show_minimax_editor()

func _on_minimax_editor_profile_completed(profile: MinimaxProfile) -> void:
	minimax_editor.clear()
	
	if profile != null:
		if edited_profile != null:
			GameManager.delete_minimax_profile(edited_profile)
		edited_profile = null
		
		GameManager.save_minimax_profile(profile)
		GameManager.minimax_profiles.append(profile)
	
	_hide_minimax_editor()
	_show_minimax_list()

func _on_minimax_list_profile_edited(profile: MinimaxProfile) -> void:
	edited_profile = profile
	_hide_minimax_list()
	_show_minimax_editor()
	minimax_editor.clear()
	minimax_editor.load_profile(profile)

func _on_back_to_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)
