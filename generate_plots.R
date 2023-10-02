library(tidyverse)
library(forcats)
library(plotrix) 
library(stringr)
library(ggpubr)
library(patchwork)
library(ggrepel)
library(grid)

# to automate using command line
args <- commandArgs(trailingOnly = TRUE) 
# args[1] is prob_label
# args[2] is num_runs 

main <- function(prob_label, run_num) {
  # loading verb-frame frequency data from liu et al
  setwd("~/Desktop/FG_project/noise_project/data/")
  v_freq = read.csv("frequency_48verbs_unified_osf.csv")
  
  
  model = paste("tokens_noise_", prob_label, "_", run_num, sep = '')
  
  
  
  # loading Liu et al. and Pearl and Sprouse data
  setwd(paste("./", model, "_pearl_liu", sep = ''))
  
  temp = list.files(pattern="*.csv")
  for (i in 1:length(temp)) assign(str_split_fixed(temp[i], "\\.0\\.", 2)[,2], 
                                   read.csv(temp[i])) # lopping off the model run name 
  
  # liu et al stim data
  bridge = liu_bridge.results.csv %>%
    mutate(condition = 'bridge')
  
  factive = liu_factive.results.csv %>%
    mutate(condition = 'factive')
  
  manner = liu_manner.results.csv %>%
    mutate(condition = 'manner')
  
  other = liu_other.results.csv %>%
    mutate(condition = 'other')
  
  d = rbind.data.frame(bridge, factive, manner, other)
  d = d %>% mutate(Sentence = as.character(Sentence)) %>%
    mutate(matrix_verb = word(Sentence, 2), 
           length_factorized = MAPScore / (str_count(as.character(Sentence), ' ') + 1)) 
  
  
  insidescore_w_vfreq = d %>% 
    group_by(matrix_verb, condition) %>%
    dplyr::summarise(InsideScore = mean(InsideScore), 
                     LenFac = mean(length_factorized)) %>% 
    inner_join(v_freq)
  
  
  
  
  ### pearl & sprouse stim data
  # matrix
  matrix_non_is = pearl_stim_matrix.results.csv %>%
    mutate(condition = 'main', island = "non-island structure")
  
  matrix_is = pearl_stim_matrix.results.csv %>%
    mutate(condition = 'main', island = "island structure")
  
  # complex NP
  np_emb_is = pearl_stim_np_emb_is.results.csv %>%
    mutate(condition = 'embedded', island = "island structure")
  
  np_emb_non_is = pearl_stim_np_emb_non_is.results.csv %>%
    mutate(condition = 'embedded', island = "non-island structure")
  
  # subject
  subject_emb_is = pearl_stim_subj_emb_is.results.csv %>%
    mutate(condition = 'embedded', island = "island structure")
  
  subject_emb_non_is = pearl_stim_subj_emb_nonis.results.csv %>%
    mutate(condition = 'embedded', island = "non-island structure")
  
  # adjunct
  adjunct_emb_is = pearl_stim_adjunct_emb_is.results.csv %>%
    mutate(condition = 'embedded', island = "island structure")
  
  adjunct_emb_non_is = pearl_stim_adjunct_emb_nonis.results.csv %>%
    mutate(condition = 'embedded', island = "non-island structure")
  
  # whether
  whether_emb_is = pearl_stim_whether_emb_is.results.csv %>%
    mutate(condition = 'embedded', island = "island structure")
  
  whether_emb_non_is = pearl_stim_whether_emb_nonis.results.csv %>%
    mutate(condition = 'embedded', island = "non-island structure")
  
  
  d_np = rbind.data.frame(matrix_non_is, matrix_is, np_emb_non_is, np_emb_is) %>%
    mutate(length_factorized = MAPScore / (str_count(as.character(Sentence), ' ') + 1))
  d_subj = rbind.data.frame(matrix_non_is, matrix_is, subject_emb_non_is, subject_emb_is) %>%
    mutate(length_factorized = MAPScore / (str_count(as.character(Sentence), ' ') + 1))
  d_adjunct = rbind.data.frame(matrix_non_is, matrix_is, adjunct_emb_non_is, adjunct_emb_is) %>%
    mutate(length_factorized = MAPScore / (str_count(as.character(Sentence), ' ') + 1))
  d_whether = rbind.data.frame(matrix_non_is, matrix_is, whether_emb_non_is, whether_emb_is) %>%
    mutate(length_factorized = MAPScore / (str_count(as.character(Sentence), ' ') + 1))
  
  
  
  
  ### liu plots ###
  # calculating r squared 
  liu_fit <- summary(lm(LenFac ~ log_fre, data = insidescore_w_vfreq))
  liu_fit$r.squared
  
  liu.plot.lenfac <- ggplot(insidescore_w_vfreq, mapping = aes(x = log_fre, y = LenFac)) +
    stat_smooth(method = lm) +
    geom_label(aes(label = matrix_verb)) + # , color = condition 
    annotation_custom(
      grid::textGrob(bquote(~R^2~ "=" ~ .(round(liu_fit$r.squared, 3))), 
                     0.85, 0.1, gp = gpar(col = "black", fontsize = 20))) +
    xlab("Log-transformed frequency of verb frame") +
    ylab("Length Factorized Score") +
    theme_classic() +
    # labs(color = "Verb type") +
    ggtitle("Liu et al. (2022) Stimuli") +
    theme(plot.title = element_text(hjust = 0.5, size = 30),
          axis.text=element_text(size=14),
          axis.title = element_text(size=22))
  
  
  
  
  
  ### Pearl and Sprouse plots ###
  toplot.df <- d_adjunct %>%
    mutate(island_type = 'adjunct') %>%
    rbind(d_np %>%
            mutate(island_type = 'np')) %>%
    rbind(d_subj %>%
            mutate(island_type = 'subj')) %>%
    rbind(d_whether %>%
            mutate(island_type = 'whether')) %>%
    mutate(condition = factor(condition,levels=c('main','embedded'))) %>%
    mutate(island_type = as.character(island_type)) %>%
    mutate(island_type = case_when(island_type == 'np' ~  'Complex NP Island',
                                   island_type == 'subj' ~ 'Subject Island',
                                   island_type == 'whether' ~ 'Whether Island',
                                   island_type == 'adjunct' ~ 'Adjunct Island')) %>%
    mutate(island_type = factor(island_type, levels=c('Complex NP Island','Subject Island','Whether Island','Adjunct Island')))
  
  grid.plot <- toplot.df %>%
    group_by(island_type,condition,island) %>%
    dplyr::summarise(mean_InsideScore = mean(InsideScore),
              stdErr = std.error(InsideScore)) %>%
    ggplot(data=.,aes(x=condition,y=mean_InsideScore,color=island)) +
    geom_point() +
    geom_line(aes(group=island)) +
    geom_errorbar(aes(x=condition, ymin = mean_InsideScore - stdErr, 
                      ymax = mean_InsideScore + stdErr), width=0.1) +
    facet_wrap(~island_type) +
    labs(y='Log Probability',x='Condition',color=element_blank()) +
    theme_classic() +
    theme(legend.position = 'bottom') 
  
  
  grid_len.plot <- toplot.df %>%
    group_by(island_type,condition,island) %>%
    dplyr::summarise(mean_length_factorized = mean(length_factorized), 
                     stdErr = std.error(length_factorized)) %>%
    ggplot(data=.,aes(x=condition,y=mean_length_factorized,color=island)) +
    geom_point() +
    geom_line(aes(group=island)) +
    geom_errorbar(aes(x=condition, ymin = mean_length_factorized - stdErr, 
                      ymax = mean_length_factorized + stdErr), width=0.1) +
    facet_wrap(~island_type) +
    labs(y='Log prob length factorized',x='Condition',color=element_blank()) +
    theme_classic() +
    theme(legend.position = 'bottom') 
  
  
  
  se_2mean <- function(vec) {
    main = sqrt(vec[1]+vec[2])/4
    return(main)
  }
  
  diff_mod_df <- toplot.df %>%
    group_by(island_type,condition,island) %>%
    dplyr::summarise(mean_length_factorized = -mean(length_factorized), 
                     var = var(length_factorized)) %>%
    mutate_all(~replace(., is.na(.), 0)) %>%
    group_by(condition, island_type) %>% 
    dplyr::summarise(diff = -diff(mean_length_factorized), se = se_2mean(var)) 
  
  
  diff_plot <- ggplot(data=diff_mod_df,aes(x=condition, y = diff)) +
    geom_point(aes(y=diff), size = 2, show.legend = F) +
    geom_line(aes(y = diff, group=island_type)) + 
    geom_errorbar(aes(ymin = diff - se, ymax = diff + se), width=0.2) +
    facet_wrap(~island_type) +
    theme_classic() 
  
  
  
  ### De Villiers results ###
  d1 = read.csv(paste("../", model, "_dev/", model, 
                      ".0.dev_ld.results.csv", sep = '')) %>% # for the noise analysis: 
    tibble::rownames_to_column(var = "rowname") %>%
    mutate(condition = case_when(rowname %in% c(1:4) ~ "acceptable",
                                 rowname %in% c(4:13) ~ "unacceptable"),
           dependency_length = 'long',
           length_factorized = MAPScore / (str_count(as.character(Sentence), ' ') + 1))
  
  d2 = read.csv(paste("../", model, "_dev/", model, 
                      ".0.dev_sd.results.csv", sep = '')) %>% # for the noise analysis: 
    tibble::rownames_to_column(var = "rowname") %>%
    mutate(condition = case_when(rowname %in% c(2:13) ~ "acceptable",
                                 rowname %in% c(1) ~ "unacceptable"),
           dependency_length = 'short',
           length_factorized = MAPScore / (str_count(as.character(Sentence), ' ') + 1))
  
  # want to add long distance preferences from the de Villiers paper 
  d3 = d1 
  d3$ld_preference = c(0.79, 0.48, 0.80, 0.25, 0.04, 0.03, 0.04, 0.09, 0.20, NA, NA, NA, NA)
  p_orig_dev <- ggplot(data = d3[c(1:9),], mapping = aes(x = rowname, y = ld_preference, label = rowname)) +
    geom_label() +
    ggtitle('De Villiers Original Data')
  
  
  # percentage difference
  long <- d1$length_factorized
  short <- d2$length_factorized
  
  d1$long_pref = exp(long)/ (exp(long) + exp(short)) 
  
  
  combined_prefs <- tibble(pref = c(d1$long_pref[1:9], d3$ld_preference[1:9]), 
                           type = c(rep("Model Prediction", 9), rep("Child Preference", 9)),
                           item = c(c(1:9),c(1:9)))
  
  dev.scatter <- spread(combined_prefs, type, pref) %>%
    ggplot(data = ., aes(x = `Child Preference`, y = `Model Prediction`)) + # , label = item
    geom_point(size = 4) +
    ylim(c(0,1)) +
    xlim(c(0,1)) +
    theme_classic() +
    geom_hline(yintercept = 0.5, linetype="dashed") +
    geom_vline(xintercept = 0.5, linetype="dashed") +
    annotate('rect', xmin=0.5, xmax=1, ymin=0.5, ymax=1, alpha=.5, fill='gray') +
    annotate('rect', xmin=0, xmax=0.5, ymin=0, ymax=0.5, alpha=.5, fill='gray') +
    ggtitle("de Villiers et al. (2008) Stimuli") +
    theme(plot.title = element_text(hjust = 0.5, size = 25),
          axis.text=element_text(size=14),
          axis.title = element_text(size=20)) 

  ### Final Plot list ###
  pdf(paste("~/Desktop/FG_project/noise_project/plots/",
            model,".pdf", sep = ''))
  # liu.plot
  print(liu.plot.lenfac)
  print(grid.plot)
  print(grid_len.plot)
  print(diff_plot)
  print(dev.scatter)
  dev.off()
}


# producing all the plots
for (i in 1:args[2]) {
  main(args[1], i)
}




