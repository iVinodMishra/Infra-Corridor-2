************************************************************************
***************Ghani - Goswami- Kerr -		 ***********************
***************Golden Quadrilateral Highways*******
***************Economic Journal, 2014 ******************
************************************************************************

clear
clear matrix
cap log close
set mem 900m
set maxvar 10000
set matsize 4000

global work "C:\Arti\lenovo work\Bill Kerr\Data\ASI NSS old data\ASI&NSS\03. Working"
global intdata "C:\Arti\lenovo work\Bill Kerr\Data\ASI NSS old data\ASI&NSS\04. Intermediate Datasets"
global do "C:\Arti\lenovo work\Bill Kerr\Data\ASI NSS old data\ASI&NSS\Programs"

log using "$work\ASI + NSS Dataset Append Clean and Flag.txt", t replace
qui do "$do\Prep industry deflators.do"

****************************
*****INPUT & APPEND DATA
local note1="This file uses appended establishment level ASI for years 1989-90, 1994-95,1999-00 to 2009-10. "

****************************
use "$intdata\ASI_Allyears_Clean.dta", clear
g dataset=survey+string(year)


compress


***FIX THIS
local note2 = "States which spun off from larger states during the sample time period have been recombined to original states as in Kathuria, Raj and Sen (2010). " 
***as in 2000, Bihar, MP and UP were bifurcated and three new states Uttarakhand(UP), Chattisgarh(MP) and Jharkhand (Bihar)
g state_ORIGINAL=state
tab state
replace state="BIHAR" if state=="Jharkhand" | state=="JHARKHAND"
replace state="MADHYA PRADESH" if state=="CHHATISGARH" | state=="Chhattisgarh"
replace state="UTTAR PRADESH" if state=="UTTARANCHAL" | state=="Uttaranchal"
tab state
 

****************************
***Clean States***
****************************
replace state=upper(state)
replace state="A & N ISLANDS" if state=="ANDAMAN AND NICOBAR ISLANDS"
replace state="CHHATTISGARH" if state=="CHHATISGARH"
replace state="DADRA & NAGAR HAVELI" if state=="DADRA  AND  NAGAR  HAVELI"
replace state="DAMAN & DIU" if state=="DAMAN  &  DIU "
replace state="MAHARASHTRA" if state=="MAHARASTRA"
replace state="PONDICHERRY" if state=="PONDICHERI"
replace state="UNKNOWN" if state==""
	

****************************
***OUTPUT CLEANUP	***
local note3 = "We replace total value of output with total value of sales where output value not available or not collected. Negative output values are recoded as missing."
****************************
***REPLACE totaloutput=totalsales in ASI 1989 & anywhere else not available
***REPLACE totaloutput=totalsales in NSS where not available
replace totaloutput=totalsales if dataset=="ASI1989"
replace totaloutput=totalsales if survey=="ASI" & totaloutput==. & totalsales!=.
bysort dataset: count if totaloutput<0
replace totaloutput=. if totaloutput<0
replace totalrawmaterials=totalrawmaterials+for_input_value if for_input_value!=.


****************************
***Crosswalk NICs***
local note4 = "NIC codes have been updated to the 2004 NIC classification system at the 3-digit level using crosswalking files provided by CSO. "
****************************


g nic387=""
g nic498=""
g nic404=""
g nic408 = ""

replace nic387=substr(industrycode,1,3) if year<1998
replace nic498=substr(industrycode,1,4) if year>=1998&year<2004
replace nic404=substr(industrycode,1,4) if year>=2004
replace nic408=substr(industrycode,1,4) if year>=2008

merge nic387 using "$work\NIC8798Crosswalk.dta", uniqusing sort nokeep
replace nic498 = nic498a if _==3
drop nic498a

tab year _merge
drop _merge

compress
merge nic498 using "$work\NIC9804Crosswalk.dta", uniqusing sort nokeep
replace nic404 = nic404a if _==3
drop nic404a
drop _merge

