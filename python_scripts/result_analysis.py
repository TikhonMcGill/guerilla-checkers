import pandas as pd

TOTAL_GAMES_LABEL = "Total Games"
TOURNAMENT_TIME_LABEL = "Tournament Time (ms)"
GUERILLA_BRANCHING_FACTOR_LABEL = "Mean Guerilla Branching Factor"
COIN_BRANCHING_FACTOR_LABEL = "Mean COIN Branching Factor"

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

dataset = pd.read_csv(EVAL_FUNCTION_PATH)