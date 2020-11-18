CREATE PROCEDURE [dbo].[usp_jobs_DeployJob] 
@Job_Name sysname 
AS
SET NOCOUNT ON

-- Procedure level variables
DECLARE @PRC_job_exists bit
DECLARE @PRC_job_deployment_mode varchar(50)


-- Job level variables:
DECLARE @jobId BINARY(16)
DECLARE @Job_Enabled bit
DECLARE @Job_description nvarchar(2000) 
DECLARE @Job_category_name nvarchar(4000) 
DECLARE @Job_owner_login_name sysname 


-- Job step level variables:
DECLARE @JobStep_step_id INT
DECLARE @JobStep_step_name sysname
DECLARE @JobStep_cmdexec_success_code int
DECLARE @JobStep_on_success_action int
DECLARE @JobStep_on_success_step_id int
DECLARE @JobStep_on_fail_action int
DECLARE @JobStep_on_fail_step_id int
DECLARE @JobStep_retry_attempts int
DECLARE @JobStep_retry_interval int
DECLARE @JobStep_subsystem nvarchar(40)
DECLARE @JobStep_command nvarchar(max)
DECLARE @JobStep_database_name sysname


-- Job Schedule level variables:
DECLARE @JobSchedule_Type varchar(50)
DECLARE @JobSchedule_name sysname
DECLARE @JobSchedule_enabled bit
DECLARE @JobSchedule_freq_type int
DECLARE @JobSchedule_freq_interval int
DECLARE @JobSchedule_freq_subday_type int
DECLARE @JobSchedule_freq_subday_interval int
DECLARE @JobSchedule_freq_relative_interval int
DECLARE @JobSchedule_freq_recurrence_factor int
DECLARE @JobSchedule_active_start_date int
DECLARE @JobSchedule_active_end_date int
DECLARE @JobSchedule_active_start_time int
DECLARE @JobSchedule_active_end_time int

-- Starting transactional deployment
SET XACT_ABORT ON
BEGIN TRAN

BEGIN TRY 

-- Phase 1: creating job

-- Step 1.1: Check if job already exists on the server and if job definitions exists in metadata

IF EXISTS (
	SELECT * FROM msdb.dbo.sysjobs WHERE [name] = @Job_Name
)
	SET @PRC_job_exists = 1
ELSE
	SET @PRC_job_exists = 0


IF NOT EXISTS (
	SELECT * FROM dbo.Jobs WHERE [name] = @Job_Name
)
BEGIN
	PRINT CONCAT('Metadata for job "',@Job_Name,'" does not exists, terminating the execution of [dbo].[usp_jobs_DeployJob]')
	RETURN
END


-- Step 1.2: Retreive job level metadata

SELECT 
	@Job_Enabled = [enabled]
,	@Job_description = [description]
,	@Job_category_name = category_name
,	@Job_owner_login_name = SUSER_SNAME(0x1)
,	@PRC_job_deployment_mode = deployment_mode
FROM dbo.Jobs 
WHERE [name] = @Job_Name


-- Step 1.4: Create Job Category if missing
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=@Job_category_name AND category_class=1)
	EXEC msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=@Job_category_name


IF (@PRC_job_exists = 1 AND @PRC_job_deployment_mode IN ( 'Drop', 'ReCreate') )
BEGIN
	PRINT CONCAT('[',@Job_Name,']: Removing the job') 

	EXEC msdb.dbo.sp_delete_job  @job_name = @Job_Name; 
END


IF ((@PRC_job_exists = 0 AND @PRC_job_deployment_mode IN ('CreateUpdate', 'CreateOnly') ) OR  @PRC_job_deployment_mode IN ('ReCreate') )
BEGIN
    PRINT CONCAT('[',@Job_Name,']: Creating the job') 
	EXEC    msdb.dbo.sp_add_job 
			@job_name= @Job_Name,
			@enabled=@Job_Enabled, 		
			@description=@Job_description,
			@category_name=@Job_category_name,
			@owner_login_name=@Job_owner_login_name,
			@job_id = @jobId OUTPUT

	EXEC    msdb.dbo.sp_add_jobserver @job_name = @Job_Name, @server_name = N'(local)'
	
