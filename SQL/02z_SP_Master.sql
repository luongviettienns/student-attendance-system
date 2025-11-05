-- ===========================================
-- 02z_SP_Master.sql
-- ===========================================
-- Description: Master file to execute all stored procedures
-- Usage: Run this file to create all SPs in correct order
-- Note: For SQL Server Management Studio, use File > Open > File
--       and execute each file in order, or use sqlcmd with -i option
-- ===========================================

USE EducationManagement;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

PRINT '========================================';
PRINT 'STORED PROCEDURES MASTER EXECUTION';
PRINT '========================================';
PRINT '';
PRINT 'To execute all SPs, run files in this order:';
PRINT '  1. 02a_SP_Users.sql';
PRINT '  2. 02b_SP_Organization.sql';
PRINT '  3. 02c_SP_Academic.sql';
PRINT '  4. 02d_SP_Students.sql';
PRINT '  5. 02e_SP_Lecturers.sql';
PRINT '  6. 02f_SP_Subjects.sql';
PRINT '  7. 02g_SP_Classes.sql';
PRINT '  8. 02h_SP_Attendance.sql';
PRINT '  9. 02i_SP_Grades.sql';
PRINT '  10. 02j_SP_System.sql';
PRINT '  11. 02k_SP_Timetable.sql';
PRINT '  12. 02l_SP_Administrative.sql';
PRINT '';
PRINT 'Or use PowerShell script: Run-All-SPs.ps1';
PRINT '========================================';
GO
