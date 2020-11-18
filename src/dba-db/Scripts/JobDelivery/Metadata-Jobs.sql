-- Load job level metadata
TRUNCATE TABLE dbo.Jobs


INSERT INTO dbo.Jobs (
	[name]
,	[enabled]
,	[description]
,	[category_name]
,	[deployment_mode]
)

-- Job: Job 1
SELECT 
	N'Job 1' AS [name]
,	1 AS [enabled]
,	N'Description of job 1' AS [description]
,	N'DBA - Maintenance' AS [category_name]
,   'CreateUpdate' as [deployment_mode]
