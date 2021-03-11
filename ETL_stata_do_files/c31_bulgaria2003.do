clear all
*******************************************************************************
					*** LSMS Compilation ****
*******************************************************************************
* Program: Ethiopia Consumption
* File Name: c31_bulgaria2003
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
						* I.   * Bulgaria 2003
*******************************************************************************
*******************************************************************************

cd "/Users/bsastrakinsky/Dropbox/LSMS_Compilation/Data/bulgaria_2003"

*----------------------------------------------------------*
*1.0. Aggregate Consumption
*----------------------------------------------------------*
use bg03exp, clear


clonevar hhid = hhcode

rename 	tconsexp 	total_consumption
rename 	nonfood		nonfood_consumption
rename 	health		health_consumption
gen 	food_consumption = total_consumption - nonfood_consumption
	
save aux1, replace	

	
*----------------------------------------------------------*
*1.1. HHead info
*----------------------------------------------------------*	
use ns_individual, clear

* hhid
egen hhid = concat(id1 id2 id3 id4)

* Grab hhsize
egen hhsize = count(hh1_1) , by(hhid)

* keep only hhead
keep if hh1_1==1

* Urban
gen urban = (lok=="0" | lok=="1")

gen hhead_female = (hh1_2==2)
clonevar hhead_age = hh1_age
gen hhead_married = (hh1_5==2)

keep hhid hhsize hhead* urban

* Merge data
merge 1:1 hhid using aux1
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


	
save aux2, replace
	
	
*----------------------------------------------------------*
*2.0. Grab OOPs from Health Module
*----------------------------------------------------------*
use ns_individual, clear

* hhid
egen hhid = concat(id1 id2 id3 id4)

unab one_month: h_24*
unab twelve_month: h_25*

* 1 month recall period
egen aux_1month = rsum(`one_month')
	egen healthm_1month = sum(aux_1month) , by(hhid)
		replace healthm_1month = healthm_1month * 13 // annualize
		
* 12 month recall period (they are the exact same questions)
egen aux_12month = rsum(`twelve_month')
	egen healthm_12month = sum(aux_12month) , by(hhid)

* Create a combination of both - make 1 month recall count for one month, and
* 12 month recall count for 11 month
gen healthm_oops = healthm_1month/13 + healthm_12month/12 *11


	
* Hospital
gen aux_hosp = (h_19==1)
egen episodic_hosp = max(aux_hosp) , by(hhid)

* Will do 
egen healthm_hosp_oops = sum(h_25a) , by(hhid) // give best name to most common
* in other sruveys , oops with 12 month recall
egen healthm_hosp_oops1month = sum(h_24a), by(hhid)


	
*----------------------------------------------------------*
*3.0. Merge and calculate FPIs
*----------------------------------------------------------*

* Merge
duplicates drop hhid, force
keep hhid* healthm* epi*

merge 1:1 hhid using aux2
	drop _merge
	
	
* Save
cd "~/Dropbox/LSMS_Compilation/Analysis/Output_Files/"
gen survey = "Bulgaria_2003"
gen year = 2003
save bulgaria_2003 , replace

	






















