clear all
*******************************************************************************
					*** LSMS Compilation ****
*******************************************************************************
* Program: Malawi
* File Name: c25_tazaniaNPS_panel08_14
* RA: Benjamin Sas
* PI: Karen Grepin
* Date: 02/07/19
* Version: 1				
*******************************************************************************
* Objective: 	* Obtain consumption
				* FP indicators
				* Health Module
*******************************************************************************

cd "~/Dropbox/LSMS_Compilation/Analysis/Output_Files/"

*******************************************************************************
*******************************************************************************
							* Tanzania NPS Panel *
*******************************************************************************
*******************************************************************************


*----------------------------------------------------------*
*1.1. Append Datasets
*----------------------------------------------------------*

use tanzaniaNPS_2008, clear
	append using tanzaniaNPS_2010
	append using tanzaniaNPS_2012
	append using tanzaniaNPS_2014

order hhid y2_hhid y3_hhid y4_hhid	