replace nic498="" if nic498=="."
replace nic404="" if nic404=="."
replace nic404="9999" if nic404=="" & nic387=="" & nic498==""
tab dataset if nic304==""
replace nic304 =substr(nic404,1,3) if nic304=="" & nic404!=""
tab dataset if nic304==""
replace nic304="999" if nic304=="" & nic387=="" & nic498==""
replace nic304="999" if nic304==""

*******************************merging NIC2008

merge nic408 using "$work\NIC0804Crosswalk.dta", uniqusing sort nokeep
replace nic404 = nic404a if _m==3
replace nic304 =substr(nic404,1,3) if _m==3
drop nic404a
drop _merge

replace nic408="" if nic408=="."
replace nic404="" if nic404=="."
replace nic404="9999" if nic404=="" & nic387=="" & nic498=="" & nic408 == ""
tab dataset if nic304==""
replace nic304 =substr(nic404,1,3) if nic304=="" & nic404!=""
replace nic304= "241" if nic304 =="233" & year >=2008
tab dataset if nic304==""
replace nic304="999" if nic304=="" & nic387=="" & nic498==""
replace nic304="999" if nic304==""
drop nic387 nic498 industrycode


****************************
***Replace Unknown 3 digit nics from latest year which are probably recording errors***
local note5 = "A small number of errant 3-digit NIC codes have been reclassified as unknown. Errant NIC codes are those which are not listed in the official NIC directory."
****************************
replace nic304="999" if nic304=="150"
replace nic304="999" if nic304=="190"
replace nic304="999" if nic304=="212"
replace nic304="999" if nic304=="214"
replace nic304="999" if nic304=="229"
replace nic304="999" if nic304=="264"
replace nic304="999" if nic304=="267"
replace nic304="999" if nic304=="282"
replace nic304="999" if nic304=="310"
replace nic304="999" if nic304=="452"
replace nic304="999" if nic304=="454"
replace nic304="999" if nic304=="501"
replace nic304="999" if nic304=="503"
replace nic304="999" if nic304=="505"
replace nic304="999" if nic304=="523"
replace nic304="999" if nic304=="552"
replace nic304="999" if nic304=="742"
replace nic304="999" if nic304=="911"

destring nic304, replace
drop if nic304 <150 | nic304>369
tostring nic304, replace

merge nic304 using "$work\NIC304 Description", uniqusing sort nokeep
tab _

replace nic2desc="Other Undefined N.E.C." if nic2desc==""
g nic204=substr(nic304,1,2)

tab year _
drop _merge

****************************
***Assign Lead-Lag Designations***
local note6 = "Leading/lagging regions follow the classification methodology used by Honorati and Mengistae (2007).  They use a two-way classification, which follows Purfield (2006) but uses more recent data."
****************************
g lead=""
replace lead="Lead" if state=="A & N ISLANDS"
replace lead="Lag" if state=="ANDHRA PRADESH"
replace lead="Lag" if state=="ARUNACHAL PRADESH"
replace lead="Lag" if state=="ASSAM"
replace lead="Lag" if state=="BIHAR"
replace lead="Lead" if state=="CHANDIGARH"
replace lead="Lag" if state=="CHHATTISGARH"
replace lead="Lead" if state=="DADRA & NAGAR HAVELI"
replace lead="Lead" if state=="DAMAN & DIU"
replace lead="Lead" if state=="DELHI"
replace lead="Lead" if state=="GOA"
replace lead="Lead" if state=="GUJARAT"
replace lead="Lead" if state=="HARYANA"
replace lead="Lead" if state=="HIMACHAL PRADESH"
replace lead="Lag" if state=="JAMMU & KASHMIR"
replace lead="Lag" if state=="JHARKHAND"
replace lead="Lead" if state=="KARNATAKA"
replace lead="Lead" if state=="KERALA"
replace lead="Lag" if state=="LAKSHADWEEP"
replace lead="Lag" if state=="MADHYA PRADESH"
replace lead="Lead" if state=="MAHARASHTRA"
replace lead="Lag" if state=="MANIPUR"
replace lead="Lag" if state=="MEGHALAYA"
replace lead="Lag" if state=="MIZORAM"
replace lead="Lag" if state=="NAGALAND"
replace lead="Lag" if state=="ORISSA"
replace lead="Lead" if state=="PONDICHERRY"
replace lead="Lead" if state=="PUNJAB"
replace lead="Lag" if state=="RAJASTHAN"
replace lead="Lag" if state=="SIKKIM"
replace lead="Lead" if state=="TAMIL NADU"
replace lead="Lag" if state=="TRIPURA"
replace lead="Lag" if state=="UTTAR PRADESH"
replace lead="Lag" if state=="UTTARANCHAL"
replace lead="Lag" if state=="WEST BENGAL"
replace lead="UNK" if state=="UNKNOWN"





