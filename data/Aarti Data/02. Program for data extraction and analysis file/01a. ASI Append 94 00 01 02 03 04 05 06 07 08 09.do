************************************************************************
***************Ghani - Goswami- Kerr -		 ***********************
***************Golden Quadrilateral Highways*******
***************Economic Journal, 2014 ******************
************************************************************************

clear	
clear matrix
cap log close
set mem 900m, perm	
global work "C:\Arti\lenovo work\Bill Kerr\Data\ASI NSS old data\ASI&NSS\03. Working"	
global intdata "C:\Arti\lenovo work\Bill Kerr\Data\ASI NSS old data\ASI&NSS\04. Intermediate Datasets"	
global input "C:\Projects\Industrial Data\India\01. Data\ASI\ASI2000_01\"	
global do "C:\Projects\Industrial Data\India\02. Programs\ASI\"	



****APPEND 8990 & 9495
use "$intdata\ASI8990_clean", clear
append using "$intdata\ASI9495_clean"
g district=substr(statedist,length(statedist)-1,2)
tostring ruralurban, replace

drop batch


rename runningslno dsl
drop recordcategory
drop linkcode

rename permanentslno psl

drop fodregioncode

drop backwardareacode
rename openclosedcode status
rename outstandingloanclose closeoutstandingloan
rename menmanufdays manufdaysmen
rename womenmanufdays manufdayswomen
rename childrenmanufdays manufdayschildren
rename thrucontrmanufdays manufdaysthrucontr
rename supervstaffmanufdays manufdayssupervstaff
rename otheremployeesmanufdays manufdaysotheremployees
rename totalEEsmanufdays manufdaystotalEEs
rename mennonmanufdays nonmanufdaysmen
rename womennonmanufdays nonmanufdayswomen
rename childrennonmanufdays nonmanufdayschildren
rename thrucontrnonmanufdays nonmanufdaysthrucontr
rename supervstaffnonmanufdays nonmanufdayssupervstaff
rename otheremployeesnonmanufdays nonmanufdaysotheremployees
rename totalEEsnonmanufdays nonmanufdaystotalEEs
rename mentotaldays totaldaysmen
rename womentotaldays totaldayswomen
rename childrentotaldays totaldayschildren
rename thrucontrtotaldays totaldaysthrucontr
rename supervstafftotaldays totaldayssupervstaff
rename otheremployeestotaldays totaldaysotheremployees
rename totalEEstotaldays totaldaystotalEEs
rename men_avg _avgmen
rename women_avg _avgwomen
rename children_avg _avgchildren
rename thrucontr_avg _avgthrucontr
rename supervstaff_avg _avgsupervstaff
rename otheremployees_avg _avgotheremployees
rename gproprietors_avg _avggproprietors
rename unpaidEE_avg _avgunpaidEE
rename ifcoop_avg _avgifcoop
rename totalEE_avg _avgtotalEEs
rename wagesandsalariesEEs wagesandsalariestotalEEs
rename bonusEEs bonustotalEEs
rename contributiontopfEEs contributiontopftotalEEs
rename welfareexpenseEEs welfareexpensetotalEEs
rename totallabourcostEEs totallabourcosttotalEEs
rename wagessupervisory wagesandsalariessupervstaff
rename bonussupervisory bonussupervstaff
rename contribsupervisory contributiontopfsupervstaff
rename welfareexpsupervisory welfareexpensesupervstaff
*rename qtyelectricitypurch 
rename valueelectricitypurch valueelectricitypurchased
****94-95 survey does not have value of electricity generated***
ren qtytotalimportedmaterials importedqty 
drop if year ==1989


# delim ;
keep
uniqid
yearofinitialprod
state
district
ruralurban
industry*
noofunits
status
noofmanufacturingdays
totalnoofworkingdays
/*totalnoofshifts
lengthofshifts */
monthsofoperation 
typeoforganisation
typeofownership
year
multiplier

closeoutstandingloan
interest

