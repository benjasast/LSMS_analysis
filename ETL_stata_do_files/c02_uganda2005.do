clear all
*******************************************************************************
					*** LSMS Compilation ****
*******************************************************************************
* Program: Uganda Consumption
* File Name: c02_uganda
* RA: Benjamin Sas
* PI: Karen Grepin
* Date: 10/04/19
* Version: 1				
*******************************************************************************
* Objective: 	* Obtain consumption
				* FP indicators
				* episodic health.
				* Asset list	
*******************************************************************************


*******************************************************************************
*******************************************************************************
						* I. Uganda 2005  *
*******************************************************************************
*******************************************************************************

* Dir
cd "/Users/bsastrakinsky/Dropbox/LSMS_Compilation/Data/uganda_2005_2009/"



* No consolidated consumption file, we will have to create consumption
*----------------------------------------------------------*
*1.0. Food consumption
*----------------------------------------------------------*
use 2005_GSEC14A

* Add quantity and values for purchases, home production, gifts.
gen aux1 =  H14aq4 * H14aq5 if !mi(H14aq4,H14aq5)
	replace aux1 = H14aq5 if mi(H14aq4)
	
gen aux2 = H14aq6*H14aq7 if !mi(H14aq6,H14aq7)
	replace aux2 = H14aq7 if mi(H14aq6)

gen aux3 = H14aq8 * H14aq9 if !mi(H14aq8,H14aq9)
	replace aux3 = H14aq9 if mi(H14aq8)

gen aux4 = H14aq10 * H14aq11 if !mi(H14aq10, H14aq11)
	replace aux4 = H14aq11 if mi(H14aq10)


egen food_consumption = rsum(aux1 aux2 aux3 aux4)


* Variables to keep
clonevar hhid = Hhid
destring hhid, replace
collapse (sum) food_consumption , by(hhid)
gen recall = 7

* grab hhweigth
clonevar Hhid = hhid
tostring Hhid, replace
merge 1:1 Hhid using 2005_GSEC1 , keepusing(Region Hmult Inidpcmp Substrat) force
	drop if _merge!=3 // 3 obs from using - empty
	drop _merge
	
rename Hmult hhweight
gen urban = (Substrat==1)
	

* Save aux dataset
destring hhid, replace
save aux1.dta , replace


*----------------------------------------------------------*
*2.0. Non-Food consumption
*----------------------------------------------------------*
* Includes inputted rent! =)
use 2005_GSEC14B, clear

gen aux1 =  H14bq4 * H14bq5 if !mi(H14bq4,H14bq5)
	replace aux1 = H14bq5 if mi(H14bq4)
	
gen aux2 = H14bq6*H14bq7 if !mi(H14bq6,H14bq7)
	replace aux2 = H14bq7 if mi(H14bq6)

gen aux3 = H14bq8 * H14bq9 if !mi(H14bq8,H14bq9)
	replace aux3 = H14bq9 if mi(H14bq8)



egen nonfood_consumption = rsum(aux1 aux2 aux3)


* OOPs
gen oops_tag = (H14bq2>=501 & H14bq2<=509)
egen health_consumption = rsum(aux1 aux2 aux3) if oops_tag==1


* Variables to keep
rename Hhid hhid
collapse (sum) nonfood_consumption health_consumption , by(hhid)

gen recall = 30

* Save
destring hhid, replace
save aux2.dta , replace


*----------------------------------------------------------*
*3.0. Non-Food consumption - Part b
*----------------------------------------------------------*
use 2005_GSEC14C, clear


* Remove all consumer durables
drop if (H14cq2>= 421 & H14cq2<=431)

gen aux1 =  H14cq4 * H14cq5 if !mi(H14cq4,H14cq5)
	replace aux1 = H14cq5 if mi(H14cq4)

gen nonfood_consumptionb = aux1

* Variables to keep
rename Hhid hhid
collapse (sum) nonfood_consumptionb, by(hhid)

gen recall = 365

* Save
destring hhid, replace
save aux3.dta , replace


