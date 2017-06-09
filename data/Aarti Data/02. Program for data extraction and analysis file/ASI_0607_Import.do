************************************************************************
***************Ghani - Goswami- Kerr -		 ***********************
***************Golden Quadrilateral Highways*******
***************Economic Journal, 2014 ******************
************************************************************************


clear	
*set mem 900m, perm	
global work "C:\Arti\03. Working"	
global intdata "C:\Arti\04. Intermediate Datasets"	
global input "C:\Arti\Raw Data\ASI2001_02"	
		
	
#delim ;	
clear;	
qui infix	
year	1-2
str block	3-4
str dsl	5-10
str psl	11-15
str scheme	16-16
str industrycode	17-20
str industrycode5	21-25
str state	26-27
str district	28-29
str ruralurban	30-30
rosrocode	31-35
noofunits	36-38
status	39-40
noofmanufacturingdays	41-43
noofnonmanufacturingdays	44-46
totalnoofworkingdays	47-49
costofproduction	50-61
multiplier	62-70
extra	71-178
using "$input\asi07m.txt"	;
keep if block=="A"	;
drop year extra block	;
save "$work\tempA", replace	;
	
	
	
	
	
	
#delim ;	
clear;	
qui infix	
year	1-2
str block	3-4
str dsl	5-10
typeoforganisation	11-12
typeofownership	13-13
noofunits2	14-17	
unitsinstate	18-21	
yearofinitialprod	22-25	
accountingyearopening	26-34	
accountingyearclosing	35-43	
monthsofoperation	44-45	
computers	46-46	
floppy	47-47	
extra	48-178
using "$input\asi07m.txt"	;
keep if block=="B"	;
drop year extra block	;
save "$work\tempB", replace	;
	
	
	
	
#delim ;	
clear;	
qui infix	
year	1-2
str block	3-4
str dsl	5-10
slno	11-12
openinggross	13-24
addbyreval	25-36
addnew	37-48
deduction	49-60
closinggross	61-72
uptoyearbeg	73-84
providedyear	85-96
uptoyearend	97-108
openingnet	109-120
closingnet	121-132
extra1	133-144
extra	145-178
using "$input\asi07m.txt"	;
keep if block=="C"	;
drop extra extra1 year block		;
tostring slno, replace	;	
replace slno="land" if slno=="1"	;	
replace slno="building" if slno=="2"	;	
replace slno="plant_mach" if slno=="3"	;	
replace slno="transportequip" if slno=="4"	;	
replace slno="compequip" if slno=="5"	;	
replace slno="plollutctrl" if slno=="6"	;	
replace slno="otherFA" if slno=="7"	;	
drop if slno=="8"	;	
replace slno="totalcapitalwip" if slno=="9"	;	
replace slno="totalFA" if slno=="10"	;	
reshape wide openinggross-closingnet, i(dsl) j(slno) string	;	
save "$work\tempC", replace		;
		
	
#delim ;	
clear;	
qui infix	
year	1-2
str block	3-4
str dsl	5-10
slno	11-12
open	13-24
close	25-36
extra	37-178
using "$input\asi07m.txt"	;
keep if block=="D"	;
drop year extra block	;
tostring slno, replace	;
replace slno="rawmaterials" if slno=="1"	;
replace slno="fuellube" if slno=="2"	;
replace slno="sparesothers" if slno=="3"	;
drop if slno=="4"	;
replace slno="semifinished" if slno=="5"	;
replace slno="finishedgoods" if slno=="6"	;
replace slno="totalinventory" if slno=="7"	;
replace slno="cash" if slno=="8"	;
replace slno="sundrydebtors" if slno=="9"	;
replace slno="othercurrentasts" if slno=="10"	;
drop if slno=="11"	;
replace slno="sundrycreditors" if slno=="12"	;
replace slno="overdraftsetc" if slno=="13"	;
replace slno="othercurrentliab" if slno=="14"	;
drop if slno=="15"	;
replace slno="workingcapital" if slno=="16"	;
replace slno="outstandingloan" if slno=="17"	;
reshape wide open close, i(dsl) j(slno) string	;
save "$work\tempD", replace	;
	
		
	
