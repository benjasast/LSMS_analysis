clear all
*******************************************************************************
					*** LSMS Compilation ****
*******************************************************************************
* Program: Malawi
* File Name: c18_malawi2013
* RA: Benjamin Sas
* PI: Karen Grepin
* Date: 19/06/19
* Version: 1				
*******************************************************************************
* Objective: 	* Obtain consumption
				* FP indicators
				* Health Module
*******************************************************************************

cd "~/Dropbox/LSMS_Compilation/Data/malawi_2013/"

*******************************************************************************
*******************************************************************************
							* Malawi 2013 *
*******************************************************************************
*******************************************************************************


*******************************************************************************
*******************************************************************************
						* I. Consumption Aggregate  *
*******************************************************************************
*******************************************************************************


use "Round 2 (2013) Consumption Aggregate" , clear
destring case_id , replace


gen urban1 = (urban==1)
drop urban
rename urban1 urban


* Rename vars
rename rexpagg 		total_consumption
rename rexp_cat06 	health_consumption
rename rexp_cat01 	food_consumption
gen nonfood_consumption = total_consumption - food_consumption

* Vars we need
keep y2_hhid case_id *consumption poor region urban district strata hhweight hhweightR1 hhsize intmonth intyear



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
	

save aux1 , replace


* HHead info
use HH_MOD_B_10, clear
destring case_id , replace

keep if hh_b04==1
rename hh_b03 hhead_sex
rename hh_b05a hhead_age
rename hh_b18 hhead_educ

gen hhead_married = (hh_b24==1)
gen hhead_female = (hhead_sex==2)

duplicates drop case_id , force
keep case_id hhead*

save aux11, replace



*******************************************************************************
*******************************************************************************
						* II. Health Module  *
*******************************************************************************
*******************************************************************************

use HH_MOD_D_13 , clear
rename hh_* *

* Injuries present in hh
# delimit ;
local ill_list
fevermalaria 1
diarrhea 2
stomach 3
vomiting 4
sorethroat 5
upperrespiratory 6
lowerrespiratory 7
flu 8
asthma 9
headache 10
fainting 11
skinproblem 12
dentalproblem 13
eyeproblem 14
ENT 15
backache 16
heartproblem 17
bloodpressure 18
urine 19
diabetes 20
mentaldisorder 21
TB 22
STD 23
burn 24
fracture 25
wound 26
poisoning 27
pregnancy 28
unspecified_lt 29
other 30
;
# delimit cr

	local a = 1
	local b = 2
	
	forval i = 1/30{ // 

		
		local e1: word `a' of `ill_list'
		local e2: word `b' of `ill_list'
		
		gen ill_`e1' = (d05a==`i' | d05b==`i')
		
		local a = `a' + 2
		local b = `b' + 2

	}
	

* chronic illness
# delimit ;
local chronic_list
malariafever 1
tb 2
hiv 3
diabetes 4
asthma 5
bilharzia 6
arthritis 7
neverdisorder 8
stomachdisorder 9
sores 10
cancer 11
pneumonia 12
other 13
;
#delimit cr	

	local a = 1
	local b = 2
	
	forval i = 1/13{ // 

		
		local e1: word `a' of `chronic_list'
		local e2: word `b' of `chronic_list'
		
		gen chronic_`e1' = (d34a==`i' | d34b==`i')
		
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
	
	
collapse 	(max) ill* chronic* d07a d07b d35a d35b ///
			(min) d04 d06a d06b d13 d17 d18 d33 d36a d36b d40 d41 d42  ///
			, by(y2_hhid)
	
	
* put back var labels
  foreach v of var * {
 	label var `v' "`l`v''"
  }


* Put value labels
unab d_list: d*
rename `d_list' , upper


unab D_list: D*
foreach var in `D_list'{
	label values `var' HH_`var'

} 

rename `D_list' , lower

* Rename Vars
order d* , last sequential

rename d04 ill_any
rename d06a ill_diagnosis1
rename d06b ill_diagnosis2
rename d07a ill_action1
rename d07b ill_action2
rename d13 ill_hospitalization
rename d17 ill_financoping
rename d18 ill_overnighttrad

rename d33 chronic_any
rename d35a chronic_years
rename d35b chronic_months
rename d36a chronic_diagnosis1
rename d36b chronic_diagnosis2

rename d40 birth_any
rename d41 birth_prenatal
rename d42 birth_place

gen episodic_hosp = (ill_hospitalization==1)


save aux2, replace

*******************************************************************************
*******************************************************************************
						* III. Shock Module  *
*******************************************************************************
*******************************************************************************

use HH_MOD_U_13 , clear
rename hh_* *

* Keep only three most important shocks (those with coping strategies)
keep if u01>=1 & u01<=3


* Categories of shocks
gen shock_category =.
	replace shock_category = 1 if ( (u0a>=104 & u0a<=107) )
	replace shock_category = 2 if ( (u0a>=108 & u0a<=113) )
	replace shock_category = 3 if ( (u0a>=114 & u0a<=115) )
	replace shock_category = 4 if ( (u0a>=116 & u0a<=117) )
	replace shock_category = 5 if ( (u0a>=101 & u0a<=103) | (u0a>=118 & u0a<=121) )
	
	
label define shock 1 "Agricultural" 2 "Income" 3 "Health" 4 "Death" 5 "Other"
	label values shock_category shock


local fix_list 	u04a u04b u04c u03a u03b u03c u03d u03e
	foreach var in `fix_list'{
		replace `var' = . if `var' == 99
	}
	

* Collapse answers to shock cateogory
collapse 	(max) u04a u04b u04c  ///
			(min) u01 u03a u03b u03c u03d u03e ///
			, by(y2_hhid shock_category)

			
			
			
			
* Put back value labels
unab ulist: u*
rename `ulist' , upper

unab Ulist: U*
foreach var in `Ulist'{
	label values `var' HH_`var'
} 
rename `Ulist' , lower



* Put in hh observation
drop if shock_category==.		



unab vlist: u*
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
reshape wide u* , i(y2_hhid) j(shock_category)

foreach new of local newlist {
    gettoken lab lablist : lablist
    lab var `new'  "`lab'"
    }


* Rename
rename u01* shock_*
rename u03a* shockincome_*
rename u03b* shockasset_*
rename u03c* shockfood_*
rename u03d* shockfoodstock_*
rename u03e* shockfoodpur_*


rename u04a* shockcope1_*
rename u04b* shockcope2_*
rename u04c* shockcope3_*


* Shock names
rename *1 *agricul
rename *2 *income
rename *3 *health
rename *4 *death
rename *5 *other

* Save 
save aux3 , replace

*******************************************************************************
*******************************************************************************
						* IV. Death Module  *
*******************************************************************************
*******************************************************************************

* No death module in this round.


*******************************************************************************
*******************************************************************************
						* V. Save  *
*******************************************************************************
*******************************************************************************

use aux1, clear

merge 1:1 y2_hhid using aux2
	drop _merge // perfect match
	
merge 1:1 y2_hhid using aux3	
	drop _merge // perfect match

	
* hhead info
duplicates drop case_id , force
merge 1:1 case_id using aux11
	drop if _merge!=3
	drop _merge
	
* Save
cd "~/Dropbox/LSMS_Compilation/Analysis/Output_Files/"
gen survey = "Malawi_2013"
save malawi_2013 , replace

				


























	
	
	
	
	
	
	
	
	
	
	
	
	
	
