clear all
set more off
*set matsize 8000
*shell cd -cd/d %~dp0-
cd "D:\GitHub\Coursework\Finance\Advanced Financial Econometrics 2014F\Assignment II\WorkingData"

***************************************************************
************** INITILIZATION                      *************
***************************************************************
*1.Asset, Liability
import excel using ..\RawData\DARatio\FS_Combas.xls, firstrow clear
drop in 1/2
rename A001000000 Asset
rename A002000000 Liability
save DARatio1.dta, replace

import excel using ..\RawData\DARatio\FS_Combas1.xls, firstrow clear
drop in 1/2
rename A001000000 Asset
rename A002000000 Liability
save DARatio2.dta, replace

use DARatio1.dta, clear
append using DARatio2.dta
sort Stkcd Accper
save DARatio.dta, replace

*2.ROE
import excel using ..\RawData\ROE\FI_T5.xls, firstrow clear
drop in 1/2
rename F050504C ROE
save ROE1.dta, replace

import excel using ..\RawData\ROE\FI_T51.xls, firstrow clear
drop in 1/2
rename F050504C ROE
save ROE2.dta, replace

use ROE1.dta, clear
append using ROE2.dta
bysort Stkcd Accper: keep if _n==1
sort Stkcd Accper
save ROE.dta, replace

*3.IPO Information
import excel using ..\RawData\IPO\IPO_Cobasic.xls, firstrow clear
drop in 1/2
sort Stkcd
save IPO.dta, replace

*4.Accounting Period
import excel using ..\RawData\AccountingPeriod\IAR_Rept.xls, firstrow clear
drop in 1/2
save AccountingPeriod1.dta, replace

import excel using ..\RawData\AccountingPeriod\IAR_Rept1.xls, firstrow clear
drop in 1/2
save AccountingPeriod2.dta, replace

use AccountingPeriod1.dta
append using AccountingPeriod2.dta
sort Stkcd Accper
save AccountingPeriod.dta, replace

*5.Control Variables
*5.1.Tax Rate
import excel using ..\RawData\Control_IncomeTaxRate\FN_Fn004.xls, firstrow clear
drop in 1/2
rename Fn00410 IncomeTaxRate
sort Stkcd
save IncomeTaxRate.dta, replace

*5.2.Liquidity Ratio
import excel using ..\RawData\Control_Liquidity\CSR_Finidx.xls, firstrow clear
drop in 1/2
rename T10100 LiquidityRatio
sort Stkcd Accper
save LiquidityRatio.dta, replace

*5.3.P/B Ratio
import excel using ..\RawData\Control_PBratio\FI_T10.xls, firstrow clear
drop in 1/2
rename F101001A PBRatio
save PBRatio1.dta, replace

import excel using ..\RawData\Control_PBratio\FI_T101.xls, firstrow clear
drop in 1/2
rename F101001A PBRatio
save PBRatio2.dta, replace

use PBRatio1.dta, clear
append using PBRatio2.dta
sort Stkcd Accper
save PBRatio.dta, replace

*5.4.SG&A
import excel using ..\RawData\Control_SG&A\FI_T5.xls, firstrow clear
drop in 1/2
save SGA1.dta, replace

import excel using ..\RawData\Control_SG&A\FI_T51.xls, firstrow clear
drop in 1/2
save SGA2.dta, replace

use SGA1.dta, clear
append using SGA2.dta
rename F051701C Se
rename F052001C SGAe
bysort Stkcd Accper (SGAe): keep if _n==1
sort Stkcd Accper
save SGA.dta, replace

*5.5.Top 10 Shareholders
cd ..\RawData\Control_Top10Shareholders\
local file : dir . files "*.xls",nofail
gen filename=""
local obs = 1
foreach f of local file {
	import excel using "`f'", firstrow clear
	gen source = "`obs'"
	save "..\..\WorkingData\Shareholders_`obs'", replace
	local obs = `obs' +1
}


cd ..\..\WorkingData\

use Shareholders_1.dta, clear
local end = `obs' - 1
forvalue i = 2(1)`end'{
	append using "Shareholders_`i'.dta"
}

gen lenSKT = strlen(Stkcd)
keep if lenSKT == 6
drop lenSKT
rename Reptdt Accper
rename S0301a ShareholderName
rename S0304a ShareholderRatio	


