/*Sets data library */
libname d "M:\datasets";
/*Imports one data file */
proc import
OUT = work.ALL DATAFILE= "M:\datasets\ALL.csv"
DBMS = csv replace;
run;



/*question  2 */
data work.all;
set d.ALL;
where vax_lot is not null;
run;

proc sort data = work.all; by vax_lot; run;

data try (keep = Vaers_ID Vax_lot Adverse_Events Symptom1 Symptom2 Symptom3 Symptom4 Symptom5);
set all;

number_missing=cmiss(of symptom1-symptom5);
Adverse_Events =5 - number_missing;

run;


proc sql;
create table part2 as
select vaers_id, Vax_lot,
Adverse_Events, Symptom1, Symptom2, Symptom3, Symptom4, Symptom5,
count (vax_lot) as VaxLot_Count
from try
group by vax_lot
;
quit;


proc sql;
create table part2_1 as
select vaers_id, Vax_lot,
Adverse_Events,
count (vax_lot) as VaxLot_Count
from try
group by vax_lot
order by VaxLot_Count desc
;
quit;


proc sql;
create table part2_2 as
select distinct Vax_lot,
sum(Adverse_Events) as TotalReportofAdverseEvent,
VaxLot_Count
from part2_1
group by vax_lot
order by VaxLot_Count desc
;
quit;


/*question 3*/
/* join the NUMDAYS into the VAX_COUNT data set*/
proc sql ;
create table part3 as
select a.VAERS_ID, a.NUMDAYS, b.VAX_LOT, b.VAXLOT_Count
from work.all a inner join part2_1 b
on a.VAERS_ID = b.VAERS_ID
;
quit;

/*select distince LOT and compute the average NUMDAYS*/
proc sql;
	create table part3_2 as
	select distinct(VAX_LOT) , mean(NUMDAYS) as meanNUMDAYS, VAXLOT_Count
		 from 	part3				
		 group by VAX_LOT ;
quit;

/* sort the data set from highest VAX_count to lowest*/
proc sort data = part3_2; by descending VAXLOT_Count vax_lot; run;

/* select the top 10 obs*/
proc sql;
create table part3_3 as 
select vax_lot,meanNUMDAYS
 from part3_2 (OBS=10)
;
 quit;


/*plot the graph with x axis is lot and y axis is average NUMDAYS*/
title 'AVERAGE NUMDAYS of TOP 10 LOTS';
axis1 label=('LOT');
axis2 label=(a=90 'Average NUMDAYS');
proc gchart data=part3_3;
   vbar vax_lot / sumvar=meanNUMDAYS maxis=axis1 raxis=axis2;
run;
quit; 


/*select the top 1 lots, 
top 1 lots has 4042 obs had adverse event*/
proc sql;
create table Part3_4 as 
	select VAERS_ID, NUMDAYS,VAX_LOT, VAXLOT_Count
	from Part3 
	where VAXLOT_Count= 4042;
quit;

/*formatting and creating the bin*/
proc format;
value myThing
1-7 = '1-7'
7-14 = '7-14'
14-90 = '14-90'
90-400 = '>90'
0 ='within 1 day'
. = 'No info'
/* Other values */
other = [best.];
run;
/* use mything format in dataset part3_4*/
data test;
set Part3_4;
format NUMDAYS myThing.;
run;

/*plot the gragh*/
title 'NUMDAYS distribution of the 016L20A LOT';
proc freq data=test;
    table NUMDAYS / nopercent nocum;
run;










