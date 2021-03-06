-- Load job level metadata
TRUNCATE TABLE dbo.JobSchedules

INSERT INTO [dbo].[JobSchedules]
(
	[job_name]
,	[schedule_name]
,	[schedule_enabled]
,	[freq_type]
,	[freq_interval]
,	[freq_subday_type]
,	[freq_subday_interval]
,	[freq_relative_interval]
,	[freq_recurrence_factor]
,	[active_start_date]
,	[active_end_date]
,	[active_start_time]
,	[active_end_time]
)

-- Job: dba - cycle errorlog
SELECT 
    'dba - cycle errorlog' as [job_name]
,	'Daily @ 20:00' as [schedule_name]
,	1 as [schedule_enabled]
,	4 as [freq_type]
,	1 as [freq_interval]
,	1 as [freq_subday_type]
,	0 as [freq_subday_interval]
,	0 as [freq_relative_interval]
,	0 as [freq_recurrence_factor]	
,	20100101 as [active_start_date]
,	99991231 as [active_end_date]	
,	200000 as [active_start_time]
,	235959 as [active_end_time]

UNION ALL

-- Job: dba - clean backup history
SELECT 
    'dba - clean backup history' as [job_name]
,	'Daily @ 21:00' as [schedule_name]
,	1 as [schedule_enabled]
,	4 as [freq_type]
,	1 as [freq_interval]
,	1 as [freq_subday_type]
,	0 as [freq_subday_interval]
,	0 as [freq_relative_interval]
,	0 as [freq_recurrence_factor]	
,	20100101 as [active_start_date]
,	99991231 as [active_end_date]	
,	210000 as [active_start_time]
,	235959 as [active_end_time]
