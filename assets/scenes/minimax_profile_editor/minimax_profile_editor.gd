extends Control

@onready var minimax_list: VBoxContainer = $PanelContainer/MarginContainer/MinimaxList
@onready var minimax_editor: VBoxContainer = $PanelContainer/MarginContainer/MinimaxEditor

func _ready() -> void:
	_hide_minimax_editor()
	_show_minimax_list()

func _show_minimax_list() -> void:
	minimax_list.visible = true

func _hide_minimax_list() -> void:
	minimax_list.visible = false

func _show_minimax_editor() -> void:
	minimax_editor.visible = true

func _hide_minimax_editor() -> void:
	minimax_editor.visible = false

func _on_create_new_profile_button_pressed() -> void:
	_hide_minimax_list()
	minimax_editor.clear()
	_show_minimax_editor()

func _on_minimax_editor_profile_completed(profile: MinimaxProfile) -> void:
	GameManager.save_minimax_profile(profile)
	_hide_minimax_editor()
	_show_minimax_list()
