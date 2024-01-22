extends Control

const GAME_SCENE_PATH := "res://assets/scenes/game_scene/game_scene.tscn"

func _on_play_button_pressed():
	get_tree().change_scene_to_file(GAME_SCENE_PATH)
