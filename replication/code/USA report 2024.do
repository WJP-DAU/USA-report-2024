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

*Creating q21_merge 
gen USA_q21j_merge=USA_q21j_G1 
replace USA_q21j_merge=USA_q21j_G2 if USA_q21j_merge==.


#delimit ;
global vars "
USA_q18b 
USA_q18c 
q43_G2 
q50 
q51 
q52 
q45a_G1 
q45b_G1 
q45c_G1 
q1i 
q1e 
q1g 
q1b 
q1c 
q1d 
q48g_G2 
q48f_G2 
q48e_G1 
q48g_G1 
USA_q21e_G1
USA_q21f_G1
USA_q1k
USA_q2h
USA_q21g_G2
USA_q21a_G1
USA_q21a_G2
USA_q21b_G1
USA_q21h_G1
USA_q21j_merge
USA_q21b_G2
USA_q21g_G1
USA_q21h_G2
USA_q21i_G2
USA_q21c_G2
USA_q21c_G1
USA_q21d_G1
USA_q21f_G2
USA_q21j_G2
USA_q20a
USA_q20b
USA_q19a
USA_q19b
USA_q19c
USA_q19d
USA_q19e
USA_q19f
USA_q22a_G1
USA_q22b_G1
USA_q22c_G1
USA_q22d_G1
USA_q22e_G1
USA_q22a_G2
USA_q22b_G2
USA_q22c_G2
USA_q22d_G2
USA_q22e_G2
" ;
#delimit cr


*------ Full Sample

tabout USA_q18a using "$data\\Full Sample.xls" if year==2024, replace c(freq col) format(0c 2) h3(USA_q18a|No.|%)

foreach v in $vars {
	tabout `v' using "$data\\Full Sample.xls" if year==2024, append c(freq col) format(0c 2) h3(`v'|No.|%)
}


*------ By age

gen age2=.
replace age2=1 if age<=24 & age!=.
replace age2=2 if age>24 & age<=34 & age!=.
replace age2=3 if age>34 & age<=44 & age!=.
replace age2=4 if age>44 & age<=54 & age!=.
replace age2=5 if age>54 & age<=64 & age!=.
replace age2=6 if age>64 & age!=.

label define age 1 "18-24" 2 "25-34" 3 "35-44" 4 "45-54" 5 "55-64" 6 "65+"
label values age2 age

tabout USA_q18a age2 using "$data\\Age.xls" if year==2024, replace c(freq col) h1(USA_q18a) format(0c 2 0c 2 0c 2 0c 2 0c 2 0c 2 0c 2)

foreach v in $vars {
	tabout `v' age2 using "$data\\Age.xls" if year==2024, append c(freq col) h1(`v') format(0c 2 0c 2 0c 2 0c 2 0c 2 0c 2 0c 2)
}


*------ By gender

tabout USA_q18a gend using "$data\\Gender.xls" if year==2024, replace c(freq col) h1(USA_q18a) format(0c 2 0c 2 0c 2)

foreach v in $vars {
	tabout `v' gend using "$data\\Gender.xls" if year==2024, append c(freq col) h1(`v') format(0c 2 0c 2 0c 2)
}

*------ By race

gen ethni2=.
replace ethni2=1 if ethni=="White"
replace ethni2=2 if ethni!="White" & ethni!="Prefer not to answer"
replace ethni2=3 if ethni=="Prefer not to answer"

label define ethni 1 "White" 2 "Others" 3 "Prefer not to say"
label values ethni2 ethni 

tabout USA_q18a ethni2 using "$data\\Race.xls" if year==2024, replace c(freq col) h1(USA_q18a) format(0c 2 0c 2 0c 2 0c 2)

foreach v in $vars {
	tabout `v' ethni2 using "$data\\Race.xls" if year==2024, append c(freq col) h1(`v') format(0c 2 0c 2 0c 2 0c 2)
}


*------ By Urban

label define urban 1 "Urban" 2 "Rural"
label values Urban urban


tabout USA_q18a Urban using "$data\\Urban.xls" if year==2024, replace c(freq col) h1(USA_q18a) format(0c 2 0c 2 0c 2)

foreach v in $vars {
	tabout `v' Urban using "$data\\Urban.xls" if year==2024, append c(freq col) h1(`v') format(0c 2 0c 2 0c 2)
}


*------ By Party

gen USA_new_paff=.
replace USA_new_paff=1 if USA_paff1==2 //Democrats
replace USA_new_paff=2 if USA_paff1==1 //Republicans
replace USA_new_paff=3 if USA_paff1==3 //Independent
replace USA_new_paff=4 if USA_paff1==4 | USA_paff1==98 | USA_paff1==99 //Other, prefer not, DK

label define paff 1 "Democrats" 2 "Republicans" 3 "Independent" 4 "Other, prefer not to say, don't know"
label value USA_new_paff paff


tabout USA_q18a USA_new_paff using "$data\\Party.xls" if year==2024, replace c(freq col) h1(USA_q18a) format(0c 2 0c 2 0c 2 0c 2 0c 2)

foreach v in $vars {
	tabout `v' USA_new_paff using "$data\\Party.xls" if year==2024, append c(freq col) h1(`v') format(0c 2 0c 2 0c 2 0c 2 0c 2)
}






