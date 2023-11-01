library(tidyverse)
library(forcats)
library(plotrix) 
library(stringr)
# library(ggpubr)
library(patchwork)
library(ggrepel)
library(grid)
library(gridExtra)
library(viridis)

# load in data
load_data <- function(prob_label, run_num) {
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
    inner_join(v_freq) %>%
    dplyr::mutate(mod_run = paste(prob_label,"_",run_num, sep = '')) 
  
  
  
  
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
  
  
  ps.df <- d_adjunct %>%
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
    mutate(island_type = factor(island_type, levels=c('Complex NP Island',
                                                      'Subject Island',
                                                      'Whether Island',
                                                      'Adjunct Island'))) %>%
    dplyr::mutate(mod_run = paste(prob_label,"_",run_num, sep = '')) 
  
  
  ### de villiers data 
  d1 <- read.csv(paste("../", model, "_dev/", model, 
                      ".0.dev_ld.results.csv", sep = '')) %>%  
    tibble::rownames_to_column(var = "rowname") %>%
    mutate(condition = case_when(rowname %in% c(1:4) ~ "acceptable",
                                 rowname %in% c(4:13) ~ "unacceptable"),
           dependency_length = 'long',
           length_factorized = MAPScore / (str_count(as.character(Sentence), ' ') + 1))
  
  d2 <- read.csv(paste("../", model, "_dev/", model, 
                      ".0.dev_sd.results.csv", sep = '')) %>% 
    tibble::rownames_to_column(var = "rowname") %>%
    mutate(condition = case_when(rowname %in% c(2:13) ~ "acceptable",
                                 rowname %in% c(1) ~ "unacceptable"),
           dependency_length = 'short',
           length_factorized = MAPScore / (str_count(as.character(Sentence), ' ') + 1))
  
  # want to add long distance preferences from the de Villiers et al (2008) paper 
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
                           item = c(c(1:9),c(1:9))) %>%
    dplyr::mutate(mod_run = paste(prob_label,"_",run_num, sep = '')) 
  
  
  return(list(liu = insidescore_w_vfreq, ps = ps.df, dev = combined_prefs))
}

# loading no noise data separate 
list2env(`names<-`(load_data(0,1)[c("liu", "ps", "dev")],
                   c("liu_0_1", "ps_0_1", "dev_0_1")), environment())

liu0_df <- liu_0_1 %>%
  mutate(alpha = 0)

ps0_df <- ps_0_1 %>%
  mutate(alpha = 0)

dev0_df <- dev_0_1 %>% 
  mutate(alpha = 0)
  

## extract combined df while loading in the data 
create_comb_df <- function(prob_label) {
  liu = paste("liu", prob_label,"_", sep = '')
  ps = paste("ps", prob_label,"_", sep = '')
  dev = paste("dev", prob_label,"_", sep = '')
  
  for (i in 1:10) {
    list2env(`names<-`(load_data(prob_label,i)[c("liu", "ps", "dev")],
                       c(paste(liu,i,sep = ''), paste(ps,i,sep = ''),
                         paste(dev,i,sep = ''))), # this first argument just changes the names of the load_data() output to mach the prob and run num
             environment())# sets the variables to the global environment
    # https://stackoverflow.com/questions/7519790/assign-multiple-new-variables-on-lhs-in-a-single-line/73182106#73182106?newreg=df2bb668a5bc4b97a40174edc0b0d95b
  }

  # helper
  pst <- function(str, i) {
    return(get(paste(str, i, sep = ''))) # get() helpful function to return the variable from str name
  }
  
  liu_l = list()
  ps_l = list()
  dev_l = list()
  for (i in 1:10) {
    liu_l[[i]] = pst(liu,i)
    ps_l[[i]] = pst(ps,i)
    dev_l[[i]] = pst(dev,i)
  }
  
  comb_liu.df <- liu_l %>%
    reduce(full_join) %>%
    mutate(alpha = prob_label/100)
  
  comb_ps.df <- ps_l %>%
    reduce(full_join) %>%
    mutate(alpha = prob_label/100)
  
  comb_dev.df <- dev_l %>%
    reduce(full_join) %>%
    mutate(alpha = prob_label/100)

  return(list(comb_liu.df, comb_ps.df, comb_dev.df))
}

l1_dfs = create_comb_df(1)
comb_liu1.df = l1_dfs[[1]]
comb_ps1.df = l1_dfs[[2]]
comb_dev1.df = l1_dfs[[3]]

l10_dfs = create_comb_df(10)
comb_liu10.df = l10_dfs[[1]]
comb_ps10.df = l10_dfs[[2]]
comb_dev10.df = l10_dfs[[3]]

