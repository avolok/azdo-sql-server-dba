TRUNCATE TABLE dbo.JobSteps

INSERT INTO dbo.JobSteps 
(
    [job_name]
,   [step_name]
,   [step_id]
,   [cmdexec_success_code]
,   [on_success_action]
,   [on_success_step_id]
,   [on_fail_action]
,   [on_fail_step_id]
,   [retry_attempts]
,   [retry_interval]
,   [subsystem]
,   [command]
,   [database_name]
)

SELECT 
	N'dba - cycle errorlog' AS [job_name]
,	N'dba - cycle errorlog: run stored procedure [sp_cycle_errorlog]' AS [step_name]
,	1 AS [step_id]
,	0 AS [cmdexec_success_code]
,	1 AS [on_success_action]
,	0 AS [on_success_step_id]
,	2 AS [on_fail_action]
,	0 AS [on_fail_step_id]
,	0 AS [retry_attempts]
,	0 AS [retry_interval]
,	N'TSQL' AS [subsystem]
,	N'EXEC sp_cycle_errorlog;' AS [command]
,	N'master' AS [database_name]

UNION ALL

SELECT 
	N'dba - clean backup history' AS [job_name]
,	N'dba - clean backup history: run stored procedure [sp_delete_backuphistory]' AS [step_name]
,	1 AS [step_id]
,	0 AS [cmdexec_success_code]
,	1 AS [on_success_action]
,	0 AS [on_success_step_id]
,	2 AS [on_fail_action]
,	0 AS [on_fail_step_id]
,	0 AS [retry_attempts]
,	0 AS [retry_interval]
,	N'TSQL' AS [subsystem]
,	N'declare @oldest DATETIME  = Getdate()-30; 
exec sp_delete_backuphistory @oldest_date=@oldest;' AS [command]
,	N'msdb' AS [database_name]





 