END

ELSE IF(@PRC_job_exists = 1 AND @PRC_job_deployment_mode IN ('CreateUpdate') )
BEGIN
    PRINT CONCAT('[',@Job_Name,']: Updating the job') 
	EXEC    msdb.dbo.sp_update_job
			@job_name= @Job_Name,
			@enabled=@Job_Enabled, 			
			@description=@Job_description,
			@category_name=@Job_category_name
			
END

ELSE IF (@PRC_job_exists = 1 AND @PRC_job_deployment_mode IN ( 'CreateOnly') )
BEGIN
PRINT CONCAT('[',@Job_Name,']: job already exists. Deployment mode is "CreateOnly", terminating the execution of [dbo].[usp_jobs_DeployJob]') 
END
ELSE IF (@PRC_job_exists = 0 AND @PRC_job_deployment_mode IN ( 'Drop') )
BEGIN
	PRINT CONCAT('[',@Job_Name,']: Job doesn''t exists, terminating the execution of [dbo].[usp_jobs_DeployJob]') 	
END



-- Phase 2: Job steps:

IF (@PRC_job_deployment_mode IN ('CreateUpdate', 'ReCreate') OR (@PRC_job_deployment_mode IN ('CreateOnly') AND @PRC_job_exists = 0 ) )
BEGIN
	

	-- Step 2.1: Clean existing job steps:
	DECLARE ct_JobSteps CURSOR FOR
	SELECT js.step_id FROM msdb.dbo.sysjobsteps js
	JOIN msdb.dbo.sysjobs j on js.job_id = j.job_id
	WHERE j.name = @Job_Name 
	order by js.step_id DESC

	OPEN ct_JobSteps

	FETCH NEXT FROM ct_JobSteps into @JobStep_step_id

	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		EXEC msdb.dbo.sp_delete_jobstep @job_name=@Job_Name, @step_id=@JobStep_step_id

		FETCH NEXT FROM ct_JobSteps into @JobStep_step_id
	END

	CLOSE ct_JobSteps
	DEALLOCATE ct_JobSteps



	-- Step 2.2: Re-create job steps:	

	DECLARE ct_JobSteps CURSOR FOR
	SELECT	
			[step_name]
	,		[step_id]
	,		[cmdexec_success_code]
	,		[on_success_action]
	,		[on_success_step_id]
	,		[on_fail_action]
	,		[on_fail_step_id]
	,		[retry_attempts]
	,		[retry_interval]	
	,		[subsystem]
	,		[command]
	,		[database_name]
	FROM dbo.JobSteps
	WHERE [job_name] = @Job_Name
	ORDER BY [step_id]

	OPEN ct_JobSteps

	FETCH NEXT FROM ct_JobSteps INTO 
		@JobStep_step_name
	,	@JobStep_step_id
	,	@JobStep_cmdexec_success_code
	,	@JobStep_on_success_action
	,	@JobStep_on_success_step_id
	,	@JobStep_on_fail_action
	,	@JobStep_on_fail_step_id
	,	@JobStep_retry_attempts
	,	@JobStep_retry_interval
	,	@JobStep_subsystem
	,	@JobStep_command
	,	@JobStep_database_name
	


	WHILE @@FETCH_STATUS = 0
	BEGIN
	
		PRINT CONCAT('[',@Job_Name,']: Adding job step "',@JobStep_step_name, '"') 
	
		EXEC    msdb.dbo.sp_add_jobstep 
				@job_name=@Job_Name,
				@step_name=@JobStep_step_name, 
				@step_id=@JobStep_step_id, 
				@cmdexec_success_code=@JobStep_cmdexec_success_code, 
				@on_success_action=@JobStep_on_success_action, 
				@on_success_step_id=@JobStep_on_success_step_id, 
				@on_fail_action=@JobStep_on_fail_action, 
				@on_fail_step_id=@JobStep_on_fail_step_id, 
				@retry_attempts=@JobStep_retry_attempts, 
				@retry_interval=@JobStep_retry_interval, 				
				@subsystem=@JobStep_subsystem, 
				@command=@JobStep_command, 
				@database_name=@JobStep_database_name


		FETCH NEXT FROM ct_JobSteps INTO 
			@JobStep_step_name
		,	@JobStep_step_id
		,	@JobStep_cmdexec_success_code
		,	@JobStep_on_success_action
		,	@JobStep_on_success_step_id
		,	@JobStep_on_fail_action
		,	@JobStep_on_fail_step_id
		,	@JobStep_retry_attempts
		,	@JobStep_retry_interval		
		,	@JobStep_subsystem
		,	@JobStep_command
		,	@JobStep_database_name
		
	END

	CLOSE ct_JobSteps
	DEALLOCATE ct_JobSteps