****************************
***Assign IMPORT Status
****************************
g importer=for_input_value>0 & for_input_value!=.

****************************
***Calculate firm size bvy # of plants
*************************
replace plants=1 if plants==0
g totalemployees_plant=totalemployees/plants

****************************
***Designate Firm Size
local note8 = "We assign establishment size based on various sets of cutoffs. The most widely used variable will be 'fsize_5'."
*************************
*Firm size: 
*0- ultramicro 1-4 employees,
*1- micro 5-9 employees,
*2- vsmall 10-19,
*3- mediumsmall 20-39,
*4- medium 40-99,
*5- large 100-499,
*6- mega 500+
*************************

g fsize_7=.
replace fsize=0 if  totalemployees_plant>=0& totalemployees_plant<5
replace fsize=1 if  totalemployees_plant>=5& totalemployees_plant<10
replace fsize=2 if  totalemployees_plant>=10& totalemployees_plant<20
replace fsize=3 if  totalemployees_plant>=20& totalemployees_plant<40
replace fsize=4 if  totalemployees_plant>=40& totalemployees_plant<100
replace fsize=5 if  totalemployees_plant>=100 & totalemployees_plant<500
replace fsize=6 if  totalemployees_plant>=500 & totalemployees_plant!=.
replace fsize=-9 if  totalemployees_plant==.

tab fsize
count

lab def fsize_7 0"UltraMicro" 1"Micro" 2"VSmall" 3"MediumSmall" 4"Medium" 5"Large" 6"Mega" -9"Unk"
lab val fsize_7 fsize_7
tab fsize_7


****************************
***Designate Firm Size
*************************
***ACC TO ANN HARRISON NSF PROPOSAL GROUPS
*************************

g fsize_AH=.
replace fsize_AH=0 if  totalemployees_plant>=0& totalemployees_plant<5
replace fsize_AH=1 if  totalemployees_plant>=5& totalemployees_plant<10
replace fsize_AH=2 if  totalemployees_plant>=10& totalemployees_plant<50
replace fsize_AH=3 if  totalemployees_plant>=50& totalemployees_plant<100
replace fsize_AH=4 if  totalemployees_plant>=100& totalemployees_plant<200
replace fsize_AH=5 if  totalemployees_plant>=200 & totalemployees_plant<500
replace fsize_AH=6 if  totalemployees_plant>=500 & totalemployees_plant!=.
replace fsize_AH=-9 if  totalemployees_plant==.

tab fsize_AH
count

lab def fsize_AH 0"0+" 1"5+" 2"10+" 3"50+" 4"100+" 5"200+" 6"500+" -9"Unk", modify
lab val fsize_AH fsize_AH
tab fsize_AH


****************************
***Designate Firm Size
*************************
***4 GROUPS 
*************************

g fsize_4=.
replace fsize_4=0 if  totalemployees_plant>=0& totalemployees_plant<10
replace fsize_4=1 if  totalemployees_plant>=10& totalemployees_plant<20
replace fsize_4=2 if  totalemployees_plant>=20& totalemployees_plant<100
replace fsize_4=3 if  totalemployees_plant>=100& totalemployees_plant!=.
replace fsize_4=-9 if  totalemployees_plant==.

tab fsize_4
count

lab def fsize_4 0"Micro 0-9" 1"Small 10-19" 2"Medium 20-99" 3"Large 100+" -9"Unk", modify
lab val fsize_4 fsize_4
tab fsize_4




****************************
***Designate Firm Size
*************************
***5 GROUPS---THIS IS THE DESIGNATION TO USE IN FINAL ANALYSES
*************************

