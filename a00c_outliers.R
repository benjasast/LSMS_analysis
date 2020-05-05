
# Control Outliers --------------------------------------------------------

library(tidyverse)
library(magrittr)
library(dplyr)

rm(list=ls())


# Load Data ---------------------------------------------------------------

df <- readRDS(file = "LSMScompilation_nontidy_PPPadjusted")

df_money <-  df %>% 
  select(-consumption_quintile) %>% 
  select(contains(c("hhid_compilation","survey","consumption","Health","Consumption")))

df_money %>% 
  group_by(survey) %>% 