    /**********************************************************************
    *   PRODUCT:   SAS
    *   VERSION:   9.4
    *   CREATOR:   External File Interface
    *   DATE:      30JUN14
    *   DESC:      Generated SAS Datastep Code
    *   TEMPLATE SOURCE:  (None Specified.)
    ***********************************************************************/
/*导入数据*/
/*
proc import datafile ="E:\Dropbox\Gap Year\GSM\金融计量\第一次作业\RawData\Dalyr\Dalyr (1).xlsx"
out = temp
dbms = excel replace;
getnames = yes;
run;

%macro excel(datapath=, dataname =, datanu=);
%do i=1 %to %datanum;
proc import datafile = "%datapath&dataname (&i).xls"
out = &dataname&i replace;
%end;
%mend;
%xlsimport
*/
data WORK.MAIN;
infile 'E:\Dropbox\Gap Year\GSM\金融计量\第一次作业\WorkingData\Stocks.csv' delimiter = ',' MISSOVER DSD firstobs=2;
input
       StkID
	   Date
	   Dreturn
	   Mreturn
	   Lev               
       ;
       if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
       run;
data Y2011;
	set MAIN;
	where Date < 20120101;
	*if Trddt < 20120101 then output Y2011;
run;

data Y2012;
	set MAIN;
	where Date >= 20120101;
	*if Trddt >= 20120101 then output Y2012;
run;

/*计算alpha,beta,和u*/
proc sort data = y2011;
by StkID;
run;

proc reg data = Y2011 outest = BETA2011 noprint;
	by StkID;
	var Mreturn Dreturn;
	model Dreturn = Mreturn;
quit;

proc sort data = Y2011;
	by StkID;
run;

proc sort data = BETA2011;
	by StkID;
run;

data beta2011;
	set BETA2011;
	rename Mreturn = beta;
	rename Intercept = alpha;
run;


data Y2011;
	merge beta2011 Y2011;
	by StkID;
	u = Dreturn - alpha - beta*Mreturn;
	label alpha = "Alpha" beta = "Beta";
run;

/*Q1.*/
data Y2011SAMPLE;
	set y2011;
	where StkID = 1;
	*if StkID =1 then output y2011sample;
run;
proc arima data = Y2011SAMPLE;
	identify var = u nlag = 5;
run;
/*
data y2011sample;
	set y2011sample;
	by date;
	lu = lag(u);
run;

proc sort data = y2011sample;
	by date;
run;



proc reg data = y2011sample;
	model u = lu;
run;

/*Q2*/

/*Q3*/
proc sort data = y2012;
	by StkID;
run;

proc means data = y2012;
	var Dreturn Lev;
	by StkID;
	output out = meantemp(drop = _TYPE_ _FREQ_);
run;

data r2012;
	set meantemp;
	where _STAT_ = "MEAN";
	drop _STAT_;
run;

data return;
	merge beta2011 r2012;
	by StkID;
run;

proc reg data = RETURN;
	var Lev Alpha Beta DReturn;
	model dReturn = Lev Alpha Beta;
run;
