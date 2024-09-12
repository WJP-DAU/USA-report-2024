/*=====================================================================================================================================
Project:		USA REPORT 2024
Author(s):		Natalia Rodriguez
Dependencies:  	World Justice Project
Creation Date:	August 2024
=======================================================================================================================================*/

clear all
cls


/*=====================================================================================================================================
					0. Settings and Data Loading
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


*------ Loading Data - USA data all years
use "$data\\usa_report_2024.dta", clear


/*=====================================================================================================================================
					1. Recoding questions
=====================================================================================================================================*/


*------Creating q21_merge: USA_q21j_G1 and USA_q21e_G2
gen USA_q21j_merge=USA_q21j_G1 
replace USA_q21j_merge=USA_q21e_G2 if USA_q21j_merge==.


*------ Political parties
gen USA_new_paff=.
replace USA_new_paff=1 if USA_paff1==2 //Democrats
replace USA_new_paff=2 if USA_paff1==1 //Republicans
replace USA_new_paff=3 if USA_paff1==3 //Independent
replace USA_new_paff=4 if USA_paff1==4 | USA_paff1==98 | USA_paff1==99 //Other, prefer not, DK

label define paff 1 "Democrats" 2 "Republicans" 3 "Independent" 4 "Other, prefer not to say, don't know"
label value USA_new_paff paff

label var USA_new_paff "Political party"


*------Recoding questions

#delimit ;
foreach v in 
USA_q18a
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
{ ;
	recode `v' (98 99=.) ;
} ;
#delimit cr


/*=====================================================================================================================================
					2. Frequency tables
=====================================================================================================================================*/

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

tabout USA_q18a using "$data\\frequency\\Full Sample.xls" if year==2024, replace c(freq col) format(0c 2) h3(USA_q18a|No.|%)

foreach v in $vars {
	tabout `v' using "$data\\frequency\\Full Sample.xls" if year==2024, append c(freq col) format(0c 2) h3(`v'|No.|%)
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

tabout USA_q18a age2 using "$data\\frequency\\Age.xls" if year==2024, replace c(freq col) h1(USA_q18a) format(0c 2 0c 2 0c 2 0c 2 0c 2 0c 2 0c 2)

foreach v in $vars {
	tabout `v' age2 using "$data\\frequency\\Age.xls" if year==2024, append c(freq col) h1(`v') format(0c 2 0c 2 0c 2 0c 2 0c 2 0c 2 0c 2)
}


*------ By gender

tabout USA_q18a gend using "$data\\frequency\\Gender.xls" if year==2024, replace c(freq col) h1(USA_q18a) format(0c 2 0c 2 0c 2)

foreach v in $vars {
	tabout `v' gend using "$data\\frequency\\Gender.xls" if year==2024, append c(freq col) h1(`v') format(0c 2 0c 2 0c 2)
}

*------ By race

gen ethni2=.
replace ethni2=1 if ethni=="White"
replace ethni2=2 if ethni!="White" & ethni!="Prefer not to answer"
replace ethni2=3 if ethni=="Prefer not to answer"

label define ethni 1 "White" 2 "Others" 3 "Prefer not to say"
label values ethni2 ethni 

tabout USA_q18a ethni2 using "$data\\frequency\\Race.xls" if year==2024, replace c(freq col) h1(USA_q18a) format(0c 2 0c 2 0c 2 0c 2)

foreach v in $vars {
	tabout `v' ethni2 using "$data\\frequency\\Race.xls" if year==2024, append c(freq col) h1(`v') format(0c 2 0c 2 0c 2 0c 2)
}


*------ By Urban

label define urban 1 "Urban" 2 "Rural"
label values Urban urban


tabout USA_q18a Urban using "$data\\frequency\\Urban.xls" if year==2024, replace c(freq col) h1(USA_q18a) format(0c 2 0c 2 0c 2)

foreach v in $vars {
	tabout `v' Urban using "$data\\frequency\\Urban.xls" if year==2024, append c(freq col) h1(`v') format(0c 2 0c 2 0c 2)
}


*------ By Party

tabout USA_q18a USA_new_paff using "$data\\frequency\\Party.xls" if year==2024, replace c(freq col) h1(USA_q18a) format(0c 2 0c 2 0c 2 0c 2 0c 2)

