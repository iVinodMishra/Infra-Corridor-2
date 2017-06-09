FF************************************************************************
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

************************
*** MERGE IN industry groups for regressions
************************
destring nic204, replace
merge m:1 nic204 using "$data2\ind_traits.dta"
drop if _merge==2
drop _merge


*******************COLLAPSE DATA
***************************************
***************************************************************************************************************************************************
foreach ind in land_bldg materials capital labor {
foreach gp in 0_25 25_50 50_75 25_75 75_100 50_100  {

preserve
keep if gp_`gp'_`ind' == 1

*******************COLLAPSE DATA
collapse (sum) plants  totalemployees  totaloutput new_emp new_estab new_out old_emp old_estab old_out Totalemployeeswagebill totalemployeestotalLcost (mean) lpdty_unwt, by (year survey districtname  state_CONSISTENT )

rename plants plant
rename totalemployees empt
rename totaloutput output
ren Totalemployeeswagebill totalwage
ren totalemployeestotalLcost totalcost

foreach stat in mean {
merge  m:1 year survey districtname  state_CONSISTENT using "$data\tfp_w_ind_`stat'_by survey.dta"
drop _merge

merge m:1  year survey districtname  state_CONSISTENT using  "$data\tfp_w_ind_`stat'_by survey_resid.dta"
drop _m

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

************************
*** MERGE IN POPULATION for regressions
************************
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

merge m:1 state_CON districtname using "$data2\district road railway data.dta"
drop if _m ==2
drop _m

***********************GQ variables
**********Noida is located in Gautam Budh Nagar district of Uttar Pradesh state 1997-09-06: Gautam Buddha Nagar district split from Bulandshahr. So the district containing the city of Noida should be called Bulandshahr in our data

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


# delimit;
drop state_ORIGINAL;
gen GQ_10_30=(dis_km_GQ2>10 & dis_km_GQ2<=30);
gen GQ_30_50=(dis_km_GQ2>30 & dis_km_GQ2<=50);
gen ldis_km_GQ=ln(dis_km_GQ);
replace ldis_km_GQ=1 if (ldis_km_GQ<1 | dis_km_GQ==.) & GQ_0_10==1;

*** Winsorize variables (note by year automatically) and  TFP already in unit sd;

for var new_estab* new_emp* new_out* plant* empt* output*:
\ replace X=. if X==0 \ gen temp2=X 
\ egen temp1=pctile(temp2), p(01) \ replace X=temp1 if X<temp1 | X==. \ drop temp1
\ egen temp1=pctile(temp2), p(99) \ replace X=temp1 if X>temp1 & X!=. \ drop temp*;
for var  lab_pdty* tfp_w_wins_mean* new_tfp_w_wins_mean* avg_wage* avg_cost*:
\ gen temp2=X  
\ egen temp1=pctile(temp2), p(01) \ replace X=temp1 if X<temp1 & X==. \ drop temp1
\ egen temp1=pctile(temp2), p(99) \ replace X=temp1 if X>temp1 & X!=. \ drop temp*;





*** Prepare differenced variables;
for any plant empt output new_emp new_estab new_out lab_pdty avg_wage avg_cost:
\ gen LD1X=ln((X2007+X2009)/(X1994+X2000))
\ gen LD2X=ln((X2007+X2009)/(2*X2000))
\ gen B1X=ln((X1994+X2000)/2)
\ gen B2X=ln(X2000);
for any tfp_w_wins_mean new_tfp_w_wins_mean:
\ gen LD1X=(X2007+X2009)-(X1994+X2000)
\ gen LD2X=X2007+X2009-2*X2000
\ gen B1X=(X1994+X2000)/2
\ gen B2X=X2000;


*** Final prep;
gen outlier=(district=="Bulandshahr" | district=="Nagar Hardwar"); 
gen wt=ln_totpop;
gen PctDis=PctSTribe+PctSCaste;
for any NH SH broad_double broad_single meter narrow: replace X=0 if X==.;
replace NH=1 if nodal_GQ==1 | GQ_0_10==1;
egen RR=rmax(broad_double broad_single); sum NH SH RR;
for var dis_nh dis_sh dis_railway: replace X=1 if X<1 \ replace X=ln(X);
for var Dem_Div SexRatio PctUrban PctDis Literacy infra: egen temp1=std(X) \ replace X=temp1 \ drop temp1;
# delimit cr


eststo clear 
estimates clear
foreach X in plant empt output new_estab new_emp new_out lab_pdty tfp_w_wins_mean new_tfp_w_wins_mean avg_wage avg_cost {
eststo: xi: regress LD2`X' nodal_GQ GQ_0_10 GQ_10_50 B2`X' [aw=wt] , vce(r)
esttab _all using "$OUTPUT\T9a_`gp'_`ind'.csv" ,replace se r2 ar2  star( + .1 ++ .05 +++ .01)  b(%9.3f) se(%9.3f) drop( B2`X'  _cons ) order(nodal_GQ GQ_0_10 GQ_10_50  )
}

eststo clear 
estimates clear
foreach X in plant empt output new_estab new_emp new_out lab_pdty tfp_w_wins_mean new_tfp_w_wins_mean avg_wage avg_cost {
eststo: xi: areg   LD2`X' nodal_GQ GQ_0_10 GQ_10_50 B2`X' NH SH RR ln_totpop Dem_Div SexRatio PctUrban PctDis Literacy infra [aw=wt] , absorb(state) vce(r)
esttab _all using "$OUTPUT\T9bs_`gp'_`ind'.csv" ,replace se r2 ar2  star( + .1 ++ .05 +++ .01)  b(%9.3f) se(%9.3f) drop( B2`X'  _cons  ) order(nodal_GQ GQ_0_10 GQ_10_50 NH SH RR ln_totpop Dem_Div SexRatio PctUrban PctDis Literacy infra_*  )
}
restore
}
}
