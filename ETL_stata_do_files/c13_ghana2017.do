clear all
*******************************************************************************
					*** LSMS Compilation ****
*******************************************************************************
* Program: Ghana
* File Name: c12_ghana2017
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
						* Ghana 2013 *
*******************************************************************************
*******************************************************************************

* Dir
cd "~/Dropbox/LSMS_Compilation/Data/ghana_2017/aggregate files/aggregate files/"

*******************************************************************************
*******************************************************************************
						* I. Consumption Aggregate  *
*******************************************************************************
*******************************************************************************


use povgh_2017, clear

* Fixes
rename *, lower // all in lower case

* Replication of nonfood consumption aggregate - includes hospitalization
egen nf3 = rsum(totclth tothous totfurn tothlth tottrsp totcmnq totrcre toteduc tothotl totmisc hosp)


* Rename
gen HID = hid
rename hid hhid
rename totfood food_consumption
rename tothlth health_consumption
rename hhexp_n total_consumption
rename hosp health_hosp_oops



rename totnfd nonfood_consumption
rename wta_s hhweight
rename sex hhead_sex
rename s1q5y hhead_age
gen hhead_married = (s1q6==1)
rename emp_status hhead_work

* Add hosp expenditures to health consumption
replace health_consumption = health_consumption + health_hosp_oops if !mi(health_hosp_oops)
replace total_consumption = total_consumption + health_hosp_oops if !mi(health_hosp_oops)
replace nonfood_consumption = nonfood_consumption + health_hosp_oops if !mi(health_hosp_oops)


* keep rel vars
keep phid hhid clust nh pid hhead* hhsize district month year hhstatus ///
loc2 hhweight country survemo surveyr rururb food_consumption ///
health_consumption nonfood_consumption total_consumption pstatus ppp2011
 
 


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

	
save aux1 , replace	

	
*******************************************************************************
*******************************************************************************
						* II. Pregnancies last year  *
*******************************************************************************
*******************************************************************************

* Section for currently pregnant women, or those who have given birth in last 12 months.

use "~/Dropbox/LSMS_Compilation/Data/ghana_2017/PartAB/PartA/g7sec3d.dta" , clear


* Save var labels
foreach v of var * {
 	local l`v' : variable label `v'
        if `"`l`v''"' == "" {
 		local l`v' "`v'"
  	}
  }

  
  
collapse 	(min) s3dq17 s3dq22 s3dq16 s3dq11  ///
			(max) s3dq18 s3dq20 , by(phid)



* put back var labels
  foreach v of var * {
 	label var `v' "`l`v''"
  }
 
* Put back value labels
rename * , upper

  foreach v of var * {
 	capture label values `v' `v' 
	 }

rename *, lower	 



* Rename vars
rename s3dq11 preg_currentpregnant
rename s3dq16 preg_antenatal
rename s3dq17 preg_firstantenatal
rename s3dq18 preg_antenatalplace
rename s3dq20 preg_antenataltimes
rename s3dq22 preg_antenatalwhynot




save aux2, replace



*******************************************************************************
*******************************************************************************
						* III. Health Module  *
*******************************************************************************
*******************************************************************************
use "~/Dropbox/LSMS_Compilation/Data/ghana_2017/PartAB/PartA/g7sec3a.dta" , clear

* Create disability var 
gen s3aq27 =.
tokenize `c(alpha)'

forval i = 1/7{
	replace s3aq27 = `i' if s3aq27``i''==1

}

label def S3AQ27 //// 
	1 "sight" ///
	2 "hearing" ///
	3 "speech" ///
	4 "physical" ///
	5 "intellectual" ///
	6 "emotional" ///
	7 "other"

label values s3aq27 S3AQ27	
label var s3aq27  "Type of disability"




* Save var labels
foreach v of var * {
 	local l`v' : variable label `v'
        if `"`l`v''"' == "" {
 		local l`v' "`v'"
  	}
  }




* Conditions in last 2 weeks  
collapse 	(max) s3aq1 s3aq8 ///
			(min) s3aq3 s3aq5 s3aq7 s3aq18 s3aq26 s3aq27 , by(phid)


* put back var labels
  foreach v of var * {
 	label var `v' "`l`v''"
  }
 
* Put back value labels
rename * , upper

  foreach v of var * {
 	capture label values `v' `v' 
	 }

rename *, lower	 

* Rename vars
rename s3aq1 health_ill
rename s3aq8 health_placeconsultation
rename s3aq3 health_stoppedusualact
rename s3aq5 health_consultation
rename s3aq7 health_reasonconsul
rename s3aq18 health_hospitalization
rename s3aq26 health_disability
rename s3aq27 health_typedisability

save aux3, replace

*******************************************************************************
*******************************************************************************
						* IV. OOPs from health module  *
*******************************************************************************
*******************************************************************************
use "~/Dropbox/LSMS_Compilation/Data/ghana_2017/PartAB/PartA/g7sec3a.dta" , clear

* Indv exp
* replace don't know for zeros
foreach var in s3aq9 s3aq10 s3aq11 s3aq12 s3aq13 s3aq14 s3aq15 s3aq20 s3aq22{
	replace `var'=0 if `var'==-99
}

egen aux = rsum(s3aq9 s3aq10 s3aq11 s3aq12 s3aq13 s3aq14 s3aq15 s3aq20 s3aq22)
	replace aux = s3aq23 if mi(aux)

	
* Household health expenditures
egen healthm_oops = sum(aux), by(nh clust)
		replace healthm_oops = healthm_oops *2 *13 // annualize expenditures
		replace healthm_oops = healthm_oops/100 // cents to dollar
		
duplicates drop phid, force
keep healthm* phid		

save aux4, replace


*******************************************************************************
*******************************************************************************
						* V. Save  *
*******************************************************************************
******************************************************************************* 

use aux1, clear

	merge 1:1 phid using aux2
		rename _merge _merge_preg
	
	merge 1:1 phid using aux3
		rename _merge _merge_health
		
	merge 1:1 phid using aux4
		drop _merge
				

* Save
cd "~/Dropbox/LSMS_Compilation/Analysis/Output_Files/"
gen survey = "Ghana_2017"
save ghana_2017 , replace







	 
 

