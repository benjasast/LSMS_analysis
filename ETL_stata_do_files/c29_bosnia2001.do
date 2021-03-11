clear all
*******************************************************************************
					*** LSMS Compilation ****
*******************************************************************************
* Program: Ethiopia Consumption
* File Name: c29_bosnia
* RA: Benjamin Sas
* PI: Karen Grepin
* Date: 22/04/20
* Version: 1				
*******************************************************************************
* Objective: 	* Obtain consumption
				* FP indicators
				* episodic health.
				* Asset list	
*******************************************************************************


*******************************************************************************
*******************************************************************************
						* I.   * Bosnia 2001
*******************************************************************************
*******************************************************************************

cd "/Users/bsastrakinsky/Dropbox/LSMS_Compilation/Data/bosnia_2001"

*----------------------------------------------------------*
*1.0. Aggregate Consumption
*----------------------------------------------------------*
use POVERTY1, clear

* Grab deflator and total consumption
gen paasche = adjyrcon/yrcons
rename adjyrcon total_consumption

* Generate 
gen food_consumption = totfoodc * paasche
gen nonfood_consumption = total_consumption - food_consumption


* Grab others
rename 	whhd		hhweight
rename 	hhldsize	hhsize
egen 	hhid = group(muncode hid gnd numis)

rename headage		hhead_age
gen hhead_female = (headsex==2)
gen hhead_married = (headmarr==2)

save aux1, replace

*----------------------------------------------------------*
*1.1. Urban or rural
*----------------------------------------------------------*
use M8, clear

gen urban = (m8_q03!=2)
keep urban muncode hid gnd numis
duplicates drop muncode hid gnd numis , force

merge 1:1 muncode hid gnd numis using aux1 // perfect match
	drop _merge

save aux1, replace

*----------------------------------------------------------*
*2.0. Grab OOPs from Health Module
*----------------------------------------------------------*
use M4_A , clear

* 4 week recall
egen aux_4weeks = rsum( ///
	m4_q08 m4_q9a m4_q9b m4_q10a m4_q10b m4_q11 ///
	m4_q16 m4_q17a m4_q17b m4_q18a m4_q18b m4_q19 ///
	m4_q36 m4_q37a m4_q37b m4_q38a m4_q38b m4_q39 ///
	m4_q43 m4_q44a m4_q44b m4_q45a m4_q45b ///
	m4_q48 m4_q49a m4_q49b m4_q50a m4_q50b ///
	m4_q52)
	
egen healthm_4weeks = sum(aux_4weeks) , by(muncode hid gnd numis)
		replace healthm_4weeks = healthm_4weeks * 13

egen aux_12month = rsum( /// 
	m4_q23 m4_q24a m4_q24b m4_q25a m4_q25b m4_q26 ///
	m4_q30 m4_q31a m4_q31b m4_q32 ///
	m4_q57 m4_q58a m4_q58b m4_q59a m4_q59b)
	
	
egen healthm_12month = sum(aux_12month) , by(muncode hid gnd numis)


* Health Consumption
egen health_consumption = rsum(healthm_4weeks healthm_12month)


egen aux_hospital = rsum( ///
	m4_q57 m4_q58a m4_q58b m4_q59a m4_q59b)
	
egen healthm_hosp_oops = sum(aux_hospital), by(muncode hid gnd numis)

gen aux_episodic = (m4_q54==1)
	egen episodic_hosp = max(aux_episodic) , by(muncode hid gnd numis)


keep health* epi* muncode hid gnd numis
duplicates drop muncode hid gnd numis, force

save aux2, replace


*----------------------------------------------------------*
*3.0. Merge and calculate FPIs
*----------------------------------------------------------*
use aux1, clear
merge 1:1 muncode hid gnd numis using aux2
	drop _merge // perfect
	
	
* Fix consumption -  add health	
replace health_consumption = health_consumption * paasche
replace nonfood_consumption = nonfood_consumption + health_consumption 
replace total_consumption = total_consumption + health_consumption


	*----------------------------------------------------------*
	*3.1 FP Indicators
	*----------------------------------------------------------*
	
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


* Save
cd "~/Dropbox/LSMS_Compilation/Analysis/Output_Files/"
gen survey = "Bosnia_2001"
gen year = 2001
save bosnia_2001 , replace