l40_dfs = create_comb_df(40)
comb_liu40.df = l40_dfs[[1]]
comb_ps40.df = l40_dfs[[2]]
comb_dev40.df = l40_dfs[[3]]

l80_dfs = create_comb_df(80)
comb_liu80.df = l80_dfs[[1]]
comb_ps80.df = l80_dfs[[2]]
comb_dev80.df = l80_dfs[[3]]

l400_dfs = create_comb_df(400)
comb_liu400.df = l400_dfs[[1]]
comb_ps400.df = l400_dfs[[2]]
comb_dev400.df = l400_dfs[[3]]

l900_dfs = create_comb_df(900)
comb_liu900.df = l900_dfs[[1]]
comb_ps900.df = l900_dfs[[2]]
comb_dev900.df = l900_dfs[[3]]

### need to add no noise and full noise 

comb_liu.df <- list(comb_liu1.df, comb_liu10.df, comb_liu40.df, comb_liu80.df,
                    comb_liu400.df, comb_liu900.df) %>%
  reduce(full_join) %>%
  rbind(liu0_df)

comb_ps.df <- list(comb_ps1.df, comb_ps10.df, comb_ps40.df, comb_ps80.df,
                    comb_ps400.df, comb_ps900.df) %>%
  reduce(full_join)

comb_dev.df <- list(comb_dev1.df, comb_dev10.df, comb_dev40.df, comb_dev80.df,
                   comb_dev400.df, comb_dev900.df) %>%
  reduce(full_join)


### liu plots ###
# calculating r squared
calc_rsquared <- function(mod_run_str) {
  filtered_data <- filter(comb_liu.df, mod_run == mod_run_str)
  rsquared = summary(lm(LenFac ~ log_fre, data = filtered_data))$r.squared
  return(rsquared)
}

# final df including the rsquared values 
rsq_df <- comb_liu.df %>%
  rowwise() %>%
  mutate(rsquared = calc_rsquared(mod_run)) %>% 
  filter(matrix_verb == 'say')


# plot
liu.plot.lenfac <- ggplot(data = comb_liu.df, mapping = aes(x = log_fre, y = LenFac, color = as.factor(alpha))) +
  geom_line(data = filter(comb_liu.df, alpha == 0), stat = "smooth", method = lm, 
            se=F, size = 3) +
  geom_line(stat = "smooth", method = lm, se=F, size = 1) +
  xlab("Log-transformed frequency of verb frame") +
  ylab("Length Factorized Score") +
  theme_classic() +
  ggtitle("Verb Frequency Pattern") +
  labs(y = "Model Prediction") +
  theme(plot.title = element_text(hjust = 0.5, size = 25),
        axis.text=element_text(size=14),
        axis.title = element_text(size=20),
        legend.text = element_text(size=14),
        legend.title = element_text(size=15)) +
  scale_color_manual(values = viridis_pal(option='H')(7), 
                     labels = c('0%','1%','9%','31%','52%','96%','99.9%')) +
  guides(color=guide_legend(title = "% Forgotten", 
                            override.aes = list(size = c(3,1,1,1,1,1,1)))) 

liu.plot.lenfac

# maybe plot all of them except 0.8? not sure I have a story for why its so high





### Pearl and Sprouse plots ###
diff_mod_df <- comb_ps.df %>% 
  rbind(ps0_df) %>%
  group_by(island_type,condition,island,mod_run,alpha) %>%
  dplyr::summarise(mean_length_factorized = -mean(length_factorized), 
                   var = var(length_factorized)) %>%
  mutate_all(~replace(., is.na(.), 0)) %>% 
  group_by(condition, island_type, mod_run,alpha) %>% 
  dplyr::summarise(diff = -diff(mean_length_factorized)) %>% # , se = se_2mean(var))
  group_by(condition, island_type, alpha) %>%
  dplyr::summarise(mean_diff = mean(diff), se = sd(diff)/sqrt(n()))  %>%
  mutate_all(~replace(., is.na(.), 0)) 
# warning message. use reframe() instead 


