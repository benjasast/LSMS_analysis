*** Income, Consumption, and Assets Comparison***

*Random Data Cleaning
clear all
import excel "D:\Dropbox\McMaster\Data\CH1\data_catalogue.xlsx", sheet("stata") firstrow 
drop in 85
drop in 27
gen filen= path + "\" + file + ".dta"
gen filen2 = substr(filen, 4, .)
levelsof filen if country=="Peru",local(perufiles) clean
foreach f of local perufiles {
	use `f'
	tostring segmento vivienda hogar, gen(hhid1 hhid2 hhid3) format(%03.0f)
	gen hhid=hhid1+ hhid2+ hhid3
	drop hhid1 hhid2 hhid3
	save `f', replace
}
use "D:\Dropbox\McMaster\Data\CH1\ICA_data.dta"
replace unit="hhid" if country=="Peru"
gen svn2 = substr(filen, 22, 8)
save "D:\Dropbox\McMaster\Data\CH1\ICA_data.dta", replace

use D:\Dropbox\LSMS_Anth\TJK_2007_LSMS_v01_M_STATA\r1m13.dta
collapse (sum) m13q3, by(hhid)
drop if m13q3==0
save D:\Dropbox\LSMS_Anth\TJK_2007_LSMS_v01_M_STATA\r1m13.dta, replace

use "D:\Dropbox\McMaster\Data\CH1\ICA_data.dta"
levelsof filen if country=="Cote d'Ivoire",local(CIfiles) clean
foreach f of local CIfiles {

	use `f'
	tostring clust nh, gen(hhid1 hhid2) format(%03.0f)
	gen CIhhid=hhid1+ hhid2
	drop hhid1 hhid2
	save `f', replace
}
use "D:\Dropbox\McMaster\Data\CH1\ICA_data.dta"
replace unit="CIhhid" if country=="Cote d'Ivoire"
save "D:\Dropbox\McMaster\Data\CH1\ICA_data.dta", replace

use D:\Dropbox\LSMS_Anth\UGA_2011_UNPS_v01_M_Stata8\GSEC11.dta
collapse (sum) h11q5, by(HHID)
drop if h11q5==0
save D:\Dropbox\LSMS_Anth\UGA_2011_UNPS_v01_M_Stata8\GSEC11.dta, replace

use "D:\Dropbox\LSMS_Anth\NGA_2010_GHS_v02_M_STATA\NGA_2010_GHSP_v02_M_STATA\sect10_plantingw1.dta" 
egen N_income= rowtotal(s10q2  s10q5  s10q8)
save "D:\Dropbox\LSMS_Anth\NGA_2010_GHS_v02_M_STATA\NGA_2010_GHSP_v02_M_STATA\sect10_plantingw1.dta" , replace

use "D:\Dropbox\LSMS_Anth\NGA_2010_GHS_v02_M_STATA\NGA_2010_GHSP_v02_M_STATA\sect10_plantingw1.dta" 
egen N_income= rowtotal(s10q2  s10q5  s10q8)
save "D:\Dropbox\LSMS_Anth\NGA_2010_GHS_v02_M_STATA\NGA_2010_GHSP_v02_M_STATA\sect10_plantingw1.dta" , replace

use "D:\Dropbox\LSMS_Anth\NGA_2012_GHSP-W2_v03_M_STATA\sect10_plantingw2.dta" 
egen N_income= rowtotal(s10q2 s10q6 s10q10)
save "D:\Dropbox\LSMS_Anth\NGA_2012_GHSP-W2_v03_M_STATA\sect10_plantingw2.dta" , replace

use D:\Dropbox\LSMS_Anth\GUY_1992_LSMS_v01_M_Stata8\HHCHAR.dta, clear
tostring ed_dvsn ed_smpl smpl_hh, gen(hhid1 hhid2 hhid3) format(%03.0f)
gen GYhhid=hhid1+ hhid2+ hhid3
drop hhid1 hhid2 hhid3
save D:\Dropbox\LSMS_Anth\GUY_1992_LSMS_v01_M_Stata8\HHCHAR.dta, replace
use D:\Dropbox\LSMS_Anth\GUY_1992_LSMS_v01_M_Stata8\CONKM03.dta, clear
tostring ed_dvsn ed_smpl smpl_hh, gen(hhid1 hhid2 hhid3) format(%03.0f)
gen GYhhid=hhid1+ hhid2+ hhid3
drop hhid1 hhid2 hhid3
save D:\Dropbox\LSMS_Anth\GUY_1992_LSMS_v01_M_Stata8\CONKM03.dta, replace
use D:\Dropbox\LSMS_Anth\GUY_1992_LSMS_v01_M_Stata8\FERTWNN.dta, clear
gen newid=NEWID
tostring ED SN HH, gen(hhid1 hhid2 hhid3) format(%03.0f)
gen GYhhid=hhid1+ hhid2+ hhid3
save D:\Dropbox\LSMS_Anth\GUY_1992_LSMS_v01_M_Stata8\FERTWNN.dta, replace
use D:\Dropbox\LSMS_Anth\GUY_1992_LSMS_v01_M_Stata8\ANTHRON.dta, clear
gen newid=NEWID
tostring ED SN HH, gen(hhid1 hhid2 hhid3) format(%03.0f)
gen GYhhid=hhid1+ hhid2+ hhid3
save D:\Dropbox\LSMS_Anth\GUY_1992_LSMS_v01_M_Stata8\ANTHRON.dta, replace
use D:\Dropbox\LSMS_Anth\GUY_1992_LSMS_v01_M_Stata8\WEIGHTID.dta, clear
gen newid=NEWID
tostring ED ED_SMPL SMPL_HH, gen(hhid1 hhid2 hhid3) format(%03.0f)
gen GYhhid=hhid1+ hhid2+ hhid3
save D:\Dropbox\LSMS_Anth\GUY_1992_LSMS_v01_M_Stata8\WEIGHTID.dta, replace
use "D:\Dropbox\McMaster\Data\CH1\ICA_data.dta"
replace unit="GYhhid" if country=="Guyana"
use "D:\Dropbox\LSMS_Anth\CIV_1988_EPAM_v01_M_STATA\SEC02B.dta"
duplicates drop CIhhid, force
save "D:\Dropbox\LSMS_Anth\CIV_1988_EPAM_v01_M_STATA\SEC02B.dta", replace
use "D:\Dropbox\LSMS_Anth\CIV_1988_EPAM_v01_M_STATA\SEC08.dta"
duplicates drop CIhhid, force
save "D:\Dropbox\LSMS_Anth\CIV_1988_EPAM_v01_M_STATA\SEC08.dta", replace
*dropping per capita file for Ghana because it also has household expenditure
drop if type=="Consumption" & file=="percapita_expenditure"


save "D:\Dropbox\McMaster\Data\CH1\ICA_data.dta", replace

*Income compilation

clear all
use "D:\Dropbox\McMaster\Data\CH1\ICA_data.dta"

levelsof filen if type== "Income" | type== "Income & Consumption",local(incomefiles) clean
levelsof income_hh if type== "Income" | type== "Income & Consumption",local(keepinc1) clean
levelsof income_pc if type== "Income" | type== "Income & Consumption",local(keepinc2) clean
levelsof unit if type== "Income" | type== "Income & Consumption",local(keepinc3) clean
levelsof hh_size if type== "Income" | type== "Income & Consumption",local(keepinc4) clean
local masterlist "`keepinc1' `keepinc2' `keepinc3' `keepinc4'"
display "`masterlist'"

