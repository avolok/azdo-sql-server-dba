-- Load job step level metadata
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

-- Job: Job 1
-- Step 1:

SELECT 
	N'Job 1' AS [job_name]
,	N'Job 1 - Step 1' AS [step_name]
,	1 AS [step_id]
,	0 AS [cmdexec_success_code]
,	1 AS [on_success_action]
,	0 AS [on_success_step_id]
,	2 AS [on_fail_action]
,	0 AS [on_fail_step_id]
,	0 AS [retry_attempts]
,	0 AS [retry_interval]
,	N'TSQL' AS [subsystem]
,	N'PRINT ''Hello World''' AS [command]
,	N'dba-db' AS [database_name]