valueofelectricitysold
valueelectricitypurchased
electricitygenerated
electricitypurchased
electricityconsumed
valueofelectricityconsumed
inputvalue_max	
inputqty_max	
inputitemcode_max	
inputprice_max	
for_input_value	
for_inputvalue_max	
for_inputqty_max	
for_inputitemcode_max	
for_inputprice_max
value_max	
qty_max	
itemcode_max	
price_max
				
rentforpm	
totalotherexp		
rentforbuilding	
rentoflandetc

	

/*totalrent*/

_avgmen
_avgwomen
_avgmen _avgwomen _avgchildren _avgthrucontr _avgsupervstaff _avgotheremployees /*_avggproprietors*/ _avgtotalEE

/*_avgunpaidEE*/

wagesandsalariestotalEEs


totallabourcosttotal
closingnetland
closingnetbuilding
itemwiseexactvalue
grosssalevalue
valuetotalrawmaterials
totallabourcosttotal
closingnettotalFA
closingnettotalFA openingnettotalFA
/*valuetotalimportedmaterials*/
;


# delim ;	
	
	
rename yearofinitialprod startyear	;
	
	
	
	
rename noofunits plants	;
	
rename noofmanufacturingdays manufdays	;
rename totalnoofworkingdays workingdays	;
*rename totalnoofshifts noofshifts	;
*rename lengthofshifts lengthshifts	;
rename typeoforganisation organization	;
rename typeofownership ownership	;
rename  monthsofoperation monthsops;

	
	
	
rename closeoutstandingloan loanamount	;
rename interest interestamount	;
	
/*rename electricitypurchased electricityexpense	;
*rename electricitygenerated ownelectricitygenerated	;
	*/
*rename totalrent totalFArent	;
	
rename _avgmen Memployees	;
rename _avgwomen Femployees	;
rename _avgtotalEE totalemployees	;
*rename _avgunpaidEE TOTOTHEE ;
rename wagesandsalariestotalEEs Totalemployeeswagebill	;
rename totallabourcosttotal totalemployeestotalLcost	;
	
rename itemwiseexactvalue totaloutput	;
rename grosssalevalue totalsales	;
rename valuetotalrawmaterials totalrawmaterials	;
g fixedcapitalformation= closingnettotalFA-openingnettotalFA	;
rename closingnettotalFA totalfixedassets	;
*rename valuetotalimportedmaterials totalimports	;

*replace industrycode5=substr("00000"+industrycode5,length("00000"+industrycode5)-4,5);
*replace industrycode=substr(industrycode5,1,4) if industrycode=="9999" & year>=1999 ;
*drop industrycode5; 

# delim cr
log using "$work\var inspection.txt", t replace

ds, has(type numeric)
foreach var in `r(varlist)' {
	dis "`var'"
	tab year if `var'==.
	bysort year: sum `var', d
}

log c

