extends Node

class_name Player

signal move_taken(move : Move)

func take_move(move : Move) -> void:
	move_taken.emit(move)
