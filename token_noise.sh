# add noise to stimuli
python /Users/niels/Desktop/FG_project/noise_project/noisy_input_tokens.py $1 $2 $3

# now leaning a FG on created stimuli
cd ~/Desktop/FG_project/noise_project/fg-source-code-restore/
python /Users/niels/Desktop/FG_project/noise_project/fg_learn_command.py $2 $3

# R grammar fix to format the grammar output
cd ..
Rscript grammar_fix.R $2 $3
