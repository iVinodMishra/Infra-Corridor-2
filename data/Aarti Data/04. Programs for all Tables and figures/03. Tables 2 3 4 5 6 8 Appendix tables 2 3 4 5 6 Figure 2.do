************************************************************************
***************Ghani - Goswami- Kerr -		 ***********************
***************Golden Quadrilateral Highways*******
***************Economic Journal, 2014 ******************
************************************************************************
global work "C:\Arti\"
global data "C:\Arti\EJ Programs\03. Final district level datasets"
global data1 "C:\Arti\EJ Programs\01. Data\Highway timing details"
global data2 "C:\Arti\EJ Programs\01. Data\Districts"
global data3 "C:\Arti\lenovo work\Bill Kerr\Highway Project\revise and resubmit\Final table set\programs\EJ Programs\01. Data\Maps and distances"

#delimit;
cap n log close; 
cd "C:\Arti\EJ Programs\03. Final district level datasets\";
global OUTPUT "C:\Arti\";
global work "C:\Arti\";

log using 130729-gq_1.log, replace; 

* Arti Grover Goswami;
* Last Modified: Aug 2014;

**clear all; *set mem 1g; *set matsize 2000; *set more off;

*****************************;
*** Des Features          ***;
*****************************;

*** Merge datasets;
*****************************;
*** Long Differences      ***;
*****************************;

*** Open data;
use 130730-arti-data-working_3, clear; des, full; sum; 
drop state_ORIGINAL;
*** Prepare distance measures;
*gen GQ_50_125=(dis_km_GQ2>50 & dis_km_GQ2<=125);
*gen GQ_125_200=(dis_km_GQ2>125 & dis_km_GQ2<=200);
gen GQ_10_30=(dis_km_GQ>10 & dis_km_GQ<=30);
gen GQ_30_50=(dis_km_GQ>30 & dis_km_GQ<=50);
gen ldis_km_GQ=ln(dis_km_GQ);
replace ldis_km_GQ=1 if (ldis_km_GQ<1 | dis_km_GQ==.) & GQ_0_10==1;

*** Winsorize variables (note by year automatically) and  TFP already in unit sd;
log off;
for var new_estab* new_emp* new_out*:
\ replace X=. if X==0 \ gen temp2=X 
\ egen temp1=pctile(temp2), p(01) \ replace X=temp1 if X<temp1 | X==. \ drop temp1
\ egen temp1=pctile(temp2), p(99) \ replace X=temp1 if X>temp1 & X!=. \ drop temp*;
for var plant* empt* output* lab_pdty* lpdty_unwt* tfp_w_wins_mean* new_tfp_w_wins_mean*  tfp_w_resid* new_tfp_w_resid* avg_wage* avg_cost*:
\ gen temp2=X  
\ egen temp1=pctile(temp2), p(01) \ replace X=temp1 if X<temp1 & X==. \ drop temp1
\ egen temp1=pctile(temp2), p(99) \ replace X=temp1 if X>temp1 & X!=. \ drop temp*;
log on;

foreach i in 1994 2000 2005 2007 2009 {;
replace lpdty_unwt`i' = ln(lpdty_unwt`i');
};

*** Prepare differenced variables;
log off;
for any plant empt output new_emp new_estab new_out lpdty_unwt lab_pdty avg_wage avg_cost:
\ gen LD1X=ln((X2007+X2009)/(X1994+X2000))
\ gen LD2X=ln((X2007+X2009)/(2*X2000))
\ gen B1X=ln((X1994+X2000)/2)
\ gen B2X=ln(X2000);
for any tfp_w_wins_mean_wt  tfp_w_wins_mean   tfp_w_resid_wt tfp_w_resid  new_tfp_w_wins_mean_wt new_tfp_w_wins_mean new_tfp_w_resid new_tfp_w_resid_wt :
\ gen LD1X=(X2007+X2009)-(X1994+X2000)
\ gen LD2X=X2007+X2009-2*X2000
\ gen B1X=(X1994+X2000)/2
\ gen B2X=X2000;

for any plant empt output :
\ gen y_LD1X=ln((X_age_7_y2007+X_age_9_y2009)/(X1994+X2000))
\ gen y_LD2X=ln((X_age_7_y2007+X_age_9_y2009)/(2*X2000));


