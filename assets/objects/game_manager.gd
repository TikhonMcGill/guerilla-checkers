extends Node

enum PLAYER_TYPE {HUMAN,RANDOM,UTILITY,MINIMAX}

const EASY_MINIMAX_PROFILE : MinimaxProfile = preload("res://assets/resources/beginner_minimax.tres")
const MEDIUM_MINIMAX_PROFILE : MinimaxProfile = preload("res://assets/resources/decent_minimax.tres")
const HARD_MINIMAX_PROFILE : MinimaxProfile = preload("res://assets/resources/hard_minimax.tres")

var guerilla_player_type : PLAYER_TYPE = PLAYER_TYPE.HUMAN
var coin_player_type : PLAYER_TYPE = PLAYER_TYPE.HUMAN

var guerilla_player_name : String = "The Guerilla"
var coin_player_name : String = "The Counterinsurgent"

var minimax_profiles : Array[MinimaxProfile]

var guerilla_minimax_profile : MinimaxProfile = null
var coin_minimax_profile : MinimaxProfile = null

var tournament_games_left : int = -1
var rapid_tournament : bool = false

var saved_selections : SavedSelections

func _load_minimax_profiles() -> void:
	var files := DirAccess.get_files_at("user://minimax_profiles")
	for f in files:
		minimax_profiles.append(load_minimax_profile(f))

func save_minimax_profile(profile : MinimaxProfile) -> void:
	var filename := profile.profile_name.validate_filename()
	ResourceSaver.save(profile,"user://minimax_profiles/"+filename+".tres")

func delete_minimax_profile(profile : MinimaxProfile) -> void:
	minimax_profiles.erase(profile)
	DirAccess.remove_absolute("user://minimax_profiles/"+profile.profile_name.validate_filename()+".tres")

func load_minimax_profile(path : String) -> MinimaxProfile:
	return ResourceLoader.load("user://minimax_profiles/"+path)

func _ready() -> void:
	if DirAccess.dir_exists_absolute("user://minimax_profiles") == false:
		DirAccess.make_dir_absolute("user://minimax_profiles")
	
	if DirAccess.dir_exists_absolute("user://tournament_results") == false:
		DirAccess.make_dir_absolute("user://tournament_results")
	
	_save_default_minimax_profiles()
	_load_settings()
	_load_minimax_profiles()

func is_tournament() -> bool:
	return tournament_games_left != -1

func _load_settings() -> void:
	if FileAccess.file_exists("user://settings.tres") == false:
		saved_selections = SavedSelections.new()
		save_settings()
	else:
		saved_selections = ResourceLoader.load("user://settings.tres")

func _save_default_minimax_profiles() -> void:
	var easy_filename := EASY_MINIMAX_PROFILE.profile_name.validate_filename()+".tres"
	var medium_filename := MEDIUM_MINIMAX_PROFILE.profile_name.validate_filename()+".tres"
	var hard_filename := HARD_MINIMAX_PROFILE.profile_name.validate_filename()+".tres"
	
	if FileAccess.file_exists("user://minimax_profiles/"+easy_filename) == false:
		ResourceSaver.save(EASY_MINIMAX_PROFILE,"user://minimax_profiles/"+easy_filename)
	if FileAccess.file_exists("user://minimax_profiles/"+medium_filename) == false:
		ResourceSaver.save(MEDIUM_MINIMAX_PROFILE,"user://minimax_profiles/"+medium_filename)
	if FileAccess.file_exists("user://minimax_profiles/"+hard_filename) == false:
		ResourceSaver.save(HARD_MINIMAX_PROFILE,"user://minimax_profiles/"+hard_filename)
	
	
func save_settings() -> void:
	ResourceSaver.save(saved_selections,"user://settings.tres")

func get_minimax_name_index(nomen : String) -> int:
	for p in range(len(minimax_profiles)):
		if minimax_profiles[p].profile_name == nomen:
			return p
	return -1