ds, has(type string)
foreach var in `r(varlist)' {
	dis "`var'"
	tab year if `var'==""
}


***figure out open-closeds---& drop closedddd
destring ruralurban, replace
replace ruralurban=2 if ruralurban==3
replace ruralurban=ruralurban-1
tab ruralurban
replace ruralurban=. if ruralurban<0 | ruralurban>2

keep if (status==0 & (year==1989 | year==1994)) | (status==1 & (year>=1999))


drop  openingnettotalFA _avgchildren _avgotheremployees _avgsupervstaff _avgthrucontr status manufdays workingdays /* noofshifts lengthshifts  _avggproprietors */


save "$intdata\ASI9495.dta", replace


*******2000-01
use "$intdata\ASI0001_clean", clear

***********1999-00

append using "$intdata\ASI9900_clean"

***************2001-02, 02-03, 03-04, 04-05, 05-06, 06-07, 07-08 08-09
append using "$intdata\ASI0102_clean"
append using "$intdata\ASI0203_clean"
append using "$intdata\ASI0304_clean"
append using "$intdata\ASI0405_clean"

append using "$intdata\ASI0506_clean"

append using "$intdata\ASI0607_clean"

append using "$intdata\ASI0708_clean"

append using "$intdata\ASI0809_clean"

***********2009-10

append using "$intdata\ASI0910_clean"

# delim ;
keep
uniqid
yearofinitialprod
state
district
ruralurban
industry*
noofunits
status
noofmanufacturingdays
totalnoofworkingdays
/*totalnoofshifts
lengthofshifts */
monthsofoperation 
typeoforganisation
typeofownership
year
multiplier

closeoutstandingloan
interest

valueofelectricitysold
valueelectricitypurchased
electricitygenerated
electricitypurchased
electricityconsumed
valueofelectricityconsumed
inputvalue_max	
inputqty_max	
inputitemcode_max	
inputprice_max	
for_input_value	
for_inputvalue_max	
for_inputqty_max	
for_inputitemcode_max	
for_inputprice_max
value_max	
qty_max	
itemcode_max	
price_max
				
rentforpm	
totalotherexp		
rentforbuilding	
rentoflandetc

	

/*totalrent*/

_avgmen
_avgwomen
_avgmen _avgwomen _avgchildren _avgthrucontr _avgsupervstaff _avgotheremployees /*_avggproprietors*/ _avgtotalEE

/*_avgunpaidEE*/

wagesandsalariestotalEEs
closingnetland
closingnetbuilding
itemwiseexactvalue
grosssalevalue
valuetotalrawmaterials
closingnettotalFA
closingnettotalFA openingnettotalFA
bonustotalEEs  
contributiontopftotalEEs 
welfareexpensetotalEEs
/*valuetotalimportedmaterials*/
;


# delim ;	
	
	
rename yearofinitialprod startyear	;
egen totallabourcosttotal=rowtotal(wagesandsalariestotalEEs bonustotalEEs  contributiontopftotalEEs welfareexpensetotalEEs);
drop  bonustotalEEs  contributiontopftotalEEs welfareexpensetotalEEs;
rename noofunits plants	;
rename noofmanufacturingdays manufdays	;
rename totalnoofworkingdays workingdays	;
*rename totalnoofshifts noofshifts	;
*rename lengthofshifts lengthshifts	;
rename typeoforganisation organization	;
rename typeofownership ownership	;
rename  monthsofoperation monthsops;

	
	
	
rename closeoutstandingloan loanamount	;
rename interest interestamount	;
	
/*rename electricitypurchased electricityexpense	;
*rename electricitygenerated ownelectricitygenerated	;
	*/
*rename totalrent totalFArent	;
	
rename _avgmen Memployees	;
rename _avgwomen Femployees	;
rename _avgtotalEE totalemployees	;
*rename _avgunpaidEE TOTOTHEE ;
rename wagesandsalariestotalEEs Totalemployeeswagebill	;
rename totallabourcosttotal totalemployeestotalLcost	;
	
rename itemwiseexactvalue totaloutput	;
rename grosssalevalue totalsales	;
rename valuetotalrawmaterials totalrawmaterials	;
g fixedcapitalformation= closingnettotalFA-openingnettotalFA	;
rename closingnettotalFA totalfixedassets	;
*rename valuetotalimportedmaterials totalimports	;

replace industrycode5=substr("00000"+industrycode5,length("00000"+industrycode5)-4,5);
replace industrycode=substr(industrycode5,1,4) if industrycode=="9999" & year>=1999 ;
*drop industrycode5; 

# delim cr
log using "$work\var inspection.txt", t replace

ds, has(type numeric)
foreach var in `r(varlist)' {
	dis "`var'"
	tab year if `var'==.
	bysort year: sum `var', d
}

log c

ds, has(type string)
foreach var in `r(varlist)' {
	dis "`var'"
	tab year if `var'==""
}


***figure out open-closeds---& drop closedddd
destring ruralurban, replace
replace ruralurban=2 if ruralurban==3
replace ruralurban=ruralurban-1
tab ruralurban
replace ruralurban=. if ruralurban<0 | ruralurban>2

keep if (status==0 & (year==1989 | year==1994)) | (status==1 & (year>=1999))


drop  openingnettotalFA _avgchildren _avgotheremployees _avgsupervstaff _avgthrucontr status manufdays workingdays /* noofshifts lengthshifts  _avggproprietors */

append using "$intdata\ASI9495.dta"


g survey="ASI"

save "$intdata\ASI_Allyears_Clean.dta", replace