for any plant empt output :
\ gen sh_LD1X=((sh_X_age_102007+sh_X_age_102009)/(sh_X_age_101994+sh_X_age_102000))
\ gen sh_LD2X=((sh_X_age_102007+sh_X_age_102009)/(2*sh_X_age_102000))
\ gen sh_B1X=((sh_X_age_101994+sh_X_age_102000)/2)
\ gen sh_B2X=(sh_X_age_102000);



log on;

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

***********************************************************************************************
*******************TABLE 2 and Appendix table 2
***********************************************************************************************
******************************************************************************************************************
*** Table 2 with indicators for NH-SH-RR;
* Robust to outlier==0;
* Robust to including travel time to nearest big city (but this likely includes GQ upgrades);
eststo clear 
estimates clear

foreach X in plant empt output new_estab new_emp new_out lab_pdty tfp_w_wins_mean avg_wage avg_cost {
 **************************************
 eststo: xi: regress LD2`X' nodal_GQ GQ_0_10 GQ_10_50 B2`X' [aw=wt] , vce(r)
esttab _all using "$OUTPUT\T2_A.csv" ,replace se r2 ar2   b(%9.3f) se(%9.3f) star( + .1 ++ .05 +++ .01) drop( B2`X'  _cons  ) order(nodal_GQ GQ_0_10 GQ_10_50  )
}

eststo clear 
estimates clear
foreach X in plant empt output new_estab new_emp new_out lab_pdty tfp_w_wins_mean   avg_wage avg_cost {
 eststo: xi: regress LD2`X' nodal_GQ GQ_0_10 GQ_10_50 B2`X' dis_nh dis_sh dis_railway ln_totpop Dem_Div SexRatio PctUrban PctDis Literacy infra  [aw=wt], vce(r)
esttab _all using "$OUTPUT\T2_B.csv" ,replace se r2 ar2   b(%9.3f) se(%9.3f) star( + .1 ++ .05 +++ .01) drop( B2`X'  _cons ) order(nodal_GQ GQ_0_10 GQ_10_50 dis_nh dis_sh dis_railway ln_totpop Dem_Div SexRatio PctUrban PctDis Literacy infra_*)
}

eststo clear 
estimates clear
foreach X in plant empt output new_estab new_emp new_out lab_pdty tfp_w_wins_mean   avg_wage avg_cost {
 eststo: xi: areg   LD2`X' nodal_GQ GQ_0_10 GQ_10_50 B2`X' dis_nh dis_sh dis_railway ln_totpop Dem_Div SexRatio PctUrban PctDis Literacy infra  [aw=wt], absorb(state) vce(r)
 esttab _all using "$OUTPUT\T2_C.csv" ,replace se r2 ar2   b(%9.3f) se(%9.3f) star( + .1 ++ .05 +++ .01) drop( B2`X'  _cons dis_nh dis_sh dis_railway ln_totpop Dem_Div SexRatio PctUrban PctDis Literacy infra_*  ) order(nodal_GQ GQ_0_10 GQ_10_50 )
}
 
 
 eststo clear 
estimates clear
foreach X in plant empt output new_estab new_emp new_out lab_pdty tfp_w_wins_mean   avg_wage avg_cost {
eststo: xi: regress LD2`X' nodal_GQ GQ_0_10_t1 GQ_0_10_t2 GQ_10_50 B2`X' dis_nh dis_sh dis_railway ln_totpop Dem_Div SexRatio PctUrban PctDis Literacy infra [aw=wt], vce(r)
 esttab _all using "$OUTPUT\T2_D.csv" ,replace se r2 ar2   b(%9.3f) se(%9.3f) star( + .1 ++ .05 +++ .01) drop( B2`X'  _cons dis_nh dis_sh dis_railway ln_totpop Dem_Div SexRatio PctUrban PctDis Literacy infra_*) order(nodal_GQ GQ_0_10_t1 GQ_0_10_t2  GQ_10_50  )
}
 

eststo clear 
estimates clear
foreach X in plant empt output new_estab new_emp new_out lab_pdty tfp_w_wins_mean   avg_wage avg_cost {
eststo: xi: regress LD2`X' nodal_GQ GQ_0_10 GQ_10_50 GQ_50_125 GQ_125_200 B2`X' dis_nh dis_sh dis_railway ln_totpop Dem_Div SexRatio PctUrban PctDis Literacy infra  [aw=wt], vce(r)
esttab _all using "$OUTPUT\T2_E.csv" ,replace se r2 ar2   b(%9.3f) se(%9.3f) star( + .1 ++ .05 +++ .01) drop( B2`X'  _cons dis_nh dis_sh dis_railway ln_totpop Dem_Div SexRatio PctUrban PctDis Literacy infra_*) order(nodal_GQ GQ_0_10 GQ_10_50 GQ_50_125 GQ_125_200 )
}
 ****************************************************************************************************************;
*** Appendix table 3;
****************************************************************************************************************;
* Need to add-in outlier groups;
* Continuous density approach is not working and should likely be dropped;
eststo clear 
estimates clear
foreach X in plant empt output new_estab new_emp new_out lab_pdty tfp_w_wins_mean   avg_wage avg_cost {
eststo: xi: regress LD2`X' nodal_GQ GQ_0_10 GQ_10_50 B2`X'  dis_nh dis_sh dis_railway ln_totpop Dem_Div SexRatio PctUrban PctDis Literacy infra  ,  vce(r)
esttab _all using "$OUTPUT\A3_A.csv" ,replace se r2 ar2   b(%9.3f) se(%9.3f) star( + .1 ++ .05 +++ .01) drop( B2`X'  _cons ) order(nodal_GQ GQ_0_10 GQ_10_50 dis_nh dis_sh dis_railway ln_totpop Dem_Div SexRatio PctUrban PctDis Literacy infra* )
}
eststo clear 
estimates clear
foreach X in plant empt output new_estab new_emp new_out lab_pdty tfp_w_wins_mean   avg_wage avg_cost {
eststo: xi: regress LD2`X' nodal_GQ GQ_0_10 B2`X'  dis_nh dis_sh dis_railway ln_totpop Dem_Div SexRatio PctUrban PctDis Literacy infra  [aw=wt] , vce(r)
esttab _all using "$OUTPUT\A3_B.csv" ,replace se r2 ar2   b(%9.3f) se(%9.3f) star( + .1 ++ .05 +++ .01) drop( B2`X'  _cons dis_nh dis_sh dis_railway ln_totpop Dem_Div SexRatio PctUrban PctDis Literacy infra_* ) order(nodal_GQ GQ_0_10  )
}
eststo clear 
estimates clear
foreach X in plant empt output new_estab new_emp new_out lab_pdty tfp_w_wins_mean   avg_wage avg_cost {
eststo: xi: regress LD2`X' nodal_GQ GQ_0_10 GQ_10_30 GQ_30_50 B2`X' dis_nh dis_sh dis_railway ln_totpop Dem_Div SexRatio PctUrban PctDis Literacy infra [aw=wt] , vce(r)
esttab _all using "$OUTPUT\A3_C.csv" ,replace se r2 ar2   b(%9.3f) se(%9.3f) star( + .1 ++ .05 +++ .01) drop( B2`X'  _cons dis_nh dis_sh dis_railway ln_totpop Dem_Div SexRatio PctUrban PctDis Literacy infra_* ) order(nodal_GQ GQ_0_10 GQ_10_30 GQ_30_50 )
}
eststo clear 
estimates clear
preserve
replace ldis_km_GQ = 0 if ldis_km_GQ==. & dis_km_GQ ==0
foreach X in plant empt output new_estab new_emp new_out lab_pdty tfp_w_wins_mean   avg_wage avg_cost {
eststo: xi: regress LD2`X' ldis_km_GQ B2`X' dis_nh dis_sh dis_railway ln_totpop Dem_Div SexRatio PctUrban PctDis Literacy infra [aw=wt] if (GQ_0_10==1 | GQ_10_50==1) , vce(r)
esttab _all using "$OUTPUT\A3_D.csv" ,replace se r2 ar2   b(%9.3f) se(%9.3f) star( + .1 ++ .05 +++ .01) drop( B2`X'  _cons dis_nh dis_sh dis_railway ln_totpop Dem_Div SexRatio PctUrban PctDis Literacy infra_* ) order(ldis_km_GQ )
}
restore

***************************
*****TABLE 3
***************************

eststo clear 
estimates clear
foreach X in plant empt output new_estab new_emp new_out lab_pdty tfp_w_wins_mean   avg_wage avg_cost {
eststo: xi: regress LD2`X' nodal_GQ GQ_0_10 GQ_10_50 nodal_NS_EW NS_EW_0_10_phI NS_EW_0_10_phII NS_EW_10_50 dis_nh dis_sh dis_railway ln_totpop Dem_Div SexRatio PctUrban PctDis Literacy infra  B2`X' [aw=wt], vce(r)
esttab _all using "$OUTPUT\T3.csv" ,replace se r2 ar2   b(%9.3f) se(%9.3f) star( + .1 ++ .05 +++ .01) drop( B2`X'  _cons ) order(nodal_GQ GQ_0_10 GQ_10_50 nodal_NS_EW NS_EW_0_10_phI NS_EW_0_10_phII NS_EW_10_50 )
}


********************************
***TABLE  4a
*******************************
merge m:1 state_CONSISTENT districtname using "$data3\dis_iv_rt1_edge.dta"
drop if _m ==2
drop _m

merge m:1 state_CONSISTENT districtname using "$data3\dis_iv_rt2_edge.dta"
drop if _m ==2
drop _m

merge m:1 state_CONSISTENT districtname using "$data3\dis_iv_EJ rev2.dta"
drop if _m ==2
drop _m

eststo clear 
estimates clear
foreach X in plant empt output new_estab new_emp new_out lab_pdty tfp_w_wins_mean   avg_wage avg_cost {
eststo: xi: regress LD2`X' GQ_0_10  B2`X' [aw=wt] if nodal_GQ==0, vce(r)
esttab _all using "$OUTPUT\T4a_A.csv" ,replace se r2 ar2   b(%9.3f) se(%9.3f) star( + .1 ++ .05 +++ .01) drop( B2`X'  _cons ) order(GQ_0_10)
}
foreach i in iv_rt1 iv_rt2 {
gen dum_`i' = 0
replace dum_`i' = 1 if dis_`i' <=10
label variable dum_`i' "Straight line distance less than 10km"
}

***********first stage:
foreach i in iv_rt1 iv_rt2 {
reg GQ_0_10 dum_`i'
}

eststo clear 
estimates clear
foreach i in iv_rt1 iv_rt2 {
foreach X in plant empt output new_estab new_emp new_out lab_pdty tfp_w_wins_mean   avg_wage avg_cost {
eststo: xi: regress LD2`X' dum_`i'  B2`X' [aw=wt] if nodal_GQ==0, vce(r)
esttab _all using "$OUTPUT\T4a_2_`i'B.csv" ,replace se r2 ar2   b(%9.3f) se(%9.3f) star( + .1 ++ .05 +++ .01) drop( B2`X'  _cons ) order(dum_`i' )
}
eststo clear 
estimates clear
}


eststo clear 
estimates clear
foreach i in iv_rt1 iv_rt2 {
foreach X in plant empt output new_estab new_emp new_out lab_pdty tfp_w_wins_mean   avg_wage avg_cost {
eststo: xi: ivregress 2sls LD2`X'   B2`X' (GQ_0_10 = dum_`i') [aw=wt] if nodal_GQ==0, vce(r)
*esttab _all using "$OUTPUT\T4_3_`i'1.csv" ,replace se r2 ar2   b(%9.3f) se(%9.3f) star( + .1 ++ .05 +++ .01) drop( B2`X'  _cons ) order(GQ_0_10 )
estat endogenous, forceweights
estadd scalar p_value = r(p_regF)
esttab _all using "$OUTPUT\T4a_3_`i'_C.csv" ,replace se r2 ar2   stats( p_value) se(%9.3f) star( + .1 ++ .05 +++ .01) drop( B2`X'  _cons `regvar1'  ) order(GQ_0_10 )

}
eststo clear 
estimates clear
}



****************************************************
***************TABLE 4b (WITH DISTRICT COVARIATE CONTROLS)
****************************************************
*******************************
local regvar "dis_nh dis_sh dis_railway ln_totpop Dem_Div SexRatio PctUrban PctDis Literacy infra_composite"
local regvar1 " ln_totpop Dem_Div SexRatio PctUrban PctDis Literacy infra_composite"

***********first stage:
foreach i in iv_rt1 iv_rt2 {
reg GQ_0_10 dum_`i' `regvar1'
}

eststo clear 
estimates clear 
eststo clear 
estimates clear
foreach X in plant empt output new_estab new_emp new_out lab_pdty tfp_w_wins_mean   avg_wage avg_cost {
eststo: xi: regress LD2`X' GQ_0_10  B2`X' `regvar1' [aw=wt] if nodal_GQ==0, vce(r)

esttab _all using "$OUTPUT\T4b_A.csv" ,replace se r2 ar2   b(%9.3f) se(%9.3f) star( + .1 ++ .05 +++ .01) drop( B2`X'  _cons `regvar1' ) order(GQ_0_10)
}

eststo clear 
estimates clear
foreach i in iv_rt1 iv_rt2 {
foreach X in plant empt output new_estab new_emp new_out lab_pdty tfp_w_wins_mean   avg_wage avg_cost {
eststo: xi: regress LD2`X' dum_`i'  B2`X' `regvar1' [aw=wt] if nodal_GQ==0, vce(r)
esttab _all using "$OUTPUT\T4b_`i'B.csv" ,replace se r2 ar2   b(%9.3f) se(%9.3f) star( + .1 ++ .05 +++ .01) drop( B2`X'  _cons `regvar1' ) order(dum_`i' )
}
eststo clear 
estimates clear
}



eststo clear 
estimates clear
local regvar "dis_nh dis_sh dis_railway ln_totpop Dem_Div SexRatio PctUrban PctDis Literacy infra_composite"
local regvar1 " ln_totpop Dem_Div SexRatio PctUrban PctDis Literacy infra_composite"
foreach i in iv_rt1 iv_rt2 {
foreach X in plant empt output new_estab new_emp new_out lab_pdty tfp_w_wins_mean   avg_wage avg_cost {
eststo: xi: ivregress 2sls LD2`X'   B2`X' `regvar1'  (GQ_0_10 = dum_`i') [aw=wt] if nodal_GQ==0, vce(r)
*esttab _all using "$OUTPUT\T4_3_`i'.csv" ,replace se r2 ar2   b(%9.3f) se(%9.3f) star( + .1 ++ .05 +++ .01) drop( B2`X'  _cons `regvar1'  ) order(GQ_0_10 )
estat endogenous, forceweights
estadd scalar p_value = r(p_regF)
esttab _all using "$OUTPUT\T4b_`i'C.csv" ,replace se r2 ar2   stats( p_value) se(%9.3f) star( + .1 ++ .05 +++ .01) drop( B2`X'  _cons `regvar1'  ) order(GQ_0_10 )
}
eststo clear 
estimates clear
}



************************************************************************
***************************************TABLE 6***********************************
********************************************************************


foreach X in plant empt output  {
foreach i in y_LD2 {
egen min_`i'`X' =min(`i'`X')
replace `i'`X' = min_`i'`X' if `i'`X'==.
}
}


eststo clear 
estimates clear
foreach X in plant empt output  {
 eststo: xi: regress y_LD2`X' nodal_GQ GQ_0_10 GQ_10_50 B2`X' dis_nh dis_sh dis_railway ln_totpop Dem_Div SexRatio PctUrban PctDis Literacy infra  [aw=wt], vce(r)
esttab _all using "$OUTPUT\T6_1.csv" ,replace se r2 ar2   b(%9.3f) se(%9.3f) star( + .1 ++ .05 +++ .01) drop( B2`X'  _cons ) order(nodal_GQ GQ_0_10 GQ_10_50 dis_nh dis_sh dis_railway ln_totpop Dem_Div SexRatio PctUrban PctDis Literacy infra_*)
}

eststo clear 
estimates clear
foreach X in plant empt output  {
 eststo: xi: regress sh_LD2`X' nodal_GQ GQ_0_10 GQ_10_50 sh_B2`X' dis_nh dis_sh dis_railway ln_totpop Dem_Div SexRatio PctUrban PctDis Literacy infra  [aw=wt], vce(r)
esttab _all using "$OUTPUT\T6_2.csv" ,replace se r2 ar2   b(%9.3f) se(%9.3f) star( + .1 ++ .05 +++ .01) drop( sh_B2`X'  _cons ) order(nodal_GQ GQ_0_10 GQ_10_50 dis_nh dis_sh dis_railway ln_totpop Dem_Div SexRatio PctUrban PctDis Literacy infra_*)
}




*************************************************************************************************************
********************************TABLE 8
*************************************************************************************************************
eststo clear 
estimates clear
foreach X in plant empt output new_estab new_emp new_out lab_pdty tfp_w_wins_mean   avg_wage avg_cost {
eststo: xi: regress LD2`X' GQ_0_10  B2`X' [aw=wt] if nodal_GQ==0 & (GQ_0_10 ==1 | GQ_10_50==1), vce(r)
esttab _all using "$OUTPUT\T8_A.csv" ,replace se r2 ar2   b(%9.3f) se(%9.3f) star( + .1 ++ .05 +++ .01) drop( B2`X'  _cons ) order(GQ_0_10)
}
*******************distance to nodal district
preserve
insheet using "$work\dis_nodal_city.csv", clear
ren state state_orig
g state = upper(state_orig)
g state_CONSISTENT = upper(state)
replace state_CONSISTENT = "UTTAR PRADESH" if state == "UTTARANCHAL"
replace state_CONSISTENT = "MADHYA PRADESH" if state == "CHHATTISGARH"
replace state_CONSISTENT = "BIHAR" if state == "JHARKHAND"

ren final districtname
*******currently taking mean of the distances with multiple district names,as before. but we could also do a min of the distances. for example mumbai's distance from the city center is measured as 1.2 km while from suburb is 24 km.
collapse (mean) dis_chennai dis_kolkata dis_delhi dis_mumbai , by(state_CONSISTENT  districtname)             

egen dis_nodal = rowmin(dis_chennai dis_kolkata dis_delhi dis_mumbai) 
g dis_n = dis_nodal/1000
egen dis_n_mean = mean(dis_n)

save "$work\dis_n_gps.dta", replace

restore


merge m:1 state_CONSISTENT districtname using "$data3\dis_n_gps.dta"
drop if _merge == 2
drop _merge

**************bring means from population census data 
preserve
use "$work\PopCensus District Indicators.dta", clear
egen infra_composite=rsum(PctVill_Telec PctVill_Power PctVill_Paved PctVill_SafeH2O)
keep PctUrban Literacy infra_composite districtname state_CONSISTENT
foreach var in PctUrban Literacy infra_composite {
egen  `var'_mean = mean(`var')
}
keep *_mean districtname state_CON
sort state_CON districtname 
tempfile demean
save `demean', replace
restore
************
merge m:1  state_CON districtname using `demean'
drop if _m==2
drop _m


foreach var in PctUrban dis_n Literacy infra_composite {
gen `var'_d = `var'-`var'_mean
drop `var'_mean
}

foreach i in PctUrban dis_n Literacy infra_composite GQ_0_10 {
egen `i'_std = std(`i')
egen `i'_med = median(`i')
gen `i'_above = 0
replace `i'_above = 1 if `i' >`i'_med & `i'!=.
gen `i'_below = 0
replace `i'_below = 1 if `i' <=`i'_med & `i'!=.
}

g ldis_n = ln(dis_n)
g ldis_n_std = ln(dis_n_std)

foreach var in PctUrban ldis_n Literacy infra_composite {
g GQ_0_10_`var' = 0
replace GQ_0_10_`var' = GQ_0_10_std*`var'_std
}


foreach var in PctUrban  Literacy infra_composite  {
g GQ_0_10_`var'_abo = 0
replace GQ_0_10_`var'_abo = GQ_0_10*`var'_above
g GQ_0_10_`var'_bel = 0
replace GQ_0_10_`var'_bel = GQ_0_10*`var'_below
}

g GQ_0_10_ldis_n_abo = 0
replace GQ_0_10_ldis_n_abo = GQ_0_10*dis_n_above
g GQ_0_10_ldis_n_bel = 0
replace GQ_0_10_ldis_n_bel = GQ_0_10*dis_n_below



foreach var in  PctUrban ldis_n Literacy infra_composite  {
eststo clear 
estimates clear
foreach X in plant empt output new_estab new_emp new_out lab_pdty tfp_w_wins_mean  avg_wage avg_cost {
eststo: xi: regress LD2`X' GQ_0_10_`var'_abo GQ_0_10_`var'_bel B2`X' [aw=wt] if nodal_GQ==0 & (GQ_0_10 ==1 | GQ_10_50==1), vce(r)
esttab _all using "$OUTPUT\T8_`var'_B C D E.csv" ,replace se r2 ar2   b(%9.3f) se(%9.3f) star( + .1 ++ .05 +++ .01) drop( B2`X'  _cons ) order(GQ_0_10_`var'_abo GQ_0_10_`var'_bel)
}
}

**************************************************************************************************
**************************Appendix table 4
************************************************************************************

eststo clear
estimates clear
foreach X in lab_pdty lpdty_unwt   tfp_w_wins_mean_wt  tfp_w_wins_mean   tfp_w_resid_wt tfp_w_resid  new_tfp_w_wins_mean_wt new_tfp_w_wins_mean new_tfp_w_resid new_tfp_w_resid_wt {
eststo: xi:regress LD2`X' nodal_GQ GQ_0_10 GQ_10_50 B2`X' [aw=wt],    vce(r)
esttab _all using "$OUTPUT\A4.csv" ,replace se r2 ar2   b(%9.3f) se(%9.3f) star( + .1 ++ .05 +++ .01)  drop( B2`X'  _cons  ) order(nodal_GQ GQ_0_10 GQ_10_50  )
}



*****************************;
*** Dynamic Estimations :
*****************************;

****************
#delimit;

*** Basic Prep for Entry Analysis;
use 130930-arti-data-working, clear; des, full; sum; 

keep state_CON district 
     plant* empt* output* new_estab* new_emp* new_out* lab_pdty* lpdty_unwt* tfp_* new_tfp_* avg_wage* avg_cost*   
     nodal_GQ GQ_* dis_km_GQ2 cons_time*
     ln_totpop;

*** Winsorize variables (note by year automatically) and place TFP into unit sd;
*log off;
for var new_estab* new_emp* new_out*:
\ gen RX=X
\ replace X=. if X==0 \ gen temp2=X 
\ egen temp1=pctile(temp2), p(01) \ replace X=temp1 if X<temp1 | X==. \ drop temp1
\ egen temp1=pctile(temp2), p(99) \ replace X=temp1 if X>temp1 & X!=. \ drop temp*;
for var plant* empt* output* lab_pdty* tfp_w_wins_mean* new_tfp_w_wins_mean* avg_wage* avg_cost*:
\ gen temp2=X  
\ egen temp1=pctile(temp2), p(01) \ replace X=temp1 if X<temp1 & X==. \ drop temp1
\ egen temp1=pctile(temp2), p(99) \ replace X=temp1 if X>temp1 & X!=. \ drop temp*;
*log on;

*** Catalogue extreme growth rates;
for any plant empt output new_emp new_estab new_out:
\ egen temp1=rmin(X1994 X1999 X2000 X2001 X2002 X2003 X2004 X2005 X2006 X2007 X2008 X2009) 
\ egen temp2=rmax(X1994 X1999 X2000 X2001 X2002 X2003 X2004 X2005 X2006 X2007 X2008 X2009) 
\ gen MZX=temp2/temp1 \ drop temp*;

drop plant_size* ;
*** Reshape file long;
reshape long plant empt output new_estab new_emp new_out Rnew_estab Rnew_emp Rnew_out lab_pdty lpdty_unwt tfp_w_wins_mean new_tfp_w_wins_mean tfp_w_wins_mean_wt new_tfp_w_wins_mean_wt  tfp_w_resid_wt new_tfp_w_resid_wt  tfp_w_resid new_tfp_w_resid avg_wage avg_cost, i(district state) j(year);
for var plant empt output new_estab new_emp new_out lab_pdty avg_wage avg_cost: replace X=ln(X);
egen dist=group(district state); gen wt=ln_totpop; drop if year==1989; xi i.year;

*
*** Create interactions for panel; 
for var GQ_0_10: 
\ gen PX=X*(year>=2005)
/*\ gen Q94X=X*(year==1994)*/
\ gen Q99X=X*(year==1999)
\ gen Q00X=X*(year==2000)
\ gen Q01X=X*(year==2001)
\ gen Q02X=X*(year==2002)
\ gen Q03X=X*(year==2003)
\ gen Q04X=X*(year==2004)
\ gen Q05X=X*(year==2005)
\ gen Q06X=X*(year==2006)
\ gen W00X=X*(year==2000)
\ gen W05X=X*(year==2005)
\ gen W07_09X=X*(year>=2007)
\ gen Q07X=X*(year==2007)
\ gen Q08X=X*(year==2008)
\ gen Q09X=X*(year==2009);



*** Capture outliers;
format MZ* %8.0f;
for var MZ*:
\ egen temp1=pctile(X), p(95)
\ tab district if X>=temp1, s(X)
\ drop temp1;
gen outlier=(district=="Bulandshahr" | district=="Nagar Hardwar");



# delimit cr

preserve
insheet using "$work\completion year.csv", clear
drop v5
drop month_year
ren  state_consistent state_CONSISTENT
tempfile tmp_cy
save `tmp_cy', replace
restore

merge  m:1 state_CONSISTENT districtname using `tmp_cy'
drop if _m ==2
drop _m

g age_completion = year-completion_year

g zero_cy = 0
replace zero_cy = 1 if  age_completion ==0

g one_cy = 0 
replace one_cy = 1 if  age_completion ==1

g two_cy = 0 
replace two_cy = 1 if  age_completion ==2

g three_cy = 0 
replace three_cy = 1 if  age_completion ==3

g four_cy = 0 
replace four_cy = 1 if  age_completion ==4

g five_cy = 0 
replace five_cy = 1 if  age_completion ==5

g six_cy = 0 
replace six_cy = 1 if  age_completion >=6

g one_bcy = 0 
replace one_bcy = 1 if  age_completion ==-1

g two_bcy = 0 
replace two_bcy = 1 if  age_completion ==-2

g three_bcy = 0 
replace three_bcy = 1 if  age_completion ==-3

*************************************************************************
*********************Table 5 and appendix table 6
*****************************************************************************

preserve
 keep if outlier==0 & (GQ_0_10==1 | GQ_10_50==1)

*** Dynamic Estimations;
global FE "i.year"
eststo clear 
estimates clear
foreach X in plant empt output new_estab new_emp new_out lab_pdty tfp_w_wins_mean new_tfp_w_wins_mean avg_wage avg_cost {
eststo: xi: areg `X' PGQ_0_10  $FE  [aw=wt] if nodal_GQ!=1 , a(dist) cl(dist)
esttab _all using "$OUTPUT\T5_A.csv" ,replace se r2 ar2   b(%9.3f) se(%9.3f) star( + .1 ++ .05 +++ .01) drop(   _cons) indicate( "Year FE = _Iyear*"    ) order(PGQ_0_10_cons_time1 PGQ_0_10_cons_time2 PGQ_0_10_cons_time3 )
}

foreach i in 1 2 3 {
gen PGQ_0_10_cons_time`i' = PGQ_0_10* cons_time`i'
replace PGQ_0_10_cons_time`i'  = 0 if PGQ_0_10_cons_time`i'  ==.
}

eststo clear 
estimates clear
foreach X in plant empt output new_estab new_emp new_out lab_pdty tfp_w_wins_mean new_tfp_w_wins_mean avg_wage avg_cost {
eststo: xi: areg `X' PGQ_0_10_cons_time1 PGQ_0_10_cons_time2 PGQ_0_10_cons_time3 $FE  [aw=wt] if nodal_GQ!=1 , a(dist) cl(dist)
esttab _all using "$OUTPUT\T5_B.csv" ,replace se r2 ar2   b(%9.3f) se(%9.3f) star( + .1 ++ .05 +++ .01) drop(   _cons) indicate( "Year FE = _Iyear*"    ) order(PGQ_0_10_cons_time1 PGQ_0_10_cons_time2 PGQ_0_10_cons_time3 )
}

eststo clear 
estimates clear
foreach X in plant empt output new_estab new_emp new_out lab_pdty tfp_w_wins_mean   avg_wage avg_cost {
eststo: xi: areg `X' Q* $FE  [aw=wt] if nodal_GQ!=1 , a(dist) cl(dist)
esttab _all using "$OUTPUT\T6a data.csv" ,replace se r2 ar2   b(%9.3f) se(%9.3f) star( + .1 ++ .05 +++ .01) drop(   _cons) indicate( "Year FE = _Iyear*"    ) order(Q* )
}

eststo clear 
estimates clear
foreach X in plant empt output new_estab new_emp new_out lab_pdty tfp_w_wins_mean   avg_wage avg_cost {
eststo: xi: areg `X' *_cy  three_bcy two_bcy one_bcy $FE  [aw=wt] if nodal_GQ!=1 , a(dist) cl(dist)
esttab _all using "$OUTPUT\A6b.csv" ,replace se r2 ar2   b(%9.3f) se(%9.3f) star( + .1 ++ .05 +++ .01) drop(   _cons) indicate( "Year FE = _Iyear*"    ) order( three_bcy two_bcy one_bcy *_cy )
}



#delimit;
eststo clear; 
estimates clear;

**********************************************************************;
*** Appendix table 5: Negative Binomial for Entry;
*************************************************************************************;
xtset dist year; set seed 1; xi i.dist i.year;

eststo clear;
estimates clear;
foreach i in plant empt Rnew_estab Rnew_emp {;
eststo: xi:cap n xtnbreg `i' PGQ_0_10 $FE, fe nolog irr vce(boot);
esttab _all using "$OUTPUT\A5.csv" ,replace se r2 ar2   eform b(%9.3f) se(%9.3f) star( + .1 ++ .05 +++ .01) drop(   _cons) indicate(   "Year FE = _Iyear*"    ) order(PGQ_0_10 );
};


restore;
# delimit cr
log close
