clear all
*******************************************************************************
					*** LSMS Compilation ****
*******************************************************************************
* Program: Ethiopia Consumption
* File Name: c27_albania2005
* RA: Benjamin Sas
* PI: Karen Grepin
* Date: 21/04/20
* Version: 1				
*******************************************************************************
* Objective: 	* Obtain consumption
				* FP indicators
				* episodic health.
				* Asset list	
*******************************************************************************


*******************************************************************************
*******************************************************************************
						* I. Albania 2005  *
*******************************************************************************
*******************************************************************************

clear all
cd "~/Dropbox/LSMS_Compilation/Data/albania_2005/"

*----------------------------------------------------------*
*1.0. Aggregate Consumption
*----------------------------------------------------------*
use poverty, clear


rename totcons 		total_consumption
rename food			food_consumption
rename weight 		hhweight
rename psupind 		paasche
rename famsize 		hhsize

gen urban = (m0_ur!=2) 
gen nonfood_consumption = total_consumption - food_consumption


save aux1, replace

*----------------------------------------------------------*
*1.1. Hhead
*----------------------------------------------------------*
use household_rosterA_cl, clear

* head only
keep if m1a_q03==1

gen hhead_female = (m1a_q02==2)
gen hhead_age = m1a_q5y

keep hhead* hhid

merge 1:1 hhid using aux1 
	drop if _merge!=3 
	drop _merge
	
save aux2, replace


*----------------------------------------------------------*
*2.0. OOPs from health module (only available there)
*----------------------------------------------------------*
use healthA_cl, clear


* 4 week recall
egen aux_outpatient = 	rsum(m9a_q16 m9a_q17 m9a_q19 m9a_q20 m9a_q22 m9a_q23)
egen aux_houtpatient = 	rsum(m9a_q28 m9a_q29 m9a_q31 m9a_q32 m9a_q34 m9a_q35)
egen aux_privdoctor = 	rsum(m9a_q38 m9a_q39 m9a_q41 m9a_q42 m9a_q43)
egen aux_nursemid = 	rsum(m9a_q46 m9a_q47 m9a_q49 m9a_q50 m9a_q51)
egen aux_altmed = 		rsum(m9a_q54 m9a_q55 m9a_q57 m9a_q58 m9a_q59)
egen aux_owndrug = 		rsum(m9a_q61)

* 12 month recall
egen aux_hosp = 		rsum(m9a_q68 m9a_q69 m9a_q71 m9a_q72 m9a_q73)
egen aux_dentist = 		rsum(m9a_q76 m9a_q77 m9a_q79 m9a_q80 m9a_q81)


* Get household estimate
unab aux_list: aux*

foreach var in `aux_list'{
	egen `var'2 = sum(`var') , by(hhid)
}


* 4 week recall consumption
egen healthm_4week = rsum(aux_outpatient2 aux_houtpatient2 aux_privdoctor2 aux_nursemid2 ///
							aux_altmed2 aux_owndrug2)

							replace healthm_4week = healthm_4week	* 13						
							
* 12 month recall							
egen healthm_12month = rsum(aux_hosp2 aux_dentist2)
rename aux_hosp2 healthm_hosp_oops


* Health consumption by hh
egen health_consumption = rsum(healthm_12month healthm_4week)							

* Hospitalization in household
gen aux = (m9a_q62==1)
	egen episodic_hosp = max(aux) , by(hhid)

	
keep hhid *consumption healthm* epi*
duplicates drop hhid, force

save aux3, replace


*----------------------------------------------------------*
*3.0. Merge and calculate FPIs
*----------------------------------------------------------*
use aux2, clear
merge 1:1 hhid using aux3
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
gen survey = "Albania_2005"
gen year = 2005
save albania_2005 , replace























