clear all
*******************************************************************************
					*** LSMS Compilation ****
*******************************************************************************
* Program: Nigeria
* File Name: c06_nningeria2012
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
						* Nigeria 2012 *
*******************************************************************************
*******************************************************************************

* Dir
cd "/Users/bsastrakinsky/Dropbox/LSMS_Compilation/Data/nigeria_2012/"



*******************************************************************************
*******************************************************************************
						* I. Consumption Aggregate  *
*******************************************************************************
*******************************************************************************
/* We can find consumption for: 1. Year 2. Post Harves, 3. Pre-Harvest */

*----------------------------------------------------------*
*1.1 Total Consumption (Year)
*----------------------------------------------------------*
use cons_agg_w2, clear

preserve

* General
rename hhtexp_dr_w2 	total_consumption
rename fdtexp_dr_w2		food_consumption
rename hltexp_dr_w2		health_consumption
rename nfdtexp_dr_w2	nonfood_consumption
rename wta_hh_PH		hhweight
rename hhsize_PH		hhsize



* Household Head
gen hhead_female  = (hh_sex_PH==0)

	*----------------------------------------------------------*
	*1.1.2 FP Indicators
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
	
	*----------------------------------------------------------*
	*1.1.3 Save Year Estimates
	*----------------------------------------------------------*
	
	keep zone state rururb hhid hhsize hhweight hhead* *_consumption che* price_deflat*
	order zone state rururb hhid hhsize hhweight hhead* *_consumption che*

	save auxyear_1 , replace
	
restore

*----------------------------------------------------------*
*1.2 Total Consumption (By Rounds, Panel Set-up)
*----------------------------------------------------------*

* Drop all year variables
drop *_w2

* Rename according to rounds (Post PLanting - 1, Post-Harvest - 2)
rename *PP *1
rename *PH *2

* Reshape dataset to long
reshape long 	wta_hh_ wta_pop_ hhsize_ dependants_ hh_sex_ pindex_ ///
				price_deflat_ hhtexp_dr_ pcexp_dr_ ///
				fdtotby_dr_ fdtotpr_dr_ fdtexp_dr_ edtexp_dr_ ///
				hltexp_dr_ nfdftexp_dr_ nfditexp_dr_ nfdtexp_dr_ ///
				, i(hhid) j(round)

* Fix names
rename *_ *

* Consumption
rename hhtexp_dr		total_consumption
rename fdtexp_dr		food_consumption
rename hltexp_dr		health_consumption
rename nfdtexp_dr		nonfood_consumption
rename wta_hh			hhweight
rename hhsize			hhsize

* Household Head
gen hhead_female  = (hh_sex==0)


* Convert prices to those of round 1
unab money_list: *_consumption
	foreach var in `money_list'{
		replace `var' = `var' / price_deflat if round==2
	}

	*----------------------------------------------------------*
	*1.2.2 FP Indicators
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
	
	*----------------------------------------------------------*
	*1.1.3 Save Year Estimates
	*----------------------------------------------------------*
	
	keep zone state rururb hhid round hhsize hhweight hhead* *_consumption che*
	order zone state rururb hhid round hhsize hhweight hhead* *_consumption che*

	save auxround_1 , replace

	
*******************************************************************************
*******************************************************************************
						* II. Assets  *
*******************************************************************************
*******************************************************************************
* Only asked in Post Planting Round
use sect5a_plantingw2, clear



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
merge 1:1 hhid using auxyear_1
	*drop if _merge!=3
	drop _merge

* Save aux dataset
drop aux* s* item_cd  item_desc tracked_obs		
save aux2, replace


*******************************************************************************
*******************************************************************************
				* V. Household Characteristics  *
*******************************************************************************
*******************************************************************************

use sect1_plantingw2, clear

* Grab HHead information
keep if s1q3==1

rename s1q6 hhead_age
gen hhead_married = (s1q8==1)
gen hhead_female = (s1q2==2)

* Grab education of hhead
merge 1:1 hhid indiv using sect2_plantingw2

	drop if _merge!=3
	drop _merge

	
replace s2q8 = 0 if mi(s2q7)

* Educational level	
recode s2q8 ///
	(0/15 61 = 0 "None") ///
	(16/25 = 1 "Primary School") ///
	(26/28 32 = 2 "Secondary School") ///
	(31 33 34/52 = 3 "Higher Education") ///
	, gen(hhead_education)

keep hhid hhead*

* Save
merge 1:1 hhid using aux2	
	*drop if _merge!=3
	drop _merge


save aux3, replace



*******************************************************************************
*******************************************************************************
						* VI. OOPs from health module  *
*******************************************************************************
*******************************************************************************

* Only in post-harvest (round 2)
use sect4a_harvestw2.dta , replace
clear all
*******************************************************************************
					*** LSMS Compilation ****
*******************************************************************************
* Program: Nigeria
* File Name: c06_nningeria2012
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
						* Nigeria 2012 *
*******************************************************************************
*******************************************************************************

* Dir
cd "/Users/bsastrakinsky/Dropbox/LSMS_Compilation/Data/nigeria_2012/"



*******************************************************************************
*******************************************************************************
						* I. Consumption Aggregate  *
*******************************************************************************
*******************************************************************************
/* We can find consumption for: 1. Year 2. Post Harves, 3. Pre-Harvest */

*----------------------------------------------------------*
*1.1 Total Consumption (Year)
*----------------------------------------------------------*
use cons_agg_w2, clear

preserve

* General
rename hhtexp_dr_w2 	total_consumption
rename fdtexp_dr_w2		food_consumption
rename hltexp_dr_w2		health_consumption
rename nfdtexp_dr_w2	nonfood_consumption
rename wta_hh_PH		hhweight
rename hhsize_PH		hhsize



