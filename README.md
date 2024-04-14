# EVALUATING PERFORMANCE OF DIFFERENT PARAMETERS OF A MINIMAX AI PLAYING GUERILLA CHECKERS

## 1 - Introduction

This Repository contains Implementation Code, as well as Experimental Results, for my 2024 Heriot-Watt Honors Project,
the aim of which was to digitize Guerilla Checkers, a Board Game designed by Brian Train in 2010, and then implement a Minimax
AI for it, testing its parameters using a Tournament Infrastructure.

The implementation was done using Godot 4.2.1, and the folder of the Repository, when downloaded, can be loaded into Godot and edited.

There are 4 Player Types developed:
1. Human Player - this is a Player that takes moves using a Graphical Representation of the Board
2. Random Player - this Player takes completely random moves (useful for debugging or training, perhaps)
3. Utility Computer Player - this Player, based on a Hardcoded Function and with no Lookahead, picks the move which leads to the highest utility. Its purpose was to act as a Baseline measure of Performance for Minimax Players.
4. Minimax Player - this Player uses a Minimax Algorithm to select moves. It has customizable Depth Lookahead (1 to 10), a choice of Move Sorting Function, and very many customizable parameters to the evaluation function. Minimax Players play using a "Minimax Profile", a customizable resource, 
saved on disk, which holds the parameters of the Minimax. By default, there are no Minimax Profiles, so one has to be created before use. I uploaded
the Minimax Profiles I used in my experiment into the "minimax_profiles" folder - move its contents into the Guerilla Checkers Minimax Profile folder (on Windows, User/YOUR_USERNAME/Appdata/Roaming/Guerilla Checkers/minimax_profiles). There is a Minimax Profile Editor Interface, but it provides no explanation of the parameters - for that, see the commented code of the Minimax Profile Script in the Godot Project.

### 1.1 - The Godot Project

This Repository contains the "project.godot" file, which can be opened using the Godot Game Engine. I used Godot 4.2.1, but future
versions shouldn't be an issue (Godot is quite backwards-compatible - not sure what will happen when Godot 5 comes out).

### 1.2 - CSV Results

In the "csv_results" folder is a collection of CSVs containing results that I used in my Thesis Discussion. 

### 1.3 - Python Scripts

I did not develop a complex system for saving Tournament Results in Godot - at the end of a Rapid Tournament (See Section 2), you can
press a "Save Results to File" Button, which will save the results to a Text File in your User folder (on Windows, Users/YOUR_USERNAME/Appdata/Roaming/Guerilla Checkers/tournament_results).

There are, therefore, Python scripts for working with the results, in the "python_scripts" folder.

"result_conversion.py" takes a folder of these text files and converts them into a CSV, for easier analysis.

"result_analysis.py" contains a host of helper methods that I used in my dissertation for analysis - they might be of use in future implementations, and
are decently commented.

### 1.4 - Minimax Profiles

The Different Configurations of Minimax that I used for the experiment are in the "minimax_profiles" folder - to use them, launch the Project once, 
and then go to your User folder (on Windows, Users/YOUR_USERNAME/Appdata/Roaming/Guerilla Checkers/), and copy the "minimax_profiles" folder into them. 

Then, restart the Application, and you should have the Minimax Profiles show up! You can then select them by choosing one of your players to be a Minimax
Player, and then choosing a Profile for them.

## 2 - Rapid Tournaments

In the Implementation, two players can play a "Tournament" against each other, which is a repeated number of games (the number of games is set by the User), with a final tally at the end. Sides do not swap in a Tournament. 

There are Regular Tournaments, which play through the game slowly, animating every move, before providing a final tally. These also allow a Human Player
to participate.

Then there are "Rapid Tournaments". They can only be played between two non-Human Players, and what makes them useful is that they forgo animations, playing as quickly as possible (hence Rapid Tournaments). At the end, there is a tally of results, *which can also be saved as a text file*, more
useful than regular tournaments. 

To activate Rapid Tournaments, have 2 Non-Human Players, toggle "Activate Tournament Mode" in the Main Menu before running the Game, and then toggle "Rapid Play", and press "Play".