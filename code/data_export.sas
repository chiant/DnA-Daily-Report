	/*ods html5 close;*/
	FILENAME csvdata1 "C:\work\Project\Daily Self-report\export\work_daily_rpt_&analysis_date_txt._alldata.csv" ENCODING="utf-8";

	proc export data = CURRENT_DATA 
		outfile = csvdata1
		dbms = csv  replace;
	run;

	FILENAME csvdata2 "C:\work\Project\Daily Self-report\export\work_daily_rpt_&analysis_date_txt..csv" ENCODING="utf-8";

	proc export data = CURRENT_DATA (keep=staff_id name work_status_today work_hour_today work_status_tomorrow work_hour_tomorrow  track_date lob_area tribe) 
		outfile = csvdata2
		dbms = csv  replace;
	run;