* Household Head
gen hhead_female  = (hh_sex_PH==0)

	*----------------------------------------------------------*
	*1.1.2 FP Indicators
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
	
	*----------------------------------------------------------*
	*1.1.3 Save Year Estimates
	*----------------------------------------------------------*
	
	keep zone state rururb hhid hhsize hhweight hhead* *_consumption che* price_deflat*
	order zone state rururb hhid hhsize hhweight hhead* *_consumption che*

	save auxyear_1 , replace
	
restore

*----------------------------------------------------------*
*1.2 Total Consumption (By Rounds, Panel Set-up)
*----------------------------------------------------------*

* Drop all year variables
drop *_w2

* Rename according to rounds (Post PLanting - 1, Post-Harvest - 2)
rename *PP *1
rename *PH *2

* Reshape dataset to long
reshape long 	wta_hh_ wta_pop_ hhsize_ dependants_ hh_sex_ pindex_ ///
				price_deflat_ hhtexp_dr_ pcexp_dr_ ///
				fdtotby_dr_ fdtotpr_dr_ fdtexp_dr_ edtexp_dr_ ///
				hltexp_dr_ nfdftexp_dr_ nfditexp_dr_ nfdtexp_dr_ ///
				, i(hhid) j(round)

* Fix names
rename *_ *

* Consumption
rename hhtexp_dr		total_consumption
rename fdtexp_dr		food_consumption
rename hltexp_dr		health_consumption
rename nfdtexp_dr		nonfood_consumption
rename wta_hh			hhweight
rename hhsize			hhsize

* Household Head
gen hhead_female  = (hh_sex==0)


* Convert prices to those of round 1
unab money_list: *_consumption
	foreach var in `money_list'{
		replace `var' = `var' / price_deflat if round==2
	}

	*----------------------------------------------------------*
	*1.2.2 FP Indicators
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
	
	*----------------------------------------------------------*
	*1.1.3 Save Year Estimates
	*----------------------------------------------------------*
	
	keep zone state rururb hhid round hhsize hhweight hhead* *_consumption che*
	order zone state rururb hhid round hhsize hhweight hhead* *_consumption che*

	save auxround_1 , replace

	
*******************************************************************************
*******************************************************************************
						* II. Assets  *
*******************************************************************************
*******************************************************************************
* Only asked in Post Planting Round
use sect5a_plantingw2, clear



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
merge 1:1 hhid using auxyear_1
	*drop if _merge!=3
	drop _merge

* Save aux dataset
drop aux* s* item_cd  item_desc tracked_obs		
save aux2, replace


*******************************************************************************
*******************************************************************************
				* V. Household Characteristics  *
*******************************************************************************
*******************************************************************************

use sect1_plantingw2, clear

* Grab HHead information
keep if s1q3==1

rename s1q6 hhead_age
gen hhead_married = (s1q8==1)
gen hhead_female = (s1q2==2)

* Grab education of hhead
merge 1:1 hhid indiv using sect2_plantingw2

	drop if _merge!=3
	drop _merge

	
replace s2q8 = 0 if mi(s2q7)

* Educational level	
recode s2q8 ///
	(0/15 61 = 0 "None") ///
	(16/25 = 1 "Primary School") ///
	(26/28 32 = 2 "Secondary School") ///
	(31 33 34/52 = 3 "Higher Education") ///
	, gen(hhead_education)

keep hhid hhead*

* Save
merge 1:1 hhid using aux2	
	*drop if _merge!=3
	drop _merge


save aux3, replace



*******************************************************************************
*******************************************************************************
						* VI. OOPs from health module  *
*******************************************************************************
*******************************************************************************

* Only in post-harvest (round 2)
use sect4a_harvestw2.dta , replace

egen aux = rsum(s4aq9 s4aq10 s4aq14)
	egen healthm_1month = sum(aux) , by(hhid)
	
egen aux2 = rsum(s4aq17 s4aq19)
	egen healthm_12month = sum(aux2), by(hhid)
	
egen healthm_hosp_oops = sum(s4aq17) , by(hhid)	

gen healthm_oops = healthm_1month * 13 + healthm_12month


* Hospitalization
gen aux3 = (s4aq15==1)
egen episodic_hosp = max(aux3) , by(hhid)


duplicates drop hhid, force
keep healthm* epi* hhid


* Merge
merge 1:1 hhid using aux3
	drop _merge


save aux4, replace






*******************************************************************************
*******************************************************************************
				* VII. Year Dataset  *
*******************************************************************************
*******************************************************************************
use aux4, replace

order hhid lga ea zone rururb hhsize hhweight *_consumption che* hhead* asset*


* Save
cd "/Users/bsastrakinsky/Dropbox/LSMS_Compilation/Analysis/Output_Files/"

gen survey = "Nigeria_2013"
gen year = 2013



* Multiply by deflator healthm vars
unab health_vars: healthm*

foreach var in `health_vars'{
	replace `var' = `var' * price_deflat_PH
}


* Delete empty obs
drop if mi(hhweight)


save nigeria_2012 , replace


*******************************************************************************
*******************************************************************************
				* VII. Panel Dataset  *
*******************************************************************************
*******************************************************************************
cd "/Users/bsastrakinsky/Dropbox/LSMS_Compilation/Data/nigeria_2010/NGA_2010_GHSP_v02_M_STATA/"

use auxround_1, clear


* Merge with Info
merge m:1 hhid using aux3, keepusing(hhead* asset*)
	drop if _merge!=3
	drop _merge

gen year = 2013
	
		
* Save as panel	
cd "/Users/bsastrakinsky/Dropbox/LSMS_Compilation/Analysis/Output_Files/"

append using nigeria_10_panel

order hhid year round
sort hhid year round


save nigeria_10_12_panel , replace












