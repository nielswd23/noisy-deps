from nltk import word_tokenize
import os

### Intro ###
# When testing the FG model, need to make sure the test items do not include
# unseen lexical items- the model cannot parse these items. Thus we replace 
# any unseen lexical items in the testing stimuli with the special item, WUG.
### Intro ###


# pull out unique lexical items with paths to forms file
def extract_lex_items(forms_path):
    with open(forms_path, 'r') as file:
        l = file.readlines()

        flat_tokenize = [item for seq in l for item in word_tokenize(seq)]

        unique_lex = []
        for i,token in enumerate(flat_tokenize):
                if token == "LEX" and flat_tokenize[i+1] not in unique_lex:
                     unique_lex.append(flat_tokenize[i+1])
        
        return unique_lex


### load in stimuli files ###
# function that takes in a file path, output path, and list of unique lex items. writes the new WUGed stimuli list to output path based on the list
def add_wug(input_path, output_path, unique_lex): 
    with open(input_path, "r") as file:
        stim_file = file.readlines()

    stim_tokenize = [word_tokenize(seq) for seq in stim_file]
    for seq in stim_tokenize:
        for i,token in enumerate(seq):
            if token == "LEX" and (seq[i+1] not in unique_lex and seq[i+1] != "<"):
                seq[i+1] = "<WUG>"

    def l_to_seq(l):
        return "".join([str(i) for i in l])

    new_stim = []
    for l in stim_tokenize:
        new_stim.append(l_to_seq(l))

    def add_spaces(string):
        prev_c = ''
        space_points = []
        for i,c in enumerate(string):
            if prev_c == '':
                prev_c = c
            elif ((c == "(" and (prev_c == ")" or prev_c.isupper())) 
                or (prev_c == "X" and (c == "'" or c.islower() or c == "<") )):
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

    stimuli = [add_spaces(i) for i in new_stim]

    with open(output_path, "w") as f: 
        for item in stimuli:
            f.write("%s\n" % item)


### function that takes in random parameter and trial number and creates relevant stimuli sets ###
def create_stimuli_set(p_label, run_num): 
    # getting list of unique lex items
    sub_path = "tokens_noise_" + str(p_label) + "_" + str(run_num) 
    path = ("/Users/niels/Desktop/FG_project/noise_project/fg-source-code-" +
        "restore/data/" + sub_path + "/" + sub_path + ".forms.txt")
    l_lex = extract_lex_items(path)

    ## pearl sprouse stim ##
    # create a folder for new stimuli
    id_str = str(p_label) + "_" + str(run_num)
    start_path = "/Users/niels/Desktop/FG_project/noise_project/stimuli/"
    os.makedirs(start_path + "tokens_noise_ps_" + id_str, exist_ok=True)

    # adjunct 
    add_wug(start_path + "pearl_stim/pearl_stim_adjunct_emb_is.txt",
            start_path + "tokens_noise_ps_" + id_str + "/pearl_stim_adjunct_emb_is.txt",
            l_lex)
    add_wug(start_path + "pearl_stim/pearl_stim_adjunct_emb_nonis.txt",
            start_path + "tokens_noise_ps_" + id_str + "/pearl_stim_adjunct_emb_nonis.txt",
            l_lex)
    # matrix 
    add_wug(start_path + "pearl_stim/pearl_stim_matrix.txt",
            start_path + "tokens_noise_ps_" + id_str + "/pearl_stim_matrix.txt",
            l_lex)
    # NP
    add_wug(start_path + "pearl_stim/pearl_stim_np_emb_is.txt",
            start_path + "tokens_noise_ps_" + id_str + "/pearl_stim_np_emb_is.txt",
            l_lex)
    add_wug(start_path + "pearl_stim/pearl_stim_np_emb_non_is.txt",
            start_path + "tokens_noise_ps_" + id_str + "/pearl_stim_np_emb_non_is.txt",
            l_lex)
    # subject 
    add_wug(start_path + "pearl_stim/pearl_stim_subj_emb_is.txt",
            start_path + "tokens_noise_ps_" + id_str + "/pearl_stim_subj_emb_is.txt",
            l_lex)
    add_wug(start_path + "pearl_stim/pearl_stim_subj_emb_nonis.txt",
            start_path + "tokens_noise_ps_" + id_str + "/pearl_stim_subj_emb_nonis.txt",
            l_lex)
    # whether 
    add_wug(start_path + "pearl_stim/pearl_stim_whether_emb_is.txt",
            start_path + "tokens_noise_ps_" + id_str + "/pearl_stim_whether_emb_is.txt",
            l_lex)
    add_wug(start_path + "pearl_stim/pearl_stim_whether_emb_nonis.txt",
            start_path + "tokens_noise_ps_" + id_str + "/pearl_stim_whether_emb_nonis.txt",
            l_lex)


    ## liu stim ##
    # bridge
    add_wug(start_path + "liu_stim/liu_bridge.txt",
            start_path + "tokens_noise_ps_" + id_str + "/liu_bridge.txt",
            l_lex)

    # factive
    add_wug(start_path + "liu_stim/liu_factive.txt",
            start_path + "tokens_noise_ps_" + id_str + "/liu_factive.txt",
            l_lex)

    # manner
    add_wug(start_path + "liu_stim/liu_manner.txt",
            start_path + "tokens_noise_ps_" + id_str + "/liu_manner.txt",
            l_lex)

    # other
    add_wug(start_path + "liu_stim/liu_other.txt",
            start_path + "tokens_noise_ps_" + id_str + "/liu_other.txt",
            l_lex)

    ## de villiers stim ##
    os.makedirs(start_path + "tokens_noise_dev_" + id_str, exist_ok=True)

    # ld
    add_wug(start_path + "devilliers_stim/devillier_stim_ld_wug.txt",
            start_path + "tokens_noise_dev_" + id_str + "/dev_ld.txt",
            l_lex)

    # sd
    add_wug(start_path + "devilliers_stim/devillier_stim_sd_wug.txt",
            start_path + "tokens_noise_dev_" + id_str + "/dev_sd.txt",
            l_lex)

def main(prob_label, num_runs):
    for i in range(num_runs):
        create_stimuli_set(prob_label, i+1)
    

if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(
        description = "Creating the testing stimuli."
    )
    parser.add_argument(
        'arg_prob_label', type=int, help='Num used to label the prob in file names. Can do 10X prob so if prob is 0.4 then label is 4.' 
    )
    parser.add_argument(
        'arg_num_runs', type=int, help='Number of times to run the model and producing separate data files for each run.' 
    )
    args = parser.parse_args()
    main(args.arg_prob_label, args.arg_num_runs)
