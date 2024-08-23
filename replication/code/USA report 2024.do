/*=====================================================================================================================================
Project:		USA REPORT 2024
Author(s):		Natalia Rodriguez
Dependencies:  	World Justice Project
Creation Date:	August 2024
=======================================================================================================================================*/

clear all
cls

/*=====================================================================================================================================
					1. Settings and Data Loading
=====================================================================================================================================*/


*--- Required packages:
* NONE


*--- Defining directories paths:
// First, we define the path to the SharePoint in your local computer (This is different for EACH USER):

*------ (a) Natalia Rodriguez:
if (inlist("`c(username)'", "nrodriguez")) {
	global path2SP "C:\Users\nrodriguez\OneDrive - World Justice Project\Programmatic"
}

*------ (b) Any other user: PLEASE INPUT YOUR PERSONAL PATH TO THE SHAREPOINT DIRECTORY:
else {
	global path2SP ""
}

// Second, we define the path to the data and reference do-files (This is the same for ALL USERS):
// No need to change

global doFiles ""
global data "${path2SP}\\Data Analytics\6. Country Reports\USA-report-2024\replication"

/*
*--- Loading Data (Master dataset/Merged):
use "${path2SP}\\General Population Poll\GPP 2024\Merged Files\Historical Files\Merged.dta", clear

*------ Keeping only the countries needed
keep if country=="United States"

*------ Saving the dataset only with the US data
save "$data\\usa_report_2024.dta", replace
*/


/*=====================================================================================================================================
					2. Frequency tables
=====================================================================================================================================*/


*------ Loading Data - USA data all years
use "$data\\usa_report_2024.dta", clear


*------ Full Sample

global vars "USA_q18b USA_q18c q43_G2 q43_G2 q50 q51 q52 q52 q45a_G1 q45b_G1 q45c_G1 q45a_G1 q45b_G1 q45c_G1 q1i q1e q1g q1b q1c q1d q1i q1g q1e q1c q1b q1d q48g_G2 q48f_G2 q48e_G1 q48g_G1 q48g_G2 q48f_G2 q48e_G1 q48g_G1"

tabout USA_q18a using "$data\\Full Sample.xls", replace c(freq col) format(0c 2) h3(USA_q18a|No.|%)

foreach v in $vars {
	tabout `v' using "$data\\Full Sample.xls", append c(freq col) format(0c 2) h3(`v'|No.|%)
}

*------ By gender












/*
collect clear

table USA_q18a, stat(frequency) stat(percent)
table USA_q18b, stat(frequency) stat(percent) append
collect layout (USA_q18a USA_q18b) (result)

collect export "$data\\Frequency tables.xlsx", replace

showcounts 
totals(USA_q18a) 




table USA_q18a gend if year==2024, stat(percent, across(USA_q18a)) nototals
tab USA_q18a gend if year==2024, col
*/

