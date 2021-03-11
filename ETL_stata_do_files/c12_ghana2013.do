clear all
*******************************************************************************
					*** LSMS Compilation ****
*******************************************************************************
* Program: Ghana
* File Name: c12_ghana2013
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
cd "~/Dropbox/LSMS_Compilation/Data/ghana_2013/DATA/STATA/STATA/AGGREGATES/"


*******************************************************************************
*******************************************************************************
						* I. Consumption Aggregate  *
*******************************************************************************
*******************************************************************************

use POV_GHA_2013_GLSS6-updated, clear

* Fixes
drop hhsize region // repeated vars
rename *, lower // all in lower case

* Replication of nonfood consumption aggregate - includes hospitalization
egen nf = rsum(totclth tothous totfurn tothlth tottrsp totcmnq totrcre toteduc tothotl totmisc)



* Rename
gen HID = hid
rename hid hhid
rename totfood food_consumption
rename tothlth health_consumption
rename hhexp_nr total_consumption
rename totnfd nonfood_consumption
rename wta_s hhweight
rename sex hhead_sex
rename agey hhead_age
rename emp_status hhead_work


* keep rel vars
keep HID hhid region rururb hhsize food_consumption health_consumption ///
nonfood_consumption cpi2005_def total_consumption hhweight surveyr ///
survemo country district clust nh month year poor ///
hhead* povpi

save aux0, replace


* Grab hhead marital status
use "/Users/bsastrakinsky/Dropbox/LSMS_Compilation/Data/ghana_2013/DATA/STATA/STATA/PARTA/SEC1.dta"
keep if (s1q3==1) // only hhead
gen hhead_married = (s1q6==1)

merge 1:1 clust nh using aux0
drop _merge // perfect match



* Grab health expenditures from consumption module
merge 1:1 HID using ///
"~/Dropbox/LSMS_Compilation/Data/ghana_2013/DATA/STATA/STATA/AGGREGATES/06_GHA_EXPHLTH.dta"
drop _merge

* Add hospital expenditures to health consumption
rename HOSP health_hosp_oops
replace health_consumption = health_consumption + health_hosp_oops

* Add hospital expenditures to agg variables (they were not included)
replace total_consumption = total_consumption + health_hosp
replace nonfood_consumption = nonfood_consumption + health_hosp



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

use "~/Dropbox/LSMS_Compilation/Data/ghana_2013/DATA/STATA/STATA/PARTA/SEC3d.dta" , clear

* Current pregnancy in hh
gen aux1 = (s3dq11==1)
	egen preg_currentpregnant = max(aux1) , by(HID)
		label var preg_currentpregnant "Women in hh currently pregnant"
	
	
* Recieved antenatal care
gen aux2 = (s3dq16==1)
	egen preg_antenatal = max(aux2) , by(HID)
		label var preg_antenatal "Women in HH using/used antenatal care last 12 months"
	
* Date first antenatal
egen preg_firstantenatal = min(s3dq17) , by(HID)
	label var preg_firstantenatal "weeks pregnant until first antenatal"
	
* Where recieved care
egen preg_antenatalplace = min(s3dq18) , by(HID)
	label values preg_antenatalplace S3DQ18
		label var preg_antenatalplace "Place of antenatal care consultations"
	
* Times antenatal care
egen preg_antenataltimes = max(s3dq20) , by(HID)
	label var preg_antenataltimes "Number of sessions of antenatal care"

* Why not antenatal care
egen preg_antenatalwhynot = min(s3dq22) , by(HID)
	label values preg_antenatalwhynot S3DQ22
		label var preg_antenatalwhynot "Reaseons for not going for antenatal care"

	
* one obs per hh
keep clust nh HID preg*
duplicates drop HID, force
	
	
save aux2 , replace	
	

*******************************************************************************
*******************************************************************************
						* III. Health Module  *
*******************************************************************************
*******************************************************************************
use "~/Dropbox/LSMS_Compilation/Data/ghana_2013/DATA/STATA/STATA/PARTA/SEC3a.dta" , clear


* Save var labels
foreach v of var * {
 	local l`v' : variable label `v'
        if `"`l`v''"' == "" {
 		local l`v' "`v'"
  	}
  }

  

* Conditions in last 2 weeks  
collapse 	(max) s3aq1 s3aq8 ///
			(min) s3aq3 s3aq5 s3aq7 s3aq18 s3aq26 s3aq27 , by(HID)


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

rename hid HID

save aux3, replace  


*******************************************************************************
*******************************************************************************
						* IV. Grab OOPs from health module  *
*******************************************************************************
*******************************************************************************
use "~/Dropbox/LSMS_Compilation/Data/ghana_2013/DATA/STATA/STATA/PARTA/SEC3a.dta" , clear

* indv exp
egen aux = rsum(s3aq9 s3aq10 s3aq11 s3aq12 s3aq13 s3aq14 s3aq15 s3aq20 s3aq22)
	replace aux = s3aq23 if mi(aux)
	
egen healthm_oops = sum(aux), by(nh clust)
		replace healthm_oops = healthm_oops *2 *13 // annualize expenditures
		
		
duplicates drop clust nh, force
keep healthm_oops clust nh HID

save aux4, replace		


*******************************************************************************
*******************************************************************************
						* V. Save  *
*******************************************************************************
******************************************************************************* 

use aux1, clear
	merge 1:1 HID using aux2
		rename _merge _merge_preg
	
	merge 1:1 HID using aux3
		rename _merge _merge_health
	
	merge 1:1 HID using aux4
		drop _merge

* multiply oops from health module by deflator
replace healthm_oops = healthm_oops * povpi		
		

* Save
cd "~/Dropbox/LSMS_Compilation/Analysis/Output_Files/"
gen survey = "Ghana_2013"
save ghana_2013 , replace

		













  
  
  
  








	
	































