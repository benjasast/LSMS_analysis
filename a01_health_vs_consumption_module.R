
# Analysis - Health vs. Consumption Module --------------------------------

library(tidyverse)
library(modelr)
library(magrittr)
library(dplyr)
library(ggrepel)
library(hexbin)
library(gridExtra)

rm(list=ls())


# Load
df <- read.csv2("LSMScompilation_tidy.csv")
tab_recall <- read.csv2("LSMScompilation_recall_nitems.csv")
df_nontidy <- read.csv2("LSMScompilation_nontidy.csv")

tab_recall

# Filter - only surveys with health module and consumption module ---------

# get list of surveys with both modules
surveys_bothmodules <- tab_recall %>% 
  select(survey) %>% 
  group_by(survey) %>% 
  mutate(count = n()) %>% 
  filter(count>1) %>% 
  select(survey) %>% 
  distinct()

length(surveys_bothmodules$survey)

surveys_bothmodules

# Keep only observations from selected surveys - tidy
df_bothm <- df %>% # df with surveys from both modules
  inner_join(surveys_bothmodules)

# keep only observations from selected surveys - nontidy
df_bothm_nontidy <- df_nontidy %>% 
  inner_join(surveys_bothmodules)



# Scatter-Plots -----------------------------------------------------------


# Facet_wrap not really an option, I will make individual graphs by survey

scatter_xy <- function(survey_name){

# Filter survey and take outliers out
data <- df_bothm_nontidy %>% 
  filter(survey==survey_name) %>%
  select(hhid_compilation,health_consumption,healthm_oops) %>% 
  na.omit() %>% 
  mutate(z_health = healthm_oops / sd(healthm_oops, na.rm = TRUE),
         z_consumption = health_consumption / sd(health_consumption, na.rm = TRUE)) %>% 
  filter(z_health<2, z_consumption<2) %>%  # take out all those with z>2 for viz purposes
  rename(`Health Module` = healthm_oops,
         `Consumption Module` = health_consumption)

# Limit for both axis for viz  
max_scale <- data %$% 
    max( max(`Health Module`, na.rm = TRUE), max(`Consumption Module`)     , na.rm = TRUE)

# Number of bins (optional to use)
nbins <- data %>% 
  nrow() / 100
  
# one special for Ghana 2013
  if (survey_name=="Ghana_2013"){
    graph <- data %>% 
      ggplot(aes(`Consumption Module`,`Health Module`)) +
      #geom_point(alpha = 1/10) +
      geom_hex(bins = 68) +
      scale_fill_gradient(low = "yellow", high = "red", limits = c(5, 200) , guide = FALSE) + #option to show the
      geom_abline(intercept = 0, slope = 1, alpha=10, linetype = "dashed", color="black") +
      scale_y_continuous(limits = c(0,max_scale)) +
      scale_x_continuous(limits = c(0,max_scale)) +
      ggtitle(survey_name) +
      theme(axis.text = element_text(size = 7), 
            axis.title = element_text(size = 7),
            plot.title = element_text(size = 11, face = "bold", hjust=0.5))
    
    graph

# All the rest  
  } else{
  
    graph <- data %>% 
    ggplot(aes(`Consumption Module`,`Health Module`)) +
    #geom_point(alpha = 1/10) +
    geom_hex() + #bins= nbins
    scale_fill_gradient(low = "yellow", high = "red", limits = c(5, 200) , guide = FALSE) + #option to show the
    geom_abline(intercept = 0, slope = 1, alpha=10, linetype = "dashed", color="black") +
    scale_y_continuous(limits = c(0,max_scale)) +
    scale_x_continuous(limits = c(0,max_scale)) +
    ggtitle(survey_name) +
    theme(axis.text = element_text(size = 7), 
            axis.title = element_text(size = 7),
            plot.title = element_text(size = 11, face = "bold", hjust=0.5))
  
  graph
  }

}



# Try it
scatter_xy("Ghana_2017")

# List of surveys
bothm_surveylist <- surveys_bothmodules$survey %>% 
  as.character()

