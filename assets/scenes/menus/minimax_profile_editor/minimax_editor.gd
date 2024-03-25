extends VBoxContainer

signal profile_completed(profile : MinimaxProfile)

@onready var profile_name_edit: LineEdit = $ProfileNameEdit

@onready var move_sorting_option_button: OptionButton = $MoveSortingOptionButton
@onready var cutoff_spin_box: SpinBox = $CutoffSpinBox
@onready var timeout_spin_box: SpinBox = $TimeoutSpinBox
@onready var interval_spin_box : SpinBox = $IntervalSpinBox

@onready var turn_lookahead_checkbox: CheckBox = $TurnLookaheadCheckbox

@onready var victory_utility_spin_box: SpinBox = $EvaluationsContainer/VBoxContainer/VictoryUtilitySpinBox
@onready var defeat_utility_spin_box: SpinBox = $EvaluationsContainer/VBoxContainer/DefeatUtilitySpinBox
@onready var draw_utility_spin_box: SpinBox = $EvaluationsContainer/VBoxContainer/DrawUtilitySpinBox

@onready var pieces_left_utility_spin_box: SpinBox = $EvaluationsContainer/VBoxContainer/PiecesLeftUtilitySpinBox
@onready var pieces_on_board_utility_spin_box: SpinBox = $EvaluationsContainer/VBoxContainer/PiecesOnBoardUtilitySpinBox
@onready var checkers_on_board_utility_spin_box: SpinBox = $EvaluationsContainer/VBoxContainer/CheckersOnBoardUtilitySpinBox

@onready var guerilla_threatened_checkers_utility_spin_box: SpinBox = $EvaluationsContainer/VBoxContainer/GuerillaThreatenedCheckersUtilitySpinBox
@onready var edge_threatened_checkers_utility_spin_box: SpinBox = $EvaluationsContainer/VBoxContainer/EdgeThreatenedCheckersUtilitySpinBox
@onready var threatened_guerilla_pieces_utility_spin_box: SpinBox = $EvaluationsContainer/VBoxContainer/ThreatenedGuerillaPiecesUtilitySpinBox

@onready var guerilla_pieces_between_checker_corners_utility_spinbox : SpinBox = $EvaluationsContainer/VBoxContainer/GuerillaPiecesBetweenCheckerCornersUtilitySpinbox
@onready var coin_checkers_taken_utility_spin_box : SpinBox = $EvaluationsContainer/VBoxContainer/COINCheckersTakenUtilitySpinBox
@onready var blocked_coin_checker_movements_utility_spinbox: SpinBox = $EvaluationsContainer/VBoxContainer/BlockedCOINCheckerMovementsUtilitySpinbox

func clear() -> void:
	profile_name_edit.clear()
	move_sorting_option_button.selected = -1
	cutoff_spin_box.value = 1
	timeout_spin_box.value = 5000
	turn_lookahead_checkbox.button_pressed = false
	
	victory_utility_spin_box.value = 100
	defeat_utility_spin_box.value = -100
	draw_utility_spin_box.value = 0
	
	pieces_left_utility_spin_box.value = 0
	pieces_on_board_utility_spin_box.value = 1
	checkers_on_board_utility_spin_box.value = -11
	
	guerilla_threatened_checkers_utility_spin_box.value = 0
	edge_threatened_checkers_utility_spin_box.value = 0
	threatened_guerilla_pieces_utility_spin_box.value = 0
	
	guerilla_pieces_between_checker_corners_utility_spinbox.value = 0
	coin_checkers_taken_utility_spin_box.value = 0
	blocked_coin_checker_movements_utility_spinbox.value = 0
	
func load_profile(profile : MinimaxProfile):
	profile_name_edit.text = profile.profile_name
	move_sorting_option_button.selected = profile.move_sorting
	cutoff_spin_box.value = profile.cutoff_depth
	timeout_spin_box.value = profile.timeout
	turn_lookahead_checkbox.button_pressed = profile.turn_lookahed
	interval_spin_box.value = profile.utility_interval
	
	victory_utility_spin_box.value = profile.victory_utility
	defeat_utility_spin_box.value = profile.defeat_utility
	draw_utility_spin_box.value = profile.draw_utility
	pieces_left_utility_spin_box.value = profile.pieces_left_utility
	
	pieces_on_board_utility_spin_box.value = profile.pieces_on_board_utility
	checkers_on_board_utility_spin_box.value = profile.checkers_utility
	
	guerilla_threatened_checkers_utility_spin_box.value = profile.guerilla_threatened_checkers_utility
	edge_threatened_checkers_utility_spin_box.value = profile.edge_threatened_checkers_utility
	threatened_guerilla_pieces_utility_spin_box.value = profile.threatened_guerilla_pieces_utility
	
	guerilla_pieces_between_checker_corners_utility_spinbox.value = profile.guerilla_pieces_between_coin_checkers_utility
	coin_checkers_taken_utility_spin_box.value = profile.coin_checkers_taken_utility
	blocked_coin_checker_movements_utility_spinbox.value = profile.blocked_coin_checker_movements_utility
	
func _on_confirm_button_pressed():
	if profile_name_edit.text.validate_filename() == "":
		return
	
	if move_sorting_option_button.selected == -1:
		return
	
	var new_profile := MinimaxProfile.new()
	
	new_profile.profile_name = profile_name_edit.text
	new_profile.cutoff_depth = int(cutoff_spin_box.value)
	new_profile.move_sorting = move_sorting_option_button.selected
	new_profile.timeout = timeout_spin_box.value
	new_profile.utility_interval = interval_spin_box.value
	
	new_profile.turn_lookahed = turn_lookahead_checkbox.button_pressed
	
	new_profile.victory_utility = victory_utility_spin_box.value
	new_profile.defeat_utility = defeat_utility_spin_box.value
	new_profile.draw_utility = draw_utility_spin_box.value

	new_profile.pieces_left_utility = pieces_left_utility_spin_box.value
	new_profile.pieces_on_board_utility = pieces_on_board_utility_spin_box.value
	new_profile.checkers_utility = checkers_on_board_utility_spin_box.value
	
	new_profile.guerilla_threatened_checkers_utility = guerilla_threatened_checkers_utility_spin_box.value
	new_profile.edge_threatened_checkers_utility = edge_threatened_checkers_utility_spin_box.value
	new_profile.threatened_guerilla_pieces_utility = threatened_guerilla_pieces_utility_spin_box.value
	
	new_profile.guerilla_pieces_between_coin_checkers_utility = guerilla_pieces_between_checker_corners_utility_spinbox.value
	new_profile.coin_checkers_taken_utility = coin_checkers_taken_utility_spin_box.value
	new_profile.blocked_coin_checker_movements_utility = blocked_coin_checker_movements_utility_spinbox.value
	
	profile_completed.emit(new_profile)

func _on_cancel_button_pressed() -> void:
	profile_completed.emit(null)
