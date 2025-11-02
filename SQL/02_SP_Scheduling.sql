-- ===========================================
-- 02_SP_Scheduling.sql
-- ===========================================
-- Description: Timetable and Administrative Classes Management
-- ===========================================

USE EducationManagement;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

PRINT '========================================';
PRINT 'Starting: 02_SP_Scheduling.sql';
PRINT 'Scheduling Management SPs';
PRINT '========================================';
GO

IF OBJECT_ID('sp_AssignStudentToAdminClass', 'P') IS NOT NULL
    DROP PROCEDURE sp_AssignStudentToAdminClass;
GO
CREATE PROCEDURE sp_AssignStudentToAdminClass
    @StudentId VARCHAR(50),
    @AdminClassId VARCHAR(50),
    @UpdatedBy VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if student exists
        IF NOT EXISTS (SELECT 1 FROM students WHERE student_id = @StudentId AND deleted_at IS NULL)
        BEGIN
            THROW 50009, N'KhĂ´ng tĂ¬m tháº¥y sinh viĂªn', 1;
        END
        
        -- Check if class exists
        IF NOT EXISTS (SELECT 1 FROM administrative_classes WHERE admin_class_id = @AdminClassId AND deleted_at IS NULL)
        BEGIN
            THROW 50002, N'KhĂ´ng tĂ¬m tháº¥y lá»›p hĂ nh chĂ­nh', 1;
        END
        
        -- Check if class is full
        DECLARE @MaxStudents INT, @CurrentStudents INT;
        SELECT @MaxStudents = max_students, @CurrentStudents = current_students
        FROM administrative_classes
        WHERE admin_class_id = @AdminClassId;
        
        IF @CurrentStudents >= @MaxStudents
        BEGIN
            THROW 50010, N'Lá»›p Ä‘Ă£ Ä‘áº§y', 1;
        END
        
        -- Check if student already has a class
        DECLARE @OldClassId VARCHAR(50);
        SELECT @OldClassId = admin_class_id FROM students WHERE student_id = @StudentId;
        
        -- If student already in a class, decrease that class count
        IF @OldClassId IS NOT NULL AND @OldClassId != @AdminClassId
        BEGIN
            UPDATE administrative_classes
            SET current_students = current_students - 1,
                updated_at = GETDATE(),
                updated_by = @UpdatedBy
            WHERE admin_class_id = @OldClassId;
        END
        
        -- Assign student to new class
        UPDATE students
        SET admin_class_id = @AdminClassId
        WHERE student_id = @StudentId;
        
        -- Increase new class count (only if different from old class)
        IF @OldClassId IS NULL OR @OldClassId != @AdminClassId
        BEGIN
            UPDATE administrative_classes
            SET current_students = current_students + 1,
                updated_at = GETDATE(),
                updated_by = @UpdatedBy
            WHERE admin_class_id = @AdminClassId;
        END
        
        COMMIT TRANSACTION;
        
        SELECT 1 AS Success, N'PhĂ¢n sinh viĂªn vĂ o lá»›p thĂ nh cĂ´ng' AS Message;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

IF OBJECT_ID('sp_AutoCreateCohort', 'P') IS NOT NULL 
    DROP PROCEDURE sp_AutoCreateCohort;
GO
CREATE PROCEDURE sp_AutoCreateCohort
    @StartYear INT,                    -- 2025
    @DurationYears INT = 4,            -- Máº·c Ä‘á»‹nh 4 nÄƒm (Ä‘áº¡i há»c)
    @CreatedBy VARCHAR(50) = 'system'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Validate
        IF @StartYear < 2020 OR @StartYear > 2050
            THROW 50001, N'âŒ NÄƒm báº¯t Ä‘áº§u khĂ´ng há»£p lá»‡ (2020-2050)', 1;
        
        DECLARE @CohortId VARCHAR(50) = CONCAT('AY', CAST(@StartYear AS VARCHAR(4)));
        DECLARE @CohortCode NVARCHAR(10) = CONCAT(N'K', CAST(RIGHT(CAST(@StartYear AS VARCHAR(4)), 2) AS NVARCHAR(2)));
        DECLARE @EndYear INT = @StartYear + @DurationYears;
        DECLARE @YearName NVARCHAR(50) = CONCAT(CAST(@StartYear AS NVARCHAR(4)), N'-', CAST(@EndYear AS NVARCHAR(4)));
        DECLARE @Description NVARCHAR(500) = CONCAT(N'NiĂªn khĂ³a ', @CohortCode, N' (', CAST(@StartYear AS NVARCHAR(4)), N'-', CAST(@EndYear AS NVARCHAR(4)), N')');
        
        -- Check exists
        IF EXISTS (SELECT 1 FROM academic_years WHERE academic_year_id = @CohortId)
            THROW 50002, N'âŒ NiĂªn khĂ³a Ä‘Ă£ tá»“n táº¡i!', 1;
        
        -- Insert cohort
        INSERT INTO academic_years (
            academic_year_id, year_name, cohort_code, start_year, end_year, duration_years,
            is_active, created_at, created_by
        )
        VALUES (
            @CohortId, @YearName, @CohortCode, @StartYear, @EndYear, @DurationYears,
            0, GETDATE(), @CreatedBy
        );
        
        -- Auto-create school years for this cohort
        DECLARE @i INT = 0;
        WHILE @i < @DurationYears
        BEGIN
            EXEC sp_AutoCreateSchoolYear 
                @StartYear = @StartYear + @i,
                @AcademicYearId = @CohortId,
                @CreatedBy = @CreatedBy;
            SET @i = @i + 1;
        END
        
        SELECT 
            'SUCCESS' AS Status,
            @CohortId AS CohortId,
            @CohortCode AS CohortCode,
            @YearName AS YearName,
            @DurationYears AS DurationYears,
            N'âœ… ÄĂ£ táº¡o niĂªn khĂ³a ' + @CohortCode + N' vĂ  ' + CAST(@DurationYears AS NVARCHAR) + N' nÄƒm há»c' AS Message;
            
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

IF OBJECT_ID('sp_AutoCreateSchoolYear', 'P') IS NOT NULL 
    DROP PROCEDURE sp_AutoCreateSchoolYear;
GO
CREATE PROCEDURE sp_AutoCreateSchoolYear
    @StartYear INT,                           -- 2024
    @AcademicYearId VARCHAR(50) = NULL,       -- Optional link to cohort
    @CreatedBy VARCHAR(50) = 'system'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @SchoolYearId VARCHAR(50) = 'SY' + CAST(@StartYear AS VARCHAR);
        DECLARE @YearCode NVARCHAR(20) = CAST(@StartYear AS NVARCHAR) + N'-' + CAST(@StartYear + 1 AS NVARCHAR);
        DECLARE @YearName NVARCHAR(100) = N'NÄƒm há»c ' + @YearCode;
        
        -- Dates according to Vietnamese university calendar
        DECLARE @StartDate DATE = DATEFROMPARTS(@StartYear, 9, 1);      -- 01-Sep
        DECLARE @EndDate DATE = DATEFROMPARTS(@StartYear + 1, 6, 30);   -- 30-Jun
        DECLARE @Sem1Start DATE = DATEFROMPARTS(@StartYear, 9, 1);      -- 01-Sep
        DECLARE @Sem1End DATE = DATEFROMPARTS(@StartYear + 1, 1, 31);   -- 31-Jan
        DECLARE @Sem2Start DATE = DATEFROMPARTS(@StartYear + 1, 2, 1);  -- 01-Feb
        DECLARE @Sem2End DATE = DATEFROMPARTS(@StartYear + 1, 6, 30);   -- 30-Jun
        
        -- Check exists
        IF EXISTS (SELECT 1 FROM school_years WHERE school_year_id = @SchoolYearId)
        BEGIN
            PRINT '   â ï¸  School year ' + @YearCode + ' already exists';
            RETURN;
        END
        
        -- Insert school year
        INSERT INTO school_years (
            school_year_id, year_code, year_name, academic_year_id,
            start_date, end_date,
            semester1_start, semester1_end, semester2_start, semester2_end,
            is_active, current_semester,
            created_at, created_by
        )
        VALUES (
            @SchoolYearId, @YearCode, @YearName, @AcademicYearId,
            @StartDate, @EndDate,
            @Sem1Start, @Sem1End, @Sem2Start, @Sem2End,
            0, NULL,
            GETDATE(), @CreatedBy
        );
        
        PRINT '   âœ… Created school year: ' + @YearCode;
        
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

IF OBJECT_ID('sp_AutoTransitionSemester', 'P') IS NOT NULL 
    DROP PROCEDURE sp_AutoTransitionSemester;