destring ShareholderRatio, replace
gen nShareholderRatio = -ShareholderRatio
gen HHI = ShareholderRatio^2/10000
bysort Stkcd Accper (nShareholderRatio): gen HHIsum = sum(HHI)
bysort Stkcd Accper (nShareholderRatio): gen HHI5 = HHIsum[5]
bysort Stkcd Accper (nShareholderRatio): gen HHI10 = HHIsum[10]
bysort Stkcd Accper (nShareholderRatio): drop if _n>1
keep Stkcd Accper HHI*
drop HHIsum
sort Stkcd Accper
save Shareholders.dta, replace

*5.6.CEO
cd ..\RawData\Control_CEO\
local file : dir . files "*.xls",nofail
gen filename=""
local obs = 1
foreach f of local file {
	import excel using "`f'", firstrow clear
	gen source = "`obs'"
	save "..\..\WorkingData\CEO_`obs'", replace
	local obs = `obs' +1
}


cd ..\..\WorkingData\

use CEO_1.dta, clear
local end = `obs' - 1
forvalue i = 2(1)`end'{
	append using "CEO_`i'.dta"
}

gen lenSKT = strlen(Stkcd)
keep if lenSKT == 6
drop lenSKT
rename Reptdt Accper
rename D0101b CEOName
rename D0301b CEOGender
replace CEOGender = "1" if CEOGender == "ÄÐ"
replace CEOGender = "0" if CEOGender == "Å®"
rename D0401b CEOAge
rename D0501b CEOEdu
rename D0901b CEOisSalary
rename D1001b CEOSalary
rename D1101b CEOShare

destring _all, replace
keep Stkcd Accper CEOGender CEOAge CEOSalary CEOShare
collapse (mean)CEOGender CEOAge CEOSalary CEOShare, by(Stkcd Accper)
tostring Stkcd, replace
sort Stkcd Accper
save CEO.dta, replace

*5.7.CEO Incentive
import excel using ..\RawData\Control_CEOIncentive\CG_Incperson.xls, firstrow clear
drop in 1/2
rename Pishrttl CEOIncentiveRatio
rename  Rptdt Accper
sort Stkcd Accper
save CEOIncentive.dta, replace

*6.IV - MainBusinessIncome
import excel using ..\RawData\IV_MainBusinessIncome\FAR_Finidx.xls, firstrow clear
drop in 1/2
rename B110101 MainBusinessIncome
sort Stkcd Accper
save MainBusinessIncome.dta, replace


***************************************************************
************** MERGE                              *************
***************************************************************
use DARatio.dta, clear
*1.1:1
merge Stkcd Accper using ROE.dta
tab _merge
drop _merge
sort Stkcd Accper

merge Stkcd Accper using AccountingPeriod.dta
tab _merge
drop _merge
sort Stkcd Accper

merge Stkcd Accper using LiquidityRatio.dta
tab _merge
drop _merge
sort Stkcd Accper

merge Stkcd Accper using PBratio.dta
tab _merge
drop _merge
sort Stkcd Accper

merge Stkcd Accper using SGA.dta
tab _merge
drop _merge
sort Stkcd Accper

merge Stkcd Accper using MainBusinessIncome.dta
tab _merge
drop _merge
sort Stkcd Accper

merge Stkcd Accper using Shareholders.dta
tab _merge
drop _merge
sort Stkcd Accper

merge Stkcd Accper using CEO.dta
tab _merge
drop _merge
sort Stkcd Accper
/*
merge Stkcd Accper using CEOIncentive.dta
tab _merge
drop _merge
sort Stkcd Accper 
*/

merge Stkcd Accper using CEO.dta
tab _merge
drop _merge
sort Stkcd Accper 


*2.m:1
merge Stkcd using IPO.dta
tab _merge
drop _merge
sort Stkcd 
/*
merge Stkcd using IncomeTaxRate.dta
tab _merge
drop _merge
sort Stkcd 
*/

destring _all, replace
save main.dta, replace

***************************************************************
************** VARIABLE INI                       *************
***************************************************************
use main.dta, clear
local Y DARatio
local X CorpAge CorpAge2 Size ROE
local ControlVar LiquidityRatio HHI10 PBRatio SGAe CEO*

*1.Annual report
keep if Reptyp==4

