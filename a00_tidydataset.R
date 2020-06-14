
# Create Tidy Dataset -----------------------------------------------------

library(tidyverse)
library(magrittr)
library(dplyr)

rm(list=ls())

# Load
df <- read_csv("/Users/bsastrakinsky/Dropbox/LSMS_Compilation/Analysis/Output_Files/aux_tidy.csv",
               col_types = cols(hhead_age = col_double(),
                                health_items = col_double(),
                                health_recall2 = col_double(),
                                health_consumption = col_double(),
                                consumption_quintile = col_integer(),
                                nonfood_nonhealth_consumption = col_double(),
                                nonhealth_consumption = col_double(),
                                food_consumption = col_double(),
                                year = col_double(),
                                hhweight = col_double(),
                                hhsize = col_double(),
                                episodic_hosp = col_logical(),
                                urban = col_logical(
                                )))


# Make Tidy -----------------------------------------------------------

# Keep relevant vars
df_rel <- df %>% 
  select(hhid_compilation,survey, consumption_quintile, nonsub_consumption,
         food_consumption, nonhealth_consumption, nonfood_nohealth_consumption, 
         health_consumption,healthm_oops, healthm_recall2, health_recall2, healthm_items, health_items,
         hhead_married, hhead_female, hhead_age,
         episodic_hosp, year, hhweight, hhsize, urban)


# Pivot - OOPs
df_pivot <- df_rel %>% select(survey,hhid_compilation,healthm_oops,health_consumption, consumption_quintile,
                              food_consumption, nonsub_consumption, nonhealth_consumption, nonfood_nohealth_consumption,
                              hhead_married, hhead_female, hhead_age,episodic_hosp, year, hhweight) %>% 
  pivot_longer(c(health_consumption, healthm_oops),names_to = "module", values_to = "oops") %>% 
  filter(oops>-1) %>% # Take out NAs and keep zeros
  mutate(module = case_when(
    module == "health_consumption" ~ "Consumption",
    module == "healthm_oops" ~ "Health"
  ))



# Grab Table of Recall and Length for each survey-module
tab_recall_len <- df_rel %>% select(survey, healthm_recall2, healthm_items, health_items, health_recall2) %>% 
  group_by(survey) %>% 
  slice(1) %>% # they are all the same for each survey, we only need first obs
  pivot_longer(c(healthm_recall2, health_recall2), names_to = "module", values_to = "recall") %>% # pivot recall
  filter(recall>0) %>% 
  pivot_longer(c(healthm_items, health_items), names_to = "module2", values_to = "nitems" ) %>%  # pivot items
  filter(nitems>0) %>% 
  mutate(keep = case_when(
    module=="healthm_recall2" & module2=="healthm_items" ~ 1,
    module=="health_recall2" & module2=="health_items" ~ 1
  )) %>% 
  filter(keep==1) %>% # Avoid non-valid combinations
  select(survey, module, recall, nitems) %>% 
  mutate(module = case_when(
    module == "health_recall2" ~ "Consumption",
    module == "healthm_recall2" ~ "Health"
  ))

tab_recall_len

# Join pivotted dataset with table of recall and nitems
df_tidy <- df_pivot %>% 
  left_join(tab_recall_len)

head(df_tidy)


# Household information (to use later with filtered dataset)
hhinfo <- df_rel %>% select(contains(c("hhweight","hhead","episodic","consumption_quintile","hhid_compilation","hhsize", "urban")))



# Save --------------------------------------------------------------------

# Tidydataset
saveRDS(df_tidy, file = "LSMScompilation_tidy")

# Table with characteristics of each survey
saveRDS(tab_recall_len, file = "LSMScompilation_recall_nitems")

# non-tidy dataset
saveRDS(df_rel, file = "LSMScompilation_nontidy")

#hh info
saveRDS(hhinfo, file= "LSMScompilation_hhinfo")





