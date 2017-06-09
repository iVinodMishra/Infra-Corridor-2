************************************************************************
***************Ghani - Goswami- Kerr -		 ***********************
***************Golden Quadrilateral Highways*******
***************Economic Journal, 2014 ******************
************************************************************************

clear
clear matrix
cap log close


global root "C:\Arti\lenovo work\Bill Kerr\Data\ASI 2007"
global work "C:\Arti\lenovo work\Bill Kerr\Data\ASI 2007"
global intdata "C:\Arti\lenovo work\Bill Kerr\Data\ASI 2007\"
global do "C:\Arti\lenovo work\Bill Kerr\Data\ASI 2007\"

foreach i in 1989 1994 1999 2001  2005 2007 2009 {
clear
insheet using "$do\`i'code.csv", clear
keep  statename staterocode subregion final district1code
rename statename state

	replace subregion=trim(subregion)
rename final district1name
	replace district1name=trim(district1name)

tostring staterocode , replace
replace staterocode =substr("000"+staterocode ,length("000"+staterocode )-2,3)	
	g statecode=substr(staterocode, 1,2)
	drop staterocode 

g year=`i'

keep year state statecode subregion district1name district1code
rename district1name districtname
rename district1code district


drop if districtname=="blank" & district==0 | district ==.
tab district, mi
tab districtname, mi
							assert district!=.
							assert districtname!=""

							
replace district=district*-1
tostring district, replace
replace district=substr("00"+district,length("00"+district)-1,2)	



	
if `i'==2005 {
	preserve
	keep state districtname subregion
	replace subregion="Plains Northern" if districtname=="Bans KanthaMahesana"
	replace subregion="Plains Northern" if districtname=="Sabar Kantha"
	replace subregion="Eastern" if subregion=="Plains Southern" & state=="Gujarat"
	replace subregion="Northern"	if districtname=="HoshiarpurPatialaRupnagar"
	replace subregion="Inland Eastern" if districtname=="BellaryChitradurgaDharwadShimoga"
	replace subregion="Southern" if districtname=="AllahabadBanda"
	duplicates drop
	duplicates drop state districtname, force

	tempfile master
	save `master'

	keep if state=="Uttaranchal" | state=="Jharkhand" | state=="Chhattisgarh"
	replace state="Madhya Pradesh" if state=="Chhattisgarh"
	replace state="Bihar" if state=="Jharkhand"
	replace state="Uttar Pradesh" if state=="Uttaranchal"
	append using `master'
	tempfile regionmerge
	save `regionmerge'	, replace
	restore
	}

drop subregion	

tempfile `i'
save ``i''



}
append using `2005'
append using `2007'
append using `2001'
append using `1994'
append using `1989'
append using `1999'

	duplicates drop 
	egen panel=group(state districtname)
	bysort panel year: g rank=_N
	tab rank
	

/* the regionmerge file somehow has duplicates in state and districtname, once the district name "HoshiarpurPatialaRupnagar" appears with subregion == "Northern" while in another instance it appears with subregion == "Southern" Not sure why this is happening and therefore, it not possible to merge the region merge file"  */

/**to bypass this, I save the file manually at this point by some name "tempo" and then open the region merge file, delete the duplicates and save it. Open the tempo file again and merge with the command below then */


merge m:1 state districtname using `regionmerge'
	assert _m!=1 | (state=="Mizoram" & districtname=="Lawngtlai")
	drop if _m==2
	drop _merge	
	

	
destring year, replace
destring district, replace
drop statecode panel rank


replace state=upper(state)
replace state="A & N ISLANDS" if state=="ANDAMAN & NICOBAR ISLANDS"

g survey="ASI"
count
replace year=2000 if year==2001


drop if state=="KARNATAKA" & year==2000
drop if state=="GUJARAT" & year==2000

tempfile temp2
save `temp2'
keep if (state=="KARNATAKA" & year==2005) | (state=="GUJARAT" & year==2005) |(state=="JHARKHAND" & year==2005)| (state=="CHHATTISGARH" & year==2005)| (state=="UTTARANCHAL" & year==2005) 
replace year=2000
append using `temp2'
tempfile temp
save `temp'

keep if (state=="MADHYA PRADESH" & year==2000 & district>=39)| (state=="BIHAR" & year==2000 & district>=28)| (state=="UTTAR PRADESH" & year==2000 & (district==68 | district==78 | district==79 | district==83))
replace state = "CHHATTISGARH" if state=="MADHYA PRADESH" 
replace state="JHARKHAND" if state=="BIHAR"
replace state="UTTARANCHAL" if state=="UTTAR PRADESH"
*append using `temp'
tempfile finalnss
save `finalnss'

use `temp', clear
replace survey="ASI"
duplicates drop state year district survey, force
bysort state year district survey: g rank=_N
tab rank 
assert rank==1
drop rank


tab district year if state=="KARNATAKA" 
tab district year if state=="GUJARAT" 
*****FOR ASI, APPLY 2005 DISTRICT CODING TO 2000 per OBSERVATION OF DATA VALUES IN THOSE STATES-YEARS: GUJARAT & KARNATAKA
drop if state=="KARNATAKA" & year==2000
drop if state=="GUJARAT" & year==2000
drop if state=="MADHYA PRADESH" & year==2000
drop if state=="MAHARASHTRA" & year==2000
drop if state=="NAGALAND" & year==2000
drop if state=="ORISSA" & year==2000
drop if state=="CHHATTISGARH" & year==2000
drop if state=="JHARKHAND" & year==2000
drop if state=="UTTARANCHAL" & year==2000

tempfile temp3
save `temp3'
keep if (state=="KARNATAKA" & year==2005) | (state=="GUJARAT" & year==2005) | (state=="MADHYA PRADESH" & year==2005) | (state=="MAHARASHTRA" & year==2005)| (state=="NAGALAND" & year==2005) | (state=="ORISSA" & year==2005)| (state=="JHARKHAND" & year==2005)| (state=="CHHATTISGARH" & year==2005) | (state=="UTTARANCHAL" & year==2005) 
replace year=2000
append using `temp3'

tab district year if state=="KARNATAKA" 
tab district year if state=="GUJARAT" 

duplicates drop state year district survey, force
bysort state year district survey: g rank=_N
tab rank 

assert rank==1
drop rank


count
append using `finalnss'
count

tab survey

rename state state_ORIGINAL

save "$work\District codes & names.dta", replace

duplicates drop state_ORIGINAL district year survey, force

save "$work\District codes & names_nodup.dta", replace


