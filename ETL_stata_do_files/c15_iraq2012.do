clear all
*******************************************************************************
					*** LSMS Compilation ****
*******************************************************************************
* Program: Iraq
* File Name: c15_iraq2012
* RA: Benjamin Sas
* PI: Karen Grepin
* Date: 07/06/19
* Version: 1				
*******************************************************************************
* Objective: 	* Obtain consumption
				* FP indicators
				* episodic health.
				* Asset list	
*******************************************************************************

*******************************************************************************
*******************************************************************************
						* Iraq 2012 *
*******************************************************************************
*******************************************************************************


cd "~/Dropbox/LSMS_Compilation/Data/iraq_2012/IRQ_2012_IHSES_v02_M_Stata8/"


*******************************************************************************
*******************************************************************************
						* I. Consumption Aggregate  *
*******************************************************************************
*******************************************************************************

use 2012ihses_summary , clear


* Rename vars
clonevar hhid = questid
rename weight hhweight
rename hsize hhsize

* Generate conso
gen food_consumption = pcep_food * hhsize
gen health_consumption = pcep_health  * hhsize
gen total_consumption = pcep * hhsize
gen nonfood_consumption = total_consumption - food_consumption


* Check it does not include health on total consumption
egen pcep2 = rsum(pcep_food pcep_liqtob pcep_housing ///
 pcep_utilities pcep_clothing pcep_household pcep_health pcep_education ///
 pcep_transport pcep_comm* pcep_recr* pcep_other pcep_dur*)

 
* Include health
replace total_consumption = total_consumption + health_consumption if !mi(health_consumption)
replace nonfood_consumption = nonfood_consumption + health_consumption if !mi(health_consumption)


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

	
keep  	questid hhid cluster qhada stratum hhweight hhsize governorate hhid ///
		znat *_consumption che*	paasche

save aux1, replace		
		
		
*----------------------------------------------------------*
*1.1 Household characteristics
*----------------------------------------------------------*
* Urbanicity
use 2012ihses00_cover_page, clear

gen urban = (q00_16==1)
keep questid urban

merge 1:1 questid using aux1
	drop if _merge!=3
	drop _merge
	
	
save aux2, replace

* HHead
use 2012ihses01_household_roster, clear

* hhead only
keep if q0105==1
gen hhead_female = (q0102==2)
gen hhead_age = (q0104)
gen hhead_married = (q0106==1)

keep questid hhead*

merge 1:1 questid using aux2
	drop if _merge!=3
	drop _merge	
	
save aux3, replace
	
	
*******************************************************************************
*******************************************************************************
						* II. Health Module  *
*******************************************************************************
*******************************************************************************

use 2012ihses06_p1_health_members, clear


* chronic help
# delimit;
local help_list
publichosp 3
primarycentre 4
popularclinic 5
othergovhealth 6
privatehosp 7
docprivclinic 8
privatelab 9
pharmacy 10
other 11
outsideiraq 12
;
#delimit cr


	local a = 1
	local b = 2
	
	forval i = 3/12{ // 

		
		local e1: word `a' of `help_list'
		local e2: word `b' of `help_list'
		
		gen chronichelp_`e1' = (q0607==`i')
		
		local a = `a' + 2
		local b = `b' + 2

	}	

	
* Illness and injury in hh last 90 days

# delimit ;
local ill_list
sugar 1
hypertension 2
heart 3
kidney 4
tumors 5
cholesterol 6
mental 7
psychological 8
paralysis 9
gastroenteritis 10
thyroid 11
hepatitis 12
respiratory 13
maternaldisease 14
hematology 15
inflamationtyroid 16
skin 17
leaddisability 18
urinary 19
infactious 20
other 21
;
# delimit cr


	local a = 1
	local b = 2
	
	forval i = 1/21{ // 

		
		local e1: word `a' of `ill_list'
		local e2: word `b' of `ill_list'
		
		gen ill_`e1' = (q0611A==`i')
		
		local a = `a' + 2
		local b = `b' + 2

	}	


* injury list
#delimit ;
local injury_list
rupture 1
head_internal 2
sinking 3
suffocation 4
fractures 5
toxins 6
burns 7
hitcar 8
work 9
other 10
;
# delimit cr

	local a = 1
	local b = 2
	
	forval i = 1/10{ // 

		
		local e1: word `a' of `injury_list'
		local e2: word `b' of `injury_list'
		
		gen injury_`e1' = (q0611B==`i')
		
		local a = `a' + 2
		local b = `b' + 2

	}