foreach v in $vars {
	tabout `v' USA_new_paff using "$data\\frequency\\Party.xls" if year==2024, append c(freq col) h1(`v') format(0c 2 0c 2 0c 2 0c 2 0c 2)
}



/*=====================================================================================================================================
					3. Replication
=====================================================================================================================================*/


**                       **
******** SECTION I ********
**                       **

*------ Chart 2

foreach v in USA_q18a USA_q18b USA_q18c {
	gen double `v'_r=`v'
	recode `v'_r (1 2=1) (3 4=0)
	tab `v'_r USA_new_paff
}

preserve

keep if year==2024

collapse (mean) USA_q18a_r USA_q18b_r USA_q18c_r, by(country_year USA_new_paff)

label var USA_q18a_r "The future of the United States"
label var USA_q18b_r "US democracy"
label var USA_q18c_r "Your own life"


drop if USA_new_paff>2

export excel "$data\\Report replication.xlsx", replace sheet("Chart 2") firstrow(varl) cell(A1) 

putexcel set "$data\\Report replication.xlsx", sheet("Chart 2") modify
putexcel C2:E4, overwri nformat(percent) 
putexcel A1:E1, overwri bold hcenter txtwrap

restore


*------ Chart 3.1

qui tab q43_G2, g(q43_G2_)

preserve

collapse (mean) q43_G2_3, by(country_year)

label var q43_G2_3 "Percentage of respondents who believe that high-ranking government officials would be held accountable for breaking the law" 

export excel "$data\\Report replication.xlsx", sheet("Chart 3.1") firstrow(varl) cell(A1)

putexcel set "$data\\Report replication.xlsx", sheet("Chart 3.1") modify
putexcel B2:B8, overwri nformat(percent) 
putexcel A1:B1, overwri bold hcenter txtwrap

restore


*------ Chart 3.2

gen paff_year=.

*2018
replace paff_year=1 if paff3=="12103" & year== 2018 //Democrats 
replace paff_year=2 if paff3=="12104" & year== 2018 //Republicans

*2021
replace paff_year=1 if paff3=="The Democratic Party" & year==2021
replace paff_year=2 if paff3=="The Republican Party" & year==2021

*2024
replace paff_year=1 if USA_paff1==2 & year==2024 //Democrats
replace paff_year=2 if USA_paff1==1 & year==2024 //Republicans


label define paff_year 1 "Democrats" 2 "Republicans"
label value paff_year paff_year
label var paff_year "Political party"

preserve
collapse (mean) q43_G2_3, by(country_year paff_year)

drop if paff_year==.

label var q43_G2_3 "Percentage of respondents who believe that high-ranking government officials would be held accountable for breaking the law" 
label var paff_year "Political party"

export excel "$data\\Report replication.xlsx", sheet("Chart 3.2") firstrow(varl) cell(A1)

putexcel set "$data\\Report replication.xlsx", sheet("Chart 3.2") modify
putexcel C2:C7, overwri nformat(percent) 
putexcel A1:C1, overwri bold hcenter txtwrap

restore


*------ Chart 4

foreach v in q50 q51 {
	gen double `v'_r=`v'
	recode `v'_r (1 2 5=0) (3 4=1)
	tab `v'_r 
}

gen double q52_r=q52 
recode q52_r (1 2=1) (3 4=2)
qui tab q52_r, g(q52_r_)

preserve

keep if year>2017

collapse (mean) q50_r q51_r q52_r_1 q52_r_2, by(country_year)

label var q50_r "It is important that citizens have a say in government matters, even at the expense of efficiency."
label var q51_r "The president must always obey the law and the courts."
label var q52_r_1 "It is important to obey the government in power, no matter who you voted for."
label var q52_r_2 "It is not necessary to obey the laws of a government that you did not vote for."

export excel "$data\\Report replication.xlsx", sheet("Chart 4") firstrow(varl) cell(A1)

putexcel set "$data\\Report replication.xlsx", sheet("Chart 4") modify
putexcel B2:E4, overwri nformat(percent) 
putexcel A1:E1, overwri bold hcenter txtwrap

restore


*------ Chart 5

foreach v in q45a_G1 q45b_G1 q45c_G1 {
	gen double `v'_r=`v'
	recode `v'_r (1 2 =1) (3 4 = 0)
	tab `v'_r 
}

preserve

collapse (mean) q45a_G1_r q45b_G1_r q45c_G1_r, by(country_year )

