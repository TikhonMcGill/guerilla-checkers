extends VBoxContainer

const MINIMAX_ENTRY_SCENE := preload("res://assets/scenes/minimax_profile_editor/minimax_entry.tscn")

@onready var minimax_entry_list: VBoxContainer = $ScrollContainer/MinimaxEntryList

signal profile_edited(profile : MinimaxProfile)

func _clear():
	for c in minimax_entry_list.get_children():
		c.queue_free()

func populate():
	_clear()
	for p in GameManager.minimax_profiles:
		_create_entry_for_profile(p)

func _create_entry_for_profile(profile : MinimaxProfile) -> void:
	var new_entry : MinimaxEntry = MINIMAX_ENTRY_SCENE.instantiate()
	minimax_entry_list.add_child(new_entry)
	
	new_entry.set_profile(profile)
	new_entry.profile_edited.connect(_do_edited_profile)
	new_entry.profile_deleted.connect(_delete_entry_for_profile)

func _delete_entry_for_profile(profile : MinimaxProfile) -> void:
	for entry : MinimaxEntry in minimax_entry_list.get_children():
		if entry.my_profile == profile:
			GameManager.delete_minimax_profile(profile)
			entry.queue_free()
			return

func _do_edited_profile(profile : MinimaxProfile) -> void:
	profile_edited.emit(profile)
