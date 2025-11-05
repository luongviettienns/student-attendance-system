-- ===========================================
-- 02k_SP_Timetable.sql
-- ===========================================
-- Description: Timetable Management SPs
-- Generated from: SQL/02_StoredProcedures.sql
-- ===========================================

USE EducationManagement;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

PRINT '========================================';
PRINT 'Starting: 02k_SP_Timetable.sql';
PRINT '========================================';
GO
GO

-- =====================================================================
-- TIMETABLE CONFLICT CHECKS
-- =====================================================================
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- Overlap helper explained in comments: two intervals [a,b) & [c,d) overlap if a < d AND c < b
IF OBJECT_ID('dbo.sp_CheckTimetableConflicts','P') IS NOT NULL
    DROP PROCEDURE dbo.sp_CheckTimetableConflicts;
GO
CREATE PROCEDURE dbo.sp_CheckTimetableConflicts
    @SessionId      VARCHAR(50) = NULL, -- nullable when creating
    @ClassId        VARCHAR(50),
    @SubjectId      VARCHAR(50),
    @LecturerId     VARCHAR(50) = NULL,
    @RoomId         VARCHAR(50) = NULL,
    @SchoolYearId   VARCHAR(50) = NULL,
    @WeekNo         INT = NULL,
    @Weekday        INT,
    @StartTime      TIME,
    @EndTime        TIME
AS
BEGIN
    SET NOCOUNT ON;

    -- 1) Lecturer conflicts
    SELECT TOP 100
        'LECTURER' AS conflict_type,
        ts.session_id AS existing_session_id,
        ts.week_no, ts.weekday, ts.start_time, ts.end_time,
        c.class_id, c.class_code, c.class_name,
        r.room_code
    FROM dbo.timetable_sessions ts
    INNER JOIN dbo.classes c ON c.class_id = ts.class_id
    LEFT JOIN dbo.rooms r ON r.room_id = ts.room_id
    WHERE @LecturerId IS NOT NULL
      AND ts.lecturer_id = @LecturerId
      AND ts.weekday = @Weekday
      AND (ts.week_no = @WeekNo OR ts.week_no IS NULL OR @WeekNo IS NULL)
      AND (ts.end_time > @StartTime AND @EndTime > ts.start_time)
      AND (ts.deleted_at IS NULL)
      AND (@SessionId IS NULL OR ts.session_id <> @SessionId);

    -- 2) Room conflicts
    SELECT TOP 100
        'ROOM' AS conflict_type,
        ts.session_id AS existing_session_id,
        ts.week_no, ts.weekday, ts.start_time, ts.end_time,
        c.class_id, c.class_code, c.class_name,
        r.room_code
    FROM dbo.timetable_sessions ts
    INNER JOIN dbo.classes c ON c.class_id = ts.class_id
    LEFT JOIN dbo.rooms r ON r.room_id = ts.room_id
    WHERE @RoomId IS NOT NULL
      AND ts.room_id = @RoomId
      AND ts.weekday = @Weekday
      AND (ts.week_no = @WeekNo OR ts.week_no IS NULL OR @WeekNo IS NULL)
      AND (ts.end_time > @StartTime AND @EndTime > ts.start_time)
      AND (ts.deleted_at IS NULL)
      AND (@SessionId IS NULL OR ts.session_id <> @SessionId);

    -- 3) Student conflicts (students of target class colliding other sessions)
    SELECT TOP 200
        'STUDENT' AS conflict_type,
        ts.session_id AS existing_session_id,
        e2.student_id,
        s2.student_code,
        s2.full_name AS student_name,
        ts.week_no, ts.weekday, ts.start_time, ts.end_time,
        c2.class_id, c2.class_code, c2.class_name
    FROM dbo.enrollments e -- students in the target class
    INNER JOIN dbo.students s2 ON s2.student_id = e.student_id
    INNER JOIN dbo.enrollments e2 ON e2.student_id = e.student_id AND e2.deleted_at IS NULL
    INNER JOIN dbo.timetable_sessions ts ON ts.class_id = e2.class_id AND ts.deleted_at IS NULL
    INNER JOIN dbo.classes c2 ON c2.class_id = ts.class_id
    WHERE e.class_id = @ClassId AND e.deleted_at IS NULL
      AND ts.weekday = @Weekday
      AND (ts.week_no = @WeekNo OR ts.week_no IS NULL OR @WeekNo IS NULL)
      AND (ts.end_time > @StartTime AND @EndTime > ts.start_time)
      AND (@SessionId IS NULL OR ts.session_id <> @SessionId)
      AND (e2.class_id <> @ClassId);

    -- 4) Capacity check
    DECLARE @capacity INT = NULL, @enrolled INT = NULL;
    IF @RoomId IS NOT NULL
        SELECT @capacity = capacity FROM dbo.rooms WHERE room_id = @RoomId;
    SELECT @enrolled = COUNT(1) FROM dbo.enrollments WHERE class_id = @ClassId AND deleted_at IS NULL;
    SELECT @capacity AS room_capacity, @enrolled AS enrolled, CASE WHEN @capacity IS NOT NULL AND @enrolled > @capacity THEN 1 ELSE 0 END AS is_over_capacity;
