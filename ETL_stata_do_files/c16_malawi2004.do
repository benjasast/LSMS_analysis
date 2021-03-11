clear all
*******************************************************************************
					*** LSMS Compilation ****
*******************************************************************************
* Program: Malawi
* File Name: c16_malawi2004
* RA: Benjamin Sas
* PI: Karen Grepin
* Date: 10/06/19
* Version: 1				
*******************************************************************************
* Objective: 	* Obtain consumption
				* FP indicators
				* Health Module
*******************************************************************************

*******************************************************************************
*******************************************************************************
							* Malawi 2014 *
*******************************************************************************
*******************************************************************************

cd "~/Dropbox/LSMS_Compilation/Data/malawi_2004/"

*******************************************************************************
*******************************************************************************
						* I. Consumption Aggregate  *
*******************************************************************************
*******************************************************************************

use ihs2_household , clear

gen date_month = month(idate)
gen date_year = year(idate)

* rename vars
rename hh* hhead_*
rename hhead_wght hhweight
rename hhead_size	hhsize

gen urban = (reside==0)

destring case_id, replace

gen hhead_married = (hhead_mar==1)


local wi_vars g01 g11 g13 g20 roof floor water toilet rubbish // Wealth index vars
foreach var in `wi_vars'{
	rename `var' wi_`var'
}


rename rexpagg total_consumption
rename rexpfood food_consumption
rename rexpnfd nonfood_consumption
rename rexp_cat06 health_consumption



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

	
keep 	dist ta ea case_id hhweight strata region reside type hhsize ///
		idate hhead* wi* child boys girls adult madult fadult elderly ///
		melder felder emp unemp active poor ultra_poor *_consumption che* price_index urban  	
	
save aux1 , replace	


*******************************************************************************
*******************************************************************************
						* II. Health Module  *
*******************************************************************************
*******************************************************************************

use sec_d , clear

destring case_id , replace

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

* Disability list
# delimit;
local disability_list
misshand 1
missfoot 2
lame 3
blind 4
deaf 5
mute 6
mental 7
other 8
;
# delimit cr	

	local a = 1
	local b = 2
	
	forval i = 1/8{ // 

		
		local e1: word `a' of `disability_list'
		local e2: word `b' of `disability_list'
		
		gen disability_`e1' = (d23a==`i' | d23b==`i' | d23c==`i')
		
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
		
		gen chronic_`e1' = (d27a==`i' | d27b==`i')
		
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


collapse 	(max) ill* disability* chronic* d07a d07b d09 d11 d28a ///
			(min) d04 d06a d06b d08 d10 d15 d18 d22 d26 d35 d36 d37 d38 ///
			, by(case_id)



* put back var labels
  foreach v of var * {
 	label var `v' "`l`v''"
  }


* Put value labels
unab d_list: d*
foreach var in `d_list'{
	label values `var' `var'

} 


* rename vars
rename d07a ill_action1
rename d07b ill_action2
rename d09 ill_dayslost
rename d11 ill_dayslostother

rename d28a chronic_years
rename d04 ill_any
rename d06a ill_diagnosis1
rename d06b ill_diagnosis2

rename d08 ill_stopactivities
rename d10 ill_otherstopactivities
rename d15 ill_hospitalization
rename d18 ill_overnighttrad

rename d22 disability_any
rename d26 chronic_any
rename d35 birth_any
rename d36 birth_prenatal
rename d37 birth_place
rename d38 birth_prof


* Grab episodic hosp
gen episodic_hosp = (ill_hospitalization==1)


save aux2 , replace


*******************************************************************************
*******************************************************************************
						* III. Shock Module  *
*******************************************************************************
*******************************************************************************


use sec_ab , clear

destring case_id , replace

* Keep only three most important shocks (those with coping strategies)
keep if ab03>=1 & ab03<=3


