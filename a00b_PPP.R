
# Adjust by PPP -----------------------------------------------------------

library(tidyverse)
library(quantmod)
library(magrittr)
library(dplyr)
library(WDI)


rm(list=ls())


# Load --------------------------------------------------------------------

# Df nontidy
df_nontidy <- read.csv2("LSMScompilation_nontidy.csv")

# Df tidy
df_tidy <- read.csv2("LSMScompilation_tidy.csv")


# Prepare Data ------------------------------------------------------------

# Countries to evaluate - those in the survey
surveys <- df_nontidy %>% 
  select(survey) %>% 
  distinct()

# Grab countries
country_list <- surveys$survey %>% 
  str_extract(pattern = "^[a-zA-Z]*") %>% 
  str_extract(pattern = "[A-Z]*[a-z]*")

# Include surveys
survey_country_list <- tibble(country = country_list,survey = surveys$survey) %>% 
  mutate(year = as.numeric(str_extract(survey,pattern = "\\d*$") ))

survey_country_list

# Grab inflation and PPP ---------------------------------------------------------

country_codes <- c("BG","BA","AL","UG","NG","TZ","MW","IQ","GH","ET")
ppp_inflation <- WDI(country=country_codes, indicator = c("PA.NUS.PPP","FP.CPI.TOTL"),
    start = 1988)

# Grab 2011 inflation
tab_adjustment <- ppp_inflation %>% 
  filter(year==2011) %>% 
  select(country, `FP.CPI.TOTL`) %>%
  rename(cpi_2011 = `FP.CPI.TOTL`) %>% 
  right_join(ppp_inflation) %>% 
  mutate(cpi = `FP.CPI.TOTL`/cpi_2011) %>% 
  select(country,year,cpi,`PA.NUS.PPP`) %>% 
  mutate(adjustment = `PA.NUS.PPP`/cpi,
         country = ifelse(country=="Bosnia and Herzegovina","Bosnia",country)) %>% 
  as_tibble()

tab_adjustment

# Join WDI inforamtion with surveys ---------------------------------------

adjustment_ready <- survey_country_list %>% left_join(tab_adjustment)

# Unsuccesful in: Bosnia 2001, Bosnia 2004, Ghana 1989, Ghana 1988
adjustment_ready %>% filter(is.na(adjustment))

# Repalce with some values
tab_adjustment <- adjustment_ready %>% 
  mutate(adjustment = case_when(
    survey=="Bosnia_2004" ~ `PA.NUS.PPP`/ 84.5/103.6713, # Information from CPI from FRED, 2010 base that is why is divided
    survey=="Bosnia_2001" ~ `PA.NUS.PPP` / 84.5/ (1+(0.547/100))*(1+(0.313/100))*(1+(4.573/100)) /103.6713 ,
    survey=="Ghana_1989" ~ 108.7268 / cpi/	1.054099e-02, # used closest year for PPP ER 1990
    survey=="Ghana_1988" ~ 108.7268 / cpi/	1.054099e-02, # used closest year for PPP ER 1990
    TRUE ~ adjustment # all the rest
  )) %>% 
  select(country,year, survey,cpi,adjustment)


# Adjust tidydatasets -----------------------------------------------------



# Tidy dataset
df_tidy_adjusted <- df_tidy %>% left_join(tab_adjustment, by="survey") %>% 
  mutate_at(c("food_consumption","nonsub_consumption","nonhealth_consumption","nonfood_nohealth_consumption","oops"),funs(. /adjustment))

tab <- df_tidy_adjusted %>% 
  group_by(survey, module) %>% 
  summarise(mean_oops = mean(oops, na.rm = TRUE)) %>% 
  mutate(mean_oops = mean_oops %>% round(2) )

tab









