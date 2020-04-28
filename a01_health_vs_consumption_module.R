
# Analysis - Health vs. Consumption Module --------------------------------

library(tidyverse)
library(magrittr)
library(dplyr)

rm(list=ls())


# Load
df <- read.csv2("LSMScompilation_tidy.csv")
tab_recall <- read.csv2("LSMScompilation_recall_nitems.csv")

# Filter - only surveys with health module and consumption module ---------


# get list of surveys with both modules
surveys_bothmodules <- tab_recall %>% 
  select(survey) %>% 
  group_by(survey) %>% 
  mutate(count = n()) %>% 
  filter(count>1) %>% 
  select(survey) %>% 
  distinct()

surveys_bothmodules

# Keep only observations from selected surveys
df_bothm <- df %>% # df with surveys from both modules
  inner_join(surveys_bothmodules)

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
          survey2 = fct_reorder(survey, desc(order) )) %>% # Create order for surveys
  na.omit() # those without consumption_quintile


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


# Compare zero OOPs - Consumption vs. Health Module -----------------------


df_zero <- df_bothm %>% 
  group_by(hhid_compilation) %>% 
  mutate(zero_state = case_when(
    first(oops)==0 & last(oops)==0 ~ 0,
    first(oops)>0 & last(oops)==0 ~ 1,
    first(oops)==0 & last(oops)>0 ~ 2,
    first(oops)>0 & last(oops)>0 ~ 3
  ))

df_zero %>% 
  select(hhid_compilation, module, oops, zero_state) %>% 
  tail()










