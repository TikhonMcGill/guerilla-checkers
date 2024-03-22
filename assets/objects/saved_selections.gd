extends Resource

class_name SavedSelections

const HUMAN_PLAYER : String = "MAN"
const RANDOM_PLAYER : String = "RND"
const UTILITY_PLAYER : String = "UCP"
const MINIMAX_PLAYER : String = "MMX"

@export var guerilla_player_name : String = "The Guerilla"
@export var coin_player_name : String = "The Counterinsurgent"

@export var guerilla_player_type : String = HUMAN_PLAYER
@export var coin_player_type : String = HUMAN_PLAYER

@export var tournament : bool = false
@export var tournament_games : int = 2
@export var rapid_tournament : bool = false