GO
CREATE PROCEDURE sp_AutoTransitionSemester
    @ExecutedBy VARCHAR(50) = 'system'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    BEGIN TRY
        DECLARE @Today DATE = CAST(GETDATE() AS DATE);
        DECLARE @SchoolYearId VARCHAR(50);
        DECLARE @CurrentSemester INT;
        DECLARE @NewSemester INT;
        
        -- Get current school year and semester
        SELECT TOP 1
            @SchoolYearId = school_year_id,
            @CurrentSemester = current_semester,
            @NewSemester = CASE 
                WHEN @Today BETWEEN semester1_start AND semester1_end THEN 1
                WHEN @Today BETWEEN semester2_start AND semester2_end THEN 2
                ELSE NULL
            END
        FROM school_years
        WHERE @Today BETWEEN start_date AND end_date
            AND deleted_at IS NULL
        ORDER BY is_active DESC;
        
        -- If semester changed, transition
        IF @NewSemester IS NOT NULL AND (@CurrentSemester IS NULL OR @CurrentSemester <> @NewSemester)
        BEGIN
            -- Calculate GPA for previous semester if exists
            IF @CurrentSemester IS NOT NULL
            BEGIN
                PRINT '   đŸ“ Calculating GPA for Semester ' + CAST(@CurrentSemester AS VARCHAR) + '...';
                EXEC sp_CalculateAllStudentGPA 
                    @AcademicYearId = @SchoolYearId,
                    @Semester = @CurrentSemester,
                    @CreatedBy = @ExecutedBy;
            END
            
            -- Update current semester
            UPDATE school_years
            SET current_semester = @NewSemester,
                updated_at = GETDATE(),
                updated_by = @ExecutedBy
            WHERE school_year_id = @SchoolYearId;
            
            PRINT '   âœ… Transitioned to Semester ' + CAST(@NewSemester AS VARCHAR);
            
            -- Log transition
            INSERT INTO audit_logs (user_id, action, entity_type, entity_id, new_values, created_at)
            VALUES (
                @ExecutedBy, 
                'AUTO_TRANSITION_SEMESTER', 
                'school_years', 
                @SchoolYearId,
                CONCAT('{"semester":', @NewSemester, '}'),
                GETDATE()
            );
        END
        ELSE
        BEGIN
            PRINT '   â„¹ï¸  No semester transition needed';
        END
        
        COMMIT TRANSACTION;
        
        SELECT 
            'SUCCESS' AS Status,
            @SchoolYearId AS SchoolYearId,
            @NewSemester AS CurrentSemester,
            N'âœ… ÄĂ£ kiá»ƒm tra vĂ  cáº­p nháº­t há»c ká»³' AS Message;
            
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

IF OBJECT_ID('sp_AutoTransitionToNewSchoolYear', 'P') IS NOT NULL 
    DROP PROCEDURE sp_AutoTransitionToNewSchoolYear;
GO
CREATE PROCEDURE sp_AutoTransitionToNewSchoolYear
    @NewSchoolYearId VARCHAR(50),
    @ExecutedBy VARCHAR(50) = 'system'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Validate new school year exists
        IF NOT EXISTS (SELECT 1 FROM school_years WHERE school_year_id = @NewSchoolYearId AND deleted_at IS NULL)
            THROW 50001, N'âŒ NÄƒm há»c má»›i khĂ´ng tá»“n táº¡i!', 1;
        
        -- Get old school year
        DECLARE @OldSchoolYearId VARCHAR(50);
        SELECT @OldSchoolYearId = school_year_id
        FROM school_years
        WHERE is_active = 1 AND deleted_at IS NULL;
        
        IF @OldSchoolYearId IS NOT NULL
        BEGIN
            -- Calculate GPA for entire old school year
            PRINT '   đŸ“ Calculating yearly GPA for old school year...';
            EXEC sp_CalculateAllStudentGPA 
                @AcademicYearId = @OldSchoolYearId,
                @Semester = NULL,  -- NULL = yearly GPA
                @CreatedBy = @ExecutedBy;
            
            -- Deactivate old school year
            UPDATE school_years
            SET is_active = 0,
                updated_at = GETDATE(),
                updated_by = @ExecutedBy
            WHERE school_year_id = @OldSchoolYearId;
            
            PRINT '   âœ… Closed old school year: ' + @OldSchoolYearId;
        END
        
        -- Activate new school year
        UPDATE school_years
        SET is_active = 1,
            current_semester = 1,  -- Start with Semester 1
            updated_at = GETDATE(),
            updated_by = @ExecutedBy
        WHERE school_year_id = @NewSchoolYearId;
        
        PRINT '   âœ… Activated new school year: ' + @NewSchoolYearId;
        
        -- Log transition
        INSERT INTO audit_logs (user_id, action, entity_type, entity_id, old_values, new_values, created_at)
        VALUES (
            @ExecutedBy,
            'AUTO_TRANSITION_SCHOOL_YEAR',
            'school_years',
            @NewSchoolYearId,
            CONCAT('{"old_school_year":"', @OldSchoolYearId, '"}'),
            CONCAT('{"new_school_year":"', @NewSchoolYearId, '"}'),
            GETDATE()
        );
        
        COMMIT TRANSACTION;
        
        SELECT 
            'SUCCESS' AS Status,
            @OldSchoolYearId AS OldSchoolYearId,
            @NewSchoolYearId AS NewSchoolYearId,
            N'âœ… ÄĂ£ chuyá»ƒn sang nÄƒm há»c má»›i' AS Message;
            
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

IF OBJECT_ID('sp_BulkEnrollment', 'P') IS NOT NULL
    DROP PROCEDURE sp_BulkEnrollment;
GO
CREATE PROCEDURE sp_BulkEnrollment
    @StudentId VARCHAR(50),
    @ClassIds NVARCHAR(MAX), -- Comma-separated list of class IDs
    @CreatedBy VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        DECLARE @SuccessCount INT = 0;
        DECLARE @ErrorCount INT = 0;
        DECLARE @Results TABLE (
            class_id VARCHAR(50),
            class_code VARCHAR(20),
            success BIT,
            message NVARCHAR(500)
        );
        
        -- Parse comma-separated class IDs
        DECLARE @ClassId VARCHAR(50);
        DECLARE @Pos INT;
        DECLARE @ClassIdList NVARCHAR(MAX) = @ClassIds + ',';
        
        WHILE LEN(@ClassIdList) > 0
        BEGIN
            SET @Pos = CHARINDEX(',', @ClassIdList);
            SET @ClassId = LTRIM(RTRIM(SUBSTRING(@ClassIdList, 1, @Pos - 1)));
            SET @ClassIdList = SUBSTRING(@ClassIdList, @Pos + 1, LEN(@ClassIdList));
            
            IF LEN(@ClassId) > 0
            BEGIN
                BEGIN TRY
                    -- Generate enrollment ID
                    DECLARE @EnrollmentId VARCHAR(50) = 'ENR-' + REPLACE(CONVERT(VARCHAR(36), NEWID()), '-', '');
                    
                    -- Try to enroll
                    EXEC sp_CreateEnrollment 
                        @EnrollmentId = @EnrollmentId,
                        @StudentId = @StudentId,
                        @ClassId = @ClassId,
                        @Notes = NULL,
                        @CreatedBy = @CreatedBy;
                    
                    SET @SuccessCount = @SuccessCount + 1;
                    
                    INSERT INTO @Results
                    SELECT @ClassId, class_code, 1, N'ThĂ nh cĂ´ng'
                    FROM classes WHERE class_id = @ClassId;
                    
                END TRY
                BEGIN CATCH
                    SET @ErrorCount = @ErrorCount + 1;
                    
                    INSERT INTO @Results
                    SELECT @ClassId, ISNULL(class_code, @ClassId), 0, ERROR_MESSAGE()
                    FROM classes WHERE class_id = @ClassId;
                END CATCH
            END
        END
        
        -- Return summary
        SELECT @SuccessCount AS success_count, @ErrorCount AS error_count;
        SELECT * FROM @Results;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

IF OBJECT_ID('sp_CheckEnrollmentEligibility', 'P') IS NOT NULL
    DROP PROCEDURE sp_CheckEnrollmentEligibility;
GO
CREATE PROCEDURE sp_CheckEnrollmentEligibility
    @StudentId VARCHAR(50),
    @ClassId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        DECLARE @IsEligible BIT = 1;
        DECLARE @ErrorMessage NVARCHAR(500) = NULL;
        
        -- Check 1: Student exists
        IF NOT EXISTS (SELECT 1 FROM students WHERE student_id = @StudentId AND deleted_at IS NULL)
        BEGIN
            SET @IsEligible = 0;
            SET @ErrorMessage = N'Sinh viĂªn khĂ´ng tá»“n táº¡i';
        END
        
        -- Check 2: Class exists
        ELSE IF NOT EXISTS (SELECT 1 FROM classes WHERE class_id = @ClassId AND deleted_at IS NULL)
        BEGIN
            SET @IsEligible = 0;
            SET @ErrorMessage = N'Lá»›p há»c khĂ´ng tá»“n táº¡i';
        END
        
        -- Check 3: Registration period is OPEN
        ELSE IF NOT EXISTS (
            SELECT 1 FROM registration_periods rp
            INNER JOIN classes c ON rp.academic_year_id = c.academic_year_id AND rp.semester = c.semester
            WHERE c.class_id = @ClassId
            AND rp.status = 'OPEN'
            AND GETDATE() BETWEEN rp.start_date AND rp.end_date
            AND rp.deleted_at IS NULL
        )
        BEGIN
            SET @IsEligible = 0;
            SET @ErrorMessage = N'KhĂ´ng trong thá»i gian Ä‘Äƒng kĂ½';
        END
        
        -- Check 4: Class not full
        ELSE 
        BEGIN
            DECLARE @MaxStudents INT, @CurrentEnrollment INT;
            SELECT @MaxStudents = max_students, @CurrentEnrollment = current_enrollment
            FROM classes WHERE class_id = @ClassId;
            
            IF @CurrentEnrollment >= @MaxStudents
            BEGIN
                SET @IsEligible = 0;
                SET @ErrorMessage = N'Lá»›p Ä‘Ă£ Ä‘áº§y';
            END
        END
        
        -- Check 5: Not already enrolled
        IF @IsEligible = 1
        BEGIN
            IF EXISTS (
                SELECT 1 FROM enrollments
                WHERE student_id = @StudentId
                AND class_id = @ClassId
                AND enrollment_status IN ('PENDING', 'APPROVED')
                AND deleted_at IS NULL
            )
            BEGIN
                SET @IsEligible = 0;
                SET @ErrorMessage = N'ÄĂ£ Ä‘Äƒng kĂ½ lá»›p nĂ y';
            END
        END
        
        -- Check 6: No schedule conflict (basic check on schedule string)
        IF @IsEligible = 1
        BEGIN
            DECLARE @NewSchedule NVARCHAR(500);
            SELECT @NewSchedule = schedule FROM classes WHERE class_id = @ClassId;
            
            IF EXISTS (
                SELECT 1 FROM enrollments e
                INNER JOIN classes c ON e.class_id = c.class_id
                WHERE e.student_id = @StudentId
                AND e.enrollment_status = 'APPROVED'
                AND e.deleted_at IS NULL
                AND c.schedule = @NewSchedule -- Simple string comparison
                AND c.class_id != @ClassId
            )
            BEGIN
                SET @IsEligible = 0;
                SET @ErrorMessage = N'TrĂ¹ng lá»‹ch há»c';
            END
        END
        
        -- Return result
        SELECT 
            @IsEligible AS is_eligible,
            @ErrorMessage AS error_message,
            @StudentId AS student_id,
            @ClassId AS class_id;
        
    END TRY
    BEGIN CATCH
        DECLARE @Error NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @Error, 1;
    END CATCH
