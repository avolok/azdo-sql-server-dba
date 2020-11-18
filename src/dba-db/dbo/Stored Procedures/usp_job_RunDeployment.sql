CREATE PROC dbo.usp_job_RunDeployment
AS
DECLARE @Deployment_JobName sysname
DECLARE @Deployment_Mode varchar(50)
DECLARE @Deployment_JobExists bit


PRINT 'Starting job deployment'

DECLARE CT_DeployJobs CURSOR FOR
SELECT 
	j.[name] as JobName
,	j.deployment_mode as JobDeploymentMode
FROM dbo.Jobs j


OPEN CT_DeployJobs

FETCH NEXT FROM CT_DeployJobs INTO @Deployment_JobName, @Deployment_Mode
WHILE @@FETCH_STATUS = 0
BEGIN	
 
		EXEC dbo.usp_jobs_DeployJob @Deployment_JobName


FETCH NEXT FROM CT_DeployJobs INTO @Deployment_JobName, @Deployment_Mode
END

CLOSE CT_DeployJobs
DEALLOCATE CT_DeployJobs