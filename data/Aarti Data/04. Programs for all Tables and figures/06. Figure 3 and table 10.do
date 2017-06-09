************************************************************************
***************Ghani - Goswami- Kerr -		 ***********************
***************Golden Quadrilateral Highways*******
***************Economic Journal, 2014 ******************
************************************************************************
************************************************************************

global work "C:\Arti\"
global data "C:\Arti\EJ Programs\03. Final district level datasets"
global data1 "C:\Arti\EJ Programs\01. Data\Highway timing details"
global data2 "C:\Arti\EJ Programs\01. Data\Districts"


use "$work\analysis file_ASI_1989_2009.dta", clear
g VA_1 = totaloutput-totalrawmaterials 
drop if VA_1<0
drop if districtname == "Unknown"
drop if year ==1999 

rename ruralurban ruralurban2
g ruralurban=""
replace ruralurban = "_RUR" if ruralurban2==0
replace ruralurban = "_URB" if ruralurban2==1

g new_emp=totalemployees if under3yrsold==1
g new_estab=plants if under3yrsold==1
g new_out=totaloutput if under3yrsold==1

g old_emp=totalemployees if under3yrsold==0
g old_estab=plants if under3yrsold==0
g old_out=totaloutput if under3yrsold==0



foreach i in plants  totalemployees  totaloutput new_emp new_estab new_out old_emp old_estab old_out Totalemployeeswagebill totalemployeestotalLcost {
replace `i'=`i'*multiplier

}

************************
*** MERGE IN POPULATION 
************************
merge m:1 state_CONSISTENT districtname using "$data2\PopCensus District Indicators"
drop if _merge==2
drop _merge


************************
*** SET UP SAMPLE / REGRESSION DROP FLAGS
************************
***** Drop states with less than 100 (post-weighted) plants 
bysort state_CONSISTENT year survey: egen state_cutoff=sum(plants)
g state_size_drop=(state_cutoff<=100)
tab state_CONS state_size_drop
***** Drop small states / UTs, conflict-prone places
tab state_CONSISTENT year, mi
count
g state_out_drop=(state_CONSISTENT=="A & N ISLANDS") |(state_CONSISTENT=="DADRA & NAGAR HAVELI") |(state_CONSISTENT=="DAMAN & DIU") |(state_CONSISTENT=="JAMMU & KASHMIR") |(state_CONSISTENT=="TRIPURA") |(state_CONSISTENT=="MANIPUR") |(state_CONSISTENT=="MEGHALAYA") |(state_CONSISTENT=="MIZORAM") |(state_CONSISTENT=="NAGALAND") |(state_CONSISTENT=="ASSAM")
count
tab state_CONSISTENT state_out_drop, mi
g count=1
local count =_N
dis `count'
tempfile temp
save `temp', replace
***********************
*** SELECT DATA
***********************
bysort state_CONS district year survey: egen district_cutoff=sum(plants)
g district_sample_size_drop=(district_cutoff<=50)
g district_pop_size_drop= (totpop<1000000)


***********************
*** MAKE BASE SAMPLE FLAG
***********************
g reg_sample=0
replace reg_sample = 1 if  state_out_drop ==0 
keep if reg_sample == 1

g lpdty_unwt = totaloutput/totalemployees 

merge  m:1 state_CONSISTENT districtname  using "$data1\GQ_dist_min_max.dta"
*assert _m==3
drop if _m ==2
drop _merge

ren mean_dis_km dis_km_GQ

merge  m:1 state_CONSISTENT districtname  using "$data1\NS_EW_dis.dta"
drop if _m ==2
drop _merge
ren dis_km dis_km_NS_EW
drop  state state_ORIGINAL

g nodal_GQ = 0
replace nodal_GQ = 1 if districtname == "Delhi" | districtname == "Mumbai" | districtname == "Bulandshahr" | districtname == "Gurgaon" | districtname == "Faridabad" | districtname == "Thane" |   districtname == "Kolkata" | districtname == "Chennai" | districtname == "Ghaziabad" 

g nodal_NS_EW = 0
replace nodal_NS_EW = 1 if districtname == "Delhi" | districtname == "Chandigarh" | districtname == "Bulandshahr" | districtname == "Gurgaon" | districtname == "Faridabad" | districtname == "Ghaziabad" | districtname == "Hyderabad" | districtname == "Bangalore" | districtname == "Kochi" | districtname == "Kanniyakumari" | districtname == "Kanpur Nagar" | districtname == "Lucknow" 


