*******************************************************************************
					*** LSMS Compilation ****
*******************************************************************************
* Program: Ethiopia Consumption
* File Name: p01_consolidation_variables
* RA: Benjamin Sas
* PI: Karen Grepin
* Date: 18/03/20
* Version: 1				
*******************************************************************************
* Objective: 	* Obtain consumption
				* FP indicators
				* episodic health.
				* Asset list	
*******************************************************************************


*******************************************************************************
*******************************************************************************
						* I. Set-up  *
*******************************************************************************
*******************************************************************************
clear all

* Dir
cd "~/Dropbox/LSMS_Compilation/Analysis/Output_Files/"

* Levels of key variables
/*
hhead_education:
           0 No education
           1 Elementary School
           2 High School
           3 Higher education
		   
recall_health: in weeks	

health_recall2: average of recall period across questions.


hhid: as string
	   
*/


*******************************************************************************
*******************************************************************************
						* 1. Ethiopia 2015  *
*******************************************************************************
*******************************************************************************

use ethiopia_2015, clear

* OOOPs from health module
gen healthm_items = 1
gen healthm_recall = 52
gen healthm_recall2 = 28
gen healthm_module = "Health"
gen year = 2015 


gen hhid_compilation = survey + hhid

* For consistency
gen nonhealth_consumption = total_consumption - health_consumption
gen nonfood_nohealth_consumption = nonfood_consumption - health_consumption
clonevar healthm_oops = health_consumption
drop health_consumption


drop consumption_quintile // make it from nonhealth consumption
xtile consumption_quintile = nonhealth_consumption , nq(5)
 	

	
* One duplicate id
duplicates drop hhid_compilation, force


keep hhid* hhsize hhweight urban ///
	consumption_quintile *consumption ///
	episodic_hosp ///
	che* ///
	hhead* ///
	survey  year healthm*

	
save aux_tidy, replace


*******************************************************************************
*******************************************************************************
						* 2. Ghana 1988  *
*******************************************************************************
*******************************************************************************

use ghana_1988, clear

* OOPs from consumption module
gen health_items = 2
gen health_recall = 52
gen health_recall2 = 52
gen health_module = "Consumption"

* OOPs from health module
gen healthm_items = 4
gen healthm_recall = 4
gen healthm_recall2 = 4
gen healthm_module = "Health"

* Nonhealth consumption
gen nonhealth_consumption = total_consumption - health_consumption
gen nonfood_nohealth_consumption = nonfood_consumption - health_consumption
xtile consumption_quintile = nonhealth_consumption , nq(5)


recode hhead_education ///
	(0 = 0 "No education") ///
	(1 = 1 "Elementary School") ///
	(2 = 2 "High School") ///
	(3 = 3 "Higher education"), gen(hhead_education2)

drop hhead_education
rename hhead_education2 hhead_education	

tostring hhid, replace
gen hhid_compilation = survey + hhid


**********
* NO HHWEIGHT. NO HOSP INFO
* According to WB microdata, weights were equal across all HHs by survey
* construction
gen hhweight =1
********


* One duplicate id
duplicates drop hhid_compilation, force



keep hhid* hhsize hhweight epi* urban ///
	consumption_quintile *consumption ///
	che* ///
	hhead* ///
	survey health_items health_recall* health_module year healthm*


append using aux_tidy, force
save aux_tidy, replace

*******************************************************************************
*******************************************************************************
						* 3. Ghana 1989  *
*******************************************************************************
*******************************************************************************
* 88-89
use ghana_1989, clear


* OOPs from consumption module
gen health_items = 2
gen health_recall = 52
gen health_recall2 = 52
gen health_module = "Consumption"

* OOPs from health module
gen healthm_items = 4
gen healthm_recall = 4
gen healthm_recall2 = 4
gen healthm_module = "Health"

* Nonhealth consumption
gen nonhealth_consumption = total_consumption - health_consumption
gen nonfood_nohealth_consumption = nonfood_consumption - health_consumption
xtile consumption_quintile = nonhealth_consumption , nq(5)



recode hhead_education ///
	(0 = 0 "No education") ///
	(1 = 1 "Elementary School") ///
	(2 = 2 "High School") ///
	(3 = 3 "Higher education"), gen(hhead_education2)

drop hhead_education
rename hhead_education2 hhead_education	

tostring hhid, replace
gen hhid_compilation = survey + hhid


**********
* There is information on assets, and we have not exploded episodic information yet
* Need to get hhead married information too.

* NO HHWEIGHT INFO.
********

************************
* too many empty obs -- we have Health OOPs for them but nothing else
drop if mi(total_consumption)
************************

keep hhid* hhsize urban ///
	consumption_quintile *consumption epi* ///
	che* ///
	hhead* ///
	survey health_items health_recall* health_module year healthm*


append using aux_tidy, force
save aux_tidy, replace


*******************************************************************************
*******************************************************************************
						* 4. Ghana 1991  *
