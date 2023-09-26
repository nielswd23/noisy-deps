# add noise to stimuli
python /Users/niels/Desktop/FG_project/noise_project/noisy_input_tokens.py $1 $2 $3

# now leaning a FG on created stimuli
cd ~/Desktop/FG_project/noise_project/fg-source-code-restore/
python /Users/niels/Desktop/FG_project/noise_project/fg_learn_command.py $2 $3

# R formating the grammar output to make reading in python easier
cd ..
Rscript grammar_format.R $2 $3

# adding smoothed rules to grammar output and adding this file back into the FG folder
python /Users/niels/Desktop/FG_project/noise_project/grammar_fix.py $2 $3 