g fsize_5=.
replace fsize_5=0 if  totalemployees_plant>=0& totalemployees_plant<10
replace fsize_5=1 if  totalemployees_plant>=10& totalemployees_plant<20 & survey=="NSS"
replace fsize_5=2 if  totalemployees_plant>=10& totalemployees_plant<20 & survey=="ASI"
replace fsize_5=3 if  totalemployees_plant>=20& totalemployees_plant<40
replace fsize_5=4 if  totalemployees_plant>=40& totalemployees_plant<100
replace fsize_5=5 if  totalemployees_plant>=100& totalemployees_plant<500
replace fsize_5=6 if  totalemployees_plant>=500& totalemployees_plant!=.
replace fsize_5=-9 if  totalemployees_plant==.

tab fsize_5
count

lab def fsize_5 0"0_9" 1"10_19_NSS"  2"10_19_ORG" 3"20-39" 4"40-99" 5"100-499" 6"500+" -9"Unk", modify
lab val fsize_5 fsize_5
tab fsize_5


****************************
***Designate Firm Size
*************************
***IC GROUPS
*************************
*************************
*Firm size: 
*1- micro 1-10 employees,
*2- small 11-50,
*3- medium 21-200,
*4- large >200
*************************

g fsize_IC=.
replace fsize_IC=1 if totalemployees_plant>=0&totalemployees_plant<=10
replace fsize_IC=2 if totalemployees_plant>10&totalemployees_plant<=50
replace fsize_IC=3 if totalemployees_plant>50&totalemployees_plant<=200
replace fsize_IC=4 if totalemployees_plant>200&totalemployees_plant!=.

tab fsize_IC
count

lab def fsize_IC 1"Micro" 2"Small" 3"Medium" 4"Large", modify
lab val fsize_IC fsize_IC
tab fsize_IC


drop totalemployees_plant

***********************************************************
*Firm's age category:
*1- young 1-5years, 2- mature 6-15 years, 3 - old >15 years
local note9 = "We clean a small number of suspected entry errors in the 'year of first operations' variable. We topcode a constructed 'age of enterprise' variable at 99 years."
***********************************************************
g age = year-startyear
tab dataset if age==.

replace startyear=. if startyear>2009
replace startyear=2000+startyear if startyear<=9

tab startyear if startyear<1000

replace startyear=1968 if startyear==168
replace startyear=1982 if startyear==182
replace startyear=1984 if startyear==184
replace startyear=1986 if startyear==186
replace startyear=1989 if startyear==189
replace startyear=1991 if startyear==191
replace startyear=1992 if startyear==192
replace startyear=1995 if startyear==195
replace startyear=1996 if startyear==196
replace startyear=1997 if startyear==197
replace startyear=1998 if startyear==198
replace startyear=1999 if startyear==199
replace startyear=2000 if startyear==200
replace startyear=2001 if startyear==201
replace startyear=2004 if startyear==204
replace startyear=2005 if startyear==205
replace startyear=2002 if startyear==202
replace startyear=2003 if startyear==203
replace startyear=2006 if startyear==206
replace startyear=2007 if startyear==207
replace startyear=2009 if startyear==209
replace startyear=2008 if startyear==208


replace startyear=1974 if startyear==974
replace startyear=1976 if startyear==976
replace startyear=1978 if startyear==978
replace startyear=1982 if startyear==982
replace startyear=1983 if startyear==983
replace startyear=1994 if startyear==994
replace startyear=1996 if startyear==996

tab startyear if startyear<1000

tab startyear if startyear>year & startyear!=.
replace startyear = year if startyear-1==year
replace startyear =. if startyear>year & startyear!=.

replace startyear=. if startyear<1000

replace age=year-startyear if age==.
replace age=0 if age<0
replace age=99 if age>99 & age!=.
sum age, d

g under3=1 if (age<=3 & survey=="ASI") 
replace under3=0 if under3==.

tab dataset under3


gen age_cat=1 if age>=1&age<=5
replace age_cat=2 if age>=6&age<=15
replace age_cat=3 if age>=16
replace age_cat=. if age==.
lab def age_cat 1"young" 2"mature" 3"old"
lab val age_cat age_cat



