import os 

def mv_command(p_label, run_num):
    sub_str = "tokens_noise_" + str(p_label) + "_" + str(run_num)
    path = ("../fg-source-code-restore/out/" + sub_str + "/" + sub_str + 
            ".0.FG-output.rank-1")
    command = "mv " + path + ".txt " + path + "_OLD.txt" 
    return(command)

# # full automated model multiple runs
# def main(prob_label,num_runs):
#     for i in range(num_runs):
#         os.system(mv_command(prob_label,i+1))

# running into some problems with the full automated run when the FG learning 
# runs in parallel. I've added this code so that I can run the model one run 
# at a time
def main(prob_label, num_run):
    os.system(mv_command(prob_label, num_run))


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
