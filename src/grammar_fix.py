import nltk
import math
import pandas as pd
from scipy.special import logsumexp
import numpy as np

# convert rule string to list of symbols. also replace UNKs with LEX 
def Convert(string):
    l = list(string.split(" "))
    l.remove('') # just because after the first node there is two whitespaces
    l_no_UNK = []
    for symb in l:
        if symb == "_UNK":
            l_no_UNK.append('LEX')
        else:
            l_no_UNK.append(symb)

    return l_no_UNK

## taking in a df, d with columns log_prob and rule. This returns a df with the
#  same columns but UNK has been changed to LEX, duplicate rules have been 
#  removed, and the removed log_probs have been logaddexp'ed back across the 
#  rules to keep the probability distribution intact 
def unks_to_lex(d): 
    # using convert() to make rule lists and replace UNK with LEX
    for i in range(len(d)):
        d.at[i, 'rule'] = Convert(d.at[i, 'rule'])

    # look for duplicates 
    unique_rules = []
    l_probs = []
    dict_duplicate_probs = {'CP': [], 'IP': [], 'NP': [], 'PP': [], 'VP': []}
    d_rule_tracker = {'CP': 0, 'IP': 0, 'NP': 0, 'PP': 0, 'VP': 0, 
                  'LEX': 0, 'START': 0}
    rem_lex_prob = None # setting it to None because in the case of 0 noise we wont have a LEX --> LEX rule to remove
    for i in range(len(d)):
        r = d.at[i, 'rule']
        p = d.at[i, 'log_prob']
        if r == ['LEX', 'LEX']:
            rem_lex_prob = p # remove the LEX --> LEX rule by not adding it to the new rules list. but we keep the log_prob in order to adjust the LEX rules
        elif r not in unique_rules:
            unique_rules.append(r)
            l_probs.append(p)
            d_rule_tracker[r[0]] = d_rule_tracker[r[0]] + 1 # counting the total num of rules for each nonterminal
        else:
            dict_duplicate_probs[r[0]].append(p) # list of probabilites of the removed duplicates

    # defining our dictionary of constants that will be added to each rule (based on the nonterminal key). the first if else is just to handle the case of 0 noise when we don't need to do any LEX smoothing 
    if rem_lex_prob:
        d_prob_constant = {'LEX': (rem_lex_prob - np.log(d_rule_tracker['LEX']))} # starting with our LEX constant because of the removed LEX --> LEX rule
    else:
        d_prob_constant = {}
    for key in dict_duplicate_probs.keys():
        if not dict_duplicate_probs[key]: # if the list is empty (i.e. there were no duplicate rules for this rule expansion)
            pass # we won't have a constant to add to these rules. logsumexp([]) was raising an error
        else:
            d_prob_constant[key] = (logsumexp(dict_duplicate_probs[key]) -
                                    np.log(d_rule_tracker[key]))
        
    smoothed_probs = []
    for i,num in enumerate(l_probs):
        nonterminal = unique_rules[i][0]
        if nonterminal in d_prob_constant.keys():
            smoothed_probs.append(np.logaddexp(num, d_prob_constant[nonterminal]))
        else:
            smoothed_probs.append(num)

    df = pd.DataFrame(list(zip(smoothed_probs,unique_rules)), 
                    columns=['log_prob','rule'])
    
    return df

# function that loads in the data, applies our helper functions, and writes the 
# output df (with all possible expansions) to rank1 grammar 
def smoothing(prob_label, run_num): 
    ### reading csv and formatting the df
    sub_path = "tokens_noise_" + str(prob_label) + "_" + str(run_num) 
    path = ("../data/" + sub_path + "_grammar1.csv")
    d = pd.read_csv(path)

    # updated grammar removing the UNKs
    d = unks_to_lex(d) 
        
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

    ### smoothing 
    c = min(list(d.log_prob)) - np.log(2) # our new low probability rules are simply half the probability of the lowest probability 

    # adding our c constant to all the non-LEX rules (because LEX is not in the list of all possible rules)
    for i in range(len(d)):
        if not d.at[i, 'rule'][0] == 'LEX': 
            d.at[i, 'log_prob'] = np.logaddexp(d.at[i, 'log_prob'], c) 

    # all the new_rules get log_prob of c
    d1 = {'log_prob': c, 'rule': list(new_rules)}
    df = pd.DataFrame(data=d1)       

    d = pd.concat([d, df], ignore_index=True)

    # renormalize
    d['lhs'] = d['rule'].map(lambda r: r[0])

    d_lnz = d.groupby('lhs').aggregate(lnz = ('log_prob', lambda p: 
                                        logsumexp(p.to_list()))).reset_index()
    d = d.merge(d_lnz, on='lhs')

    d['log_prob'] = d['log_prob'] - d['lnz']


    # # now getting a final text file
    for i in range(len(d)):
        d.at[i, 'rule'] = " ".join(d.at[i, 'rule'])


    # test that the rules for a certain nonterminal sums to one
    log_probs_test = []
    rules_test = []
    for i,num in enumerate(d.log_prob):
        if d['lhs'][i] == 'IP':
            log_probs_test.append(num)
            rules_test.append(d.rule[i])
    print(math.exp(logsumexp(log_probs_test)))


    # rank 1 grammar 
    fin_path = ("../fg-source-code-restore/out/" + sub_path +
                "/" + sub_path + ".0.FG-output.rank-1.txt")
    d[['log_prob', 'rule']].to_csv(fin_path, header=False, index=False,sep='\t',
                                    mode='a')

# # # full automated model multiple runs
# # def main(p_label, num_runs):
# #     for i in range(num_runs):
# #         smoothing(p_label, i+1)

# running into some problems with the full automated run when the FG learning 
# runs in parallel. I've added this code so that I can run the model one run 
# at a time
def main(prob_label, num_run):
    smoothing(prob_label, num_run)

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
