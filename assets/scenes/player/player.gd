extends Node

class_name Player

##A Base Class for all Players

signal move_taken(move : Move) ##Emitted when the Player takes their move

var game_state : GameState ##The State of the Game the Player is looking at

var my_type : GameState.PLAYER ##The type of the player (i.e. whether they're a Guerilla or Counterinsurgent)

func do_move() -> void:
	pass
