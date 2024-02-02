extends Player

class_name HumanPlayer

var game_board : GameBoard

var selected_corner : Corner = null;
var selected_tile : Tile = null;

func _process(delta):
	prepare_graphics()

func prepare_graphics():
	if game_state.get_current_player() == my_type:
		if is_guerilla() == true:
			setup_guerilla_graphics()

func setup_guerilla_graphics():
	var placeable_corners = game_state.get_placeable_corners()
	
	for g in range(len(game_board.corners.get_children())):
		var corner : Corner = game_board.corners.get_child(g)
		if g in placeable_corners:
			corner.modulate = game_board.placeable_corner_color
		else:
			corner.modulate = game_board.corner_color

func setup_ui(_board : GameBoard):
	game_board = _board
	
	if is_guerilla() == true:
		game_board.mouse_over_corner.connect(_select_corner)
		game_board.mouse_exit_corner.connect(_deselect_corner)

func _input(event):
	if Input.is_action_just_pressed("left_click") == true and is_my_turn() == true:
		if is_guerilla() == true and selected_corner != null:
			var move = GuerillaPiecePlacementMove.new(game_board.get_corner_index(selected_corner))
			move_taken.emit(move)
			
		#Check for Is Instance Valid with Checker

func _select_corner(corner : Corner):
	if corner.modulate == game_board.placeable_corner_color:
		selected_corner = corner

func _deselect_corner():
	if selected_corner != null:
		selected_corner = null
