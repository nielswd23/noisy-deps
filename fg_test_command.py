import os 

def gen_command(p_label, run_num, stim_set):
    sub_path = "~/Desktop/FG_project/noise_project/"
    id_str = "_" + str(p_label) + "_" + str(run_num)
    command = ("for file in " + sub_path + "stimuli/tokens_noise_" + stim_set+
               id_str + "/*.txt ; do sh test.sh " + sub_path + 
               "fg-source-code-restore tokens_noise" + id_str + 
               " \"$file\" ; done")
    return command 

def main(prob_label, num_runs):
    # pearl and liu testing
    ps_l = [gen_command(prob_label, i+1, "ps") for i in range(num_runs)]
    full_ps_com = " & ".join(ps_l) 
    os.system(full_ps_com)

    # de villiers testing
    dev_l = [gen_command(prob_label, i+1, "dev") for i in range(num_runs)]
    full_dev_com = " & ".join(dev_l) 
    os.system(full_dev_com)


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(
        description = "Command to test learned FG."
    )
    parser.add_argument(
        'arg_prob_label', type=int, help='Num used to label the prob in file names. Can do 10X prob so if prob is 0.4 then label is 4.' 
    )
    parser.add_argument(
        'arg_num_runs', type=int, help='Number of times to run the model and producing separate data files for each run.' 
    )
    args = parser.parse_args()
    main(args.arg_prob_label, args.arg_num_runs)