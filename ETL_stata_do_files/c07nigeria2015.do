clear all
*******************************************************************************
					*** LSMS Compilation ****
*******************************************************************************
* Program: Nigeria
* File Name: c07_nningeria2015
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
						* Nigeria 2015 *
*******************************************************************************
*******************************************************************************

* Dir
cd "/Users/bsastrakinsky/Dropbox/LSMS_Compilation/Data/nigeria_2015/"



*******************************************************************************
*******************************************************************************
						* I. Consumption Aggregate  *
*******************************************************************************
*******************************************************************************
/* Time scale of consumption estimates if YEAR */

*----------------------------------------------------------*
*1.1 Round 1 - Post Planting
*----------------------------------------------------------*
use cons_agg_wave3_visit1, clear

* General
rename totcons 			total_consumption

* Food Consumption
unab food_list: f*
display "`food_list'"
egen afood_consumption = rsum(`food_list')

* NonFood
unab nonfood_list: nf*
display "`nonfood_list'"
egen nonfood_consumption = rsum(`nonfood_list')

* Keeo relevant stuff
drop f* nf* ed*
rename afood_consumption food_consumption

* Save
gen round = 1
save aux1 , replace


*----------------------------------------------------------*
*1.2. Round 2 - Post Harvest
*----------------------------------------------------------*
use cons_agg_wave3_visit2, clear

* General
rename totcons 			total_consumption

* Food Consumption
unab food_list: f*
display "`food_list'"
egen afood_consumption = rsum(`food_list')

* NonFood
unab nonfood_list: nf*
display "`nonfood_list'"
egen nonfood_consumption = rsum(`nonfood_list')

* Keeo relevant stuff
drop f* nf* ed*
rename afood_consumption food_consumption


* Save
gen round = 2
save aux2 , replace

*----------------------------------------------------------*
*1.3. Year Data - Save round Data
*----------------------------------------------------------*
use aux1, clear
	append using aux2
		
		save aux_round1, replace

*********************************************************************************	
**** I just took the mean up consumption, we need time deflators HERE!!! ********
*****															****************
*********************************************************************************

collapse (mean) *_consumption hhweight , by(hhid) // Both Consumption Aggregates are scaled to year
merge 1:1 hhid using aux2, keepusing(country zone state lga ea rururb hhsize)
	drop _merge

save aux_year1 , replace


*******************************************************************************
*******************************************************************************
						* II. Grab Health Consumption  *
*******************************************************************************
*******************************************************************************

* It is collected in 6 month recall, it appears that this is how they expressed
* the consumption data too.

*----------------------------------------------------------*
*2.1 Round 1 - Post Planting
*----------------------------------------------------------*
use sect8c_plantingw3, clear

gen oops = s8q6*2 if item_cd==430 // to make it yearly
egen health_consumption = total(oops) , by(hhid)
duplicates drop hhid, force

keep hhid health_consumption
gen round = 1

save aux3 , replace


*----------------------------------------------------------*
*2.2 Round 2 - Post Harvest
*----------------------------------------------------------*
use sect11c_harvestw3, clear

gen oops = s11cq6*2 if item_cd==430 // to make it yearly
egen health_consumption = total(oops) , by(hhid)
duplicates drop hhid, force

keep hhid health_consumption
gen round = 2

save aux4 , replace


*----------------------------------------------------------*
*2.3 Year
*----------------------------------------------------------*
use aux3, clear
	append using aux4
			
		preserve	
			merge 1:1 hhid round using aux_round1
				drop if _merge!=3
				drop _merge
			
		save aux_round2 , replace	
				
		restore		
		
	
collapse (mean) health_consumption , by(hhid)
	merge 1:1 hhid using aux_year1
		drop if _merge!=3
		drop _merge

save aux_year2, replace


	
*******************************************************************************
*******************************************************************************
						* III. Assets  *
*******************************************************************************
*******************************************************************************
* Only asked in Post Planting Round
use sect5_plantingw3, clear

drop if item_cd>3341

#delimit ;
local codepair
         301 sofaSet
         302 chairs
         303 tables
         304 mattress
         305 bed
         306 mat
         307 sewingMachine
         308 gasCooker
         309 stoveElectric
         310 stoveGas
         311 stoveKerosene
         312 fridge
         313 freezer
         314 airconditioner
         315 washingmachine
         316 electricDryer
         317 bicycle
         318 motorbike
         319 cars
         320 generator
         321 fan
         322 radio
         323 cassetteRecorder
         324 hifi
         325 microwave
         326 iron
         327 tvset
         328 computer
         329 dvdplayer
         330 satellitedish
         331 musicalInstrument
         332 MobilePhone
         333 Inverter
         334 Others
;
#delimit cr




* 34 items in total

	local a 	= 1
	local aa 	= 2


forvalues z = 1/34{

	local i: word `a' of `codepair'
	local ii: word `aa' of `codepair'

	
	gen aux_`ii' = (item_cd==`i')
	egen asset_`ii' = max(aux_`ii') , by(hhid)


	local a = `a' + 2
	local aa = `aa' + 2

}

* Make it 1 ob per hh
duplicates drop hhid, force

* Merge with dataset with all households in panel
merge 1:1 hhid using aux_year2
	*drop if _merge!=3
	drop _merge

* Save aux dataset
drop aux* s* item_cd  item_desc	item_other	
save aux_year3, replace



*******************************************************************************
*******************************************************************************
						* V. OOPs from health module  *
*******************************************************************************
*******************************************************************************
* Only in post-harvest (round 2) - NO EPISODIC INFO! But has information to create ADL
use sect4a_harvestw3 , clear


egen aux = rsum(s4aq9 s4aq10 s4aq13 s4aq14)
	egen healthm_1month = sum(aux) , by(hhid)
	
egen aux2 = rsum(s4aq17 s4aq19)
	egen healthm_12month = sum(aux2), by(hhid)
	
egen healthm_hosp_oops = sum(s4aq17) , by(hhid)	

gen healthm_oops = healthm_1month * 13 + healthm_12month

gen aux3 = (s4aq15==1)
egen episodic_hosp = max(aux3) , by(hhid)


duplicates drop hhid, force
keep healthm* epi* hhid


* Merge
merge 1:1 hhid using aux_year3
	drop _merge


save aux_year4, replace




*******************************************************************************
*******************************************************************************
				* VI. Household Characteristics  *
*******************************************************************************
*******************************************************************************

use sect1_plantingw3, clear

* Grab HHead information
keep if s1q3==1

rename s1q6 hhead_age
gen hhead_married = (s1q8==1)
gen hhead_female = (s1q2==2)

* Grab education of hhead
merge 1:1 hhid indiv using sect2_harvestw3
	drop if _merge!=3
	drop _merge

	
replace s2aq10 = 0 if mi(s2aq10)

* Educational level	
recode s2aq10 ///
	(0 1 = 0 "None") ///
	(2/3 = 1 "Primary School") ///
	(4/7 = 2 "Secondary School") ///
	(8/13 = 3 "Higher Education") ///
	, gen(hhead_education)

keep hhid hhead*


* Save
merge 1:1 hhid using aux_year4
	*drop if _merge!=3
	drop _merge


save aux_year4, replace


*******************************************************************************
*******************************************************************************
				* VII. Rounds Data - Panel  *
*******************************************************************************
*******************************************************************************
use  aux_round2, clear

merge m:1 hhid using aux_year4 , keepusing(hhead* asset*)
	drop if _merge!=3
	drop _merge

gen year = 2016



	

	*----------------------------------------------------------*
	*5.1 FP Indicators
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

	
	order hhid year round visit surveyt zone state lga ea rururb hhsize hhweight *_consumption 
	save aux_round5, replace
	
	*----------------------------------------------------------*
	*5.2 Save - Panel
	*----------------------------------------------------------*
		
	* Append to Panel
	cd "/Users/bsastrakinsky/Dropbox/LSMS_Compilation/Analysis/Output_Files/"
	append using nigeria_10_12_panel 
	
	* Drop redundant variables
	drop visit surveyt lga ea country
	
	save nigeria_10_15_panel.dta , replace
	
	

*******************************************************************************
*******************************************************************************
				* VI. Save Yearly Data *
*******************************************************************************
*******************************************************************************
* Dir
cd "/Users/bsastrakinsky/Dropbox/LSMS_Compilation/Data/nigeria_2015/"
use aux_year4, clear


* Health was not added to consumption aggregates
* Include health
replace total_consumption = total_consumption + health_consumption if !mi(health_consumption)
replace nonfood_consumption = nonfood_consumption + health_consumption if !mi(health_consumption)



	*----------------------------------------------------------*
	*6.1 FP Indicators
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

* delete not useful empty
drop if mi(hhweight)
	

gen year = 2016
gen survey = "Nigeria_2016"

order hhid year rururb hhsize *_consumption 
drop country


cd "/Users/bsastrakinsky/Dropbox/LSMS_Compilation/Analysis/Output_Files/"
save nigeria_2015 , replace

