*----------------------------------------------------------*
*4.0. Cost of use consumer durables - and assets
*----------------------------------------------------------*
use 2005_GSEC12A, clear

drop if H12aq2==. // no article code
drop if H12aq2==1 | H12aq2==2 // no houses or properties, already counted in inputted rent

**** ASSETS *******

#delimit ;
local codepair
			3 Furniture
			4 Furnishings
			5 Bednets
			6 appliances
			7 Electronic_equipment
			8 Generators
			9 Solar_panel
			10 Biycle
			11 Motor_cycle
			12 Other_transport
			13 Jewelly_watches
			14 Mobile_phone
			15 Other_assets
			101 Hoe
			102 Ploughs
			103 Pangas
			104 Wheel_barrows
			105 Other_agricultural
			106 Transport_equipment
			107 Other_enterpriseequipment
;
#delimit cr

* 25 items in total

	local a 	= 1
	local aa 	= 2


forvalues z = 1/20{

	local i: word `a' of `codepair'
	local ii: word `aa' of `codepair'

	
	gen aux_`ii' = (H12aq3==1 & H12aq2==`i')


	local a = `a' + 2
	local aa = `aa' + 2

}


* Replace for each household - if they have asset
	local a 	= 1
	local aa 	= 2

forvalues z = 1/20{

	local i: word `a' of `codepair'
	local ii: word `aa' of `codepair'

	
	egen asset_`ii' = max(aux_`ii') , by(Hhid)


	local a = `a' + 2
	local aa = `aa' + 2

}






**** COST OF USE OF ASSETS *******

* Questions are structured different here, see page 15 of questionnaire.
* They ask for estimated value of assets now, and estimated value 12 months ago.


* Drop those not having the asset
drop if H12aq3!=1

* Variables with estimated value per assets
	// item codes where numbers are specified: 8,9,10, 103, 104, 105

gen p1 = H12aq5
gen p0 = H12aq8	
	
replace p1 = H12aq5/H12aq4 	if H12aq2==8 | H12aq2==9 | H12aq2==10 | H12aq2==103 | H12aq2==104 | H12aq2==105
replace p0 = H12aq8/H12aq7 	if H12aq2==8 | H12aq2==9 | H12aq2==10 | H12aq2==103 | H12aq2==104 | H12aq2==105

* Cost of use per asset (we will only admit positive values, depreciation)
gen cu = p0 - p1 if !mi(p0,p1)
	replace cu = . if cu<0	
	
egen cu_asset = median(cu) , by(H12aq2)
	replace cu_asset = cu_asset * H12aq4 ///
							if H12aq2==8 | H12aq2==9 | H12aq2==10 | H12aq2==103 | H12aq2==104 | H12aq2==105

egen costuse =  total(cu_asset), by(Hhid)
							

* Save							
							
rename Hhid hhid							
collapse (max) costuse asset* , by(hhid)
destring hhid, replace		
gen recall = 365					
save aux4.dta , replace

*----------------------------------------------------------*
*4.0. Consumption Estimates
*----------------------------------------------------------*

