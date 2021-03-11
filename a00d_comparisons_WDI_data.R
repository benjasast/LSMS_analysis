
# a00d_comparisons_WDI_data -----------------------------------------------

library(tidyverse)
library(magrittr)
library(dplyr)
library(WDI)

# Retrieve comparable WDI data - CHE and OOPs -----------------------------

country_codes <- c("BG","BA","AL","UG","NG","TZ","MW","IQ","GH","ET")

oops_che <- WDI(country=country_codes, indicator = c("SH.XPD.OOPC.PP.CD","SH.UHC.OOPC.10.ZS"),
                start = 1988)


