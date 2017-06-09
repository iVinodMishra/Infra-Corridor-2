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
str industrycode	1-4
str runningslno	5-9
str state	10-11
str scheme	12
recordcategory	13-15
linkcode	16-18
fodrsl	19-23
permanentslno	24-28
noofunits	29-31
str statedist	32-37
str fodregioncode	38-42
ruralurban	43
backwardareacode	44
yearofinitialprod	45-48
typeoforganisation	49
typeofownership	50
typeofmanagement	51
whetherancillaryunit	52
whetherregistered	53
accountingyearclosing	54-59
monthsofoperation	60-61
typeofpowerused	62
openclosedcode	63
noofrecordsblk4	64-65
noofrecordsblk5	66
noofrecordsblk7	67
noofrecordsblk8	68
noofrecordsblk9	69
noofrecordsblk10	70
noofrecordsblk11	71
noofrecordsblk12	72
noofrecordsblk13	73-74
noofrecordsblk13a	75-76
noofrecordsblk13b	77-78
noofrecordsblk14	79-80
noofrecordsblk14a	81
noofrecordstotal	82-84
filler	85-123
multiplier	124-127
using "$input\ASID9495.txt"	;
g uniqid= industry+ runningslno+ state+ scheme	;
drop filler noofrec*	;
keep if recordcategory==11	;
	replace statedist=substr(statedist,1,4);
duplicates drop	;
save "$work\ASI9495block1", replace	;



#delim ;
clear;	
qui infix	
str industrycode	1-4
str runningslno	5-9
str state	10-11
str scheme	12
recordcategory	13  -    15
subrecordcode	 16 -   18 
openinggross	 19 -  29 
addbyreval	30-40
addnew	41-51
deduction	52-62
deprecbeg	63-73
deprecduring	74-84
soldordiscarded	85-95
openingnet	96-106
closingnet	107-117
filler	118-127
using "$input\ASID9495.txt"	;
g uniqid= industry+ runningslno+ state+ scheme	;
keep if recordcategory==40	;
drop filler recordcategory	;
duplicates drop	;
tostring subrecordcode, replace	;
replace subrecordcode="land" if subrecordcode=="1"	;
replace subrecordcode="devland" if subrecordcode=="2"	;
replace subrecordcode="building" if subrecordcode=="3"	;
replace subrecordcode="plant_mach" if subrecordcode=="4"	;
replace subrecordcode="furn_fittgs" if subrecordcode=="5"	;
replace subrecordcode="transportequip" if subrecordcode=="6"	;
replace subrecordcode="otherFA" if subrecordcode=="7"	;
replace subrecordcode="totalcapitalwip" if subrecordcode=="9"	;
drop if subrecordcode=="10"	;
drop if subrecordcode=="11"	;
drop if subrecordcode=="12"	;
drop if subrecordcode=="8"	;
drop if subrecordcode=="14"	;
replace subrecordcode="totalFA" if subrecordcode=="13"	;
reshape wide openinggross-closingnet, i(industry-scheme uniqid) j(subrecordcode) string	;
save "$work\ASI9495block2", replace	;








#delim ;
clear;	
qui infix	
str industrycode	1-4
str runningslno	5-9
str state	10-11
str scheme	12
recordcategory	13-15
subrecordcode	16-18
pmundepreciatedopening	19-29
pmleasedinopening	30-40
pmleasedoutopening	41-51
pmtotalopening	52-62
pmundepreciatedclosing	63-73
pmleasedinclosing	74-84
pmleasedoutclosing	85-95
pmtotalclosing	96-106
filler	107-127
using "$input\ASID9495.txt"	;
g uniqid= industry+ runningslno+ state+ scheme	;
keep if recordcategory==40	;
keep if subrecordcode==14	;
drop filler recordcategory subrecordcode	;
duplicates drop	;
save "$work\ASI9495block3", replace	;



#delim ;
clear;	
qui infix	
str industrycode	1-4
str runningslno	5-9
str state	10-11
str scheme	12
recordcategory	13-15
linkcode	16-18
rawmaterials	19-29
fuellube	30-40
sparesothers	41-51
semifinished	52-62
finishedgoods	63-73
totalinventory	74-84
filler	85-127
using "$input\ASID9495.txt"	;
g uniqid= industry+ runningslno+ state+ scheme	;
keep if recordcategory==51 | recordcategory==53	;
drop filler linkcode	;
tostring recordcategory, replace	;
duplicates drop	;
replace recordcategory="open" if recordcategory=="51"	;
replace recordcategory="close" if recordcategory=="53"	;
reshape wide rawmaterials-totalinventory, i(industry-scheme uniqid) j(recordcategory) string	;
save "$work\ASI9495block4", replace	;



