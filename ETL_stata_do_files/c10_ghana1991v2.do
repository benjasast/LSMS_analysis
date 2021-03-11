clear all
*******************************************************************************
					*** LSMS Compilation ****
*******************************************************************************
* Program: Nigeria
* File Name: c10_ghana1991v2
* RA: Benjamin Sas
* PI: Karen Grepin
* Date: 07/05/20
* Version: 1				
*******************************************************************************
* Objective: 	* Obtain consumption
				* FP indicators
				* episodic health.
				* Asset list	
*******************************************************************************


* Dir
cd "~/Dropbox/LSMS_Compilation/Data/ghana_1991/data/stata/stata/"

* We will use the harmonized dataset now

*******************************************************************************
*******************************************************************************
						* I. Consumption Aggregate  *
*******************************************************************************
*******************************************************************************
use GHA_1991_E, clear

* lower case
unab vars : _all
rename `vars' , lower


* Main variables
rename hhexp_r 	total_consumption
rename totnfd 	nonfood_consumption
gen food_consumption = total_consumption - nonfood_consumption
rename tothlth	health_consumption


* Non-food replicate: includes health
egen nf3 = rsum(totclth ///
tothous totfurn health_consumption totrcre toteduc tothotl totmisc tottrsp totcmnq)

* Grab more vars
gen urban = (rururb==2)


save aux1b, replace

*******************************************************************************
*******************************************************************************
				* II. Grab Health Expenditures (Consumption Module)  *
*******************************************************************************
*******************************************************************************
* simply a check
use 06_EXPHLTH, clear

* lower case
unab vars : _all
rename `vars' , lower

* they did not include hospitalization
egen health_consumption2 = rsum(hlmedi hloutp hosp)

rename hlmedi health_medprod
rename hloutp health_outpat
rename hosp	  health_hosp


* merge with other data
merge 1:1 hid using aux1b
	drop _merge


* Correct consumption
replace total_consumption = total_consumption - health_consumption + health_consumption2	
replace nonfood_consumption = total_consumption - health_consumption + health_consumption2	

drop health_consumption
rename health_consumption2 health_consumption	
	

save aux2b, replace	


*******************************************************************************
*******************************************************************************
				* III. OOPS health module  *
*******************************************************************************
*******************************************************************************
* Grab Episodic OOPs
	use S3A, clear


	egen aux = rsum(s3aq11 s3aq12 s3aq16 s3aq18)
	egen healthm_episodic = sum(aux), by(clust nh)

	* Hospitalization (2 week recall)
	gen aux_hosp = (s3aq14==1)
	egen episodic_hosp = max(aux_hosp) , by(clust nh)

	
	* Put them in yearly amounts: 2 weeks to 52 weeks
	replace healthm_episodic = healthm_episodic * 13 * 2
	duplicates drop nh clust, force
	
	save aux5, replace


* Grab Vaccination OOOPSs
	use S3B, clear

	* Keep only vaccinated in the last year (options 1 or 2, complete set or incomplete)
	egen aux_vac = rowmin(s3bq4a s3bq4b s3bq4c s3bq4d)
	keep if aux_vac==1 | aux_vac==2

	* grab OOPs (yearly - for latest vaccination)
	egen healthm_vacc = sum(s3bq7) , by(clust nh)

	keep nh clust healthm*		
	duplicates drop nh clust, force
	save aux6, replace

* Grab postnatal OOPs
	use S3C, clear
	keep if s3cq1==1 // had postnatal care last 12 month

	gen aux_healthm_postnatal = s3cq2*s3cq4 if !mi(s3cq2,s3cq4)
		replace aux_healthm_postnatal = s3cq4 if mi(s3cq2)
		
	* get it by hh
	egen healthm_postnatal = sum(aux_healthm_postnatal) , by(clust nh)	
	
	keep nh clust healthm*	
	duplicates drop nh clust, force
	save aux6, replace

* Grab Prenatal OOPs
	use S3D, clear
	keep if s3dq11==1 // keep only pregnant in last 12 months

	* How many times
	egen aux_times = rsum(s3dq17a s3dq17b)
	gen aux_prenatal = aux_times * s3dq18 if !mi(aux_times,s3dq18)
		replace aux_prenatal = s3dq18 if mi(aux_times)
		
	egen healthm_prenatal = sum(aux_prenatal), by(clust nh)
	
	duplicates drop nh clust, force
	save aux7, replace

	
* Grab contraceptive method OOPs
	use S3D, clear

	egen healthm_prevention = sum(s3dq23) , by(clust nh)
		replace healthm_prevention = healthm_prevention * 13 // monthly to yearly

	keep nh clust healthm*	
	duplicates drop nh clust, force	
	save aux8, replace

* Put all OOPs together
use aux5, clear

forval i = 6(1)8{
	merge 1:1 clust nh using aux`i'
		drop _merge

}

keep clust nh healthm* epi*

* Zeros
unab healthm_list: healthm*
	foreach var in `healthm_list'{
		replace `var' = 0 if mi(`var')
	}
	
* Get total OOPs
egen healthm_oops = rsum(healthm*)

* Create id
tostring clust, gen(aux1)
gen aux2 = "/"
tostring nh, gen(aux3)
gen hid = aux1+aux2+aux3
drop aux*

* Merge with rest
merge 1:1 hid using aux2b
	drop if _merge!=3
	drop _merge

save aux3b, replace	
	
*******************************************************************************
*******************************************************************************
				* IV. Grab more hh characteristics  *
*******************************************************************************
*******************************************************************************	
use GHA_1991_H, clear

* lower case
unab vars : _all
rename `vars' , lower

* Important vars
rename wta_hh hhweight
gen hhead_female = (hhsex==0)
rename hhagey hhead_age
gen hhead_married = (hhmarst==2|hhmarst==3)
rename hhedlev hhead_educ 


* Merge with other data
merge 1:1 hid using aux3b
	drop if _merge!=3
	drop _merge
	
	
* Drop useless obs
drop if mi(hhweight)
rename hid hhid


cd "~/Dropbox/LSMS_Compilation/Analysis/Output_Files/"
gen survey = "Ghana_1991"
save ghana_1991 , replace
	





	




















