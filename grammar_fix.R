# re formatting rank 1 grammar in order to add all possible rules in python file (no_s_end_grammar_fix.py)

library(tidyverse)
library(reshape2)

# hand coding the file paths
# file_str = "tokens_noise_4_3"

# to automate using command line
args <- commandArgs(trailingOnly = TRUE) 
# args[1] is prob_label
# args[2] is num_runs 


main <- function(prob_labl, run_num) {
  file_str = paste("tokens_noise_", prob_labl, "_", run_num, sep = '')
  # file for rank 1 grammar output from model
  d = read.delim2(paste("~/Desktop/FG_project/noise_project/fg-source-code-restore/out/", 
                        file_str, "/", file_str, ".0.FG-output.rank-1.txt", sep = ''),
                  header = TRUE, col.names = "grammar")
  d <- colsplit(d$grammar," ",c("log_prob","rule"))
  
  # file name of formatted csv
  write.csv(d, paste("~/Desktop/FG_project/noise_project/data/", file_str, 
                  "_grammar1.csv", sep = ''), row.names = FALSE)
}


for (i in 1:args[2]) {
  main(args[1], i)
}