#delim ;
clear;	
qui infix	
str industrycode	1-4
str runningslno	5-9
str state	10-11
str scheme	12
recordcategory	13-15
linkcode	16-18
cash	19-29
sundrydebtors	30-40
othercurrentasts	41-51
sundrycreditors	52-62
overdraftsetc	63-73
othercurrentliab	74-84
workingcapital	85-95
outstandingloan	96-106
filler	107-127
using "$input\ASID9495.txt"	;
g uniqid= industry+ runningslno+ state+ scheme	;
keep if recordcategory==52 | recordcategory==54	;
drop filler linkcode	;
duplicates drop	;
tostring recordcategory, replace	;
replace recordcategory="open" if recordcategory=="52"	;
replace recordcategory="close" if recordcategory=="54"	;
reshape wide cash-outstandingloan, i(industry-scheme uniqid) j(recordcategory) string	;
save "$work\ASI9495block5", replace	;






#delim ;
clear;	
qui infix	
str industrycode	1-4
str runningslno	5-9
str state	10-11
str scheme	12
recordcategory	13-15
linkcode	16-18
men	19-29
women	30-40
children	41-51
thrucontr	52-62
supervstaff	63-73
otheremployees	74-84
totalEEs	85-95
filler	96-127
using "$input\ASID9495.txt"	;
g uniqid= industry+ runningslno+ state+ scheme	;
keep if recordcategory==71 | recordcategory==72 | recordcategory==73	;
drop filler	;
duplicates drop	;
tostring recordcategory, replace	;
replace recordcategory="manufdays" if recordcategory=="71"	;
replace recordcategory="nonmanufdays" if recordcategory=="72"	;
replace recordcategory="totaldays" if recordcategory=="73"	;
reshape wide men-totalEEs, i(industry-scheme uniqid) j(recordcategory) string	;
save "$work\ASI9495block6", replace	;




#delim ;
clear;	
qui infix	
str industrycode	1-4
str runningslno	5-9
str state	10-11
str scheme	12
recordcategory	13-15
linkcode	16-18
men_avg	19-25
women_avg	26-32
children_avg	33-39
thrucontr_avg	40-46
supervstaff_avg	47-53
otheremployees_avg	54-60
gproprietors_avg	61-67
unpaidEE_avg	68-74
ifcoop_avg	75-81
totalEE_avg	82-88
noofmanufacturingdays	89-95
totalnoofworkingdays	96-102
totalnoofshifts	103-109
lengthofshifts	110-116
filler	117-127
using "$input\ASID9495.txt"	;
g uniqid= industry+ runningslno+ state+ scheme	;
keep if recordcategory==74	;
drop filler recordcategory	;
duplicates drop	;
egen check=rowtotal( men_avg women_avg children_avg thrucontr_avg supervstaff_avg otheremployees_avg gproprietors_avg unpaidEE_avg ifcoop_avg) ;
replace totalEE_avg = check if check!=totalEE_avg;
drop check;
save "$work\ASI9495block7", replace	;





#delim ;
clear;	
qui infix	
str industrycode	1-4
str runningslno	5-9
str state	10-11
str scheme	12
recordcategory	13-15
linkcode	16-18
wagesandsalariesEEs	19-28
bonusEEs	29-38
contributiontopfEEs	39-48
welfareexpenseEEs	49-58
totallabourcostEEs	59-68
wagessupervisory	69-78
bonussupervisory	79-88
contribsupervisory	89-98
welfareexpsupervisory	99-108
totallabourcostsupervisory	109-118
filler	119-127
using "$input\ASID9495.txt"	;
g uniqid= industry+ runningslno+ state+ scheme	;
keep if recordcategory==81	;
drop filler recordcategory	;
duplicates drop	;
save "$work\ASI9495block8", replace	;







#delim ;
clear;	
qui infix	
str industrycode	1-4
str runningslno	5-9
str state	10-11
str scheme	12
recordcategory	13-15
linkcode	16-18
wagessalariesothers	19-28
bonus0thers	29-38
contributiontopfothers	39-48
welfareexpenseothers	49-58
totallabourcostothers	59-68
wagessalariestotal	69-78
bonustotal	79-88
contributiontopftotal	89-98
welfareexpensestotal	99-108
totallabourcosttotal	109-118
filler	119-127
using "$input\ASID9495.txt"	;
g uniqid= industry+ runningslno+ state+ scheme	;
keep if recordcategory==82	;
drop filler recordcategory	;
duplicates drop	;
save "$work\ASI9495block9", replace	;