*******************************************************************************
*******************************************************************************
* 8 with 12 month recall period, there are 5 items also filled as expenditure since last visit.

use ghana_1991, clear

* OOPs from consumption module
gen health_items = 8
gen health_recall = 52
gen health_recall2 = ( (7*52)+(5*13) ) / 12
gen health_module = "Consumption"

* OOPs from health module
gen healthm_items = 8
gen healthm_recall = 2
gen healthm_recall2 = (2*4+12*4)/8
gen healthm_module = "Health"

* Nonhealth consumption
gen nonhealth_consumption = total_consumption - health_consumption
gen nonfood_nohealth_consumption = nonfood_consumption - health_consumption
xtile consumption_quintile = nonhealth_consumption , nq(5)

*******
*************************************************************
drop if nonhealth_consumption<0 // I have to check this!! --
* there was massive outlier control on the survey detailed in the report
*************************************************************
*******
gen year = 1991

* HHID
drop hhid
egen hhid = group(clust nh)
tostring hhid, replace
gen hhid_compilation = survey + hhid



keep hhid* hhsize hhweight epi* urban ///
	consumption_quintile *consumption ///
	hhead* ///
	survey health_items health_recall* health_module year healthm*


append using aux_tidy, force
save aux_tidy, replace


*******************************************************************************
*******************************************************************************
						* 5. Ghana 1998  *
*******************************************************************************
*******************************************************************************

*******************************************************************************
*******************************************************************************
						* 6. Ghana 2005  *
*******************************************************************************
*******************************************************************************
use ghana_2005, clear

* OOPs from consumption module
gen health_items = 22
gen health_recall = 52
gen health_recall2 = ( (17*52)+(5*13) ) / 22
gen health_module = "Consumption"

* OOPs from health module
gen healthm_items = 5 // did not use other 4 items
gen healthm_recall = 2
gen healthm_recall2 = 2
gen healthm_module = "Health"

* Nonhealth consumption
gen nonhealth_consumption = total_consumption - health_consumption
gen nonfood_nohealth_consumption = nonfood_consumption - health_consumption
xtile consumption_quintile = nonhealth_consumption , nq(5)



gen hhead_female = (hhead_sex==2)


* HHID
capture tostring nh, replace
capture tostring clust, replace
gen hhid_compilation = survey + clust + nh



keep hhid* hhsize hhweight epi* urban ///
	consumption_quintile *consumption ///
	che* ///
	hhead* ///
	survey health_items health_recall* health_module year healthm*


append using aux_tidy, force
save aux_tidy, replace

*******************************************************************************
*******************************************************************************
						* 6. Ghana 2013  *
*******************************************************************************
*******************************************************************************

use ghana_2013, clear

* OOPs from consumption module
gen health_items = 22
gen health_recall = 52
gen health_recall2 = ( (17*52)+(5*13) )/22
gen health_module = "Consumption"


* OOPs from health module
gen healthm_items = 14
gen healthm_recall = 2
gen healthm_recall2 = 2
gen healthm_module = "Health"

* Nonhealth consumption
gen nonhealth_consumption = total_consumption - health_consumption
gen nonfood_nohealth_consumption = nonfood_consumption - health_consumption
xtile consumption_quintile = nonhealth_consumption , nq(5)


gen hhead_female = (hhead_sex==2)

* Hospitalization
gen episodic_hosp = (health_hospitalization==1)

* HHID
gen hhid_compilation = survey + hhid

* rural urb
gen urban = (rururb==2)

keep hhid* hhsize hhweight epi* urban ///
	consumption_quintile *consumption ///
	che* ///
	hhead* ///
	survey health_items health_recall* health_module year healthm*

	
append using aux_tidy, force
save aux_tidy, replace

*******************************************************************************
*******************************************************************************
						* 7. Ghana 2017  *
*******************************************************************************
*******************************************************************************
	
use ghana_2017, clear

* OOPs from consumption module
gen health_items = 32
gen health_recall = 52
gen health_recall2 = ( (26*52)+(6*13) )/32
gen health_module = "Consumption"

* OOPs from health module
gen healthm_items = 14
gen healthm_recall = 2
gen healthm_recall2 = 2
gen healthm_module = "Health"

* Nonhealth consumption
gen nonhealth_consumption = total_consumption - health_consumption
gen nonfood_nohealth_consumption = nonfood_consumption - health_consumption
xtile consumption_quintile = nonhealth_consumption , nq(5)

* female
gen hhead_female = (hhead_sex==2)
* Hospitalization
gen episodic_hosp = (health_hospitalization==1)

* HHID
gen hhid_compilation = survey + phid

* Urban
gen urban = (loc2==1)


keep hhid* hhsize hhweight epi* urban ///
	hhead* ///
	consumption_quintile *consumption ///
	che* ///
	survey health_items health_recall* health_module year healthm*
	
* Lots of empty obs somehow
drop if mi(hhid)	

append using aux_tidy, force
save aux_tidy, replace

