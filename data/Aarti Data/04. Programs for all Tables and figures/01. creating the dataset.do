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

g lpdty_unwt = totaloutput/totalemployees 



*******cohort analysis for table 6
g age_9 = 0
 replace age_9 =1 if age>=9
 g age_7 =0
 replace age_7 = 1 if age>=7
 
  g age_10 =0
 replace age_10 = 1 if age>=10

 foreach age_c in age_7 age_9 age_10 {
 preserve
 collapse (sum) plants  totalemployees  totaloutput new_emp new_estab new_out (mean) lpdty_unwt, by (year survey districtname `age_c' state_CONSISTENT )
 rename plants plant
rename totalemployees empt
rename totaloutput output
 foreach i in plant  empt  output new_emp new_estab new_out  {
 ren `i' `i'_`age_c'
 }
 keep if `age_c' ==1
 drop `age_c'
 sort state_CONSISTENT districtname year 
 tempfile tmp_`age_c'
 save tmp_`age_c', replace
 restore
 
 } 

  foreach age_c in age_7 age_9 age_10 {
 preserve
 collapse (sum) plants  totalemployees  totaloutput new_emp new_estab new_out (mean) lpdty_unwt, by (year survey districtname `age_c' state_CONSISTENT )
 rename plants plant
rename totalemployees empt
rename totaloutput output
 foreach i in plant  empt  output new_emp new_estab new_out  {
 ren `i' `i'_`age_c'_y
 }
 keep if `age_c' ==0 
 drop `age_c'
 sort state_CONSISTENT districtname year 
 tempfile tmp_`age_c'_y
 save tmp_`age_c'_y, replace
 restore
  } 
 
*******************COLLAPSE DATA
collapse (sum) plants  totalemployees  totaloutput new_emp new_estab new_out old_emp old_estab old_out Totalemployeeswagebill totalemployeestotalLcost (mean) lpdty_unwt, by (year survey districtname  state_CONSISTENT )

rename plants plant
rename totalemployees empt
rename totaloutput output
ren Totalemployeeswagebill totalwage
ren totalemployeestotalLcost totalcost

*****************merge cohorts
 foreach age_c in age_7 age_9 age_10 {
  merge m:1 year survey districtname state_CONSISTENT using tmp_`age_c'
  drop if _m==2
  drop _m
  merge m:1 year survey districtname state_CONSISTENT using tmp_`age_c'_y
  drop if _m==2
  drop _m
    }
foreach i in plant empt output {
g sh_`i'_age_10 = `i'_age_10/`i'

replace sh_`i'_age_10  = 1 if sh_`i'_age_10  ==.
}

**************merging distance data

merge  m:1 state_CONSISTENT districtname  using "$data1\GQ_dist_min_max.dta"
*assert _m==3
drop if _m ==2
drop _merge

ren mean_dis_km dis_km

********distance from district centroid

merge  m:1 state_CONSISTENT districtname  using  "$data1\distance_centroid.dta"
* assert _m==3
drop if _m ==2
drop _merge


foreach stat in mean {
merge  m:1 year survey districtname  state_CONSISTENT using "$data\tfp_w_ind_`stat'_by survey_5yrs.dta"
drop _merge

merge m:1  year survey districtname  state_CONSISTENT using  "$data\tfp_w_ind_`stat'_by survey_resid_5yrs.dta"
drop _m


}

drop if year ==1999 | year == 2001 | year ==2002 | year ==2003 | year ==2004 | year ==2006


merge m:1 state_CONSISTENT districtname using "$data2\PopCensus District Indicators"
drop if _merge==2
drop _merge



destring year, replace
egen clustervar =group(state_CONSISTENT districtname)
global FE "i.year"
global FE1 " i.districtname i.year"
global FE2 "i.state_CONSISTENT i.year"

global options ", vce(cluster clustervar)"


g plant_size = (output/plant) 
g lab_pdty = (output/empt)
g plan_siz_em = (empt/plant)

g new_plant_size = (new_out/new_estab) 
g new_lab_pdty = (new_out/new_emp)
g new_plan_siz_em = (new_emp/new_estab)

g old_plant_size = (old_out/old_estab) 
g old_lab_pdty = (old_out/old_emp)
g old_plan_siz_em = (old_emp/old_estab)


g avg_wage = totalwage/empt
g avg_cost = totalcost/empt

drop if year == 1989
bys  state_CONSISTENT districtname survey: g cont = _N
drop if cont != 5 & survey == "ASI"
drop cont

keep if survey =="ASI"
keep  survey year state_CONSISTENT districtname plant empt output new_emp new_estab new_out totalwage totalcost dis_km  tfp* new_tfp* plant_size lab_pdty avg_wage avg_cost lpdty_unwt

order dis_km, before(plant)
reshape wide  plant- avg_cost, i( survey state_CONSISTENT districtname dis_km ) j( year)
ren dis_km  dis_km_GQ

merge  m:1 state_CONSISTENT districtname  using "$data1\NS_EW_dis.dta"
drop if _m ==2
drop _merge
ren dis_km dis_km_NS_EW
drop  state state_ORIGINAL
merge m:1 state_CONSISTENT districtname using "$data2\PopCensus District Indicators"
drop if _merge==2
drop _merge
g ln_totpop = ln(totpop)



sort  state_CONSISTENT districtname 
order  dis_km_GQ
order  dis_km_GQ, last
order  ln_totpop, last

merge m:1 state_CON districtname using "$data1\district road railway data.dta"

drop _m

preserve
insheet using "$data1\early_late_new_recons.csv",clear
ren v6 cons_type
ren  earlylatemoderate cons_time
ren state_consistent state_CONSISTENT 
g cons_time1 = 0
replace cons_time1 = 1 if cons_time == "early"
g cons_time2 = 0
replace cons_time2 = 1 if cons_time == "medium"
g cons_time3 = 0
replace cons_time3 = 1 if cons_time == "late"
g cons_type1 = 0
replace cons_type1 = 1 if cons_type == "new"
g cons_type2 = 0
replace cons_type2 = 1 if cons_type == "recons"
tempfile tmp
save `tmp', replace

restore

merge m:1 state_CONSISTENT districtname using `tmp'
drop if _m ==2
drop _m

*******************************PHASE I AND PHASE II OF NS -EW

preserve
insheet using "$data1\NS_EW_phaseI.csv", clear
drop if v3 == "phase1"
ren  v1 state_CONSISTENT
ren  v2 districtname
ren v3 phaseI
g phase_I = 0
replace phase_I = 1 if phaseI == "yes"
g phase_II = 0
replace phase_II = 1 if phaseI == "no"
tempfile tmp1
save `tmp1', replace


restore

merge m:1 state_CONSISTENT districtname using `tmp1'
drop if _m ==2
drop _m

g nodal_GQ = 0
replace nodal_GQ = 1 if districtname == "Delhi" | districtname == "Mumbai" | districtname == "Bulandshahr" | districtname == "Gurgaon" | districtname == "Faridabad" | districtname == "Thane" |   districtname == "Kolkata" | districtname == "Chennai" | districtname == "Ghaziabad" 


g nodal_NS_EW = 0
replace nodal_NS_EW = 1 if districtname == "Delhi" | districtname == "Chandigarh" | districtname == "Bulandshahr" | districtname == "Gurgaon" | districtname == "Faridabad" | districtname == "Ghaziabad" | districtname == "Hyderabad" | districtname == "Bangalore" | districtname == "Kochi" | districtname == "Kanniyakumari" | districtname == "Kanpur Nagar" | districtname == "Lucknow" 



foreach hi in GQ NS_EW {

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

g `hi'_200 = 0
replace `hi'_200 = 1 if dis_km_`hi' >200 & nodal_`hi' !=1
replace `hi'_200 = . if dis_km_`hi'==.

}



g dis_km_GQ2 = dis_km_GQ*dis_km_GQ


foreach i in I II  {
g NS_EW_0_10_ph`i' = NS_EW_0_10*phase_`i'
label variable NS_EW_0_10_ph`i' "NS_EW_0_10*Phase`i'"
replace NS_EW_0_10_ph`i' = 0 if NS_EW_0_10_ph`i' == .
}

foreach i in 1 2 3 {
g GQ_0_10_`i' = GQ_0_10*cons_time`i'
replace GQ_0_10_`i' = 0 if GQ_0_10_`i' ==.
}

foreach i in 1 2  {
g GQ_0_10_t`i' = GQ_0_10*cons_type`i'
replace GQ_0_10_t`i' = 0 if GQ_0_10_t`i' == . 
}


label variable GQ_0_10_1 "GQ_0_10*early"
label variable GQ_0_10_2 "GQ_0_10*med"
label variable GQ_0_10_3 "GQ_0_10*late"

label variable GQ_0_10_t1 "GQ_0_10*new"
label variable GQ_0_10_t2 "GQ_0_10*recons"



save "$data\130730-arti-data-working_3.dta", replace

 