#delim ;	
clear;	
qui infix	
str industrycode	1-4
str runningslno	5-9
str state	10-11
str scheme	12
recordcategory	13-15
linkcode	16-18
itemcode1	19-22
qty1	23-33
value1	34-44
itemcode2	45-48
qty2	49-59
value2	60-70
itemcode3	71-74
qty3	75-85
value3	86-96
itemcode4	97-100
qty4	101-111
value4	112-122
filler	123-127
using "$input\ASID9495.txt"	;
g uniqid= industry+ runningslno+ state+ scheme	;
keep if recordcategory==91	;
drop filler 	;
duplicates drop	;
tempfile master	;
save `master'	;
	
forval i=1/4 {	;
use `master', clear	;
keep   industrycode- recordcategory uniqid itemcode`i' qty`i' value`i'	;
rename itemcode itemcode	;
rename value value	;
rename qty qty;
tempfile temp`i'	;
save `temp`i''	;
}	;
	
use `temp1', clear	;
append using `temp2'	;
append using `temp3'	;
append using `temp4'	;
	
drop if itemcode==0	;
keep if itemcode <=16 | itemcode==9999	;
	
tostring itemcode, replace	;
replace itemcode="coal" if recordcategory==91 & itemcode=="1"	;
replace itemcode="lignite" if recordcategory==91 & itemcode=="2"	;
replace itemcode="coalgas" if recordcategory==91 & itemcode=="3"	;
replace itemcode="liqpetgas" if recordcategory==91 & itemcode=="4"	;
replace itemcode="natgas" if recordcategory==91 & itemcode=="5"	;
replace itemcode="petrol" if recordcategory==91 & itemcode=="6"	;
replace itemcode="diesel" if recordcategory==91 & itemcode=="7"	;
replace itemcode="furnaceoil" if recordcategory==91 & itemcode=="8"	;
replace itemcode="otherfueloil" if recordcategory==91 & itemcode=="9"	;
replace itemcode="wood" if recordcategory==91 & itemcode=="10"	;
replace itemcode="biomass" if recordcategory==91 & itemcode=="11"	;
replace itemcode="electricitypurch" if recordcategory==91 & itemcode=="12"	;
replace itemcode="lube" if recordcategory==91 & itemcode=="13"	;
replace itemcode="water" if recordcategory==91 & itemcode=="14"	;
replace itemcode="other" if recordcategory==91 & itemcode=="15"	;
replace itemcode="totalfuelelec" if recordcategory==91 & itemcode=="9999"	;
replace itemcode="totalrawmaterials" if recordcategory==131 & itemcode=="9999"	;
replace itemcode="totalimportedmaterials" if recordcategory==133 & itemcode=="9999"	;
collapse (sum)  qty value, by (industrycode- scheme uniqid itemcode)	;
reshape wide qty value, i(industrycode- scheme uniqid) j(itemcode) string	;
egen valuefuel = rsum(valuediesel valuepetrol valuefurnaceoil valueotherfueloil), missing; 
egen valueothfuel =rsum(valuenatgas valuewood valuebiomass valuelignite valuecoalgas valueliqpetgas valueother), missing;

save "$work\ASI9495block10", replace	;


#delim ;
clear;	
qui infix	
str industrycode	1-4
str runningslno	5-9
str state	10-11
str scheme	12
recordcategory	13-15
linkcode	16-18
workdonebyothers	19-28
repairmaintmachinery	29-38
repairmaintbuilding	39-48
repairmaintothers	49-58
inwardfreightetc	59-68
ratesandtaxes	69-78
postagetelephoneetc	79-88
insurancecharges	89-98
bankingcharges	99-108
printingstationery	109-118
filler	119-127
using "$input\ASID9495.txt"	;
g uniqid= industry+ runningslno+ state+ scheme	;
keep if recordcategory==101	;
drop filler recordcategory linkcode	;
duplicates drop	;
egen repairmainttotal=rowtotal(repairmaint*); drop repairmaintmachinery-repairmaintothers	;
save "$work\ASI9495block11", replace	;






#delim ;
clear;	
qui infix	
str industrycode	1-4
str runningslno	5-9
str state	10-11
str scheme	12
recordcategory	13-15
linkcode	16-18
miscellaneous	19-28
totalotherexp	29-38
rentoflandetc	39-48
rentforbuilding	49-58
rentforpm	59-68
rentforotherassets	69-78
totalrent	79-88
interest	89-98
purchesevalueofgoodssold	99-108
labourcostownconstruction	109-118
filler	119-127
using "$input\ASID9495.txt"	;
g uniqid= industry+ runningslno+ state+ scheme	;
keep if recordcategory==102	;
drop filler recordcategory linkcode	;
duplicates drop	;
save "$work\ASI9495block12", replace	;




#delim ;
clear;	
qui infix	
str industrycode	1-4
str runningslno	5-9
str state	10-11
str scheme	12
recordcategory	13-15
linkcode	16-18
othersownconstruction	19-28
totalownconstruction	29-38
workdoneforothers	39-48
nonindustrialsvcs	49-58
varstockofsemifin	59-68
valueofelectricitysold	69-78
valueofownconstruction	79-88
totalotheroutput	89-98
salevaluegoodssold	99-108
filler	109-127
using "$input\ASID9495.txt"	;
g uniqid= industry+ runningslno+ state+ scheme	;
keep if recordcategory==111	;
drop filler recordcategory 	;
duplicates drop	;
save "$work\ASI9495block13", replace	;




#delim ;
clear;	
qui infix	
str industrycode	1-4
str runningslno	5-9
str state	10-11
str scheme	12
recordcategory	13-15
linkcode	16-18
electricitypurchased	19-29
electricitygenerated	30-40
electricitysold	41-51
electricityconsumed	52-62
filler	63-127
using "$input\ASID9495.txt"	;
g uniqid= industry+ runningslno+ state+ scheme	;
keep if recordcategory==121	;
drop filler recordcategory linkcode	;
duplicates drop	;
save "$work\ASI9495block14", replace	;




#delim ;
clear;	
qui infix	
str industrycode	1-4
str runningslno	5-9
str state	10-11
str scheme	12
recordcategory	13-15
linkcode	16-18
itemcode1	19-22
qty1	23-33
value1	34-44
itemcode2	45-48
qty2	49-59
value2	60-70
itemcode3	71-74
qty3	75-85
value3	86-96
itemcode4	97-100
qty4	101-111
value4	112-122
filler	123-127
using "$input\ASID9495.txt"	;
g uniqid= industry+ runningslno+ state+ scheme	;
keep if recordcategory==131 	;
drop filler 	;
duplicates drop	;
tempfile master	;
save `master'	;
	