*******************************************************************************
*******************************************************************************
						* 8. Iraq 2006  *
*******************************************************************************
*******************************************************************************
	
use iraq_2006, clear

* OOPs from consumption module
gen health_items = 44
gen health_recall = 9
gen health_recall2 = ( (11*52)+(29*13)+(4*4)) /44
gen health_module = "Consumption"

* OOPs from health module
gen healthm_items = 5
gen healthm_recall = 4
gen healthm_recall2 = 4
gen healthm_module = "Health"

* Nonhealth consumption
gen nonhealth_consumption = total_consumption - health_consumption
gen nonfood_nohealth_consumption = nonfood_consumption - health_consumption
xtile consumption_quintile = nonhealth_consumption , nq(5)


gen year = 2006

tostring hhid, replace
gen hhid_compilation = survey + hhid
drop if hhid=="." // all empty



keep hhid* hhsize hhweight urban ///
	consumption_quintile *consumption ///
	che* hhead* ///
	survey health_items health_recall* health_module year healthm*


append using aux_tidy, force
save aux_tidy, replace


*******************************************************************************
*******************************************************************************
						* 9. Iraq 2012  *
*******************************************************************************
*******************************************************************************
use iraq_2012, clear

* OOPs from consumption module
gen health_items =  46
gen health_recall = 12
gen health_recall2 = ( (5*4)+(29*13)+(12*52) ) /46
gen health_module = "Consumption"

* Nonhealth consumption
gen nonhealth_consumption = total_consumption - health_consumption
gen nonfood_nohealth_consumption = nonfood_consumption - health_consumption
xtile consumption_quintile = nonhealth_consumption , nq(5)


gen year = 2012
tostring hhid, replace
gen hhid_compilation = survey + hhid
drop if hhid=="." // all empty



keep hhid* hhsize hhweight ///
	consumption_quintile *consumption ///
	che* ///
	hhead* ///
	survey health_items health_recall* health_module year urban


append using aux_tidy, force
save aux_tidy, replace

*******************************************************************************
*******************************************************************************
						* 10. Malawi 2004  *
*******************************************************************************
*******************************************************************************

use malawi_2004,clear 

* OOPs from health module
gen healthm_items =  5
gen healthm_recall = 4
gen healthm_recall2 = ((4*4)+(1*52)) / 5
gen healthm_module = "Health"



gen year = 2004

gen hhead_maried = (hhead_mar==1 | hhead_mar==2)
rename hhead_fem hhead_female
rename case_id hhid



recode hhead_grd ///
	(0/3 = 0 "No education") ///
	(4/13 = 1 "Elementary School") ///
	(14/17 20/22 = 2 "High School" ) ///
	(18/19 23 = 3 "Higher Education"), ///
	gen(hhead_education)

gen hhid2 = _n
tostring hhid2, replace force	
gen hhid_compilation = survey + hhid2
	
* For consistency
gen nonhealth_consumption = total_consumption - health_consumption
gen nonfood_nohealth_consumption = nonfood_consumption - health_consumption
clonevar healthm_oops = health_consumption
drop health_consumption 	
xtile consumption_quintile = nonhealth_consumption , nq(5)


	
keep hhid* hhsize hhweight ///
	consumption_quintile *consumption ///
	che* ///
	hhead* ///
	episodic_hosp ///
	survey year healthm* episodic_hosp urban

append using aux_tidy, force
save aux_tidy, replace	
	
	
*******************************************************************************
*******************************************************************************
						* 11. Malawi 2010   *
*******************************************************************************
*******************************************************************************

use malawi_2010,clear 

* OOPs from health module
gen healthm_items =  9
gen healthm_recall = 4
gen healthm_recall2 = ( (5*4)+(4*52) )/9
gen healthm_module = "Health"


gen year = 2010


gen hhead_female = (hhead_sex==2)

recode hhead_education ///
	(1 = 0 "None") ///
	(2/3 = 1 "Elementary School") ///
	(3/5 = 2 "High School") ///
	(6/7 = 3 "Higher Education") ///
	, gen(hhead_education2)
	
drop hhead_education
rename hhead_education2 hhead_education

* For consistency
gen nonhealth_consumption = total_consumption - health_consumption
gen nonfood_nohealth_consumption = nonfood_consumption - health_consumption
clonevar healthm_oops = health_consumption
drop health_consumption 
xtile consumption_quintile = nonhealth_consumption , nq(5)
	
rename case_id hhid


* ID
gen aux = _n
tostring aux, replace
gen hhid_compilation = survey + aux




keep hhid* hhsize hhweight ///
	consumption_quintile *consumption ///
	che* ///
	hhead* ///
	episodic_hosp ///
	survey  year healthm* urban
	

append using aux_tidy, force
save aux_tidy, replace	
	
*******************************************************************************
*******************************************************************************
						* 12. Malawi 2013    *
*******************************************************************************
*******************************************************************************

use malawi_2013,clear 

