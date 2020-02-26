/*%let intern_name="'bella hu','jack c liu',;*/
%macro check_other_work_status(intbl=master);

	data otherwork_status;
		set &intbl.;
		drop location_region lob_area tribe Health_Status;
		where (lowcase(work_status_today) like  '%others - please specify%' or
			lowcase(work_status_tomorrow) like  '%others - please specify%' or
			lowcase(work_status_today) like  '%for intern only%'  or
			lowcase(work_status_tomorrow) like  '%for intern only%' ) and
			staff_id not in (&intern_id.)
		;
	run;

	proc sort data=otherwork_status;
		by no;
	run;

%mend;


DATA WORK.master_raw;
	LENGTH
		NO                 8
		submit_dt          8
		submit_duration  $ 100
		source           $ 100
		source_detail    $ 100
		source_ip        $ 100
		staff_id           8
/*		name             $ 100*/
/*		lob              $ 100*/
/*		AML_Tribe        $ 100*/
/*		AOC_Tribe        $ 100*/
/*		ASP_Tribe        $ 100*/
		Health_Status  $100
		work_status_today $ 100
		work_hour_today    8
		work_status_tomorrow $ 100
		work_hour_tomorrow   8
		feedback	 $2000.;
	LABEL
		NO               = "No"
		submit_dt        = "Submit datetime"
		submit_duration  = "Submit duration"
		source           = "Source"
		source_detail    = "Source detail"
		source_ip        = "IP Address"
		staff_id         = "Staff ID"
/*		name             = "English Fullname"*/
/*		lob              = "Line of Business"*/
/*		AML_Tribe        = "AMH Tribe "*/
/*		AOC_Tribe        = "AOC Tribe "*/
/*		ASP_Tribe        = "ASP Tribe "*/
		Health_Status = "Health Status"
		work_status_today = "Work Status Today"
		work_hour_today  = "Working hours today"
		work_status_tomorrow = "Plan for Tomorrow"
		work_hour_tomorrow = "Planned working hours tomorrow"
		feedback="Staff Feedback";
	FORMAT
		NO               BEST8.
		submit_dt        DATETIME18.
		submit_duration  $CHAR100.
		source           $CHAR100.
		source_detail    $CHAR100.
		source_ip        $CHAR100.
		staff_id         BEST8.
/*		name             $CHAR100.*/
/*		lob              $CHAR100.*/
/*		AML_Tribe        $CHAR100.*/
/*		AOC_Tribe        $CHAR100.*/
/*		ASP_Tribe        $CHAR100.*/
		Health_Status $CHAR100.
		work_status_today $CHAR100.
		work_hour_today  BEST12.
		work_status_tomorrow $CHAR100.
		work_hour_tomorrow BEST12.
		feedback	 $2000.;
	INFORMAT
		NO               BEST8.
		submit_dt        DATETIME18.
		submit_duration  $CHAR100.
		source           $CHAR100.
		source_detail    $CHAR100.
		source_ip        $CHAR100.
		staff_id         BEST8.
/*		name             $CHAR100.*/
/*		lob              $CHAR100.*/
/*		AML_Tribe        $CHAR100.*/
/*		AOC_Tribe        $CHAR100.*/
/*		ASP_Tribe        $CHAR100.*/
		Health_Status $CHAR100.
		work_status_today $CHAR100.
		work_hour_today  BEST12.
		work_status_tomorrow $CHAR100.
		work_hour_tomorrow BEST12.
		feedback	 $2000.;
	INFILE 'C:\work\Project\Daily Self-report\master_raw.csv'
		LRECL=32767
		firstobs=2
		ENCODING="UTF-8"
		TERMSTR=CRLF
		DLM=','
		MISSOVER
		DSD;
	INPUT
		NO               : ?? BEST8.
		submit_dt        : ?? ANYDTDTM18.
		submit_duration  : $CHAR100.
		source           : $CHAR100.
		source_detail    : $CHAR100.
		source_ip        : $CHAR100.
		staff_id         : ?? BEST8.
