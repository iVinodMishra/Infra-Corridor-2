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
str year		1-2 ///
str block		3-4 ///
str dsl			5-10 ///
str psl			11-15 ///
str scheme		16 ///
str industrycode		17-20 ///
str industrycode5		21-25 ///
str state		26-27 ///
str district		28-29 ///
str ruralurban		30 ///
rosrocode		31-35 ///
noofunits 		36-38 ///
status		39-40 ///
bonus		41-54 ///		
contributiontopf		55-68 ///
welfareexpense	69-82 ///		
noofmanufacturingdays		83-85 ///
noofnonmanufacturingdays 	86-88 ///
totalnoofworkingdays  	89-91 ///
costofproduction		92-103 ///
export_share	104-106 ///
multiplier		107-115 ///
extra		116-178 ///
using "$input\asi10m.txt"		;
keep if block=="A"		;
drop extra year block		;
save "$work\tempA", replace		;

		
#delim ;		
clear;		
qui infix		
str year		1-2 ///
str block		3-4 ///
str dsl			5-10 ///
typeoforganisation		11-12 ///
typeofownership		13 ///
noofunits2		14-17 ///
plant_mach	18 ///
str ISO_certified	19 ///
yearofinitialprod		20-23 ///
accountingyearopening		24-29 ///
accountingyearclosing		30-35 ///
monthsofoperation		36-37 ///
computers	38 ///
floppy		39 ///
extra		40-178 ///	
using "$input\asi10m.txt"		;
keep if block=="B"		;
drop extra year block		;
save "$work\tempB", replace		;



	
#delim ;		
clear;		
qui infix		str year		1-2 ///
str block		3-4 ///
str dsl			5-10 ///
 slno	11-12 ///
 openinggross		13-24 ///
 addbyreval		25-36 ///
 addnew		37-48 ///
 deduction	49-60 ///
 closinggross		61-72 ///
 ouptoyearbeg	73-84 ///
 providedyear	85-96 ///
 soldordiscarded	97-108 ///
 uptoyearend 	109-120 ///
 openingnet		121-132 ///
 closingnet		133-144 ///
 extra		145-178 ///
using "$input\asi10m.txt"		;
keep if block=="C"		;
drop extra year block		;
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
using "$input\asi10m.txt"		;
keep if block=="D"		;
drop extra year block		;
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
save "$work\tempD", replace		;
		
		
		
		
		
		
		
		
		
		
		
		
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
extra	69-178	
using "$input\asi10m.txt"		;
keep if block=="E"		;
drop extra year block		;
tostring slno, replace	;	
replace slno="men" if slno=="1"	;	
replace slno="women" if slno=="2"	;	
drop if slno=="3"	;	
replace slno="thrucontr" if slno=="4"	;	
drop if slno=="5"	;	
replace slno="supervstaff" if slno=="6"	;	
replace slno="otheremployees" if slno=="7"	;	
replace slno="unpaid" if slno=="8"	;	
replace slno="totalEEs" if slno=="9"	;	
reshape wide manufdays-wagesandsalaries, i(dsl) j(slno) string	;	
save "$work\tempE", replace		;
		

/*variables not present in 2009-10 ASI survey	
*repairmaintmachinery	35-46	
*repairmaintothpol	46-57
variables present in 2009-10 but not in others	
rent_plant_exp	83-94 /// separately from rent on bldgs. this is true in 94-95 survey as well.
*/

#delim ;		
clear;		
qui infix		
year	1-2	
str block	3-4	
str dsl	5-10	
workdonebyothers	11-22	
repairmaintbuilding	23-34	
repairmaintothers	35-46	
operatingexpenses	47-58	
nonooperatingexpenses	59-70	
insurancecharges	71-82	
rentforpm	83-94 
totalotherexp	95-106	
rentforbuilding	107-118	
rentoflandetc	119-130	
interest	131-142	
purchesevalueofgoodssold	143-154	
extra   155-178
using "$input\asi10m.txt"		;
keep if block=="F"		;
drop extra year block		;
egen repairmainttotal=rowtotal(repairmaint*); drop repairmaintbuilding-repairmaintothers	;
save "$work\tempF", replace		;
/*egen totalrent = rsum(rentonplant_mach rentforbuilding	rentoflandetc), missing;*/

						
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
subsidies  143-154
extra	155-178	
using "$input\asi10m.txt"		;
keep if block=="G"		;
drop extra year block		;
save "$work\tempG", replace		;
		
		
		
#delim ;		
clear;		
qui infix		
year	1-2	
str block	3-4	
str dsl	5-10	
slno	11-12	
itemcode	13-17	
quantityunit	18-20	
quantity	21-35	
purchasevalue	36-47	
rateperunit	48-62	
extra1	63-178	
using "$input\asi10m.txt"	;	
keep if block=="H"	;	
drop year block extra* quantityunit rateperunit	;	
keep if slno <=10 | slno>=15 & slno<=23	;	
tostring slno, replace	;	
replace slno="electricitygenerated" if slno=="15"	;
replace slno="electricitypurchased" if slno=="16"	;	
replace slno="fuel" if slno=="17"	;	
replace slno="coal" if slno=="18"	;
drop if slno == "19" ;	
replace slno="othfuel" if slno=="20"	;	
replace slno="consstore" if slno=="21"	;	
replace slno="totalfuelelec" if slno=="22"	;	
replace slno="totalrawmaterials" if slno=="23"	;	
rename purchasevalue value	;
reshape wide itemcode value quantity, i(dsl) j(slno) string	;

