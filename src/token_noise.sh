# produce a json file for our full set of token input data (loading in json file as opposed to 
# producing token stimuli each run is clearly a lot faster)
python deps_tokens.py 

# add noise to stimuli
python noisy_input_tokens.py $1 $2 $3

# now leaning a FG on created stimuli
cd ../fg-source-code-restore/
python ../src/fg_learn_command.py $2 $3

# R formating the grammar output to make reading in python easier
cd ../src
Rscript grammar_format.R $2 $3

# rename rank1 output so that we can generate a new file with smoothed rules
python rename_rank1_output.py $2 $3

# adding smoothed rules to grammar output and adding this file back into the FG folder
python grammar_fix.py $2 $3

# creating our testing stimuli. pulls out the lexical items from the grammar and adds WUG in the stimuli if a word doesn't appear in the grammar
python add_wug.py $2 $3

# testing FG on generated test sets
cd ../fg-source-code-restore/
python ../src/fg_test_command.py $2 $3

# move output files
cd ../src
python move_output_data.py $2 $3

# produce plots
Rscript generate_plots.R $2 $3
