PROC IMPORT OUT= AFE2014F.cpi 
            DATAFILE= "D:\GitHub\Coursework\Finance\Advanced Financial E
conometrics 2014F\Assignment III\WorkingData\cpi.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