*2.Duplication check 
capture drop dup
bysort Stkcd Accper: gen dup = _N
gsort -dup Stkcd Accper

*3.Drop Dulicates
bysort Stkcd Accper: keep if _n==1
gen year = year(date(Accper, "YMD"))
gen AccDate = date(Accper, "YMD")
xtset Stkcd AccDate

*4.Generating Variables 
gen CorpAge = (date(Accper,"YMD")-date(Estbdt,"YMD"))/365
gen CorpAge2 = CorpAge^2

gen ListAge = (date(Accper,"YMD")-date(Listdt,"YMD"))/365
gen ListAge2 = ListAge^2

gen DARatio = Liability/Asset
gen Size = log(Asset)

gen lgMainBusiness = log(MainBusiness)

*5.Drop
*drop industry with firms less than 10
capture drop IndcdN
bysort Indcd year: gen IndcdN = _N
drop if IndcdN<10
capture drop IndcdN

*drop those without liquidity
drop if Asset<0
drop if Asset < Liability

*6.Winsor
winsor2 `Y' `X' `ControlVar' , replace by(Indcd year) cuts(1 99)
***************************************************************
************** ASSIGNMENT                         *************
***************************************************************
*Q0.

latabstat `Y' `X' `ControlVar', s(mean sd med min max ) ///
cap(Summarize of Variables) clabel(tab:latabstat1) ///
columns(s) f(%9.2fc) hw(16) replace ///
tf(..\TeX\SumofVar)

*Q1.
*OLS
xi: reg `Y' `X' i.Indcd i.year
est table, keep(`X') b se
est store model11
xi: reg `Y' `X' `ControlVar' i.Indcd i.year
est store model12


*Fixed-Effect
xtreg `Y' `X' i.year, fe i(Stkcd)
est store model21
xtreg `Y' `X' `ControlVar' i.year, fe i(Stkcd)
est store model22
xtivreg `Y' CorpAge CorpAge2 Size (ROE=lgMainBusiness) `ControlVar' i.year, fe i(Stkcd)
est store model23
estimate store fe

*Random-Effect
xtreg `Y' `X' i.year, re
est store model31
xtreg `Y' `X' `ControlVar' i.year, re i(Stkcd)
est store model32
xtivreg `Y' CorpAge CorpAge2 Size (ROE=lgMainBusiness) `ControlVar' i.year, re i(Stkcd)
est store model33
estimate store re

*Q2.
sjlog using ..\TeX\HausmanTest, replace
hausman fe re, sigmamore all
sjlog close, replace nolog

*Q4.FEGMM
*xtabond2 `Y' `X' `ControlVar' i.year, gmmstyle(`X' `ControlVar') ivstyle(L(0/4).(`X' `ControlVar')) robust small

*TeXtify
#delimit ;
esttab model11 model12 model21 model22 model31 model32 using ..\TeX\regression.tex, drop(_* *year) replace
title("Results of OLS, FE and RE"\label{tab:regression})
mtitle("OLS" "OLS" "FE" "FE" "RE" "RE")
b(%6.4f) se(%6.4f) star(* 0.1 ** 0.05 *** 0.01) ar2 
coeflabels(mpg2 "mpg$?2$" _cons Constant);
#delimit cr

#delimit ;
esttab model21 model22 model23 using ..\TeX\regressionFE.tex, drop(_* *year) replace
title("Result of Fixed Effect Model(IV used)"\label{tab:regressionFE})
mtitle("FE" "FE" "IV-FE")
b(%6.4f) se(%6.4f) star(* 0.1 ** 0.05 *** 0.01) ar2
coeflabels(mpg2 "mpg$?2$" _cons Constant);
#delimit cr

#delimit ;
esttab model31 model32 model33 using ..\TeX\regressionRE.tex, drop(_* *year) replace
title("Result of Random Effect Model(IV used)"\label{tab:regressionRE})
mtitle("FE" "FE" "IV-FE")
b(%6.4f) se(%6.4f) star(* 0.1 ** 0.05 *** 0.01) ar2
coeflabels(mpg2 "mpg$?2$" _cons Constant);
#delimit cr
/*
esttab model1 model2 mode21 mode22 mode31 mode32 using ..\TeX\esttab1.tex, replace
xtivreg `Y' (`X' = MainBusinessIncome) `ControlVar', fe small


