-- ===========================================
-- 02h_SP_Attendance.sql
-- ===========================================
-- Description: Attendances Management SPs
-- Generated from: SQL/02_StoredProcedures.sql
-- ===========================================

USE EducationManagement;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

PRINT '========================================';
PRINT 'Starting: 02h_SP_Attendance.sql';
PRINT '========================================';
GO

-- ===========================================
-- 11. ATTENDANCES MANAGEMENT
-- ===========================================

IF OBJECT_ID('sp_GetAttendancesByClass', 'P') IS NOT NULL DROP PROCEDURE sp_GetAttendancesByClass;
GO
CREATE PROCEDURE sp_GetAttendancesByClass
    @ClassId VARCHAR(50),
    @AttendanceDate DATE = NULL
AS
BEGIN
    SELECT a.*, e.enrollment_id, s.student_code, s.full_name as student_name
    FROM dbo.attendances a
    INNER JOIN dbo.enrollments e ON a.enrollment_id = e.enrollment_id
    INNER JOIN dbo.students s ON e.student_id = s.student_id
    WHERE a.class_id = @ClassId
        AND (@AttendanceDate IS NULL OR CAST(a.attendance_date AS DATE) = @AttendanceDate)
    ORDER BY s.student_code;
END
GO

IF OBJECT_ID('sp_CreateAttendance', 'P') IS NOT NULL DROP PROCEDURE sp_CreateAttendance;
GO
CREATE PROCEDURE sp_CreateAttendance
    @AttendanceId VARCHAR(50),
    @EnrollmentId VARCHAR(50),
    @ClassId VARCHAR(50),
    @AttendanceDate DATETIME,
    @Status NVARCHAR(20),
    @Note NVARCHAR(500) = NULL,
    @CreatedBy VARCHAR(50) = 'system'
AS
BEGIN
    INSERT INTO dbo.attendances (attendance_id, enrollment_id, class_id, attendance_date,
                                  status, note, created_at, created_by)
    VALUES (@AttendanceId, @EnrollmentId, @ClassId, @AttendanceDate, @Status, @Note,
            GETDATE(), @CreatedBy);
END
GO

IF OBJECT_ID('sp_UpdateAttendance', 'P') IS NOT NULL DROP PROCEDURE sp_UpdateAttendance;
GO
CREATE PROCEDURE sp_UpdateAttendance
    @AttendanceId VARCHAR(50),
    @Status NVARCHAR(20),
    @Note NVARCHAR(500) = NULL,
    @UpdatedBy VARCHAR(50) = 'system'
AS
BEGIN
    UPDATE dbo.attendances
    SET status = @Status, note = @Note, updated_at = GETDATE(), updated_by = @UpdatedBy
    WHERE attendance_id = @AttendanceId;
END
GO

