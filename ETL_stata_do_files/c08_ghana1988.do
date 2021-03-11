clear all
*******************************************************************************
					*** LSMS Compilation ****
*******************************************************************************
* Program: Nigeria
* File Name: c08_ghana1988
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
						* Ghana 1988 *
*******************************************************************************
*******************************************************************************

* Dir
cd "~/Dropbox/LSMS_Compilation/Data/ghana_1988/Data/STATA/"

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
egen 				nonfood_consumption  = rsum(nfooda nfoodb) 
egen				health_consumption	= rsum(exp127 exp128)

	*----------------------------------------------------------*
	*1.2 FP Indicators
	*----------------------------------------------------------*
	* Quickly grab hhsize
	merge 1:1 hid using Head
		*drop if _merge!=3
		drop _merge
		
	rename size hhsize	
	
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

*******************************************************************************
*******************************************************************************
				* II. Household Characteristics  *
*******************************************************************************
*******************************************************************************
* Grab HHead info (aleready merged) -- no marriage info.

rename 	agehd	hhead_age
gen 	hhead_female = (sexhd==2)

recode gradehd ///
	(0/3 = 0 "None") ///
	(4/9 = 1 "Primary School") ///
	(10/13 = 2 "Secondary School") ///
	(13/32 = 3 "Higher Education") ///
	, gen(hhead_education)


	
keep 	hid hhid hhsize *_consumption che* hhead*
order 	hid hhid hhsize  *_consumption che* hhead*

save aux2, replace

*******************************************************************************
*******************************************************************************
				* III. Assets  *
*******************************************************************************
*******************************************************************************
use Y11C, clear

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
keep hhid hid asset* clust

merge 1:1 hhid using aux2
	drop _merge

order hid hhid *_consumption che* hhead* asset*

save aux3, replace

*******************************************************************************
*******************************************************************************
				* IV. OOPs in health module  *
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
merge 1:1 hid using aux3
	drop _merge
save aux4, replace


* Grab deflators
use PRICE.dta, clear
duplicates drop clust defl, force // deflators is already unique by clust
merge 1:m clust using aux4

* deflate
replace healthm_oops = healthm_oops*defl
drop if _merge!=3
drop _merge


save aux5, replace	
	

*******************************************************************************
*******************************************************************************
				* IV. Grab Rural/Urban  *
*******************************************************************************
*******************************************************************************
* Can only get this for selected sample!!

use price, clear

gen urban = (typres!=5 & typres!=7) // these are the rural cats
duplicates drop clust, force

save aux6, replace

* Merge with other data
use aux5, clear
	merge m:1 clust using aux6



*******************************************************************************
*******************************************************************************
				* VI. Yearly Data *
*******************************************************************************
*******************************************************************************

cd "/Users/bsastrakinsky/Dropbox/LSMS_Compilation/Analysis/Output_Files/"

gen year = 1988
gen survey = "Ghana_1988"
save ghana_1988 , replace






























	

	
