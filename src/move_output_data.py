import os
import shutil

def move_data(p_label, run_num): 
    id_str = "tokens_noise_" + str(p_label) + "_" + str(run_num)
    pl_d_path = "../data/" + id_str + "_pearl_liu"
    extract_subpath = "../fg-source-code-restore/out/" + id_str + "/" + id_str

    # move ps and liu data with a list of file names
    l_files = [".0.pearl_stim_whether_emb_nonis.results.csv",
               ".0.pearl_stim_whether_emb_is.results.csv", 
               ".0.pearl_stim_subj_emb_nonis.results.csv", 
               ".0.pearl_stim_subj_emb_is.results.csv",
               ".0.pearl_stim_np_emb_non_is.results.csv",
               ".0.pearl_stim_np_emb_is.results.csv", 
               ".0.pearl_stim_matrix.results.csv",
               ".0.pearl_stim_adjunct_emb_nonis.results.csv",
               ".0.pearl_stim_adjunct_emb_is.results.csv", 
               ".0.liu_other.results.csv", ".0.liu_manner.results.csv",
               ".0.liu_factive.results.csv", ".0.liu_bridge.results.csv"]
    os.makedirs(pl_d_path, exist_ok=True)
    for file in l_files:
        shutil.move(extract_subpath +file, pl_d_path)

    # move dev data 
    os.makedirs("../data/" + id_str + "_dev", exist_ok=True)
    shutil.move(extract_subpath + ".0.dev_sd.results.csv",
                "../data/" + id_str + "_dev")
    shutil.move(extract_subpath + ".0.dev_ld.results.csv", 
                "../data/" + id_str + "_dev")

# # full automated model multiple runs
# def main(prob_label, num_runs):
#     for i in range(num_runs):
#         move_data(prob_label, i+1)

# running into some problems with the full automated run when the FG learning 
# runs in parallel. I've added this code so that I can run the model one run 
# at a time
def main(prob_label, num_run):
    move_data(prob_label, num_run)

if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(
        description = "Extract a folder of data from the FG output."
    )
    parser.add_argument(
        'arg_prob_label', type=int, help='Num used to label the prob in file names. Can do 10X prob so if prob is 0.4 then label is 4.' 
    )
    parser.add_argument(
        'arg_num_runs', type=int, help='Number of times to run the model and producing separate data files for each run.' 
    )
    args = parser.parse_args()
    main(args.arg_prob_label, args.arg_num_runs)