* OOPs from health module
gen healthm_items =  9
gen healthm_recall = 4
gen healthm_recall2 = ( (5*4)+(4*52) )/9
gen healthm_module = "Health"


gen year = 2013

rename case_id hhid

recode hhead_educ ///
	(1 = 0 "None") ///
	(2/3 = 1 "Elementary School") ///
	(3/5 = 2 "High School") ///
	(6/7 = 3 "Higher Education") ///
	, gen(hhead_education)
	

* For consistency
gen nonhealth_consumption = total_consumption - health_consumption
gen nonfood_nohealth_consumption = nonfood_consumption - health_consumption
clonevar healthm_oops = health_consumption
drop health_consumption 
xtile consumption_quintile = nonhealth_consumption , nq(5)
	

gen hhid2 = _n
tostring hhid2, replace force	
gen hhid_compilation = survey + hhid2
	

keep hhid* hhsize hhweight ///
	consumption_quintile *consumption ///
	che* ///
	hhead* ///
	episodic_hosp ///
	survey year healthm* urban
	

append using aux_tidy, force
save aux_tidy, replace	
	
*******************************************************************************
*******************************************************************************
						* 13. Malawi 2016   *
*******************************************************************************
*******************************************************************************

use malawi_2016, clear

* OOPs from health module
gen healthm_items =  9
gen healthm_recall = 52
gen healthm_recall2 = ( (3*4)+(6*52) )/9
gen healthm_module = "Health"



gen year = 2016

rename case_id hhid
rename hh_wgt hhweight

recode hhead_educ ///
	(1 = 0 "None") ///
	(2/3 = 1 "Elementary School") ///
	(3/5 = 2 "High School") ///
	(6/7 = 3 "Higher Education") ///
	, gen(hhead_education2)
	
drop hhead_educ
rename hhead_education2 hhead_education

* For consistency
gen nonhealth_consumption = total_consumption - health_consumption
gen nonfood_nohealth_consumption = nonfood_consumption - health_consumption
clonevar healthm_oops = health_consumption
drop health_consumption 
xtile consumption_quintile = nonhealth_consumption , nq(5)
	



gen hhid2 = _n
tostring hhid2, replace force	
gen hhid_compilation = survey + hhid2
	



keep hhid* hhsize hhweight ///
	consumption_quintile *consumption ///
	episodic_hosp ///
	che* ///
	hhead* ///
	survey year healthm* urban
	

append using aux_tidy, force
save aux_tidy, replace	
	
*******************************************************************************
*******************************************************************************
						* 14. Tanzania NPS 2008   *
*******************************************************************************
*******************************************************************************

use tanzaniaNPS_2008, clear

* OOPs in health module
gen healthm_items =  5
gen healthm_recall = 4
gen healthm_recall2 = ( (3*4)+(2*52) )/5
gen healthm_module = "Health"


gen year = 2008


recode hhead_educ ///
	(1/13 = 0 "None") ///
	(14/32 = 1 "Elementary School") ///
	(33/43 = 2 "High School") ///
	(44/45 = 3 "Higher Education") ///
	, gen(hhead_education)
	

gen hhid_compilation = survey + hhid
	
* For consistency
gen nonhealth_consumption = total_consumption - health_consumption
gen nonfood_nohealth_consumption = nonfood_consumption - health_consumption
clonevar healthm_oops = health_consumption
drop health_consumption 	
xtile consumption_quintile = nonhealth_consumption , nq(5)

	
keep hhid* hhsize hhweight ///
	consumption_quintile *consumption ///
	episodic_hosp ///
	che* ///
	hhead* ///
	survey year healthm* urban
	

append using aux_tidy, force
save aux_tidy, replace	

*******************************************************************************
*******************************************************************************
						* 15. Tanzania NPS 2010  *
*******************************************************************************
*******************************************************************************

use tanzaniaNPS_2010, clear


* OOPs from health module
gen healthm_items =  6
gen healthm_recall = 4
gen healthm_recall2 = ((4*4)+(2*52))/6
gen healthm_module = "Health"

gen year = 2010

recode hhead_educ ///
	(1/13 = 0 "None") ///
	(14/32 = 1 "Elementary School") ///
	(33/43 = 2 "High School") ///
	(44/45 = 3 "Higher Education") ///
	, gen(hhead_education)

replace hhead_educ = 0 if mi(hhead_educ)


gen hhid_compilation = survey + hhid

* For consistency
gen nonhealth_consumption = total_consumption - health_consumption
gen nonfood_nohealth_consumption = nonfood_consumption - health_consumption
clonevar healthm_oops = health_consumption
drop health_consumption 	
xtile consumption_quintile = nonhealth_consumption , nq(5)



keep hhid* hhsize hhweight ///
	consumption_quintile *consumption ///
	episodic_hosp ///
	che* ///
	hhead* ///
	survey  year healthm* urban


append using aux_tidy, force
save aux_tidy, replace

*******************************************************************************
*******************************************************************************
						* 16. Tanzania NPS 2012   *
