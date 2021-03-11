clear all
*******************************************************************************
					*** LSMS Compilation ****
*******************************************************************************
* Program: Ethiopia Consumption
* File Name: c32_bulgaria2007
* RA: Benjamin Sas
* PI: Karen Grepin
* Date: 24/04/20
* Version: 1				
*******************************************************************************
* Objective: 	* Obtain consumption
				* FP indicators
				* episodic health.
				* Asset list	
*******************************************************************************


*******************************************************************************
*******************************************************************************
						* I.   * Bulgaria 2007
*******************************************************************************
*******************************************************************************

cd "/Users/bsastrakinsky/Dropbox/LSMS_Compilation/Data/bulgaria_2007"


*----------------------------------------------------------*
*0.1. Daily Expenses
*----------------------------------------------------------*
use wb_section_13a, clear
clonevar hhid = id

* Nonfood q2:(1/5)
local money_nonfood s13a_q2p1 s13a_q2p2 s13a_q2p3 s13a_q2p4 s13a_q2p5
	egen nonfood_7day = rsum(`money_nonfood')
	
* Food
local money_food s13a_q4p1 s13a_q4p2 s13a_q4p3 s13a_q4p4 s13a_q4p5
	egen food_7day = rsum(`money_food')


* Annualize
replace nonfood_7day = nonfood_7day * 52
replace food_7day = food_7day * 52	

keep hhid nonfood* food*
duplicates drop hhid,force
save aux_01, replace

*----------------------------------------------------------*
*0.2. Food consumption
*----------------------------------------------------------*
use wb_section_13b, clear
clonevar hhid = id

gen aux_f_1month = (s13b_q2/s13b_q4)* s13b_q3 // value of what they have consumed
gen aux_f_12month = s13b_q9 + s13b_q10

* Food consumption
egen f_1month = sum(aux_f_1month) , by(hhid)
egen f_12month = sum(aux_f_12month) , by(hhid)

* Annualize
replace f_1month = f_1month * 12
gen food_consumption = f_1month + f_12month

keep hhid food*
duplicates drop hhid,force
save aux_02, replace
	
*----------------------------------------------------------*
*0.3. Nonfood Consumption
*----------------------------------------------------------*
use wb_section_13c, clear
clonevar hhid = id

gen aux_nf1 = s13c_q2   // 1 month
egen aux_nf2 = rsum(s13c_q3 s13c_q5)    // 12 month + 12 months gifts

* NF consumption
egen nf_1month = sum(aux_nf1) , by(hhid)
egen nf_c12month = sum(aux_nf2) , by(hhid)
gen nonfood_consumption = nf_1month + nf_c12month /12 * 11

keep nonfood* hhid
duplicates drop hhid,force
save aux_03, replace

*----------------------------------------------------------*
*0.4. Consumer durables
*----------------------------------------------------------*
use wb_mainsample_section_1, clear
clonevar hhid = id


* Calculate cost of use for each durable
forval i = 1/23{

	egen avgtime_`i' = mean(s1_q26_`i')
		replace avgtime_`i' = 2 if avgtime_`i'<2 // replace with 2 years if lower avg
		
	gen costuse_`i' = s1_q28_`i' / avgtime_`i'	
}

* Final cost of use
unab cu_list: costuse_*
egen costuse = rsum(`cu_list')

keep costuse hhid
duplicates drop hhid,force
save aux_04, replace

*----------------------------------------------------------*
*0.5. Rent inputation
*----------------------------------------------------------*
* Impossible to do inputation rent with only 4% of households renting
* gen renter = (s1_q12==2 | s1_q12==3)


*----------------------------------------------------------*
*0.6. Create consumption
*----------------------------------------------------------*
use aux_01, replace
	merge 1:1 hhid using aux_02
		drop _merge
	merge 1:1 hhid using aux_03
		drop _merge
	merge 1:1 hhid using aux_04	
		drop if _merge==2
		drop _merge

* Add costuse to nf
replace nonfood_consumption = nonfood_consumption + costuse if !mi(costuse)
egen total_consumption = rsum(food_consumption nonfood_consumption)
		
		
save aux0, replace		

*----------------------------------------------------------*
*1.0. Grab OOPs from Consumption module
*----------------------------------------------------------*
use wb_section_13c, clear
clonevar hhid = id

gen aux_oops1 = s13c_q2  if  (id_nof==221 | id_nof==222) // 1 month
gen aux_oops2 = s13c_q3  if  (id_nof==221 | id_nof==222) // 12 month
gen aux_oops3 = s13c_q5  if  (id_nof==221 | id_nof==222) // 12 month gifts
egen aux_oops4 = rsum(aux_oops2 aux_oops3)

* OOPs from consumption module
egen health_c1month = sum(aux_oops1) , by(hhid)
egen health_c12month = sum(aux_oops4) , by(hhid)
gen health_consumption = health_c1month + health_c12month /12 * 11


rename weight hhweight
gen urban = (location!=2)

* Save
duplicates drop hhid, force
keep hhid* health_consumption hhweight urban health_c*

merge 1:1 hhid using aux0
	drop _merge
	

save aux1, replace




*----------------------------------------------------------*
*2.0. Grab OOPs from Health Module
*----------------------------------------------------------*
use wb_section_6 , clear

clonevar hhid = id

* OOPs
egen aux_1month = rsum(s6_q38*)
egen aux_12month = rsum(s6_q39*)

egen healthm_1month = sum(aux_1month) , by(hhid)
	replace healthm_1month = healthm_1month * 12
egen healthm_12month = sum(aux_12month), by(hhid)

* Create health OOPs
gen healthm_oops = healthm_1month + healthm_12month /12 * 11


* Hospital
gen aux_hosp = (s6_q27==1)
egen episodic_hosp = max(aux_hosp) , by(hhid)
egen healthm_hosp_oops = sum(s6_q39_1_1) , by(hhid) // use the most common 12 month recall

* Merge
keep health*  epi* hhid
duplicates drop hhid, force
merge 1:1 hhid using aux1
	drop _merge
	
save aux2, replace
	
*----------------------------------------------------------*
*3.0. Grab Household characteristics
*----------------------------------------------------------*
use wb_section_2 , clear
clonevar hhid = id


egen hhsize = count(resp) , by(id)
gen urban = (location==1)

* hhead
keep if s2_q3==1

gen hhead_female = (s2_q2==2)
gen hhead_age = (2007-s2_q4y)
gen hhead_married = (s2_q6==2)

* hhead education
merge 1:1 cluster id_hh id_hhm using wb_section_5b
	drop if _merge!=3 // we matched all hheads
	drop _merge

* New var
recode s5b_q4 ///
	(10/12 	= 0 "No education") ///
	(9 		= 1 "Elementary School") ///
	(5/8	= 2 "High School") ///
	(1/4 	= 3 "Higher education") ///
	,gen(hhead_educ)
	
	
keep hhid hhsize urban hhead*
duplicates drop hhid, force

* Merge with rest of data
merge 1:1 hhid using aux2
	drop _merge // perfect

	
	
	
	

*----------------------------------------------------------*
*3.0. Save
*----------------------------------------------------------*


* Save
cd "~/Dropbox/LSMS_Compilation/Analysis/Output_Files/"
gen survey = "Bulgaria_2007"
gen year = 2007
save bulgaria_2007 , replace

	




















