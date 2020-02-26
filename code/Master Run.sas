%macro report_new(internal=Y);
	%let _resolution_=180;
	%let breakspace = 25pt;
	%let rowvaluefontsize=10;
	%let datalabelfontsize=16;

	%if &internal.=Y %then
		%do;	
			%let pdf_file_nm=Work Status Daily Report &analysis_date_txt. - Internal Use%str(.)pdf;
		%end;
	%if &internal.=N %then
		%do;	
			%let pdf_file_nm=Work Status Daily Report &analysis_date_txt.%str(.)pdf;
		%end;


	%let pdf_out_file=&pdf_full_path.&pdf_file_nm;
	%put ***&pdf_out_file.****;

	title "GAC Guangzhou Daily Work Status Report - &analysis_date_txt.";
	footnote "GAC Guangzhou D%str(&)A Team  -  &analysis_date_txt.";

	options nodate;
	ods noproctitle;
	ods escapechar='^';
	ods pdf STYLE=fancyprinter 
		dpi=&_resolution_.  compress=9 startpage=never notoc bookmarkgen=no file="&pdf_out_file.";
	ods pdf startpage=now;
/*	options number pageno=1;*/
	ods pdf text="^S={font_size=24pt}"; /* spacer */
	ods pdf text="^S={font_size=24pt font_weight=bold just=center}GAC Guangzhou Daily Work Status Report - &analysis_date_txt.";
	ods pdf text="^S={font_size=24pt}"; /* spacer */

	ods graphics on/width=700px height=200px noborder;
	ods pdf text="^S={font_size=16pt font_weight=bold just=center}Work Status of  All Staff of GAC Guangzhou";
	proc sgplot data=current_data noautolegend;
		hbar work_status_today/group=work_status_today datalabel  DATALABELFITPOLICY=NONE datalabelattrs=(size=&datalabelfontsize.);
		xaxis label="N of Staff" ;
		yaxis label=" "  valueattrs=(size=&rowvaluefontsize.);
	run;

	ods graphics on/width=700px height=280px noborder;
	ods pdf text="^S={font_size=&breakspace.}"; /* spacer */
	ods pdf text="^S={font_size=16pt font_weight=bold just=center}Work Status  by Line of Business";
	proc sgpanel data=current_data noautolegend;
		panelby lob_area /novarname columns=1;
		hbar work_status_today / group=work_status_today groupdisplay=cluster datalabel  DATALABELFITPOLICY=NONE datalabelattrs=(size=&datalabelfontsize.);
		colaxis label="N of staff";
		rowaxis  valueattrs=(size=&rowvaluefontsize.);
	run;

	ods pdf text="^S={font_size=&breakspace.}"; /* spacer */
	ods pdf text="^S={font_size=16pt font_weight=bold just=center}Work Status by Line of Business & Tribe";
	ods graphics on/width=700px height=280px noborder;

	proc sgpanel data=current_data noautolegend;
		panelby lob_area tribe /novarname;
		hbar work_status_today / group=work_status_today groupdisplay=cluster DATALABELFITPOLICY=NONE datalabel  datalabelattrs=(size=&datalabelfontsize.);
		colaxis label="N of staff";
		rowaxis  valueattrs=(size=&rowvaluefontsize.);
	run;

	%if &N_inoffice. >0 and &internal.=Y %then
		%do;
		ods pdf text="^S={font_size=&breakspace.}"; /* spacer */
		ods pdf text="^S={font_size=16pt font_weight=bold just=center} Staff Who Work in Office or Have Special Arrangement Today";

			proc print data=work_in_office label obs="No";
				/*				var staff_id name lob_area location lalastation;*/
				/*				label location="Location of Today" last_location="Location of Last Survey";*/
			run;

		%end;

	ods graphics on/width=700px height=200px noborder;
		ods pdf text="^S={font_size=&breakspace.}"; /* spacer */
		ods pdf text="^S={font_size=16pt font_weight=bold just=center}Work Schedule of Next Day - All Staff of GAC Guangzhou";

	proc sgplot data=current_data noautolegend;
		hbar work_status_tomorrow/group=work_status_tomorrow datalabel DATALABELFITPOLICY=NONE  datalabelattrs=(size=&datalabelfontsize.);
		xaxis label="N of Staff" ;
		yaxis label=" "  valueattrs=(size=&rowvaluefontsize.);
	run;

	/*proc sgplot data=current_data;*/
	/*hbar lob_area/ group=work_status_today  groupdisplay=cluster datalabel ;*/
	/*run;*/

	ods graphics on/width=700px height=280px noborder;

	ods pdf text="^S={font_size=&breakspace.}"; /* spacer */
	ods pdf text="^S={font_size=16pt font_weight=bold just=center}Work Schedule of Next Day  by Line of Business";

	proc sgpanel data=current_data noautolegend;
		panelby lob_area /novarname columns=1;
		hbar work_status_tomorrow / group=work_status_tomorrow groupdisplay=cluster datalabel DATALABELFITPOLICY=NONE datalabelattrs=(size=&datalabelfontsize.);
		colaxis label="N of staff";
		rowaxis  valueattrs=(size=&rowvaluefontsize.);
	run;

	ods pdf text="^S={font_size=&breakspace.}"; /* spacer */
	ods pdf text="^S={font_size=16pt font_weight=bold just=center}Work Schedule of Next Day by Line of Business & Tribe";
	ods graphics on/width=700px height=280px noborder;

	proc sgpanel data=current_data noautolegend;
		panelby lob_area tribe /novarname;
		hbar work_status_tomorrow / group=work_status_tomorrow groupdisplay=cluster DATALABELFITPOLICY=NONE datalabel  datalabelattrs=(size=&datalabelfontsize.);
		colaxis label="N of staff";
		rowaxis  valueattrs=(size=&rowvaluefontsize.);
	run;

	%if &N_inoffice_plan. >0 and &internal.=Y %then
		%do;
			ods pdf text="^S={font_size=&breakspace.}";
			ods pdf text="^S={font_size=16pt font_weight=bold just=center} Staff Who Plan to Work in Office or Have Special Arrangement Tomorrow";

			proc print data=work_in_office_nextday label obs="No";
			run;
		%end;

	%if &N_feedback. >0 and &internal.=Y %then
		%do;
			ods pdf text="^S={font_size=&breakspace.}";
			ods pdf text="^S={font_size=16pt font_weight=bold just=center} Staff feedback";

			proc print data=feedback label obs="No";

			run;

		%end;

	ods graphics on/width=500px height=200px noborder;
	ods pdf text="^S={font_size=&breakspace.}"; /* spacer */
	ods pdf text="^S={font_size=16pt font_weight=bold just=center}Staff Location Summary of GAC Guangzhou";
	proc sgplot data=current_data noautolegend;
		hbar location_region/group=location_region datalabel DATALABELFITPOLICY=NONE  datalabelattrs=(size=&datalabelfontsize.);
		xaxis label="N of Staff" ;
		yaxis label=" "  valueattrs=(size=&rowvaluefontsize.);
	run;

	ods graphics off;