*******************************************************************************
*******************************************************************************

use tanzaniaNPS_2012, clear

* OOPs from health module
gen healthm_items =  6
gen healthm_recall = 4
gen healthm_recall2 = ( (4*4)+(2*52) )/6
gen healthm_module = "Health"



gen year = 2012

recode hhead_educ ///
	(1/13 = 0 "None") ///
	(14/32 = 1 "Elementary School") ///
	(33/43 = 2 "High School") ///
	(44/45 = 3 "Higher Education") ///
	, gen(hhead_education)

replace hhead_educ = 0 if mi(hhead_educ)

rename y3_hhid hhid
rename y3_weight hhweight

gen hhid_compilation = survey + hhid

* For consistency
gen nonhealth_consumption = total_consumption - health_consumption
gen nonfood_nohealth_consumption = nonfood_consumption - health_consumption
clonevar healthm_oops = health_consumption
drop health_consumption 	
xtile consumption_quintile = nonhealth_consumption , nq(5)

* drop thoswe without weights
drop if mi(hhweight)



keep hhid* hhsize hhweight ///
	consumption_quintile *consumption ///
	episodic_hosp ///
	che* ///
	hhead* ///
	survey  year healthm* urban


append using aux_tidy, force
save aux_tidy, replace

*******************************************************************************
*******************************************************************************
						* 16. Tanzania NPS 2014   *
*******************************************************************************
*******************************************************************************

use tanzaniaNPS_2014, clear

* OOPS from health module
gen healthm_items =  6
gen healthm_recall = 4
gen healthm_recall2 = ( (4*4)+(2*52) )/6
gen healthm_module = "Health"


gen year = 2014

recode hhead_educ ///
	(1/13 = 0 "None") ///
	(14/32 = 1 "Elementary School") ///
	(33/43 = 2 "High School") ///
	(44/45 = 3 "Higher Education") ///
	, gen(hhead_education)

replace hhead_educ = 0 if mi(hhead_educ)

rename y4_hhid hhid



gen hhid_compilation = survey + hhid

* For consistency
gen nonhealth_consumption = total_consumption - health_consumption
gen nonfood_nohealth_consumption = nonfood_consumption - health_consumption
clonevar healthm_oops = health_consumption
drop health_consumption 
xtile consumption_quintile = nonhealth_consumption , nq(5)
	


keep hhid* hhsize hhweight ///
	consumption_quintile *consumption ///
	episodic_hosp ///
	che* ///
	hhead* ///
	survey  year healthm* urban


append using aux_tidy, force
save aux_tidy, replace


*******************************************************************************
*******************************************************************************
						* 17. Nigeria 2010   *
*******************************************************************************
*******************************************************************************
use nigeria_2010, clear

* OOPs from consumption module
gen health_items =  1
gen health_recall = 26
gen health_recall2 = 26
gen health_module = "Consumption"

* OOPs from health module
gen healthm_items = 5 
gen healthm_recall = 4
gen healthm_recall2 = (4*3+12*2)/5
gen healthm_module = "Health"


* Nonhealth consumption
gen nonhealth_consumption = total_consumption - health_consumption
gen nonfood_nohealth_consumption = nonfood_consumption - health_consumption
xtile consumption_quintile = nonhealth_consumption , nq(5)



* ID
capture tostring hhid, replace
gen hhid_compilation = survey + hhid

*urban 
gen urban = (rururb==1)



keep hhid* hhsize hhweight epi* urban ///
	consumption_quintile *consumption ///
	che* ///
	hhead* ///
	survey health_items health_recall* health_module year healthm*


append using aux_tidy, force
save aux_tidy, replace


*******************************************************************************
*******************************************************************************
						* 18. Nigeria 2012    *
*******************************************************************************
*******************************************************************************
use nigeria_2012, clear

* OOPs from consumption module
gen health_items =  5
gen health_recall = 26
gen health_recall2 = 26
gen health_module = "Consumption"


* OOPs from health module
gen healthm_items = 1
gen healthm_recall = 4
gen healthm_recall2 = (4*3+12*2)/5
gen healthm_module = "Health"

* Nonhealth consumption
gen nonhealth_consumption = total_consumption - health_consumption
gen nonfood_nohealth_consumption = nonfood_consumption - health_consumption
xtile consumption_quintile = nonhealth_consumption , nq(5)


* ID
capture tostring hhid, replace
capture tostring ea, replace force
gen hhid_compilation = survey + ea + hhid

*urban 
gen urban = (rururb==1)


keep hhid* hhsize hhweight epi* urban ///
	consumption_quintile *consumption ///
	che* ///
	hhead* ///
	survey health_items health_recall* health_module year healthm*


append using aux_tidy, force
save aux_tidy, replace

*******************************************************************************
*******************************************************************************
						* 19. Nigeria 2015    *
*******************************************************************************
*******************************************************************************
use nigeria_2015, clear

* OOPs from consumption module
gen health_items = 1 
gen health_recall = 26
gen health_recall2 = 26
gen health_module = "Consumption"

