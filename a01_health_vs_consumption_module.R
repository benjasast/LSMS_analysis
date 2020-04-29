
# Analysis - Health vs. Consumption Module --------------------------------

library(tidyverse)
library(magrittr)
library(dplyr)
library(ggrepel)
library(hexbin)

rm(list=ls())


# Load
df <- read.csv2("LSMScompilation_tidy.csv")
tab_recall <- read.csv2("LSMScompilation_recall_nitems.csv")

# need number of obs by survey
obs <- df %>% 
  select(hhid_compilation, survey) %>% 
  distinct() %>% 
  group_by(survey) %>% 
  summarise(count= n())


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

# Keep only observations from selected surveys
df_bothm <- df %>% # df with surveys from both modules
  inner_join(surveys_bothmodules)

head(df_bothm)

# Scatter-Plots -----------------------------------------------------------

# Facet_wrap not really an option, I will make individual graphs by survey

scatter_xy <- function(survey_name){

# Filter survey and take outliers out
data <- df_bothm %>% 
  filter(survey==survey_name) %>%
  select(hhid_compilation,module, oops, module) %>% 
  na.omit() %>% 
  group_by(module) %>% 
  mutate(z_score = oops / sd(oops, na.rm = TRUE)) %>% 
  filter(z_score<2) # take out all those with z>2 for viz purposes

data %>% head()

# Put it wider, and create vars  
data2 <- data %>% 
  group_by(hhid_compilation) %>% 
  mutate(count = n()) %>% 
  filter(count>1) %>% # Take away possible observations with only one
  mutate(`Health Module` = last(oops)) %>% 
  slice(1) %>% # keep only one observation
  ungroup() %>% 
  rename(`Consumption Module` = oops)  # very inneficient but pivot_wider not working for a reason

# Limit for both axis for viz  
max_scale <- data2 %$% 
    max( max(`Health Module`, na.rm = TRUE), max(`Consumption Module`)     , na.rm = TRUE)

# Number of bins
nbins <- data2 %>% 
  nrow() / 100
  

  graph <- data2 %>% 
  ggplot(aes(`Consumption Module`,`Health Module`)) +
  #geom_point(alpha = 1/10) +
  geom_hex(bins= nbins) +
  scale_fill_gradient(limits = c(5, 200)) +
  geom_abline(intercept = 0, slope = 1) +
  scale_y_continuous(limits = c(0,max_scale)) +
  scale_x_continuous(limits = c(0,max_scale)) +
  ggtitle(survey_name)

graph

}


# List of surveys
bothm_surveylist <- surveys_bothmodules$survey %>% 
  as.character()

# get all the graphs
hex_graphs <- bothm_surveylist %>%  map(scatter_xy)
hex_graphs

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
  





























