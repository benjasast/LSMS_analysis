clear all
*******************************************************************************
					*** LSMS Compilation ****
*******************************************************************************
* Program: Ethiopia Consumption
* File Name: c27_albania2008
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
						* I. Albania 2008  *
*******************************************************************************
*******************************************************************************

clear all
cd "~/Dropbox/LSMS_Compilation/Data/albania_2008/Data_2008/"

*----------------------------------------------------------*
*1.0. Aggregate Consumption
*----------------------------------------------------------*
use poverty, clear

* Very lacking poverty file
rename totcons 		total_consumption
rename rfood		food_consumption
gen rural = (urbrur==2)
gen nonfood_consumption = total_consumption - food_consumption

* Grab weights
merge 1:1 hh psu using Weight_retro_2008
	drop if _merge!=3 // 2 obs
	drop _merge
	
rename 	Weight_retro hhweight

* cannot find paasche
save aux1, replace

*----------------------------------------------------------*
*2.0. OOPs from health module (only available there)
*----------------------------------------------------------*
use Modul_9A_health, clear

* Keep only numeric vars
ds, has(type long)
keep `r(varlist)' psu hh id m9a_q62

rename m9a_q62 aux_hosp

* Keep only vars that are continuos
unab mvars: m*
	foreach var in `mvars'{
		qui: tab `var'
		if r(r)<4{
			drop `var'
			display "`var' dropped"
		}
	}


* 4 week recall
egen aux = rsum( ///
	m9a_q16 m9a_q17 m9a_q20 m9a_q22 m9a_q23 ///
	m9a_q28 m9a_q29 m9a_q32 m9a_q34 m9a_q35 ///
	m9a_q38 m9a_q39 m9a_q41 m9a_q42 m9a_q43 ///
	m9a_q46 m9a_q47 m9a_q49 m9a_q50 m9a_q51 ///
	m9a_q54 m9a_q55 m9a_q57 m9a_q58 m9a_q59 ///
	m9a_q61 ///
)

egen healthm_4weeks = sum(aux), by(psu hh)
	replace healthm_4weeks = healthm_4weeks*13
	
* 12 month recall
egen aux2 = rsum( ///
	m9a_q68 m9a_q69 m9a_q71 m9a_q72 m9a_q73 ///
	m9a_q76 m9a_q77 m9a_q79 m9a_q80 m9a_q81 ///
	)
egen healthm_12month = sum(aux2), by(psu hh)


* Health consumption
gen health_consumption = healthm_12month + healthm_4weeks


* Hosp
egen aux3 = rsum(m9a_q68 m9a_q69 m9a_q71 m9a_q72 m9a_q73)
	egen healthm_hosp = sum(aux3) , by(psu hh)

gen aux_hosp2 = (aux_hosp==1)
	egen episodic_hosp = max(aux_hosp2) , by(psu hh)

	
	
	
keep psu hh *consumption healthm* epi*
duplicates drop psu hh, force

save aux2, replace


*----------------------------------------------------------*
*3.0. Merge and calculate FPIs
*----------------------------------------------------------*
use aux1, clear
merge 1:1 psu hh using aux2
	drop _merge // perfect match

**** NO PAASCHE FOUND***** IMPOSSIBLE TO RECONCILE TOTAL CONSUMPTION AND
**** CALCULATED HEALTH EXPENDITURES FROM HEALTH MODULE. ****

* Fix consumption - annualize it and add health	

*replace health_consumption = health_consumption * paasche
replace food_consumption = food_consumption * 12
replace nonfood_consumption = nonfood_consumption*12 + health_consumption 
replace total_consumption = total_consumption*12 + health_consumption


* We will just keep health consumption
keep hhid health_consumption healthm* epi* rural



* Save
cd "~/Dropbox/LSMS_Compilation/Analysis/Output_Files/"
gen survey = "Albania_2008"
gen year = 2008
save albania_2008 , replace