****************************
***designate age groups
****************************
g age_group=""

replace age_group="0-9" if age>=0 & age<10
replace age_group="10-19" if age>=10 & age<20
replace age_group="20-29" if age>=20 & age<30
replace age_group="30-39" if age>=30 & age<40
replace age_group="40-49" if age>=40 & age<50
replace age_group="50-59" if age>=50 & age<60
replace age_group="60-69" if age>=60 & age<70
replace age_group="70-79" if age>=70 & age<80
replace age_group="80-89" if age>=80 & age<90
replace age_group="90-98" if age>=90 & age<99
replace age_group="99+" if age>=99 & age<101

g age_group5=""
replace age_group5="0-5" if age>=0 & age<5
replace age_group5="05-10" if age>=5 & age<10
replace age_group5="10-14" if age>=10 & age<15
replace age_group5="15-19" if age>=15 & age<20
replace age_group5="20-24" if age>=20 & age<25
replace age_group5="25-29" if age>=25 & age<30
replace age_group5="30-34" if age>=30 & age<35
replace age_group5="35-39" if age>=35 & age<40
replace age_group5="40-44" if age>=40 & age<45
replace age_group5="45-49" if age>=45 & age<50
replace age_group5="50-54" if age>=50 & age<55
replace age_group5="55-59" if age>=55 & age<60
replace age_group5="60-79" if age>=60 & age<80
replace age_group5="80-98" if age>=80 & age<99
replace age_group5="99+" if age>=99 & age<104


****************************
******G 5 YEAR COHORTS****
****************************
tab dataset if startyear==.
destring year, replace


g cohort=""
replace cohort="2001-2005" if startyear>=2001 & startyear<=2005
replace cohort="1995-2000" if startyear>=1995 & startyear<=2000
replace cohort="1990-1994" if startyear>=1990 & startyear<=1994
replace cohort="1985-1989" if startyear>=1985 & startyear<=1989
replace cohort="1980-1984" if startyear>=1980 & startyear<=1984
replace cohort="1975-1979" if startyear>=1975 & startyear<=1979
replace cohort="1970-1974" if startyear>=1970 & startyear<=1974
replace cohort="1965-1969" if startyear>=1965 & startyear<=1969
replace cohort="1960-1964" if startyear>=1960 & startyear<=1964
replace cohort="1955-1959" if startyear>=1955 & startyear<=1959
replace cohort="1950-1954" if startyear>=1950 & startyear<=1954
replace cohort="1945-1949" if startyear>=1945 & startyear<=1949
replace cohort="1940-1944" if startyear>=1940 & startyear<=1944
replace cohort="1935-1939" if startyear>=1935 & startyear<=1939
replace cohort="1930-1934" if startyear>=1930 & startyear<=1934
replace cohort="1935-" if startyear<=1935
replace cohort="Unknown-" if cohort=="" & survey=="ASI"


tab dataset if cohort==""



****************************
***Change Currency Accounts from LCU to 2005 Const USD***
local note10 = "We deflate the current rupee values using wholesale price indices of manufacturing industries used by Gupta, Hasan, and Kumar (2009), and convert to 2005 international $USD at purchasing-power parity."
****************************
g nic304_orig=nic304
	replace nic304="241" if nic304=="242"
	replace nic304="241" if nic304=="243"
	replace nic304="272" if nic304=="273"
	replace nic304="293" if nic304=="291"
	replace nic304="293" if nic304=="292"
	replace nic304="311" if nic304=="312"
	replace nic304="314" if nic304=="315"
	replace nic304="322" if nic304=="323"
	replace nic304="341" if nic304=="342"
	replace nic304="341" if nic304=="343"

merge m:1 nic304 year using "$work\industry_deflator"
	drop if _m==2
	tab nic304 year if _m==1
	destring nic304, replace
	
	*assert (nic304<150 | nic304>369) if _m==1
	tostring nic304, replace
	drop _m
	
replace nic304=nic304_orig