forval i=1/4 {	;
use `master', clear	;
keep   industrycode- recordcategory uniqid itemcode`i' qty`i' value`i'	;
rename itemcode itemcode	;
rename value value	;
rename qty qty	;
tempfile temp`i'	;
save `temp`i''	;
}	;
	
use `temp1', clear	;
append using `temp2'	;
append using `temp3'	;
append using `temp4'	;
drop if itemcode==0	;

collapse (sum)  qty value, by (industrycode- scheme uniqid itemcode)	;

drop if itemcode!=9999 & qty== 0 ;
bysort uniqid: egen inputvalue_max1=max(value) if  qty!=0 ;

ren value value_orig;
g float  value = value_orig;
drop value_orig;

foreach i in qty itemcode { ;
g `i'_max1=`i' if value==inputvalue_max1 ;
bys uniqid: egen input`i'_max=mean(`i'_max1);
drop `i'_max1;
};

bys uniqid: egen inputvalue_max= mean(inputvalue_max1);
drop inputvalue_max1;

ren value valuetotalrawmaterials ;
keep if itemcode == 9999;
keep industrycode runningslno state scheme uniqid valuetotalrawmaterials inputvalue_max inputqty_max inputitemcode_max ;
g inputprice_max = inputvalue_max/inputqty_max;
save "$work\ASI9495block15", replace	;



#delim ;	
clear;	
qui infix	
str industrycode	1-4
str runningslno	5-9
str state	10-11
str scheme	12
recordcategory	13-15
linkcode	16-18
itemcode1	19-22
qty1	23-33
value1	34-44
itemcode2	45-48
qty2	49-59
value2	60-70
itemcode3	71-74
qty3	75-85
value3	86-96
itemcode4	97-100
qty4	101-111
value4	112-122
filler	123-127
using "$input\ASID9495.txt"	;
g uniqid= industry+ runningslno+ state+ scheme	;
keep if recordcategory==133	;
drop filler 	;
duplicates drop	;
tempfile master	;
save `master'	;
	
forval i=1/4 {	;
use `master', clear	;
keep   industrycode- recordcategory uniqid itemcode`i' qty`i' value`i'	;
rename itemcode itemcode	;
rename value value	;
rename qty qty	;
tempfile temp`i'	;
save `temp`i''	;
}	;
	
use `temp1', clear	;
append using `temp2'	;
append using `temp3'	;
append using `temp4'	;
	
drop if itemcode==0	;

collapse (sum) qty value, by (industrycode- scheme uniqid itemcode)	;

drop if itemcode!=9999 & qty== 0 ;
bysort uniqid: egen for_inputvalue_max1=max(value) if  qty!=0 ;

ren value value_orig;
g float  value = value_orig;
drop value_orig;

foreach i in qty itemcode { ;
g `i'_max1=`i' if value==for_inputvalue_max1 ;
bys uniqid: egen for_input`i'_max=mean(`i'_max1);
drop `i'_max1;
};

bys uniqid: egen for_inputvalue_max=mean(for_inputvalue_max1);
drop for_inputvalue_max1;

ren value for_input_value ;
keep if itemcode == 9999;
keep industrycode runningslno state scheme uniqid for_input_value  for_inputvalue_max for_inputqty_max for_inputitemcode_max ;
g for_inputprice_max = for_inputvalue_max/for_inputqty_max;
save "$work\ASI9495block17", replace	;


#delim ;
clear;	
qui infix	
str industrycode	1-4
str runningslno	5-9
str state	10-11
str scheme	12
recordcategory	13-15
linkcode	16-18
itemcode	19-22
qtymanufactured	23-33
qtysold	34-44
grosssalevalue	45-55
excisedutyproducts	56-66
saletaxproducts	67-77
distexpensesother	78-88
distexpensestotal	89-99
itemwisensvunit	100-110
itemwiseexactvalue	111-121
filler	122-127
using "$input\ASID9495.txt"	;
g uniqid= industry+ runningslno+ state+ scheme	;
keep if recordcategory==141	;
drop filler recordcategory	;
duplicates drop	;
drop linkcode	;

drop if itemcode!=9999 & qtysold== 0 ;
bysort uniqid: egen value_max1=max(grosssalevalue) if  qtysold!=0 ;

ren grosssalevalue grosssalevalue_orig;
g float  grosssalevalue = grosssalevalue_orig;
drop grosssalevalue_orig;

foreach i in qtysold itemcode { ;
g `i'_max1=`i' if grosssalevalue==value_max1 ;
bys uniqid: egen `i'_max=mean(`i'_max1);
drop `i'_max1;
};

bys uniqid: egen value_max=mean(value_max1);
drop value_max1;

ren qtysold_max qty_max;
keep if itemcode == 9999;
keep industrycode runningslno state scheme grosssalevalue excisedutyproducts saletaxproducts distexpensesother distexpensestotal itemwisensvunit itemwiseexactvalue uniqid value_max qty_max itemcode_max ;
g price_max = value_max/qty_max;
gsort +uniqid - grosssalevalue - distexpensestotal - saletax - distexpensesother	;
by uniqid: g rank=_n	; 
keep if rank==1; drop rank	;
save "$work\ASI9495block18", replace	;





#delim ;
clear;	
qui infix	
str industrycode	1-4
str runningslno	5-9
str state	10-11
str scheme	12
recordcategory	13-15
linkcode	16-18
exciseduty	19-29
saletax	30-40
transportcharges	41-51
commissiontoagents	52-62
rebates	63-73
otherdistexp	74-84
totaldistexp	85-95
filler	96-127
using "$input\ASID9495.txt"	;
g uniqid= industry+ runningslno+ state+ scheme	;
keep if recordcategory==142	;
drop filler recordcategory	;
duplicates drop	;
save "$work\ASI9495block19", replace	;


#delim ;
use "$work\ASI9495block1", replace	;
merge industry-scheme uniqid using 
"$work\ASI9495block2" 
"$work\ASI9495block3" 
"$work\ASI9495block4" 
"$work\ASI9495block5" 
"$work\ASI9495block6" 
"$work\ASI9495block7" 
"$work\ASI9495block8" 
"$work\ASI9495block9" 
"$work\ASI9495block10" 
"$work\ASI9495block11" 
"$work\ASI9495block12" 
"$work\ASI9495block13" 
"$work\ASI9495block14"
"$work\ASI9495block15" 
"$work\ASI9495block17"  
"$work\ASI9495block18" 
"$work\ASI9495block19"
, sort unique ;
drop _merge*;



***Fix States;
# delim ;
destring state, replace;
lab def state
2 "ANDHRA PRADESH"

4 "ASSAM"
5 "BIHAR"
6 "GOA"
7 "GUJARAT"
8 "HARYANA"
9 "HIMACHAL PRADESH"
10 "JAMMU & KASHMIR"
11 "KARNATAKA"
12 "KERALA"
13 "MADHYA PRADESH"
14 "MAHARASHTRA"
15 "MANIPUR"
16 "MEGHALAYA"

18 "NAGALAND"
19 "ORISSA"
20 "PUNJAB"
21 "RAJASTHAN"

23 "TAMIL NADU"
24 "TRIPURA"
25 "UTTAR PRADESH"
26 "WEST BENGAL"
27 "ANDAMAN AND NICOBAR ISLANDS"
28 "CHANDIGARH"
29 "DADRA  AND  NAGAR  HAVELI"
30 "DAMAN  &  DIU "
31 "DELHI"

33 "PONDICHERRY"
, modify;
lab val state state;
decode state, g(state2);
drop state;
rename state2 state;
tab state, mi;


***Code Ownership Organization and others;
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
8 "Co-Operative Society"
9 "Others  (including  trusts, wakf,  boards etc.)"
,modify;
lab val typeoforganisation typeoforganisation;
decode typeoforganisation, g(typeoforganisation2);
drop typeoforganisation;
rename typeoforganisation2 typeoforganisation;
tab typeoforganisation, mi;




# delim ;
destring typeofownership, replace;
lab def typeofownership
1 "Wholly Central Government"
2 "Wholly State and/or Local Government "
3 "Central  Government and State and/or Local  Government jointly "
4 "Joint  Sector Public"
5 "Joint  Sector  Private  "
6 "Wholly  private  Ownership"
,modify;
lab val typeofownership typeofownership;
decode typeofownership, g(typeofownership2);
drop typeofownership;
rename typeofownership2 typeofownership;
tab typeofownership, mi;


/***DEMULTIPLY DATA ---WHY IS PREMULTIPLICATION DONE BY CSO EVEN THO MLTIPLIER IS IN DATA?!!? AAAAARGHHHH!!!Extract Multipliers based on Scheme from Shanthi Nataraj email below;
*/;

# delim ;
tab scheme, mi;
replace multiplier=multiplier/1000;

foreach var of varlist  noofunits  openinggrossbuilding- totaldistexp {;
qui replace `var' = `var'/(multiplier);
};

# delimit cr
*drop qtyelectricitypurch



************generating value of electricity consumed
g price_elec_sold = valueofelectricitysold/electricitysold
g price_elec_purch = valueelectricitypurch/qtyelectricitypurch

foreach i in price_elec_sold price_elec_purch {
replace `i' = . if `i' == 0
}

egen price_elec =rmean(price_elec_sold price_elec_purch)

g valueofelectricitygenerated = electricitygenerated*price_elec

g valueofelectricitysold1 =valueofelectricitysold
replace valueofelectricitysold1 = 0 if valueofelectricitysold == .

egen valueofelectricityconsum = rsum(valueofelectricitygenerated  valueelectricitypurch), missing 
g valueofelectricityconsumed = valueofelectricityconsum- valueofelectricitysold1
drop valueofelectricityconsum price_ele*
drop  valueofelectricitysold1 

ren valueofelectricitygenerated valueelectricitygenerated
ren valueelectricitypurch valueelectricitypurchased
ren electricitypurchased electricitypurchased_o
ren qtyelectricitypurch electricitypurchased

g elecprice = valueelectricitypurch/electricitypurchased
g elecprice_o = valueelectricitypurch/electricitypurchased_o
replace  electricitypurchased = electricitypurchased_o if (electricitypurchased==. | electricitypurchased ==0)  
replace  electricitypurchased = electricitypurchased_o if  elecprice>7 & electricitypurchased_o!=. & elecprice_o <7 
replace  electricitypurchased = electricitypurchased_o if  elecprice<1.5 & electricitypurchased_o!=. & elecprice_o <7 & elecprice_o>1.5 
drop elecprice_o elecprice electricitypurchased_o

g year=1994
save "$intdata\ASI9495_clean1.dta", replace