-- SP: Get All Attendances
IF OBJECT_ID('sp_GetAllAttendances', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllAttendances;
GO
CREATE PROCEDURE sp_GetAllAttendances
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        a.attendance_id,
        a.enrollment_id,
        a.class_id,
        a.attendance_date,
        a.status,
        a.note,
        a.created_at,
        a.created_by,
        a.updated_at,
        a.updated_by,
        e.student_id,
        s.student_code,
        s.full_name as student_name,
        c.class_code,
        c.class_name
    FROM dbo.attendances a
    INNER JOIN dbo.enrollments e ON a.enrollment_id = e.enrollment_id
    INNER JOIN dbo.students s ON e.student_id = s.student_id
    INNER JOIN dbo.classes c ON a.class_id = c.class_id
    WHERE a.deleted_at IS NULL
    ORDER BY a.attendance_date DESC, s.student_code;
END
GO

-- SP: Get Attendance By ID
IF OBJECT_ID('sp_GetAttendanceById', 'P') IS NOT NULL DROP PROCEDURE sp_GetAttendanceById;
GO
CREATE PROCEDURE sp_GetAttendanceById
    @AttendanceId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        a.attendance_id,
        a.enrollment_id,
        a.class_id,
        a.attendance_date,
        a.status,
        a.note,
        a.created_at,
        a.created_by,
        a.updated_at,
        a.updated_by,
        e.student_id,
        s.student_code,
        s.full_name as student_name,
        c.class_code,
        c.class_name
    FROM dbo.attendances a
    INNER JOIN dbo.enrollments e ON a.enrollment_id = e.enrollment_id
    INNER JOIN dbo.students s ON e.student_id = s.student_id
    INNER JOIN dbo.classes c ON a.class_id = c.class_id
    WHERE a.attendance_id = @AttendanceId AND a.deleted_at IS NULL;
END
GO

-- SP: Get Attendances By Student
IF OBJECT_ID('sp_GetAttendancesByStudent', 'P') IS NOT NULL DROP PROCEDURE sp_GetAttendancesByStudent;
GO
CREATE PROCEDURE sp_GetAttendancesByStudent
    @StudentId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        a.attendance_id,
        a.enrollment_id,
        a.class_id,
        a.attendance_date,
        a.status,
        a.note,
        a.created_at,
        a.created_by,
        a.updated_at,
        a.updated_by,
        e.student_id,
        s.student_code,
        s.full_name as student_name,
        c.class_code,
        c.class_name
    FROM dbo.attendances a
    INNER JOIN dbo.enrollments e ON a.enrollment_id = e.enrollment_id
    INNER JOIN dbo.students s ON e.student_id = s.student_id
    INNER JOIN dbo.classes c ON a.class_id = c.class_id
    WHERE e.student_id = @StudentId AND a.deleted_at IS NULL
    ORDER BY a.attendance_date DESC;
END
GO

-- SP: Get Attendances By Schedule (using timetable_sessions)
IF OBJECT_ID('sp_GetAttendancesBySchedule', 'P') IS NOT NULL DROP PROCEDURE sp_GetAttendancesBySchedule;
GO
CREATE PROCEDURE sp_GetAttendancesBySchedule
    @ScheduleId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        a.attendance_id,
        a.enrollment_id,
        a.class_id,
        a.attendance_date,
        a.status,
        a.note,
        a.created_at,
        a.created_by,
        a.updated_at,
        a.updated_by,
        e.student_id,
        s.student_code,
        s.full_name as student_name,
        c.class_code,
        c.class_name,
        ts.session_id as schedule_id
    FROM dbo.attendances a
    INNER JOIN dbo.enrollments e ON a.enrollment_id = e.enrollment_id
    INNER JOIN dbo.students s ON e.student_id = s.student_id
    INNER JOIN dbo.classes c ON a.class_id = c.class_id
    INNER JOIN dbo.timetable_sessions ts ON ts.class_id = a.class_id
    WHERE ts.session_id = @ScheduleId AND a.deleted_at IS NULL
    ORDER BY a.attendance_date DESC, s.student_code;
END
GO

-- SP: Delete Attendance
IF OBJECT_ID('sp_DeleteAttendance', 'P') IS NOT NULL DROP PROCEDURE sp_DeleteAttendance;
GO
CREATE PROCEDURE sp_DeleteAttendance
    @AttendanceId VARCHAR(50),
    @DeletedBy VARCHAR(50) = 'system'
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.attendances
    SET deleted_at = GETDATE(), deleted_by = @DeletedBy
    WHERE attendance_id = @AttendanceId;
END
GO

PRINT '[OK] Attendances Management SPs created';
GO

-- ===========================================
-- 11. ATTENDANCES MANAGEMENT
-- ===========================================

IF OBJECT_ID('sp_GetAttendancesByClass', 'P') IS NOT NULL DROP PROCEDURE sp_GetAttendancesByClass;
GO
CREATE PROCEDURE sp_GetAttendancesByClass
    @ClassId VARCHAR(50),
    @AttendanceDate DATE = NULL
AS
BEGIN
    SELECT a.*, e.enrollment_id, s.student_code, s.full_name as student_name
    FROM dbo.attendances a
    INNER JOIN dbo.enrollments e ON a.enrollment_id = e.enrollment_id
    INNER JOIN dbo.students s ON e.student_id = s.student_id
    WHERE a.class_id = @ClassId
        AND (@AttendanceDate IS NULL OR CAST(a.attendance_date AS DATE) = @AttendanceDate)
    ORDER BY s.student_code;
END
GO

IF OBJECT_ID('sp_CreateAttendance', 'P') IS NOT NULL DROP PROCEDURE sp_CreateAttendance;
GO
CREATE PROCEDURE sp_CreateAttendance
    @AttendanceId VARCHAR(50),
    @EnrollmentId VARCHAR(50),
    @ClassId VARCHAR(50),
    @AttendanceDate DATETIME,
    @Status NVARCHAR(20),
    @Note NVARCHAR(500) = NULL,
    @CreatedBy VARCHAR(50) = 'system'
AS
BEGIN
    INSERT INTO dbo.attendances (attendance_id, enrollment_id, class_id, attendance_date,
                                  status, note, created_at, created_by)
    VALUES (@AttendanceId, @EnrollmentId, @ClassId, @AttendanceDate, @Status, @Note,
            GETDATE(), @CreatedBy);
END
GO

IF OBJECT_ID('sp_UpdateAttendance', 'P') IS NOT NULL DROP PROCEDURE sp_UpdateAttendance;
GO
CREATE PROCEDURE sp_UpdateAttendance
    @AttendanceId VARCHAR(50),
    @Status NVARCHAR(20),
    @Note NVARCHAR(500) = NULL,
    @UpdatedBy VARCHAR(50) = 'system'
AS
BEGIN
    UPDATE dbo.attendances
    SET status = @Status, note = @Note, updated_at = GETDATE(), updated_by = @UpdatedBy
    WHERE attendance_id = @AttendanceId;
END
GO

PRINT '[OK] Attendances Management SPs created';
GO

PRINT '[OK] Attendances Management SPs completed';
GO