bothm_surveylist

# get all the graphs
hex_graphs <- bothm_surveylist %>%  map(scatter_xy)

# Put all graphs in one page
grid.arrange(hex_graphs[[1]],hex_graphs[[2]],hex_graphs[[3]],hex_graphs[[4]],
             hex_graphs[[5]],hex_graphs[[6]],hex_graphs[[7]],hex_graphs[[8]],
             hex_graphs[[9]],hex_graphs[[10]],hex_graphs[[11]],hex_graphs[[12]],
             hex_graphs[[13]],hex_graphs[[14]],hex_graphs[[15]],hex_graphs[[16]], hex_graphs[[17]])



# Characteristic of surveys -----------------------------------------------

# Create simple regression
survey_model <- function(survey_name){
  df_aux <- df_bothm_nontidy %>% filter(survey==survey_name)
  model <- lm(healthm_oops ~ health_consumption , data = df_aux)
  coef(model)[[2]]
}


coefs <- bothm_surveylist %>% map(survey_model) %>% unlist()

tab_reg <- tibble(coef = coefs, survey = bothm_surveylist) %>%
  inner_join(tab_recall) %>% pivot_wider(names_from = module, values_from = c(recall,nitems)) %>% 
  group_by(survey) %>% 
  transmute(Survey = survey,
            `Regression Coefficient` = coef,
            `Items Health Module` = first(nitems_Health),
            `Items Consumption Module` = last(nitems_Consumption),
            `Avg. Recall Health Module` = first(recall_Health),
            `Avg. Recall Consumption Module` = last(recall_Consumption) ) %>% 
  distinct() %>% 
  arrange(`Regression Coefficient`)


# Compare Averages between modules ----------------------------------------

# Grab means by survey and module
tab_mean_oops <- df_bothm %>% 
  group_by(survey,module) %>% 
  summarise(mean_oops = mean(oops, na.rm = TRUE),
            median_oops = median(oops, na.rm=TRUE),
            obs = n())

tab_mean_oops

# Graph
tab_mean_oops %>% 
  ggplot(aes(survey,mean_oops) ) +
  geom_point( aes(color = module ) ) +
  coord_flip()


# Grab OOPs of health module over OOPs of consumption module
tab_health_over_consumption <- tab_mean_oops %>% 
  group_by(survey) %>% 
  mutate(healthc_healthm = first(mean_oops) / last(mean_oops),
         mhealthc_mhealthm = first(median_oops) / last(median_oops),
         trim_mhealthc_mhealthm = if_else(mhealthc_mhealthm>2,2,mhealthc_mhealthm)) %>% 
  ungroup() %>% 
  select(survey, mhealthc_mhealthm, healthc_healthm, trim_mhealthc_mhealthm) %>% 
  distinct() %>% 
  mutate( order = seq_along(survey),
          survey2 = fct_reorder(survey, desc(order) ))

tab_health_over_consumption





# Graph Average Means by survey
tab_health_over_consumption %>% 
  ggplot(aes( survey2 ,healthc_healthm)) +
  geom_point(color="blue") +
  coord_flip() +
  ggtitle("Mean OOPs from the consumption module over the health module") +
  xlab("") +
  ylab("Share") +
  geom_hline(yintercept=1, alpha=3, linetype = "dashed") +
  scale_y_continuous(breaks = seq(0,2,0.25))



# Graph Median by survey
tab_health_over_consumption %>% 
  ggplot(aes( survey2 ,trim_mhealthc_mhealthm )) +
  geom_point(color="blue") +
  coord_flip() +
  ggtitle("Median OOPs from the consumption module over the health module") +
  xlab("") +
  ylab("Share") +
  geom_hline(yintercept=1, alpha=3, linetype = "dashed") +
  scale_y_continuous(breaks = c(0,0.25,0.5,0.75,1,1.25,1.5,1.75,2), 
                     label = c("0","0.25","0.5","0.75","1","1.25","1.5","1.75","2+"))


# Compare Averages between modules by consumption quintile ----------------


