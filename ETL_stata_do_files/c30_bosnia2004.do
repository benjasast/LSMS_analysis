clear all
*******************************************************************************
					*** LSMS Compilation ****
*******************************************************************************
* Program: Ethiopia Consumption
* File Name: c30_bosnia2004
* RA: Benjamin Sas
* PI: Karen Grepin
* Date: 23/04/20
* Version: 1				
*******************************************************************************
* Objective: 	* Obtain consumption
				* FP indicators
				* episodic health.
				* Asset list	
*******************************************************************************


*******************************************************************************
*******************************************************************************
						* I.   * Bosnia 2004
*******************************************************************************
*******************************************************************************

cd "/Users/bsastrakinsky/Dropbox/LSMS_Compilation/Data/bosnia_2004"

*----------------------------------------------------------*
*1.0. Aggregate Consumption
*----------------------------------------------------------*
use poverty1, clear


clonevar hhid = hid
gen paasche = adjyrcon / yrcons
rename adjyrcon total_consumption

* Generate 
gen food_consumption = totfoodc * paasche
gen nonfood_consumption = total_consumption - food_consumption


* Grab others
rename 	w4pop		hhweight
rename 	hhldsize	hhsize

rename headage		hhead_age
gen hhead_female = (headsex==2)
gen hhead_married = (headmarr==2)

save aux1, replace


*----------------------------------------------------------*
*2.0. Grab OOPs from Health Module
*----------------------------------------------------------*
use dbhiind_bih, clear


* 14 month recall period (everything)
egen aux_14month = rsum( /// 
	d4_q06 d4_q10 d4_q13 d4_q16 d4_q19 d4_q21 d4_q23 d4_q27)
	
egen healthm_14month = sum(aux_14month) , by(hid)	
	replace healthm_14month = healthm_14month /14*13

* Hospital
egen healthm_hosp_oops = sum(d4_q27) , by(hid)
gen aux = (d4_q25==1)
egen episodic_hosp = max(aux), by(hid)

clonevar health_consumption = healthm_14month


* Grab urban or rural
gen urban  = (d8_q08!=1)

keep health* epi* hid urban
duplicates drop hid, force
save aux2, replace


*----------------------------------------------------------*
*3.0. Merge and calculate FPIs
*----------------------------------------------------------*

use aux1, clear
	merge 1:1 hid using aux2
		drop _merge // perfect

* Add OOPs into total consumption
replace total_consumption = total_consumption + health_consumption if !mi(health_consumption)		
replace nonfood_consumption = nonfood_consumption + health_consumption if !mi(health_consumption)		
		
		
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
gen survey = "Bosnia_2004"
gen year = 2004
save bosnia_2004 , replace



































