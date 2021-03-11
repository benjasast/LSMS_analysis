*******************************************************************************
					*** LSMS Compilation ****
*******************************************************************************
* Program: 
* File Name: p00_run_allcountryfiles
* RA: Benjamin Sas
* PI: Karen Grepin
* Date: 07/06/20
* Version: 1				
*******************************************************************************
* Objective: 	* Obtain consumption
				* FP indicators
				* episodic health.
				* Asset list	
*******************************************************************************

clear all
* Dir
cd "~/Dropbox/LSMS_Compilation/Analysis/Do-Files/"

* Get list with all country files

#delimit ;
local myfilelist1
 c01_ethiopia2015 
 c02_uganda2005 c03_uganda2009 c04_uganda2010 ///
 c05_uganda2011 c05_uganda2013 ///
 c06_nigeria2010 c07_nigeria2012 ///
 c07nigeria2015 ///
 c08_ghana1988 c09_ghana1989 c10_ghana1991v2 c11_ghana2005 c12_ghana2013 ///
 c13_ghana2017 ///
 c14_iraq2006 c15_iraq2012 ///
 c16_malawi2004 c17_malawi2010 c18_malawi2013 c19_malawi2016 ///
 c21_tanzaniaNPS_08 c22_tanzaniaNPS_10 c23_tanzaniaNPS_12 c24_tanzaniaNPS_14 ///
 ///
 c26_albania2002 c27_albania2005 c28_albania2008 ///
 c29_bosnia2001 c30_bosnia2004 ///
 c31_bulgaria2003 c32_bulgaria2007 
  ;
#delimit cr

 
* Run each file
foreach file in `myfilelist1'{
	do `file'
	cd "~/Dropbox/LSMS_Compilation/Analysis/Do-Files/"
}
