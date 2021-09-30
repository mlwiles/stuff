SET QUOTED_IDENTIFIER ON
USE VeeamBackup
GO
UPDATE [Backup.Model.JobSessions]
SET [state] = '-1' --Set Stopped state
WHERE [state] != '-1' --For every job that is not in a Stopped state
GO