* OOPs from health module
gen healthm_items = 5
gen healthm_recall = 4
gen healthm_recall2 = (4*3+12*2)/5
gen healthm_module = "Health"


* Nonhealth consumption
gen nonhealth_consumption = total_consumption - health_consumption
gen nonfood_nohealth_consumption = nonfood_consumption - health_consumption
xtile consumption_quintile = nonhealth_consumption , nq(5)

* ID
capture tostring hhid, replace
gen hhid_compilation = survey + hhid

*urban 
gen urban = (rururb==1)


keep hhid* hhsize hhweight epi*  urban ///
	consumption_quintile *consumption ///
	che* ///
	hhead* ///
	survey health_items health_recall* health_module year healthm*

append using aux_tidy, force
save aux_tidy, replace


*******************************************************************************
*******************************************************************************
						* 20. Uganda 2005    *
*******************************************************************************
*******************************************************************************
use uganda_2005, clear

* OOPs from consumption module
gen health_items = 5
gen health_recall = 4
gen health_recall2 = 4
gen health_module = "Consumption"


* OOPs from health module
gen healthm_items = 2
gen healthm_recall = 4
gen healthm_recall2 = 4
gen healthm_module = "Health"

* Nonhealth consumption
gen nonhealth_consumption = total_consumption - health_consumption
gen nonfood_nohealth_consumption = nonfood_consumption - health_consumption
xtile consumption_quintile = nonhealth_consumption , nq(5)


* Fix education
recode hhead_educ ///
	(0/13 99 = 0 "None") ///
	(14/22 41 = 1 "Elementary School") ///
	(23/33 = 2 "High School") ///
	(34/36 51 61 = 3 "Higher Education") ///
	, gen(aux)

drop hhead_educ
rename aux hhead_educ


* ID
egen aux = group(hhid)
tostring aux, replace
gen hhid_compilation = survey + aux
	
	

keep hhid* hhsize hhweight urban  ///
	consumption_quintile *consumption ///
	che* ///
	hhead* ///
	survey health_items health_recall* health_module year healthm*


append using aux_tidy, force
save aux_tidy, replace


*******************************************************************************
*******************************************************************************
						* 21. Uganda 2009 *
*******************************************************************************
*******************************************************************************
use uganda_2009, clear


* OOPs from consumption module
gen health_items = 5
gen health_recall = 4
gen health_recall2 = 4
gen health_module = "Consumption"

* OOPs from health module
gen healthm_items = 1
gen healthm_recall = 4
gen healthm_recall2 = 4
gen healthm_module = "Health"


* Nonhealth consumption
gen nonhealth_consumption = total_consumption - health_consumption
gen nonfood_nohealth_consumption = nonfood_consumption - health_consumption
xtile consumption_quintile = nonhealth_consumption , nq(5)



recode hhead_educ ///
	(0/13 99 = 0 "None") ///
	(14/22 41 = 1 "Elementary School") ///
	(23/33 = 2 "High School") ///
	(34/36 51 61 = 3 "Higher Education") ///
	, gen(aux)
	
drop hhead_educ
rename aux hhead_educ
		

* ID
egen aux = group(hhid)
tostring aux, replace
gen hhid_compilation = survey + aux
	
		
		

keep hhid* hhsize hhweight urban ///
	consumption_quintile *consumption ///
	che* ///
	hhead* ///
	survey health_items health_recall* health_module year healthm*


append using aux_tidy, force
save aux_tidy, replace

*******************************************************************************
*******************************************************************************
						* 22. Uganda 2010 *
*******************************************************************************
*******************************************************************************
use uganda_2010, clear

* OOPs from consumption module
gen health_items = 5
gen health_recall = 4
gen health_recall2 = 4
gen health_module = "Consumption"

* OOPs from health module
gen healthm_items = 1
gen healthm_recall = 4
gen healthm_recall2 = 4
gen healthm_module = "Health"

* Nonhealth consumption
gen nonhealth_consumption = total_consumption - health_consumption
gen nonfood_nohealth_consumption = nonfood_consumption - health_consumption
xtile consumption_quintile = nonhealth_consumption , nq(5)



recode hhead_educ ///
	(0/13 99 = 0 "None") ///
	(14/22 41 = 1 "Elementary School") ///
	(23/33 = 2 "High School") ///
	(34/36 51 61 = 3 "Higher Education") ///
	, gen(aux)
	
drop hhead_educ
rename aux hhead_educ


* ID
egen aux = group(hhid)
tostring aux, replace
gen hhid_compilation = survey + aux
	


* drop those without weights
drop if mi(hhweight)
	


keep hhid* hhsize hhweight urban ///
	consumption_quintile *consumption ///
	che* ///
	hhead* ///
	survey health_items health_recall* health_module year healthm*


append using aux_tidy, force
save aux_tidy, replace

*******************************************************************************
*******************************************************************************
						* 23. Uganda 2011  *
