************************************************************************
***************Ghani - Goswami- Kerr -		 ***********************
***************Golden Quadrilateral Highways*******
***************Economic Journal, 2014 ******************
************************************************************************

use "C:\Arti\lenovo work\Bill Kerr\Data\ASI NSS old data\ASI&NSS\04. Intermediate Datasets\ASI_AppendedMaster_CleanFlagged.dta", clear
/***********************LIST OF FLAGS IN DATA
output_per_worker_flag
NSS_toobig_flag
emp_outlier_flag
services_flag
state_sample_flag
null_totalemployees_flag
no_totalemployees_flag
neg_totalemployees_flag
null_totaloutput_flag
no_totaloutput_flag
neg_totaloutput_flag
null_totalrawmaterials_flag
no_totalrawmaterials_flag
neg_totalrawmaterials_flag
null_totalfixedassets_flag
no_totalfixedassets_flag
neg_totalfixedassets_flag
high_output_flag
*/
**********************
g anyflg=0
foreach var of varlist *flag {
tab dataset `var'
replace anyflg=1 if `var'==1
}
tab dataset anyflg
drop if anyflg
drop anyflg
/*end code*/
tab state year, mi
tab state_ORIGINAL year, mi
rename state state_CONSISTENT
tostring district, replace


******************************************

replace state_ORIGINAL=state_CONSISTENT if state_ORIGINAL!="Jharkhand" & state_ORIGINAL!="JHARKHAND"& state_ORIGINAL!="CHHATISGARH" & state_ORIGINAL!="Chhattisgarh" & state_ORIGINAL!="UTTARANCHAL" & state_ORIGINAL!="Uttaranchal"
replace state_ORIGINAL=upper(state_ORIGINAL)
tab state_ORIGINAL year, mi
replace state_ORIGINAL="CHHATTISGARH" if state_ORIGINAL=="CHHATISGARH"
replace state_CONSISTENT="MADHYA PRADESH" if state_ORIGINAL=="CHHATTISGARH" & year>=2000
replace state_CONSISTENT="BIHAR" if state_ORIGINAL=="JHARKHAND" & year>=2000
replace state_CONSISTENT="UTTAR PRADESH" if state_ORIGINAL=="UTTARANCHAL" & year>=2000
tab state_ORIGINAL year, mi
tab state_CONSISTENT year, mi
destring year, replace
destring district, replace
replace district = 30 if state_ORIGINAL=="TAMIL NADU" & district==31 & year>=2005
replace district = 18 if state_ORIGINAL=="WEST BENGAL" & district==19 & year>=2005
replace district=1 if district==17 & state_ORIGINAL=="A & N ISLANDS"
g new_entrant=0
replace new_entrant=plants if under3==1
g new_plants_0_4=plants if fsize_7==0 & under3==1
g new_plants_5_9=plants if fsize_7==1 & under3==1
g new_plants_10_19=plants if fsize_7==2 & under3==1
g new_plants_20_39=plants if fsize_7==3 & under3==1
g new_plants_40_99=plants if fsize_7==4 & under3==1
g new_plants_100_plus=plants if (fsize_7==5 | fsize_7==6) & under3==1
g new_emp_0_4=totalemployees if fsize_7==0 & under3==1
g new_emp_5_9=totalemployees if fsize_7==1 & under3==1
g new_emp_10_19=totalemployees if fsize_7==2 & under3==1
g new_emp_20_39=totalemployees if fsize_7==3 & under3==1
g new_emp_40_99=totalemployees if fsize_7==4 & under3==1
g new_emp_100_plus=totalemployees if (fsize_7==5 | fsize_7==6) & under3==1
g plants_0_4=plants if fsize_7==0
g plants_5_9=plants if fsize_7==1
g plants_10_19=plants if fsize_7==2
g plants_20_39=plants if fsize_7==3
g plants_40_99=plants if fsize_7==4
g plants_100_plus=plants if (fsize_7==5 | fsize_7==6)
g emp_0_4=totalemployees if fsize_7==0
g emp_5_9=totalemployees if fsize_7==1
g emp_10_19=totalemployees if fsize_7==2
g emp_20_39=totalemployees if fsize_7==3
g emp_40_99=totalemployees if fsize_7==4
g emp_100_plus=totalemployees if (fsize_7==5 | fsize_7==6)
g direct_importer_plants=plants if rawmat_trade_tot>0 & !mi(rawmat_trade_tot)
destring nic304, replace
***THIS SHOULD BECOME IRRELEVANT
g dist_orig=district
replace district=1 if state_ORIGINAL=="DELHI"
merge m:1 state_ORIGINAL district year survey using "C:\Arti\lenovo work\Bill Kerr\Data\ASI NSS old data\ASI&NSS\04. Intermediate Datasets\District codes & names_nodup.dta"
tab state_ORIGINAL _merge, mi
tab state_ORIGINAL year if _m==1
tab state_ORIGINAL if _m==2
bysort state_ORIGINAL: tab district year if _m==1
bysort state_ORIGINAL: tab district if _m==2
drop if _m==2
replace district=999 if _m==1
replace districtname="Unknown" if _m==1
*drop if _m==1 & state_ORIGINAL!="DELHI"
drop _m
tab districtname year if state_ORIGINAL=="DELHI"
replace districtname ="Delhi" if state_ORIGINAL=="DELHI"
replace districtname ="Mumbai" if districtname=="Mumbai Suburban"
replace districtname=trim(districtname)
save "C:\Arti\lenovo work\Bill Kerr\Data\ASI NSS old data\ASI&NSS\analysis file_ASI_1989_2009.dta", replace

