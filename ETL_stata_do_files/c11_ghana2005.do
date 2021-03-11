clear all
*******************************************************************************
					*** LSMS Compilation ****
*******************************************************************************
* Program: Nigeria
* File Name: c11_ghana2005
* RA: Benjamin Sas
* PI: Karen Grepin
* Date: 06/06/19
* Version: 1				
*******************************************************************************
* Objective: 	* Obtain consumption
				* FP indicators
				* episodic health.
				* Asset list	
*******************************************************************************

*******************************************************************************
*******************************************************************************
						* Ghana 2005 *
*******************************************************************************
*******************************************************************************

* Dir
cd "~/Dropbox/LSMS_Compilation/Data/ghana_2005/stata/aggregates/"
*******************************************************************************
*******************************************************************************
						* I. Consumption Aggregate  *
*******************************************************************************
*******************************************************************************
use pov_gh5, clear

* rename vars
rename weight hhweight
rename fexpendc food_consumption
rename expendc total_consumption
gen nonfood_consumption = total_consumption - food_consumption
rename sexhead hhead_sex
rename agehead hhead_age
rename pstatus poor

gen urban = (loc2==1)

keep clust nh pid hhsize region district month year hhweight hhead* urban ///
 food_consumption total_consumption nonfood_consumption povpi loc7 income incomec

save aux1 , replace


* Grab hhead married
use "~/Dropbox/LSMS_Compilation/Data/ghana_2005/stata/parta/sec1.dta"
keep if s1q3==1 // keep only head
gen hhead_married = (s1q6==1)

merge 1:1 clust nh using aux1
drop _merge // perfect match

save aux1, replace

*******************************************************************************
*******************************************************************************
				* II. Grab Health Expenditures  *
*******************************************************************************
*******************************************************************************

use "~/Dropbox/LSMS_Compilation/Data/ghana_2005/stata/aggregates/GLSS5-exp/exp8.dta" , clear

keep if nfdex1cd>=116 & nfdex1cd<=132
egen tot = sum(yrexp) , by(clust nh)

collapse tot , by(clust nh)
rename tot health_12month

save aux2, replace


* More health expenditures (asked in visits) - drugs
use "~/Dropbox/LSMS_Compilation/Data/ghana_2005/stata/aggregates/GLSS5-exp/exp9.dta"

keep if (freqcd==193| freqcd==194 | freqcd==195 | freqcd==197 | freqcd==198)
egen tot = sum(dayexp) , by(clust nh)
collapse tot , by(clust nh)
rename tot health_visit // health exp by visit already adjusted.

merge 1:1 clust nh using aux2
	drop if _merge!=3
	drop _merge

* Create health expenditures	
egen health_consumption = rsum(health_12month health_visit)
		
	
merge 1:1 clust nh using aux1
	drop if _merge!=3
	drop _merge

	
	* Get the deflator for later.
	sum povpi if loc7==1 // standarize prices to accra
	gen deflator = povpi/r(mean)

	*----------------------------------------------------------*
	*2.2 FP Indicators
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


save aux3 , replace


*******************************************************************************
*******************************************************************************
				* IV. OOPs from health module  *
*******************************************************************************
*******************************************************************************

use "~/Dropbox/LSMS_Compilation/Data/ghana_2005/stata/parta/sec3a.dta", clear


* Episodic OOPs

	* Sum by indv
	egen aux = rsum(s3aq10 s3aq11 s3aq16 s3aq18)
		replace aux = s3aq19 if mi(aux) // total is given if breakdown was not possible
		
		
	* healthcare expenditures // 2 week recall period- adjust
	egen healthm_episodic = sum(aux) , by(clust nh)
		replace healthm_episodic = healthm_episodic * 2 * 13


	* Hospitalization (in last 2 weeks)
	gen aux2 = (s3aq14==1) if !mi(s3aq14)
	egen episodic_hosp = sum(aux2), by(clust nh)
		replace episodic_hosp = 1 if episodic_hosp>0


	duplicates drop clust nh, force
	keep healthm_episodic episodic* clust nh	
	
	save aux4, replace

* OOPs Vaccination
use "~/Dropbox/LSMS_Compilation/Data/ghana_2005/stata/parta/sec3b.dta", clear

	egen healthm_vacc = sum(s3bq4) , by(clust nh)
	keep healthm* clust nh
	duplicates drop clust nh, force
	
	save aux5, replace
	
* OOPs postnatal
use "~/Dropbox/LSMS_Compilation/Data/ghana_2005/stata/parta/sec3c.dta", clear

	gen aux_healthm_postnatal = (s3cq2*s3cq4) if !mi(s3cq2,s3cq4)
		replace aux_healthm_postnatal = s3cq4 if mi(s3cq2)
		
	egen healthm_postnatal = sum(aux_healthm_postnatal) , by(clust nh)

	keep healthm* clust nh
	duplicates drop clust nh, force

	save aux6,replace	
		
* OOPs prenatal
use "~/Dropbox/LSMS_Compilation/Data/ghana_2005/stata/parta/sec3d.dta", clear

	gen aux_healthm_prenatal = (s3dq20*s3dq21) if !mi(s3dq20,s3dq21)
		replace aux_healthm_prenatal = s3dq21 if mi(s3dq20)
			
	egen healthm_prenatal = sum(aux_healthm_prenatal), by(nh clust)

	keep healthm* clust nh
	duplicates drop clust nh, force

	save aux7, replace		
			
* OOPs contraception // we will skip no clarity about when it was consumed
*use "~/Dropbox/LSMS_Compilation/Data/ghana_2005/stata/parta/sec3e.dta", clear
*tab s3eq2

* Consolidate OOPs
	use aux4, clear
		merge 1:1 clust nh using aux5
			drop _merge
		merge 1:1 clust nh using aux6
			drop _merge
		merge 1:1 clust nh using aux7
			drop _merge
			
egen healthm_oops = rsum(healthm*)





*******************************************************************************
*******************************************************************************
				* V. Save  *
*******************************************************************************
*******************************************************************************

* Merge with previous data
merge 1:1 clust nh using aux3	

* Multiply health expenditures by deflator
*replace healthm_oops = healthm_oops * deflator

* Second alternative of deflator directly from data
gen deflator2 = incomec / income
	drop if deflator2<0 // 1 observation has this problem
replace healthm_oops = healthm_oops * deflator2


* Clean
drop if mi(total_consumption)

cd "~/Dropbox/LSMS_Compilation/Analysis/Output_Files/"
gen survey = "Ghana_2006" // changed name
save ghana_2005 , replace





























