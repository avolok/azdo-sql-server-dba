-- Load jobs metadata
:r .\JobDelivery\Metadata-Jobs.sql
:r .\JobDelivery\Metadata-JobSteps.sql
:r .\JobDelivery\Metadata-JobSchedules.sql

-- Trigger deployment of jobs
EXEC dbo.usp_jobs_RunDeployment