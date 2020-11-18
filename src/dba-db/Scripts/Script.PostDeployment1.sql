-- Reload jobs metadata
:r .\JobDelivery\Metadata-Jobs.sql
:r .\JobDelivery\Metadata-JobSteps.sql
:r .\JobDelivery\Metadata-JobSchedules.sql

-- Deploy jobs
EXEC dbo.usp_job_RunDeployment