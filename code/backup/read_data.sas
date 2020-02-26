DATA WORK.master_raw;
	LENGTH
		NO                 8
		submit_dt          8
		submit_duration  $ 20
		source           $ 20
		source_detail    $ 50
		source_ip        $ 50
		staff_id           8
		name             $ 50
		lob              $ 50
		AML_Tribe        $ 50
		AOC_Tribe        $ 50
		ASP_Tribe        $ 50
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
		name             = "English Fullname"
		lob              = "Line of Business"
		AML_Tribe        = "AMH Tribe "
		AOC_Tribe        = "AOC Tribe "
		ASP_Tribe        = "ASP Tribe "
		work_status_today = "Work Status Today"
		work_hour_today  = "Working hours today"
		work_status_tomorrow = "Plan for Tomorrow"
		work_hour_tomorrow = "Planned working hours tomorrow"
			feedback="Staff Feedback";
	FORMAT
		NO               BEST3.
		submit_dt        DATETIME18.
		submit_duration  $CHAR20.
		source           $CHAR20.
		source_detail    $CHAR20.
		source_ip        $CHAR34.
		staff_id         BEST8.
		name             $CHAR50.
		lob              $CHAR50.
		AML_Tribe        $CHAR50.
		AOC_Tribe        $CHAR50.
		ASP_Tribe        $CHAR50.
		work_status_today $CHAR100.
		work_hour_today  BEST12.
		work_status_tomorrow $CHAR100.
		work_hour_tomorrow BEST12.
			feedback	 $2000.;
	INFORMAT
		NO               BEST3.
		submit_dt        DATETIME18.
		submit_duration  $CHAR20.
		source           $CHAR20.
		source_detail    $CHAR50.
		source_ip        $CHAR50.
		staff_id         BEST8.
		name             $CHAR50.
		lob              $CHAR50.
		AML_Tribe        $CHAR50.
		AOC_Tribe        $CHAR50.
		ASP_Tribe        $CHAR50.
		work_status_today $CHAR100.
		work_hour_today  BEST12.
		work_status_tomorrow $CHAR100.
		work_hour_tomorrow BEST12.
			feedback	 $2000.;
	INFILE 'C:\work\Project\Daily Self-report\master_raw.csv'
		LRECL=278
		firstobs=2
		ENCODING="UTF-8"
		TERMSTR=CRLF
		DLM=','
		MISSOVER
		DSD;
	INPUT
		NO               : ?? BEST3.
		submit_dt        : ?? ANYDTDTM18.
		submit_duration  : $CHAR20.
		source           : $CHAR20.
		source_detail    : $CHAR50.
		source_ip        : $CHAR50.
		staff_id         : ?? BEST8.
		name             : $CHAR50.
		lob              : $CHAR50.
		AML_Tribe        : $CHAR50.
		AOC_Tribe        : $CHAR50.
		ASP_Tribe        : $CHAR50.
		work_status_today : $CHAR100.
		work_hour_today  : ?? BEST8.
		work_status_tomorrow : $CHAR100.
		work_hour_tomorrow : ?? BEST8.
			feedback: $2000.;
RUN;

data master;
	format track_date date9.;
	format track_time time9.;
	format location $50.;
	format location_region $50.;
	format lob_area $50.;
	format tribe $50.;
	set master_raw;
	location =scan(source_ip,2,'(');
	location=substr(location,1,length(location)-1);
	if location="广东-广州" then location_region = "GZ/FS";
	else if location="广东-佛山" then location_region= "GZ/FS";
	else if scan(location,1,"-")="国外" then location_region="Oversea";
	else  location_region="China(Non-GZ/FS)";

	track_date=datepart(submit_dt);
	track_time=timepart(submit_dt);

	if feedback="(空)" then feedback="";
	weekday=weekday(track_date);

	if weekday^=1 and weekday^=7;

	drop source source_detail submit_duration submit_dt source_ip AML_Tribe AOC_Tribe  ASP_Tribe lob;
run;

proc sort data=master;
	by staff_id  track_date track_time;
run;

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


if last.track_date;
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
set daily.master daily.master_jan;
run;

proc sort data=daily.master;
by track_Date track_time  ;
run;

proc sql  noprint;
drop table master_raw, master, master2;
quit;


