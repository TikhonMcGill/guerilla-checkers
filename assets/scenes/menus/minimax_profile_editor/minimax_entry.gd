extends HBoxContainer

class_name MinimaxEntry

signal profile_deleted(profile : MinimaxProfile)
signal profile_edited(profile : MinimaxProfile)

var my_profile : MinimaxProfile

@onready var profile_name_label: Label = $ProfileNameLabel

func set_profile(profile : MinimaxProfile):
	my_profile = profile
	profile_name_label.text = my_profile.profile_name

func _on_edit_button_pressed() -> void:
	profile_edited.emit(my_profile)

func _on_delete_button_pressed() -> void:
	profile_deleted.emit(my_profile)