label var q45a_G1_r "Congress"
label var q45b_G1_r "Courts"
label var q45c_G1_r "Citizens"

export excel "$data\\Report replication.xlsx", sheet("Chart 5") firstrow(varl) cell(A1)

putexcel set "$data\\Report replication.xlsx", sheet("Chart 5") modify
putexcel B2:D8, overwri nformat(percent) 
putexcel A1:D1, overwri bold hcenter txtwrap

restore


*------ Chart 6

preserve

keep if year==2018 | year==2024

collapse (mean) q45a_G1_r q45b_G1_r q45c_G1_r, by(country_year paff_year)

drop if paff_year==.

label var q45a_G1_r "Congress"
label var q45b_G1_r "Courts"
label var q45c_G1_r "Citizens"

export excel "$data\\Report replication.xlsx", sheet("Chart 6") firstrow(varl) cell(A1)

putexcel set "$data\\Report replication.xlsx", sheet("Chart 6") modify
putexcel B2:E5, overwri nformat(percent) 
putexcel A1:E1, overwri bold hcenter txtwrap

restore


*------ Chart 7

foreach v in q1i q1g q1e q1c q1b q1d {
	gen double `v'_r=`v'
	recode `v'_r (1 2 =1) (3 4 = 0)
	tab `v'_r 
}

preserve
collapse (mean) q1i_r q1g_r q1e_r q1c_r q1b_r q1d_r, by(country_year )

label var q1i_r "The news media"
label var q1g_r "Judges & Magistrates"
label var q1e_r "Prosecutors"
label var q1c_r "National Government Officers"
label var q1b_r "Local Government Officers"
label var q1d_r "Police Officers"

export excel "$data\\Report replication.xlsx", sheet("Chart 7") firstrow(varl) cell(A1)

putexcel set "$data\\Report replication.xlsx", sheet("Chart 7") modify
putexcel A2:G8, overwri nformat(percent)
putexcel A1:G1, overwri bold hcenter txtwrap

restore


*------ Chart 8

preserve

keep if year==2018 | year==2024

collapse (mean) q1i_r q1g_r q1e_r q1c_r q1b_r q1d_r, by(country_year paff_year)

drop if paff_year==.

label var q1i_r "The news media"
label var q1g_r "Judges & Magistrates"
label var q1e_r "Prosecutors"
label var q1c_r "National Government Officers"
label var q1b_r "Local Government Officers"
label var q1d_r "Police Officers"

export excel "$data\\Report replication.xlsx", sheet("Chart 8") firstrow(varl) cell(A1)

putexcel set "$data\\Report replication.xlsx", sheet("Chart 8") modify
putexcel A2:H5, overwri nformat(percent)
putexcel A1:H1, overwri bold hcenter txtwrap

restore


*------ Chart 9

foreach v in q48g_G2 q48f_G2 q48e_G1 q48g_G1 {
	gen double `v'_r=`v'
	recode `v'_r (1 2 =1) (3 4 = 0)
	tab `v'_r 
}

replace q48g_G1_r=1-q48g_G1_r

preserve
collapse (mean) q48g_G2_r q48f_G2_r q48e_G1_r q48g_G1_r, by(country_year )

label var q48g_G2_r "Judges decide cases in an independent manner"
label var q48f_G2_r "Prosecutors prosecute crimes in an independent manner"
label var q48e_G1_r "Courts guarantee everyone a fair trial"
label var q48g_G1_r "Courts are not biased towards money or influence"

export excel "$data\\Report replication.xlsx", sheet("Chart 9") firstrow(varl) cell(A1)

putexcel set "$data\\Report replication.xlsx", sheet("Chart 9") modify
putexcel A2:E8, overwri nformat(percent)
putexcel A1:E1, overwri bold hcenter txtwrap

restore


*------ Chart 10

preserve

keep if year==2018 | year==2024

collapse (mean) q48g_G2_r q48f_G2_r q48e_G1_r q48g_G1_r, by(country_year paff_year)

drop if paff_year==.

label var q48g_G2_r "Judges decide cases in an independent manner"
label var q48f_G2_r "Prosecutors prosecute crimes in an independent manner"
label var q48e_G1_r "Courts guarantee everyone a fair trial"
label var q48g_G1_r "Courts are not biased towards money or influence"

export excel "$data\\Report replication.xlsx", sheet("Chart 10") firstrow(varl) cell(A1)