END
GO

IF OBJECT_ID('sp_CheckScheduleConflict', 'P') IS NOT NULL
    DROP PROCEDURE sp_CheckScheduleConflict;
GO
CREATE PROCEDURE sp_CheckScheduleConflict
    @StudentId VARCHAR(50),
    @NewClassId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        DECLARE @NewSchedule NVARCHAR(500);
        DECLARE @HasConflict BIT = 0;
        DECLARE @ConflictDetails NVARCHAR(MAX) = NULL;
        
        -- Get new class schedule
        SELECT @NewSchedule = schedule
        FROM classes
        WHERE class_id = @NewClassId;
        
        -- Check for conflicts (simple string comparison)
        IF EXISTS (
            SELECT 1 
            FROM enrollments e
            INNER JOIN classes c ON e.class_id = c.class_id
            WHERE e.student_id = @StudentId
            AND e.enrollment_status = 'APPROVED'
            AND e.deleted_at IS NULL
            AND c.schedule = @NewSchedule
        )
        BEGIN
            SET @HasConflict = 1;
            
            SELECT @ConflictDetails = STRING_AGG(c.class_code + ' (' + c.schedule + ')', ', ')
            FROM enrollments e
            INNER JOIN classes c ON e.class_id = c.class_id
            WHERE e.student_id = @StudentId
            AND e.enrollment_status = 'APPROVED'
            AND e.deleted_at IS NULL
            AND c.schedule = @NewSchedule;
        END
        
        SELECT 
            @HasConflict AS has_conflict,
            @ConflictDetails AS conflict_details,
            @NewSchedule AS new_class_schedule;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

IF OBJECT_ID('dbo.sp_CheckStudentPrerequisites','P') IS NOT NULL
    DROP PROCEDURE dbo.sp_CheckStudentPrerequisites;
GO
CREATE PROCEDURE dbo.sp_CheckStudentPrerequisites
    @StudentId VARCHAR(50),
    @SubjectId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH Required AS (
        SELECT sp.prerequisite_id, sp.subject_id, sp.prerequisite_subject_id
        FROM dbo.subject_prerequisites sp
        WHERE sp.subject_id = @SubjectId
    ),
    StudentPassed AS (
        SELECT DISTINCT s.subject_id
        FROM dbo.enrollments e
        INNER JOIN dbo.classes c ON c.class_id = e.class_id
        INNER JOIN dbo.subjects s ON s.subject_id = c.subject_id
        LEFT  JOIN dbo.grades g ON g.enrollment_id = e.enrollment_id
        WHERE e.student_id = @StudentId
          AND e.deleted_at IS NULL
          AND (g.final_score IS NULL OR g.final_score >= 4) -- treat null as passed for in-progress
    )
    SELECT r.prerequisite_subject_id AS MissingSubjectId
    FROM Required r
    LEFT JOIN StudentPassed p ON p.subject_id = r.prerequisite_subject_id
    WHERE p.subject_id IS NULL;
END
GO

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

IF OBJECT_ID('sp_CloseRegistrationPeriod', 'P') IS NOT NULL
    DROP PROCEDURE sp_CloseRegistrationPeriod;
GO
CREATE PROCEDURE sp_CloseRegistrationPeriod
    @PeriodId VARCHAR(50),
    @UpdatedBy VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if period exists
        IF NOT EXISTS (SELECT 1 FROM registration_periods WHERE period_id = @PeriodId AND deleted_at IS NULL)
        BEGIN
            THROW 50012, N'KhĂ´ng tĂ¬m tháº¥y Ä‘á»£t Ä‘Äƒng kĂ½', 1;
        END
        
        -- Close the period
        UPDATE registration_periods
        SET 
            status = 'CLOSED',
            updated_at = GETDATE(),
            updated_by = @UpdatedBy
        WHERE period_id = @PeriodId;
        
        COMMIT TRANSACTION;
        
        -- Return updated period
        EXEC sp_GetRegistrationPeriodById @PeriodId;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

IF OBJECT_ID('dbo.sp_CreateAdministrativeClass','P') IS NOT NULL
    DROP PROCEDURE dbo.sp_CreateAdministrativeClass;
GO
CREATE PROCEDURE dbo.sp_CreateAdministrativeClass
    @AdminClassId    VARCHAR(50),
    @ClassCode       VARCHAR(20),
    @ClassName       NVARCHAR(150),
    @MajorId         VARCHAR(50) = NULL,
    @AdvisorId       VARCHAR(50) = NULL,
    @AcademicYearId  VARCHAR(50) = NULL,
    @CohortYear      INT,
    @MaxStudents     INT = 50,
    @Description     NVARCHAR(500) = NULL,
    @IsActive        BIT = 1,
    @CreatedBy       VARCHAR(50) = 'System'
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.administrative_classes (
        admin_class_id, class_code, class_name,
        major_id, advisor_id, academic_year_id,
        cohort_year, max_students, current_students,
        description, is_active, created_at, created_by
    ) VALUES (
        @AdminClassId, @ClassCode, @ClassName,
        @MajorId, @AdvisorId, @AcademicYearId,
        @CohortYear, @MaxStudents, 0,
        @Description, ISNULL(@IsActive,1), GETDATE(), @CreatedBy
    );

    SELECT @AdminClassId AS admin_class_id;
END
GO

IF OBJECT_ID('sp_CreateEnrollment', 'P') IS NOT NULL
    DROP PROCEDURE sp_CreateEnrollment;
GO
CREATE PROCEDURE sp_CreateEnrollment
    @EnrollmentId VARCHAR(50),
    @StudentId VARCHAR(50),
    @ClassId VARCHAR(50),
    @Notes NVARCHAR(500) = NULL,
    @CreatedBy VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check eligibility first
        DECLARE @IsEligible BIT, @ErrorMsg NVARCHAR(500);
        
        EXEC sp_CheckEnrollmentEligibility 
            @StudentId = @StudentId,
            @ClassId = @ClassId;
        
        -- Get eligibility result from temp table or variable
        -- For simplicity, re-run checks inline
        
        -- Validate class not full
        DECLARE @MaxStudents INT, @CurrentEnrollment INT;
        SELECT @MaxStudents = max_students, @CurrentEnrollment = current_enrollment
        FROM classes WHERE class_id = @ClassId;
        
        IF @CurrentEnrollment >= @MaxStudents
        BEGIN
            THROW 50020, N'Lá»›p Ä‘Ă£ Ä‘áº§y', 1;
        END
        
        -- Check not already enrolled
        IF EXISTS (
            SELECT 1 FROM enrollments
            WHERE student_id = @StudentId
            AND class_id = @ClassId
            AND enrollment_status IN ('PENDING', 'APPROVED')
            AND deleted_at IS NULL
        )
        BEGIN
            THROW 50021, N'ÄĂ£ Ä‘Äƒng kĂ½ lá»›p nĂ y', 1;
        END
        
        -- Calculate drop deadline (enrollment_date + 2 weeks)
        DECLARE @DropDeadline DATE = CAST(DATEADD(WEEK, 2, GETDATE()) AS DATE);
        
        -- Insert enrollment
        INSERT INTO enrollments (
            enrollment_id,
            student_id,
            class_id,
            enrollment_date,
            enrollment_status,
            drop_deadline,
            notes,
            created_at,
            created_by
        )
        VALUES (
            @EnrollmentId,
            @StudentId,
            @ClassId,
            GETDATE(),
            'APPROVED', -- Auto-approve
            @DropDeadline,
            @Notes,
            GETDATE(),
            @CreatedBy
        );
        
        -- Update class enrollment count
        UPDATE classes
        SET current_enrollment = current_enrollment + 1
        WHERE class_id = @ClassId;
        
        COMMIT TRANSACTION;
        
        -- Return enrollment info
        SELECT 
            e.enrollment_id,
            e.student_id,
            s.student_code,
            s.full_name AS student_name,
            e.class_id,
            c.class_code,
            c.class_name,
            sub.subject_name,
            e.enrollment_date,
            e.enrollment_status,
            e.drop_deadline,
            1 AS success,
            N'ÄÄƒng kĂ½ thĂ nh cĂ´ng' AS message
        FROM enrollments e
        INNER JOIN students s ON e.student_id = s.student_id
        INNER JOIN classes c ON e.class_id = c.class_id
        INNER JOIN subjects sub ON c.subject_id = sub.subject_id
        WHERE e.enrollment_id = @EnrollmentId;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

IF OBJECT_ID('sp_CreatePrerequisite', 'P') IS NOT NULL
    DROP PROCEDURE sp_CreatePrerequisite;
