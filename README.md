Goal:
Investigating the acquistion of wh-dpendencies under noise constraints. The main learning model is a Fragment Grammar model run on child directed wh-questions with varying levels of noise to remove some proportion of learned lexical items.

Description of repository:
The main bit of code to add noise to child-directed dependency input is the noisy_input_tokens.py file. This script reads the dependency files located in the "dependencies" folder and probabilistically replaces lexical items with a special string that denotes an unseen item, "UNK," and returns dependency files that will get fed into the main FG model. This script takes 3 arguments. The first argument is the alpha parameter, [0,inf), that controls how often the lexical items are removed (higher alpha leads to higher noise). This noise process is modeling the recency effect in that the farther from the end of the utterance, the higher likelihood the lexical item will be removed. The next argument is a label to keep track of the output files. And the last argument is the number of runs controlling how many output files the script will produce.

Another main component of this repository is the shell script, which automates a full run of this model: from the noisy_input_tokens.py to testing the FG model to reformatting the output to producing plots for the results. This script takes in the same arguments as the noisy_input_tokens.py file and can be run from the command line using the following command:
sh token_noise.sh <alpha> <alpha_label> <num runs>
For example, running "sh token_noise.sh 0.05 5 3" would be running the model with low noise level, alpha = 0.05, with an alpha label of 5 for the output files, and with 3 runs of the model (thus 3 separate outputs).

This repository also includes data from [1]Liu et al. (2022) in the data folder. This data is used in producing the final plots in replicating their verb frequency pattern from the model's performance. This file was downloaded from their supplementary materials: https://osf.io/2ydqc/.

This repository does not include the code required to run the FG model [2]. This code was provided by Timothy O'Donnell via personal communication.



Works cited:
[1] Yingtong Liu, Rachel Ryskin, Richard Futrell, and Edward Gibson. 2022. A verb-frame frequency account of
constraints on long-distance dependencies in english. Cognition, 222:104902.

[2] Timothy O’Donnell, Jesse Snedeker, Joshua Tenenbaum, and Noah Goodman. 2011. Productivity and reuse in
language. In Proceedings of the Annual Meeting of the Cognitive Science Society, volume 33.
