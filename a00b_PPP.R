
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
    survey=="Bosnia_2001" ~ `PA.NUS.PPP` / 84.5/  103.6713 / (1+(0.547/100))/(1+(0.313/100))/(1+(4.573/100)) ,
    survey=="Ghana_1989" ~ 108.7268 / cpi/	1.054099e-02, # used closest year for PPP ER 1990
    survey=="Ghana_1988" ~ 108.7268 / cpi/	1.054099e-02, # used closest year for PPP ER 1990
    TRUE ~ adjustment # all the rest
  )) %>% 
  select(country,year, survey,cpi,adjustment)


# Adjust tidydatasets -----------------------------------------------------

# Tidy dataset
df_tidy_adjusted <- df_tidy %>% left_join(tab_adjustment, by="survey") %>% 
  mutate_at(c("food_consumption","nonsub_consumption","nonhealth_consumption","nonfood_nohealth_consumption","oops"),funs(. /adjustment)) 

# Make manual adjustments -------------------------------------------------


# Fixes for Iraq (survey measured in 1000s)
df_iraq_adjusted <- df_tidy_adjusted %>% 
  filter(country=="Iraq") %>% 
  mutate_at(c("food_consumption","nonsub_consumption","nonhealth_consumption","nonfood_nohealth_consumption","oops"),funs(. * 1000))

df_iraq_adjusted %>% 
  group_by(survey,module) %>% 
  summarise(mean_oops = mean(oops, na.rm = TRUE)) %>% 
  mutate(mean_oops = mean_oops %>% round(2) )

# Fixes for Ghana 2006 - they used old cedis instead of new
df_ghana2006_adjusted <- adjustment_ready %>% 
  filter(survey=="Ghana_2006") %>% 
  mutate(adjustment = 5.4/ 9259.259259 / cpi) %>%  # PPP/forex/inflation
left_join(df_tidy, by="survey") %>% 
  mutate_at(c("food_consumption","nonsub_consumption","nonhealth_consumption","nonfood_nohealth_consumption","oops"),funs(. *adjustment)) 

df_ghana2006_adjusted %>% group_by(survey,module) %>% 
  summarise(mean_oops = mean(oops, na.rm = TRUE))

# Fixes Ghana 1991
df_ghana1991_adjusted <- adjustment_ready %>% 
  filter(survey=="Ghana_1991") %>% 
  mutate(adjustment = 5.4/ (166.06/100)*1.431 / cpi) %>%   # PPP/effective exchange rate (2010=100) * forex 2010/inflation
  left_join(df_tidy, by="survey") %>% 
  mutate_at(c("food_consumption","nonsub_consumption","nonhealth_consumption","nonfood_nohealth_consumption","oops"),funs(. /adjustment)) 

df_ghana1991_adjusted %>% group_by(survey,module) %>% 
  summarise(mean_oops = mean(oops, na.rm = TRUE))

# Fixes Ghana 1989
df_ghana1989_adjusted <- adjustment_ready %>% 
  filter(survey=="Ghana_1989") %>% 
  mutate(adjustment = 5.4/ (163.86/100)*1.431 / cpi) %>%   # PPP/effective exchange rate (2010=100) * forex 2010/inflation
  left_join(df_tidy, by="survey") %>% 
  mutate_at(c("food_consumption","nonsub_consumption","nonhealth_consumption","nonfood_nohealth_consumption","oops"),funs(. /adjustment)) 

df_ghana1989_adjusted %>% group_by(survey,module) %>% 
  summarise(mean_oops = mean(oops, na.rm = TRUE))

# Fixes Ghana 1988
df_ghana1988_adjusted <- adjustment_ready %>% 
  filter(survey=="Ghana_1988") %>% 
  mutate(adjustment = 5.4/ (175.15/100)*1.431 / cpi) %>%   # PPP/effective exchange rate (2010=100) * forex 2010/inflation
  left_join(df_tidy, by="survey") %>% 
  mutate_at(c("food_consumption","nonsub_consumption","nonhealth_consumption","nonfood_nohealth_consumption","oops"),funs(. /adjustment)) 

df_ghana1988_adjusted %>% group_by(survey,module) %>% 
  summarise(mean_oops = mean(oops, na.rm = TRUE))

# Fixes Bosnia 2004
df_bosnia2004_adjusted <- adjustment_ready %>% 
  filter(survey=="Bosnia_2004") %>% 
  mutate(adjustment =  1/ (1.5579*(84.5/103.6713)*0.876)      ) %>%   # divided by exchange rate, CPI, and PPP adjustment
  left_join(df_tidy, by="survey") %>% 
  mutate_at(c("food_consumption","nonsub_consumption","nonhealth_consumption","nonfood_nohealth_consumption","oops"),funs(. *adjustment)) 