foreach hi in GQ  NS_EW {

g `hi'_100 = .
replace `hi'_100 = 1 if dis_km_`hi' <100
replace `hi'_100 = 0 if dis_km_`hi'>=100
replace `hi'_100 = . if dis_km_`hi'==.

g `hi'_50 = .
replace `hi'_50 = 1 if dis_km_`hi' <50
replace `hi'_50 = 0 if dis_km_`hi'>=50
replace `hi'_50 = . if dis_km_`hi'==.

********create distance bins

g `hi'_0_10 = 0
replace `hi'_0_10 = 1 if dis_km_`hi' <=10 & dis_km_`hi' >=0 & nodal_`hi' !=1
replace `hi'_0_10 = .  if dis_km_`hi' ==.

g `hi'_10_50 = 0
replace `hi'_10_50 = 1 if dis_km_`hi' <=50 & dis_km_`hi' >10 & nodal_`hi' !=1
replace `hi'_10_50 = . if dis_km_`hi' ==.


***********another set of distance bins

*****[0,10], [10,50], [50, 125], [125,200]

g `hi'_50_125 = 0
replace `hi'_50_125 = 1 if dis_km_`hi' >50 & dis_km_`hi' <=125 & nodal_`hi' !=1
replace `hi'_50_125 = . if dis_km_`hi'==.


g `hi'_125_200 = 0
replace `hi'_125_200 = 1 if dis_km_`hi' >125 & dis_km_`hi' <=200 & nodal_`hi' !=1
replace `hi'_125_200 = . if dis_km_`hi'==.

g `hi'_200 = .
replace `hi'_200 = 1 if dis_km_`hi' <200
replace `hi'_200 = 0 if dis_km_`hi'>=200
replace `hi'_200 = . if dis_km_`hi'==.

}

*************adding abbreviated nic3 description
preserve
insheet using "$data2\nic3_short_des.csv", clear
keep nic304 nic3_desc
sort nic304
tempfile tmpnic3
save `tmpnic3', replace
restore
sort nic304
merge m:1 nic304 using `tmpnic3'
drop _m

***********IMPORTANT: CODING NODAL CITIES AS LYING WITHIN 0-10 KM
replace GQ_0_10 =1 if nodal_GQ==1
*********************************************************************
foreach hi in GQ NS_EW {
foreach dis in 200 {
foreach y in 1994  2000 {
preserve
collapse (sum) plants  totalemployees  totaloutput new_emp new_estab new_out old_emp old_estab old_out Totalemployeeswagebill totalemployeestotalLcost , by (year  `hi'_`dis' nic304 nic3_desc)


g wt_output = ln(totaloutput)
g wt_empt = ln(totalemployees) 

rename plants plant
rename totalemployees empt
rename totaloutput output
ren Totalemployeeswagebill totalwage
ren totalemployeestotalLcost totalcost

keep  plant empt output new_estab new_emp new_out old_emp old_estab old_out wt_output wt_empt  year nic304 nic3_desc `hi'_`dis'

***********************************************************************************

foreach i in  plant empt output new_estab new_emp new_out old_emp old_estab old_out {
bysort year nic304: egen sum_`i' = sum(`i')
}
foreach i in  plant empt output new_estab new_emp new_out old_emp old_estab old_out {
gen r_`i' = `i'/sum_`i'
}
keep if `hi'_`dis' ==1
drop `hi'_`dis'
drop sum_*
reshape wide plant empt output new_estab new_emp new_out old_emp old_estab old_out wt_output wt_empt r_*, i(nic304 nic3_desc) j(year)
 
foreach X in plant empt output new_estab new_emp new_out {
gen LD1`X'=ln((`X'2007+`X'2009)/(`X'1994+`X'2000))
gen LD2`X'=ln((`X'2007+`X'2009)/(2*`X'2000))
}

keep nic304 nic3_desc wt_output`y' wt_empt`y' LD1* LD2* r_plant`y' r_empt`y' r_output`y' r_new_estab`y' r_new_emp`y' r_new_out`y'
rensfix `y'


merge m:1  nic304 using "$data\alloc_LP style.dta"
drop if _m!=3
drop _m

merge m:1  nic304 using "$data\alloc_resid.dta"
drop if _m!=3
drop _m
**********************************************************************************************************************************
**************************FIGURE 3
**********************************************************************************************************************************
foreach X in empt output  {
foreach alloc in alloc {
foreach k in  LD2 {
 **************************************
twoway scatter  `k'`alloc' r_`X', xtitle("Share of `X' within 0-`dis' km of `hi', `y'", size(small)) ytitle("Change in Allocative Efficiency", size(small)) mlab(nic3_desc) legend(off) || lfit `k'`alloc' r_`X'  /*if `k'`alloc'<=0.5 & `k'`alloc'>=-0.5 */, legend(off)
graph export "$work\_`k'_`X'_`alloc'_`hi'_`dis'_`y'.wmf", replace
}
}
}
**********************************************************************************************************************************
**************************TABLE 10
**********************************************************************************************************************************
foreach i in r_  {
foreach alloc in alloc alloc00_94 alloc_resid {
eststo clear 
estimates clear
foreach X in plant empt output new_estab new_emp new_out  {
foreach k in  LD2 {
 **************************************
eststo: xi: regress  `k'`alloc' `i'`X' 
esttab _all using "$work\Alloc_regn_`alloc'_`hi'_`dis'_`i'_`y'.csv" ,replace se r2 ar2  star( + .1 ++ .05 +++ .01) b(%9.3f) se(%9.3f) drop( _cons  ) order(`i'`X' )
}
}
}
}
restore
}
}
}