* Categories of shocks
gen shock_category =.
	replace shock_category = 1 if ( (ab02>=101 & ab02<=103) | ab02==107 )
	replace shock_category = 2 if ( (ab02>=104 & ab02<=106) | ab02==108 )
	replace shock_category = 3 if ( (ab02>=109 & ab02<=110) )
	replace shock_category = 4 if ( (ab02>=111 & ab02<=112) )
	replace shock_category = 5 if ( (ab02>=114 & ab02<=118) )
	
	
label define shock 1 "Agricultural" 2 "Income" 3 "Health" 4 "Death" 5 "Other"
	label values shock_category shock


local fix_list 	ab06b ab07a ab07b ab07c
	foreach var in `fix_list'{
		replace `var' = . if `var' == 99
	}
	
	
	
* Collapse answers to shock cateogory
collapse 	(max) ab04 ab06a ab06b ab07a ab07b ab07c ///
			(min) ab01 ab05 ///
			, by(case_id shock_category)

* Put back value labels
unab vlist: ab*
foreach var in `vlist'{
	label values `var' `var'
}
			
			
			
drop if shock_category==.		



unab vlist: ab*
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
reshape wide ab* , i(case_id) j(shock_category)


foreach new of local newlist {
    gettoken lab lablist : lablist
    lab var `new'  "`lab'"
    }


	
	
* Rename
rename ab01* shock_*
rename ab04* shockincome_*
rename ab05* shockaff_*
rename ab06a* shockyear*
rename ab06b* shockmonth*
rename ab07a* shockcope1_*
rename ab07b* shockcope2_*
rename ab07c* shockcope3_*


* Shock names
rename *1 *agricul
rename *2 *income
rename *3 *health
rename *4 *death
rename *5 *other


* Save
save aux3, replace


*******************************************************************************
*******************************************************************************
						* IV. Death Module  *
*******************************************************************************
*******************************************************************************
use sec_ac , clear

destring case_id , replace

* One ob per hh, the first mentioned
duplicates drop case_id, force



* Rename
rename ac04 	death_rel 
rename ac05 	death_sex
rename ac06a 	death_ageyears
rename ac06b 	death_agemonths
rename ac07 	death_work
rename ac08 	death_cause
rename ac09		death_causenonill
rename ac10a	death_causeill1
rename ac10b	death_causeill2
rename ac11a	death_causeilltime
rename ac11b	death_causeilltunit
rename ac12		death_deathdiagnosed
rename ac13		death_losslandassets
rename ac14		death_lossvalue


keep case_id death*



save aux4 , replace

*******************************************************************************
*******************************************************************************
			* V. Verify OOPs from consumption module  *
*******************************************************************************
*******************************************************************************

use ihs2_exp, clear
keep case_id exp_cat061 exp_cat062 exp_cat063
destring case_id, replace


save aux5, replace


*******************************************************************************
*******************************************************************************
						* V. Save  *
*******************************************************************************
*******************************************************************************

use aux1, clear

	* Health Module
	merge 1:1 case_id using aux2
		drop _merge // perfect merge
	
	* Shock Module
	merge 1:1 case_id using aux3
		local zero_list shock_agricul shock_income shock_health shock_death shock_other
			foreach var in `zero_list'{
				replace `var' = 0 if _merge==1 // give value zero, we dropped no's from shock module.
			}
	drop _merge
	
	
	* Death Module
	merge 1:1 case_id using aux4
		gen death_any = (_merge==3)
			label var death_any "Any death in hh in las 24 months"
		drop _merge
		
	* Verification	
	merge 1:1 case_id using aux5
		drop _merge
		
	* Check if health_consumption incldues hospitalization
	egen health_consumption2 = rsum(exp_cat061 exp_cat062 exp_cat063)
		replace health_consumption2 = health_consumption2*price_index /100 // cents to dollar		
		
		
* Save
cd "~/Dropbox/LSMS_Compilation/Analysis/Output_Files/"
gen survey = "Malawi_2005"
save malawi_2004 , replace

	
	

























