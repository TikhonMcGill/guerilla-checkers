import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import textwrap

TOTAL_GAMES_LABEL = "Total Games"
TOURNAMENT_TIME_LABEL = "Tournament Time (ms)"

GUERILLA_VICTORIES_LABEL = "Guerilla Victories"
COIN_VICTORIES_LABEL = "Total COIN Victories"

GUERILLA_BRANCHING_FACTOR_LABEL = "Mean Guerilla Branching Factor"
COIN_BRANCHING_FACTOR_LABEL = "Mean COIN Branching Factor"

GUERILLA_PLAYER_LABEL = "Guerilla Player"
COIN_PLAYER_LABEL = "COIN Player"

MEAN_COIN_VICTORY_TURNS_LABEL = "Mean Turns per COIN Victory"

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

#Get all data entries for games between a specific Guerilla and a Specific COIN
def get_all_specific_games(dataset : pd.DataFrame,guerilla : str,coin:str):
     #Get all Rows where the Guerilla is the one passed in
    my_guerilla_rows = dataset.loc[dataset[GUERILLA_PLAYER_LABEL] == guerilla]
    
    #Return all Rows where the COIN is the one passed in (in my experiment, I only had each type of AI play
    #against each other one once, but this function should work for multiple takes, BUT IS UNTESTED)
    return my_guerilla_rows.loc[my_guerilla_rows[COIN_PLAYER_LABEL] == coin]

#Calculate Advantage Coefficient between two Players in a Dataset
def calculate_advantage_coefficient(dataset : pd.DataFrame,guerilla_player : str,coin_player : str) -> float:
    #In my implementation, AIs don't play against themselves, so if the two players are the same, return 0
    if guerilla_player == coin_player:
        return 0.0

    all_games = get_all_specific_games(dataset,guerilla_player,coin_player)

    #Get total Guerilla Victories, total COIN Victories, and total non-Draw games
    guerilla_victories = all_games[GUERILLA_VICTORIES_LABEL].sum()
    coin_victories = all_games[COIN_VICTORIES_LABEL].sum()

    non_draw_games = guerilla_victories + coin_victories
    #If ARE NO non-draw games (i.e. all games are draws), assume the two opponents are evenly-matched and return 0
    if non_draw_games == 0:
        return 0

    #The Advantage Coefficient = (guerilla victories - coin victories) / non draw games
    #When Advantage Coefficient is 1 or close, the Guerilla did really well, when it's -1 or close, COIN did really well,
    #and if it is around 0, the two players are evenly-matched

    return float(guerilla_victories - coin_victories) / non_draw_games

#Generate a new Dataframe, with rows being Guerilla Players, and columns being COIN Players, with values being advantage
#coefficients
def generate_heatmap_dataframe(dataset : pd.DataFrame) -> pd.DataFrame:
    player_names = dataset[GUERILLA_PLAYER_LABEL].unique()

    #This line of code ensures the label text autowraps for the heatmap
    player_name_labels = []
    for p in player_names:
        new_name = "\n".join(textwrap.wrap(p,20))
        player_name_labels.append(new_name)

    data = []

    for guerilla in player_names:
        new_row = []
        for coin in player_names:
            new_row.append(calculate_advantage_coefficient(dataset,guerilla,coin))
        data.append(new_row)
    
    return pd.DataFrame(data, player_name_labels, player_name_labels)

#Generate a Heatmap, based on the Dataframe
def generate_heatmap(dataset : pd.DataFrame):
    heatmap_data = generate_heatmap_dataframe(dataset)

    plt.subplots(figsize=(10,10))
    plt.subplots_adjust(left=0.3)
    plt.yticks(rotation=45)
    plt.tight_layout()

    ax = sns.heatmap(
        heatmap_data,cmap="bwr", vmin=-1, vmax=1, annot=True,
        square=True,annot_kws={"fontsize":12,"fontweight":"bold"}
    )
    ax.xaxis.tick_top()

dataset = pd.read_csv(MOVE_SORT_PATH)

text = """
    Mean time for a No Sorting Guerilla against UCP: %.1f
    Mean time for a End-Take-Other Guerilla against UCP: %.1f
    Mean time for a By Utility Guerilla against UCP: %.1f
    Mean time for a Random Shuffle Guerilla against UCP: %.1f
    Mean turns for Coin victory (No Sorting against UCP): %.1f
    Mean turns for Coin victory (End-Take-Other against UCP): %.1f
    Mean turns for Coin victory (By Utility against UCP): %.1f
    Mean turns for Coin victory (Random Shuffle against UCP): %.1f

""" % (
    get_all_specific_games(dataset,"No Sorting","Utility Computer Player")[TOURNAMENT_TIME_LABEL].mean(),
    get_all_specific_games(dataset,"End-Take-Other","Utility Computer Player")[TOURNAMENT_TIME_LABEL].mean(),
    get_all_specific_games(dataset,"By Utility","Utility Computer Player")[TOURNAMENT_TIME_LABEL].mean(),
    get_all_specific_games(dataset,"Random Shuffle","Utility Computer Player")[TOURNAMENT_TIME_LABEL].mean(),
    get_all_specific_games(dataset,"No Sorting","Utility Computer Player")[MEAN_COIN_VICTORY_TURNS_LABEL].mean(),
    get_all_specific_games(dataset,"End-Take-Other","Utility Computer Player")[MEAN_COIN_VICTORY_TURNS_LABEL].mean(),
    get_all_specific_games(dataset,"By Utility","Utility Computer Player")[MEAN_COIN_VICTORY_TURNS_LABEL].mean(),
    get_all_specific_games(dataset,"Random Shuffle","Utility Computer Player")[MEAN_COIN_VICTORY_TURNS_LABEL].mean()
)

print(text)