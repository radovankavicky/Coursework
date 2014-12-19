clear all
set more off

cd "D:\GitHub\Coursework\Finance\Advanced Financial Econometrics 2014F\Assignment III\WorkingData"
import excel "..\RawData\CPI.xls", sheet("È«¹ú") firstrow allstring

rename A month
rename B CPI

drop if strlen(CPI)<=3
destring CPI, replace


gen CPIc = CPI[1]
replace CPIc = CPI*CPIc[_n-1]/100 if _n>1
gen monthNO = _n

keep if mod(monthNO,3) == 0
gen quarterNO = _n
label variable quarterNO "Quarter no. since Jan. 2010"

twoway line CPIc quarterNO, title("Quaterly CPI") note("Source: www.cei.gov.cn")
graph export ..\Graph\CPI.png, replace

rename CPIc cpi
export excel cpi using "cpi.xls", firstrow(variables) replace
/*

*1. Unit-root, DF test
tsset quarterNO
dfuller CPIc
dfuller CPIc, lags(4)

gen logCPI = log(CPIc)
dfuller D.logCPI
dfuller D.logCPI, lags(4)

*2. ACF PACF
ac d.logCPI
pac d.logCPI


*3.ARMA
arima logCPI, ar(1) ma(1)