putexcel set "$data\\Report replication.xlsx", sheet("Chart 10") modify
putexcel A2:F8, overwri nformat(percent)
putexcel A1:F1, overwri bold hcenter txtwrap

restore


**                       **
******** SECTION II ********
**                       **

*------ Chart 11

foreach v in USA_q1k USA_q21g_G2 USA_q21f_G1 USA_q21e_G1 USA_q2h {
	gen double `v'_r=`v'
	recode `v'_r (1 2 =1) (3 4 = 0)
	tab `v'_r 
}

foreach v in USA_q21b_G1 USA_q21a_G2 USA_q21a_G1 USA_q21h_G1 USA_q21j_merge {
	gen double `v'_r=`v'
	recode `v'_r (1 2 =1) (3 4 = 0)
	tab `v'_r 
}

foreach v in USA_q21i_G2 USA_q21h_G2 USA_q21g_G1 USA_q21c_G2 USA_q21b_G2 {
	gen double `v'_r=`v'
	recode `v'_r (1 2 =1) (3 4 = 0)
	tab `v'_r 
}


foreach v in USA_q21j_G2 USA_q21f_G2 USA_q21d_G1 USA_q21c_G1 {
	gen double `v'_r=`v'
	recode `v'_r (1 2 =1) (3 4 = 0)
	tab `v'_r 
}

preserve

keep if year==2024

#delimit ;
collapse (mean) 
USA_q1k_r USA_q21g_G2_r USA_q21f_G1_r USA_q21e_G1_r USA_q2h_r
USA_q21b_G1_r USA_q21a_G2_r USA_q21a_G1_r USA_q21h_G1_r USA_q21j_merge_r
USA_q21i_G2_r USA_q21h_G2_r USA_q21g_G1_r USA_q21c_G2_r USA_q21b_G2_r
USA_q21j_G2_r USA_q21f_G2_r USA_q21d_G1_r USA_q21c_G1_r
, by(country_year paff_year) ;
#delimit cr

drop if paff_year==.

label var USA_q1k_r "Election officials are trustworthy"
label var USA_q21g_G2_r "Complaint mechanism are transparent and impartial"
label var USA_q21f_G1_r "Checks and balances ensure electoral confidence"
label var USA_q21e_G1_r "The electoral authority is importial and effective"
label var USA_q2h_r "Election officials are free of corruption"

label var USA_q21b_G1_r "People are able to vote conveniently"
label var USA_q21a_G2_r "Voting access is equal for all citizens"
label var USA_q21a_G1_r "Ballot secrecy is guaranteed"
label var USA_q21h_G1_r "Political entry barries are low"
label var USA_q21j_merge_r "Candidates and parties avoid misinformation"

label var USA_q21i_G2_r "The process is free from foreign interference"
label var USA_q21h_G2_r "The process is free of corruption"
label var USA_q21g_G1_r "The process is safe from cyberattacks"
label var USA_q21c_G2_r "Electoral rules are impartial"
label var USA_q21b_G2_r "The process prevents fraud"

label var USA_q21j_G2_r "Losing candidates accept the results as legitimate"
label var USA_q21f_G2_r "Election results are transparently available"
label var USA_q21d_G1_r "Monitors can oversee voting and counting"
label var USA_q21c_G1_r "Votes are counted accurately"

export excel "$data\\Report replication.xlsx", sheet("Chart 11") firstrow(varl) cell(A1)

putexcel set "$data\\Report replication.xlsx", sheet("Chart 11") modify
putexcel A2:U3, overwri nformat(percent)
putexcel A1:U1, overwri bold hcenter txtwrap

restore


*------ Chart 12

