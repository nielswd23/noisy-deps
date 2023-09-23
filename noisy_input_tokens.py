from nltk import word_tokenize
import random
import os
import numpy as np 
import argparse


## loading the child directed wh dependencies
with open(r"./dependencies/seq.forms.txt") as file:
    seq = file.readlines()

with open(r"./dependencies/seq.counts.txt") as file:
    counts = file.readlines()

# defining raw input to work with tokens
raw_input = []
for i,num in enumerate(counts):
    raw_input.extend([seq[i]] * int(num))

l_tokenize = [word_tokenize(seq) for seq in raw_input]


## code for adding noise to the input  
list_of_dicts = [] # creates a dictionary that has the indices for the lexical items as the key and the value is which number lexical item for that dependency item (this is reversed. So it is how far away it is from the last lexical item). So we could have a dictionary like {5:2, 11:1} meaning there's a lexical item in the list with index 5 and it's one away from the last lexical item. This is because we are modeling the recency effect where we want the most remebered item to be last
for i,l in enumerate(l_tokenize):
    dict = {}
    n = 1
    for m,token in reversed(list(enumerate(l))):
        if token == "LEX":
            dict[m+1] = n
            n += 1
    list_of_dicts.append(dict)


def full_add_unks(list_tok, a): # taking in the full list_tok (list of lists where each item is a token list) and a parameter and returning the add unk list of lists and all the probabilities so that we can get an average
    probs = []
    total_lex_item_num = 0
    lex_to_unk_num = 0 # these two are just to track how many lexical items we switched to unknown
    for i,l in enumerate(list_tok):
        for key in list_of_dicts[i]:
            n = list_of_dicts[i][key]
            if random.random() > (n+1)**-a: # so as n increases (the farther we are from the last lexical item) this second term gets smaller and smaller making the random number more likely to be greater than it. Thus making it more likely to add a UNK
                list_tok[i][key] = "UNK"
                probs.append((n+1)**-a)
                lex_to_unk_num += 1
                total_lex_item_num += 1
            else:
                probs.append((n+1)**-a)
                total_lex_item_num += 1
    return np.mean(probs), list_tok, (lex_to_unk_num/total_lex_item_num) # first number is an average remembering probability


## code for reformatting resulting stimuli list
def l_to_seq(l):
    return "".join([str(i) for i in l])

def add_spaces(string):
    prev_c = ''
    space_points = []
    for i,c in enumerate(string):
        if prev_c == '':
            prev_c = c
        elif ((c == "(" and (prev_c == ")" or prev_c.isupper())) 
            or (prev_c == "X")): # got rid of more criteria because i think the only capital X in the input should be LEX. but does make me a bit nervous. other criteria: and (c == "'" or c.islower())
            space_points.append(i)
            prev_c = c 
        else:
            prev_c = c

    prev_n = 0
    seq = ""
    for n in space_points:
        seq = seq + string[prev_n:n] + " " 
        prev_n = n

    return seq + string[space_points[-1]:]


## now running the noise porcess over the stimuli and reformatting
def main(prob, p_label, run_num):
    mean_remember_prob,l_unks,forget_prob = (
        full_add_unks(l_tokenize,prob))
    # at a = 0 our remembering prob is 1 because we remember everything. As a increases we get higher and higher forgetting as the memory prob decreases
    print(f'Proportion of forgotten lexical items: {forget_prob}') # nice to keep track of the proportion of removed lexical items

    str_seq_unks = []
    for l in l_unks:
        str_seq_unks.append(l_to_seq(l))

    stimuli = [add_spaces(i) for i in str_seq_unks]


    ## creating new forms and counts files
    def CountFrequency(my_list):    
        # Creating an empty dictionary  
        count = {} 
        for i in my_list: 
            count[i] = count.get(i, 0) + 1
        return count 

    seq_frequency_dict = CountFrequency(stimuli) 
    noisy_forms = seq_frequency_dict.keys()
    noisy_counts = seq_frequency_dict.values() 

    # now create folder to run FG model and populate folders with forms and counts txt files
    label = "tokens_noise_" + str(p_label) + "_" + str(run_num)
    folder_path = ("/Users/niels/Desktop/FG_project/noise_project/" + 
                "fg-source-code-restore/data/" + label + "/")

    os.makedirs(folder_path, exist_ok=True)

    with open(folder_path + label + ".forms.txt", "w") as f: 
        for item in noisy_forms:
            f.write("%s\n" % item)

    with open(folder_path + label + ".counts.txt", "w") as f: 
        for item in noisy_counts:
            f.write("%s\n" % item)


## running the model multiple times
def run(prob, p_label, num_runs):
    for i in range(num_runs):
        main(prob, p_label, i+1)

# run(0.4, 40, 3)

## now add dunder syntax
if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(
        description = "Adds an adjustable level of noise to tokens of wh_deps input."
    )
    parser.add_argument(
        'arg_prob', type=float, help='The alpha parameter ranging from 0 to inf. As alpha gets larger the model forgets more.'
    )
    parser.add_argument(
        'arg_prob_label', type=int, help='Num used to label the prob in file names. Can do 10X prob so if prob is 0.4 then label is 4.' 
    )
    parser.add_argument(
        'arg_num_runs', type=int, help='Number of times to run the model and producing separate data files for each run.' 
    )
    args = parser.parse_args()
    run(args.arg_prob, args.arg_prob_label, args.arg_num_runs)