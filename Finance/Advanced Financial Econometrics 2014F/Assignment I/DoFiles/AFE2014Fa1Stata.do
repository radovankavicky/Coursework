clear all
set trace off
set more off
cd "E:\Dropbox\Gap Year\GSM\金融计量\第一次作业\RawData\Dalyr"

***************************************************************
************** INITILIZATION                      *************
***************************************************************
*1.Data of Stocks
local file : dir . files "*.xls",nofail
gen filename=""
local obs = 1
foreach f of local file {
	import excel using "`f'", firstrow clear
	gen source = "`obs'"
	save "..\..\WorkingData\Dalyr_`obs'", replace
	local obs = `obs' +1
}


cd ..\..\WorkingData\

use Dalyr_1.dta, clear
local end = `obs' - 1
forvalue i = 2(1)`end'{
	append using "Dalyr_`i'.dta"
}

gen lenSKT = strlen(Stkcd)
keep if lenSKT == 6
drop lenSKT
destring Dretwd, replace
sort Trddt
save Stocks.dta, replace


*2.Data of Index
import excel using ..\RawData\TRD_Index.xls, firstrow clear
drop in 1/2
destring Retindex, replace
keep if Indexcd =="000001"
sort Trddt
save Index.dta, replace


*3.Data of Asset, Liability
import excel using ..\RawData\FS_Combas.xls, firstrow clear
drop in 1/2
keep if Accper =="2011-12-31"
rename A001000000 Asset
rename A002000000 Liability
destring Asset Liability, replace
gen Lev = Liability / Asset
save Lev.dta, replace

*Merging
use Stocks.dta, clear
merge m:1 Trddt using Index.dta
tab _merge
keep if _merge ==3
drop _merge
sort Stkcd
merge m:1 Stkcd using Lev.dta
keep if _merge ==3
tab _merge
drop _merge


*Format
replace Trddt = subinstr(Trddt, "-", "",.)
rename Stkcd StkID
rename Trddt date
rename Dretwd Dreturn
rename Retindex Mreturn

keep StkID date Dreturn Mreturn Lev
destring StkID, replace
save StocksMerged.dta, replace
outsheet using "Stocks.csv", comma replace




*Beta
use StocksMerged.dta, clear
gen Date = date(date,"YMD")
keep if Date < date("20120101", "YMD")
drop Date
statsby _b[_cons] _b[Mreturn] e(rmse), by(StkID) clear: reg Dreturn Mreturn
rename _stat_1 Alpha
rename _stat_2 Beta
rename _stat_3 nonSE
sort StkID
save Beta.dta, replace

use Stocksmerged.dta, clear
sort StkID
merge StkID using Beta.dta
tab _merge
drop _merge
gen ui = Dreturn - Alpha - Beta*Mreturn
gen Date = date(date,"YMD")
gen year = year(Date)
*bysort StkID year: drop if _N<400
tsset StkID Date
egen Stkgp = group(StkID)
save StocksMerged.dta, replace


***************************************************************
**************                       *************
***************************************************************
use StocksMerged.dta, clear


*Q1

qui sum Stkgp
sca randomgp = round(runiform()*r(max),1)
keep if Stkgp == randomgp
reg ui l1.ui l2.ui l3.ui l4.ui 
twoway lfitci ui l1.ui || scatter ui l1.ui 

use StocksMerged.dta, clear
qui sum Stkgp
sca randomgp = round(runiform()*r(max),1)
keep if Stkgp == randomgp
reg ui l1.ui l2.ui l3.ui l4.ui 
twoway lfitci ui l1.ui || scatter ui l1.ui 


*Q2
*Already done in the part BETA


*Q3
use Stocksmerged.dta, clear
capture drop Date
gen Date = date(date,"YMD")
keep if Date >= date("20120101", "YMD")
collapse (mean)Dreturn Lev, by(StkID)
rename Dreturn return12
sort StkID
save Return12.dta, replace

use Beta.dta, clear
bysort StkID: keep if _n==1
merge StkID using Return12.dta
tab _merge
drop _merge
gen Beta_Lev = Beta*Lev
reg return12 Lev nonSE Beta

*Q4
reg return12 Lev nonSE Beta_Lev Beta
test Beta_Lev = 0

*Q5

hettest
reg return12 Lev nonSE Beta_Lev Beta, robust

*WLS=FGLS
quietly {
	reg return12 Lev nonSE Beta_Lev Beta 
	predict el, res 
	gen lne2=log(el^2)
	reg lne2 Lev nonSE Beta_Lev Beta  
	predict lne2f
	gen e2f=exp(lne2f) 
}
reg return12 Lev nonSE Beta_Lev Beta [aw=1/e2f] 

*FGLS
*xtreg return12 Lev nonSE Beta_Lev Beta,re

*Q6
cumul Lev, gen(cuLev)
recode cuLev(0/0.5 = 0)(0.5/1 = 1)
reg return12 c.Lev##cuLev c.nonSE##cuLev c.Beta_Lev##cuLev c.Beta##cuLev, robust
contrast cuLev cuLev#c.Lev cuLev#c.nonSE cuLev#c.Beta_Lev cuLev#c.Beta, overall