* Facility care recieved list
# delimit ;
local illfac_list
publichosp 1
primarycentre 2
popularclinic 3
otherpublic 4
privatehosp 5
docprivclinic 6
privatelab 7
pharmacy 8
other 9
outsideiraq 10	
;
# delimit cr

	local a = 1
	local b = 2
	
	forval i = 1/10{ // 

		
		local e1: word `a' of `illfac_list'
		local e2: word `b' of `illfac_list'
		
		gen illfac_`e1' = (q0614==`i')
		
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

	
	

collapse 	(max) chronic* ill* injur* q0603 q0604 q0606 q0612 q0618   ///
			(min) q0602 q0605 q0607 q0610 q0613 q0619 ///
			, by(questid)
			
	
* put back var labels
  foreach v of var * {
 	label var `v' "`l`v''"
  }
 
* value labels
unab q_list: q*

foreach var in `q_list'{
	label values `var' `var'

}


* Rename vars
rename q0603 disability_severity
rename q0604 disability_years
rename q0606 chronic_years
rename q0612 ill_daysinterrupted
rename q0618 illfac_time
rename q0602 disability_any
rename q0605 chronic_any
rename q0607 chronic_consultation
rename q0610 ill_any
rename q0613 ill_medicalcare
rename q0619 ill_whynotcare


order questid dis* chronic* ill* injur* 



save aux4, replace



*******************************************************************************
*******************************************************************************
						* III. Shock Module  *
*******************************************************************************
*******************************************************************************	

use 2012ihses20_shocks , clear


* Drop empty obs
keep if q2001!=2


# delimit ;
local shock_list
1 Drought
2 Lossasset
3 epilivestock
4 waterquality
5 croppest
6 grazingarea
7 violence
8 riots
9 refugee
10 eviction
11 police
12 lossjob
13 lesshours
14 nonpayment
15 Cutremitta
16 deathh
17 illinjury
18 drinkwater
19 highdisease
20 breakuphh
21 highpfood
22 Lossrations
23 Lossgovtasst
;
#delimit cr


# delimit;
local coping_list
1 savings
2 asstfriends
3 asstgovt
4 asstngo
5 foodqual
6 foodvar
7 lesseduchealth
8 morework
9 nework
10 hhmemleaves
11 loansfriends
12 loanscompany
13 foodcredit
14 sellagriassets
15 selldurables
16 sellland
17 sellcrop
18 selllivestock
19 childout
;
# delimit cr





* Number of shocks

	local a = 1
	local b = 2
	
	forval i = 1/23{ // 

		
		local e1: word `a' of `shock_list'
		local e2: word `b' of `shock_list' 
		
		
		* HH declares shock i
		gen aux = (shock_id==`i' & q2001==1)
		egen shock_`e2' = max(aux) , by(questid)
		drop aux
		
		local c = 1
		local d = 2
		
		forval k = 1/19{
		
			*Coping Strategies for shock i
			local f1: word `c' of `coping_list'
			local f2: word `d' of `coping_list' 
			
			gen aux2 = (shock_`e2'==1) & (q2003_1==`k' | q2003_2==`k' | q2003_3==`k')
			egen s`e2'_`f2' = max(aux2) , by(questid)
			
			drop aux2
			
			local c = `c' + 2
			local d = `d' + 2
		
		}
		
		
			
		local a = `a' + 2
		local b = `b' + 2

	}	


duplicates drop questid , force

save aux5, replace



*******************************************************************************
*******************************************************************************
			* V. Investigate OOPs from consumption module  *
*******************************************************************************
*******************************************************************************	
use "~/Dropbox/LSMS_Compilation/Data/iraq_2012/IRQ_2012_IHSES_v02_M_Stata8/2012ihses09_non_food_30_day.dta"

* 30 day recall period
	gen aux = q0903 if q0901c>=600000 & q0901c<700000
	egen aux2 = sum(aux), by(questid)
	gen health30 = aux2 * 13

duplicates drop questid, force	
keep health30 questid
save aux5, replace

* 90 days recall period
use "~/Dropbox/LSMS_Compilation/Data/iraq_2012/IRQ_2012_IHSES_v02_M_Stata8/2012ihses10_non_food_90_day.dta"
	
	gen aux = q1003 if q1001c>=600000 & q1001c<700000
	egen aux2 = sum(aux), by(questid)
	gen health90 = aux2 * 4

duplicates drop questid, force	
keep health90 questid
save aux6, replace

* 12 month recall period
use "~/Dropbox/LSMS_Compilation/Data/iraq_2012/IRQ_2012_IHSES_v02_M_Stata8/2012ihses11_non_food_12_month.dta"

	gen aux = q1103 if q1101c>=600000 & q1101c<700000
	egen aux2 = sum(aux), by(questid)
	gen health12m = aux2

duplicates drop questid, force
keep health12m questid	
save aux7, replace	


* Health expenditures		
merge 1:1 questid using aux5
	drop _merge
merge 1:1 questid using aux6
	drop _merge

egen health_consumption2 = rsum(health*)	
keep health_consumption2 questid	
save aux8, replace




*******************************************************************************
*******************************************************************************
						* V. Save  *
*******************************************************************************
*******************************************************************************	

use aux3, clear

	* Health
	merge 1:1 questid using aux4
	*drop if _merge!=3
	drop _merge
	
	* Shocks
	merge 1:1 questid using aux5
	
	* Replace with zeros
	unab s_list: s*
	foreach var in `s_list'{
		replace `var' = 0 if mi(`var')
	}
	
	drop _merge
	
	
	* Verification of health expenditures
	merge 1:1 questid using aux8
	drop _merge
	
* Verification of health expenditures
replace health_consumption2 = health_consumption2/12 * paasche // Make monthly same as data, deflate
	
	
	
* Save
cd "~/Dropbox/LSMS_Compilation/Analysis/Output_Files/"
gen survey = "Iraq_2012"
save iraq_2012 , replace

		
	
	








 	 
	
	
	
	
	
	
	
	
	
	