/*		name             : $CHAR100.*/
/*		lob              : $CHAR100.*/
/*		AML_Tribe        : $CHAR100.*/
/*		AOC_Tribe        : $CHAR100.*/
/*		ASP_Tribe        : $CHAR100.*/
		Health_Status 	:$CHAR100.
		work_status_today : $CHAR100.
		work_hour_today  : ?? BEST8.
		work_status_tomorrow : $CHAR100.
		work_hour_tomorrow : ?? BEST8.
		feedback	: $2000.;
RUN;

data master;
	format track_date date9.;
	format track_time time9.;
	format location $50.;
	format location_region $50.;
/*	format lob_area $50.;*/
/*	format tribe $50.;*/
	set master_raw;
	location =scan(source_ip,2,'(');
	location=substr(location,1,length(location)-1);

	if location="广东-广州" then
		location_region = "GZ/FS";
	else if location="广东-佛山" then
		location_region= "GZ/FS";
	else if scan(location,1,"-")="国外" then
		location_region="Oversea";
	else  location_region="China(Non-GZ/FS)";
	track_date=datepart(submit_dt);
	track_time=timepart(submit_dt);

	if feedback="(空)" then
		feedback="";

	if feedback="无" then
		feedback="";

	if lowcase(feedback)="na" then
		feedback="";

	if lowcase(feedback)="no" then
		feedback="";
	weekday=weekday(track_date);

		if weekday^=1 and weekday^=7;
/*	if weekday^=7;*/
	drop source source_detail submit_duration submit_dt source_ip 
/*AML_Tribe AOC_Tribe  ASP_Tribe lob*/
;
run;

proc sort data=master;
	by staff_id  track_date track_time;
run;

%let intern_id=45079629 45079710 45079392 45079618 45079625;



/*%check_other_work_status(intbl=master);*/
/**/
/*data interns;*/
/*	set master;*/
/*	keep staff_id  no track_date work_status_tomorrow work_status_today;*/
/*	where staff_id in (&intern_id.) */
/*		or lowcase(work_status_today) like  '%for intern only%' */
/*	;*/
/*run;*/
/**/
/*proc sort data=interns;*/
/*	by no;*/
/*run;*/

libname daily "C:\work\Project\Daily Self-report\data";

data master2;
	set master;
	by staff_id  track_date track_time;
	work_status_today=compress(work_status_today,'"');
	work_status_tomorrow=compress(work_status_tomorrow,'"');

	/*if  work_status_today='No working - Wait for further notice (for Intern only)' then work_status_today='No working - Weekend or public holiday';*/
	/*if  work_status_tomorrow='No working - Wait for further notice (for Intern only)' then work_status_tomorrow='No working - Weekend or public holiday';*/
	if substr(lowcase(work_status_today),1,25) ="working in company office" then
		work_status_today=cats(" ","Work in Office:",scan(work_status_today,2,"〖"));

	if substr(lowcase(work_status_tomorrow),1,25) ="working in company office" then
		work_status_tomorrow=cats(" ","Work in Office:",scan(work_status_tomorrow,2,"〖"));

	if substr(lowcase(work_status_today),1, 23) = 'others - please specify' then
		work_status_today = scan(work_status_today,2,"〖");

	if substr(lowcase(work_status_tomorrow),1, 23) = 'others - please specify' then
		work_status_tomorrow = scan(work_status_tomorrow,2,"〖");

	if last.track_date;
run;

proc freq  data=master2;
table work_status_today work_status_tomorrow ;
run;

proc sql noprint;
	create table daily.master as
		select 
			A.NO,
			A.track_date,
			A.track_time,
			A.staff_id,
			B.name,
			A.location,
			A.location_region,
			B.lob_area,
			B.tribe,
			A.health_status,
			A.work_status_today,
			A.work_hour_today,
			A.work_status_tomorrow,
			A.work_hour_tomorrow,
			A.feedback
		from master2 A
			left join daily.master_header B
				on A.staff_id=B.staff_id
			order by A.NO
	;
quit;

data daily.master;
	set daily.master daily.MASTER_FEB2;
	where name is not null;
run;

proc sort data=daily.master;
	by track_Date track_time;
run;

proc sql  noprint;
	drop table master_raw, master, master2;
quit;