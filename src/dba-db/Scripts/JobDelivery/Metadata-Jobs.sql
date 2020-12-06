TRUNCATE TABLE dbo.Jobs

INSERT INTO dbo.Jobs (
	[name]
,	[category_name]
,	[description]
,	[deployment_mode]
)
-- Job: dba - cycle errorlog'
SELECT 
	N'dba - cycle errorlog' AS [name]
,	N'DBA Jobs' AS [category_name]
,	N'Closes and cycles the current error log file by running [sp_cycle_errorlog]' AS [description]
,   'CreateUpdate' as [deployment_mode]

UNION ALL

-- Job: dba - clean backup history'
SELECT 
	N'dba - clean backup history' AS [name]
,	N'DBA Jobs' AS [category_name]
,	N'Reduces the size of the backup and restore history tables by running [sp_cycle_errorlog]' AS [description]
,   'CreateUpdate' as [deployment_mode]

