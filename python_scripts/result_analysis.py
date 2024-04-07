import pandas as pd

TOTAL_GAMES_LABEL = "Total Games"
TOURNAMENT_TIME_LABEL = "Tournament Time (ms)"

GUERILLA_VICTORIES_LABEL = "Guerilla Victories"
COIN_VICTORIES_LABEL = "Total COIN Victories"

GUERILLA_BRANCHING_FACTOR_LABEL = "Mean Guerilla Branching Factor"
COIN_BRANCHING_FACTOR_LABEL = "Mean COIN Branching Factor"

GUERILLA_PLAYER_LABEL = "Guerilla Player"
COIN_PLAYER_LABEL = "COIN Player"


DEPTH_CUTOFF_PATH = "D:/Tisha's Files/University (Better Organized)/Year 4/Honors Project/Stage 2 - Dissertation/Experimentation Results/CSV Results/depth_cutoff_results.csv"
EVAL_FUNCTION_PATH = "D:/Tisha's Files/University (Better Organized)/Year 4/Honors Project/Stage 2 - Dissertation/Experimentation Results/CSV Results/eval_function_results.csv"
MOVE_SORT_PATH = "D:/Tisha's Files/University (Better Organized)/Year 4/Honors Project/Stage 2 - Dissertation/Experimentation Results/CSV Results/move_sort_results.csv"

#Calculate total no. games in the Dataset
def calculate_total_games(dataset : pd.DataFrame) -> int:
    return dataset[TOTAL_GAMES_LABEL].sum()

#Calculate total time in milliseconds in the Dataset
def calculate_total_time(dataset : pd.DataFrame) -> int:
    return dataset[TOURNAMENT_TIME_LABEL].sum()

#Calculate mean (mean of means) branching factor for Guerilla and COIN in the Dataset
def calculate_mean_branching_factor(dataset : pd.DataFrame) -> tuple:
    mean_guerilla_factor = dataset[GUERILLA_BRANCHING_FACTOR_LABEL].mean()
    mean_coin_factor = dataset[COIN_BRANCHING_FACTOR_LABEL].mean()

    return mean_guerilla_factor, mean_coin_factor

#Calculate Advantage Coefficient between two Players in a Dataset
def calculate_advantage_coefficient(dataset : pd.DataFrame,guerilla_player : str,coin_player : str) -> float:
    #In my implementation, AIs don't play against themselves, so if the two players are the same, return 0
    if guerilla_player == coin_player:
        return 0.0

    #Get all Rows where the Guerilla is the one passed in
    my_guerilla_rows = dataset.loc[dataset[GUERILLA_PLAYER_LABEL] == guerilla_player]

    #Get all Rows where the COIN is the one passed in (in my experiment, I only had each type of AI play
    #against each other one once, but this function should work for multiple takes, BUT IS UNTESTED)
    my_coin_rows = my_guerilla_rows.loc[my_guerilla_rows[COIN_PLAYER_LABEL] == coin_player]

    #Get total Guerilla Victories, total COIN Victories, and total non-Draw games
    guerilla_victories = my_coin_rows[GUERILLA_VICTORIES_LABEL].sum()
    coin_victories = my_coin_rows[COIN_VICTORIES_LABEL].sum()

    non_draw_games = guerilla_victories + coin_victories

    #The Advantage Coefficient = (guerilla victories - coin victories) / non draw games
    #When Advantage Coefficient is 1 or close, the Guerilla did really well, when it's -1 or close, COIN did really well,
    #and if it is around 0, the two players are evenly-matched

    return float(guerilla_victories - coin_victories) / non_draw_games

dataset = pd.read_csv(EVAL_FUNCTION_PATH)