#delim ;	
clear;	
qui infix	
year	1-2
str block	3-4
str dsl	5-10
slno	11-12
manufdays	13-20
nonmanufdays	21-28
totaldays	29-38
_avg	39-46
days_paid	47-56	
wagesandsalaries	57-68	
bonus	69-80	
contributiontopf	81-92	
welfareexpense	93-104	
extra	105-178	
using "$input\asi07m.txt"	;
keep if block=="E"	;
drop year extra block	;
tostring slno, replace	;
replace slno="men" if slno=="1"	;
replace slno="women" if slno=="2"	;
replace slno="children" if slno=="3"	;
drop if slno=="4"	;
replace slno="thrucontr" if slno=="5"	;
drop if slno=="6"	;
replace slno="supervstaff" if slno=="7"	;
replace slno="otheremployees" if slno=="8"	;
replace slno="unpaid" if slno=="9"	;
replace slno="totalEEs" if slno=="10"	;
drop if slno=="11"	;
drop if slno=="12"	;
reshape wide manufdays-welfareexp, i(dsl) j(slno) string	;
save "$work\tempE", replace	;
	
	
	
#delim ;	
clear;	
qui infix	
year	1-2
str block	3-4
str dsl	5-10
workdonebyothers	11-22
repairmaintbuilding	23-34
repairmaintmachinery	35-46
repairmaintothpol	47-58	
repairmaintothers	59-70	
operatingexpenses	71-82	
nonooperatingexpenses	83-94	
insurancecharges	95-106	
rentforpm	107-118	
totalotherexp	119-130	
rentforbuilding	131-142	
rentoflandetc	143-154	
interest	155-166	
purchesevalueofgoodssold	167-178
using "$input\asi07m.txt"	;
keep if block=="F"	;
drop year block	;
egen repairmainttotal=rowtotal(repairmaint*); drop repairmaintbuilding-repairmaintothers	;
save "$work\tempF", replace	;
	
	
#delim ;	
clear;	
qui infix	
year	1-2
str block	3-4
str dsl	5-10
workdoneforothers	11-22
varstockofsemifin	23-34
valueofelectricitysold	35-46
valueofownconstruction	47-58
balancegoodssold	59-70
rentreceived	71-82
totalotheroutput	83-94
rentrecvdbuilding	95-106
rentrecvdland	107-118
interestrecvd	119-130
salevaluegoodssold	131-142
extra	143-178
using "$input\asi07m.txt"	;
keep if block=="G"	;
drop year block extra	;
save "$work\tempG", replace	;
	
	
	
#delim ;	
clear;	
qui infix	
year	1-2
str block	3-4
str dsl	5-10
slno	11-12
itemcode	13-17
quantityunit	18-20
quantity	21-36
purchasevalue	37-48
rateperunit	49-63
extra1	64-178
using "$input\asi07m.txt"	;
keep if block=="H"	;
drop year block extra* quantityunit ;	
keep if slno <=10 | slno>=15 & slno<=22	;	
tostring slno, replace	;	
replace slno="electricitygenerated" if slno=="15"	;
replace slno="electricitypurchased" if slno=="16"	;	
replace slno="fuel" if slno=="17"	;	
replace slno="coal" if slno=="18"	;	
replace slno="othfuel" if slno=="19"	;	
replace slno="consstore" if slno=="20"	;	
replace slno="totalfuelelec" if slno=="21"	;	
replace slno="totalrawmaterials" if slno=="22"	;	
rename purchasevalue value	;
sort dsl slno itemcode rateperunit;
drop rateperunit;
duplicates drop dsl slno itemcode, force;
reshape wide itemcode value quantity, i(dsl) j(slno) string	;
rename  quantityelectricitypurchased electricitypurchased ;
rename  quantityelectricitygenerated electricitygenerated ;
egen electricityconsumed = rsum(electricitypurchased electricitygenerated), missing;


# delimit cr
egen t_pv = rsum(value1-value5), missing
forval i = 1/5 {
g pv_r_`i'1 =(value`i'/t_pv)*100 
}
egen pv_max1 = rmax(pv_r*)
g inputvalue_max = .
g inputqty_max = .
g inputitemcode_max =.

g pv_max = int(pv_max1)
forval i = 1/5 {
g pv_r_`i' = int(pv_r_`i'1)
}

