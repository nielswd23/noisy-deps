import os 

def main(p_label, num_runs):
    command = ("sh best.sh ~/Desktop/FG_project/noise_project/fg-" + 
    "source-code-restore tokens_noise_" + str(p_label) + "_")

    # for i in range(num_runs): 
    #     os.system(command + str(i+1))
    l = [(command + str(i+1)) for i in range(num_runs)]
    full_com = " & ".join(l) 
    os.system(full_com)

if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(
        description = "Command to learn FG."
    )
    parser.add_argument(
        'arg_prob_label', type=int, help='Num used to label the prob in file names. Can do 10X prob so if prob is 0.4 then label is 4.' 
    )
    parser.add_argument(
        'arg_num_runs', type=int, help='Number of times to run the model and producing separate data files for each run.' 
    )
    args = parser.parse_args()
    main(args.arg_prob_label, args.arg_num_runs)