scalar ppp_adjustor=14.66854168	/*FROM WDI, series "PPP conversion factor, GDP (LCU per international $)" for INDIA 2005 */
foreach i of varlist  totalfixedassets loanamount totalemployeestotalLcost Totalemployeeswagebill valueofelectricitysold valueelectricitypurchased valueofelectricityconsumed totalrawmaterials  interestamount totaloutput totalsales closingnetland closingnetbuilding inputvalue_max  for_inputvalue_max inputprice_max  for_inputprice_max  value_max price_max {
g `i'_LCU=`i'
replace `i' = `i'/wpi_deflator
replace `i'=`i'/ppp_adjustor
}

drop wpi_deflator



****************************
***Order Vars
****************************
ren under3 under3yrsold

#delim ;
order 

uniqid
survey
dataset
year
state
district
ruralurban
organization
ownership
organization
startyear
age
nic404
nic304
nic3description
nic2desc 
description
lead
importer
fsize*
age_cat
age_group age_group5 cohort
under3yrsold 
monthsops
multiplier

plants
totalfixedassets
closingnetland
closingnetbuilding
loanamount
totalemployees

Memployees
Femployees
totalemployeestotalLcost
Totalemployeeswagebill

totalrawmaterials
/*totalFArent*/
interestamount
totaloutput
totalsales
for_input_value
fixedcapitalformation
totalfixedassets_LCU
closingnetland_LCU
closingnetbuilding_LCU
loanamount_LCU
totalemployeestotalLcost_LCU
Totalemployeeswagebill_LCU
totalrawmaterials_LCU
/*totalFArent_LCU*/
interestamount_LCU
totaloutput_LCU
totalsales_LCU
;



#delim cr
compress


****************
***	INSPECT AND CREATE FLAGS TO CLEAN DATA OF OUTLIERS & OTHER PECULIARITIES
local note11="We inspect the data in an intensive manner to identify outliers and other idiosyncrasies that would affect summary statistics or econometric estimations."
****************
***NOTE: ALL ACCOUNTS HAVE ALREADY BEEN MADE ANNUAL
****************
***	Calculate Yearly LOGW per WORKER
****************
g W_per_worker=Totalemployeeswagebill/totalemployees
	g logW=log(W_per_worker)
bysort dataset: sum W_per_worker, d
bysort dataset: sum W_per_worker if state=="MAHARASHTRA", d
g monthly_wage_per_worker=W_per_worker
replace monthly_wage_per_worker=W_per_worker/12
bysort dataset: sum monthly_wage_per_worker, d

tabstat monthly_wage_per_worker, by (dataset) stat (mean p50 sd)

g Y_per_worker=totaloutput/totalemployees
bysort dataset: sum Y_per_worker, d
bysort dataset: sum Y_per_worker if state=="MAHARASHTRA", d
g monthly_Y_per_worker=Y_per_worker
replace monthly_Y_per_worker=Y_per_worker/12
bysort dataset: sum monthly_Y_per_worker, d

tabstat Y_per_worker, by (dataset) stat (mean p50 sd)
tabstat monthly_Y_per_worker, by (dataset) stat (mean p50 sd)
	g logY_per_EE=log(Y_per_worker)


****************
***	CLEAN OUTLIERS
****************
***Investigate cause of high output per worker means in ASI 1989
****************

tabstat Y_per_worker, by (dataset) stat (mean p50 sd)
***NOTICE V HIGH MEAN IN ASI 1989

sum Y_per_worker if year==1989 & survey=="ASI", d
***POSSIBLE CUTOFF OF LABOR PRODUCTIVITY OF >ONE MILLION USD PER WORKER PER ANNUM (?) Test and see WHERE these occur and WHAT happens to mean labor prod when removed
tab dataset 
tab dataset if Y_per_worker>1000000&Y_per_worker!=.

g output_per_worker_flag= Y_per_worker>1000000 & Y_per_worker!=.
tab dataset output_per_worker_flag, mi
***recheck effect of dropping outliers on means
tabstat Y_per_worker if output_per_worker_flag==0, by (dataset) stat (mean p50 sd)
sum Y_per_worker if year==1989 & survey=="ASI" & output_per_worker_flag==0, d

