
# Adjust by PPP -----------------------------------------------------------

library(tidyverse)
library(quantmod)
library(magrittr)
library(dplyr)


rm(list=ls())


# Load --------------------------------------------------------------------

# Country currency tibble
tab_currency <- read_csv("~/Dropbox/LSMS_Compilation/Data/Tab_currencies_country.csv")
tab_currency

# PPP data
tab_ppp <- read_csv("~/Dropbox/LSMS_Compilation/Data/2011_PPP_household_expenditures.csv") %>% 
  rename(country = Country)

# Df nontidy
df_nontidy <- read.csv2("LSMScompilation_nontidy.csv")


# Prepare Data ------------------------------------------------------------

# Table with country-currency-PPP
tab_country <- tab_currency %>% 
  left_join(tab_ppp) %>% 
  na.omit() %>% 
  mutate(country = ifelse(country=="Bosnia and Herzegovina","Bosnia",country)) # Fix bosnia


# Countries to evaluate - those in the survey
surveys <- df_nontidy %>% 
  select(survey) %>% 
  distinct()

# Grab countries
country_list <- surveys$survey %>% 
  str_extract(pattern = "^[a-zA-Z]*") %>% 
  str_extract(pattern = "[A-Z]*[a-z]*")

# Include surveys
survey_country_list <- tibble(country = country_list,survey = surveys$survey)

# Get min and max year per country
country_years <- surveys %>% 
  left_join(survey_country_list) %>% 
  mutate(aux_year = as.numeric( str_extract(survey,pattern = "\\d*$") ),
         year = ifelse(aux_year<100,aux_year+2000,aux_year)) %>% 
  group_by(country) %>% 
  summarise(min_year = min(year,na.rm = TRUE),
            max_year = max(year,na.rm = TRUE))


# Create final table to use to grab information - it has each country used, with max and min year and PPP
df_survey_currency <- country_years %>% 
  left_join(tab_country) %>% 
  mutate(aux_currency = str_c(currency,"=X"))
  
df_survey_currency


# Extract Forex info for each country -------------------------------------


# Extracts Forex information between date1 and date2 and returns the latest FX
grab_closeyear_fx <- function(date1,date2,currency){
  #name_fx <- str_c(currency,"=X") # option without aux_currency
  name_fx <- currency # option with aux_currency
  price <- getSymbols(name_fx,src="yahoo",from=date1, to =date2, auto.assign = FALSE)
  df <- price %>% tibble() 
  df_ele <- df$.[]
  last_fx <- df_ele$`UGX=X.Close` %>% tail(1)
  last_fx
}


# LOOP to extract information for each country

# List to store
datalist <-  list()

# country list to loop
df_survey_currency

list <- df_survey_currency %>%
  filter(min_year>2003) %>% 
  select(country) 

list

# counter
i = 1
for (cty in list$country){
  aux_df <- df_survey_currency %>% 
    filter(country==cty)
    
  # Country info
  min_year <- aux_df$min_year[[1]]
  max_year <- aux_df$max_year[[1]]
  curr <- aux_df$aux_currency[[1]]
  
  
  # For calculations
  years <- seq(min_year,max_year) %>% as.character()
  start <- "-12-20"
  end <- "-12-31"
    
  start_list <- str_c(years,start)
  end_list <- str_c(years,end)
  
  # Get closing year FX for all years of cty
  cty_fx <- map2(start_list,end_list,grab_closeyear_fx, currency=curr) %>% unlist
  cty_fx2 <- tibble(cty_fx,year = years, country = cty)
  
  # Add to storing df
  datalist[[i]] <-  cty_fx2
  i = i + 1

}




price <- getSymbols("ALL=X",src="yahoo",from="2002-12-20", to = "2002-12-31", auto.assign = FALSE)
price






# Uganda
years <- c(seq(2005,2014)) %>% as.character()
start <- "-12-20"
end <- "-12-31"

start_list <- str_c(years,start)
end_list <- str_c(years,end)


grab_closeyear_fx <- function(date1,date2,currency){
  name_fx <- str_c(currency,"=X")
  price <- getSymbols(name_fx,src="yahoo",from=date1, to =date2, auto.assign = FALSE)
  df <- price %>% tibble() 
  df_ele <- df$.[]
  last_fx <- df_ele$`UGX=X.Close` %>% tail(1)
  last_fx
}

# Get closing year FX for all years of Uganda
uganda <- map2(start_list,end_list,grab_closeyear_fx, currency="ALL") %>% unlist()
uganda

df_fx <- tibble(country = "Uganda", fx = uganda ,year = as.numeric(years)) 
df_fx
  



grab_closeyear_fx("2012-12-20","2015-12-31","UGX")
getSymbols("UGX=X",src="yahoo",from="2010-12-30", to ="2010-12-30" )

