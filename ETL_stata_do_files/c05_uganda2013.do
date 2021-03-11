clear all
*******************************************************************************
					*** LSMS Compilation ****
*******************************************************************************
* Program: Uganda Consumption
* File Name: c05_uganda2013
* RA: Benjamin Sas
* PI: Karen Grepin
* Date: 16/04/19
* Version: 1				
*******************************************************************************
* Objective: 	* Obtain consumption
				* FP indicators
				* episodic health.
				* Asset list	
*******************************************************************************


*******************************************************************************
*******************************************************************************
						* Uganda 2010/2011 *
*******************************************************************************
*******************************************************************************

* Dir
cd "/Users/bsastrakinsky/Dropbox/LSMS_Compilation/Data/uganda_2013/UGA_2013_UNPS_v01_M_STATA8/"

*******************************************************************************
*******************************************************************************
						* I. Food Consumption  *
*******************************************************************************
*******************************************************************************
use GSEC15b, clear


* Add quantity and values for purchases, home production, gifts.
gen aux1 =  h15bq4 * h15bq5 if !mi(h15bq4, h15bq5)
	replace aux1 = h15bq5 if mi(h15bq4)
	
gen aux2 = h15bq6 * h15bq7 if !mi(h15bq6, h15bq7)
	replace aux2 = h15bq7 if mi(h15bq6)

gen aux3 = h15bq8 * h15bq9 if !mi(h15bq8, h15bq9)
	replace aux3 = h15bq9 if mi(h15bq8)

gen aux4 = h15bq10 * h15bq11 if !mi(h15bq10, h15bq11)
	replace aux4 = h15bq11 if mi(h15bq10)


egen food_consumption = rsum(aux1 aux2 aux3 aux4)


collapse (sum) food_consumption , by(HHID)
gen recall = 7

clonevar hhid = HHID
destring hhid, replace

* Grab hhweight
merge 1:1 HHID using GSEC1 , keepusing(region urban wgt_X)
rename wgt_X hhweight
drop if _merge!=3
drop _merge


* Save aux dataset
rename hhid hhid_new
save aux1.dta , replace


*******************************************************************************
*******************************************************************************
		* II. NonFood Consumption - Part A (30 days)  *
*******************************************************************************
*******************************************************************************
/* INLCUDES RENT AND INPUTTED RENT =) */

use GSEC15c, clear

rename HHID hhid
destring hhid, replace

gen aux1 =  h15cq4 * h15cq5 if !mi(h15cq4, h15cq5)
	replace aux1 = h15cq5 if mi(h15cq4)
	
gen aux2 = h15cq6 * h15cq7 if !mi(h15cq6, h15cq7)
	replace aux2 = h15cq7 if mi(h15cq6)

gen aux3 = h15cq8 * h15cq9 if !mi(h15cq8, h15cq9)
	replace aux3 = h15cq9 if mi(h15cq8)

	
egen nonfood_consumptionA = rsum(aux1 aux2 aux3)	
gen health_consumption = nonfood_consumptionA if itmcd>=500 & itmcd<=599




collapse (sum) nonfood_consumptionA health_consumption , by(hhid)

gen recall = 30

* Save aux dataset
rename hhid hhid_new
save aux2.dta , replace


*******************************************************************************
*******************************************************************************
		* III. NonFood Consumption - Part B (365 days)  *
*******************************************************************************
*******************************************************************************
use GSEC15d, clear

rename HHID hhid
destring hhid, replace


egen aux = rsum(h15dq3 h15dq4 h15dq5)
egen nonfood_consumptionB = total(aux) , by(hhid)

duplicates drop hhid, force
keep hhid nonfood*

gen recall = 365


rename hhid hhid_new
save aux3.dta , replace



*******************************************************************************
*******************************************************************************
				* IV. Assets and Cost of use  *
*******************************************************************************
*******************************************************************************
use GSEC14A, clear
rename HHID hhid
destring hhid, replace


*----------------------------------------------------------*
*4.1. Assets
*----------------------------------------------------------*

* Drop house, land and buildings
drop if h14q2==1 | h14q2==1==2 | h14q2==3
* Drop other (specify) - we will have no clarity on depreciation
drop if h14q2==21 | h14q2==22


#delimit ;
local codepair
           4 Furniture
           5 appliances
           6 Television
           7 RadioCassette
           8 Generators
           9 Solar_panel
          10 Biycle
          11 Motor_cycle
          12 Motorvehicle
          13 Boat
          14 OtherTransport
          15 Jewelly_watches
          16 Mobile_phone
          17 Computer
          18 InternetAccess
          19 Electronic_equipment
          20 Other_assets
;
#delimit cr




* 17 items in total

	local a 	= 1
	local aa 	= 2


forvalues z = 1/17{

	local i: word `a' of `codepair'
	local ii: word `aa' of `codepair'

	
	gen aux_`ii' = (h14q3==1 & h14q2==`i')
	egen asset_`ii' = max(aux_`ii') , by(hhid)


	local a = `a' + 2
	local aa = `aa' + 2

}





duplicates drop hhid,force
keep hhid asset*
destring hhid, replace


rename hhid hhid_new
save aux4 , replace



*----------------------------------------------------------*
*4.2. Cost of Use
*----------------------------------------------------------*

/* NO WAY TO CALCULATE COST OF USE WITH DATA */



*******************************************************************************
*******************************************************************************
				* IV. Episodic Disease  *
