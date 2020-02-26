/*%let analysis_date='31JAN2020'd;*/
/*%let analysis_date_txt=31JAN2020;*/
%let analysis_date=%sysfunc(date());
%let analysis_date_txt=%sysfunc(date(),date9.);

/*intern list
Jack C Liu 45079629
Evelyn Yang 45079710
Hazel Han 45079392
Bella Hu 45079618
Steven m x Song 45079625
*/
%let intern_id=45079629 45079710 45079392 45079618 45079625;

data current;
	set daily.master;

	if work_status_tomorrow='8' then do;
	work_status_tomorrow='Work from home';
	work_hour_tomorrow=8;
end;
if work_status_today='8' then do;
	work_status_today='Work from home';
	work_hour_today=8;
end;

	if track_date=&analysis_date;
	where staff_id  not in (&intern_id.) and lob_area not in ("MGMT");
run;


data false_intern;
set current;
drop location_region lob_area tribe Health_Status;
where (lowcase(work_status_today) like  '%others - please specify%' or
 lowcase(work_status_tomorrow) like  '%others - please specify%' or
lowcase(work_status_today) like  '%for intern only%'  or
lowcase(work_status_tomorrow) like  '%for intern only%' ) and
staff_id not in (&intern_id.)
;
run;

title 'Wrong Intern Work Status';
proc print data=false_intern;
var no staff_id  track_date track_time  name work_status_today work_status_tomorrow;
run;
title 'work status summary';
proc freq data=current;
	table work_status_today work_status_tomorrow;
run;

proc sql noprint;
	select max(track_Date) into: lastdate
		from daily.master
			where track_date<&analysis_date
	;
quit;

%put ***&lastdate.***;

data last;
	set daily.master;

	if track_date=&lastdate;
run;

data work_in_office;
	set current;
	keep staff_id name lob_area work_status_today work_hour_today;
	where lowcase(work_status_today) like '%work in office%' or
 lowcase(work_status_today) not in ("no working - weekend or public holiday","work from home")
;
run;

%let N_inoffice=0;

proc sql noprint;
	select count(*) into: N_inoffice from work_in_office;
quit;

data work_in_office_nextday;
	set current;
	keep staff_id name lob_area work_status_tomorrow  work_hour_tomorrow;
	where lowcase(work_status_tomorrow) like  '%work in office%' or
	 lowcase(work_status_tomorrow) not in ("no working - weekend or public holiday","work from home");
run;

%let N_inoffice_plan=0;

proc sql noprint;
	select count(*) into: N_inoffice_plan from work_in_office_nextday;
quit;

data feedback;
	set current;
	keep staff_id name lob_area location work_status_today feedback;
	where feedback is not null;
run;

%let N_feedback=0;

proc sql noprint;
	select count(*) into: N_feedback from feedback;
quit;

proc sql noprint;
	create table current_data as
		select A.*,
			B.location as last_location
		from current A
			left join last B
				on A.staff_id= B.staff_id
	;
quit;

data back_to_GD travel_out_GD travel_in_GD  ;
	set current_data;
	format current_province $50.;
	format current_city $50.;
	format last_province $50.;
	format last_city $50.;

	current_province=scan(location,1,'-');
	current_city=scan(location,2,'-');

	last_province=scan(last_location,1,'-');
	last_city=scan(last_location,2,'-');

	if location^=last_location and location^='' and last_location^='' and 
		not (location="广东-广州" and last_location="广东-佛山") and
		not (location="广东-佛山" and last_location="广东-广州")
	;
	if current_province="广东"  and last_province^="广东" then output back_to_GD;
	else if current_province="广东"  and last_province="广东" then output travel_in_GD;
	else output travel_out_GD;

	keep staff_id name track_date location last_location lob_area 
			current_province current_city last_province last_city
		;
run;

data travel_in_GD;
	set travel_in_GD;
	if current_city^='未知' and last_city^='未知';
run;

%let N_back_to_GD=0;

proc sql noprint;
	select count(*) into: N_back_to_GD from back_to_GD;
quit;

%let N_travel_out_GD=0;

proc sql noprint;
	select count(*) into: N_travel_out_GD from travel_out_GD;
quit;

%let N_travel_in_GD=0;

proc sql noprint;
	select count(*) into: N_travel_in_GD from travel_in_GD;
quit;


proc sql noprint;
	create table noanswer as
		select * from daily.master_header
			where staff_id not in (select staff_id from current_data) and 
				staff_id not in (&intern_id.) 
				and lob_area not in ("MGMT")
			order by lob_area, tribe
	;
quit;

%let N_noAns=0;

proc sql noprint;
	select count(*) into: N_noAns from noanswer;
quit;

proc sql  noprint;
	create table location as
		select location,
			count(*) as N_person label="N of Staff"
		from current_data
			group by location
				order by  N_person desc, location
	;
quit;

proc sql noprint;
	create table health_status as
		select health_status,
			count(*) as N_Health_Status label="N of Staff"
		from current_data
			group by health_status
			order by N_Health_Status desc
		;
quit;

data unhealthy;
	set current_data;
	keep staff_id Health_Status location name lob_area  work_status_today work_status_tomorrow;
	where health_status not in ("Feeling well and healthy");
run;


%let N_unhealthy=0;

proc sql noprint;
	select count(*) into: N_unhealthy from unhealthy;
quit;

