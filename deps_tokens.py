from nltk import word_tokenize
import json


## loading the child directed wh dependencies
with open(r"./dependencies/seq.forms.txt") as file:
    seq = file.readlines()

with open(r"./dependencies/seq.counts.realistic_counts.txt") as file:
    counts = file.readlines()

# defining raw input to work with tokens
raw_input = []
for i,num in enumerate(counts):
    raw_input.extend([seq[i]] * int(num))

l_tokenize = [word_tokenize(seq) for seq in raw_input]

# writing list to a json file 
with open('deps_tokens.json', 'w') as file:
    json.dump(l_tokenize, file)