replace inputvalue_max = value1 if pv_r_1 == pv_max
replace inputqty_max = quantity1 if pv_r_1 == pv_max
replace inputitemcode_max = itemcode1 if pv_r_1 == pv_max

forval i = 2/5 { 
replace inputvalue_max = value`i' if pv_r_`i' ==pv_max 
replace inputqty_max = quantity`i' if pv_r_`i' ==pv_max 
replace inputitemcode_max = itemcode`i' if pv_r_`i' ==pv_max 
}
drop *1 *2 *3 *4 *5
keep valuecoal valueconsstore electricitygenerated valueelectricitygenerated electricitypurchased valueelectricitypurchased valuefuel valueothfuel valuetotalfuelelec valuetotalrawmaterials electricityconsumed dsl  inputvalue_max inputqty_max inputitemcode_max
g inputprice_max = inputvalue_max/inputqty_max
save "$work\tempH", replace	
	
/*	
#delim ;	
clear;	
qui infix	
year	1-2
str block	3-4
str dsl	5-10
slno	11-12
quantity	13-24
value	25-36
extra	37-48
extra1	49-178
using "$input\asi07m.txt"	;
keep if block=="H1"	;
drop year block extra* ;
tostring slno, replace	;
replace slno="electricitygenerated" if slno=="1"	;
replace slno="electricityconsumed" if slno=="2"	;
drop if slno!="electricitygenerated" & slno!="electricityconsumed"	;
reshape wide quantity value, i(dsl) j(slno) string	;
save "$work\tempH1", replace	;
*/	
	
	
	
#delim ;	
clear;	
qui infix	
year	1-2
str block	3-4
str dsl	5-10
slno	11-12
itemcode	13-17
quantitycode	18-20
quantity	21-36
purchasevalue	37-48
extra	49-63
extra1	64-178
using "$input\asi07m.txt"	;
keep if block=="I"	;
drop year block extra* quantitycode 	;
keep if slno <=5 | slno==7;
rename purchasevalue value ;
reshape wide value itemcode quantity, i(dsl) j(slno) ;
# delimit cr

egen t_pv = rsum(value1-value5), missing
forval i = 1/5 {
g pv_r_`i'1 =(value`i'/t_pv)*100 
}
egen pv_max1 = rmax(pv_r*)
g for_inputvalue_max = .
g for_inputqty_max = .
g for_inputitemcode_max =.

g pv_max = int(pv_max1)
forval i = 1/5 {
g pv_r_`i' = int(pv_r_`i'1)
}


replace for_inputvalue_max = value1 if pv_r_1 == pv_max
replace for_inputqty_max = quantity1 if pv_r_1 == pv_max
replace for_inputitemcode_max = itemcode1 if pv_r_1 == pv_max

forval i = 2/5 { 
replace for_inputvalue_max = value`i' if pv_r_`i' ==pv_max 
replace for_inputqty_max = quantity`i' if pv_r_`i' ==pv_max 
replace for_inputitemcode_max = itemcode`i' if pv_r_`i' ==pv_max 
}
drop *1 *2 *3 *4 *5 
rensfix 7
drop t_pv pv_max
keep dsl value for_inputvalue_max for_inputqty_max for_inputitemcode_max
g for_inputprice_max = for_inputvalue_max/for_inputqty_max
rename value for_input_value	
save "$work\tempI", replace	
	
#delim ;	
clear;	
qui infix	
year	1-2
str block	3-4
str dsl	5-10
slno	11-12
itemcode	13-17
quantityunit	18-20
qtymanufactured	21-36
qtysold	37-52
grosssalevalue	53-64
exciseduty	65-76
saletax	77-88
distexpensesother	89-100
distexpensestotal	101-112
itemwisensvunit	113-127
itemwiseexactvalue	128-139
extra	140-178
using "$input\asi07m.txt"	;
keep if block=="J"	;
drop year block extra  itemwisensvunit	;
# delimit cr

tostring slno, replace	
reshape wide itemcode-itemwiseexactvalue, i(dsl) j(slno) string
egen t_gsv = rsum(grosssalevalue1-grosssalevalue10), missing
forval i = 1/10 {
g gsv_r_`i'1 =(grosssalevalue`i'/t_gsv)*100 
}
egen gsv_max1 = rmax(gsv_r*)
g value_max = .
g qty_max = .
g itemcode_max =.