foreach f of local incomefiles {
	di as text "Now starting with file `f'"
	use "`f'" ,clear 
	gen svn = "`f'"
	gen svn2 = substr(svn, 22, 8)
	levelsof svn2 ,local(svn) clean 
	local keeplist = ""
	foreach i of local masterlist  {
    capture confirm variable `i'
        if !_rc {
            local keeplist "`keeplist' `i'"
        }
}
	keep `keeplist' svn2
	foreach g of local keepinc1  {
    capture confirm variable `g'
        if !_rc {
           rename `g' householdincome
        }
}
	foreach h of local keepinc2  {
    capture confirm variable `h'
        if !_rc {
           rename `h' percapitaincome
        }
}
	foreach j of local keepinc3  {
    capture confirm variable `j'
        if !_rc {
           rename `j' householdid
		   tostring householdid, replace
        }
}

	foreach u of local keepinc4  {
    capture confirm variable `u'
        if !_rc {
           rename `u' householdsize
        }
}
	save D:\Dropbox\McMaster\Data\CH1\Data\temp_`svn', replace
clear all
}


*Compile Income
use "D:\Dropbox\McMaster\Data\CH1\ICA_data.dta"
levelsof svn2 if type== "Income" | type== "Income & Consumption",local(incomefiles2) clean
clear all
set obs 1
generate blank=.
foreach t of local incomefiles2 {
append using D:\Dropbox\McMaster\Data\CH1\Data/temp_`t'.dta
}
replace svn2 = "ALB_2002" if svn2 == "B_2002_L"
drop if _n==1
drop blank
rename householdid hhid
rename percapitaincome pc_inc
rename householdincome hh_inc
rename householdsize hh_size
drop if svn2=="TJK_2007"
replace hh_inc= hh_size*pc_inc if svn2=="GTM_2000"
hist hh_inc if hh_inc>0, by( svn2)
save "D:\Dropbox\McMaster\Data\CH1\ICA_income.dta", replace


use "D:\Dropbox\McMaster\Data\CH1\ICA_income.dta"

*Consumption compilation

clear all
use "D:\Dropbox\McMaster\Data\CH1\ICA_data.dta"

levelsof filen if type== "Consumption" | type== "Consumption & Weights" | type== "Income & Consumption" ,local(consfiles) clean
levelsof hh_con if type== "Consumption" | type== "Consumption & Weights" | type== "Income & Consumption",local(keepcons1) clean
levelsof pc_cons if type== "Consumption" | type== "Consumption & Weights" | type== "Income & Consumption",local(keepcons2) clean
levelsof unit if type== "Consumption" | type== "Consumption & Weights" | type== "Income & Consumption",local(keepcons3) clean
levelsof hh_size if type== "Consumption" | type== "Consumption & Weights" | type== "Income & Consumption",local(keepcons4) clean
local masterlist "`keepcons1' `keepcons2' `keepcons3' `keepcons4'"
display "`masterlist'"

foreach f of local consfiles {
	di as text "Now starting with file `f'"
	use "`f'" ,clear 
	gen svn = "`f'"
	gen svn2 = substr(svn, 22, 8)
	levelsof svn2 ,local(svn) clean 
	local keeplist = ""
	foreach i of local masterlist  {
    capture confirm variable `i'
        if !_rc {
            local keeplist "`keeplist' `i'"
        }
}
	keep `keeplist' svn2
	foreach g of local keepcons1  {
    capture confirm variable `g'
        if !_rc {
           rename `g' householdconsumption
        }
}
 	foreach h of local keepcons2  {
    capture confirm variable `h'
        if !_rc {
           rename `h' percapitaconsumption
        }
}
	foreach j of local keepcons3  {
    capture confirm variable `j'
        if !_rc {
			rename  `j' householdid
		   tostring householdid,   replace force
        }
}

	  foreach u of local keepcons4  {
    capture confirm variable `u'
        if !_rc {
           rename `u' householdsize
        }
}
	save D:\Dropbox\McMaster\Data\CH1\Data\temp_`svn'_cons, replace 
clear all
}

*Tanzania fix

use "D:\Dropbox\LSMS_Anth\TZA_2010_KHDS_v01_M_STATA8\TZA_2010_NPS2_v01_M_SPSS\TZY2.HH.Consumption.dta"
rename y2_hhidc householdid
rename expmR householdconsumption
rename hhsize householdsize
keep householdid householdconsumption householdsize
gen svn2="TZA_2010"
save "D:\Dropbox\McMaster\Data\CH1\Data\temp_TZA_2010_cons.dta", replace


*Compile Consumption

use "D:\Dropbox\McMaster\Data\CH1\ICA_data.dta"
levelsof svn2 if type== "Consumption" | type== "Consumption & Weights" | type== "Income & Consumption"  ,local(consfiles2) clean
clear all
set obs 1
generate blank=.
gen str17 householdid=""

foreach t of local consfiles2 {
append using D:\Dropbox\McMaster\Data\CH1\Data/temp_`t'_cons.dta
}
replace svn2 = "ALB_2002" if svn2 == "B_2002_L"
replace svn2 = "GHA_1988" if svn2 == "GLSS1-19"
drop if _n==1
drop blank
rename householdid hhid
rename percapitaconsumption pc_cons
rename householdconsumption hh_cons
rename householdsize hh_size
replace hh_cons= hh_size*pc_cons if svn2=="GTM_2000" | svn2=="TJK_2007" | svn2=="TLS_2007"
drop if hh_cons==.
hist hh_cons if hh_cons>0, by( svn2)
save "D:\Dropbox\McMaster\Data\CH1\ICA_consumption.dta", replace
use "D:\Dropbox\McMaster\Data\CH1\ICA_consumption.dta"


*Asset compilation

clear all
use "D:\Dropbox\McMaster\Data\CH1\ICA_data.dta"

levelsof filen if type== "Assets" | type== "Assets & hhsize" ,local(assetsfiles) clean
*levelsof file if type== "Assets" | type== "Assets & hhsize" ,local(afile) clean
levelsof asset_index_list if type== "Assets" | type== "Assets & hhsize" ,local(keepassets1) clean
levelsof unit if type== "Assets" | type== "Assets & hhsize" ,local(keepassets2) clean
local masterlist "`keepassets1' `keepassets2'"
display "`masterlist'"

foreach f of local assetsfiles {
	di as text "Now starting with file `f'"
	use "`f'" ,clear 
	gen svn = "`f'"
	gen svn2 = substr(svn, 22, 8)
	levelsof svn2 ,local(svn) clean 
	gen svn3 = substr(svn, -12, 8)
	replace svn3 = subinstr(svn3, "\", "",.) 
	levelsof svn3 ,local(asvn) clean 
	local keeplist = ""
	foreach i of local masterlist  {
    capture confirm variable `i'
        if !_rc {
            local keeplist "`keeplist' `i'"
        }
}
	keep `keeplist' svn2 svn3
	foreach g of local keepassets1  {
    capture confirm variable `g'
        if !_rc {
           rename `g' asset`g'
        }
}
 	foreach h of local keepassets2  {
    capture confirm variable `h'
        if !_rc {
           rename `h' householdid
        }
}


	save D:\Dropbox\McMaster\Data\CH1\Data/temp_`svn'_`asvn'.dta, replace
clear all
}


*Calcultate Asset Indices
clear all
use "D:\Dropbox\McMaster\Data\CH1\Data\temp_BRA_1996_SEC01PB1.dta"
merge 1:1 householdid using "D:\Dropbox\McMaster\Data\CH1\Data\temp_BRA_1996_SEC01PA.dta", keep(match master)
drop _merge assetV01A11 assetV01A12
local factors "assetV01B05 assetV01B06 assetV01B10 assetV01B11 assetV01B15 assetV01B19 assetV01B21 assetV01A01 assetV01A02 assetV01A03 assetV01A04 assetV01A05 assetV01A06 assetV01A07 assetV01A08 assetV01A09 assetV01A10 assetV01A13 assetV01A14 assetV01A15 assetV01A16 assetV01A17"
polychoricpca `factors', score(wealth) nscore(1)
save "D:\Dropbox\McMaster\Data\CH1\Data\temp_BRA_1996_assets.dta"
clear all
use "D:\Dropbox\McMaster\Data\CH1\Data\temp_CIV_1988_TASEC08.dta"
merge 1:1 householdid using "D:\Dropbox\McMaster\Data\CH1\Data\temp_CIV_1988_ASEC02B.dta", keep(match master)
drop _merge assetwateros assettoiletu assettoiletw assetelecm assetelecpm
local factors "assetarea assethowm assetwalls assetfloor assetroof assetwindow assetdwater assetowater assetgarbage assettoilet assetlight assetfuel"
polychoricpca `factors', score(wealth) nscore(1)
save "D:\Dropbox\McMaster\Data\CH1\Data\temp_CIV_1988_assets.dta"
clear all
use "D:\Dropbox\McMaster\Data\CH1\Data\temp_CIV_1987_TATAF08.dta"
merge 1:1 householdid using "D:\Dropbox\McMaster\Data\CH1\Data\temp_CIV_1987_ATAF02B.dta", keep(match master)
drop _merge assetwateros assettoiletu assettoiletw assetelecm assetelecpm
local factors "assetarea assethowm assetwalls assetfloor assetroof assetwindow assetdwater assetowater assetgarbage assettoilet assetlight assetfuel"
polychoricpca `factors', score(wealth) nscore(1)
save "D:\Dropbox\McMaster\Data\CH1\Data\temp_CIV_1987_assets.dta"
clear all
use "D:\Dropbox\McMaster\Data\CH1\Data\temp_GLSS1-19_TATAY08.dta"
merge 1:1 householdid using "D:\Dropbox\McMaster\Data\CH1\Data\temp_GLSS1-19_ATAY02B.dta", keep(match master)
drop _merge
merge 1:1 householdid using "D:\Dropbox\McMaster\Data\CH1\Data\temp_GLSS1-19_ATAHEAD.dta", keep(match master)
drop if _merge==1
drop _merge assetwateros assettoiletu assettoiletw assetelecm assetelecpm 
local factors "assetarea assethowm assetwalls assetfloor assetroof assetwindow assetdwater assetowater assetgarbage assettoilet assetlight assetfuel assetradio assetsewmach assetrefrig assetaircond assettapepl assettelevis assetbicycle  assetautomo"
polychoricpca `factors', score(wealth) nscore(1)
save "D:\Dropbox\McMaster\Data\CH1\Data\temp_GHA_1988_assets.dta" /* Remember that I changed the name from the svn original here*/
clear all
use "D:\Dropbox\McMaster\Data\CH1\Data\temp_GHA_2009_A8S12AI.dta"
merge 1:1 householdid using "D:\Dropbox\McMaster\Data\CH1\Data\temp_GHA_2009_8S12AII.dta", keep(match master)
drop if _merge==1
drop _merge assets12b_20 assets12a_36 assets12b_14
local factors "assets12a_9i assets12a_12ii assets12a_22 assets12a_24 assets12a_25 assets12a_28 assets12a_30 assets12a_31 assets12a_32 assets12a_33i assets12a_33ii assets12a_33iii assets12a_33iv assets12a_33v assets12a_33vi  assets12b_1 assets12b_2 assets12b_3 assets12b_6 assets12b_7 assets12b_8 assets12b_9  assets12b_23 assets12b_24"
polychoricpca `factors', score(wealth) nscore(1)
save "D:\Dropbox\McMaster\Data\CH1\Data\temp_GHA_2009_assets.dta" 
clear all
use "D:\Dropbox\McMaster\Data\CH1\Data\temp_GTM_2000_ECV01H01.dta"
drop  assetp01a13 assetp01a14 assetp01a27 assetarea assetp01a11 assetp01a29c assetp01a29d assetp01a29a assetp01a05f
local factors "assetp01a01 assetp01a02 assetp01a03 assetp01a04 assetp01a05a assetp01a05b assetp01a05c assetp01a05d assetp01a05e  assetp01a06 assetp01a07 assetp01a08 assetp01a09 assetp01a10 assetp01a12 assetp01a25 assetp01a26  assetp01a29b   assetp01a29e assetp01a32 assetp01a34 assetp01a39 "
polychoricpca `factors', score(wealth) nscore(1)
save "D:\Dropbox\McMaster\Data\CH1\Data\temp_GTM_2000_assets.dta"
clear all
use "D:\Dropbox\McMaster\Data\CH1\Data\temp_GUY_1992_8HHCHAR.dta"
local factors "assetbldg1 assetbldg3 assetbldg4 assethous2 assethous3 assethous4 assethous5 assethous6 assethous7 assethous8 assethhld4 assethhld5 assethhld6"
polychoricpca `factors', score(wealth) nscore(1)
save "D:\Dropbox\McMaster\Data\CH1\Data\temp_GUY_1992_assets.dta"
clear all
use "D:\Dropbox\McMaster\Data\CH1\Data\temp_PAN_1997_AEQUIPO.dta"
merge 1:1 householdid using "D:\Dropbox\McMaster\Data\CH1\Data\temp_PAN_1997_VIVIENDA.dta", keep(match master)
drop  _merge assetarea assetv119  assetf120
local factors " assetf102 assetf103 assetf101 assetf104 assetf119 assetf105 assetf106 assetf107 assetf108 assetf109 assetf110 assetf111 assetf112 assetf113 assetf114 assetf115 assetf116 assetf117 assetf118   assetf121 assetf122 assetf123 assetf124 assetv103 assetv104 assetv105 assetv106 assetv107 assetv108 assetv109 assetv110 assetv114  assetv121 assetv122 assetv124 assetv125 assetv129"
polychoricpca `factors', score(wealth) nscore(1)
save "D:\Dropbox\McMaster\Data\CH1\Data\temp_PAN_1997_assets.dta"
clear all
use "D:\Dropbox\McMaster\Data\CH1\Data\temp_PAK_1991_ATAF02C.dta"
merge 1:1 householdid using "D:\Dropbox\McMaster\Data\CH1\Data\temp_PAK_1991_ATAF02A.dta", keep(match master)
drop  if _merge==1
drop _merge
local factors "assetdwater assetdrains assetgarbage assettoilet assettelephon assetrooms assetshrhh assetwalls assetfloor assetroof assetwindow"
polychoricpca `factors', score(wealth) nscore(1)
save "D:\Dropbox\McMaster\Data\CH1\Data\temp_PAK_1991_assets.dta"
clear all
use "D:\Dropbox\McMaster\Data\CH1\Data\temp_NGA_2012_arvestw2.dta"
drop  assets8q37
local factors "assets8q6 assets8q7 assets8q8 assets8q9 assets8q10 assets8q11 assets8q12 assets8q15 assets8q17 assets8q29 assets8q31 assets8q33a assets8q33b assets8q36 assets8q38"
polychoricpca `factors', score(wealth) nscore(1)
save "D:\Dropbox\McMaster\Data\CH1\Data\temp_NGA_2012_assets.dta"
clear all
use "D:\Dropbox\McMaster\Data\CH1\Data\temp_NGA_2010_arvestw1.dta"
drop  assets8q33b assets8q37
local factors "assets8q6 assets8q7 assets8q8 assets8q9 assets8q10 assets8q11 assets8q12 assets8q15 assets8q17 assets8q29 assets8q31 assets8q33a assets8q33c assets8q36 assets8q38"
polychoricpca `factors', score(wealth) nscore(1)
save "D:\Dropbox\McMaster\Data\CH1\Data\temp_NGA_2010_assets.dta"
clear all
use "D:\Dropbox\McMaster\Data\CH1\Data\temp_KGZ_1998_SECT02AB.dta"
drop  asseta0206 asseta0216 asseta0208
local factors "asseta0201 asseta0202 asseta0205 asseta0207  asseta0210 asseta0211 asseta0212 asseta0213 asseta0214 asseta0215  asseta0217 asseta0218 asseta0220 asseta0221 asseta0222 asseta0223 asseta0224 asseta0226"
polychoricpca `factors', score(wealth) nscore(1)
local factorsb "asseta0201 asseta0202 asseta0205 asseta0207  asseta0211 asseta0212 asseta0213 asseta0214 asseta0215  asseta0217 asseta0218 asseta0220 asseta0221 asseta0222 asseta0223 asseta0224 asseta0226"
polychoricpca `factorsb', score(wealthb) nscore(1)
save "D:\Dropbox\McMaster\Data\CH1\Data\temp_KGZ_1998_assets.dta"
clear all
use "D:\Dropbox\McMaster\Data\CH1\Data\temp_KGZ_1997_SEC02AB1.dta"
drop  assetv02a06
local factors "assetv02a01 assetv02a02 assetv02a05 assetv02a06 assetv02a07 assetv02a10 assetv02a11 assetv02a12 assetv02a13 assetv02a14 assetv02a15 assetv02a16 assetv02a17 assetv02a18 assetv02a20 assetv02a21 assetv02a22 assetv02a23 assetv02a24 assetv02a26"
polychoricpca `factors', score(wealth) nscore(1)
local factorsb "assetv02a01  assetv02a05 assetv02a06 assetv02a07 assetv02a10 assetv02a11 assetv02a12 assetv02a13 assetv02a14 assetv02a15 assetv02a16 assetv02a17 assetv02a18 assetv02a20 assetv02a21 assetv02a22 assetv02a23 assetv02a24 assetv02a26"
polychoricpca `factorsb', score(wealthb) nscore(1)
save "D:\Dropbox\McMaster\Data\CH1\Data\temp_KGZ_1997_assets.dta"
clear all
use "D:\Dropbox\McMaster\Data\CH1\Data\temp_UGA_2011_GSEC10A.dta"
merge 1:1 householdid using "D:\Dropbox\McMaster\Data\CH1\Data\temp_UGA_2011_8GSEC9A.dta", keep(match master)
drop _merge
local factors "asseth10q1 asseth10q6 asseth10q9 asseth9q1 asseth9q3 asseth9q4 asseth9q5 asseth9q6 asseth9q7 asseth9q17 asseth9q18 asseth9q19 asseth9q22 asseth9q23"
polychoricpca `factors', score(wealth) nscore(1)
save "D:\Dropbox\McMaster\Data\CH1\Data\temp_UGA_2011_assets.dta"
clear all
use "D:\Dropbox\McMaster\Data\CH1\Data\temp_TZA_2010_H_SEC_J1.dta"
local factors "assethh_j05 assethh_j06 assethh_j07 assethh_j09 assethh_j10 assethh_j14 assethh_j15 assethh_j16 assethh_j17 assethh_j19 assethh_j22 assethh_j25_1"
polychoricpca `factors', score(wealth) nscore(1)
save "D:\Dropbox\McMaster\Data\CH1\Data\temp_TZA_2010_assets.dta"
clear all
use "D:\Dropbox\McMaster\Data\CH1\Data\temp_TLS_2007_TAhhold.dta"
*assetq02b16c
local factors "assetq02a01 assetq02a02 assetq02a03 assetq02a04 assetq02a06 assetq02b01 assetq02b05 assetq02b06 assetq02b08 assetq02b13 assetq02b15 assetq02b16a assetq02b16b  assetq02b16d"
polychoricpca `factors', score(wealth) nscore(1)
save "D:\Dropbox\McMaster\Data\CH1\Data\temp_TLS_2007_assets.dta"
clear all
use "D:\Dropbox\McMaster\Data\CH1\Data\temp_TJK_2007_TAr1m7c.dta"
merge 1:1 householdid using "D:\Dropbox\McMaster\Data\CH1\Data\temp_TJK_2007_TAr1m7b.dta", keep(match master)
drop _merge
merge 1:1 householdid using "D:\Dropbox\McMaster\Data\CH1\Data\temp_TJK_2007_TAr1m7a.dta", keep(match master)
drop _merge assetm7aq9
local factors "assetm7cq1 assetm7cq3 assetm7cq7 assetm7cq230 assetm7cq24 assetm7cq25 assetm7cq27a assetm7bq1 assetm7bq4 assetm7bq13 assetm7bq14 assetm7bq20 assetm7bq24 assetm7bq26 assetm7aq3 assetm7aq4 assetm7aq5 assetm7aq8  assetm7aq11a assetm7aq11b assetm7aq11c assetm7aq11d assetm7aq11e assetm7aq11f assetm7aq11g"
polychoricpca `factors', score(wealth) nscore(1)
save "D:\Dropbox\McMaster\Data\CH1\Data\temp_TJK_2007_assets.dta"
clear all
use "D:\Dropbox\McMaster\Data\CH1\Data\temp_PER_1994_TAREG04.dta"
merge 1:1 householdid using "D:\Dropbox\McMaster\Data\CH1\Data\temp_PER_1994_TAREG03.dta", keep(match master)
drop _merge assetd20
local factors "assetd08 assetd15 assetd16 assetd18  assetc01 assetc02 assetc03 assetc04 assetc05 assetc06"
polychoricpca `factors', score(wealth) nscore(1)
save "D:\Dropbox\McMaster\Data\CH1\Data\temp_PER_1994_assets.dta"
clear all
use "D:\Dropbox\McMaster\Data\CH1\Data\temp_PAN_2003_E03HG01.dta"
local factors "assetv01 assetv02 assetv03 assetv04 assetv17 assetv18 assetv19 assetv24 assetv25 assetv26 assetv29 assetv33 assetv35 assetv38 assetv40a1 assetv40a2 assetv40a3 assetv40a4 assetv40a5"
polychoricpca `factors', score(wealth) nscore(1)
save "D:\Dropbox\McMaster\Data\CH1\Data\temp_PAN_2003_assets.dta"
clear all
use "D:\Dropbox\McMaster\Data\CH1\Data\temp_ZAF_1993_S4_HSV1.dta"
merge 1:1 householdid using "D:\Dropbox\McMaster\Data\CH1\Data\temp_ZAF_1993_S3_HSV3.dta", keep(match master)
drop _merge  
merge 1:1 householdid using "D:\Dropbox\McMaster\Data\CH1\Data\temp_ZAF_1993_S3_HSV2.dta", keep(match master)
drop _merge 
local factors "assethouse_c assetwall1_c assetfloor assetrooms_to assetconnecte assetcook_m assetlight_m assetheatw_m assetheath_m assetwsame assetwsource_  assettoilloc_"
polychoricpca `factors', score(wealth) nscore(1)
local factorsb "assettoilet assethouse_c assetwall1_c assetfloor assetrooms_to  assetcook_m assetlight_m assetheatw_m assetheath_m assetwsame assetwsource_  assettoilloc_"
polychoricpca `factorsb', score(wealthb) nscore(1)
save "D:\Dropbox\McMaster\Data\CH1\Data\temp_ZAF_1993_assets.dta"
*A lot of clumping here
clear all
use "D:\Dropbox\McMaster\Data\CH1\Data\temp_UGA_2013_GSEC10_1.dta"
merge 1:1 householdid using "D:\Dropbox\McMaster\Data\CH1\Data\temp_UGA_2013_GSEC9_1.dta", keep(match master)
drop _merge   asseth10q6
local factors "asseth10q1  asseth10q9 asseth9q1 asseth9q3 asseth9q4 asseth9q5 asseth9q6 asseth9q7 asseth9q17 asseth9q18 asseth9q19 asseth9q22 asseth9q22a asseth9q23"
polychoricpca `factors', score(wealth) nscore(1)
local factorsb "asseth10q1  asseth10q9 asseth9q1 asseth9q3 asseth9q4 asseth9q5 asseth9q6 asseth9q7 asseth9q17 asseth9q18 asseth9q19 asseth9q22"
polychoricpca `factorsb', score(wealthb) nscore(1)
*B probably best
save "D:\Dropbox\McMaster\Data\CH1\Data\temp_UGA_2013_assets.dta"
clear all
use "D:\Dropbox\McMaster\Data\CH1\Data\temp_B_2002_L_lling_cl.dta"
drop assetm3a_q5a assetm3a_q09 assetm3a_q11_3 assetm3a_q11_7 assetm3a_q11_5
local factors "assetm3a_q02 assetm3a_q03 assetm3a_q04 assetm3a_q07 assetm3a_q08 assetm3a_q10 assetm3a_q11_1 assetm3a_q11_2  assetm3a_q11_4  assetm3a_q11_6  assetm3b_q01 assetm3b_q05 assetm3b_q16 assetm3b_q33 assetm3b_q39 assetm3b_q42 assetm3b_q45"
polychoricpca `factors', score(wealth) nscore(1)
save "D:\Dropbox\McMaster\Data\CH1\Data\temp_ALB_2002_assets.dta" /* Remember that I changed the name from the svn original here*/

use "D:\Dropbox\McMaster\Data\CH1\Data\temp_ZAF_1993_assets.dta"
local factorsc "assethouse_c assetwall1_c assetfloor assetrooms_to  assetcook_m assetlight_m assetheatw_m assetheath_m assetwsame assetwsource_ assettoilet assettoilloc_ wsupply wfetch wdist_c"
polychoricpca `factorsc', score(wealthc) nscore(1)
local factorsd "assethouse_c assetwall1_c assetfloor assetrooms_to assetconnecte assetcook_m assetlight_m assetheatw_m assetheath_m assetwsame assetwsource_ assettoilet assettoilloc_ wsupply wfetch wdist_c"
polychoricpca `factorsd', score(wealthd) nscore(1)
save "D:\Dropbox\McMaster\Data\CH1\Data\temp_ZAF_1993_assets.dta", replace

*Compile Asset indices

clear all
use "D:\Dropbox\McMaster\Data\CH1\ICA_data.dta"
gen svn4=svn2
replace svn4= "ALB_2002" if svn2=="B_2002_L"
replace svn4= "GHA_1988" if svn2=="GLSS1-19"
levelsof svn4 if type== "Assets" | type== "Assets & hhsize"  ,local(assetfiles2) clean

foreach t of local assetfiles2 {
use D:\Dropbox\McMaster\Data\CH1\Data\temp_`t'_assets.dta
tostring householdid, replace force
save D:\Dropbox\McMaster\Data\CH1\Data\temp_`t'_assets.dta, replace
}
clear all
set obs 1
generate blank=.
foreach t of local assetfiles2 {
append using D:\Dropbox\McMaster\Data\CH1\Data/temp_`t'_assets.dta
}
drop if _n==1
drop blank
rename householdid hhid
duplicates drop hhid svn2, force
keep  hhid svn2 svn3 wealth1 wealthb1
hist wealth1 , by( svn2)
replace svn2 = "ALB_2002" if svn2 == "B_2002_L"
replace svn2 = "GHA_1988" if svn2 == "GLSS1-19"
save "D:\Dropbox\McMaster\Data\CH1\ICA_assets.dta", replace

*Compile all wealth measures
use "D:\Dropbox\McMaster\Data\CH1\ICA_assets.dta"
save "D:\Dropbox\McMaster\Data\CH1\ICA_wealth.dta", replace
merge 1:1 svn2 hhid using "D:\Dropbox\McMaster\Data\CH1\ICA_consumption.dta"
drop _merge
merge 1:1 svn2 hhid using "D:\Dropbox\McMaster\Data\CH1\ICA_income.dta"
replace wealth1= -wealth1 
replace wealth1= -wealth1 if svn2=="TZA_2010" | svn2=="NGA_2012"
replace wealthb1= -wealthb1 
replace wealthb1= -wealthb1 if svn2=="TZA_2010" | svn2=="NGA_2012"
gen wealth=wealth1
replace wealth= wealthb1 if svn2=="UGA_2013" | svn2=="KGZ_1997" | svn2=="KGZ_1998"
merge 1:1 svn2 hhid using "D:\Dropbox\McMaster\Data\CH1\Data\temp_ZAF_1993_assets.dta", keep(match master) keepusing(wealthd1)
replace wealth= wealthd1 if svn2=="ZAF_1993"
drop _merge
save "D:\Dropbox\McMaster\Data\CH1\ICA_wealth.dta", replace


*Recode Fertility Files



clear all
use "D:\Dropbox\LSMS_Anth\ALB_2002_LSMS_v01_M_STATA8\ALB_2002_LSMS_v01_M_STATA8\hhroster_cl.dta" 
tostring hhid, gen(persid1)
tostring m1_q00, gen(persid2)
gen  persid = persid1 + "_" + persid2
save "D:\Dropbox\LSMS_Anth\ALB_2002_LSMS_v01_M_STATA8\ALB_2002_LSMS_v01_M_STATA8\hhroster_cl.dta" ,replace
use "D:\Dropbox\LSMS_Anth\ALB_2002_LSMS_v01_M_STATA8\ALB_2002_LSMS_v01_M_STATA8\maternity_a.dta"
tostring hhid, gen(persid1)
tostring m6a_q01, gen(persid2)
gen  persid = persid1 + "_" + persid2
gen alive=0 if m6a_q03==1
replace alive=1 if m6a_q11==1 | m6a_q07==1
collapse  (mean) hhid (mean) m6a_q01 (max) m6a_q04 (sum) alive , by(persid)
replace alive=. if m6a_q04==.
merge 1:1 persid using "D:\Dropbox\LSMS_Anth\ALB_2002_LSMS_v01_M_STATA8\ALB_2002_LSMS_v01_M_STATA8\hhroster_cl.dta" 
drop if _merge==2
keep if m1_q05y<50
drop if alive>m6a_q04
save "D:\Dropbox\LSMS_Anth\ALB_2002_LSMS_v01_M_STATA8\ALB_2002_LSMS_v01_M_STATA8\maternity_a.dta", replace

clear all
use "D:\Dropbox\LSMS_Anth\CIV_1988_EPAM_v01_M_STATA\SEC13B.dta"
*sort CIhhid birthyr
*gen persid1 = sum(obirth[_n-1] - 1) + 1
*tostring persid1, gen(persid2)
*gen  persid = CIhhid + "_" + persid2
merge m:1 CIhhid using "D:\Dropbox\LSMS_Anth\CIV_1988_EPAM_v01_M_STATA\SEC13A.dta", keep(match master)
drop if _merge==1
drop _merge
rename wid pid
merge m:1 CIhhid pid using "D:\Dropbox\LSMS_Anth\CIV_1988_EPAM_v01_M_STATA\SEC01A.dta", keep(match master)
drop if sex==1
keep if agey>14
keep if agey<50
gen alive=0 
replace alive=1 if chlaliv==1 
gen births=1
collapse   (sum) births (sum) alive (mean) pid (mean) agey, by(CIhhid)
save "D:\Dropbox\LSMS_Anth\CIV_1988_EPAM_v01_M_STATA\SEC13B.dta", replace

clear all
use "D:\Dropbox\LSMS_Anth\CIV_1987_EPAM_v01_M_STATA\F13B.dta"
merge m:1 CIhhid using "D:\Dropbox\LSMS_Anth\CIV_1987_EPAM_v01_M_STATA\F13A.dta", keep(match master)
drop if _merge==1
drop _merge
rename wid pid
merge m:1 CIhhid pid using "D:\Dropbox\LSMS_Anth\CIV_1987_EPAM_v01_M_STATA\F01A.dta", keep(match master)
drop if sex==1
keep if agey>14
keep if agey<50
gen alive=0 
replace alive=1 if chlaliv==1 
gen births=1
collapse   (sum) births (sum) alive (mean) pid (mean) agey, by(CIhhid)
save "D:\Dropbox\LSMS_Anth\CIV_1987_EPAM_v01_M_STATA\F13B.dta", replace

*Ghana 1988 curated
clear all
use  "D:\Dropbox\LSMS_Anth\GLSS1-1988\GLSS1-1988\Data\STATA\Y13A1B.DTA"
gen alive=0 
replace alive=1 if chlaliv==1 
gen births=1
merge m:1 hid using "D:\Dropbox\LSMS_Anth\GLSS1-1988\GLSS1-1988\Data\STATA\Y13A1A.dta", keep(match master)
drop _merge
rename wid pid
merge m:1 hid pid using "D:\Dropbox\LSMS_Anth\GLSS1-1988\GLSS1-1988\Data\STATA\Y01A.dta", keep(match master)
keep if agey>14
keep if agey<50
collapse (mean) pid (mean) agey (sum) births (sum) alive , by(hid)
save "D:\Dropbox\LSMS_Anth\GLSS1-1988\GLSS1-1988\Data\STATA\Y13A1B.DTA", replace
*Nigeria impossible to assign the right births

clear all
use "D:\Dropbox\LSMS_Anth\NGA_2012_GHSP-W2_v03_M_STATA\sect1_harvestw2.dta" 
collapse (count) indiv , by(hhid s1q24)
drop if s1q24 ==.
rename indiv hhchildren
rename s1q24 indiv
save "D:\Dropbox\LSMS_Anth\NGA_2012_GHSP-W2_v03_M_STATA\hhchildren.dta", replace
use "D:\Dropbox\LSMS_Anth\NGA_2012_GHSP-W2_v03_M_STATA\sect4a_harvestw2.dta" 
merge 1:1 hhid indiv using "D:\Dropbox\LSMS_Anth\NGA_2012_GHSP-W2_v03_M_STATA\hhchildren.dta", keep(match master)
replace hhchildren=0 if s4aq44a!=. 
gen Ndeaths = s4aq45a + s4aq45b
gen Nbirths = hhchildren + s4aq44a + s4aq44b + s4aq45a + s4aq45b
keep if Nbirths>0 & Nbirths!=.
drop _merge
merge 1:1 hhid indiv using "D:\Dropbox\LSMS_Anth\NGA_2012_GHSP-W2_v03_M_STATA\sect1_harvestw2.dta" , keep(match master)
keep if s1q2==2
keep if s1q4>14 & s1q4<50
save "D:\Dropbox\LSMS_Anth\NGA_2012_GHSP-W2_v03_M_STATA\sect4a_harvestw2.dta" , replace


clear all
use "D:\Dropbox\LSMS_Anth\NGA_2010_GHS_v02_M_STATA\NGA_2010_GHSP_v02_M_STATA\sect1_harvestw1.dta"  
gen child=0
replace child=1 if s1q3==3
collapse (count) child , by(hhid)
*drop if s1q29 ==.
rename child hhchildren
*rename s1q29 indiv
save "D:\Dropbox\LSMS_Anth\NGA_2010_GHS_v02_M_STATA\NGA_2010_GHSP_v02_M_STATA\hhchildren.dta", replace
use "D:\Dropbox\LSMS_Anth\NGA_2010_GHS_v02_M_STATA\NGA_2010_GHSP_v02_M_STATA\sect4a_harvestw1.dta"  
merge m:1 hhid  using "D:\Dropbox\LSMS_Anth\NGA_2010_GHS_v02_M_STATA\NGA_2010_GHSP_v02_M_STATA\hhchildren.dta", keep(match master)
*replace hhchildren=0 if s4aq44a!=. 
gen Ndeaths = s4aq45a + s4aq45b
gen Nbirths = hhchildren + s4aq44a + s4aq44b + s4aq45a + s4aq45b
keep if Nbirths>0 & Nbirths!=.
drop _merge
merge 1:1 hhid indiv using "D:\Dropbox\LSMS_Anth\NGA_2010_GHS_v02_M_STATA\NGA_2010_GHSP_v02_M_STATA\sect1_harvestw1.dta" , keep(match master)
keep if s1q2==2
keep if s1q4>14 & s1q4<50
save "D:\Dropbox\LSMS_Anth\NGA_2010_GHS_v02_M_STATA\NGA_2010_GHSP_v02_M_STATA\sect4a_harvestw1.dta"  , replace


use "D:\Dropbox\LSMS_Anth\PAK_1991_LSMS_v01_M_STATA\F13A.DTA" 
gen Pbirths = nslivh + nsliva + ndlivh + ndliva + nsbd + ndbd
gen Pdeaths = nsbd + ndbd
merge 1:1 hid pid using "D:\Dropbox\LSMS_Anth\PAK_1991_LSMS_v01_M_STATA\F01A.DTA" , keep(match master)
keep if sex==2
keep if agey>14 & agey<50
save "D:\Dropbox\LSMS_Anth\PAK_1991_LSMS_v01_M_STATA\F13A.DTA" , replace

use "D:\Dropbox\LSMS_Anth\GHA_2009_GSPS_v01_M_STATA8\GHA_2009_GSPS_v01_M_STATA8\S7A.dta" 
merge 1:1 hhno hhmid using "D:\Dropbox\LSMS_Anth\GHA_2009_GSPS_v01_M_STATA8\GHA_2009_GSPS_v01_M_STATA8\S1D.dta" , keep(match master)
keep if s1d_4i>14
keep if s1d_4i<50
drop if s7a_11<s7a_14
save "D:\Dropbox\LSMS_Anth\GHA_2009_GSPS_v01_M_STATA8\GHA_2009_GSPS_v01_M_STATA8\S7A.dta", replace

use "D:\Dropbox\LSMS_Anth\GTM_2000_ENCOVI_v01_M_STATA\ECV12P11.DTA" 
drop if edad<15
drop if p11a15 < p11a16
save "D:\Dropbox\LSMS_Anth\GTM_2000_ENCOVI_v01_M_STATA\ECV12P11.DTA", replace

use "D:\Dropbox\LSMS_Anth\GUY_1992_LSMS_v01_M_Stata8\FERTWNN.dta" 
merge 1:1 NEWID PID using "D:\Dropbox\LSMS_Anth\GUY_1992_LSMS_v01_M_Stata8\ROSTERN.dta" , keep(match master)
drop if SX==1
drop if AG<15
drop if AG>49
save "D:\Dropbox\LSMS_Anth\GUY_1992_LSMS_v01_M_Stata8\FERTWNN.dta" , replace

use "D:\Dropbox\LSMS_Anth\KGZ_1998_KPMS_v01_M_STATA\SECT_08.DTA" 
egen Kdeaths = rownonmiss( v08c2_1 v08c2_2 v08c2_3 v08c2_4 v08c2_5 v08c2_6 v08c2_7 v08c2_8 v08c2_9)
replace Kdeaths=. if v0806==.
save "D:\Dropbox\LSMS_Anth\KGZ_1998_KPMS_v01_M_STATA\SECT_08.DTA", replace

use "D:\Dropbox\LSMS_Anth\PAN_2003_LSMS_v01_M_STATA\E03PE09.DTA" 
keep if p003==2
keep if p004>14 & p004<50
save "D:\Dropbox\LSMS_Anth\PAN_2003_LSMS_v01_M_STATA\E03PE09.DTA" , replace

use "D:\Dropbox\LSMS_Anth\PAN_1997_LSMS_v01_M_STATA\PERSONA.DTA" 
keep if p202==2
keep if p203>14 & p203<50
save "D:\Dropbox\LSMS_Anth\PAN_1997_LSMS_v01_M_STATA\PERSONA.DTA" , replace

use "D:\Dropbox\LSMS_Anth\UGA_2013_UNPS_v01_M_STATA8\UGA_2013_UNPS_v01_M_STATA8\WSEC4.dta" 
merge 1:1 HHID PID using "D:\Dropbox\LSMS_Anth\UGA_2013_UNPS_v01_M_STATA8\UGA_2013_UNPS_v01_M_STATA8\GSEC2.dta" , keep(match master)
keep if h2q8>14 & h2q8<50
save "D:\Dropbox\LSMS_Anth\UGA_2013_UNPS_v01_M_STATA8\UGA_2013_UNPS_v01_M_STATA8\WSEC4.dta" , replace

use "D:\Dropbox\LSMS_Anth\UGA_2011_UNPS_v01_M_Stata8\WSEC2B_1.dta" 
merge 1:1 HHID PID using "D:\Dropbox\LSMS_Anth\UGA_2013_UNPS_v01_M_STATA8\UGA_2013_UNPS_v01_M_STATA8\GSEC2.dta" , keep(match master)
keep if h2q8>14 & h2q8<50
save "D:\Dropbox\LSMS_Anth\UGA_2011_UNPS_v01_M_Stata8\WSEC2B_1.dta"  , replace


use "D:\Dropbox\LSMS_Anth\ZAF_1993_IHS_v01_M_STATA\M4_HEA2.dta" 
drop if preg_no==0
merge 1:1 hhid pcode using  "D:\Dropbox\LSMS_Anth\ZAF_1993_IHS_v01_M_STATA\M8_HROST.dta" , keep(match master)
drop if gender_c=="M"
keep if age>14 & age<50
drop if no_birth<0
drop if no_alive <0
save "D:\Dropbox\LSMS_Anth\ZAF_1993_IHS_v01_M_STATA\M4_HEA2.dta" , replace


*Compile Fertility

clear all
use "D:\Dropbox\McMaster\Data\CH1\ICA_data.dta"
levelsof filen if type== "Anthropometry & Fertility"  | type== "Fertility"| type== "Fertility, Anthr, and Age" ,local(fertilityf) clean
levelsof age_all if  type== "Anthropometry & Fertility"  | type== "Fertility"| type== "Fertility, Anthr, and Age" ,local(fertility1) clean
levelsof births if  type== "Anthropometry & Fertility"  | type== "Fertility"| type== "Fertility, Anthr, and Age"  ,local(fertility2) clean
levelsof births_male if  type== "Anthropometry & Fertility"  | type== "Fertility"| type== "Fertility, Anthr, and Age" ,local(fertility3) clean
levelsof births_female if  type== "Anthropometry & Fertility"  | type== "Fertility"| type== "Fertility, Anthr, and Age" ,local(fertility4) clean
levelsof deaths if  type== "Anthropometry & Fertility"  | type== "Fertility"| type== "Fertility, Anthr, and Age" ,local(fertility5) clean
levelsof deaths_male if  type== "Anthropometry & Fertility"  | type== "Fertility"| type== "Fertility, Anthr, and Age"  ,local(fertility6) clean
levelsof deaths_female if  type== "Anthropometry & Fertility"  | type== "Fertility"| type== "Fertility, Anthr, and Age"  ,local(fertility7) clean
levelsof alive if  type== "Anthropometry & Fertility"  | type== "Fertility"| type== "Fertility, Anthr, and Age"  ,local(fertility8) clean
levelsof alive_male if  type== "Anthropometry & Fertility"  | type== "Fertility"| type== "Fertility, Anthr, and Age" ,local(fertility9) clean
levelsof alive_female if  type== "Anthropometry & Fertility"  | type== "Fertility"| type== "Fertility, Anthr, and Age" ,local(fertility10) clean
levelsof unit if  type== "Anthropometry & Fertility"  | type== "Fertility"| type== "Fertility, Anthr, and Age" ,local(fertility11) clean
levelsof unit_2 if  type== "Anthropometry & Fertility"  | type== "Fertility"| type== "Fertility, Anthr, and Age" ,local(fertility12) clean
levelsof birth_year if  type== "Anthropometry & Fertility"  | type== "Fertility"| type== "Fertility, Anthr, and Age"  ,local(fertility13) clean
local masterlist "`fertilityf' `fertility1' `fertility2' `fertility3' `fertility4' `fertility5' `fertility6' `fertility7' `fertility8' `fertility9' `fertility10' `fertility11' `fertility12' `fertility13'"
display "`masterlist'"

foreach f of local fertilityf {
	di as text "Now starting with file `f'"
	use "`f'" ,clear 
	gen svn = "`f'"
	gen svn2 = substr(svn, 22, 8)
	levelsof svn2 ,local(svn) clean 
	local keeplist = ""
	foreach i of local masterlist  {
    capture confirm variable `i'
        if !_rc {
            local keeplist "`keeplist' `i'"
        }
}
	keep `keeplist' svn2
	foreach g of local fertility1  {
    capture confirm variable `g'
        if !_rc {
           rename `g' age_all
        }
}
	foreach h of local fertility2  {
    capture confirm variable `h'
        if !_rc {
           rename `h' births
        }
}
	foreach j of local fertility3  {
    capture confirm variable `j'
        if !_rc {
           rename `j' births_male
        }
}

	foreach u of local fertility4  {
    capture confirm variable `u'
        if !_rc {
           rename `u' births_female
        }
}
	foreach g of local fertility5  {
    capture confirm variable `g'
        if !_rc {
           rename `g' deaths
        }
}
	foreach h of local fertility6  {
    capture confirm variable `h'
        if !_rc {
           rename `h' deaths_male
        }
}
	foreach j of local fertility7  {
    capture confirm variable `j'
        if !_rc {
           rename `j' deaths_female
        }
}

	foreach u of local fertility8  {
    capture confirm variable `u'
        if !_rc {
           rename `u' alive
        }
}
	foreach g of local fertility9  {
    capture confirm variable `g'
        if !_rc {
           rename `g' alive_male
        }
}
	foreach h of local fertility10  {
    capture confirm variable `h'
        if !_rc {
           rename `h' alive_female
        }
}
	foreach j of local fertility11  {
    capture confirm variable `j'
        if !_rc {
           rename `j' householdid
		   tostring householdid,   replace force

        }
}

	foreach u of local fertility12  {
    capture confirm variable `u'
        if !_rc {
           rename `u' personid
		   tostring personid,   replace force

        }
}
	foreach u of local fertility13  {
    capture confirm variable `u'
        if !_rc {
           rename `u' birth_year
        }
}
	save D:\Dropbox\McMaster\Data\CH1\Data\temp_`svn'_fert, replace
clear all
}


*Compile Fertility
use "D:\Dropbox\McMaster\Data\CH1\ICA_data.dta"
levelsof svn2 if type== "Anthropometry & Fertility"  | type== "Fertility"| type== "Fertility, Anthr, and Age" ,local(fertilityf2) clean
clear all
set obs 1
generate blank=.
foreach t of local fertilityf2 {
append using D:\Dropbox\McMaster\Data\CH1\Data/temp_`t'_fert.dta
}
replace svn2 = "ALB_2002" if svn2 == "B_2002_L"
replace svn2 = "GHA_1988" if svn2 == "GLSS1-19"
*KGZ 97 is corrupted or miscoded
drop if svn2 == "KGZ_1997"
drop if _n==1
drop blank
rename householdid hhid
save "D:\Dropbox\McMaster\Data\CH1\ICA_fertility.dta", replace

replace births=. if svn2=="NGA_2010" | svn2=="NGA_2012"
replace births_male=. if svn2=="NGA_2010" | svn2=="NGA_2012"
replace births_female=. if svn2=="NGA_2010" | svn2=="NGA_2012"

replace deaths= deaths_male + deaths_female if svn2=="GUY_1992" | svn2=="UGA_2013" 
replace births= births_male + births_female if svn2=="PER_1994"
replace alive= alive_male + alive_female if svn2=="PER_1994"
replace deaths=0 if births!=. & deaths==. & svn2=="UGA_2013" 

gen births_n=births
gen alive_n=alive
gen deaths_n=deaths
replace alive_n= births_n-deaths_n if alive_n==.
replace deaths_n= births_n-alive_n if deaths_n==.
gen alive_pct=alive_n/births_n
gen deaths_pct=deaths_n/births_n
drop if deaths_n==.
drop if births_n>15 & births_n!=.

*Check and analyze fertility
/*
use "D:\Dropbox\LSMS_Anth\BRA_1996_LSMS_v01_M_STATA\SEC02PA.DTA" 
merge 1:1 vident vordem using "D:\Dropbox\LSMS_Anth\BRA_1996_LSMS_v01_M_STATA\SEC07PA.dta", keep(match master)
Brazil OK
Albania OK
CIV 88 and 87 OK
GHA 88 and 09 OK
GTM 00 OK
GUY 92 OK
KGZ 98 OK
NGA 10 and 12 OK
PAK 91 OK
PAN 97 and 03
PER 94 OK
TJK 07 OK
TLS 07 OK
NGA 11 and 13  still look strange, likely undercounting actual births
ZAF 93 OK
*/
hist deaths_pct, by(svn2)
merge m:1 svn2 hhid using "D:\Dropbox\McMaster\Data\CH1\ICA_wealth.dta", keep(match master)
save "D:\Dropbox\McMaster\Data\CH1\ICA_fertility.dta", replace


*Anthropometry cleaning
clear all
use "D:\Dropbox\LSMS_Anth\BRA_1996_LSMS_v01_M_STATA\SEC16.DTA" 
merge 1:1 vident vordem using "D:\Dropbox\LSMS_Anth\BRA_1996_LSMS_v01_M_STATA\SEC02PA.dta", keep(match master)
drop _merge
merge m:1 vident  using "D:\Dropbox\LSMS_Anth\BRA_1996_LSMS_v01_M_STATA\ESTRAT.dta", keep(match master)
keep if V02A08<5
gen Bheight=(V16A03*100)+V16A04
gen Bweight=V16A07+(V16A08/1000)
keep if V16A01==1
tostring V02A07, gen(d1b) format(%02.0f) 
tostring V02A06, gen(d2b) format(%02.0f) 
tostring V02A05, gen(d3b) format(%02.0f) 
tostring ano2, gen(d1a) format(%02.0f) 
tostring mes2, gen(d2a) format(%02.0f) 
tostring dia2, gen(d3a) format(%02.0f) 
gen end_date= date("19" + d1a + d2a+ d3a, "YMD")
gen end_month=mofd(end_date)
format end_month %tm
gen start_date = date("1" + d1b + d2b+ d3b, "YMD")
gen start_month=mofd(start_date)
format start_month %tm
gen age_month=end_month-start_month
drop if age_month>60
save "D:\Dropbox\LSMS_Anth\BRA_1996_LSMS_v01_M_STATA\SEC16.DTA" , replace

use "D:\Dropbox\LSMS_Anth\CIV_1987_EPAM_v01_M_STATA\F16A.dta" 
merge 1:1 CIhhid pid using "D:\Dropbox\LSMS_Anth\CIV_1987_EPAM_v01_M_STATA\F01A.DTA"  , keep(match master)
rename hid CVhhid
replace agem=0 if agem==.
gen age_ch = (12* agey) + agem
drop if age_ch>60
rename agey CVagey
rename agem CVagem
replace wta = wta/1000
replace hta = hta/10
save "D:\Dropbox\LSMS_Anth\CIV_1987_EPAM_v01_M_STATA\F16A.dta" , replace

use "D:\Dropbox\LSMS_Anth\CIV_1988_EPAM_v01_M_STATA\SEC16A.dta" 
duplicates drop CIhhid pid,force
merge 1:1 CIhhid pid using "D:\Dropbox\LSMS_Anth\CIV_1988_EPAM_v01_M_STATA\SEC01A.DTA", keep(match master)
replace agem=0 if agem==.
gen age_ch = (12* agey) + agem
drop if age_ch>60
rename agey CVagey
rename agem CVagem
replace wta = wta/1000
replace hta = hta/10
save "D:\Dropbox\LSMS_Anth\CIV_1988_EPAM_v01_M_STATA\SEC16A.dta" , replace

use "D:\Dropbox\LSMS_Anth\GHA_2009_GSPS_v01_M_STATA8\GHA_2009_GSPS_v01_M_STATA8\S6B.dta" 
duplicates drop hhno hhmid, force
merge 1:1 hhno hhmid using "D:\Dropbox\LSMS_Anth\GHA_2009_GSPS_v01_M_STATA8\GHA_2009_GSPS_v01_M_STATA8\S1D.dta" , keep(match master)
replace s1d_4ii=0 if s1d_4ii==.
gen age_ch = (12* s1d_4i) + s1d_4ii
drop if age_ch>60
save "D:\Dropbox\LSMS_Anth\GHA_2009_GSPS_v01_M_STATA8\GHA_2009_GSPS_v01_M_STATA8\S6B.dta" , replace

use  "D:\Dropbox\LSMS_Anth\GLSS1-1988\GLSS1-1988\Data\STATA\ZSCORE.DTA"  
replace agem=0 if agem==.
gen age_ch = (12* agey) + agem
drop if age_ch>60
replace height= height/10
rename agem GHagem
replace height=height*10
save "D:\Dropbox\LSMS_Anth\GLSS1-1988\GLSS1-1988\Data\STATA\ZSCORE.DTA"   , replace

use "D:\Dropbox\LSMS_Anth\GTM_2000_ENCOVI_v01_M_STATA\ECV40P18.DTA" 
replace p18a05= p18a05*0.453592
tostring p05a01a, gen(d1b) format(%02.0f) 
tostring p05a01b, gen(d2b) format(%02.0f) 
tostring p05a01c, gen(d3b) format(%02.0f) 
tostring p18a07c, gen(d1a) format(%02.0f) 
tostring p18a07b, gen(d2a) format(%02.0f) 
tostring p18a07a, gen(d3a) format(%02.0f) 
gen end_date= date("20" + d1a + d2a+ d3a, "YMD")
gen end_month=mofd(end_date)
format end_month %tm
gen start_date = date("19" + d3b +d2b + d1b  , "YMD")
replace start_date = date("20" + d3b +d2b + d1b  , "YMD") if d3b=="00"
gen start_month=mofd(start_date)
format start_month %tm
gen age_ch=end_month-start_month
drop if age_ch > 60 | age_ch <0
save "D:\Dropbox\LSMS_Anth\GTM_2000_ENCOVI_v01_M_STATA\ECV40P18.DTA" , replace

use "D:\Dropbox\LSMS_Anth\GUY_1992_LSMS_v01_M_Stata8\ANTHRON.dta" 
gen age_ch=(AYR*12)+AMNTH
drop if age_ch > 60 | age_ch <0
merge 1:1 NEWID PID using "D:\Dropbox\LSMS_Anth\GUY_1992_LSMS_v01_M_Stata8\ROSTERN.dta"  , keep(match master)
save "D:\Dropbox\LSMS_Anth\GUY_1992_LSMS_v01_M_Stata8\ANTHRON.dta" , replace

use "D:\Dropbox\LSMS_Anth\KGZ_1998_KPMS_v01_M_STATA\ANTHFL98.DTA" 
gen a0101 = a1501
gen a01cod = a15cod
duplicates drop fprimary a01cod, force
merge 1:1 fprimary a01cod a0101 using "D:\Dropbox\LSMS_Anth\KGZ_1998_KPMS_v01_M_STATA\SECT_01A.DTA"  , keep(match master)
replace a0105b=0 if a0105b==.
gen age_ch=(a0105a*12)+a0105b
drop if age_ch > 60 | age_ch <0
replace a1502b = 0 if a1502b==.
replace a1503b = 0 if a1503b==.
gen Kheight = a1502a + (a1502b/10)
gen Kweight = a1503a + (a1503b/1000)
rename a1502a Ka1502a
rename a1503a Ka1503a
save "D:\Dropbox\LSMS_Anth\KGZ_1998_KPMS_v01_M_STATA\ANTHFL98.DTA" , replace

use "D:\Dropbox\LSMS_Anth\KGZ_1997_KPMS_v01_M_STATA\ANTHFL97.DTA" 
gen name = v1501
merge 1:1 fprimary pid name using "D:\Dropbox\LSMS_Anth\KGZ_1997_KPMS_v01_M_STATA\SECT00B.DTA"  , keep(match master)
*merge 1:1 fprimary member name using "D:\Dropbox\LSMS_Anth\KGZ_1997_KPMS_v01_M_STATA\SECT00B.DTA"  , keep(match master)
replace age_m=0 if age_m==.
gen age_ch=(age_y*12)+age_m
drop if age_ch > 60 | age_ch <0
rename age_y Kage_y
rename age_m Kage_m
replace v1502b = 0 if v1502b==.
replace v1503b = 0 if v1503b==.
gen Kheight = v1502a + (v1502b/10)
gen Kweight = v1503a + (v1503b/1000)
rename v1502a Kv1502a
rename v1503a Kv1503a
save "D:\Dropbox\LSMS_Anth\KGZ_1997_KPMS_v01_M_STATA\ANTHFL97.DTA", replace

use "D:\Dropbox\LSMS_Anth\NGA_2012_GHSP-W2_v03_M_STATA\sect4a_harvestw2 - Copy.dta" 
merge 1:1 hhid indiv using "D:\Dropbox\LSMS_Anth\NGA_2012_GHSP-W2_v03_M_STATA\sect1_harvestw2.dta" , keep(match master)
tostring s1q6_year, gen(d1a) format(%04.0f) 
tostring s1q6_month, gen(d2a) format(%02.0f) 
tostring s1q6_day, gen(d3a) format(%02.0f) 
gen end_date= date("20130301", "YMD")
gen end_month=mofd(end_date)
format end_month %tm
gen start_date = date( d1a +d2a + d3a  , "YMD")
gen start_month=mofd(start_date)
format start_month %tm
gen age_ch=end_month-start_month
drop if age_ch > 60 | age_ch <0
drop if s4aq51!=1
save "D:\Dropbox\LSMS_Anth\NGA_2012_GHSP-W2_v03_M_STATA\anthroN.dta" , replace

use "D:\Dropbox\LSMS_Anth\NGA_2010_GHS_v02_M_STATA\NGA_2010_GHSP_v02_M_STATA\sect4a_harvestw1 - Copy.dta" 
merge 1:1 hhid indiv using  "D:\Dropbox\LSMS_Anth\NGA_2010_GHS_v02_M_STATA\NGA_2010_GHSP_v02_M_STATA\sect1_plantingw1.dta"  , keep(match master)
drop _merge
merge 1:1 hhid indiv using  "D:\Dropbox\LSMS_Anth\NGA_2010_GHS_v02_M_STATA\NGA_2010_GHSP_v02_M_STATA\sect1_harvestw1.dta"  , keep(match master)
tostring s1q6_year , gen(d1b) format(%04.0f) 
tostring s1q6_month , gen(d2b) format(%02.0f) 
tostring s1q6_day , gen(d3b) format(%02.0f) 
tostring s1q5_year , gen(d1a) format(%04.0f) 
tostring s1q5_month , gen(d2a) format(%02.0f) 
tostring s1q5_day , gen(d3a) format(%02.0f) 
replace d1b="" if s1q6_year==9999
replace d2b="" if s1q6_month==99
replace d3b="" if s1q6_day==99
replace d1a="" if s1q5_year==9999
replace d2a="" if s1q5_month==99
replace d3a="" if s1q5_day==99
gen end_date= date("20110301", "YMD")
gen end_month=mofd(end_date)
format end_month %tm
gen start_date = date( d1a +d2a + d3a  , "YMD")
replace start_date = date( d1b +d2b + d3b  , "YMD") if start_date==.
gen start_month=mofd(start_date)
format start_month %tm
gen age_ch=end_month-start_month
drop if age_ch > 60 | age_ch <0
drop if s4aq51!=1
save "D:\Dropbox\LSMS_Anth\NGA_2010_GHS_v02_M_STATA\NGA_2010_GHSP_v02_M_STATA\anthroNa.dta" , replace

use "D:\Dropbox\LSMS_Anth\PAK_1991_LSMS_v01_M_STATA\F14.DTA" 
gen age_ch=(agey*12)+agem
rename agey Pagey
rename agem Pagem
drop if age_ch > 60
merge 1:1 hid pid using "D:\Dropbox\LSMS_Anth\PAK_1991_LSMS_v01_M_STATA\F01A.DTA"  , keep(match master)
save "D:\Dropbox\LSMS_Anth\PAK_1991_LSMS_v01_M_STATA\F14.DTA" , replace

use "D:\Dropbox\LSMS_Anth\PAN_1997_LSMS_v01_M_STATA\ANTROP.DTA" 
gen age_ch=(a03a*12)+a03b
rename area Parea
rename nhogar Pnhogar
rename hogar Phogar
save "D:\Dropbox\LSMS_Anth\PAN_1997_LSMS_v01_M_STATA\ANTROP.DTA" , replace

use "D:\Dropbox\LSMS_Anth\PAN_2003_LSMS_v01_M_STATA\E03PE13.DTA" 
drop if edadmes>60
save "D:\Dropbox\LSMS_Anth\PAN_2003_LSMS_v01_M_STATA\E03PE13.DTA" , replace

use "D:\Dropbox\LSMS_Anth\PER_1994_LSMS_v01_M_STATA\REG10.dta" 
gen age_ch=(j02a*12)+j02b
gen b00 = j00
merge 1:1 segmento vivienda hogar b00 using "D:\Dropbox\LSMS_Anth\PER_1994_LSMS_v01_M_STATA\REG02.DTA"   , keep(match master)
rename segmento Psegmento
rename vivienda Pvivienda
rename hogar Phogar
save "D:\Dropbox\LSMS_Anth\PER_1994_LSMS_v01_M_STATA\REG10.dta" , replace

use "D:\Dropbox\LSMS_Anth\TJK_2007_LSMS_v01_M_STATA\r2m15.dta" 
replace memid = 7 in 54
replace memid = 3 in 286
replace memid = 8 in 328
replace memid = 6 in 979
replace memid = 8 in 1093
drop in 1394
replace memid = 5 in 2983
merge 1:1 hhid memid using  "D:\Dropbox\LSMS_Anth\TJK_2007_LSMS_v01_M_STATA\r1m1.dta"   , keep(match master)
drop _merge
merge m:1 hhid using  "D:\Dropbox\LSMS_Anth\TJK_2007_LSMS_v01_M_STATA\r1m0.dta"   , keep(match master)
tostring m15q5y, gen(d1b) format(%04.0f) 
tostring m15q5m, gen(d2b) format(%02.0f) 
tostring m15q5d, gen(d3b) format(%02.0f) 
tostring m1q4_3, gen(d1a) format(%04.0f) 
tostring m1q4_2, gen(d2a) format(%02.0f) 
tostring m1q4_1, gen(d3a) format(%02.0f) 
gen end_date= date(d1b + d2b + d3b, "YMD")
gen end_month=mofd(end_date)
format end_month %tm
gen start_date = date( d1a +d2a + d3a  , "YMD")
gen start_month=mofd(start_date)
format start_month %tm
gen age_ch=end_month-start_month
drop if age_ch > 60 | age_ch <0
save "D:\Dropbox\LSMS_Anth\TJK_2007_LSMS_v01_M_STATA\r2m15.dta" , replace

use "D:\Dropbox\LSMS_Anth\TLS_2007_LSMS_v01_M_STATA\indiv.dta" 
gen age_ch=(q01a05y*12)+q01a05m
drop if age_ch > 60 | age_ch <0
save "D:\Dropbox\LSMS_Anth\TLS_2007_LSMS_v01_M_STATA\indiv.dta" , replace

use "D:\Dropbox\LSMS_Anth\TZA_2010_KHDS_v01_M_STATA8\TZA_2010_NPS2_v01_M_SPSS\HH_SEC_U.dta" 
merge 1:1 y2_hhid indidy2 using  "D:\Dropbox\LSMS_Anth\TZA_2010_KHDS_v01_M_STATA8\TZA_2010_NPS2_v01_M_SPSS\HH_SEC_B.dta"  , keep(match master)
drop _merge
merge m:1 y2_hhid  using  "D:\Dropbox\LSMS_Anth\TZA_2010_KHDS_v01_M_STATA8\TZA_2010_NPS2_v01_M_SPSS\HH_SEC_A.dta" , keep(match master)
tostring hh_a18_year, gen(d1b) format(%04.0f) 
tostring hh_a18_month, gen(d2b) format(%02.0f) 
tostring hh_b03_1, gen(d1a) format(%04.0f) 
tostring hh_b03_2, gen(d2a) format(%02.0f) 
gen end_date= date(d1b + d2b + "01", "YMD")
gen end_month=mofd(end_date)
format end_month %tm
gen start_date = date( d1a +d2a + "01"  , "YMD")
gen start_month=mofd(start_date)
format start_month %tm
gen age_ch=end_month-start_month
drop if age_ch > 60 | age_ch <0
rename hhid_2008 Khhid_2008
save "D:\Dropbox\LSMS_Anth\TZA_2010_KHDS_v01_M_STATA8\TZA_2010_NPS2_v01_M_SPSS\HH_SEC_U.dta" , replace

use "D:\Dropbox\LSMS_Anth\UGA_2013_UNPS_v01_M_STATA8\UGA_2013_UNPS_v01_M_STATA8\GSEC6_1.dta" 
merge 1:1 HHID PID using  "D:\Dropbox\LSMS_Anth\UGA_2013_UNPS_v01_M_STATA8\UGA_2013_UNPS_v01_M_STATA8\GSEC2.dta", keep(match master)
gen Uheight = h6q28a
replace Uheight = h6q28b if Uheight==.
save "D:\Dropbox\LSMS_Anth\UGA_2013_UNPS_v01_M_STATA8\UGA_2013_UNPS_v01_M_STATA8\GSEC6_1.dta", replace
 
use "D:\Dropbox\LSMS_Anth\UGA_2011_UNPS_v01_M_Stata8\GSEC6A.dta" 
merge 1:1 HHID PID using "D:\Dropbox\LSMS_Anth\UGA_2011_UNPS_v01_M_Stata8\GSEC2.dta", keep(match master)
gen Uheight = h6q28a
replace Uheight = h6q28b if Uheight==.
save "D:\Dropbox\LSMS_Anth\UGA_2011_UNPS_v01_M_Stata8\GSEC6A.dta" , replace
 
use "D:\Dropbox\LSMS_Anth\ZAF_1993_IHS_v01_M_STATA\M6_ANTH.dta" 
drop if agem > 60
replace height=. if height<0
replace weight=. if weight<0
gen sex=1
replace sex=2 if gender=="F"
save "D:\Dropbox\LSMS_Anth\ZAF_1993_IHS_v01_M_STATA\M6_ANTH.dta" , replace

use "D:\Dropbox\LSMS_Anth\ALB_2002_LSMS_v01_M_STATA8\ALB_2002_LSMS_v01_M_STATA8\anthro1_cld.dta" 
gen Aweight = mf_q10a + (mf_q10b/1000)
merge 1:1 psu hh mf_q00 using  "D:\Dropbox\LSMS_Anth\ALB_2002_LSMS_v01_M_STATA8\ALB_2002_LSMS_v01_M_STATA8\hhroster_cl.dta" , keep(match master)
save "D:\Dropbox\LSMS_Anth\ALB_2002_LSMS_v01_M_STATA8\ALB_2002_LSMS_v01_M_STATA8\anthro1_cld.dta" , replace


*Compile Anthropometry
clear all
use "D:\Dropbox\McMaster\Data\CH1\ICA_data.dta"
levelsof filen if type== "Anthropometry & Fertility"  | type== "Anthropometry"| type== "Fertility, Anthr, and Age" ,local(anthrof) clean
levelsof age_all if type== "Anthropometry & Fertility"  | type== "Anthropometry"| type== "Fertility, Anthr, and Age" ,local(anthro1) clean
levelsof age_children if type== "Anthropometry & Fertility"  | type== "Anthropometry"| type== "Fertility, Anthr, and Age"  ,local(anthro2) clean
levelsof haz if type== "Anthropometry & Fertility"  | type== "Anthropometry"| type== "Fertility, Anthr, and Age"  ,local(anthro3) clean
levelsof waz if type== "Anthropometry & Fertility"  | type== "Anthropometry"| type== "Fertility, Anthr, and Age" ,local(anthro4) clean
levelsof whz if type== "Anthropometry & Fertility"  | type== "Anthropometry"| type== "Fertility, Anthr, and Age"  ,local(anthro5) clean
levelsof height if type== "Anthropometry & Fertility"  | type== "Anthropometry"| type== "Fertility, Anthr, and Age"  ,local(anthro6) clean
levelsof weight if type== "Anthropometry & Fertility"  | type== "Anthropometry"| type== "Fertility, Anthr, and Age"  ,local(anthro7) clean
levelsof unit if type== "Anthropometry & Fertility"  | type== "Anthropometry"| type== "Fertility, Anthr, and Age"  ,local(anthro8) clean
levelsof unit_2 if type== "Anthropometry & Fertility"  | type== "Anthropometry"| type== "Fertility, Anthr, and Age" ,local(anthro9) clean
levelsof sex if type== "Anthropometry & Fertility"  | type== "Anthropometry"| type== "Fertility, Anthr, and Age"  ,local(anthro10) clean
local masterlist "`anthrof' `anthro1' `anthro2' `anthro3' `anthro4' `anthro5' `anthro6' `anthro7' `anthro8' `anthro9' `anthro10'"
display "`masterlist'"

foreach f of local anthrof {
	di as text "Now starting with file `f'"
	use "`f'" ,clear 
	gen svn = "`f'"
	gen svn2 = substr(svn, 22, 8)
	levelsof svn2 ,local(svn) clean 
	local keeplist = ""
	foreach i of local masterlist  {
    capture confirm variable `i'
        if !_rc {
            local keeplist "`keeplist' `i'"
        }
}
	keep `keeplist' svn2
	foreach g of local anthro1  {
    capture confirm variable `g'
        if !_rc {
           rename `g' age_all
        }
}
	foreach h of local anthro2  {
    capture confirm variable `h'
        if !_rc {
           rename `h' age_ch
        }
}
	foreach j of local anthro3  {
    capture confirm variable `j'
        if !_rc {
           rename `j' o_haz
        }
}

	foreach u of local anthro4  {
    capture confirm variable `u'
        if !_rc {
           rename `u' o_waz
        }
}
	foreach g of local anthro5  {
    capture confirm variable `g'
        if !_rc {
           rename `g' o_whz
        }
}
	foreach h of local anthro6  {
    capture confirm variable `h'
        if !_rc {
           rename `h' o_height
        }
}
	foreach j of local anthro7  {
    capture confirm variable `j'
        if !_rc {
           rename `j' o_weight
        }
}

	foreach j of local anthro8  {
    capture confirm variable `j'
        if !_rc {
           rename `j' householdid
		   tostring householdid,   replace force

        }
}

	foreach u of local anthro9  {
    capture confirm variable `u'
        if !_rc {
           rename `u' personid
		   tostring personid,   replace force

        }
}
	foreach u of local anthro10  {
    capture confirm variable `u'
        if !_rc {
           rename `u' c_sex

        }
}

	save D:\Dropbox\McMaster\Data\CH1\Data\temp_`svn'_anthr, replace
clear all
}


*Compile Anthropometry
clear all
use "D:\Dropbox\McMaster\Data\CH1\ICA_data.dta"
levelsof svn2 if type== "Anthropometry & Fertility"  | type== "Anthropometry"| type== "Fertility, Anthr, and Age" ,local(anthf2) clean
clear all
set obs 1
generate blank=.
foreach t of local anthf2 {
append using D:\Dropbox\McMaster\Data\CH1\Data/temp_`t'_anthr.dta
}
replace svn2 = "ALB_2002" if svn2 == "B_2002_L"
replace svn2 = "GHA_1988" if svn2 == "GLSS1-19"
drop if _n==1
drop blank
rename householdid hhid
save "D:\Dropbox\McMaster\Data\CH1\ICA_anthro.dta", replace
drop if age_all>5 & age_all!=.
drop if age_ch>60
zscore06 , a(age_ch) s(c_sex) h(o_height) w(o_weight)

replace haz06=. if haz06>9.999 | haz06<-9.999
replace waz06=. if waz06>9.999 | waz06<-9.999
replace whz06=. if whz06>9.999 | whz06<-9.999


gen stunting = 0 
replace stunting = 1 if haz06<-2
gen underweight  = 0 
replace underweight = 1 if waz06<-2
gen wasting  = 0 
replace wasting = 1 if whz06<-2

gen tstunting = 0 
replace tstunting = 1 if o_haz<-2
gen tunderweight  = 0 
replace tunderweight = 1 if o_waz<-2
gen twasting  = 0 
replace twasting = 1 if o_whz<-2

table svn2, contents(mean stunting mean underweight mean wasting )

hist haz06  if haz06!=99, by(svn2)
merge m:1 svn2 hhid using "D:\Dropbox\McMaster\Data\CH1\ICA_wealth.dta", keep(match master)
save "D:\Dropbox\McMaster\Data\CH1\ICA_anthro.dta", replace

table wquin, contents(count year mean c_sex mean age_ch mean stunting mean underweight ) by(svn2)

*Wealth analysis
use "D:\Dropbox\McMaster\Data\CH1\ICA_wealth.dta"

gen wquin=.
levelsof svn2 ,local(svn2) clean
foreach q of local svn2 {
	xtile wquin`q' = wealth if svn2=="`q'", n(5)
	replace wquin=wquin`q' if svn2=="`q'"
	drop wquin`q'
}
gen wcent=.
levelsof svn2 ,local(svn2) clean
foreach q of local svn2 {
	xtile wcent`q' = wealth if svn2=="`q'", n(100)
	replace wcent=wcent`q' if svn2=="`q'"
	drop wcent`q'
}

gen ccent=.
local svn2 = "ALB_2002 CIV_1987 CIV_1988 GHA_1988 GHA_2009 GTM_2000 GUY_1992 KGZ_1997 KGZ_1998 NGA_2010 NGA_2012 PAK_1991 PAN_1997 PAN_2003 PER_1994 TJK_2007 TLS_2007 TZA_2010 UGA_2011 UGA_2013 ZAF_1993"
foreach q of local svn2 {
	xtile ccent`q' = hh_cons if svn2=="`q'", n(100)
	replace ccent=ccent`q' if svn2=="`q'"
	drop ccent`q'
}


gen icent=.
local svn2 = "ALB_2002 BRA_1996 CIV_1987 CIV_1988 GTM_2000 GUY_1992 KGZ_1997 KGZ_1998 NGA_2010 NGA_2012 PAK_1991 PAN_2003 PER_1994 UGA_2011 UGA_2013 ZAF_1993"
foreach q of local svn2 {
	xtile icent`q' = hh_inc if svn2=="`q'", n(100)
	replace icent=icent`q' if svn2=="`q'"
	drop icent`q'
}


gen year = substr(svn2,-4,.)
destring year, replace
gen countrya = substr(svn2,1,3)
kountry countrya , from(iso3c) marker
drop MARKER
rename NAMES_STD country
replace country="East Timor" if country=="Timor"
replace country="Kyrgyzstan" if country=="Kyrgyz Republic"
replace year = 1990 if country=="Ghana" | country=="Cote d'Ivoire"
gen percentile = wcent
****NOTE: Ghana and Cote d'Ivoire are using approximate years (1987 and 1988 as 1990)
merge m:1 country year percentile using "D:\Dropbox\McMaster\Data\Percentile_incomes_19dec2016\Percentile_incomes_19dec2016.dta", keep(match master)
drop _merge
rename hh_income_estimate hybrid

bysort svn2: spearman wealth  hh_cons pc_cons hh_inc pc_inc, pw
bysort svn2: pwcorr wealth  hh_cons pc_cons hh_inc pc_inc


twoway (lpoly hh_cons wcent if svn2=="ZAF_1993") (lpoly hh_cons wcent if svn2=="UGA_2013")
(scatter ccent wcent) 
twoway  (lpoly ccent wcent), by(svn2)
twoway lpoly icent wcent , by(svn2)
twoway (lpoly ccent icent), by(svn2)
twoway (scatter icent ccent ), by(svn2, note("")) ytitle("Income Centile") xtitle("Consumption Centile")
twoway (lpoly icent ccent ), by(svn2, note("")) ytitle("Income Centile") xtitle("Consumption Centile")

merge 1:1 hhid svn2 using "D:\Dropbox\McMaster\Data\CH1\Data\temp_TJK_2007_assets.dta", keep(match master) keepusing(altw)


save "D:\Dropbox\McMaster\Data\CH1\ICA_wealth.dta", replace
use "D:\Dropbox\McMaster\Data\CH1\ICA_wealth.dta"
save "D:\Dropbox\McMaster\Data\CH1\ICA_wealth2.dta", replace
replace hh_inc = . if svn2=="NGA_2012" & hh_inc==0
replace hh_inc =. if hh_inc<0

use "D:\Dropbox\McMaster\Data\CH1\ICA_wealth2.dta"

gen wcent2=.
levelsof svn2 ,local(svn2) clean
foreach q of local svn2 {
	xtile wcent2`q' = wealth if svn2=="`q'", n(100)
	replace wcent2=wcent2`q' if svn2=="`q'"
	drop wcent2`q'
}

gen ccent2=.
local svn2 = "ALB_2002 CIV_1987 CIV_1988 GHA_1988 GHA_2009 GTM_2000 GUY_1992 KGZ_1997 KGZ_1998 NGA_2010 NGA_2012 PAK_1991 PAN_1997 PAN_2003 PER_1994 TJK_2007 TLS_2007 TZA_2010 UGA_2011 UGA_2013 ZAF_1993"
foreach q of local svn2 {
	xtile ccent2`q' = hh_cons if svn2=="`q'", n(100)
	replace ccent2=ccent2`q' if svn2=="`q'"
	drop ccent2`q'
}


gen icent2=.
local svn2 = "ALB_2002 BRA_1996 CIV_1987 CIV_1988 GTM_2000 GUY_1992 KGZ_1997 KGZ_1998 NGA_2010 NGA_2012 PAK_1991 PAN_2003 PER_1994 UGA_2011 UGA_2013 ZAF_1993"
foreach q of local svn2 {
	xtile icent2`q' = hh_inc if svn2=="`q'", n(100)
	replace icent2=icent2`q' if svn2=="`q'"
	drop icent2`q'
}

twoway (lpolyci icent2 ccent2 , legend(off)), by(svn2, legend(off) note("")) ytitle("Income Centile") xtitle("Consumption Centile") legend(off)
twoway (lpolyci icent2 wcent2 ), by(svn2, legend(off) note("")) ytitle("Income Centile") xtitle("Asset Index Centile")
twoway (lpolyci ccent2 wcent2 ), by(svn2, legend(off) note("")) ytitle("Consumption Centile") xtitle("Asset Index Centile")

twoway (scatter icent2 ccent2 ), by(svn2, note("")) ytitle("Income Centile") xtitle("Consumption Centile")

twoway (qqplot hh_inc hh_cons  if svn2=="CIV_1987")

bysort svn2: spearman   hh_cons  hh_inc 
bysort svn2: spearman wealth  hh_cons  hh_inc 
bysort svn2: spearman wealth  hh_cons  hh_inc 

*Nigeria fix
gen hh_inc2=hh_inc
replace hh_inc2 = . if svn2=="NGA_2012" & hh_inc2==0
replace hh_inc2 =. if hh_inc2<0