diff_plot <- diff_mod_df %>%
  # filter(diff_mod_df, alpha != 0) %>%
  ggplot(aes(x=condition, y = mean_diff, color = as.factor(alpha))) +
  geom_point(data = filter(diff_mod_df, alpha == 0), 
             aes(y=mean_diff), size = 3) + # for no noise
  geom_point(aes(y=mean_diff), size = 2) + 
  geom_line(data = filter(diff_mod_df, alpha == 0),
            aes(y=mean_diff, group=island_type),
            size = 2) + # for no noise
  geom_line(aes(y = mean_diff, group=interaction(island_type, as.factor(alpha)))) + # the interaction allows you to group by two dimensions
  geom_errorbar(aes(ymin = mean_diff - se, ymax = mean_diff + se), width=0.2) +
  facet_wrap(~island_type) +
  theme_classic() +
  ggtitle("Island Difference Pattern") +
  labs(y = "Model Prediction") +
  theme(plot.title = element_text(hjust = 0.5, size = 25),
        axis.text=element_text(size=14),
        axis.title = element_text(size=20),
        legend.text = element_text(size=14),
        legend.title = element_text(size=15),
        strip.text = element_text(size = 15),
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank()) +
  guides(color=guide_legend(title = "% Forgotten", 
                            override.aes = list(size = c(4,2,2,2,2,2,2)))) +
  scale_color_manual(values = viridis_pal(option='H')(7), 
                     labels = c('0%','1%','9%','31%','52%','96%','99.9%')) 




### De Villiers plots ###
dev_plot.df <- comb_dev.df %>%
  rbind(dev0_df) %>%
  spread(type, pref) %>% 
  dplyr::group_by(alpha, item, `Child Preference`) %>%
  summarise(mean_pred = mean(`Model Prediction`), 
            se = sd(`Model Prediction`)/sqrt(n())) %>%
  mutate_all(~replace(., is.na(.), 0)) 

dev.scatter <- dev_plot.df %>%
  # filter(alpha != 0) %>%
  # ggplot(data = filter(., alpha != 0), aes(x = `Child Preference`, y = mean_pred, 
  #                      color = as.factor(alpha))) + # , label = item
  ggplot(data = ., aes(x = `Child Preference`, y = mean_pred, 
                                           color = as.factor(alpha))) + # , label = item
  geom_point(data = filter(dev_plot.df, alpha == 0), size = 6) +
  geom_point(size = 3) +
  # geom_errorbar(aes(ymin = mean_pred - se, ymax = mean_pred + se), width=0.1) +
  ylim(c(0,1)) +
  xlim(c(0,1)) +
  theme_classic() +
  geom_hline(yintercept = 0.5, linetype="dashed") +
  geom_vline(xintercept = 0.5, linetype="dashed") +
  annotate('rect', xmin=0.5, xmax=1, ymin=0.5, ymax=1, alpha=.5, fill='gray') +
  annotate('rect', xmin=0, xmax=0.5, ymin=0, ymax=0.5, alpha=.5, fill='gray') +
  ggtitle("Child Preference Pattern") +
  labs(y = "Model Prediction") +
  theme(plot.title = element_text(hjust = 0.5, size = 25),
        axis.text=element_text(size=14),
        axis.title = element_text(size=20),
        legend.text = element_text(size=14),
        legend.title = element_text(size=15)) +
  guides(color=guide_legend(title = "% Forgotten", 
                            override.aes = list(size = c(6,3,3,3,3,3,3)))) + 
  scale_color_manual(values = viridis_pal(option='H')(7), 
                     labels = c('0%','1%','9%','31%','52%','96%','99.9%')) 
  # scale_size_manual(values = c(6,3,3,3,3,3,3))



#### forgetting plots 
add_alpha_data <- function(alpha) {
  l=seq.int(1,5, by = 0.01)
  v=vector()
  for (i in 1:length(l)) {
    v[i] = 1/(l[i]**alpha)
  }
  return(v)
}


alpha_df <- function(a) {
  df <- data_frame(position = seq.int(1,5, by = 0.01), alpha = a, prob = add_alpha_data(a))
  return(df)
}

df <- alpha_df(0) %>%
  rbind(alpha_df(0.01)) %>%
  rbind(alpha_df(0.1)) %>%
  rbind(alpha_df(0.4)) %>%
  rbind(alpha_df(0.8)) %>% 
  rbind(alpha_df(4)) %>% 
  rbind(alpha_df(9))

p_rem_prob <- ggplot(df, aes(x = position, y = prob, color = as.factor(alpha))) +
  geom_line(data = filter(df, alpha ==0), size =2)+
  geom_line(size=1) +
  xlab("Position") +
  ylab("Remember Probability") +
  theme_classic() +
  # ggtitle("Verb Frequency Pattern") +
  theme(plot.title = element_text(hjust = 0.5, size = 25),
        axis.text=element_text(size=14),
        axis.title = element_text(size=20),
        legend.text = element_text(size=14),
        legend.title = element_text(size=15)) +
  scale_color_manual(values = viridis_pal(option='H')(7)) +
  guides(color=guide_legend(title = "alpha", 
                            override.aes = list(size = c(4,2,2,2,2,2,2)))) 



pdf("~/Desktop/FG_project/noise_project/plots/combined.pdf")
liu.plot.lenfac
diff_plot
dev.scatter
p_rem_prob
dev.off()




