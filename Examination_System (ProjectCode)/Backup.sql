--==============================================Backup===============================================
-- Daily, Automatic, at 12:00 am

-- backups stored in D:\SQLBackups , this path must exist
-- SQL Server Agent must be running
-- we have 2 jobs for backup
-- one for full backup every Friday
-- And the other for differential backup all other week days
-- each one of them runs autoamtically at 12:00 am

-- First, the full weekly backup
use msdb
--sql server agent stored inside msdb
exec sp_add_job
    @job_name = 'Examination_System_FullBackup',
    @enabled = 1,
    @description = 'Weekly full backup of ITI Examination System Database'

exec sp_add_jobstep
    @job_name = 'Examination_System_FullBackup',
    @step_name = 'Full Backup Step',
    @subsystem = 'TSQL',
    @command = '
    -- main code of backup
    declare @filename nvarchar(max)
    declare @date nvarchar(20)
    set @date = convert(varchar, getdate(), 112)
    -- 112 ==> YYYYMMDD
    set @filename = ''D:\SQLBackups\ExaminationSystem_full''+@date+''.bak''

    backup database iti_examination_system
    to disk = @filename
    with init
    ',
    --job --> server level, TSQL code inside master
    @database_name = 'master'

exec sp_add_schedule
    @schedule_name = 'Weekly_Full_Backup_Schedule',
    @freq_type = 8, --weekly
    -- @freq_type = 4, @freq_interval = 1 if daily
    @freq_interval = 32, --Friday
    @freq_recurrence_factor = 1,  -- every 1 week
    @active_start_time = 000000; --12:00 am

exec sp_attach_schedule
    @job_name = 'Examination_System_FullBackup',
    @schedule_name = 'Weekly_Full_Backup_Schedule'

exec sp_add_jobserver
    @job_name = 'Examination_System_FullBackup'



-- Second, the differential daily backup except Friday
use msdb
exec sp_add_job
    @job_name = 'Examination_System_DifferentialBackup',
    @enabled = 1,
    @description = 'Daily Differential backup of ITI Examination System Database'

exec sp_add_jobstep
    @job_name = 'Examination_System_DifferentialBackup',
    @step_name = 'Differential Backup Step',
    @subsystem = 'TSQL',
    @command = '
    -- main code of backup
    declare @filename nvarchar(max)
    declare @date nvarchar(20)
    set @date = convert(varchar, getdate(), 112)
    set @filename = ''D:\SQLBackups\ExaminationSystem_differential''+@date+''.bak''

    backup database iti_examination_system
    to disk = @filename
    with differential
    ',
    @database_name = 'master'

exec sp_add_schedule
    @schedule_name = 'Daily_Differential_Backup_Schedule',
    @freq_type = 8, --weekly as can't be daily
    @freq_interval = 95, --All days except Friday
    @freq_recurrence_factor = 1,  -- every 1 week
    @active_start_time = 000000; --12:00 am

exec sp_attach_schedule
    @job_name = 'Examination_System_DifferentialBackup',
    @schedule_name = 'Daily_Differential_Backup_Schedule'

exec sp_add_jobserver
    @job_name = 'Examination_System_DifferentialBackup'


-- run full backup manually first to avoid errors
-- if start with day rather than Friday, but Differential backup can't be done without full backup
backup database iti_examination_system
to disk = 'D:\SQLBackups\ExaminationSystem_full_Initial.bak'