foreach v in USA_q20a USA_q20b {
	tab `v', gen(`v'_)
	gen double `v'_r=`v'
	recode `v'_r (1 2 =1) (3 4 = 0)
}

replace USA_q20a_r=1-USA_q20a_r
replace USA_q20b_r=1-USA_q20b_r

preserve

keep if year==2024

collapse (mean) USA_q20a_1 USA_q20a_2 USA_q20a_3 USA_q20a_4 USA_q20b_1 USA_q20b_2 USA_q20b_3 USA_q20b_4, by(country_year paff_year)

drop if paff_year==.

label var USA_q20a_1 "Accept the results as legitimate and support his presidency"
label var USA_q20a_2 "Accept the results as legitimate and oppose his presidency"
label var USA_q20a_3 "Not accept the results as legitimate but do nothing"
label var USA_q20a_4 "Not accept the results as legitimate and take action to overturn them"

label var USA_q20b_1 "Accept the results as legitimate and support his presidency"
label var USA_q20b_2 "Accept the results as legitimate and oppose his presidency"
label var USA_q20b_3 "Not accept the results as legitimate but do nothing"
label var USA_q20b_4 "Not accept the results as legitimate and take action to overturn them"

*label var USA_q20a_r 
*label var USA_q20b_r

export excel "$data\\Report replication.xlsx", sheet("Chart 12") firstrow(varl) cell(A2)

putexcel set "$data\\Report replication.xlsx", sheet("Chart 12") modify
putexcel C1:F1 = "If the democrat candidate wins", overwri bold merge hcenter txtwrap fpattern(solid,"40 148 170") font(calibri, 11, white)
putexcel G1:J1 = "If the republican candidate wins", overwri bold merge hcenter txtwrap fpattern(solid,"243 108 33") font(calibri, 11, white)

putexcel A2:J4, overwri nformat(percent_d2)
putexcel A2:J2, overwri bold hcenter txtwrap

restore


*------ Chart 13

foreach v in USA_q19a USA_q19b USA_q19c USA_q19d USA_q19e USA_q19f {
	gen double `v'_r=`v'
	recode `v'_r (1 2 =1) (3 4 = 0)
}

preserve

keep if year==2024

collapse (mean) USA_q19a_r USA_q19b_r USA_q19c_r USA_q19d_r USA_q19e_r USA_q19f_r, by(country_year paff_year)

drop if paff_year==.

label var USA_q19a_r "Local poll workers"
label var USA_q19b_r "State-level election administrators"
label var USA_q19c_r "State and local courts"
label var USA_q19d_r "Congress"
label var USA_q19e_r "Federal and appeal courts"
label var USA_q19f_r "Supreme court"

export excel "$data\\Report replication.xlsx", sheet("Chart 13") firstrow(varl) cell(A1)

putexcel set "$data\\Report replication.xlsx", sheet("Chart 13") modify
putexcel A2:H3, overwri nformat(percent)
putexcel A1:H1, overwri bold hcenter txtwrap

restore


*------ Chart 14

foreach v in USA_q22a_G1 USA_q22b_G1 USA_q22c_G1 USA_q22d_G1 USA_q22e_G1 {
	gen double `v'_r=`v'
	recode `v'_r (1 2 =1) (3 4 = 0)
}

foreach v in USA_q22a_G2 USA_q22b_G2 USA_q22c_G2 USA_q22d_G2 USA_q22e_G2 {
	gen double `v'_r=`v'
	recode `v'_r (1 2 =1) (3 4 = 0)
}

preserve

keep if year==2024

collapse (mean) USA_q22a_G1_r USA_q22b_G1_r USA_q22c_G1_r USA_q22d_G1_r USA_q22e_G1_r USA_q22a_G2_r USA_q22b_G2_r USA_q22c_G2_r USA_q22d_G2_r USA_q22e_G2_r, by(country_year paff_year)

drop if paff_year==.

label var USA_q22a_G1_r "Criminal cases"
label var USA_q22b_G1_r "Absentee ballot"
label var USA_q22c_G1_r "Voting rights"
label var USA_q22d_G1_r "Voter harassment"
label var USA_q22e_G1_r "Vote recounts"

label var USA_q22a_G2_r "Criminal cases"
label var USA_q22b_G2_r "Absentee ballot"
label var USA_q22c_G2_r "Voting rights"
label var USA_q22d_G2_r "Voter harassment"
label var USA_q22e_G2_r "Vote recounts"

export excel "$data\\Report replication.xlsx", sheet("Chart 14") firstrow(varl) cell(A2)

putexcel set "$data\\Report replication.xlsx", sheet("Chart 14") modify
putexcel C1:G1 = "Courts", overwri bold merge hcenter txtwrap fpattern(solid,"40 148 170") font(calibri, 11, white)
putexcel H1:L1 = "Supreme court", overwri bold merge hcenter txtwrap fpattern(solid,"243 108 33") font(calibri, 11, white)

putexcel A2:L4, overwri nformat(percent)
putexcel A2:L2, overwri bold hcenter txtwrap

restore
