GO
CREATE PROCEDURE sp_CreatePrerequisite
    @PrerequisiteId VARCHAR(50),
    @SubjectId VARCHAR(50),
    @PrerequisiteSubjectId VARCHAR(50),
    @MinimumGrade DECIMAL(4,2) = 4.0,
    @IsRequired BIT = 1,
    @Description NVARCHAR(500) = NULL,
    @CreatedBy VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate: Subject cannot be prerequisite of itself
        IF @SubjectId = @PrerequisiteSubjectId
        BEGIN
            THROW 50026, N'MĂ´n há»c khĂ´ng thá»ƒ lĂ  Ä‘iá»u kiá»‡n tiĂªn quyáº¿t cá»§a chĂ­nh nĂ³', 1;
        END
        
        -- Validate: Both subjects exist
        IF NOT EXISTS (SELECT 1 FROM subjects WHERE subject_id = @SubjectId AND deleted_at IS NULL)
        BEGIN
            THROW 50027, N'MĂ´n há»c khĂ´ng tá»“n táº¡i', 1;
        END
        
        IF NOT EXISTS (SELECT 1 FROM subjects WHERE subject_id = @PrerequisiteSubjectId AND deleted_at IS NULL)
        BEGIN
            THROW 50028, N'MĂ´n há»c Ä‘iá»u kiá»‡n tiĂªn quyáº¿t khĂ´ng tá»“n táº¡i', 1;
        END
        
        -- Validate: No duplicate prerequisite
        IF EXISTS (
            SELECT 1 FROM subject_prerequisites
            WHERE subject_id = @SubjectId
            AND prerequisite_subject_id = @PrerequisiteSubjectId
            AND deleted_at IS NULL
        )
        BEGIN
            THROW 50029, N'Äiá»u kiá»‡n tiĂªn quyáº¿t Ä‘Ă£ tá»“n táº¡i', 1;
        END
        
        -- Validate: Minimum grade is valid (0-10)
        IF @MinimumGrade < 0 OR @MinimumGrade > 10
        BEGIN
            THROW 50030, N'Äiá»ƒm tá»‘i thiá»ƒu pháº£i tá»« 0 Ä‘áº¿n 10', 1;
        END
        
        -- Insert prerequisite
        INSERT INTO subject_prerequisites (
            prerequisite_id,
            subject_id,
            prerequisite_subject_id,
            minimum_grade,
            is_required,
            description,
            is_active,
            created_at,
            created_by
        )
        VALUES (
            @PrerequisiteId,
            @SubjectId,
            @PrerequisiteSubjectId,
            @MinimumGrade,
            @IsRequired,
            @Description,
            1,
            GETDATE(),
            @CreatedBy
        );
        
        COMMIT TRANSACTION;
        
        -- Return created prerequisite
        EXEC sp_GetPrerequisitesBySubject @SubjectId;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

IF OBJECT_ID('sp_CreateRegistrationPeriod', 'P') IS NOT NULL
    DROP PROCEDURE sp_CreateRegistrationPeriod;
GO
CREATE PROCEDURE sp_CreateRegistrationPeriod
    @PeriodId VARCHAR(50),
    @PeriodName NVARCHAR(200),
    @AcademicYearId VARCHAR(50),
    @Semester INT,
    @StartDate DATETIME,
    @EndDate DATETIME,
    @Description NVARCHAR(500) = NULL,
    @CreatedBy VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate: Start date < End date
        IF @StartDate >= @EndDate
        BEGIN
            THROW 50013, N'NgĂ y báº¯t Ä‘áº§u pháº£i nhá» hÆ¡n ngĂ y káº¿t thĂºc', 1;
        END
        
        -- Validate: Semester is 1, 2, or 3
        IF @Semester NOT IN (1, 2, 3)
        BEGIN
            THROW 50014, N'Há»c ká»³ khĂ´ng há»£p lá»‡ (pháº£i lĂ  1, 2, hoáº·c 3)', 1;
        END
        
        -- Validate: Academic year exists
        IF NOT EXISTS (SELECT 1 FROM academic_years WHERE academic_year_id = @AcademicYearId AND deleted_at IS NULL)
        BEGIN
            THROW 50006, N'NÄƒm há»c khĂ´ng tá»“n táº¡i', 1;
        END
        
        -- Validate: Check for overlapping periods (same academic year and semester)
        IF EXISTS (
            SELECT 1 FROM registration_periods
            WHERE academic_year_id = @AcademicYearId
            AND semester = @Semester
            AND deleted_at IS NULL
            AND (
                (@StartDate BETWEEN start_date AND end_date) OR
                (@EndDate BETWEEN start_date AND end_date) OR
                (start_date BETWEEN @StartDate AND @EndDate) OR
                (end_date BETWEEN @StartDate AND @EndDate)
            )
        )
        BEGIN
            THROW 50015, N'ÄĂ£ cĂ³ Ä‘á»£t Ä‘Äƒng kĂ½ trĂ¹ng thá»i gian cho há»c ká»³ nĂ y', 1;
        END
        
        -- Insert new period
        INSERT INTO registration_periods (
            period_id,
            period_name,
            academic_year_id,
            semester,
            start_date,
            end_date,
            status,
            description,
            is_active,
            created_at,
            created_by
        )
        VALUES (
            @PeriodId,
            @PeriodName,
            @AcademicYearId,
            @Semester,
            @StartDate,
            @EndDate,
            'UPCOMING', -- Default status
            @Description,
            1,
            GETDATE(),
            @CreatedBy
        );
        
        COMMIT TRANSACTION;
        
        -- Return created period
        EXEC sp_GetRegistrationPeriodById @PeriodId;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

IF OBJECT_ID('sp_DeleteAdministrativeClass', 'P') IS NOT NULL
    DROP PROCEDURE sp_DeleteAdministrativeClass;
GO
CREATE PROCEDURE sp_DeleteAdministrativeClass
    @AdminClassId VARCHAR(50),
    @DeletedBy VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if class exists
        IF NOT EXISTS (SELECT 1 FROM administrative_classes WHERE admin_class_id = @AdminClassId AND deleted_at IS NULL)
        BEGIN
            THROW 50002, N'KhĂ´ng tĂ¬m tháº¥y lá»›p hĂ nh chĂ­nh', 1;
        END
        
        -- Check if class has students
        DECLARE @StudentCount INT;
        SELECT @StudentCount = current_students 
        FROM administrative_classes 
        WHERE admin_class_id = @AdminClassId;
        
        IF @StudentCount > 0
        BEGIN
            THROW 50008, N'KhĂ´ng thá»ƒ xĂ³a lá»›p Ä‘ang cĂ³ sinh viĂªn', 1;
        END
        
        -- Soft delete
        UPDATE administrative_classes
        SET 
            is_active = 0,
            deleted_at = GETDATE(),
            deleted_by = @DeletedBy
        WHERE admin_class_id = @AdminClassId;
        
        COMMIT TRANSACTION;
        
        SELECT 1 AS Success, N'XĂ³a lá»›p hĂ nh chĂ­nh thĂ nh cĂ´ng' AS Message;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

IF OBJECT_ID('sp_DeletePrerequisite', 'P') IS NOT NULL
    DROP PROCEDURE sp_DeletePrerequisite;
GO
CREATE PROCEDURE sp_DeletePrerequisite
    @PrerequisiteId VARCHAR(50),
    @DeletedBy VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if prerequisite exists
        IF NOT EXISTS (
            SELECT 1 FROM subject_prerequisites 
            WHERE prerequisite_id = @PrerequisiteId 
            AND deleted_at IS NULL
        )
        BEGIN
            THROW 50031, N'KhĂ´ng tĂ¬m tháº¥y Ä‘iá»u kiá»‡n tiĂªn quyáº¿t', 1;
        END
        
        -- Soft delete
        UPDATE subject_prerequisites
        SET 
            is_active = 0,
            deleted_at = GETDATE(),
            deleted_by = @DeletedBy
        WHERE prerequisite_id = @PrerequisiteId;
        
        COMMIT TRANSACTION;
        
        SELECT 1 AS Success, N'XĂ³a Ä‘iá»u kiá»‡n tiĂªn quyáº¿t thĂ nh cĂ´ng' AS Message;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

IF OBJECT_ID('sp_DeleteRegistrationPeriod', 'P') IS NOT NULL
    DROP PROCEDURE sp_DeleteRegistrationPeriod;
GO
CREATE PROCEDURE sp_DeleteRegistrationPeriod
    @PeriodId VARCHAR(50),
    @DeletedBy VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if period exists
        IF NOT EXISTS (SELECT 1 FROM registration_periods WHERE period_id = @PeriodId AND deleted_at IS NULL)
        BEGIN
            THROW 50012, N'KhĂ´ng tĂ¬m tháº¥y Ä‘á»£t Ä‘Äƒng kĂ½', 1;
        END
        
        -- Check if period is OPEN
        DECLARE @Status NVARCHAR(20);
        SELECT @Status = status FROM registration_periods WHERE period_id = @PeriodId;
        
        IF @Status = 'OPEN'
        BEGIN
            THROW 50017, N'KhĂ´ng thá»ƒ xĂ³a Ä‘á»£t Ä‘Äƒng kĂ½ Ä‘ang má»Ÿ', 1;
        END
        
        -- Soft delete
        UPDATE registration_periods
        SET 
            is_active = 0,
            deleted_at = GETDATE(),
            deleted_by = @DeletedBy
        WHERE period_id = @PeriodId;
        
        COMMIT TRANSACTION;
        
        SELECT 1 AS Success, N'XĂ³a Ä‘á»£t Ä‘Äƒng kĂ½ thĂ nh cĂ´ng' AS Message;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