*******************************************************************************
*******************************************************************************
use uganda_2011, clear

* OOOps from consumption module
gen health_items = 5
gen health_recall = 4
gen health_recall2 = 4
gen health_module = "Consumption"

* OOPs from health module
gen healthm_items = 1
gen healthm_recall = 4
gen healthm_recall2 = 4
gen healthm_module = "Health"

* Nonhealth consumption
gen nonhealth_consumption = total_consumption - health_consumption
gen nonfood_nohealth_consumption = nonfood_consumption - health_consumption
xtile consumption_quintile = nonhealth_consumption , nq(5)



recode hhead_educ ///
	(0/13 99 = 0 "None") ///
	(14/22 41 = 1 "Elementary School") ///
	(23/33 = 2 "High School") ///
	(34/36 51 61 = 3 "Higher Education") ///
	, gen(aux)

* ID
egen aux33 = group(hhid)
tostring aux33, replace
gen hhid_compilation = survey + aux33
	

* drop thoswe without weights
drop if mi(hhweight)
	
	
	
keep hhid* hhsize hhweight urban ///
	consumption_quintile *consumption ///
	che* ///
	hhead* ///
	survey health_items health_recall* health_module year healthm*


append using aux_tidy, force
save aux_tidy, replace


*******************************************************************************
*******************************************************************************
						* 24. Uganda 2013  *
*******************************************************************************
*******************************************************************************
use uganda_2013, clear


* OOPs from consumption module
gen health_items = 5
gen health_recall = 4
gen health_recall2 = 4
gen health_module = "Consumption"

* OOPs from health module
gen healthm_items = 1
gen healthm_recall = 4
gen healthm_recall2 = 4
gen healthm_module = "Health"

* Nonhealth consumption
gen nonhealth_consumption = total_consumption - health_consumption
gen nonfood_nohealth_consumption = nonfood_consumption - health_consumption
xtile consumption_quintile = nonhealth_consumption , nq(5)


recode hhead_educ ///
	(0/13 99 = 0 "None") ///
	(14/22 41 = 1 "Elementary School") ///
	(23/33 = 2 "High School") ///
	(34/36 51 61 = 3 "Higher Education") ///
	, gen(aux)
drop hhead_educ
rename aux hhead_educ	

	
* ID
gen hhid_compilation = survey + hhid_new


* drop non-useful obs
drop if mi(hhid)	
	
keep hhid* hhsize hhweight urban ///
	consumption_quintile *consumption ///
	che* ///
	hhead* ///
	survey health_items health_recall* health_module year healthm*


append using aux_tidy, force
save aux_tidy, replace


*******************************************************************************
*******************************************************************************
						* 25. Albania 2002  *
*******************************************************************************
*******************************************************************************
use albania_2002, clear

* OOPs from health module
gen healthm_items = 30
gen healthm_recall = 4
gen healthm_recall2 = ((4*20)+(52*10)) / 30
gen healthm_module = "Health"


* ID
egen aux = group(hhid)
tostring aux, replace
gen hhid_compilation = survey + aux


* For consistency
gen nonhealth_consumption = total_consumption - health_consumption
gen nonfood_nohealth_consumption = nonfood_consumption - health_consumption
clonevar healthm_oops = health_consumption
drop health_consumption 	
xtile consumption_quintile = nonhealth_consumption , nq(5)


keep hhid* hhsize ///
	consumption_quintile *consumption ///
	che* ///
	survey year healthm*	 ///
	urban episodic_hosp hhead*
	
append using aux_tidy, force
save aux_tidy, replace



*******************************************************************************
*******************************************************************************
						* 26. Albania 2005  *
*******************************************************************************
*******************************************************************************
use albania_2005, clear

* OOPs from health module
gen healthm_items = 36
gen healthm_recall = 4
gen healthm_recall2 = ((4*26)+(52*10)) / 36
gen healthm_module = "Health"


* ID
egen aux = group(hhid)
tostring aux, replace
gen hhid_compilation = survey + aux


* For consistency
gen nonhealth_consumption = total_consumption - health_consumption
gen nonfood_nohealth_consumption = nonfood_consumption - health_consumption
clonevar healthm_oops = health_consumption
drop health_consumption 
xtile consumption_quintile = nonhealth_consumption , nq(5)
	


keep hhid* hhsize ///
	consumption_quintile *consumption ///
	che* ///
	survey year healthm* ///
	urban episodic_hosp hhead*
	
append using aux_tidy, force
save aux_tidy, replace

*******************************************************************************
*******************************************************************************
						* 27. Bosnia 2001   *
*******************************************************************************
*******************************************************************************
use bosnia_2001, clear

* OOPs from health module
gen healthm_items = 26
gen healthm_recall = 4
gen healthm_recall2 = ( 4*19+12*7 ) / 26
gen healthm_module = "Health"


* For consistency
gen nonhealth_consumption = total_consumption - health_consumption
gen nonfood_nohealth_consumption = nonfood_consumption - health_consumption
clonevar healthm_oops = health_consumption
drop health_consumption 	
xtile consumption_quintile = nonhealth_consumption , nq(5)

