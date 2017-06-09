************************************************************************
***************Ghani - Goswami- Kerr -		 ***********************
***************Golden Quadrilateral Highways*******
***************Economic Journal, 2014 ******************
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
***replace reg_sample = 1 if state_size_drop==0 & state_out_drop ==0 & district_sample_size_drop ==0 & district_pop_size_drop==0
replace reg_sample = 1 if  state_out_drop ==0 
keep if reg_sample == 1


*******************COLLAPSE DATA
collapse (sum) plants  totalemployees  totaloutput new_emp new_estab new_out old_emp old_estab old_out Totalemployeeswagebill totalemployeestotalLcost, by (year survey districtname  state_CONSISTENT )

rename plants plant
rename totalemployees empt
rename totaloutput output
ren Totalemployeeswagebill totalwage
ren totalemployeestotalLcost totalcost


foreach stat in mean {
merge  m:1 year survey districtname  state_CONSISTENT using "$data\tfp_w_ind_`stat'_by survey.dta"
drop _merge
}


keep if survey == "ASI"
keep if  year == 2000 |   year ==2005 |   year ==1994 | year ==2007 | year ==2009



keep  year state_CONSISTENT survey  districtname plant empt output new_emp new_estab new_out   tfp_w_wins_mean new_tfp_w_wins_mean 
reshape wide plant empt output new_emp new_estab new_out   tfp_w_wins_mean new_tfp_w_wins_mean  , i( state_CONSISTENT districtname) j(year)

merge  m:1 state_CONSISTENT districtname  using "$data1\GQ_dist_min_max.dta"
keep if _m==3
drop _merge

ren mean_dis_km dis_km_GQ
merge  m:1 state_CONSISTENT districtname  using "$data1\NS_EW_dis.dta"
keep if _m==3
drop _merge

ren dis_km dis_km_NS_EW

g nodal_GQ = 0
replace nodal = 1 if districtname == "Delhi" | districtname == "Mumbai" | districtname == "Bulandshahr" | districtname == "Gurgaon" | districtname == "Faridabad" | districtname == "Thane" |   districtname == "Kolkata" | districtname == "Chennai" | districtname == "Ghaziabad" 


g nodal_NS_EW = 0
replace nodal_NS_EW = 1 if districtname == "Delhi" | districtname == "Chandigarh" | districtname == "Bulandshahr" | districtname == "Gurgaon" | districtname == "Faridabad" | districtname == "Ghaziabad" | districtname == " Coimbatore" |   districtname == "Hyderabad" | districtname == "Bangalore" | districtname == "Kochi" | districtname == "Kanniyakumari" | districtname == "Kanpur Nagar" | districtname == "Lucknow" 


drop if dis_km_GQ == .

foreach hi in GQ NS_EW {


g `hi'_0_10 = 0
replace `hi'_0_10 = 1 if dis_km_`hi' <=10 & dis_km_`hi' >=0 & nodal_`hi' !=1
replace `hi'_0_10 = .  if dis_km_`hi' ==.


g `hi'_10_50 = 0
replace `hi'_10_50 = 1 if dis_km_`hi' <=50 & dis_km_`hi' >10 & nodal_`hi' !=1
replace `hi'_10_50 = . if dis_km_`hi' ==.


g `hi'_50 = 0
replace `hi'_50 = 1 if dis_km_`hi' >50 & nodal_`hi' !=1
replace `hi'_50 = . if dis_km_`hi'==.
}

foreach hi in GQ NS_EW {
preserve
collapse (sum) plant* empt* output* new_emp* new_estab* new_out*, by(nodal_`hi' `hi'_0_10 `hi'_10_50 `hi'_50)
foreach var in plant empt output new_emp new_estab new_out {
g preGQ_`var' = (`var'2000+`var'1994)/2
g postGQ_`var'= (`var'2007+`var'2005 +`var'2009)/3
} 

foreach t in preGQ postGQ {
g `t'_plant_size =(`t'_output/`t'_plant)
g `t'_lab_pdty =(`t'_output/`t'_empt)
g `t'_new_plant_size =(`t'_new_out/`t'_new_estab)
g `t'_new_lab_pdty = (`t'_new_out/`t'_new_emp)
}


keep preGQ_* postGQ_* nodal_`hi' `hi'_0_10 `hi'_10_50 `hi'_50 
gsort -nodal_`hi' -`hi'_0_10 -`hi'_10_50 -`hi'_50
order  nodal_`hi'  `hi'_0_10 `hi'_10_50 `hi'_50 preGQ_plant preGQ_empt preGQ_output preGQ_new_estab preGQ_new_emp preGQ_new_out preGQ_lab_pdty preGQ_plant_size preGQ_new_plant_size preGQ_new_lab_pdty postGQ_plant postGQ_empt postGQ_output postGQ_new_estab postGQ_new_emp postGQ_new_out postGQ_lab_pdty postGQ_plant_size postGQ_new_plant_size postGQ_new_lab_pdty
xmlsave "$work\T1_p1_`hi'restr.xml", doctype(excel) replace 
restore
}


foreach hi in GQ NS_EW {
preserve
collapse (mean) tfp_w_wins_mean* new_tfp_w_wins_mean*, by(nodal_`hi' `hi'_0_10 `hi'_10_50 `hi'_50)
foreach var in tfp_w_wins_mean new_tfp_w_wins_mean {
g preGQ_`var' = (`var'2000+`var'1994)/2
g postGQ_`var'= (`var'2007+`var'2005 +`var'2009)/3
} 



keep preGQ_* postGQ_* nodal_`hi' `hi'_0_10 `hi'_10_50 `hi'_50 

order *new*, last
order preGQ*, first 
order postGQ*, last
order  nodal_`hi' `hi'_0_10 `hi'_10_50 `hi'_50
xmlsave "$work\T1_p2_`hi'restr.xml", doctype(excel) replace 

restore
}

g state_out_drop=(state_CONSISTENT=="A & N ISLANDS") | (state_CONSISTENT=="ARUNACHAL PRADESH")|(state_CONSISTENT=="DADRA & NAGAR HAVELI") |(state_CONSISTENT=="DAMAN & DIU") |(state_CONSISTENT=="JAMMU & KASHMIR") |(state_CONSISTENT=="TRIPURA") |(state_CONSISTENT=="MANIPUR") |(state_CONSISTENT=="MEGHALAYA") |(state_CONSISTENT=="MIZORAM") |(state_CONSISTENT=="NAGALAND") |(state_CONSISTENT=="ASSAM")
g reg_sample=0
****replace reg_sample = 1 if state_size_drop==0 & state_out_drop ==0 & district_sample_size_drop ==0 & district_pop_size_drop==0
replace reg_sample = 1 if  state_out_drop ==0 
keep if reg_sample == 1

foreach hi in GQ NS_EW {
foreach bin in nodal_`hi' `hi'_0_10 `hi'_10_50 `hi'_50 {
count if `bin' == 1
}
}