rename  quantityelectricitypurchased electricitypurchased ;
rename  quantityelectricitygenerated electricitygenerated ;
egen electricityconsumed = rsum(electricitypurchased electricitygenerated), missing;

# delimit cr

/*there is no info on the value of electricity generated. although there is info on the value of electricity generated and sold, value of electricity generated and consummed 
cannot be obtained indirectly  because there is no information on the amount of electricity generated and sold */
egen t_pv = rsum(value1-value10), missing

forval i = 1/10 {
g pv_r_`i'1 =(value`i'/t_pv)*100 
}
egen pv_max1 = rmax(pv_r*)
g inputvalue_max = .
g inputqty_max = .
g inputitemcode_max =.

g pv_max = int(pv_max1)
forval i = 1/10 {
g pv_r_`i' = int(pv_r_`i'1)
}


replace inputvalue_max = value1 if pv_r_1 == pv_max
replace inputqty_max = quantity1 if pv_r_1 == pv_max
replace inputitemcode_max = itemcode1 if pv_r_1 == pv_max


forval i = 2/10 { 
replace inputvalue_max = value`i' if pv_r_`i' ==pv_max 
replace inputqty_max = quantity`i' if pv_r_`i' ==pv_max 
replace inputitemcode_max = itemcode`i' if pv_r_`i' ==pv_max 
}

drop *1 *2 *3 *4 *5 *6 *7 *8 *9 *10 
keep valuecoal quantitycoal valueconsstore electricitygenerated valueelectricitygenerated electricitypurchased valueelectricitypurchased valuefuel valueothfuel valuetotalfuelelec valuetotalrawmaterials electricityconsumed dsl  inputvalue_max inputqty_max inputitemcode_max
g inputprice_max = inputvalue_max/inputqty_max
save "$work\tempH", replace			

		
		
		
#delim ;		
clear;		
qui infix		
year	1-2	
str block	3-4	
str dsl	5-10	
slno	11-12	
itemcode	13-17	
quantitycode	18-20	
quantity	21-35	
purchasevalue	36-47	
rateperunit	48-62	
extra1	63-178	
using "$input\asi10m.txt"	;	
keep if block=="I"	;	
drop year block extra* quantitycode rateperunit	;
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
qtymanufactured	21-35	
qtysold	36-50	
grosssalevalue	51-62	
exciseduty	63-74	
saletax	75-86	
distexpensesother	87-98	
distexpensestotal	99-110	
itemwisensvunit	111-125	
itemwiseexactvalue	126-137	
extra	138-178	
using "$input\asi10m.txt"	;	
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
cd "$work";
use tempA, clear;
merge dsl using tempB tempC tempD tempE tempF tempG tempH tempI tempJ, sort;

drop _merge*;


#delim ;
destring state, replace ;
lab def state
35 "ANDAMAN AND NICOBAR ISLANDS"
28 "ANDHRA PRADESH"
12 "ARUNCHAL PRADESH"
18 "ASSAM"
10 "BIHAR"
4 "CHANDIGARH"
22 "CHHATISGARH"
26 "DADRA  AND  NAGAR  HAVELI"
25 "DAMAN  &  DIU "
7 "DELHI"
30 "GOA"
24 "GUJARAT"
6 "HARYANA"
2 "HIMACHAL PRADESH"
1 "JAMMU & KASHMIR"
20 "JHARKHAND"
29 "KARNATAKA"
32 "KERALA"
31 "LAKSHADEEP"
23 "MADHYA PRADESH"
27 "MAHARASHTRA"
14 "MANIPUR"
17 "MEGHALAYA"
15 "MIZORAM"
13 "NAGALAND"
21 "ORISSA"
34 "PONDICHERRY"
3 "PUNJAB"
8 "RAJASTHAN"
11 "SIKKAM"
33 "TAMIL NADU"
16 "TRIPURA"
9 "UTTAR PRADESH"
5 "UTTARANCHAL"
19 "WEST BENGAL"
;
lab val state state;
decode state, g(state2);
drop state;
rename state2 state;



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
g year=2009;
drop if psl =="";
****g valueofelectricityconsumed = valueelectricitypurchased;

**drop electricityconsumed;
**ren quantityelectricityconsumed electricityconsumed;
*********because the value of generated electricity is only imputed and not marketed, so its 0. hence electricity consumed will have value equal to electricity purchased.

************the value of electricity generated is all 0 or .. we need to assign value based on price. The value of electricity consumed is given as the value of electricity purchased;
g price_elec = valueelectricitypurchased/electricitypurchased;

replace valueelectricitygenerated = electricitygenerated*price_elec;

*******valueelecconsumed_imputed ;
egen valueofelectricityconsumed  = rsum(valueelectricitypurchased valueelectricitygenerated);

save "$intdata\ASI0910_clean1", replace;