IF OBJECT_ID('sp_DropEnrollment', 'P') IS NOT NULL
    DROP PROCEDURE sp_DropEnrollment;
GO
CREATE PROCEDURE sp_DropEnrollment
    @EnrollmentId VARCHAR(50),
    @Reason NVARCHAR(500) = NULL,
    @DeletedBy VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if enrollment exists
        IF NOT EXISTS (SELECT 1 FROM enrollments WHERE enrollment_id = @EnrollmentId AND deleted_at IS NULL)
        BEGIN
            THROW 50022, N'KhĂ´ng tĂ¬m tháº¥y Ä‘Äƒng kĂ½', 1;
        END
        
        -- Get enrollment info
        DECLARE @ClassId VARCHAR(50), @DropDeadline DATE, @EnrollmentStatus NVARCHAR(20);
        SELECT 
            @ClassId = class_id,
            @DropDeadline = drop_deadline,
            @EnrollmentStatus = enrollment_status
        FROM enrollments
        WHERE enrollment_id = @EnrollmentId;
        
        -- Check if already dropped
        IF @EnrollmentStatus = 'DROPPED'
        BEGIN
            THROW 50023, N'ÄĂ£ há»§y Ä‘Äƒng kĂ½ trÆ°á»›c Ä‘Ă³', 1;
        END
        
        -- Check deadline
        IF @DropDeadline IS NOT NULL AND GETDATE() > @DropDeadline
        BEGIN
            THROW 50024, N'ÄĂ£ quĂ¡ háº¡n há»§y Ä‘Äƒng kĂ½', 1;
        END
        
        -- Update enrollment status (chỉ đổi status, không xóa mềm)
        UPDATE enrollments
        SET 
            enrollment_status = 'DROPPED',
            drop_reason = @Reason,
            updated_at = GETDATE(),
            updated_by = @DeletedBy
        WHERE enrollment_id = @EnrollmentId;
        
        -- Decrease class enrollment count
        UPDATE classes
        SET current_enrollment = current_enrollment - 1
        WHERE class_id = @ClassId;
        
        COMMIT TRANSACTION;
        
        SELECT 1 AS Success, N'Há»§y Ä‘Äƒng kĂ½ thĂ nh cĂ´ng' AS Message;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

