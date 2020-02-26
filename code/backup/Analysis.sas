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

	if track_date=&analysis_date;
	where staff_id  not in (&intern_id.) and lob_area not in ("MGMT");
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
	where lowcase(work_status_today) like '%work in office%';
run;

%let N_inoffice=0;

proc sql noprint;
	select count(*) into: N_inoffice from work_in_office;
quit;

data work_in_office_nextday;
	set current;
	keep staff_id name lob_area work_status_tomorrow  work_hour_tomorrow;
	where lowcase(work_status_tomorrow) like  '%work in office%';
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

data location_change;
	set current_data;

	if location^=last_location and location^='' and last_location^='' and 
		not (location="广东-广州" and last_location="广东-佛山") and
		not (location="广东-佛山" and last_location="广东-广州")
	;
	keep staff_id name track_date location last_location lob_area;
run;

%let N_loc=0;

proc sql noprint;
	select count(*) into: N_loc from location_change;
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

%macro report;
	ods graphics on/width=900px height=300px noborder;
	title "Work Status of &analysis_date_txt.  - All Staff of GAC Guangzhou";

	proc sgplot data=current_data noautolegend;
		hbar work_status_today/group=work_status_today datalabel   datalabelattrs=(size=16px);
		xaxis label="N of Staff";
		yaxis label=" ";
	run;

	/*proc sgplot data=current_data;*/
	/*hbar lob_area/ group=work_status_today  groupdisplay=cluster datalabel ;*/
	/*run;*/
	title "Work Status of &analysis_date_txt.  by Line of Business";

	proc sgpanel data=current_data noautolegend;
		panelby lob_area /novarname columns=1;
		hbar work_status_today / group=work_status_today groupdisplay=cluster datalabel  datalabelattrs=(size=16px);
		colaxis label="N of staff";
		rowaxis  valueattrs=(size=16px);
	run;

	title "Work Status of &analysis_date_txt.  by Line of Business & Tribe";
	ods graphics on/width=900px height=400px noborder;

	proc sgpanel data=current_data noautolegend;
		panelby lob_area tribe /novarname;
		hbar work_status_today / group=work_status_today groupdisplay=cluster datalabel;
		colaxis label="N of staff";
	run;

	%if &N_inoffice. >0 %then
		%do;
			title "&analysis_date_txt.  - Staff Who Work in Office Today";

			proc print data=work_in_office label obs="No";
				/*				var staff_id name lob_area location lalastation;*/
				/*				label location="Location of Today" last_location="Location of Last Survey";*/
			run;

		%end;

	ods graphics on/width=900px height=300px noborder;
	title "Work Schedule of Next Day - All Staff of GAC Guangzhou";

	proc sgplot data=current_data noautolegend;
		hbar work_status_tomorrow/group=work_status_tomorrow datalabel   datalabelattrs=(size=16px);
		xaxis label="N of Staff";
		yaxis label=" ";
	run;

	/*proc sgplot data=current_data;*/
	/*hbar lob_area/ group=work_status_today  groupdisplay=cluster datalabel ;*/
	/*run;*/
	title "Work Schedule of Next Day  by Line of Business";

	proc sgpanel data=current_data noautolegend;
		panelby lob_area /novarname columns=1;
		hbar work_status_tomorrow / group=work_status_tomorrow groupdisplay=cluster datalabel  datalabelattrs=(size=16px);
		colaxis label="N of staff";
		rowaxis  valueattrs=(size=16px);
	run;

	title "Work Schedule of Next Day by Line of Business & Tribe";
	ods graphics on/width=900px height=400px noborder;

	proc sgpanel data=current_data noautolegend;
		panelby lob_area tribe /novarname;
		hbar work_status_tomorrow / group=work_status_tomorrow groupdisplay=cluster datalabel;
		colaxis label="N of staff";
	run;

	%if &N_inoffice_plan. >0 %then
		%do;
			title "&analysis_date_txt.  - Staff Who Plan to Work in Office Tomorrow";

			proc print data=work_in_office_nextday label obs="No";
				/*				var staff_id name lob_area location last_location;*/
				/*				label location="Location of Today" last_location="Location of Last Survey";*/
			run;

		%end;

	%if &N_feedback. >0 %then
		%do;
			title "&analysis_date_txt.  - Staff feedback";

			proc print data=feedback label obs="No";
				/*				var staff_id name lob_area location last_location;*/
				/*				label location="Location of Today" last_location="Location of Last Survey";*/
			run;

		%end;

	ods graphics on/width=500px height=300px noborder;
	title "Staff Location Summary of &analysis_date_txt.   GAC Guangzhou";

	proc sgplot data=current_data noautolegend;
		vbar location_region/group=location_region datalabel   datalabelattrs=(size=16px);
		xaxis label="Staff Location";
		yaxis label="N of Staff";
	run;

	ods graphics off;

	%if &N_loc. >0 %then
		%do;
			title "&analysis_date_txt.  - Staff with Location Change - Based on IP address";

			proc print data=location_change label obs="No";
				var staff_id name lob_area location last_location;
				label location="Location of Today" last_location="Location of Last Survey";
			run;

		%end;

	/*	title "&analysis_date_txt.  - Staff Current Location - GAC Guangzhou";*/
	/**/
	/*	proc print data=location label obs="No";*/
	/*	run;*/
	%if &N_noAns. >0 %then
		%do;
			title "&analysis_date_txt.  - Survey Not Submitted: Staff list";

			proc print data=noanswer label obs="No";
				var staff_id name lob_area tribe;
			run;

		%end;

	title;

	/*ods html5 close;*/
	FILENAME csvdata1 "C:\work\Project\Daily Self-report\export\work_daily_rpt_&analysis_date_txt._alldata.csv" ENCODING="utf-8";

	proc export data = CURRENT_DATA (drop=last_location) 
		outfile = csvdata1
		dbms = csv  replace;
	run;

	FILENAME csvdata2 "C:\work\Project\Daily Self-report\export\work_daily_rpt_&analysis_date_txt..csv" ENCODING="utf-8";

	proc export data = CURRENT_DATA (keep=staff_id name work_status_today work_hour_today work_status_tomorrow work_hour_tomorrow  track_date lob_area tribe) 
		outfile = csvdata2
		dbms = csv  replace;
	run;

%mend;

%report;

proc datasets nolist lib=work;
	delete _:  Noanswer location current last;
quit;