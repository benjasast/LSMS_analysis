clear all
*******************************************************************************
					*** LSMS Compilation ****
*******************************************************************************
* Program: Malawi
* File Name: c17_malawi2010
* RA: Benjamin Sas
* PI: Karen Grepin
* Date: 11/06/19
* Version: 1				
*******************************************************************************
* Objective: 	* Obtain consumption
				* FP indicators
				* Health Module
*******************************************************************************

cd "~/Dropbox/LSMS_Compilation/Data/malawi_2010/Full_Sample/"


*******************************************************************************
*******************************************************************************
							* Malawi 2010 *
*******************************************************************************
*******************************************************************************


*******************************************************************************
*******************************************************************************
						* I. Consumption Aggregate  *
*******************************************************************************
*******************************************************************************

use ihs3fc2M_consumption , clear


* Rename vars
rename rexpagg 		total_consumption
rename rexp_cat06 	health_consumption
rename rexp_cat01 	food_consumption
gen nonfood_consumption = total_consumption - food_consumption


* Vars we need
keep case_id *consumption

merge 1:1 case_id using "Household/hh_mod_a_filt.dta" , ///
	keepus(reside hh_wgt qx_type hh_a01 hh_a02 hh_a26a_2 hh_a26b_2 hh_a26c_2)
	drop _merge	
	
gen urban = (reside==1)
	
rename reside urban_rural 
rename hh_wgt hhweight


destring case_id , replace
save aux1, replace

* Grab hhszie and hhead characteristics
use "Household/hh_mod_b.dta", clear

destring case_id , replace
egen hhsize = count(id_code) , by(case_id)




* keep only hhead
keep if hh_b04==1
rename id_code hhead_id
rename hh_b03 hhead_sex
rename hh_b18 hhead_education
rename hh_b24 hhead_maritalstatus
rename hh_b05a hhead_age



gen hhead_married = (hhead_maritalstatus==1)
gen hhead_fem = (hhead_sex==2)


duplicates drop case_id , force

save aux2, replace


*******************************************************************************
*******************************************************************************
						* II. Health Module  *
*******************************************************************************
*******************************************************************************

use Household/hh_mod_d , clear
rename hh_* *
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
	

* Disability list (no disabilities in this round)


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

collapse 	(max) ill* chronic* d07a d07b d08 d09 d24 d25 d26 d27 d28 d29 d32 d35a d35b ///
			(min) d06a d06b d13 d17 d18  d33 d36a d36b d40 d41 d42 ///
			, by(case_id)



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
rename d07a ill_action1
rename d07b ill_action2
rename d08 ill_stopactivities
rename d09 ill_otherstopactivities

rename d24 disability2_sight
rename d25 disability2_hear
rename d26 disability2_limp
rename d27 disability2_memory
rename d28 disability2_selfcare
rename d29 disability2_communication

rename d32 disability2_measuresimprov

rename d35a chronic_years
rename d35b chronic_months

rename d06a ill_diagnosis1
rename d06b ill_diagnosis2

rename d13 ill_hospitalization
rename d17 ill_financoping
rename d18 ill_overnighttrad

rename d33 chronic_any
rename d36a chronic_diagnosis1
rename d36b chronic_diagnosis2

rename d40 birth_any
rename d41 birth_prenatal
rename d42 birth_place


gen episodic_hosp = (ill_hospitalization==1)

save aux3 , replace


*******************************************************************************
*******************************************************************************
						* III. Shock Module  *
*******************************************************************************
*******************************************************************************

use Household/hh_mod_u , clear
rename hh_* *


destring case_id , replace

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
			, by(case_id shock_category)

				
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
reshape wide u* , i(case_id) j(shock_category)

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
save aux4 , replace

*******************************************************************************
*******************************************************************************
						* IV. Death Module  *
*******************************************************************************
*******************************************************************************
use Household/hh_mod_w , clear
rename hh_* *

destring case_id , replace

* One ob per hh, the first mentioned
duplicates drop case_id, force



* Rename
rename w04 		death_rel 
rename w05 		death_sex
rename w06a 	death_ageyears
rename w06b 	death_agemonths
rename w08 		death_work
rename w09 		death_cause
rename w10		death_causenonill
rename w11a		death_causeill1
rename w11b		death_causeill2
rename w12a		death_causeilltime
rename w12b		death_causeilltunit
rename w13		death_deathdiagnosed
rename w14		death_losslandassets
rename w15		death_lossvalue


keep case_id death*



save aux5 , replace


*******************************************************************************
*******************************************************************************
						* V. Save  *
*******************************************************************************
*******************************************************************************

use aux1, clear

merge 1:1 case_id using aux2
	drop if _merge!=3 // only 3 obs without hhead
	drop _merge
	
merge 1:1 case_id using aux3 // perfect match
	drop _merge
	
merge 1:1 case_id using aux4 // perfect match
	drop if _merge!=3 // 1 ob not matched
		local zero_list shock_agricul shock_income shock_health shock_death shock_other
			foreach var in `zero_list'{
				replace `var' = 0 if _merge==1 // give value zero, we dropped no's from shock module.
			}
	
	drop _merge
	
merge 1:1 case_id using aux5 
			gen death_any = (_merge==3)
			label var death_any "Any death in hh in las 24 months"
		drop _merge

		
* Drop redundant variables		
unab hhead_list: hhead*		
local keep_list hhsize hh_a01 hhweight urban_rural hh_a26b_2 hh_a26c_2 hhead*

rename `keep_list' , upper
drop hh*

unab Keep_list: H*
rename `Keep_list' , lower



	*----------------------------------------------------------*
	*5.2 FP Indicators
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

	
* Take out empty obs
drop if mi(hhweight)
	
* Save
cd "~/Dropbox/LSMS_Compilation/Analysis/Output_Files/"
gen survey = "Malawi_2010"
save malawi_2010 , replace

			








































