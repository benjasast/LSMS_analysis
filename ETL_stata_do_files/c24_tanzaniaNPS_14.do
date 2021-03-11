clear all
*******************************************************************************
					*** LSMS Compilation ****
*******************************************************************************
* Program: Malawi
* File Name: c24_tazaniaNPS_14
* RA: Benjamin Sas
* PI: Karen Grepin
* Date: 02/07/19
* Version: 1				
*******************************************************************************
* Objective: 	* Obtain consumption
				* FP indicators
				* Health Module
*******************************************************************************

cd "~/Dropbox/LSMS_Compilation/Data/tanzania_NPS_08_10_12_14/NPS_14/"

*******************************************************************************
*******************************************************************************
							* Tanzania NPS 2014 *
*******************************************************************************
*******************************************************************************

use consumptionnps4, clear


rename healthR 	health_consumption
rename expmR 	total_consumption
rename foodbevR food_consumption

gen nonfood_consumption = total_consumption - food_consumption


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
	
	gen urban1 = (urban==2)
	drop urban
	rename urban1 urban
	
keep y4_hhid cluster strata hhweight region district ward village ///
ea intyear intmonth urban area mainland hhsize *consumption che*

order y4_hhid* *consumption 


save aux1 , replace



*******************************************************************************
*******************************************************************************
						* II. Household head info  *
*******************************************************************************
*******************************************************************************

use hh_sec_b , clear
rename hh_b* q*


keep if q05==1 // hhead

* 1 head per household
duplicates drop y4_hhid, force // ok


* Some vars
gen hhead_female = (q02==2)
rename q04 hhead_age
gen hhead_married = (q19==1 | q19==2)


* Max level educ
merge 1:1 y4_hhid indidy4 using hh_sec_c , keepus(hh_c03 hh_c07)
	drop if _merge!=3 // no hhead obs
	drop _merge

rename hh_c07 hhead_educ
	replace hhead_educ = 0 if mi(hhead_educ) & !mi(hh_c03)
	

drop hh_c03

keep y4_hhid hhead*
save aux2 , replace




*******************************************************************************
*******************************************************************************
						* III. Health Module  *
*******************************************************************************
*******************************************************************************
use hh_sec_d , clear
rename hh_d* q*


* Injury leading to hospitalization
#delimit ;
local causehosp_list
fever 1
malaria 2
stomach 3
diarrhea 4
headache 5
heart 6
lung 7
brokenbone 8
maternity 9
other 10
;
#delimit cr

	local a = 1
	local b = 2
	
	forval i = 1/10{ // 

		
		local e1: word `a' of `causehosp_list'
		local e2: word `b' of `causehosp_list'
		
		gen causehosp_`e1' = (q12_1== `i' | q12_2)
		
		local a = `a' + 2
		local b = `b' + 2

	}


	
* Save var labels
foreach v of var * {
 	local l`v' : variable label `v'
        if `"`l`v''"' == "" {
 		local l`v' "`v'"
  	}
  }	
	
	

collapse 	(max) q03_1 q03_2 q04_1 q04_2 q11_2 cause* 		///
			(min) q02 q10 q14 q37 q38 q39		///
			, by(y4_hhid)



* put back var labels
  foreach v of var * {
 	label var `v' "`l`v''"
  }
  
  

* Put back value labels
rename q* d*
unab d_list: d*

foreach var in `d_list'{
	label values `var' hh_`var'

}  
rename d* q*
  


* Rename all vars
order y4_hhid q* , seq	
order y4_hhid

rename q02 	health_anyvisit
rename q03_1 health_provider1
rename q03_2 health_provider2
rename q04_1 health_finance1
rename q04_2 health_finance2
rename q10	health_anyhosp12month
rename q11_2 health_hospnights
rename q14 	health_anyhosptrad

rename q37	birth_any
rename q38 	birth_prenatal
rename q39 	birth_place

gen episodic_hosp = (health_anyhosp12month==1)
	


save aux3 , replace