df_bosnia2004_adjusted %>% group_by(survey,module) %>% 
  summarise(mean_oops = mean(oops, na.rm = TRUE))

# Fixes Bosnia 2004
df_bosnia2004_adjusted <- adjustment_ready %>% 
  filter(survey=="Bosnia_2004") %>% 
  mutate(adjustment =  1/ (1.76*(84.5/103.6713)*0.876)      ) %>%   # divided by exchange rate, CPI, and PPP adjustment
  left_join(df_tidy, by="survey") %>% 
  mutate_at(c("food_consumption","nonsub_consumption","nonhealth_consumption","nonfood_nohealth_consumption","oops"),funs(. *adjustment)) 

df_bosnia2004_adjusted %>% group_by(survey,module) %>% 
  summarise(mean_oops = mean(oops, na.rm = TRUE))

# Fixes Bosnia 2001
cpi_2001_bosnia <-103.6713 / (1+(0.547/100))/(1+(0.313/100))/(1+(4.573/100))

df_bosnia2001_adjusted <- adjustment_ready %>% 
  filter(survey=="Bosnia_2001") %>% 
  mutate(adjustment =  1/ ((1.5579*(84.5/cpi_2001_bosnia)*0.876))      ) %>%   # divided by exchange rate, CPI, and PPP adjustment (latest)
  left_join(df_tidy, by="survey") %>% 
  mutate_at(c("food_consumption","nonsub_consumption","nonhealth_consumption","nonfood_nohealth_consumption","oops"),funs(. *adjustment)) 

df_bosnia2001_adjusted %>% group_by(survey,module) %>% 
  summarise(mean_oops = mean(oops, na.rm = TRUE))


# Put adjustments into main df --------------------------------------------

corrected_surveys <- c("Bosnia_2001","Bosnia_2004",
                       "Ghana_1988","Ghana_1989","Ghana_1991","Ghana_2006",
                       "Iraq_2007","Iraq_2012")

# Put all corrected surveys in one tibble
list_corrected_surveys <- list(df_bosnia2001_adjusted,df_bosnia2004_adjusted,
                               df_ghana1988_adjusted,df_ghana1989_adjusted,df_ghana1991_adjusted,df_ghana2006_adjusted,
                               df_iraq_adjusted) %>% reduce(full_join)

# Eliminate from adjusted dataset all corrected surveys
'%notin%' <- Negate('%in%')

df_adjusted_well <- df_tidy_adjusted %>% 
  filter(survey %notin% corrected_surveys)

# Join corrected surveys to adjusted dataset
df_adjusted_well <- df_adjusted_well %>% 
  full_join(list_corrected_surveys)

# Check
tab <- df_adjusted_well %>% 
  group_by(survey, module) %>% 
  summarise(mean_oops = mean(oops, na.rm = TRUE)) %>% 
  mutate(mean_oops = mean_oops %>% round(2) )


# Save Adjusted Df --------------------------------------------------------

# Save as tidy dataset
df_tidy_adjusted <- df_adjusted_well %>% 
  rename(year = year.x) %>% 
  select(-cpi,-PA.NUS.PPP,-adjustment,-year.y)

# Save non-tidy
df_nontidy_adjusted <- df_tidy_adjusted %>% 
  mutate(n = row_number()) %>% 
  pivot_wider(names_from = module,values_from = oops) %>% 
  group_by(hhid_compilation) %>% 
  mutate(Consumption = first(Consumption),
         Health = last(Health)) %>% 
  select(-n) %>% 
  ungroup() %>% 
  distinct()
  
head(df_nontidy_adjusted)

  

# Check - good
tab2 <- df_nontidy_adjusted %>% group_by(survey) %>% 
  summarise(Health = mean(Health, na.rm = TRUE),
            Consumption = mean(Consumption, na.rm = TRUE))


# Tidy adjusted
saveRDS(df_tidy_adjusted, file = "LSMScompilation_tidy_PPPadjusted")
write_csv(df_tidy_adjusted, "LSMScompilation_tidy_PPPadjusted.csv")
# Non-Tidy adjusted
saveRDS(df_nontidy_adjusted, file = "LSMScompilation_nontidy_PPPadjusted")
write.csv(df_nontidy_adjusted, "LSMScompilation_nontidy_PPPadjusted.csv")