g gsv_max = int(gsv_max1)
forval i = 1/10 {
g gsv_r_`i' = int(gsv_r_`i'1)
}


replace value_max = grosssalevalue1 if gsv_r_1 == gsv_max
replace qty_max = qtysold1 if gsv_r_1 == gsv_max
replace itemcode_max = itemcode1 if gsv_r_1 == gsv_max


forval i = 2/10 { 
replace value_max = grosssalevalue`i' if gsv_r_`i' ==gsv_max 
replace qty_max = qtysold`i' if gsv_r_`i' ==gsv_max 
replace itemcode_max = itemcode`i' if gsv_r_`i' ==gsv_max 
}

keep *_max dsl *12 
rensfix 12
g price_max = value_max/qty_max
drop itemcode quantityunit qtymanufactured qtysold 
save "$work\tempJ", replace	



#delim ;		
clear;
use "$work\tempA", clear ;
merge dsl using 
"$work\tempB" 
"$work\tempC" 
"$work\tempD" 
"$work\tempE" 
"$work\tempF" 
"$work\tempG" 
"$work\tempH" 
"$work\tempH1" 
"$work\tempI" 
"$work\tempJ"
, unique sort;

drop _merg*;



***Fix States;
# delim ;
destring state, replace;
lab def state
28 "ANDHRA PRADESH"
12 "ARUNCHAL PRADESH"
18 "ASSAM"
10 "BIHAR"
30 "GOA"
24 "GUJARAT"
6 "HARYANA"
2 "HIMACHAL PRADESH"
1 "JAMMU & KASHMIR"
29 "KARNATAKA"
32 "KERALA"
23 "MADHYA PRADESH"
27 "MAHARASHTRA"
14 "MANIPUR"
17 "MEGHALAYA"
15 "MIZORAM"
13 "NAGALAND"
21 "ORISSA"
3 "PUNJAB"
8 "RAJASTHAN"
11 "SIKKAM"
33 "TAMIL NADU"
16 "TRIPURA"
9 "UTTAR PRADESH"
19 "WEST BENGAL"
35 "ANDAMAN AND NICOBAR ISLANDS"
4 "CHANDIGARH"
26 "DADRA  AND  NAGAR  HAVELI"
25 "DAMAN  &  DIU "
7 "DELHI"
31 "LAKSHADEEP"
34 "PONDICHERRY"
20 "JHARKHAND"
22 "CHHATISGARH"
5 "UTTARANCHAL"
, modify;
lab val state state;
decode state, g(state2);
drop state;
rename state2 state;
tab state, mi;

***Code Ownership Organization and others;

tab typeoforganisation, mi;
# delim ;
destring typeoforganisation, replace;
lab def typeoforganisation
1 "Individual Proprietorship"
2 "Joint  Family (HUF)"
3 "Partnership"
4 "Public  Limited  Company"
5 "Private Limited  Company  "
6 "Government departmental  enterprises"
7 "Public Corporation  by  special Act of Parliament  or State Legislature"
8 "Khadi & Village Industries Commission"
9 "Handlooms"
10 "Co-Operative Society"
19 "Others  (including  trusts, wakf,  boards etc.)"
;
lab val typeoforganisation typeoforganisation;
decode typeoforganisation, g(typeoforganisation2);
drop typeoforganisation;
rename typeoforganisation2 typeoforganisation;


tab typeofownership, mi;
# delim ;
destring typeofownership, replace;
lab def typeofownership
1 "Wholly Central Government"
2 "Wholly State and/or Local Government "
3 "Central  Government and State and/or Local  Government jointly "
4 "Joint  Sector Public"
5 "Joint  Sector  Private  "
6 "Wholly  private  Ownership"
;
lab val typeofownership typeofownership;
decode typeofownership, g(typeofownership2);
drop typeofownership;
rename typeofownership2 typeofownership;


g uniqid=dsl;
drop if psl =="";
g year=2006;
rename valueelectricityconsumed valueofelectricityconsumed;
save "$intdata\ASI0607_clean", replace;