# Grab means by survey and module
tab_mean_cq <- df_bothm %>% 
  group_by(survey,module,consumption_quintile) %>% 
  summarise(mean_oops = mean(oops, na.rm = TRUE),
            median_oops = median(oops, na.rm=TRUE),
            obs = n())

# Grab OOPs of health module over OOPs of consumption module
tab_hc_cq <- tab_mean_cq %>% 
  group_by(survey,consumption_quintile) %>% 
  mutate(healthc_healthm = first(mean_oops) / last(mean_oops),
         mhealthc_mhealthm = first(median_oops) / last(median_oops),
         trim_mhealthc_mhealthm = if_else(mhealthc_mhealthm>2,2,mhealthc_mhealthm)) %>% 
  ungroup() %>% 
  select(survey, consumption_quintile, mhealthc_mhealthm, healthc_healthm, trim_mhealthc_mhealthm) %>% 
  distinct() %>% 
  mutate( order = seq_along(survey),
          survey2 = fct_reorder(survey, desc(order) )) %>%  # Create order for surveys
  filter(consumption_quintile> -1) # eliminate those with NA


tab_hc_cq

# Graph mean
tab_hc_cq %>% 
  ggplot(aes(x=survey2,y=healthc_healthm, 
             group = reorder(consumption_quintile, -consumption_quintile), 
             fill = consumption_quintile) ) +
  geom_bar(position='dodge', stat='identity') +
  coord_flip() +
  ggtitle("Mean OOPs from the consumption module over the health module") +
  labs(subtitle = "By consumption quintile") +
  xlab("") +
  ylab("Share") +
  geom_hline(yintercept=1, alpha=3, linetype = "dashed")

# Graph median
tab_hc_cq %>% 
  ggplot(aes(x=survey2,y=trim_mhealthc_mhealthm, 
             group = reorder(consumption_quintile, -consumption_quintile), 
             fill = consumption_quintile) ) +
  geom_bar(position='dodge', stat='identity') +
  coord_flip() +
  ggtitle("Median OOPs from the consumption module over the health module") +
  labs(subtitle = "By consumption quintile") +
  xlab("") +
  ylab("Share") +
  geom_hline(yintercept=1, alpha=3, linetype = "dashed")


# Repetition of Zeros -----------------------

df_zero <- df_bothm %>% 
  group_by(hhid_compilation) %>% 
  mutate(
    c0_h0 = (first(oops)==0 & last(oops)==0),
    c1_h0 = (first(oops)>0 & last(oops)==0),
    c0_h1 = (first(oops)==0 & last(oops)>0),
    c1_h1 = (first(oops)>0 & last(oops)>0 ) )

df_zero <- df_zero %>% 
  select(hhid_compilation,survey, c0_h0, c1_h0, c0_h1, c1_h1) %>% 
  distinct()

tab_zero_reps <- df_zero %>% 
  group_by(survey) %>% 
  summarise(both_zero = mean(c0_h0, na.rm = TRUE),
            posc_zeroh = mean(c1_h0, na.rm = TRUE),
            zeroc_posh = mean(c0_h1, na.rm = TRUE),
            posc_poch = mean(c1_h1, na.rm = TRUE))

tab_zero_reps

percentage <- function(x){
  round(x*100,1)
}

# Put it in percentage
tab_zero_reps %>% 
  mutate_at(vars(matches("h")) , percentage)



# CHEs --------------------------------------------------------------------

df_che <- df_bothm %>% 
  mutate(total_consumption =  nonhealth_consumption + oops,
         che10 = (oops/total_consumption)>.1,
         che25 = (oops/total_consumption)>.25)


tab_che <- df_che %>% 
  group_by(survey,module) %>% 
  summarise(mean_che10 = mean(che10, na.rm = TRUE),
            mean_che25 = mean(che25, na.rm = TRUE))

tab_che %>% 
  ggplot(aes(survey,mean_che10, color = module)) +
  geom_point() +
  coord_flip() +
  scale_y_continuous(breaks = seq(0,.6,.1), limits = c(0,.6))






























