import nltk
import pandas as pd
from scipy.special import logsumexp
import numpy as np

def smoothing(prob_label, run_num): 
    ### reading csv and formatting the df
    sub_path = "tokens_noise_" + str(prob_label) + "_" + str(run_num) 
    path = ("~/Desktop/FG_project/noise_project/data/" + sub_path + 
            "_grammar1.csv")
    d = pd.read_csv(path)


    def Convert(string):
        li = list(string.split(" "))
        li.remove('') # just because after the first node there is two whitespaces
        return li

    for i in range(len(d)):
        d.at[i, 'rule'] = Convert(d.at[i, 'rule'])
        

    ### adding additional possible rules and smoothing (to handle unseen strucutres) 
    phrase_labels = []
    for i in range(len(d)):
        for n in range(len(d.at[i, 'rule'])): 
            if (d.at[i, 'rule'][n] not in phrase_labels and 
                not d.at[i, 'rule'][n].startswith("_") and 
                d.at[i, 'rule'][n] != 'START'): # we want to exclude the start symbol even though it appears in the grammar 
                phrase_labels.append(d.at[i, 'rule'][n])
            

    # creating all possible combinations of 3 phrase_labels
    import itertools
    possible_rules = list(itertools.product(phrase_labels, repeat = 3)) # cartesian product from itertools


    rem_rules = []
    for i in range(len(possible_rules)):
        if 'LEX' == possible_rules[i][0] or 'LEX' == possible_rules[i][2]:
            rem_rules.append(possible_rules[i])
        elif list(possible_rules[i]) in list(d.rule):
            rem_rules.append(possible_rules[i])
        
            
    new_rules = [list(i) for i in possible_rules if i not in rem_rules]

    # smoothing 
    c = min(list(d.log_prob)) - np.log(2) # numpy log() is ln()

    for i in range(len(d)):
        if not (len(d.at[i, 'rule']) == 2 and d.at[i, 'rule'][0] == 'LEX' 
                and "_" in d.at[i, 'rule'][1]): 
            d.at[i, 'log_prob'] = np.logaddexp(d.at[i, 'log_prob'], c) 


    d1 = {'log_prob': c, 'rule': list(new_rules)}
    df = pd.DataFrame(data=d1)       

    d = pd.concat([d, df], ignore_index=True)

    A = logsumexp(d.log_prob)
    d['log_prob'] = d['log_prob'] - A

    # now getting a final text file
    def listToString(s): 
        str1 = " " 
        return (str1.join(s))

    for i in range(len(d)):
        d.at[i, 'rule'] = listToString(d.at[i, 'rule'])

    # rank 1 grammar 
    fin_path = ("/Users/niels/Desktop/FG_project/noise_project/" +
                "fg-source-code-restore/out/" + sub_path + 
                "/" + sub_path + ".0.FG-output.rank-1.txt")
    d.to_csv(fin_path, header=False, index=False, sep='\t', mode='a')

def main(p_label, num_runs):
    for i in range(num_runs):
        smoothing(p_label, i+1)


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(
        description = "Adding smoothed rules to FG learned grammar output."
    )
    parser.add_argument(
        'arg_prob_label', type=int, help='Num used to label the prob in file names. Can do 10X prob so if prob is 0.4 then label is 4.' 
    )
    parser.add_argument(
        'arg_num_runs', type=int, help='Number of times to run the model and producing separate data files for each run.' 
    )
    args = parser.parse_args()
    main(args.arg_prob_label, args.arg_num_runs)

 
