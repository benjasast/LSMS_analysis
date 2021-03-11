clear all
*******************************************************************************
					*** LSMS Compilation ****
*******************************************************************************
* Program: Ethiopia Consumption
* File Name: c26_ecuador2014
* RA: Benjamin Sas
* PI: Karen Grepin
* Date: 17/03/20
* Version: 1				
*******************************************************************************
* Objective: 	* Obtain consumption
				* FP indicators
				* episodic health.
				* Asset list	
*******************************************************************************


*******************************************************************************
*******************************************************************************
						* I. Albania 2002  *
*******************************************************************************
*******************************************************************************
clear all
cd "~/Dropbox/LSMS_Compilation/Data/albania_2002/"

*----------------------------------------------------------*
*1.0. Aggregate Consumption
*----------------------------------------------------------*
use poverty, clear


rename totcons1 	total_consumption
rename food			food_consumption
rename weight 		hhweight
rename psupind 		paasche


gen nonfood_consumption = total_consumption - food_consumption
drop rural
gen rural = (urbrur==2)
drop urban
gen urban = (urbrur!=2)


drop hhsize
egen hhsize = rsum(child adult elder)


save aux1, replace

*----------------------------------------------------------*
*2.0. Grab household characteristics
*----------------------------------------------------------*
use hhroster_cl, clear

* Keep only hhead
keep if m1_q03==1

* HHead characteristics
gen hhead_age = m1_q05y
gen hhead_married = (m1_q06==1)


*----------------------------------------------------------*
*2.0. Grab OOPs from Health Module (only found here)
*----------------------------------------------------------*

* 4 week recall
egen aux_outpatient = 	rsum(m5a_q14 m5a_q15 m5a_q17 m5a_q18 m5a_q20 m5a_q21)
egen aux_privdoctor = 	rsum(m5a_q24 m5a_q25 m5a_q27 m5a_q28 m5a_q29)
egen aux_nursemid = 	rsum(m5a_q32 m5a_q33 m5a_q35 m5a_q36 m5a_q37)
egen aux_altmed = 		rsum(m5a_q40 m5a_q41 m5a_q43 m5a_q44 m5a_q45)
egen aux_owndrug = 		rsum(m5a_q47)

* 12 month recall
egen aux_hosp = 		rsum(m5a_q53 m5a_q54 m5a_q56 m5a_q57 m5a_q58)
egen aux_dentist = 		rsum(m5a_q61 m5a_q62 m5a_q64 m5a_q65 m5a_q66)


* Get household estimate
unab aux_list: aux*

foreach var in `aux_list'{
	egen `var'2 = sum(`var') , by(hhid)
}


* 4 week recall consumption
egen healthm_4week = rsum(aux_outpatient2 aux_privdoctor2 aux_nursemid2 ///
							aux_altmed2 aux_owndrug2)

							replace healthm_4week = healthm_4week	* 13						
							
* 12 month recall							
egen healthm_12month = rsum(aux_hosp2 aux_dentist2)
rename aux_hosp2 healthm_hosp_oops


* Health consumption by hh
egen health_consumption = rsum(healthm_12month healthm_4week)							

* Hospitalization in household
gen aux = (m5a_q48==1)
	egen episodic_hosp = max(aux) , by(hhid)

keep hhid *_consumption health* epi* hhead*

duplicates drop hhid, force
save aux2, replace

*----------------------------------------------------------*
*3.0. Merge and calculate FPIs
*----------------------------------------------------------*
use aux1, clear
merge 1:1 hhid using aux2
	drop _merge

	
* Fix consumption - annualize it and add health	
replace health_consumption = health_consumption * paasche
replace food_consumption = food_consumption * 12
replace nonfood_consumption = nonfood_consumption*12 + health_consumption 
replace total_consumption = total_consumption*12 + health_consumption



	*----------------------------------------------------------*
	*1.2 FP Indicators
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
gen survey = "Albania_2002"
gen year = 2002
save albania_2002 , replace


































