extends Node

enum PLAYER_TYPE {HUMAN,RANDOM,UTILITY,MINIMAX}

var guerilla_player_type : PLAYER_TYPE = PLAYER_TYPE.HUMAN
var coin_player_type : PLAYER_TYPE = PLAYER_TYPE.HUMAN

var guerilla_player_name : String = "The Guerilla"
var coin_player_name : String = "The Counterinsurgent"

var minimax_profiles : Array[MinimaxProfile]

func save_minimax_profile(profile : MinimaxProfile) -> void:
	var filename := profile.profile_name.validate_filename()
	ResourceSaver.save(profile,"user://minimax_profiles/"+filename+".tres")

func _ready() -> void:
	if DirAccess.dir_exists_absolute("user://minimax_profiles") == false:
		DirAccess.make_dir_absolute("user://minimax_profiles")

