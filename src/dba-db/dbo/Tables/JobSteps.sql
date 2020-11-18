CREATE TABLE [dbo].[JobSteps](
	[job_name] [sysname] NOT NULL,
	[step_name] [sysname] NOT NULL,
	[step_id] [int] NOT NULL,
	[cmdexec_success_code] [int] NOT NULL,
	[on_success_action] [int] NOT NULL,
	[on_success_step_id] [int] NOT NULL,
	[on_fail_action] [int] NOT NULL,
	[on_fail_step_id] [int] NOT NULL,
	[retry_attempts] [int] NOT NULL,
	[retry_interval] [int] NOT NULL,
	[subsystem] [nvarchar](40) NOT NULL,
	[command] [nvarchar](max) NOT NULL,
	[database_name] [sysname] NOT NULL
) ON [PRIMARY]