*******************************************************************************
*******************************************************************************
use GSEC5, clear
rename HHID hhid
destring hhid, replace



drop if h5q7a==0 // No symptoms or disease

#delimit ;
local codepair
           1 Diarrhoea
           2 Diarrhoea_chronic
           3 Weightloss
           4 Fever_acute
           5 Fever_recurring
           6 Wound
           7 Skinrash
           8 Weakness
           9 Severeheadache
          10 Fainting
          11 Chills
          12 Vomiting
          13 Cough
          14 Productivecough
          15 Coughingblood
          16 Painurine
          17 Genitalsores
          18 Mentaldisorder
          19 Abdominalpain
          20 Sorethroat
          21 Difficultybreathing
          22 Burn
          23 Fracture
          96 Other
;
#delimit cr



	local a 	= 1
	local aa 	= 2


forvalues z = 1/24{

	local i: word `a' of `codepair'
	local ii: word `aa' of `codepair'

	
	gen aux_`ii' = (h5q7a==`i' | h5q7b==`i')
	egen ill_`ii' = max(aux_`ii') , by(hhid)
	

	local a = `a' + 2
	local aa = `aa' + 2

}



*******************************************************************************
*******************************************************************************
				* IVb. OOPs from health module  *
*******************************************************************************
*******************************************************************************

egen healthm_oops = sum(h5q12) , by(hhid)
	replace healthm_oops = healthm_oops *13


duplicates drop hhid, force
keep hhid ill* healthm*

destring hhid, replace




rename hhid hhid_new
save aux5, replace



*******************************************************************************
*******************************************************************************
				* V. Household Characteristics  *
*******************************************************************************
*******************************************************************************
use GSEC2, clear

rename HHID_old hhid
rename PID PID_new
rename PID_Old PID
destring PID, replace

destring hhid, replace
destring PID, replace

*----------------------------------------------------------*
*5.1. General
*----------------------------------------------------------*

* keep only regular members
keep if h2q7<=4 & h2q7!=0 

* Household size
egen hhsize = count(h2q7) , by(hhid)

* HHead ID
gen aux = PID if (h2q4==1)
	egen hhead_id = max(aux) , by(hhid)
	
* HHead Marital status
gen aux2 = (h2q10==1) & h2q4==1
	egen hhead_married = max(aux2) , by(hhid)
	
* HHead is female
gen aux3 = h2q3 if h2q4==1

	egen aux4 = max(aux3) , by(hhid)
		recode aux4 ///
		(1 = 0 "Male") ///
		(2 = 1 "Female") ///
		, gen(hhead_female)


* Hhead age
gen age = h2q8 if h2q4==1
	egen hhead_age = max(age) , by(hhid)
	
drop if hhead_age<0	
			
		
		
duplicates drop hhid, force		



rename HHID hhid_new		
save aux6, replace		
		
*----------------------------------------------------------*
*5.2. HHead Education
*----------------------------------------------------------*
use GSEC4, clear


rename HHID hhid
destring hhid, replace
rename PID PID_new, replace

duplicates drop PID_new, force

save aux7, replace

* Merge with HH info
use aux6, clear
	merge 1:1 PID_new using aux7 , force
	
* keep only hhead
keep if h2q4==1	

* Educ
clonevar hhead_educ = h4q7
	replace hhead_educ = 0 if mi(h4q7)

		
erase aux6.dta
erase aux7.dta		
		
* Dataset to merge later
duplicates drop hhid, force
keep hhid hhid_new hhsize hhead*

save aux6, replace



*******************************************************************************
*******************************************************************************
					* VI. Merge  *
*******************************************************************************
*******************************************************************************
use aux1,clear

forval i = 2/6{
	merge 1:1 hhid_new using aux`i'
		*drop if _merge!=3
		drop _merge

}

// not good on the hhead education section

order HHID hhid hhsize food_consumption nonfood_consumptionA nonfood_consumptionB health_consumption hhead* asset* ill*

*----------------------------------------------------------*
*6.1. Standarize consumption to 1 year
*----------------------------------------------------------*

replace food_consumption = food_consumption * 13 * 4 // 1 week 
replace nonfood_consumptionA = nonfood_consumptionA * 13 // 1 month 
replace nonfood_consumptionB = nonfood_consumptionB  // 365 days 
replace health_consumption = health_consumption * 13 // 1m 

egen nonfood_consumption = rsum(nonfood_consumptionA nonfood_consumptionB)
egen total_consumption = rsum(nonfood_consumption food_consumption)

*----------------------------------------------------------*
*6.2. FP Indicators
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

*----------------------------------------------------------*
*6.3. Save
*----------------------------------------------------------*

order hhid hhsize healthm* total_consumption food_consumption nonfood_consumption health_consumption nonsub_consumption che* hhead* asset* ill*
cd "/Users/bsastrakinsky/Dropbox/LSMS_Compilation/Analysis/Output_Files/"


gen year = 2014
gen survey = "Uganda_2014"
save uganda_2013 , replace



*******************************************************************************
*******************************************************************************
					* VII. Panel  *
*******************************************************************************
*******************************************************************************
use uganda_05_11_panel, clear
	append using uganda_2013
	
drop if mi(hhid)	

	
egen count = count(year) , by(hhid)
	drop if count==1 // keep households with more than one observation

xtset hhid year

* Standarization was already done for 2009 set, this questionnaire was identical to
* 2009 so no need to standarize.

erase uganda_05_11_panel.dta


* SAVE
save uganda_05_13_panel , replace











