clear all
*******************************************************************************
					*** LSMS Compilation ****
*******************************************************************************
* Program: Nigeria
* File Name: c08_ghana1989
* RA: Benjamin Sas
* PI: Karen Grepin
* Date: 17/04/19
* Version: 1				
*******************************************************************************
* Objective: 	* Obtain consumption
				* FP indicators
				* episodic health.
				* Asset list	
*******************************************************************************

*******************************************************************************
*******************************************************************************
						* Ghana 1989 *
*******************************************************************************
*******************************************************************************

* Dir
cd "~/Dropbox/LSMS_Compilation/Data/ghana_1989/Data/STATA/"


*******************************************************************************
*******************************************************************************
						* I. Consumption Aggregate  *
*******************************************************************************
*******************************************************************************
use EXPEND,clear

*----------------------------------------------------------*
*1.1. Grab Variables
*----------------------------------------------------------*

gen    hhid  = 		hid
rename totalexp 	total_consumption
rename foodexp		food_consumption
rename size			hhsize
egen 				nonfood_consumption  = rsum(nfooda nfoodb) 
rename mo2			month
rename yr2			year


keep hhid hid month year hhsize *_consumption clust

save aux1 , replace


*******************************************************************************
*******************************************************************************
				* II. Grab Health Expenditures  *
*******************************************************************************
*******************************************************************************
use Y11B, clear

rename hid hhid

* Recall Annual (two items)
keep if hhexpcd==127 | hhexpcd==128
egen health_consumption = total(hhexpaly) , by(hhid)

keep hhid health_consumption
duplicates drop hhid, force

merge 1:1 hhid using aux1
	drop if _merge!=3
	drop _merge

order hhid hid year month *_consumption


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


save aux2 , replace



*******************************************************************************
*******************************************************************************
				* III. Household Characteristics  *
*******************************************************************************
*******************************************************************************
use Head, clear

rename 	agehd	hhead_age
gen 	hhead_female = (sexhd==2)

recode gradehd ///
	(0/3 = 0 "None") ///
	(4/9 = 1 "Primary School") ///
	(10/13 = 2 "Secondary School") ///
	(13/32 = 3 "Higher Education") ///
	, gen(hhead_education)


merge 1:1 hid using aux2
		drop if _merge!=3
		drop _merge

		
keep hhid hid hhsize year month *_consumption hhead* che* clust
order hhid hid hhsize year month *_consumption hhead*


save aux3, replace


*******************************************************************************
*******************************************************************************
				* IV. Assets  *
*******************************************************************************
*******************************************************************************
use Y11C, clear

drop clust

gen hhid = hid

#delimit;
local codepair
201 SewingMachine
202 Stove
203 Refrigerators
204 AirConditioner
205 Fan
206 Radio
207 CassettePlayer
208 Phonograph
209 StereoEquipment
210 VideoEquipment
211 WashingMachine
212 BW_TV
213 Colot_TV
214 Bycicle
215 Motorcycle
216 Car
217 Camera
;
#delimit cr




* 17 items in total

	local a 	= 1
	local aa 	= 2


forvalues z = 1/17{

	local i: word `a' of `codepair'
	local ii: word `aa' of `codepair'

	
	gen aux_`ii' = (goodcd==`i')
	egen asset_`ii' = max(aux_`ii') , by(hhid)


	local a = `a' + 2
	local aa = `aa' + 2

}

* Make it 1 ob per hh
duplicates drop hhid, force
keep hhid hid asset*


merge 1:1 hhid using aux3
	drop if _merge!=3
	drop _merge
	
keep hhid hid hhsize year month *_consumption hhead* asset* che* clust
order hhid hid hhsize year month *_consumption hhead* asset*
	

save aux4, replace
	
*******************************************************************************
*******************************************************************************
				* IV. OOPS health module  *
*******************************************************************************
*******************************************************************************
use Y04, clear

egen aux = rsum(cost*)
egen healthm_oops = sum(aux), by(hid)

* Convert to yearly figures (4 weeks to 52 weeks)
replace healthm_oops = healthm_oops * 13

* Hospitalization
gen aux_hosp = (illo==1)
egen episodic_hosp = max(aux_hosp) , by(hid)


duplicates drop hid, force
save aux5, replace

* Grab deflators
use PRICE.dta, clear
duplicates drop clust , force // deflators is already unique by clust (only one with 2 obs, pretty much the same)
merge 1:m clust using aux5

* deflate
replace healthm_oops = healthm_oops*defl
drop if _merge!=3
drop _merge



* Put info
rename hid hhid

* Merge with all info
merge 1:1 hhid using aux4
	drop _merge
	
drop if hid==.

* Fix something about cluster
replace clust = clust+2000 if clust<2000

save aux5, replace


*******************************************************************************
*******************************************************************************
				* IV. Grab Rural/Urban  *
*******************************************************************************
*******************************************************************************

* Manually clasify based on Report (not present anywhere in data) was done
* in excel in folder

import excel "~/Dropbox/LSMS_Compilation/Data/ghana_1989/Data/list_rural_urban_clean.xlsx" ///
, sheet("Sheet1") firstrow clear

* Clean
keep clust loc2
drop if clust=="." // empty
destring clust, replace

* Create urban variable
gen urban = (loc2=="SU" | loc2=="U")

*one repeated val
duplicates drop clust, force // duplicate

* put it in format
replace clust = clust + 2000


* Merge with rest
merge 1:m clust using aux5 // finally food match
drop _merge


	


*******************************************************************************
*******************************************************************************
				* VI. Yearly Data *
*******************************************************************************
*******************************************************************************

cd "~/Dropbox/LSMS_Compilation/Analysis/Output_Files/"
gen survey = "Ghana_1989"
save ghana_1989 , replace




































































