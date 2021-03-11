clear all
*******************************************************************************
					*** LSMS Compilation ****
*******************************************************************************
* Program: Malawi
* File Name: c21_tazaniaNPS_08
* RA: Benjamin Sas
* PI: Karen Grepin
* Date: 19/06/19
* Version: 1				
*******************************************************************************
* Objective: 	* Obtain consumption
				* FP indicators
				* Health Module
*******************************************************************************

cd "~/Dropbox/LSMS_Compilation/Data/tanzania_NPS_08_10_12_14/NPS_08/"

*******************************************************************************
*******************************************************************************
							* Tanzania NPS 2008 *
*******************************************************************************
*******************************************************************************


*******************************************************************************
*******************************************************************************
						* I. Consumption Aggregate  *
*******************************************************************************
*******************************************************************************

use "TZY1.HH.Consumption.dta" , clear

gen deflatorhealth = healthR/health
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

keep hhid *consumption che* ///
hhsize hhweight strata cluster urban region area ///
mainland intmonth intyear month quarter deflatorhealth 

order hhid *consumption


save aux1 , replace




*******************************************************************************
*******************************************************************************
						* II. Household head info  *
*******************************************************************************
*******************************************************************************
use SEC_B_C_D_E1_F_G1_U , clear


rename sb* *
keep if q5==1 // hhead

* 1 head per household
duplicates drop hhid, force // ok


* Some vars
gen hhead_female = (q2==2)
rename q4 hhead_age
gen hhead_married = (q18==1 | q18==2)

* Max level educ
rename scq6 hhead_educ
	replace hhead_educ = 0 if mi(hhead_educ) & !mi(scq2)


keep hhid hhead*	
	
save aux2 , replace


*******************************************************************************
*******************************************************************************
						* III. Health Module  *
*******************************************************************************
*******************************************************************************
use SEC_B_C_D_E1_F_G1_U , clear

keep hhid sd*
rename sd* *



* Injuries present in hh
# delimit ;
local handicap_list
blind 1
deaf 2
speak 3
misslimb 4
lame 5
mental 6
other 7
;
# delimit cr


	local a = 1
	local b = 2
	
	forval i = 1/7{ // 

		
		local e1: word `a' of `handicap_list'
		local e2: word `b' of `handicap_list'
		
		gen handicap_`e1' = (q13== `i')
		
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
	

collapse 	(max)  q2_1 q2_2 q3_1 q3_2 hand*		///
			(min) q1b q4 q8 q10 q12 q21 q22 q23		///
			, by(hhid)

* put back var labels
  foreach v of var * {
 	label var `v' "`l`v''"
  }
  
* Put back value labels
unab q_list: q*
rename `q_list' , upper
unab Q_list: Q*

foreach var in `Q_list'{
	label values `var' SD`var'

}  
rename `Q_list' , lower
			
			
* Rename all vars
order hhid q* , seq	

rename q1b 	health_anyvisit
rename q2_1 health_provider1
rename q2_2 health_provider2
rename q3_1 health_finance1
rename q3_2 health_finance2
rename q4 	health_anyhosp4weeks
rename q8	health_anyhosp12month
rename q10 	health_anyhosptrad
rename q12	handicap_any
rename q21	birth_any
rename q22 	birth_prenatal
rename q23 	birth_place

gen episodic_hosp = (health_anyhosp4weeks==1 | health_anyhosp12month==1)

	
order hhid health* hand* birth*
save aux3 , replace		


*******************************************************************************
*******************************************************************************
						* IV. Shock Module  *
*******************************************************************************
*******************************************************************************
use SEC_R , clear
rename sr* *

* Keep only three most important shocks (those with coping strategies)
keep if q2>=1 & q2<=3


* Categories of shocks
gen shock_category =.
	replace shock_category = 1 if ( (code>=101 & code<=103) | code==106 | code==108  )
	replace shock_category = 2 if ( (code>=104 & code<=105) | code==107 )
	replace shock_category = 3 if ( (code==111) )
	replace shock_category = 4 if ( (code>=112 & code<=113) )
	replace shock_category = 5 if ( (code>=109 & code<=110) | (code>=114 & code<=119) )
	
	
label define shock 1 "Agricultural" 2 "Income" 3 "Health" 4 "Death" 5 "Other"
	label values shock_category shock


collapse 	(max) q3 q4 q5year q5month   ///
			(min) q1 ///
			, by(hhid shock_category)

			
* Put back value labels
unab q_list: q*
rename `q_list' , upper
unab Q_list: Q*

foreach var in `Q_list'{
	label values `var' SR`var'

}  
rename `Q_list' , lower
			
			
			
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
reshape wide q* , i(hhid) j(shock_category)

foreach new of local newlist {
    gettoken lab lablist : lablist
    lab var `new'  "`lab'"
    }
	
			
