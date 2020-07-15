
# Control Outliers --------------------------------------------------------

library(tidyverse)
library(magrittr)
library(dplyr)

rm(list=ls())


# Load Data ---------------------------------------------------------------

df <- readRDS(file = "LSMScompilation_nontidy_PPPadjusted")

df_money <-  df %>% 
  select(-consumption_quintile) %>% 
  select(contains(c("hhid_compilation","survey","consumption","Health","Consumption"))) %>% 
  select(-nonsub_consumption,-nonfood_nohealth_consumption) %>% 
  mutate(Health_nonhealth = Health/nonhealth_consumption,
         Consumption_nonhealth = Consumption/nonhealth_consumption)

# Make it really tidy
df_money_tidy <- df_money %>% 
  pivot_longer(c(food_consumption,nonhealth_consumption,Consumption,Health,Health_nonhealth,Consumption_nonhealth),names_to = "money_var", values_to = "value" )


# EDA ---------------------------------------------------------------------

# Boxplot for all relevant variables
#df_money_tidy %>% 
#  ggplot(aes(money_var,value)) +
#  geom_boxplot(aes(color=money_var)) +
#  facet_wrap(~survey, scales = "free")

head(df_money_tidy)



# Criteria 1:  ------------------------------------------------------------

# Criteria 1: OOPs over nonhealth consumption do not exceed 5x
criteria1 <- 5

# Graph with ratios (gets really bad in many cases)
#df_money_tidy %>% 
#  filter(money_var %in% c("Health_nonhealth" , "Consumption_nonhealth") ) %>% 
#  ggplot(aes(money_var,value)) +
#  geom_boxplot(aes(color=money_var)) +
#  facet_wrap(~survey, scales = "free")


# Table with number of observations failing criteria 1 per survey
n_fail_criteria1_bysurvey <- df_money_tidy %>% 
  filter(money_var %in% c("Health_nonhealth" , "Consumption_nonhealth") ) %>% 
  filter(value>criteria1) %>% 
  select(hhid_compilation, survey) %>% 
  distinct() %>% 
  group_by(survey) %>% 
  count()

# Grab hhid of failing obs
hhid_fail_criteria1 <- df_money_tidy %>% 
  filter(money_var %in% c("Health_nonhealth" , "Consumption_nonhealth") ) %>% 
  filter(value>criteria1) %>% 
  select(hhid_compilation) %>% 
  distinct()

# New money DF without those who fail
df_money_criteria1 <- df_money_tidy %>% 
  anti_join(hhid_fail_criteria1)

  
  
# Criteria 2 --------------------------------------------------------------

# Eliminate absurb amounts spent on health: PPP USD 30,000 limit
criteria2 <- 30000

# Boxplot
#df_money_criteria1 %>% 
#  filter(money_var %in% c("Health","Consumption")) %>% 
#  ggplot(aes(money_var,value)) +
#  geom_boxplot(aes(color=money_var)) +
#  facet_wrap(~survey, scales = "free")
  

# Table with number of observations failing criteria 1 per survey
n_fail_criteria2_bysurvey <- df_money_tidy %>% 
  filter(money_var %in% c("Health","Consumption") ) %>% 
  filter(value>criteria2) %>% 
  select(hhid_compilation, survey) %>% 
  distinct() %>% 
  group_by(survey) %>% 
  count()

n_fail_criteria2_bysurvey

# Grab hhid of failing obs
hhid_fail_criteria2 <- df_money_tidy %>% 
  filter(money_var %in% c("Health","Consumption") ) %>% 
  filter(value>criteria2) %>% 
  select(hhid_compilation) %>% 
  distinct()

# Create DF complying with criteria 2
df_money_criteria2 <- df_money_criteria1 %>% 
  anti_join(hhid_fail_criteria2)


# Check means -------------------------------------------------------------

tab <- df_money_criteria2 %>% 
  filter(money_var %in% c("Health","Consumption") ) %>% 
  group_by(survey,money_var) %>% 
  summarise(mean = mean(value, na.rm = TRUE)) %>% 
  na.omit()

tab_mean <- tab %>% pivot_wider(id_cols = c(survey,money_var), names_from = money_var, values_from = mean)

# Observations remaining
tab2 <- df_money_criteria2 %>% 
  select(hhid_compilation,survey) %>% 
  distinct() %>% 
  group_by(survey) %>% 
  count()



# Save results ------------------------------------------------------------

# Nontidy Dataset
df_nontidy_outliers <- df_money_criteria2 %>% pivot_wider(names_from = money_var, values_from = value)
saveRDS(df_nontidy_outliers, file="LSMScompilation_nontidy_outliers")


# Tidy datase
df_tidy_outliers <- df_nontidy_outliers %>% pivot_longer(c(Consumption,Health), names_to = "module",values_to = "oops")
saveRDS(df_tidy_outliers, file="LSMScompilation_tidy_outliers")