use aux1, replace
	forval i = 2/3{
		merge 1:1 hhid using aux`i'
			drop if _merge!=3
			drop _merge
	}
	
merge 1:1 hhid using aux4
	drop _merge // Not to drop if they don't have asset info.
	
	

order hhid food_consumption nonfood_consumption nonfood_consumptionb health_consumption costuse	
	
* Standarize consumption to yearly estimates	
	replace food_consumption = food_consumption * 52
	replace nonfood_consumption = nonfood_consumption * 13
	replace nonfood_consumptionb = nonfood_consumptionb
	replace costuse = costuse
	replace health_consumption = health_consumption * 13
	
	
* Non-food consumption
egen aux = rsum(nonfood_consumption nonfood_consumptionb)
	replace nonfood_consumption = aux

* Non-Food consumption with cost of use
egen nonfood_consumptionB = rsum(nonfood_consumption nonfood_consumptionb costuse)
	label var nonfood_consumptionB "Includes cost of use durables, not used for total C"
	
		drop aux nonfood_consumptionb	
	
egen total_consumption = rsum(food_consumption nonfood_consumption)
save aux5, replace		
		
*----------------------------------------------------------*
*5.0. Household characteristics
*----------------------------------------------------------*
use 2005_GSEC2, clear

* HHsize
egen hhsize = count(tid) , by(HHID)

destring PID, replace
destring HHID, replace

* HHhead
gen aux = PID if (h2q5==1)
egen hhead_id = max(aux) , by(HHID)

* Keep only if it is hhead
keep if h2q5==1

gen aux2 = h2q4 if h2q5==1
egen aux3 = max(aux2) , by(HHID)

recode aux3 ///
	(1 = 0 "Male") ///
	(2 = 1 "Female") ///
	, gen(hhead_female)
	
gen aux5 = 	(h2q10==1) & h2q5==1
	egen hhead_married = max(aux5) , by(HHID)

gen aux6 = h2q9 if h2q5==1
	egen hhead_age = max(aux6) , by(HHID)

	
rename HHID hhid	
keep hhid PID hhsize hhead* h2q5

save aux6, replace

* Education of hhead
use 2005_GSEC4, clear
rename Pid PID
destring PID, replace

save aux7, replace
use aux6
merge 1:1 PID using aux7
	drop _merge
	
* drop if not hhead
drop if mi(h2q5)	
clonevar hhead_educ = H4q4  
	replace hhead_educ = 0 if mi(H4q4)

* Save
save aux8 , replace

*----------------------------------------------------------*
*6.0. Dataset with FP indicators
*----------------------------------------------------------*
use aux5, clear
	merge 1:1 hhid using aux8
		*drop if _merge!=3
		drop _merge
		
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

* Save
save aux9, replace

* Delete unncessesary
drop recall
order hhid hhsize total_consumption food_consumption health_consumption costuse nonsub_consumption hhead* che* asset*

forvalues i = 1/8{
	erase aux`i'.dta
}


*----------------------------------------------------------*
*8.0. Add Episodic Disease
*----------------------------------------------------------*		
cd "/Users/bsastrakinsky/Dropbox/LSMS_Compilation/Data/uganda_2005_2009/"

use 2005_GSEC5, clear


#delimit ;
local codepair
           1 Diarrhoea
           2 Diarrhoea_chronic
           3 Weightloss
           4 Fever_acute
           5 Fever_recurring
           6 Malaria
           7 Skinrash
           8 Weakness
           9 Severeheadache
          10 Fainting
          11 Chills
          12 Vomiting
          13 Cough
          14 Coughingblood
          15 Painurine
          16 Genitalsores
          17 Mentaldisorder
          20 Abdominalpain
          21 Sorethroat
          22 Difficultybreathing
          23 Burn
          24 Fracture
          25 Wound
          26 Childbirth
          27 Other
;
#delimit cr



	local a 	= 1
	local aa 	= 2


forvalues z = 1/25{

	local i: word `a' of `codepair'
	local ii: word `aa' of `codepair'

	
	gen aux_`ii' = (H5q5a==`i' | H5q5b==`i' | H5q5c==`i')
	egen ill_`ii' = max(aux_`ii') , by(Hhid)
	

	local a = `a' + 2
	local aa = `aa' + 2

}



*----------------------------------------------------------*
*9.0. Add OOPs from health module
*----------------------------------------------------------*	

egen aux = rsum(H5q10 H5q11)
egen healthm_oops = sum(aux), by(Hhid)
	replace healthm_oops = healthm_oops * 13 // annualize it is monthly
	
	
	
save aux_epi, replace
	
	

rename Hhid hhid
destring hhid, replace
duplicates drop hhid, force
keep hhid ill* healthm*


save aux_epi.dta , replace


use aux9, clear
	merge 1:1 hhid using aux_epi.dta
		*drop if _merge!=3 // don't drop if it does not have episodic info.
		drop _merge
		
		
* Save
cd "~/Dropbox/LSMS_Compilation/Analysis/Output_Files/"
	
* Drop not useful info all empty
drop if mi(hhweight)	
	
gen year = 2005
gen survey = "Uganda_2005"
save uganda_2005 , replace















































