*******************************************************************************
*******************************************************************************
						* IV. Shock Module  *
*******************************************************************************
*******************************************************************************

use HH_SEC_R , clear
rename hh_r* q*
rename shockid code


* Keep only three most important shocks (those with coping strategies)
keep if q02>=1 & q02<=3


* Categories of shocks
gen shock_category =.
	replace shock_category = 1 if ( (code>=101 & code<=103) | code==106 | code==108  )
	replace shock_category = 2 if ( (code>=104 & code<=105) | code==107 )
	replace shock_category = 3 if ( (code==111) )
	replace shock_category = 4 if ( (code>=112 & code<=113) )
	replace shock_category = 5 if ( (code>=109 & code<=110) | (code>=114 & code<=119) )
	
	
label define shock 1 "Agricultural" 2 "Income" 3 "Health" 4 "Death" 5 "Other"
	label values shock_category shock




collapse 	(max) q03 q04_1 q04_2   ///
			(min) q01 ///
			, by(y4_hhid shock_category)
	

* Put back labels, and value labels
rename q* r*

unab r_list: r*
	foreach var in `r_list'{
		label values `var' hh_`var'
	
	}

rename r* q*	

		
			
unab vlist: q*
local j "shock_category"

*Create label for each variable in vlist for each level of J
levelsof `j', local(J)
foreach var of varlist `vlist' {
    foreach j of local J {
        local newlist `newlist' `var'`j'
        local lablist "`lablist' `"`:variable label `var'' (`j')"'"
        }
    }

* Reshape to hh unit
reshape wide q* , i(y4_hhid) j(shock_category)

foreach new of local newlist {
    gettoken lab lablist : lablist
    lab var `new'  "`lab'"
    }
		

		
* Rename
rename q01* 	shock_*
rename q03* 	shockred_*
rename q04_1* shockcope1_*
rename q04_2* shockcope2_*

* Shock names
rename *1 *agricul
rename *2 *income
rename *3 *health
rename *4 *death
rename *5 *other

* Needed later to put zeros on missing values.
local shock_list ///
shock_agricul shock_income shock_health shock_death shock_other


save aux4, replace


*******************************************************************************
*******************************************************************************
						* V. Death Module  *
*******************************************************************************
*******************************************************************************

use hh_sec_s , clear
rename hh_s* q*


* One ob per hh, the first mentioned
duplicates drop y4_hhid, force


* Rename
rename q03 		death_rel
rename q05 		death_sex
rename q07_1 	death_ageyears
rename q07_2 	death_agemonths
rename q09		death_cause
rename q10		death_causenonill
rename q11_1	death_causeill1
rename q11_2 	death_causeill2
rename q12_1 	death_causetime
rename q12_2	death_causetimeunit
rename q13		death_deathdiagnosed
rename q14		death_losslandassets
rename q15		death_lossvalue

keep y4_hhid death*
save aux5 , replace



*******************************************************************************
*******************************************************************************
						* VI. Save  *
*******************************************************************************
*******************************************************************************

use aux1, clear
	merge 1:1 y4_hhid using aux2
		*drop if _merge!=3 // 8 obs 
		drop _merge
		
	merge 1:1 y4_hhid using aux3
		*drop if _merge!=3 // 8 obs 
		drop _merge 

	merge 1:1 y4_hhid using aux4
		*drop if _merge!=3 // 894 obs no shock data
		drop _merge

	local shock_list ///
	shock_agricul shock_income shock_health shock_death shock_other
	
	foreach var in `shock_list'{
	replace `var' = 0 if mi(`var')
	}	
		
	merge 1:1 y4_hhid using aux5
		gen death_any = (_merge==3)
		drop _merge

* Drop those without hhweight (empty)
drop if mi(hhweight)	

order y4_hhid


* Save
cd "~/Dropbox/LSMS_Compilation/Analysis/Output_Files/"
gen survey = "Tanzania_2015"
save tanzaniaNPS_2014 , replace

































	
	
	
