clear all
*******************************************************************************
					*** LSMS Compilation ****
*******************************************************************************
* Program: Ethiopia Consumption
* File Name: c01_ethiopia2015
* RA: Benjamin Sas
* PI: Karen Grepin
* Date: 10/04/19
* Version: 1				
*******************************************************************************
* Objective: 	* Obtain consumption
				* FP indicators
				* episodic health.
				* Asset list	
*******************************************************************************


*******************************************************************************
*******************************************************************************
						* I. Ethiopia 2015  *
*******************************************************************************
*******************************************************************************
clear all

* Dir
cd "/Users/bsastrakinsky/Dropbox/LSMS_Compilation/Data/ethiopia_2015/"

*----------------------------------------------------------*
*1.0. Aggregate Consumption
*----------------------------------------------------------*

use "~/Dropbox/LSMS_Compilation/Data/ethiopia_2015/ETH_2015_ESS_v01_M_STATA8/Consumption Aggregate/cons_agg_w3.dta"

rename household_id 	hhid
rename household_id2	hhid_oldwave
rename pw_w3			hhweight

*Only keep those with positive consumption
keep if no_cons==0

* rename consumption vars
rename total_cons_ann		total_consumption
rename food_cons_ann		food_consumption
gen nonfood_consumption = 	total_consumption - food_consumption


* Rename other vars
rename hh_size		hhsize
gen urban =			(rural==2 | rural==3) if !mi(rural)
rename cons_quint	consumption_quintile


keep hhid hhid_oldwave ea_id saq01 rural hhweight adulteq hhsize ///
 food_consumption total_consumption price_index_hce consumption_quintile nonfood_consumption urban


duplicates drop hhid, force // 6 households
save aux1.dta   , replace


*----------------------------------------------------------*
*2.0. OOPs from Health Module
*----------------------------------------------------------*
clear
use "~/Dropbox/LSMS_Compilation/Data/ethiopia_2015/ETH_2015_ESS_v01_M_STATA8/Household/sect3_hh_w3.dta"

*ID
rename household_id hhid

* OOPs
egen health_consumption = sum(hh_s3q10) , by(hhid)

* OOPs by month
egen health_consumption_month = sum(hh_s3q06c), by(hhid)

* Episodic hospitalization
gen hosp = (hh_s3q09b>0) if !mi(hh_s3q09b)
egen episodic_hosp = max(hosp) , by(hhid)
	replace episodic_hosp = 0 if mi(episodic_hosp)


collapse health* epi* , by(hhid)
save aux2, replace

	*----------------------------------------------------------*
	*2.1 FP Indicators
	*----------------------------------------------------------*
	
	use aux1, clear
	merge 1:1 hhid using aux2
	drop if _merge!=3
	
* Add OOPs into total consumption
replace total_consumption = total_consumption + health_consumption if !mi(health_consumption)		
replace nonfood_consumption = nonfood_consumption + health_consumption if !mi(health_consumption)		
		
	
	
	* 10% total consumption
	gen che1_10 = (health_consumption/total_consumption)>=.1

	* 40% non-food
	gen che2_40 = (health_consumption/nonfood_consumption)>=.4

	* 40% non-subsistence
	gen foodeq = food_consumption / hhsize^0.56
	gen sharefood = food_consumption / total_consumption

	* Grab 45-55 percentiles of share of food households
	xtile percentiles = sharefood, nq(100)
		sum foodeq if percentiles>=45 & percentiles<=55
			scalar pline2 = r(mean)

	* Generate non-subssitence consumption
	gen nonsub_consumption = total_consumption - scalar(pline2)*hhsize^0.56

	* Gen CHE
	gen che3_40 = (health_consumption/nonsub_consumption)>=.4
	drop percentiles sharefood foodeq
	
	save aux3, replace
	
*******************************************************************************
*******************************************************************************
						* II. Household head info  *
*******************************************************************************
*******************************************************************************

* Grab hhead id
use "~/Dropbox/LSMS_Compilation/Data/ethiopia_2015/ETH_2015_ESS_v01_M_STATA8/Household/sect1_hh_w3.dta", clear
keep if  hh_s1q02==1

rename household_id hhid
rename hh_s1q00 hhead_id

gen hhead_female 	= (hh_s1q03==2)
rename hh_s1q04a	hhead_age 

gen hhead_married = (hh_s1q08==2 | hh_s1q08==3)

keep hhid individual_id hhead*
duplicates drop individual_id, force // 2 observations
save aux4, replace

* Education of hhead
use "~/Dropbox/LSMS_Compilation/Data/ethiopia_2015/ETH_2015_ESS_v01_M_STATA8/Household/sect2_hh_w3", clear
duplicates drop individual_id, force
merge 1:1 individual_id using aux4
drop if _merge!=3

recode hh_s2q05 ///
	(93 94 95 96 98 99 = 0 "No education") ///
	(1/11 21/23 31/33 = 1 "Elementary School") ///
	(12/18 24/29 = 2 "High School") ///
	(19 20 30 34 35 = 3 "Higher education"), ///
	gen(hhead_education)
	
replace hhead_education = 0 if 	hh_s2q03==2
keep hhid hhead*

duplicates drop hhid, force	
save aux4, replace


*******************************************************************************
*******************************************************************************
						* IV. Consolidate  *
*******************************************************************************
*******************************************************************************

use aux3, clear
drop _merge

merge 1:1 hhid using aux4
drop if _merge!=3
drop _merge



* Save
cd "~/Dropbox/LSMS_Compilation/Analysis/Output_Files/"
gen survey = "Ethiopia_2016"
save ethiopia_2015 , replace
























































