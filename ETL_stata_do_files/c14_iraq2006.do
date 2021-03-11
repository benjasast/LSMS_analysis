clear all
*******************************************************************************
					*** LSMS Compilation ****
*******************************************************************************
* Program: Iraq
* File Name: c14_iraq2006
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
						* Iraq 2006 *
*******************************************************************************
*******************************************************************************

cd "~/Dropbox/LSMS_Compilation/Data/iraq_2006/"

*******************************************************************************
*******************************************************************************
						* I. Consumption Aggregate  *
*******************************************************************************
*******************************************************************************

use 2007ihses_summary, clear

* Rename vars
clonevar hhid = xhhkey
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

* Get urban and rural - embedded into stratum =(
decode stratum, gen(text)
gen urban = strmatch(text,"*urban*")

save aux0, replace


* Grab hhead info
use 2007ihses01_household_roster
keep if q0105==1 // only hhead
clonevar hhead_age = q0103
gen hhead_female = (q0102==2)
gen hhead_married = (q0108==1)

duplicates drop xhhkey, force // in one household only everyone is head
merge 1:1 xhhkey using aux0
	drop if _merge!=3 // 309 obs from the non-aggregate
	drop _merge

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

keep  	xhhkey cluster qhada stratum hhweight hhsize governorate hhid ///
		znat *_consumption che*	paasche urban hhead*
	
save aux1 , replace	
	
	
*******************************************************************************
*******************************************************************************
						* II. Health Module  *
*******************************************************************************
*******************************************************************************
	
use 2007ihses05_health , clear

clonevar hhid = xhhkey


* Disabilities in hh

# delimit ;
local inability_list
Blindness 1
Deafness 2 
Dumbness 3 
Speech 4 
NotWalk 5 
Mobility 6
Limping 7 
Mental 8
MultipleDis 9
Other 10
;
# delimit cr


* Type of disability counter
local a = 1
local b = 2

forval i = 1/10{ // disability code counter

	
	local e1: word `a' of `inability_list'
	local e2: word `b' of `inability_list'
	
	* Generate dummy for each disability
	gen disability_`e1' = (q0502_1==`i' | q0502_2==`i' | q0502_3==`i')
	
	local a = `a' + 2
	local b = `b' + 2

}

* Reasons for disability (only one reason per hh, most pressing)
egen aux = rmax(q0502a_1 q0502a_2 q0502a_3) 
egen disability_reason = max (aux) , by(hhid)
	label copy q0502a_1 disability_reason 
	label values disability_reason disability_reason 

	

* Chronic disiases in hh
	# delimit ;
	local chronic_list
	diabetes 1
	bloodpressure 2
	chronicinflamattion 3
	cancer 4
	phychological 5
	paralysis 6
	heart 7
	respiratory 8
	digestive 9
	kidney 10
	anemia 11
	other 12
	;
	# delimit cr


	local a = 1
	local b = 2

	forval i = 1/12{ // disability code counter

		
		local e1: word `a' of `chronic_list'
		local e2: word `b' of `chronic_list'
		
		* Generate dummy for each chronic
		gen chronic_`e1' = (q0504a_1==`i' | q0504a_2==`i' | q0504a_3==`i')
		
		local a = `a' + 2
		local b = `b' + 2

	}


* Type of help chronic (last 12 months)

# delimit
;
local help_list
nohelp 1
publichosp 2
publiccentre 3
private 4
gendoctor 5
specialist 6
nurse 7
pharmacy 8
popularprocedure 9
clergy 10
outsideiraq 11
other 12
;
# delimit cr

	local a = 1
	local b = 2
	
	forval i = 1/12{ // 

		
		local e1: word `a' of `help_list'
		local e2: word `b' of `help_list'
		
		gen chronichelp_`e1' = (q0506==`i')
		
		local a = `a' + 2
		local b = `b' + 2

	}	


* Illness in hh last 30 days (not include chronic or disabilities from before)

# delimit ;
local ill_list
diabetes 1
pressure 2
heart 3
kidneys 4
tumors 5
cholesterol 6
mental 7
psychological 8
paralusis 9
digestive 10
thyriod 11
hepatitis 12
respiratory 13
postnatalcomplic 14
blooddisease 15
inflamthyrioid 16
skin 17
impotency 18
STD 19
contagious 20
other 21
;
# delimit cr

	local a = 1
	local b = 2
	
	forval i = 1/21{ // 

		
		local e1: word `a' of `ill_list'
		local e2: word `b' of `ill_list'
		
		gen ill_`e1' = (q0508_a==`i')
		
		local a = `a' + 2
		local b = `b' + 2

	}	

* Injuries in hh last 30 days
# delimit;
local injury_list
tornligament 1
head_internal 2
fractures 3
poisoning 4
burns 5
other 6
;
#delimit cr

	local a = 1
	local b = 2
	
	forval i = 1/6{ // 

		
		local e1: word `a' of `injury_list'
		local e2: word `b' of `injury_list'
		
		gen injury_`e1' = (q0508_b==`i')
		
		local a = `a' + 2
		local b = `b' + 2

	}	
	
* Reason injury
# delimit ;
local reason_list
traffic 1
work 2
otheraccident 3
familyviolence 4
assault 5
disturbances 6
other 7
;
#delimit cr

	local a = 1
	local b = 2
	
	forval i = 1/7{ // 

		
		local e1: word `a' of `reason_list'
		local e2: word `b' of `reason_list'
		
		gen injuryr_`e1' = (q0509==`i')
		
		local a = `a' + 2
		local b = `b' + 2

	}	


* Merical care for illness injury
#delimit ;
local facility_list
publichosp 1
publiccentre 2
privhisp 3
gendoctor 4
specialist 5
medasstant 6
nurse 7
pharmacy 8
popmedprocedure 9
clergy 10
outsideiraq 11
other 12
;
# delimit cr

	
	local a = 1
	local b = 2
	
	forval i = 1/12{ // 

		
		local e1: word `a' of `facility_list'
		local e2: word `b' of `facility_list'
		
		gen injuryfac_`e1' = (q0510==`i')
		
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

  	

collapse 	(max) disability* chronic* ill* injury* q0503_a q0505_b q0513 q0515 q0518   ///
			(min) q0507 q0510 q0517 ///
			, by(hhid)

	
* put back var labels
  foreach v of var * {
 	label var `v' "`l`v''"
  }
  
  
* value labels
unab q_list: q*

foreach var in `q_list'{
	label values `var' `var'

}
 	
* rename vars
rename 	q0503_a disability_years
rename q0505_b chronic_years
rename q0513 ill_facdistance
rename q0515 ill_factime
rename q0518 ill_daysinterrupted
rename q0507 ill_any
rename q0510 ill_anycare
rename q0517 ill_reasonnotcare
	
	
order hhid disability* chronic* ill* injury*	



save aux2 , replace



*******************************************************************************
*******************************************************************************
						* III. Shock Module  *
*******************************************************************************
*******************************************************************************	

use 2007ihses18_risks , clear

* Rername vars with zeros
forval i = 1/9{
	rename *_0`i' *_`i'
}

* Shock names
#delimit ;
local shock_list
lossemploy
salarydown
bussinessbankrupt
severeill_accident
deathworkmember
deathothermember
theft
violenceiniraq
kidnap_threats
otherviolence
other
;
# delimit cr

forval i = 1/11{
	local e1: word `i' of `shock_list'
	rename q1801_`i' shock_`e1'
}

* Coping strategies
#delimit ;
local coping_list
eatless
reduceconsumption
depletesaving
loansfamily
loanscompany
buyfoodoncredit
helpcommunity
sellhhgoods
sellcapitalgoods
rentland
mortgage
selllivestock
sellhouseland
workforfood
workreliefprog
migrateforjob
joinmilitary
increasechildlabour
kidsindenturedlab
sellchildbride
begging
moved
otheraction
nothing
;
#delimit cr

forval i = 1/24{
	local e1: word `i' of `coping_list'
	rename q1802_`i' shock_`e1'
}


save aux3, replace

*******************************************************************************
*******************************************************************************
						* IV. OOPs from health module  *
*******************************************************************************
*******************************************************************************	
use 2007ihses05_health, clear

egen aux = rsum(q0516_1 q0516_2 q0516_3 q0516_4 q0516_5)
	replace aux = q0516_6 if mi(aux)
	
* No hospitalization info
	
	
* Household health expenditures
egen healthm_oops = sum(aux), by(xhhkey)
	replace healthm_oops = healthm_oops * 13 // 1 month to a year
	
duplicates drop xhhkey, force
keep xhhkey healthm*

save aux4,replace


*******************************************************************************
*******************************************************************************
						* V. Save  *
*******************************************************************************
*******************************************************************************	

use aux1, clear
	
	* Health
	merge 1:1 hhid using aux2
		*drop if _merge!=3
		drop _merge
	
	* Drop observations with only missing values
	drop if mi(xhhkey)	
		
	* Shock
	merge 1:1 xhhkey using aux3
		*drop if _merge!=3
		drop _merge
		
	* Drop observations with only missing values
	drop if mi(xhhkey)		

	* OOPs from health module
	merge 1:1 xhhkey using aux4
		drop _merge
		
	* Multiply OOPs from health module by paasche
	replace healthm_oops = healthm_oops *paasche
		

* Save
cd "~/Dropbox/LSMS_Compilation/Analysis/Output_Files/"
gen survey = "Iraq_2007" // changed name
save iraq_2006 , replace

		
		























	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