* ID
egen aux = group(hhid)
tostring aux, replace
gen hhid_compilation = survey + aux


keep hhid* hhsize ///
	consumption_quintile *consumption ///
	che* ///
	survey year healthm*	///
	hhead* urban episodic_hosp
	

append using aux_tidy, force
save aux_tidy, replace

*******************************************************************************
*******************************************************************************
						* 28. Bosnia 2004   *
*******************************************************************************
*******************************************************************************
use bosnia_2004, clear

* OOPs from health module
gen healthm_items = 8
gen healthm_recall = 60
gen healthm_recall2 = 60
gen healthm_module = "Health"


* For consistency
gen nonhealth_consumption = total_consumption - health_consumption
gen nonfood_nohealth_consumption = nonfood_consumption - health_consumption
clonevar healthm_oops = health_consumption
drop health_consumption 
xtile consumption_quintile = nonhealth_consumption , nq(5)
	
* ID
egen aux = group(hhid)
tostring aux, replace
gen hhid_compilation = survey + aux



keep hhid* hhsize ///
	consumption_quintile *consumption ///
	che* ///
	survey year healthm* hhead* urban episodic_hosp
	

append using aux_tidy, force
save aux_tidy, replace

*******************************************************************************
*******************************************************************************
						* 29. Bulgaria 2003   *
*******************************************************************************
*******************************************************************************
use bulgaria_2003, clear


* OOPs from consumption module
gen health_items = 2
gen health_recall = 28
gen health_recall2 = 28
gen health_module = "Consumption"

* OOPs from health module
gen healthm_items = 7
gen healthm_recall = 28
gen healthm_recall2 = 28
gen healthm_module = "Health"


* Nonhealth consumption
gen nonhealth_consumption = total_consumption - health_consumption
gen nonfood_nohealth_consumption = nonfood_consumption - health_consumption
xtile consumption_quintile = nonhealth_consumption , nq(5)


* ID
egen aux = group(hhid)
tostring aux, replace
gen hhid_compilation = survey + aux


keep hhid* hhsize epi* urban ///
	consumption_quintile *consumption ///
	che* ///
	hhead* ///
	survey health_items health_recall* health_module year healthm*


append using aux_tidy, force
save aux_tidy, replace

*******************************************************************************
*******************************************************************************
						* 30. Bulgaria 2007   *
*******************************************************************************
*******************************************************************************
use bulgaria_2007, clear

* No total consumption here! ~ I still need to create them.

* OOPs from consumption module
gen health_items = 2
gen health_recall = 13
gen health_recall2 = 13
gen health_module = "Consumption"

* OOPs from health module
gen healthm_items = 7
gen healthm_recall = 13
gen healthm_recall2 = 13
gen healthm_module = "Health"


* Nonhealth consumption
gen nonhealth_consumption = total_consumption - health_consumption
gen nonfood_nohealth_consumption = nonfood_consumption - health_consumption
xtile consumption_quintile = nonhealth_consumption , nq(5)



* ID
egen aux = group(hhid)
tostring aux, replace
gen hhid_compilation = survey + aux


keep hhid* hhsize epi* urban hhweight ///
	consumption_quintile *consumption ///
	hhead* ///
	survey health_items health_recall* health_module year healthm*


append using aux_tidy, force
save aux_tidy, replace


*******************************************************************************
*******************************************************************************
						* 31. Albania 2008   *
*******************************************************************************
*******************************************************************************
* WILL NOT USE FOR NOW, I CANNOT MAKE HEALTH EXPENDITURES MAKE SENSE WITH
* AGGREGATE FILE.

/*
use albania_2008, clear


* OOPs from health module
gen healthm_items = 36
gen healthm_recall = 4
gen healthm_recall2 = (4*26+12*10)/36
gen healthm_module = "Health"



* For consistency
gen nonhealth_consumption = total_consumption - health_consumption
clonevar healthm_oops = health_consumption
drop health_consumption 	
xtile consumption_quintile = nonhealth_consumption , nq(5)



keep hhid* hhsize ///
	consumption_quintile *consumption ///
	che* ///
	survey year healthm*	

	
	
append using aux_tidy, force
save aux_tidy, replace
*/

*******************************************************************************
*******************************************************************************
						* Save Dataset  *
*******************************************************************************
*******************************************************************************
use aux_tidy, clear

keep hhid_compilation year hhead* hhsize *consumption ///
	consumption_quintile survey health* episodic_hosp hhweight urban // took out CHE
	
* Keep only vars with 80% more non-missing
unab hhead_list: hhead*

foreach var of varlist `hhead_list'{
	count if mi(`var')
	if (r(N)/184277) > .8{
		drop `var'
	display("`var' droppped")
	}
	else{
	display("`var' not droppped")
	}
}


save aux_tidy, replace
export delimited aux_tidy, replace





