extends Move

class_name GuerillaPiecePlacementMove

var first_corner : int
var second_corner : int

func _init(_corner_1 : int,_corner_2 : int):
	first_corner = _corner_1
	second_corner = _corner_2