END

    -- Phase 3: Schedules

IF (@PRC_job_deployment_mode IN ('ReCreate') OR (@PRC_job_deployment_mode IN ('CreateOnly') AND @PRC_job_exists = 0 ) )
BEGIN

	-- Step 3.2: Create job schedule			

	DECLARE ct_JobSchedules CURSOR FOR
		SELECT 
			[schedule_name]
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
		FROM dbo.JobSchedules	



	OPEN ct_JobSchedules

	FETCH NEXT FROM ct_JobSchedules 
	INTO	@JobSchedule_name
	,		@JobSchedule_enabled
	,		@JobSchedule_freq_type
	,		@JobSchedule_freq_interval
	,		@JobSchedule_freq_subday_type
	,		@JobSchedule_freq_subday_interval
	,		@JobSchedule_freq_relative_interval
	,		@JobSchedule_freq_recurrence_factor
	,		@JobSchedule_active_start_date
	,		@JobSchedule_active_end_date
	,		@JobSchedule_active_start_time
	,		@JobSchedule_active_end_time

	WHILE @@FETCH_STATUS = 0
	BEGIN
	     
		IF EXISTS (
			SELECT * FROM msdb.dbo.sysschedules ss
			JOIN msdb.dbo.sysjobschedules sjs ON ss.schedule_id = sjs.schedule_id
			JOIN msdb.dbo.sysjobs sj ON sjs.job_id = sj.job_id
			WHERE sj.name = @Job_Name
				AND ss.name = @JobSchedule_name
		)
		BEGIN
			PRINT CONCAT('[',@Job_Name,']: Schedule "',@JobSchedule_name, '" already exists') 

		END
		ELSE
		BEGIN

			PRINT CONCAT('[',@Job_Name,']: Creating a ',lower(@JobSchedule_Type),' schedule "',@JobSchedule_name, '"') 
	
			EXEC msdb.dbo.sp_add_jobschedule 
				@job_name = @Job_Name,
				@name=@JobSchedule_name, 
				@enabled=@JobSchedule_enabled, 
				@freq_type=@JobSchedule_freq_type, 
				@freq_interval=@JobSchedule_freq_interval, 
				@freq_subday_type=@JobSchedule_freq_subday_type, 
				@freq_subday_interval=@JobSchedule_freq_subday_interval, 
				@freq_relative_interval=@JobSchedule_freq_relative_interval, 
				@freq_recurrence_factor=@JobSchedule_freq_recurrence_factor, 
				@active_start_date=@JobSchedule_active_start_date, 
				@active_end_date=@JobSchedule_active_end_date, 
				@active_start_time=@JobSchedule_active_start_time, 
				@active_end_time=@JobSchedule_active_end_time

		END
		FETCH NEXT FROM ct_JobSchedules 
		INTO	@JobSchedule_name
		,		@JobSchedule_enabled
		,		@JobSchedule_freq_type
		,		@JobSchedule_freq_interval
		,		@JobSchedule_freq_subday_type
		,		@JobSchedule_freq_subday_interval
		,		@JobSchedule_freq_relative_interval
		,		@JobSchedule_freq_recurrence_factor
		,		@JobSchedule_active_start_date
		,		@JobSchedule_active_end_date
		,		@JobSchedule_active_start_time
		,		@JobSchedule_active_end_time
	END

	CLOSE ct_JobSchedules
	DEALLOCATE ct_JobSchedules

END


END TRY
BEGIN CATCH

	THROW;
	IF @@TRANCOUNT > 0
	ROLLBACK TRAN


END CATCH

COMMIT TRAN