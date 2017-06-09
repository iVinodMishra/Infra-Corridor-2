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
*****************************manipulations of tfp before using 
drop if year ==1999 | year ==1989
*************************WINSORIZING
g VA_1 = totaloutput-totalrawmaterials 
drop if VA_1<0
drop if districtname == "Unknown"

keep if reg_sample == 1
preserve
collapse (mean) wt_avg_tfp_ind_yr = tfp  [w=emp], by(nic204 year survey)
sort nic204 year survey
tempfile tmp_wt_avg
save `tmp_wt_avg', replace
restore
sort nic204 year survey
merge nic204 year survey using `tmp_wt_avg'
drop if _m==2
drop _m

bysort nic204 year survey: egen average_tfp_ind_yr = mean(tfp) 
g normal_tfp_unwt = tfp/average_tfp_ind_yr
************replace above with g "normal_tfp" if want unweighted tfp mean by industry and year.

g normal_tfp = tfp/wt_avg_tfp_ind_yr

g age_9 = 0
 replace age_9 =1 if age>=9
 g age_7 =0
 replace age_7 = 1 if age>=7
 
merge  m:1 state_CONSISTENT districtname  using "$data1\GQ_dist_min_max.dta"
keep if _m==3
drop _merge
ren mean_dis_km dis_km_GQ 
 
g nodal_GQ = 0
replace nodal = 1 if districtname == "Delhi" | districtname == "Mumbai" | districtname == "Bulandshahr" | districtname == "Gurgaon" | districtname == "Faridabad" | districtname == "Thane" |   districtname == "Kolkata" | districtname == "Chennai" | districtname == "Ghaziabad" 


drop if dis_km_GQ == .

foreach hi in GQ  {


g `hi'_0_10 = 0
replace `hi'_0_10 = 1 if dis_km_`hi' <=10 & dis_km_`hi' >=0 & nodal_`hi' !=1
replace `hi'_0_10 = .  if dis_km_`hi' ==.

g `hi'_10_50 = 0
replace `hi'_10_50 = 1 if dis_km_`hi' <=50 & dis_km_`hi' >10 & nodal_`hi' !=1
replace `hi'_10_50 = . if dis_km_`hi' ==.

g `hi'_50 = 0
replace `hi'_50 = 1 if dis_km_`hi' >50 & nodal_`hi' !=1
replace `hi'_50 = . if dis_km_`hi'==.

g `hi'_50_125 = 0
replace `hi'_50_125 = 1 if dis_km_`hi' >50 & nodal_`hi' !=1 & dis_km_`hi' <=125 
replace `hi'_50_125 = . if dis_km_`hi'==.

g `hi'_125_200 = 0
replace `hi'_125_200 = 1 if dis_km_`hi' >125 & nodal_`hi' !=1 & dis_km_`hi' <=200
replace `hi'_125_200 = . if dis_km_`hi'==.

g `hi'_200 = 0
replace `hi'_200 = 1 if dis_km_`hi' >200 & nodal_`hi' !=1
replace `hi'_200 = . if dis_km_`hi'==.
}

keep if survey =="ASI"
drop survey
preserve
collapse  (mean) wt_normal_tfp =normal_tfp [w=emp], by (year nodal_GQ GQ_0_10 GQ_10_50 GQ_50  )
keep if year ==2000 | year>=2007
gsort year -nodal_GQ -GQ_0_10 -GQ_10_50 -GQ_50
xmlsave "$work\prod_wt_GQ_50.xml", doctype(excel) replace 
restore

preserve
collapse (mean) normal_tfp, by (year nodal_GQ GQ_0_10 GQ_10_50 GQ_50 )
keep if year ==2000 | year>=2007
gsort year -nodal_GQ -GQ_0_10 -GQ_10_50 -GQ_50
xmlsave "$work\prod_GQ_50.xml", doctype(excel) replace 
restore

preserve
collapse  (mean) wt_normal_tfp =normal_tfp [w=emp], by (year nodal_GQ GQ_0_10 GQ_10_50 GQ_50_125 GQ_125_200  GQ_200   )
keep if year ==2000 | year>=2007
gsort year -nodal_GQ -GQ_0_10 -GQ_10_50 -GQ_50_125 -GQ_125_200  -GQ_200
xmlsave "$work\prod_wt_GQ_200.xml", doctype(excel) replace 
restore

preserve
collapse (mean) normal_tfp, by (year nodal_GQ GQ_0_10 GQ_10_50 GQ_50_125 GQ_125_200  GQ_200 )
keep if year ==2000 | year>=2007
gsort year -nodal_GQ -GQ_0_10 -GQ_10_50 -GQ_50_125 -GQ_125_200  -GQ_200
xmlsave "$work\prod_GQ_200.xml", doctype(excel) replace 
restore



foreach i in 0  1 {

preserve
keep if (age_7 ==`i' & year ==2007) | (age_9 ==`i' & year ==2009) 
collapse  (mean) wt_normal_tfp =normal_tfp [w=emp], by ( nodal_GQ GQ_0_10 GQ_10_50 GQ_50  )
gsort  -nodal_GQ -GQ_0_10 -GQ_10_50 -GQ_50
xmlsave "$work\prod_wt_GQ_50_`i'.xml", doctype(excel) replace 
restore

preserve
keep if (age_7 ==`i' & year ==2007) | (age_9 ==`i' & year ==2009)
collapse (mean) normal_tfp, by ( nodal_GQ GQ_0_10 GQ_10_50 GQ_50 )
gsort  -nodal_GQ -GQ_0_10 -GQ_10_50 -GQ_50
xmlsave "$work\prod_GQ_50_`i'.xml", doctype(excel) replace 
restore

preserve
keep if (age_7 ==`i' & year ==2007) | (age_9 ==`i' & year ==2009)
collapse  (mean) wt_normal_tfp =normal_tfp [w=emp], by ( nodal_GQ GQ_0_10 GQ_10_50 GQ_50_125 GQ_125_200  GQ_200   )
gsort  -nodal_GQ -GQ_0_10 -GQ_10_50 -GQ_50_125 -GQ_125_200  -GQ_200
xmlsave "$work\prod_wt_GQ_200_`i'.xml", doctype(excel) replace 
restore

preserve
keep if (age_7 ==`i' & year ==2007) | (age_9 ==`i' & year ==2009)
collapse (mean) normal_tfp, by ( nodal_GQ GQ_0_10 GQ_10_50 GQ_50_125 GQ_125_200  GQ_200 )
gsort  -nodal_GQ -GQ_0_10 -GQ_10_50 -GQ_50_125 -GQ_125_200  -GQ_200
xmlsave "$work\prod_GQ_200_`i'.xml", doctype(excel) replace 
restore
}