IF OBJECT_ID('sp_GetActiveRegistrationPeriod', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetActiveRegistrationPeriod;
GO
CREATE PROCEDURE sp_GetActiveRegistrationPeriod
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        SELECT TOP 1
            rp.period_id,
            rp.period_name,
            rp.academic_year_id,
            ay.year_name,
            rp.semester,
            rp.start_date,
            rp.end_date,
            rp.status,
            rp.description,
            DATEDIFF(DAY, GETDATE(), rp.end_date) AS days_remaining
        FROM registration_periods rp
        LEFT JOIN academic_years ay ON rp.academic_year_id = ay.academic_year_id
        WHERE rp.status = 'OPEN'
        AND rp.deleted_at IS NULL
        AND GETDATE() BETWEEN rp.start_date AND rp.end_date
        ORDER BY rp.start_date DESC;
        
        IF @@ROWCOUNT = 0
        BEGIN
            SELECT NULL AS period_id, N'KhĂ´ng cĂ³ Ä‘á»£t Ä‘Äƒng kĂ½ nĂ o Ä‘ang má»Ÿ' AS message;
        END
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

IF OBJECT_ID('sp_GetAdminClassReport', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetAdminClassReport;
GO
CREATE PROCEDURE sp_GetAdminClassReport
    @AdminClassId VARCHAR(50),
    @Semester INT = NULL,
    @AcademicYearId VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Check if class exists
        IF NOT EXISTS (SELECT 1 FROM administrative_classes WHERE admin_class_id = @AdminClassId AND deleted_at IS NULL)
        BEGIN
            THROW 50002, N'KhĂ´ng tĂ¬m tháº¥y lá»›p hĂ nh chĂ­nh', 1;
        END
        
        -- Get class basic info
        SELECT 
            ac.admin_class_id,
            ac.class_code,
            ac.class_name,
            ac.cohort_year,
            ac.max_students,
            ac.current_students,
            m.major_name,
            l.full_name AS advisor_name
        FROM administrative_classes ac
        LEFT JOIN majors m ON ac.major_id = m.major_id
        LEFT JOIN lecturers l ON ac.advisor_id = l.lecturer_id
        WHERE ac.admin_class_id = @AdminClassId;
        
        -- Get student statistics (placeholder - will be enhanced with actual grade data)
        SELECT 
            COUNT(*) AS total_students,
            COUNT(CASE WHEN s.gender = 'M' THEN 1 END) AS male_students,
            COUNT(CASE WHEN s.gender = 'F' THEN 1 END) AS female_students
        FROM students s
        WHERE s.admin_class_id = @AdminClassId
        AND s.deleted_at IS NULL;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

IF OBJECT_ID('sp_GetAdminClassStatistics', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetAdminClassStatistics;
GO
CREATE PROCEDURE sp_GetAdminClassStatistics
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        SELECT 
            COUNT(*) AS total_classes,
            SUM(current_students) AS total_students,
            AVG(CAST(current_students AS FLOAT)) AS avg_students_per_class,
            SUM(CASE WHEN current_students >= max_students THEN 1 ELSE 0 END) AS full_classes,
            SUM(CASE WHEN current_students = 0 THEN 1 ELSE 0 END) AS empty_classes
        FROM administrative_classes
        WHERE is_active = 1 
        AND deleted_at IS NULL;
        
        -- Classes by cohort year
        SELECT 
            cohort_year,
            COUNT(*) AS class_count,
            SUM(current_students) AS student_count
        FROM administrative_classes
        WHERE is_active = 1 
        AND deleted_at IS NULL
        GROUP BY cohort_year
        ORDER BY cohort_year DESC;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

IF OBJECT_ID('dbo.sp_GetAdministrativeClassById','P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetAdministrativeClassById;
GO
CREATE PROCEDURE dbo.sp_GetAdministrativeClassById
    @AdminClassId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        ac.admin_class_id,
        ac.class_code,
        ac.class_name,
        ac.major_id,
        ac.advisor_id,
        ac.academic_year_id,
        ac.cohort_year,
        ac.max_students,
        ac.current_students,
        ac.description,
        ac.is_active,
        ac.created_at,
        ac.created_by,
        ac.updated_at,
        ac.updated_by,
        ac.deleted_at,
        ac.deleted_by,
        -- present advisor/major names if available
        m.major_name,
        l.full_name AS advisor_name,
        l.phone     AS advisor_phone
    FROM dbo.administrative_classes ac
    LEFT JOIN dbo.majors m ON m.major_id = ac.major_id
    LEFT JOIN dbo.lecturers l ON l.lecturer_id = ac.advisor_id
    WHERE ac.admin_class_id = @AdminClassId;
END
GO

IF OBJECT_ID('sp_GetAllAdministrativeClasses', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetAllAdministrativeClasses;
GO
CREATE PROCEDURE sp_GetAllAdministrativeClasses
    @Page INT = 1,
    @PageSize INT = 10,
    @Search NVARCHAR(200) = NULL,
    @MajorId VARCHAR(50) = NULL,
    @CohortYear INT = NULL,
    @AdvisorId VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        DECLARE @Offset INT = (@Page - 1) * @PageSize;
        
        -- Get total count
        DECLARE @TotalCount INT;
        
        SELECT @TotalCount = COUNT(*)
        FROM administrative_classes ac
        LEFT JOIN majors m ON ac.major_id = m.major_id
        LEFT JOIN lecturers l ON ac.advisor_id = l.lecturer_id
        WHERE ac.is_active = 1 
        AND ac.deleted_at IS NULL
        AND (@Search IS NULL OR ac.class_code LIKE '%' + @Search + '%' OR ac.class_name LIKE '%' + @Search + '%')
        AND (@MajorId IS NULL OR ac.major_id = @MajorId)
        AND (@CohortYear IS NULL OR ac.cohort_year = @CohortYear)
        AND (@AdvisorId IS NULL OR ac.advisor_id = @AdvisorId);
        
        -- Get paginated data
        SELECT 
            ac.admin_class_id,
            ac.class_code,
            ac.class_name,
            ac.major_id,
            m.major_name,
            m.faculty_id,
            f.faculty_name,
            ac.cohort_year,
            ac.advisor_id,
            l.full_name AS advisor_name,
            ac.academic_year_id,
            ay.year_name,
            ac.max_students,
            ac.current_students,
            ac.description,
            ac.created_at,
            ac.created_by,
            @TotalCount AS TotalCount
        FROM administrative_classes ac
        LEFT JOIN majors m ON ac.major_id = m.major_id
        LEFT JOIN faculties f ON m.faculty_id = f.faculty_id
        LEFT JOIN lecturers l ON ac.advisor_id = l.lecturer_id
        LEFT JOIN academic_years ay ON ac.academic_year_id = ay.academic_year_id
        WHERE ac.is_active = 1 
        AND ac.deleted_at IS NULL
        AND (@Search IS NULL OR ac.class_code LIKE '%' + @Search + '%' OR ac.class_name LIKE '%' + @Search + '%')
        AND (@MajorId IS NULL OR ac.major_id = @MajorId)
        AND (@CohortYear IS NULL OR ac.cohort_year = @CohortYear)
        AND (@AdvisorId IS NULL OR ac.advisor_id = @AdvisorId)
        ORDER BY ac.cohort_year DESC, ac.class_code
        OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

IF OBJECT_ID('sp_GetAllRegistrationPeriods', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetAllRegistrationPeriods;
GO
CREATE PROCEDURE sp_GetAllRegistrationPeriods
    @AcademicYearId VARCHAR(50) = NULL,
    @Semester INT = NULL,
    @Status NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        SELECT 
            rp.period_id,
            rp.period_name,
            rp.academic_year_id,
            ay.year_name,
            rp.semester,
            rp.start_date,
            rp.end_date,
            rp.status,
            rp.description,
            rp.is_active,
            rp.created_at,
            rp.created_by,
            CASE 
                WHEN rp.status = 'OPEN' THEN 1
                WHEN GETDATE() < rp.start_date THEN 2
                WHEN GETDATE() > rp.end_date THEN 3
                ELSE 4
            END AS sort_order
        FROM registration_periods rp
        LEFT JOIN academic_years ay ON rp.academic_year_id = ay.academic_year_id
        WHERE rp.deleted_at IS NULL
        AND (@AcademicYearId IS NULL OR rp.academic_year_id = @AcademicYearId)
        AND (@Semester IS NULL OR rp.semester = @Semester)
        AND (@Status IS NULL OR rp.status = @Status)
        ORDER BY sort_order, rp.start_date DESC;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

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

IF OBJECT_ID('sp_GetAvailableClassesForStudent', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetAvailableClassesForStudent;
GO
CREATE PROCEDURE sp_GetAvailableClassesForStudent
    @StudentId VARCHAR(50),
    @AcademicYearId VARCHAR(50),
    @Semester INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Get all classes for the semester
        SELECT 
            c.class_id,
            c.class_code,
            c.class_name,
            c.subject_id,
            s.subject_name,
            s.subject_code,
            s.credits,
            c.lecturer_id,
            l.full_name AS lecturer_name,
            c.schedule,
            c.room,
            c.max_students,
            c.current_enrollment,
            (c.max_students - c.current_enrollment) AS available_slots,
            CASE 
                WHEN c.current_enrollment >= c.max_students THEN 0
                ELSE 1
            END AS has_slots,
            -- Check if already enrolled
            CASE 
                WHEN EXISTS (
                    SELECT 1 FROM enrollments e
                    WHERE e.student_id = @StudentId
                    AND e.class_id = c.class_id
                    AND e.deleted_at IS NULL
                    AND e.enrollment_status IN ('PENDING', 'APPROVED')
                ) THEN 1
                ELSE 0
            END AS is_enrolled,
            -- Eligibility check (basic - detailed check in sp_CheckEnrollmentEligibility)
            CASE 
                WHEN c.current_enrollment >= c.max_students THEN N'Lá»›p Ä‘Ă£ Ä‘áº§y'
                WHEN EXISTS (
                    SELECT 1 FROM enrollments e
                    WHERE e.student_id = @StudentId
                    AND e.class_id = c.class_id
                    AND e.deleted_at IS NULL
                    AND e.enrollment_status IN ('PENDING', 'APPROVED')
                ) THEN N'ÄĂ£ Ä‘Äƒng kĂ½ lá»›p nĂ y'
                ELSE NULL
            END AS ineligible_reason
        FROM classes c
        INNER JOIN subjects s ON c.subject_id = s.subject_id
        LEFT JOIN lecturers l ON c.lecturer_id = l.lecturer_id
        WHERE c.academic_year_id = @AcademicYearId
        AND c.semester = @Semester
        AND c.deleted_at IS NULL
        ORDER BY s.subject_name, c.class_code;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

IF OBJECT_ID('sp_GetClassRoster', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetClassRoster;
GO
CREATE PROCEDURE sp_GetClassRoster
    @ClassId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Class info
        SELECT 
            c.class_id,
            c.class_code,
            c.class_name,
            s.subject_name,
            l.full_name AS lecturer_name,
            c.schedule,
            c.room,
            c.max_students,
            c.current_enrollment
        FROM classes c
        INNER JOIN subjects s ON c.subject_id = s.subject_id
        LEFT JOIN lecturers l ON c.lecturer_id = l.lecturer_id
        WHERE c.class_id = @ClassId;
        
        -- Student roster
        SELECT 
            ROW_NUMBER() OVER (ORDER BY st.student_code) AS stt,
            st.student_id,
            st.student_code,
            st.full_name,
            st.email,
            st.phone_number,
            ac.class_code AS admin_class_code,
            ac.class_name AS admin_class_name,
            e.enrollment_date
        FROM enrollments e
        INNER JOIN students st ON e.student_id = st.student_id
        LEFT JOIN administrative_classes ac ON st.admin_class_id = ac.admin_class_id
        WHERE e.class_id = @ClassId
        AND e.enrollment_status = 'APPROVED'
        AND e.deleted_at IS NULL
        ORDER BY st.student_code;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

IF OBJECT_ID('sp_GetCurrentSchoolYearAndSemester', 'P') IS NOT NULL 
    DROP PROCEDURE sp_GetCurrentSchoolYearAndSemester;
GO
CREATE PROCEDURE sp_GetCurrentSchoolYearAndSemester
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Today DATE = CAST(GETDATE() AS DATE);
    DECLARE @SchoolYearId VARCHAR(50);
    DECLARE @CurrentSemester INT;
    
    -- Find school year containing today
    SELECT TOP 1
        @SchoolYearId = school_year_id,
        @CurrentSemester = CASE 
            WHEN @Today BETWEEN semester1_start AND semester1_end THEN 1
            WHEN @Today BETWEEN semester2_start AND semester2_end THEN 2
            ELSE NULL
        END
    FROM school_years
    WHERE @Today BETWEEN start_date AND end_date
        AND deleted_at IS NULL
    ORDER BY is_active DESC, created_at DESC;
    
    -- Return result
    SELECT 
        sy.school_year_id,
        sy.year_code,
        sy.year_name,
        sy.academic_year_id,
        ay.cohort_code,
        @CurrentSemester AS current_semester,
        CASE @CurrentSemester
            WHEN 1 THEN N'Há»c ká»³ 1'
            WHEN 2 THEN N'Há»c ká»³ 2'
            ELSE N'NgoĂ i há»c ká»³'
        END AS semester_name,
        sy.is_active,
        sy.start_date,
        sy.end_date,
        sy.semester1_start,
        sy.semester1_end,
        sy.semester2_start,
        sy.semester2_end
    FROM school_years sy
    LEFT JOIN academic_years ay ON sy.academic_year_id = ay.academic_year_id
    WHERE sy.school_year_id = @SchoolYearId;
END
GO

IF OBJECT_ID('sp_GetEnrollmentStatistics', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetEnrollmentStatistics;
GO
CREATE PROCEDURE sp_GetEnrollmentStatistics
    @AcademicYearId VARCHAR(50),
    @Semester INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Overall statistics
        SELECT 
            COUNT(DISTINCT c.class_id) AS total_classes,
            SUM(c.max_students) AS total_capacity,
            SUM(c.current_enrollment) AS total_enrolled,
            SUM(c.max_students - c.current_enrollment) AS available_slots,
            COUNT(DISTINCT e.student_id) AS unique_students,
            SUM(CASE WHEN c.current_enrollment >= c.max_students THEN 1 ELSE 0 END) AS full_classes,
            CAST(AVG(CAST(c.current_enrollment AS FLOAT) / NULLIF(c.max_students, 0) * 100) AS DECIMAL(5,2)) AS avg_fill_rate
        FROM classes c
        LEFT JOIN enrollments e ON c.class_id = e.class_id 
            AND e.enrollment_status = 'APPROVED' 
            AND e.deleted_at IS NULL
        WHERE c.academic_year_id = @AcademicYearId
        AND c.semester = @Semester
        AND c.deleted_at IS NULL;
        
        -- By subject
        SELECT 
            s.subject_id,
            s.subject_name,
            s.subject_code,
            COUNT(c.class_id) AS class_count,
            SUM(c.current_enrollment) AS enrolled_students,
            SUM(c.max_students) AS max_capacity
        FROM subjects s
        INNER JOIN classes c ON s.subject_id = c.subject_id
        WHERE c.academic_year_id = @AcademicYearId
        AND c.semester = @Semester
        AND c.deleted_at IS NULL
        GROUP BY s.subject_id, s.subject_name, s.subject_code
        ORDER BY enrolled_students DESC;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

IF OBJECT_ID('sp_GetEnrollmentsByClass', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetEnrollmentsByClass;
GO
CREATE PROCEDURE sp_GetEnrollmentsByClass
    @ClassId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        SELECT 
            e.enrollment_id,
            e.student_id,
            s.student_code,
            s.full_name AS student_name,
            s.email,
            s.phone_number,
            s.admin_class_id,
            ac.class_code AS admin_class_code,
            e.enrollment_date,
            e.enrollment_status,
            e.notes
        FROM enrollments e
        INNER JOIN students s ON e.student_id = s.student_id
        LEFT JOIN administrative_classes ac ON s.admin_class_id = ac.admin_class_id
        WHERE e.class_id = @ClassId
        AND e.deleted_at IS NULL
        AND e.enrollment_status IN ('PENDING', 'APPROVED')
        ORDER BY s.student_code;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

IF OBJECT_ID('sp_GetEnrollmentsByStudent', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetEnrollmentsByStudent;
GO
CREATE PROCEDURE sp_GetEnrollmentsByStudent
    @StudentId VARCHAR(50),
    @AcademicYearId VARCHAR(50) = NULL,
    @Semester INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        SELECT 
            e.enrollment_id,
            e.student_id,
            e.class_id,
            c.class_code,
            c.class_name,
            c.subject_id,
            s.subject_name,
            s.subject_code,
            s.credits,
            c.lecturer_id,
            l.full_name AS lecturer_name,
            c.schedule,
            c.room,
            c.semester,
            c.academic_year_id,
            ay.year_name,
            e.enrollment_date,
            e.enrollment_status,
            e.drop_deadline,
            e.notes,
            CASE 
                WHEN e.drop_deadline IS NOT NULL AND GETDATE() <= e.drop_deadline THEN 1
                ELSE 0
            END AS can_drop
        FROM enrollments e
        INNER JOIN classes c ON e.class_id = c.class_id
        INNER JOIN subjects s ON c.subject_id = s.subject_id
        LEFT JOIN lecturers l ON c.lecturer_id = l.lecturer_id
        LEFT JOIN academic_years ay ON c.academic_year_id = ay.academic_year_id
        WHERE e.student_id = @StudentId
        AND e.deleted_at IS NULL
        AND (@AcademicYearId IS NULL OR c.academic_year_id = @AcademicYearId)
        AND (@Semester IS NULL OR c.semester = @Semester)
        ORDER BY c.semester, s.subject_name;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

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

IF OBJECT_ID('sp_GetPrerequisitesBySubject', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetPrerequisitesBySubject;
GO
CREATE PROCEDURE sp_GetPrerequisitesBySubject
    @SubjectId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        SELECT 
            sp.prerequisite_id,
            sp.subject_id,
            s1.subject_name AS subject_name,
            s1.subject_code AS subject_code,
            sp.prerequisite_subject_id,
            s2.subject_name AS prerequisite_name,
            s2.subject_code AS prerequisite_code,
            sp.minimum_grade,
            sp.is_required,
            sp.description,
            sp.created_at,
            sp.created_by
        FROM subject_prerequisites sp
        INNER JOIN subjects s1 ON sp.subject_id = s1.subject_id
        INNER JOIN subjects s2 ON sp.prerequisite_subject_id = s2.subject_id
        WHERE sp.subject_id = @SubjectId
        AND sp.is_active = 1
        AND sp.deleted_at IS NULL
        ORDER BY sp.is_required DESC, s2.subject_name;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

IF OBJECT_ID('sp_GetRegistrationPeriodById', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetRegistrationPeriodById;
GO
CREATE PROCEDURE sp_GetRegistrationPeriodById
    @PeriodId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        SELECT 
            rp.period_id,
            rp.period_name,
            rp.academic_year_id,
            ay.year_name,
            rp.semester,
            rp.start_date,
            rp.end_date,
            rp.status,
            rp.description,
            rp.is_active,
            rp.created_at,
            rp.created_by,
            rp.updated_at,
            rp.updated_by,
            DATEDIFF(DAY, rp.start_date, rp.end_date) AS duration_days,
            CASE 
                WHEN GETDATE() < rp.start_date THEN DATEDIFF(DAY, GETDATE(), rp.start_date)
                WHEN GETDATE() > rp.end_date THEN 0
                ELSE DATEDIFF(DAY, GETDATE(), rp.end_date)
            END AS days_remaining
        FROM registration_periods rp
        LEFT JOIN academic_years ay ON rp.academic_year_id = ay.academic_year_id
        WHERE rp.period_id = @PeriodId
        AND rp.deleted_at IS NULL;
        
        IF @@ROWCOUNT = 0
        BEGIN
            THROW 50012, N'KhĂ´ng tĂ¬m tháº¥y Ä‘á»£t Ä‘Äƒng kĂ½', 1;
        END
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

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

IF OBJECT_ID('sp_GetStudentSchedule', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetStudentSchedule;
GO
CREATE PROCEDURE sp_GetStudentSchedule
    @StudentId VARCHAR(50),
    @Semester INT,
    @AcademicYearId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        SELECT 
            c.class_id,
            c.class_code,
            c.class_name,
            s.subject_name,
            s.subject_code,
            s.credits,
            l.full_name AS lecturer_name,
            c.schedule,
            c.room
        FROM enrollments e
        INNER JOIN classes c ON e.class_id = c.class_id
        INNER JOIN subjects s ON c.subject_id = s.subject_id
        LEFT JOIN lecturers l ON c.lecturer_id = l.lecturer_id
        WHERE e.student_id = @StudentId
        AND c.semester = @Semester
        AND c.academic_year_id = @AcademicYearId
        AND e.enrollment_status = 'APPROVED'
        AND e.deleted_at IS NULL
        ORDER BY c.schedule;
        
        -- Summary
        SELECT 
            COUNT(*) AS total_classes,
            SUM(s.credits) AS total_credits
        FROM enrollments e
        INNER JOIN classes c ON e.class_id = c.class_id
        INNER JOIN subjects s ON c.subject_id = s.subject_id
        WHERE e.student_id = @StudentId
        AND c.semester = @Semester
        AND c.academic_year_id = @AcademicYearId
        AND e.enrollment_status = 'APPROVED'
        AND e.deleted_at IS NULL;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

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
        ts.lecturer_id,
        l.full_name AS lecturer_name,
        r.room_id, r.room_code,
        sy.school_year_id, sy.year_code
    FROM dbo.timetable_sessions ts
    INNER JOIN dbo.classes c ON c.class_id = ts.class_id
    INNER JOIN dbo.subjects s ON s.subject_id = ts.subject_id
    INNER JOIN dbo.enrollments e ON e.class_id = c.class_id
    LEFT JOIN dbo.lecturers l ON l.lecturer_id = ts.lecturer_id
    LEFT JOIN dbo.rooms r ON r.room_id = ts.room_id
    LEFT JOIN dbo.school_years sy ON sy.school_year_id = ts.school_year_id
    WHERE e.student_id = @StudentId
      AND e.enrollment_status = 'APPROVED'
      AND e.deleted_at IS NULL
      AND ts.week_no = @WeekNo
      AND (sy.start_date IS NULL OR YEAR(sy.start_date) = @Year OR YEAR(sy.end_date) = @Year)
      AND ts.deleted_at IS NULL
      AND c.deleted_at IS NULL
    GROUP BY ts.session_id, ts.week_no, ts.weekday, ts.start_time, ts.end_time, ts.period_from, ts.period_to, ts.status,
             c.class_id, c.class_code, c.class_name, s.subject_id, s.subject_name, ts.lecturer_id, l.full_name,
             r.room_id, r.room_code, sy.school_year_id, sy.year_code
    ORDER BY ts.weekday, ts.start_time;
END
GO

IF OBJECT_ID('sp_GetStudentsByAdminClass', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetStudentsByAdminClass;
GO
CREATE PROCEDURE sp_GetStudentsByAdminClass
    @AdminClassId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Check if class exists
        IF NOT EXISTS (SELECT 1 FROM administrative_classes WHERE admin_class_id = @AdminClassId AND deleted_at IS NULL)
        BEGIN
            THROW 50002, N'KhĂ´ng tĂ¬m tháº¥y lá»›p hĂ nh chĂ­nh', 1;
        END
        
        SELECT 
            s.student_id,
            s.student_code,
            s.full_name,
            s.email,
            s.phone_number,
            s.date_of_birth,
            s.gender,
            s.address,
            s.admin_class_id,
            ac.class_code AS admin_class_code,
            ac.class_name AS admin_class_name,
            s.created_at AS enrolled_date
        FROM students s
        INNER JOIN administrative_classes ac ON s.admin_class_id = ac.admin_class_id
        WHERE s.admin_class_id = @AdminClassId
        AND s.deleted_at IS NULL
        ORDER BY s.student_code;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

IF OBJECT_ID('sp_GetSubjectsWithPrerequisites', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetSubjectsWithPrerequisites;
GO
CREATE PROCEDURE sp_GetSubjectsWithPrerequisites
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        SELECT 
            s.subject_id,
            s.subject_code,
            s.subject_name,
            s.credits,
            COUNT(sp.prerequisite_id) AS prerequisite_count,
            STRING_AGG(s2.subject_code, ', ') AS prerequisite_codes
        FROM subjects s
        INNER JOIN subject_prerequisites sp ON s.subject_id = sp.subject_id
        INNER JOIN subjects s2 ON sp.prerequisite_subject_id = s2.subject_id
        WHERE sp.is_active = 1
        AND sp.deleted_at IS NULL
        AND s.deleted_at IS NULL
        GROUP BY s.subject_id, s.subject_code, s.subject_name, s.credits
        ORDER BY s.subject_name;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

IF OBJECT_ID('sp_OpenRegistrationPeriod', 'P') IS NOT NULL
    DROP PROCEDURE sp_OpenRegistrationPeriod;
GO
CREATE PROCEDURE sp_OpenRegistrationPeriod
    @PeriodId VARCHAR(50),
    @UpdatedBy VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if period exists
        IF NOT EXISTS (SELECT 1 FROM registration_periods WHERE period_id = @PeriodId AND deleted_at IS NULL)
        BEGIN
            THROW 50012, N'KhĂ´ng tĂ¬m tháº¥y Ä‘á»£t Ä‘Äƒng kĂ½', 1;
        END
        
        -- Validate: Period dates are valid
        DECLARE @StartDate DATETIME, @EndDate DATETIME, @AcademicYearId VARCHAR(50), @Semester INT;
        SELECT 
            @StartDate = start_date,
            @EndDate = end_date,
            @AcademicYearId = academic_year_id,
            @Semester = semester
        FROM registration_periods
        WHERE period_id = @PeriodId;
        
        IF GETDATE() < @StartDate
        BEGIN
            THROW 50018, N'ChÆ°a Ä‘áº¿n thá»i gian má»Ÿ Ä‘á»£t Ä‘Äƒng kĂ½', 1;
        END
        
        IF GETDATE() > @EndDate
        BEGIN
            THROW 50019, N'ÄĂ£ quĂ¡ thá»i gian Ä‘Äƒng kĂ½', 1;
        END
        
        -- Close all other OPEN periods for the same academic year and semester
        UPDATE registration_periods
        SET 
            status = 'CLOSED',
            updated_at = GETDATE(),
            updated_by = @UpdatedBy
        WHERE academic_year_id = @AcademicYearId
        AND semester = @Semester
        AND status = 'OPEN'
        AND period_id != @PeriodId
        AND deleted_at IS NULL;
        
        -- Open the requested period
        UPDATE registration_periods
        SET 
            status = 'OPEN',
            updated_at = GETDATE(),
            updated_by = @UpdatedBy
        WHERE period_id = @PeriodId;
        
        COMMIT TRANSACTION;
        
        -- Return updated period
        EXEC sp_GetRegistrationPeriodById @PeriodId;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

IF OBJECT_ID('sp_RemoveStudentFromAdminClass', 'P') IS NOT NULL
    DROP PROCEDURE sp_RemoveStudentFromAdminClass;
GO
CREATE PROCEDURE sp_RemoveStudentFromAdminClass
    @StudentId VARCHAR(50),
    @UpdatedBy VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if student exists
        IF NOT EXISTS (SELECT 1 FROM students WHERE student_id = @StudentId AND deleted_at IS NULL)
        BEGIN
            THROW 50009, N'KhĂ´ng tĂ¬m tháº¥y sinh viĂªn', 1;
        END
        
        -- Get student's current class
        DECLARE @AdminClassId VARCHAR(50);
        SELECT @AdminClassId = admin_class_id FROM students WHERE student_id = @StudentId;
        
        IF @AdminClassId IS NULL
        BEGIN
            THROW 50011, N'Sinh viĂªn chÆ°a cĂ³ lá»›p hĂ nh chĂ­nh', 1;
        END
        
        -- Remove student from class
        UPDATE students
        SET admin_class_id = NULL
        WHERE student_id = @StudentId;
        
        -- Decrease class count
        UPDATE administrative_classes
        SET current_students = current_students - 1,
            updated_at = GETDATE(),
            updated_by = @UpdatedBy
        WHERE admin_class_id = @AdminClassId;
        
        COMMIT TRANSACTION;
        
        SELECT 1 AS Success, N'XĂ³a sinh viĂªn khá»i lá»›p thĂ nh cĂ´ng' AS Message;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

IF OBJECT_ID('sp_UpdateAdministrativeClass', 'P') IS NOT NULL
    DROP PROCEDURE sp_UpdateAdministrativeClass;
GO
CREATE PROCEDURE sp_UpdateAdministrativeClass
    @AdminClassId VARCHAR(50),
    @ClassCode VARCHAR(20) = NULL,
    @ClassName NVARCHAR(150) = NULL,
    @MajorId VARCHAR(50) = NULL,
    @CohortYear INT = NULL,
    @AdvisorId VARCHAR(50) = NULL,
    @AcademicYearId VARCHAR(50) = NULL,
    @MaxStudents INT = NULL,
    @Description NVARCHAR(500) = NULL,
    @UpdatedBy VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if class exists
        IF NOT EXISTS (SELECT 1 FROM administrative_classes WHERE admin_class_id = @AdminClassId AND deleted_at IS NULL)
        BEGIN
            THROW 50002, N'KhĂ´ng tĂ¬m tháº¥y lá»›p hĂ nh chĂ­nh', 1;
        END
        
        -- Validate: Check duplicate class code (if changing)
        IF @ClassCode IS NOT NULL
        BEGIN
            IF EXISTS (
                SELECT 1 FROM administrative_classes 
                WHERE class_code = @ClassCode 
                AND admin_class_id != @AdminClassId 
                AND deleted_at IS NULL
            )
            BEGIN
                THROW 50003, N'MĂ£ lá»›p Ä‘Ă£ tá»“n táº¡i', 1;
            END
        END
        
        -- Validate: Check max_students >= current_students
        IF @MaxStudents IS NOT NULL
        BEGIN
            DECLARE @CurrentStudents INT;
            SELECT @CurrentStudents = current_students 
            FROM administrative_classes 
            WHERE admin_class_id = @AdminClassId;
            
            IF @MaxStudents < @CurrentStudents
            BEGIN
                THROW 50007, N'SÄ© sá»‘ tá»‘i Ä‘a khĂ´ng Ä‘Æ°á»£c nhá» hÆ¡n sÄ© sá»‘ hiá»‡n táº¡i', 1;
            END
        END
        
        -- Update class
        UPDATE administrative_classes
        SET 
            class_code = ISNULL(@ClassCode, class_code),
            class_name = ISNULL(@ClassName, class_name),
            major_id = ISNULL(@MajorId, major_id),
            cohort_year = ISNULL(@CohortYear, cohort_year),
            advisor_id = ISNULL(@AdvisorId, advisor_id),
            academic_year_id = ISNULL(@AcademicYearId, academic_year_id),
            max_students = ISNULL(@MaxStudents, max_students),
            description = ISNULL(@Description, description),
            updated_at = GETDATE(),
            updated_by = @UpdatedBy
        WHERE admin_class_id = @AdminClassId;
        
        COMMIT TRANSACTION;
        
        -- Return updated class
        EXEC sp_GetAdministrativeClassById @AdminClassId;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

IF OBJECT_ID('sp_UpdateEnrollmentStatus', 'P') IS NOT NULL
    DROP PROCEDURE sp_UpdateEnrollmentStatus;
GO
CREATE PROCEDURE sp_UpdateEnrollmentStatus
    @EnrollmentId VARCHAR(50),
    @NewStatus NVARCHAR(20),
    @UpdatedBy VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate status
        IF @NewStatus NOT IN ('PENDING', 'APPROVED', 'DROPPED', 'WITHDRAWN')
        BEGIN
            THROW 50025, N'Tráº¡ng thĂ¡i khĂ´ng há»£p lá»‡', 1;
        END
        
        -- Check if enrollment exists
        IF NOT EXISTS (SELECT 1 FROM enrollments WHERE enrollment_id = @EnrollmentId AND deleted_at IS NULL)
        BEGIN
            THROW 50022, N'KhĂ´ng tĂ¬m tháº¥y Ä‘Äƒng kĂ½', 1;
        END
        
        -- Get old status
        DECLARE @OldStatus NVARCHAR(20), @ClassId VARCHAR(50);
        SELECT @OldStatus = enrollment_status, @ClassId = class_id
        FROM enrollments
        WHERE enrollment_id = @EnrollmentId;
        
        -- Update status
        UPDATE enrollments
        SET enrollment_status = @NewStatus,
            updated_at = GETDATE(),
            updated_by = @UpdatedBy
        WHERE enrollment_id = @EnrollmentId;
        
        -- Adjust class enrollment count
        IF @OldStatus = 'APPROVED' AND @NewStatus != 'APPROVED'
        BEGIN
            UPDATE classes SET current_enrollment = current_enrollment - 1
            WHERE class_id = @ClassId;
        END
        ELSE IF @OldStatus != 'APPROVED' AND @NewStatus = 'APPROVED'
        BEGIN
            UPDATE classes SET current_enrollment = current_enrollment + 1
            WHERE class_id = @ClassId;
        END
        
        COMMIT TRANSACTION;
        
        SELECT 1 AS Success, N'Cáº­p nháº­t tráº¡ng thĂ¡i thĂ nh cĂ´ng' AS Message;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

IF OBJECT_ID('sp_UpdateRegistrationPeriod', 'P') IS NOT NULL
    DROP PROCEDURE sp_UpdateRegistrationPeriod;
GO
CREATE PROCEDURE sp_UpdateRegistrationPeriod
    @PeriodId VARCHAR(50),
    @PeriodName NVARCHAR(200) = NULL,
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @Description NVARCHAR(500) = NULL,
    @UpdatedBy VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if period exists
        IF NOT EXISTS (SELECT 1 FROM registration_periods WHERE period_id = @PeriodId AND deleted_at IS NULL)
        BEGIN
            THROW 50012, N'KhĂ´ng tĂ¬m tháº¥y Ä‘á»£t Ä‘Äƒng kĂ½', 1;
        END
        
        -- Get current values
        DECLARE @CurrentStartDate DATETIME, @CurrentEndDate DATETIME, @CurrentStatus NVARCHAR(20);
        SELECT 
            @CurrentStartDate = start_date,
            @CurrentEndDate = end_date,
            @CurrentStatus = status
        FROM registration_periods
        WHERE period_id = @PeriodId;
        
        -- Use current values if not provided
        SET @StartDate = ISNULL(@StartDate, @CurrentStartDate);
        SET @EndDate = ISNULL(@EndDate, @CurrentEndDate);
        
        -- Validate: Start date < End date
        IF @StartDate >= @EndDate
        BEGIN
            THROW 50013, N'NgĂ y báº¯t Ä‘áº§u pháº£i nhá» hÆ¡n ngĂ y káº¿t thĂºc', 1;
        END
        
        -- Don't allow editing if status is CLOSED
        IF @CurrentStatus = 'CLOSED'
        BEGIN
            THROW 50016, N'KhĂ´ng thá»ƒ sá»­a Ä‘á»£t Ä‘Äƒng kĂ½ Ä‘Ă£ Ä‘Ă³ng', 1;
        END
        
        -- Update period
        UPDATE registration_periods
        SET 
            period_name = ISNULL(@PeriodName, period_name),
            start_date = @StartDate,
            end_date = @EndDate,
            description = ISNULL(@Description, description),
            updated_at = GETDATE(),
            updated_by = @UpdatedBy
        WHERE period_id = @PeriodId;
        
        COMMIT TRANSACTION;
        
        -- Return updated period
        EXEC sp_GetRegistrationPeriodById @PeriodId;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT '========================================';
PRINT '[OK] Scheduling Management SPs completed';
PRINT '========================================';
GO