END
GO

-- Student timetable by year-week
IF OBJECT_ID('dbo.sp_GetStudentTimetableByWeek','P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetStudentTimetableByWeek;
GO
CREATE PROCEDURE dbo.sp_GetStudentTimetableByWeek
    @StudentId VARCHAR(50),
    @Year INT,
    @WeekNo INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        ts.session_id,
        ts.week_no,
        ts.weekday,
        ts.start_time,
        ts.end_time,
        ts.period_from,
        ts.period_to,
        ts.status,
        c.class_id, c.class_code, c.class_name,
        s.subject_id, s.subject_name,
        l.lecturer_id, l.full_name AS lecturer_name,
        r.room_id, r.room_code,
        sy.school_year_id, sy.year_code
    FROM dbo.timetable_sessions ts
    INNER JOIN dbo.classes c ON c.class_id = ts.class_id
    INNER JOIN dbo.subjects s ON s.subject_id = ts.subject_id
    LEFT JOIN dbo.lecturers l ON l.lecturer_id = ts.lecturer_id
    LEFT JOIN dbo.rooms r ON r.room_id = ts.room_id
    LEFT JOIN dbo.school_years sy ON sy.school_year_id = ts.school_year_id
    INNER JOIN dbo.enrollments e ON e.class_id = ts.class_id AND e.student_id = @StudentId AND e.deleted_at IS NULL
    WHERE (ts.week_no = @WeekNo OR ts.week_no IS NULL)
      AND (sy.start_date IS NULL OR YEAR(sy.start_date) = @Year OR YEAR(sy.end_date) = @Year)
      AND (ts.deleted_at IS NULL)
    ORDER BY ts.weekday, ts.start_time;
END
GO

-- Lecturer timetable by year-week
IF OBJECT_ID('dbo.sp_GetLecturerTimetableByWeek','P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetLecturerTimetableByWeek;
GO
CREATE PROCEDURE dbo.sp_GetLecturerTimetableByWeek
    @LecturerId VARCHAR(50),
    @Year INT,
    @WeekNo INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        ts.session_id,
        ts.week_no,
        ts.weekday,
        ts.start_time,
        ts.end_time,
        ts.period_from,
        ts.period_to,
        ts.status,
        c.class_id, c.class_code, c.class_name,
        s.subject_id, s.subject_name,
        r.room_id, r.room_code,
        sy.school_year_id, sy.year_code
    FROM dbo.timetable_sessions ts
    INNER JOIN dbo.classes c ON c.class_id = ts.class_id
    INNER JOIN dbo.subjects s ON s.subject_id = ts.subject_id
    LEFT JOIN dbo.rooms r ON r.room_id = ts.room_id
    LEFT JOIN dbo.school_years sy ON sy.school_year_id = ts.school_year_id
    WHERE ts.lecturer_id = @LecturerId
      AND (ts.week_no = @WeekNo OR ts.week_no IS NULL)
      AND (sy.start_date IS NULL OR YEAR(sy.start_date) = @Year OR YEAR(sy.end_date) = @Year)
      AND (ts.deleted_at IS NULL)
    ORDER BY ts.weekday, ts.start_time;
END
GO
CREATE PROCEDURE dbo.sp_AutoCreateCohort
    @StartYear INT,
    @DurationYears INT = 4,

PRINT '[OK] Timetable SPs completed';
GO

-- ===========================================
-- SCHEDULE MANAGEMENT SPs
-- ===========================================

-- SP: Get All Schedules (using timetable_sessions)
IF OBJECT_ID('sp_GetAllSchedules', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllSchedules;
GO
CREATE PROCEDURE sp_GetAllSchedules
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        ts.session_id as schedule_id,
        ts.class_id,
        ts.subject_id,
        ts.lecturer_id,
        ts.room_id,
        ts.school_year_id,
        ts.week_no,
        ts.weekday,
        ts.start_time,
        ts.end_time,
        ts.period_from,
        ts.period_to,
        ts.recurrence,
        ts.status,
        ts.notes,
        ts.created_at,
        ts.created_by,
        ts.updated_at,
        ts.updated_by,
        c.class_code,
        c.class_name,
        s.subject_code,
        s.subject_name,
        l.full_name as lecturer_name,
        r.room_code
    FROM dbo.timetable_sessions ts
    LEFT JOIN dbo.classes c ON ts.class_id = c.class_id
    LEFT JOIN dbo.subjects s ON ts.subject_id = s.subject_id
    LEFT JOIN dbo.lecturers l ON ts.lecturer_id = l.lecturer_id
    LEFT JOIN dbo.rooms r ON ts.room_id = r.room_id
    WHERE ts.deleted_at IS NULL
    ORDER BY ts.weekday, ts.start_time;
END
GO

-- SP: Get Schedule By ID
IF OBJECT_ID('sp_GetScheduleById', 'P') IS NOT NULL DROP PROCEDURE sp_GetScheduleById;
GO
CREATE PROCEDURE sp_GetScheduleById
    @ScheduleId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        ts.session_id as schedule_id,
        ts.class_id,
        ts.subject_id,
        ts.lecturer_id,
        ts.room_id,
        ts.school_year_id,
        ts.week_no,
        ts.weekday,
        ts.start_time,
        ts.end_time,
        ts.period_from,
        ts.period_to,
        ts.recurrence,
        ts.status,
        ts.notes,
        ts.created_at,
        ts.created_by,
        ts.updated_at,
        ts.updated_by,
        c.class_code,
        c.class_name,
        s.subject_code,
        s.subject_name,
        l.full_name as lecturer_name,
        r.room_code
    FROM dbo.timetable_sessions ts
    LEFT JOIN dbo.classes c ON ts.class_id = c.class_id
    LEFT JOIN dbo.subjects s ON ts.subject_id = s.subject_id
    LEFT JOIN dbo.lecturers l ON ts.lecturer_id = l.lecturer_id
    LEFT JOIN dbo.rooms r ON ts.room_id = r.room_id
    WHERE ts.session_id = @ScheduleId AND ts.deleted_at IS NULL;
END
GO

-- SP: Get Schedules By Class
IF OBJECT_ID('sp_GetSchedulesByClass', 'P') IS NOT NULL DROP PROCEDURE sp_GetSchedulesByClass;
GO
CREATE PROCEDURE sp_GetSchedulesByClass
    @ClassId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        ts.session_id as schedule_id,
        ts.class_id,
        ts.subject_id,
        ts.lecturer_id,
        ts.room_id,
        ts.school_year_id,
        ts.week_no,
        ts.weekday,
        ts.start_time,
        ts.end_time,
        ts.period_from,
        ts.period_to,
        ts.recurrence,
        ts.status,
        ts.notes,
        ts.created_at,
        ts.created_by,
        ts.updated_at,
        ts.updated_by,
        c.class_code,
        c.class_name,
        s.subject_code,
        s.subject_name,
        l.full_name as lecturer_name,
        r.room_code
    FROM dbo.timetable_sessions ts
    LEFT JOIN dbo.classes c ON ts.class_id = c.class_id
    LEFT JOIN dbo.subjects s ON ts.subject_id = s.subject_id
    LEFT JOIN dbo.lecturers l ON ts.lecturer_id = l.lecturer_id
    LEFT JOIN dbo.rooms r ON ts.room_id = r.room_id
    WHERE ts.class_id = @ClassId AND ts.deleted_at IS NULL
    ORDER BY ts.weekday, ts.start_time;
END
GO

PRINT '[OK] Schedule Management SPs created';
GO