***LOOKS FIXED TO ME***
local note12="This inspection results in a data flag, 'output_per_worker_flag' which captures any firms with >1MM output per worker in 2005 USD @ PPP. This is a reasonable indication of eporting or recording error in the establishment level observations."



****************************
***CREATE ADDITIONAL OUTLIER AND DROP FLAGS
local note13 = "We create a number of additional flags indicating various outliers or other issues which may affect summary stats or econometrics."
****************************

****************************
***DROP KNOWN OUTLIERS***
local note14 = "We flag 1 observation which is an obvious outlier in total employment by 'emp_outlier_flag'. "
local note15="We flag any NSS (unorganized) firms with greater than 20 persons engaged (by 'NSS_toobig_flag'), as GT 20 persons engaged should be organized sector. Note that this is a very small portion of total establishments (<0.25% in any given year)."
local note16="We drop 8 observations with unrecorded state codes in 1989."
****************************
g NSS_toobig_flag =survey=="NSS" & totalemployees>20 & totalemployees!=.
g emp_outlier_flag =uniqid=="000233131702317"
drop if state=="UNKNOWN"



****************************
***FLAG  potential service industries given nic description***
local note16 = "NIC codes which indicates service industries (coverred in NSS survey sample) have been identified and flagged by the 'services_flag' variable. Note that the deflated/converted accounts for these observations will be null as deflators were unavailable."
****************************
g services_flag=0
replace services_flag=1 if nic304=="371"
replace services_flag=1 if nic304=="372"
replace services_flag=1 if nic304=="401"
replace services_flag=1 if nic304=="402"
replace services_flag=1 if nic304=="403"
replace services_flag=1 if nic304=="410"
replace services_flag=1 if nic304=="502"
replace services_flag=1 if nic304=="504"
replace services_flag=1 if nic304=="526"
replace services_flag=1 if nic304=="630"
replace services_flag=1 if nic304=="725"
replace services_flag=1 if nic304=="749"
replace services_flag=1 if nic304=="900"
replace services_flag=1 if nic304=="921"
replace services_flag=1 if nic304=="930"
replace services_flag=1 if nic304=="999"
replace services_flag=1 if nic304=="014"
replace services_flag=1 if nic304=="142"


****************************
***Clean out states***
local note17 = "We flag Arunachal Pradesh, Mizoram, Sikkim and Union Territory of Lakshadweep with 'state_sample_flag' as these states are covered only in the NSS sample. "
****************************

tab state, mi

g state_sample_flag=0
replace state_sample_flag=1 if state=="ARUNACHAL PRADESH"
replace state_sample_flag=1 if state=="LAKSHADWEEP"
replace state_sample_flag=1 if state=="MIZORAM"
replace state_sample_flag=1 if state=="SIKKIM"
replace state_sample_flag=1 if state=="UNKNOWN"



**************
********	Flag bad states, & other JUNK 
local note18="We flag other observations with null, zero or negative values in production function accounts."
**************

foreach i in totalemployees totaloutput totalrawmaterials totalfixedassets {
g null_`i'_flag=`i'==. 
g no_`i'_flag=`i'==0
g neg_`i'_flag=`i'<0
}
	

**************
********	Flag bad states, & other JUNK 
local note19="We flag a observations that are outliers in total output (GT 1 trillion 2005 USD @PPP) by 'high_output_flag'."
**************
count if totaloutput>1000000000 & totaloutput!=.
tab dataset if totaloutput>1000000000 & totaloutput!=.
sum totaloutput, d
g high_output_flag=totaloutput>1000000000
sum totaloutput if high_output_flag==0, d

/*****************************
***NEW ADDITIONS 12/3/11
****************************
egen totalunpaidemp=rowtotal(OTHEEFT OTHEEPT TOTOTHEE)
drop OTHEEFT OTHEEPT TOTOTHEE*/
****************************
***Save Master Dataset
****************************
compress

forval i=1/19{
dis "`note`i''"
}

label data "India Organized Manufacturing By Arti Grover agrover1@worldbank.org"

save "$intdata\ASI_AppendedMaster_CleanFlagged.dta", replace

cap log c


