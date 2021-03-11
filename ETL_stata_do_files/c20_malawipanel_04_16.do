clear all
*******************************************************************************
					*** LSMS Compilation ****
*******************************************************************************
* Program: Malawi
* File Name: c19_malawipanel_04_16
* RA: Benjamin Sas
* PI: Karen Grepin
* Date: 19/06/19
* Version: 1				
*******************************************************************************
* Objective: 	* Obtain consumption
				* FP indicators
				* Health Module
*******************************************************************************

cd "~/Dropbox/LSMS_Compilation/Analysis/Output_Files/"

*******************************************************************************
*******************************************************************************
							* Malawi Panel *
*******************************************************************************
*******************************************************************************

*******************************************************************************
*******************************************************************************
							* I. Data *
*******************************************************************************
*******************************************************************************



*----------------------------------------------------------*
*1.1. Round 1
*----------------------------------------------------------*

use malawi_2004 , clear


*----------------------------------------------------------*
*1.2. Round 2
*----------------------------------------------------------*

use malawi_2010 , clear

rename hh_wgt hhweight
rename hh_a01 dist
rename hh_a26b_2 date_month
rename hh_a26c_2 date_year
rename hhead_fem hhead_female
rename hhead_education hhead_edqul

drop disa* // different format for disability


save aux2 , replace

*----------------------------------------------------------*
*1.3. Round 3
*----------------------------------------------------------*

use malawi_2013 , clear

rename district dist
rename intmonth date_month
rename intyear date_year
rename urban reside
rename hhead_educ hhead_edqul

save aux3 , replace

*----------------------------------------------------------*
*1.3. Round 4
*----------------------------------------------------------*

use malawi_2016 , clear

rename hh_wgt hhweight
rename district dist
rename smonth date_month
rename syear date_year
rename urban reside
rename hhead_educ hhead_edqul

drop birth* // this is for kids of last 5 years.

save aux4 ,replace


*******************************************************************************
*******************************************************************************
							* II. Append Panel *
*******************************************************************************
*******************************************************************************

*----------------------------------------------------------*
*2.1. Append datasets
*----------------------------------------------------------*

use malawi_2004 , clear
	append using aux2
	append using aux3
	append using aux4

* Drop variables not in panel
drop 	idate hhead_edlvl wi* child boys region type ///
		girls adult madult fadult elderly melder felder emp unemp active ultra_poor ///
		disa* qx_type hhead_id visit ea_id status y2_hhid hhweightR1 TA area sdate ///
		hhead_memid hhead_grd hhead_emp hhead_unemp hhead_act hhead_ind_ag hhead_sex hhead_ent ///
		strata reside



encode survey, gen(round)	
sort case_id round 

* Order vars
order case_id round dist ta ea hhweight ///
hhead* *consumption ///
ill* chronic* birth* shock* death*

*----------------------------------------------------------*
*2.2. Panel Observations
*----------------------------------------------------------*

duplicates tag case_id , gen(nobs)
	replace nobs = nobs + 1

recode nobs ///
		(1 = 1 "Cross-sectional") ///
		(2 = 2 "Panel 2 periods") ///
		(3=3 "Panel 3 periods") ///
		, gen(type_observation)

* Order vars
order case_id type_observation round dist ta ea hhweight ///
hhead* *consumption ///
ill* chronic* birth* shock* death*


*----------------------------------------------------------*
*2.3. Check Panel
*----------------------------------------------------------*

*keep if type_observation>=2


*----------------------------------------------------------*
*2.4. Save
*----------------------------------------------------------*

save c20_malawipanel , replace

erase aux2.dta
erase aux3.dta
erase aux4.dta
































