extends Node

enum PLAYER_TYPE {HUMAN,RANDOM,UTILITY,MINIMAX}

var guerilla_player_type : PLAYER_TYPE = PLAYER_TYPE.HUMAN
var coin_player_type : PLAYER_TYPE = PLAYER_TYPE.HUMAN

var guerilla_player_name : String = "The Guerilla"
var coin_player_name : String = "The Counterinsurgent"

var minimax_profiles : Array[MinimaxProfile]

var guerilla_minimax_profile : MinimaxProfile = null
var coin_minimax_profile : MinimaxProfile = null

var tournament_games_left : int = -1

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
	
	_load_minimax_profiles()

func is_tournament() -> bool:
	return tournament_games_left != -1