* Rename
rename q1* 	shock_*
rename q3* 	shockred_*
rename q4*	shockaff_*
rename q5month* shockmonth_*
rename	q5year* shockyear_*

* Shock names
rename *1 *agricul
rename *2 *income
rename *3 *health
rename *4 *death
rename *5 *other

save aux4, replace


*******************************************************************************
*******************************************************************************
						* V. Death Module  *
*******************************************************************************
*******************************************************************************
use SEC_S2 , clear
rename ss* *

* One ob per hh, the first mentioned
duplicates drop hhid, force


* Rename
rename q3 		death_rel
rename q4 		death_sex
rename q5yr 	death_ageyears
rename q5mnth 	death_agemonths
rename q8		death_cause
rename q9		death_causenonill
rename q10_1	death_causeill1
rename q10_2 	death_causeill2
rename q11_1 	death_causetime
rename q11_2	death_causetimeunit
rename q12		death_deathdiagnosed
rename q13		death_losslandassets
rename q14		death_lossvalue


save aux5 , replace


*******************************************************************************
*******************************************************************************
						* VI. Verify OOPs from health module  *
*******************************************************************************
*******************************************************************************
/*
use SEC_B_C_D_E1_F_G1_U , clear

egen aux = rsum(sdq5 sdq6 sdq7)
	egen aux2 = sum(aux) , by(hhid) // 2 week recall

gen healthm_2week = aux2 * 13 * 2 // annualized

egen aux3 = rsum(sdq9 sdq11) // 12 month recall
	egen aux4 = sum(aux3), by(hhid)
	
gen healthm_hosp_oops = aux4

* OOPs from health module annualized
gen healthm_oops = healthm_2week + healthm_hosp_oops


duplicates drop hhid, force
keep healthm* hhid

save aux6, replace
	
*/






*******************************************************************************
*******************************************************************************
						* VI. Save  *
*******************************************************************************
*******************************************************************************
clear all

use aux1, clear
	merge 1:1 hhid using aux2
		drop _merge // perfect match
		
	merge 1:1 hhid using aux3
		drop _merge // perfect match

	merge 1:1 hhid using aux4
		*drop if _merge!=3 // only 311 without obs
		drop _merge

	merge 1:1 hhid using aux5
		gen death_any = (_merge==3)
		drop _merge
		
/*	
* Verify OOPs		
	merge 1:1 hhid using aux6
		drop _merge


unab health_list: healthm*

foreach var in `health_list'{
	replace `var' = `var' * deflatorhealth
	replace `var' = 0 if mi(`var')
}

gen aux = healthm_2week / 13 / 2
gen nonhosp = health_consumption - healthm_hosp
gen multiplier = nonhosp/aux

// They multiplied 2 weeks expenses by 13!!!, a mistake on the survey,
// or trying to control for something??
*/



		
* Save
cd "~/Dropbox/LSMS_Compilation/Analysis/Output_Files/"
gen survey = "Tanzania_2009"
save tanzaniaNPS_2008 , replace

				






















