/*
	%if &N_back_to_GD. >0 and &internal.=Y%then
		%do;
			ods pdf text="^S={font_size=&breakspace.}"; 
			ods pdf text="^S={font_size=16pt font_weight=bold just=center} Staff who travel back to Guangdong from other province/country";

			proc print data=back_to_GD label obs="No";
				var staff_id name lob_area location last_location;
				label location="Location of Today" last_location="Location of Last Survey";
			run;

		%end;

	%if &N_travel_in_GD. >0 and &internal.=Y%then
		%do;
			ods pdf text="^S={font_size=&breakspace.}"; 
			ods pdf text="^S={font_size=16pt font_weight=bold just=center} Staff who travel in Guangdong";
			proc print data=travel_in_GD label obs="No";
				var staff_id name lob_area location last_location;
				label location="Location of Today" last_location="Location of Last Survey";
			run;

		%end;

	%if &N_travel_out_GD. >0 and &internal.=Y%then
		%do;
			ods pdf text="^S={font_size=&breakspace.}"; 
			ods pdf text="^S={font_size=16pt font_weight=bold just=center} Staff who travel outside Guangdong";

			proc print data=travel_out_GD label obs="No";
				var staff_id name lob_area location last_location;
				label location="Location of Today" last_location="Location of Last Survey";
			run;

		%end;
*/

	%if  &internal.=Y %then
		%do;

	ods graphics on/width=500px height=200px noborder;
	ods pdf text="^S={font_size=&breakspace.}"; /* spacer */
	ods pdf text="^S={font_size=16pt font_weight=bold just=center}Health Status of  All Staff of GAC Guangzhou";
	proc sgplot data=current_data noautolegend;
		hbar Health_status/group=Health_status datalabel  DATALABELFITPOLICY=NONE datalabelattrs=(size=&datalabelfontsize.);
		xaxis label="N of Staff" ;
		yaxis label=" "  valueattrs=(size=&rowvaluefontsize.);
	run;

	ods graphics off;

	%end;

	%if &N_unhealthy. >0 and &internal.=Y %then
		%do;
			ods pdf text="^S={font_size=&breakspace.}"; /* spacer */
			ods pdf text="^S={font_size=16pt font_weight=bold just=center} Staff Who may have Health Issue Today";

			proc print data=unhealthy label obs="No";
			run;

		%end;



	%if &N_noAns. >0 and &internal.=Y  %then
		%do;
			ods pdf text="^S={font_size=&breakspace.}"; /* spacer */
			ods pdf text="^S={font_size=16pt font_weight=bold just=center} Survey Not Submitted: Staff list";

			proc print data=noanswer label obs="No";
				var staff_id name lob_area tribe;
			run;

		%end;

	title;
	ods pdf close;

%mend;


%let pdf_full_path=C:\work\Project\Daily Self-report\report\;


%report_new(internal=N);

proc datasets nolist lib=work;
delete _:;
quit;

%report_new(internal=Y);

proc datasets nolist lib=work;
delete _:;
quit;



	/*ods html5 close;*/
	FILENAME csvdata1 "&pdf_full_path.work_daily_rpt_&analysis_date_txt._alldata.csv" ENCODING="utf-8";

	proc export data = CURRENT_DATA 
		outfile = csvdata1
		dbms = csv  replace;
	run;

	FILENAME csvdata2 "&pdf_full_path.work_daily_rpt_&analysis_date_txt..csv" ENCODING="utf-8";

	proc export data = CURRENT_DATA (keep=staff_id name work_status_today work_hour_today work_status_tomorrow work_hour_tomorrow  track_date lob_area tribe) 
		outfile = csvdata2
		dbms = csv  replace;
	run;