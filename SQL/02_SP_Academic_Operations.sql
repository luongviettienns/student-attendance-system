-- ===========================================
-- 02_SP_Academic_Operations.sql
-- ===========================================
-- Description: Attendance and Grades Management
-- ===========================================

USE EducationManagement;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

PRINT '========================================';
PRINT 'Starting: 02_SP_Academic_Operations.sql';
PRINT 'Academic Operations SPs';
PRINT '========================================';
GO

IF OBJECT_ID('sp_CalculateGPA', 'P') IS NOT NULL DROP PROCEDURE sp_CalculateGPA;
GO
CREATE PROCEDURE sp_CalculateGPA
    @StudentId VARCHAR(50),
    @AcademicYearId VARCHAR(50),
    @Semester INT = NULL, -- NULL 
    @CreatedBy VARCHAR(50) = 'system'
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @GpaId VARCHAR(50) = NEWID();
    DECLARE @Gpa10 DECIMAL(4,2);
    DECLARE @Gpa4 DECIMAL(4,2);
    DECLARE @TotalCredits INT;
    DECLARE @AccumulatedCredits INT;
    DECLARE @RankText NVARCHAR(50);

    SELECT 
        @Gpa10 = ROUND(SUM(g.total_score * sub.credits) / NULLIF(SUM(sub.credits), 0), 2),
        @TotalCredits = SUM(sub.credits),
        @AccumulatedCredits = SUM(CASE WHEN g.total_score >= 5.0 THEN sub.credits ELSE 0 END)
    FROM dbo.students s
    INNER JOIN dbo.enrollments e ON s.student_id = e.student_id
    INNER JOIN dbo.classes c ON e.class_id = c.class_id
    INNER JOIN dbo.subjects sub ON c.subject_id = sub.subject_id
    INNER JOIN dbo.grades g ON e.enrollment_id = g.enrollment_id
    WHERE s.student_id = @StudentId
        AND c.academic_year_id = @AcademicYearId
        AND (@Semester IS NULL OR c.semester = @Semester)
        AND g.total_score IS NOT NULL
        AND s.deleted_at IS NULL
        AND e.deleted_at IS NULL;
    
    -- TĂ­nh GPA há»‡ 4
    SELECT 
        @Gpa4 = ROUND(
            SUM(
                CASE 
                    WHEN g.total_score >= 8.5 THEN 4.0
                    WHEN g.total_score >= 8.0 THEN 3.7
                    WHEN g.total_score >= 7.0 THEN 3.0
                    WHEN g.total_score >= 6.5 THEN 2.5
                    WHEN g.total_score >= 5.5 THEN 2.0
                    WHEN g.total_score >= 5.0 THEN 1.5
                    ELSE 0
                END * sub.credits
            ) / NULLIF(SUM(sub.credits), 0),
            2
        )
    FROM dbo.students s
    INNER JOIN dbo.enrollments e ON s.student_id = e.student_id
    INNER JOIN dbo.classes c ON e.class_id = c.class_id
    INNER JOIN dbo.subjects sub ON c.subject_id = sub.subject_id
    INNER JOIN dbo.grades g ON e.enrollment_id = g.enrollment_id
    WHERE s.student_id = @StudentId
        AND c.academic_year_id = @AcademicYearId
        AND (@Semester IS NULL OR c.semester = @Semester)
        AND g.total_score IS NOT NULL
        AND s.deleted_at IS NULL
        AND e.deleted_at IS NULL;
    
    -- Xáº¿p loáº¡i
    SET @RankText = CASE 
        WHEN @Gpa10 >= 8.5 THEN N'Xuất sắc'
        WHEN @Gpa10 >= 7.0 THEN N'Giỏi'
        WHEN @Gpa10 >= 5.5 THEN N'Khá'
        WHEN @Gpa10 >= 4.0 THEN N'Trung bình'
        ELSE N'Yếu'
    END;
    
    -- XĂ³a GPA cÅ© náº¿u cĂ³ (Ä‘á»ƒ cáº­p nháº­t)
    DELETE FROM dbo.gpas 
    WHERE student_id = @StudentId 
        AND academic_year_id = @AcademicYearId 
        AND ((@Semester IS NULL AND semester IS NULL) OR semester = @Semester);
    
    -- ChĂ¨n GPA má»›i
    INSERT INTO dbo.gpas (
        gpa_id, student_id, academic_year_id, semester,
        gpa10, gpa4, total_credits, accumulated_credits, rank_text,
        created_at, created_by
    )
    VALUES (
        @GpaId, @StudentId, @AcademicYearId, @Semester,
        @Gpa10, @Gpa4, @TotalCredits, @AccumulatedCredits, @RankText,
        GETDATE(), @CreatedBy
    );
    
    -- Tráº£ vá» káº¿t quáº£
    SELECT 
        @GpaId as gpa_id,
        @StudentId as student_id,
        @AcademicYearId as academic_year_id,
        @Semester as semester,
        @Gpa10 as gpa10,
        @Gpa4 as gpa4,
        @TotalCredits as total_credits,
        @AccumulatedCredits as accumulated_credits,
        @RankText as rank_text;
END
GO

IF OBJECT_ID('sp_CalculateAllStudentGPA', 'P') IS NOT NULL DROP PROCEDURE sp_CalculateAllStudentGPA;
GO
CREATE PROCEDURE sp_CalculateAllStudentGPA
    @AcademicYearId VARCHAR(50),
    @Semester INT = NULL,
    @CreatedBy VARCHAR(50) = 'system'
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @StudentId VARCHAR(50);
    DECLARE student_cursor CURSOR FOR
        SELECT DISTINCT s.student_id
        FROM dbo.students s
        INNER JOIN dbo.enrollments e ON s.student_id = e.student_id
        INNER JOIN dbo.classes c ON e.class_id = c.class_id
        WHERE c.academic_year_id = @AcademicYearId
            AND (@Semester IS NULL OR c.semester = @Semester)
            AND s.deleted_at IS NULL
            AND e.deleted_at IS NULL;
    
    OPEN student_cursor;
    FETCH NEXT FROM student_cursor INTO @StudentId;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC sp_CalculateGPA 
            @StudentId = @StudentId,
            @AcademicYearId = @AcademicYearId,
            @Semester = @Semester,
            @CreatedBy = @CreatedBy;
        
        FETCH NEXT FROM student_cursor INTO @StudentId;
    END
    
    CLOSE student_cursor;
    DEALLOCATE student_cursor;
    
    SELECT 'SUCCESS' as Status, 
           COUNT(*) as TotalStudentsProcessed
    FROM dbo.gpas
    WHERE academic_year_id = @AcademicYearId
        AND ((@Semester IS NULL AND semester IS NULL) OR semester = @Semester);
END
GO

IF OBJECT_ID('sp_CalculateGPABySchoolYear', 'P') IS NOT NULL DROP PROCEDURE sp_CalculateGPABySchoolYear;
GO
CREATE PROCEDURE sp_CalculateGPABySchoolYear
    @StudentId VARCHAR(50),
    @SchoolYearId VARCHAR(50),
    @Semester VARCHAR(20) = NULL,
    @CreatedBy VARCHAR(50) = 'system'
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @GpaId VARCHAR(50) = NEWID();
    DECLARE @Gpa10 DECIMAL(4,2);
    DECLARE @Gpa4 DECIMAL(4,2);
    DECLARE @TotalCredits INT = 0;
    DECLARE @AccumulatedCredits INT = 0;
    DECLARE @RankText NVARCHAR(50);
    DECLARE @AcademicYearId VARCHAR(50);
    
    -- Get academic_year_id from school_year (may be NULL)
    SELECT @AcademicYearId = academic_year_id
    FROM dbo.school_years
    WHERE school_year_id = @SchoolYearId;
    
    -- If academic_year_id is NULL, try to get from student's cohort
    IF @AcademicYearId IS NULL
    BEGIN
        SELECT TOP 1 @AcademicYearId = academic_year_id
        FROM dbo.students
        WHERE student_id = @StudentId;
    END
    
    -- Calculate GPA from grades
    SELECT 
        @Gpa10 = ROUND(SUM(g.total_score * sub.credits) / NULLIF(SUM(sub.credits), 0), 2),
        @TotalCredits = SUM(sub.credits),
        @AccumulatedCredits = SUM(CASE WHEN g.total_score >= 5.0 THEN sub.credits ELSE 0 END)
    FROM dbo.grades g
    INNER JOIN dbo.enrollments e ON g.enrollment_id = e.enrollment_id
    INNER JOIN dbo.classes c ON e.class_id = c.class_id
    INNER JOIN dbo.subjects sub ON c.subject_id = sub.subject_id
    WHERE e.student_id = @StudentId
        AND c.school_year_id = @SchoolYearId
        AND (@Semester IS NULL OR c.semester = @Semester)
        AND g.total_score IS NOT NULL
        AND e.deleted_at IS NULL;
    
    -- If no grades found
    IF @Gpa10 IS NULL
    BEGIN
        SET @Gpa10 = 0;
        SET @Gpa4 = 0;
    END
    ELSE
    BEGIN
        -- Convert GPA 10 to GPA 4
        SET @Gpa4 = CASE
            WHEN @Gpa10 >= 9.0 THEN 4.0
            WHEN @Gpa10 >= 8.5 THEN 3.7
            WHEN @Gpa10 >= 8.0 THEN 3.5
            WHEN @Gpa10 >= 7.0 THEN 3.0
            WHEN @Gpa10 >= 6.5 THEN 2.5
            WHEN @Gpa10 >= 6.0 THEN 2.0
            WHEN @Gpa10 >= 5.5 THEN 1.5
            WHEN @Gpa10 >= 5.0 THEN 1.0
            ELSE 0.0
        END;
    END
    
    -- Determine rank
    SET @RankText = CASE
        WHEN @Gpa10 >= 9.0 THEN N'Xuất sắc'
        WHEN @Gpa10 >= 8.0 THEN N'Giỏi'
        WHEN @Gpa10 >= 7.0 THEN N'Khá'
        WHEN @Gpa10 >= 5.5 THEN N'Trung bình'
        ELSE N'Yếu'
    END;
    
    -- Convert semester string to int (1, 2, or NULL)
    DECLARE @SemesterInt INT = NULL;
    IF @Semester IS NOT NULL AND @Semester IN ('1', '2')
    BEGIN
        SET @SemesterInt = CAST(@Semester AS INT);
    END
    
    -- Delete old GPA record if exists (to avoid unique constraint violation)
    -- Delete based on both academic_year_id and school_year_id to handle cases where
    -- multiple school_years share the same academic_year_id (e.g., SY2021, SY2022, SY2023 all belong to AY2021)
    DELETE FROM dbo.gpas 
    WHERE student_id = @StudentId 
      AND academic_year_id = @AcademicYearId
      AND school_year_id = @SchoolYearId
      AND ((@SemesterInt IS NULL AND semester IS NULL) OR semester = @SemesterInt);
    
    -- Insert new GPA record
    INSERT INTO dbo.gpas (gpa_id, student_id, academic_year_id, school_year_id, semester,
                          gpa10, gpa4, total_credits, accumulated_credits, rank_text,
                          is_active, created_at, created_by)
    VALUES (@GpaId, @StudentId, @AcademicYearId, @SchoolYearId, @SemesterInt,
            @Gpa10, @Gpa4, @TotalCredits, @AccumulatedCredits, @RankText,
            1, GETDATE(), @CreatedBy);
END
GO

IF OBJECT_ID('sp_CreateAttendance', 'P') IS NOT NULL DROP PROCEDURE sp_CreateAttendance;
GO
CREATE PROCEDURE sp_CreateAttendance
    @AttendanceId VARCHAR(50),
    @StudentId VARCHAR(50),           -- ✅ New: Student ID
    @ScheduleId VARCHAR(50),          -- ✅ New: Schedule ID (timetable_session_id)
    @AttendanceDate DATETIME,
    @Status NVARCHAR(20),
    @Note NVARCHAR(500) = NULL,
    @MarkedBy VARCHAR(50) = NULL,     -- ✅ New: Marked by (who marked attendance)
    @CreatedBy VARCHAR(50) = 'system',
    @EnrollmentId VARCHAR(50) = NULL, -- ✅ Optional: Can provide directly
    @ClassId VARCHAR(50) = NULL        -- ✅ Optional: Can provide directly
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        DECLARE @ActualEnrollmentId VARCHAR(50);
        DECLARE @ActualClassId VARCHAR(50);
        DECLARE @ErrorMsg NVARCHAR(500);
        
        -- ✅ 1. Get ClassId from ScheduleId (timetable_sessions)
        IF @ClassId IS NULL OR @ClassId = ''
        BEGIN
            SELECT TOP 1 @ActualClassId = class_id
            FROM dbo.timetable_sessions
            WHERE session_id = @ScheduleId
            AND deleted_at IS NULL;
            
            IF @ActualClassId IS NULL
            BEGIN
                THROW 50001, N'Không tìm thấy lớp học từ lịch học (schedule)', 1;
            END
        END
        ELSE
        BEGIN
            SET @ActualClassId = @ClassId;
        END
        
        -- ✅ 2. Get EnrollmentId from StudentId and ClassId
        IF @EnrollmentId IS NULL OR @EnrollmentId = ''
        BEGIN
            SELECT TOP 1 @ActualEnrollmentId = enrollment_id
            FROM dbo.enrollments
            WHERE student_id = @StudentId
            AND class_id = @ActualClassId
            AND enrollment_status = 'APPROVED'  -- ✅ Chỉ lấy enrollment đã được duyệt
            AND deleted_at IS NULL
            ORDER BY enrollment_date DESC;  -- ✅ Lấy enrollment mới nhất (nếu có nhiều)
            
            IF @ActualEnrollmentId IS NULL
            BEGIN
                THROW 50001, N'Không tìm thấy đăng ký học phần cho sinh viên này trong lớp học. Sinh viên có thể chưa đăng ký hoặc đăng ký chưa được duyệt.', 1;
            END
        END
        ELSE
        BEGIN
            -- ✅ Validate provided EnrollmentId
            IF NOT EXISTS (
                SELECT 1 FROM dbo.enrollments
                WHERE enrollment_id = @EnrollmentId
                AND student_id = @StudentId
                AND class_id = @ActualClassId
                AND enrollment_status = 'APPROVED'
                AND deleted_at IS NULL
            )
            BEGIN
                THROW 50001, N'Enrollment ID không hợp lệ hoặc không thuộc về sinh viên/lớp học này', 1;
            END
            
            SET @ActualEnrollmentId = @EnrollmentId;
        END
        
        -- ✅ 3. Validate: Chỉ được điểm danh cho ngày hôm nay
        DECLARE @Today DATE = CAST(GETDATE() AS DATE);
        DECLARE @AttendanceDateOnly DATE = CAST(@AttendanceDate AS DATE);
        
        IF @AttendanceDateOnly != @Today
        BEGIN
            SET @ErrorMsg = N'Chỉ được điểm danh cho ngày hôm nay. Ngày điểm danh phải là: ' + CONVERT(NVARCHAR(10), @Today, 120);
            THROW 50001, @ErrorMsg, 1;
        END
        
        -- ✅ 4. Validate Status
        IF @Status NOT IN ('Present', 'Absent', 'Late', 'Excused')
        BEGIN
            THROW 50001, N'Trạng thái điểm danh không hợp lệ. Chỉ chấp nhận: Present, Absent, Late, Excused', 1;
        END
        
        -- ✅ 5. Check for duplicate attendance (same student, same schedule, same date)
        IF EXISTS (
            SELECT 1 FROM dbo.attendances
            WHERE enrollment_id = @ActualEnrollmentId
            AND class_id = @ActualClassId
            AND CAST(attendance_date AS DATE) = CAST(@AttendanceDate AS DATE)
            AND deleted_at IS NULL
        )
        BEGIN
            -- ✅ Nếu đã có attendance, cập nhật thay vì tạo mới
            UPDATE dbo.attendances
            SET status = @Status,
                note = @Note,
                updated_at = GETDATE(),
                updated_by = @CreatedBy
            WHERE enrollment_id = @ActualEnrollmentId
            AND class_id = @ActualClassId
            AND CAST(attendance_date AS DATE) = CAST(@AttendanceDate AS DATE)
            AND deleted_at IS NULL;
            
            SELECT @AttendanceId as attendance_id;
            RETURN;  -- ✅ Exit early after update
        END
        
        -- ✅ 6. Insert new attendance record
        INSERT INTO dbo.attendances (attendance_id, enrollment_id, class_id, attendance_date,
                                      status, note, created_at, created_by)
        VALUES (@AttendanceId, @ActualEnrollmentId, @ActualClassId, @AttendanceDate, @Status, @Note,
                GETDATE(), @CreatedBy);
        
        SELECT @AttendanceId as attendance_id;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

IF OBJECT_ID('sp_CreateGrade', 'P') IS NOT NULL DROP PROCEDURE sp_CreateGrade;
GO
CREATE PROCEDURE sp_CreateGrade
    @GradeId VARCHAR(50),
    @StudentId VARCHAR(50) = NULL,  -- New: Student ID (if EnrollmentId not provided)
    @ClassId VARCHAR(50) = NULL,    -- New: Class ID (if EnrollmentId not provided)
    @EnrollmentId VARCHAR(50) = NULL, -- Optional: Can provide directly or find from StudentId+ClassId
    @GradeType VARCHAR(20) = NULL,   -- New: midterm, final, assignment, quiz, project
    @Score DECIMAL(4,2) = NULL,      -- New: Score value
    @MaxScore DECIMAL(4,2) = 10.0,  -- New: Max score (default 10)
    @Weight DECIMAL(5,2) = NULL,     -- New: Weight (for formula calculation)
    @Notes NVARCHAR(500) = NULL,     -- New: Notes
    @GradedBy VARCHAR(50) = NULL,    -- New: Who graded this
    @MidtermScore DECIMAL(4,2) = NULL, -- Legacy: For backward compatibility
    @FinalScore DECIMAL(4,2) = NULL,   -- Legacy: For backward compatibility
    @CreatedBy VARCHAR(50) = 'system'
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        DECLARE @ActualEnrollmentId VARCHAR(50);
        DECLARE @ActualMidtermScore DECIMAL(4,2) = NULL;
        DECLARE @ActualFinalScore DECIMAL(4,2) = NULL;
        
        -- 1. Resolve EnrollmentId
        IF @EnrollmentId IS NOT NULL AND @EnrollmentId != ''
        BEGIN
            SET @ActualEnrollmentId = @EnrollmentId;
        END
        ELSE IF @StudentId IS NOT NULL AND @ClassId IS NOT NULL
        BEGIN
            -- Find enrollment by studentId and classId
            SELECT TOP 1 @ActualEnrollmentId = enrollment_id
            FROM dbo.enrollments
            WHERE student_id = @StudentId
            AND class_id = @ClassId
            AND enrollment_status = 'APPROVED'
            AND deleted_at IS NULL
            ORDER BY enrollment_date DESC;
            
            IF @ActualEnrollmentId IS NULL
            BEGIN
                THROW 50001, N'Không tìm thấy đăng ký học phần cho sinh viên này trong lớp học', 1;
            END
        END
        ELSE
        BEGIN
            THROW 50001, N'Phải cung cấp EnrollmentId hoặc (StudentId + ClassId)', 1;
        END
        
        -- 2. Map GradeType to midterm_score or final_score
        IF @GradeType IS NOT NULL AND @Score IS NOT NULL
        BEGIN
            IF @GradeType IN ('midterm', 'Midterm', 'MIDTERM')
            BEGIN
                SET @ActualMidtermScore = @Score;
            END
            ELSE IF @GradeType IN ('final', 'Final', 'FINAL')
            BEGIN
                SET @ActualFinalScore = @Score;
            END
            -- Note: assignment, quiz, project are not stored in grades table
            -- They might be stored in a separate table or calculated later
        END
        ELSE IF @MidtermScore IS NOT NULL OR @FinalScore IS NOT NULL
        BEGIN
            -- Legacy mode: use provided midterm/final scores
            SET @ActualMidtermScore = @MidtermScore;
            SET @ActualFinalScore = @FinalScore;
        END
        ELSE
        BEGIN
            THROW 50001, N'Phải cung cấp điểm (Score + GradeType hoặc MidtermScore/FinalScore)', 1;
        END
        
        -- 3. Check if grade already exists for this enrollment
        DECLARE @ExistingGradeId VARCHAR(50);
        SELECT TOP 1 @ExistingGradeId = grade_id
        FROM dbo.grades
        WHERE enrollment_id = @ActualEnrollmentId;
        
        IF @ExistingGradeId IS NOT NULL
        BEGIN
            -- Update existing grade instead of creating new one
            IF @ActualMidtermScore IS NOT NULL
            BEGIN
                UPDATE dbo.grades
                SET midterm_score = @ActualMidtermScore,
                    updated_at = GETDATE(),
                    updated_by = @CreatedBy
                WHERE grade_id = @ExistingGradeId;
            END
            
            IF @ActualFinalScore IS NOT NULL
            BEGIN
                UPDATE dbo.grades
                SET final_score = @ActualFinalScore,
                    updated_at = GETDATE(),
                    updated_by = @CreatedBy
                WHERE grade_id = @ExistingGradeId;
            END
            
            SELECT @ExistingGradeId as grade_id;
        END
        ELSE
        BEGIN
            -- Create new grade
            INSERT INTO dbo.grades (grade_id, enrollment_id, midterm_score, final_score,
                                    created_at, created_by)
            VALUES (@GradeId, @ActualEnrollmentId, @ActualMidtermScore, @ActualFinalScore, 
                    GETDATE(), @CreatedBy);
            
            SELECT @GradeId as grade_id;
        END
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

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

IF OBJECT_ID('sp_DeleteGrade', 'P') IS NOT NULL DROP PROCEDURE sp_DeleteGrade;
GO
CREATE PROCEDURE sp_DeleteGrade
    @GradeId VARCHAR(50),
    @DeletedBy VARCHAR(50) = 'system'
AS
BEGIN
    DELETE FROM dbo.grades WHERE grade_id = @GradeId;
END
GO

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
        AND e.deleted_at IS NULL
    ORDER BY a.attendance_date DESC, s.student_code;
END
GO

IF OBJECT_ID('sp_GetAllGrades', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllGrades;
GO
CREATE PROCEDURE sp_GetAllGrades
AS
BEGIN
    SELECT 
        g.grade_id,
        g.enrollment_id,
        g.midterm_score,
        g.final_score,
        g.total_score,
        g.letter_grade,
        g.created_at,
        g.created_by,
        g.updated_at,
        g.updated_by,
        e.student_id,
        e.class_id,
        s.student_code,
        s.full_name as student_name,
        c.class_code,
        c.class_name,
        sy.year_code as school_year_code,
        sub.subject_name
    FROM dbo.grades g
    INNER JOIN dbo.enrollments e ON g.enrollment_id = e.enrollment_id
    INNER JOIN dbo.students s ON e.student_id = s.student_id
    INNER JOIN dbo.classes c ON e.class_id = c.class_id
    LEFT JOIN dbo.school_years sy ON c.school_year_id = sy.school_year_id
    LEFT JOIN dbo.subjects sub ON c.subject_id = sub.subject_id
    ORDER BY sy.start_date DESC, c.semester;
END
GO

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
    WHERE a.attendance_id = @AttendanceId 
        AND a.deleted_at IS NULL
        AND e.deleted_at IS NULL;
END
GO

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
        AND a.deleted_at IS NULL
        AND e.deleted_at IS NULL
        AND (@AttendanceDate IS NULL OR CAST(a.attendance_date AS DATE) = @AttendanceDate)
    ORDER BY s.student_code;
END
GO

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
    WHERE ts.session_id = @ScheduleId 
        AND a.deleted_at IS NULL
        AND e.deleted_at IS NULL
    ORDER BY a.attendance_date DESC, s.student_code;
END
GO

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
    WHERE e.student_id = @StudentId 
        AND a.deleted_at IS NULL
        AND e.deleted_at IS NULL
    ORDER BY a.attendance_date DESC;
END
GO

IF OBJECT_ID('sp_GetGPAsByStudent', 'P') IS NOT NULL DROP PROCEDURE sp_GetGPAsByStudent;
GO
CREATE PROCEDURE sp_GetGPAsByStudent
    @StudentId VARCHAR(50),
    @AcademicYearId VARCHAR(50) = NULL
AS
BEGIN
    SELECT 
        g.gpa_id,
        g.student_id,
        g.academic_year_id,
        g.school_year_id,
        COALESCE(g.semester, 0) as semester, -- 0 = Cả năm (thay thế NULL)
        CASE 
            WHEN g.semester IS NULL THEN N'Cả năm'
            WHEN g.semester = 1 THEN N'Học kỳ 1'
            WHEN g.semester = 2 THEN N'Học kỳ 2'
            WHEN g.semester = 3 THEN N'Học kỳ hè'
            ELSE N'Không xác định'
        END as semester_text,
        g.gpa10,
        g.gpa4,
        g.total_credits,
        g.accumulated_credits,
        g.rank_text,
        g.is_active,
        g.created_at,
        g.created_by,
        g.updated_at,
        g.updated_by,
        g.deleted_at,
        g.deleted_by,
        s.student_code,
        s.full_name as student_name,
        ay.year_name as academic_year_name
    FROM dbo.gpas g
    INNER JOIN dbo.students s ON g.student_id = s.student_id
    INNER JOIN dbo.academic_years ay ON g.academic_year_id = ay.academic_year_id
    WHERE g.student_id = @StudentId
        AND (@AcademicYearId IS NULL OR g.academic_year_id = @AcademicYearId)
        AND g.deleted_at IS NULL
    ORDER BY ay.start_year DESC, COALESCE(g.semester, 0);
END
GO

IF OBJECT_ID('sp_GetCumulativeGPA', 'P') IS NOT NULL DROP PROCEDURE sp_GetCumulativeGPA;
GO
CREATE PROCEDURE sp_GetCumulativeGPA
    @StudentId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Tính GPA tích lũy từ TẤT CẢ các môn đã học (không filter theo năm học/học kỳ)
    SELECT 
        @StudentId as student_id,
        s.student_code,
        s.full_name as student_name,
        -- GPA tích lũy hệ 10 (tính từ tất cả môn đã học)
        ROUND(SUM(g.total_score * sub.credits) / NULLIF(SUM(sub.credits), 0), 2) as cumulative_gpa10,
        -- GPA tích lũy hệ 4
        ROUND(
            SUM(
                CASE 
                    WHEN g.total_score >= 9.0 THEN 4.0
                    WHEN g.total_score >= 8.5 THEN 3.7
                    WHEN g.total_score >= 8.0 THEN 3.5
                    WHEN g.total_score >= 7.0 THEN 3.0
                    WHEN g.total_score >= 6.5 THEN 2.5
                    WHEN g.total_score >= 6.0 THEN 2.0
                    WHEN g.total_score >= 5.5 THEN 1.5
                    WHEN g.total_score >= 5.0 THEN 1.0
                    ELSE 0
                END * sub.credits
            ) / NULLIF(SUM(sub.credits), 0),
            2
        ) as cumulative_gpa4,
        -- Tổng tín chỉ đã học
        SUM(sub.credits) as total_credits_earned,
        -- Tín chỉ tích lũy (môn đạt >= 4.0)
        SUM(CASE WHEN g.total_score >= 5.0 THEN sub.credits ELSE 0 END) as accumulated_credits,
        -- Số môn đã học
        COUNT(*) as total_subjects,
        -- Số môn đạt (>= 5.0)
        SUM(CASE WHEN g.total_score >= 5.0 THEN 1 ELSE 0 END) as passed_subjects,
        -- Số môn chưa đạt (< 5.0)
        SUM(CASE WHEN g.total_score < 5.0 AND g.total_score IS NOT NULL THEN 1 ELSE 0 END) as failed_subjects,
        -- Xếp loại tổng hợp
        CASE 
            WHEN ROUND(SUM(g.total_score * sub.credits) / NULLIF(SUM(sub.credits), 0), 2) >= 9.0 THEN N'Xuất sắc'
            WHEN ROUND(SUM(g.total_score * sub.credits) / NULLIF(SUM(sub.credits), 0), 2) >= 8.0 THEN N'Giỏi'
            WHEN ROUND(SUM(g.total_score * sub.credits) / NULLIF(SUM(sub.credits), 0), 2) >= 7.0 THEN N'Khá'
            WHEN ROUND(SUM(g.total_score * sub.credits) / NULLIF(SUM(sub.credits), 0), 2) >= 5.5 THEN N'Trung bình'
            WHEN ROUND(SUM(g.total_score * sub.credits) / NULLIF(SUM(sub.credits), 0), 2) >= 5.0 THEN N'Yếu'
            ELSE N'Kém'
        END as overall_rank
    FROM dbo.students s
    INNER JOIN dbo.enrollments e ON s.student_id = e.student_id
    INNER JOIN dbo.classes c ON e.class_id = c.class_id
    INNER JOIN dbo.subjects sub ON c.subject_id = sub.subject_id
    INNER JOIN dbo.grades g ON e.enrollment_id = g.enrollment_id
    WHERE s.student_id = @StudentId
        AND g.total_score IS NOT NULL
        AND s.deleted_at IS NULL
        AND e.deleted_at IS NULL
    GROUP BY s.student_id, s.student_code, s.full_name;
END
GO

IF OBJECT_ID('sp_GetStudentTranscript', 'P') IS NOT NULL DROP PROCEDURE sp_GetStudentTranscript;
GO
CREATE PROCEDURE sp_GetStudentTranscript
    @StudentId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Lấy tất cả GPA theo từng học kỳ/năm học để hiển thị transcript
    SELECT 
        g.gpa_id,
        g.student_id,
        s.student_code,
        s.full_name as student_name,
        g.academic_year_id,
        ay.year_name as academic_year_name,
        -- Lấy cohort_code từ academic_years
        ay.cohort_code,
        g.school_year_id,
        sy.year_code as school_year_code,
        sy.year_name as school_year_name,
        COALESCE(g.semester, 0) as semester, -- 0 = Cả năm (thay thế NULL)
        CASE 
            WHEN g.semester IS NULL THEN N'Cả năm'
            WHEN g.semester = 1 THEN N'Học kỳ 1'
            WHEN g.semester = 2 THEN N'Học kỳ 2'
            WHEN g.semester = 3 THEN N'Học kỳ hè'
            ELSE N'Không xác định'
        END as semester_text,
        g.gpa10,
        g.gpa4,
        g.total_credits,
        g.accumulated_credits,
        g.rank_text,
        g.created_at as calculated_at
    FROM dbo.gpas g
    INNER JOIN dbo.students s ON g.student_id = s.student_id
    LEFT JOIN dbo.academic_years ay ON g.academic_year_id = ay.academic_year_id
    LEFT JOIN dbo.school_years sy ON g.school_year_id = sy.school_year_id
    WHERE g.student_id = @StudentId
        AND g.deleted_at IS NULL
        AND s.deleted_at IS NULL
    ORDER BY 
        CASE WHEN ay.start_year IS NOT NULL THEN ay.start_year ELSE 0 END DESC,
        CASE WHEN g.semester IS NULL THEN 0 ELSE g.semester END;
END
GO

IF OBJECT_ID('sp_GetGradeById', 'P') IS NOT NULL DROP PROCEDURE sp_GetGradeById;
GO
CREATE PROCEDURE sp_GetGradeById
    @GradeId VARCHAR(50)
AS
BEGIN
    SELECT 
        g.grade_id,
        g.enrollment_id,
        g.midterm_score,
        g.final_score,
        g.total_score,
        g.letter_grade,
        g.created_at,
        g.created_by,
        g.updated_at,
        g.updated_by,
        e.student_id,
        e.class_id,
        s.student_code,
        s.full_name as student_name,
        c.class_code,
        c.class_name,
        sy.year_code as school_year_code,
        sub.subject_name
    FROM dbo.grades g
    INNER JOIN dbo.enrollments e ON g.enrollment_id = e.enrollment_id
    INNER JOIN dbo.students s ON e.student_id = s.student_id
    INNER JOIN dbo.classes c ON e.class_id = c.class_id
    LEFT JOIN dbo.school_years sy ON c.school_year_id = sy.school_year_id
    LEFT JOIN dbo.subjects sub ON c.subject_id = sub.subject_id
    WHERE g.grade_id = @GradeId;
END
GO

IF OBJECT_ID('sp_GetGradesByClass', 'P') IS NOT NULL DROP PROCEDURE sp_GetGradesByClass;
GO
CREATE PROCEDURE sp_GetGradesByClass
    @ClassId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Return grades with student info
    -- Note: Since grades table only has midterm_score and final_score,
    -- we return both as separate rows or combine them
    SELECT 
        g.grade_id,
        g.enrollment_id,
        g.midterm_score,
        g.final_score,
        g.total_score,
        g.letter_grade,
        g.created_at,
        g.created_by,
        g.updated_at,
        g.updated_by,
        e.student_id,
        e.class_id,
        s.student_code,
        s.full_name as student_name,
        -- Add grade type indicators (derived from which score is not null)
        CASE 
            WHEN g.midterm_score IS NOT NULL THEN 'midterm'
            WHEN g.final_score IS NOT NULL THEN 'final'
            ELSE NULL
        END AS grade_type,
        -- Score value (for the grade type)
        COALESCE(g.midterm_score, g.final_score) AS score
    FROM dbo.grades g
    INNER JOIN dbo.enrollments e ON g.enrollment_id = e.enrollment_id
    INNER JOIN dbo.students s ON e.student_id = s.student_id
    WHERE e.class_id = @ClassId
    AND e.deleted_at IS NULL
    ORDER BY s.student_code;
END
GO

IF OBJECT_ID('sp_GetGradesByStudent', 'P') IS NOT NULL DROP PROCEDURE sp_GetGradesByStudent;
GO
CREATE PROCEDURE sp_GetGradesByStudent
    @StudentId VARCHAR(50)
AS
BEGIN
    SELECT 
        g.grade_id,
        g.enrollment_id,
        g.midterm_score,
        g.final_score,
        g.total_score,
        g.letter_grade,
        g.created_at,
        g.created_by,
        g.updated_at,
        g.updated_by,
        e.student_id,
        e.class_id,
        s.student_code,
        s.full_name as student_name,
        c.class_code,
        c.class_name,
        sy.year_code as school_year_code,
        sub.subject_name
    FROM dbo.grades g
    INNER JOIN dbo.enrollments e ON g.enrollment_id = e.enrollment_id
    INNER JOIN dbo.students s ON e.student_id = s.student_id
    INNER JOIN dbo.classes c ON e.class_id = c.class_id
    LEFT JOIN dbo.school_years sy ON c.school_year_id = sy.school_year_id
    LEFT JOIN dbo.subjects sub ON c.subject_id = sub.subject_id
    WHERE e.student_id = @StudentId
    ORDER BY sy.start_date DESC, c.semester;
END
GO

IF OBJECT_ID('sp_GetGradesByStudentSchoolYear', 'P') IS NOT NULL DROP PROCEDURE sp_GetGradesByStudentSchoolYear;
GO
CREATE PROCEDURE sp_GetGradesByStudentSchoolYear
    @StudentId VARCHAR(50),
    @SchoolYearId VARCHAR(50) = NULL,
    @Semester VARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Convert semester to INT if provided
    DECLARE @SemesterInt INT = NULL;
    IF @Semester IS NOT NULL AND @Semester != ''
    BEGIN
        SET @SemesterInt = CAST(@Semester AS INT);
    END
    
    SELECT 
        g.grade_id,
        g.enrollment_id,
        g.midterm_score,
        g.final_score,
        g.total_score,
        g.letter_grade,
        g.created_at,
        g.created_by,
        g.updated_at,
        g.updated_by,
        -- From enrollment
        e.student_id,
        e.class_id,
        -- From student
        s.student_code,
        s.full_name as student_name,
        -- From class
        c.class_code,
        c.class_name,
        c.semester,
        c.school_year_id,
        c.academic_year_id,
        -- From school year
        sy.year_code as school_year_code,
        -- From subject
        sub.subject_name,
        sub.credits
    FROM dbo.grades g
    INNER JOIN dbo.enrollments e ON g.enrollment_id = e.enrollment_id
    INNER JOIN dbo.students s ON e.student_id = s.student_id
    INNER JOIN dbo.classes c ON e.class_id = c.class_id
    LEFT JOIN dbo.school_years sy ON c.school_year_id = sy.school_year_id
    LEFT JOIN dbo.subjects sub ON c.subject_id = sub.subject_id
    WHERE e.student_id = @StudentId
        AND (@SchoolYearId IS NULL OR c.school_year_id = @SchoolYearId)
        AND (@SemesterInt IS NULL OR c.semester = @SemesterInt)
        AND e.deleted_at IS NULL
    ORDER BY sy.start_date DESC, c.semester, sub.subject_name;
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
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- ✅ Validate attendance exists
        IF NOT EXISTS (
            SELECT 1 FROM dbo.attendances
            WHERE attendance_id = @AttendanceId
            AND deleted_at IS NULL
        )
        BEGIN
            THROW 50001, N'Không tìm thấy bản ghi điểm danh', 1;
        END
        
        -- ✅ Validate status
        IF @Status NOT IN ('Present', 'Absent', 'Late', 'Excused')
        BEGIN
            THROW 50001, N'Trạng thái điểm danh không hợp lệ. Chỉ chấp nhận: Present, Absent, Late, Excused', 1;
        END
        
        -- ✅ Update attendance
        UPDATE dbo.attendances
        SET status = @Status, 
            note = @Note, 
            updated_at = GETDATE(), 
            updated_by = @UpdatedBy
        WHERE attendance_id = @AttendanceId
        AND deleted_at IS NULL;
        
        SELECT @AttendanceId as attendance_id;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

IF OBJECT_ID('sp_UpdateGrade', 'P') IS NOT NULL DROP PROCEDURE sp_UpdateGrade;
GO
CREATE PROCEDURE sp_UpdateGrade
    @GradeId VARCHAR(50),
    @GradeType VARCHAR(20) = NULL,   -- New: midterm, final, assignment, quiz, project
    @Score DECIMAL(4,2) = NULL,      -- New: Score value
    @MaxScore DECIMAL(4,2) = 10.0,  -- New: Max score (default 10)
    @Weight DECIMAL(5,2) = NULL,     -- New: Weight (for formula calculation)
    @Notes NVARCHAR(500) = NULL,     -- New: Notes
    @MidtermScore DECIMAL(4,2) = NULL, -- Legacy: For backward compatibility
    @FinalScore DECIMAL(4,2) = NULL,   -- Legacy: For backward compatibility
    @UpdatedBy VARCHAR(50) = 'system'
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        DECLARE @ActualMidtermScore DECIMAL(4,2) = NULL;
        DECLARE @ActualFinalScore DECIMAL(4,2) = NULL;
        
        -- Get current grade values
        DECLARE @CurrentMidtermScore DECIMAL(4,2);
        DECLARE @CurrentFinalScore DECIMAL(4,2);
        
        SELECT @CurrentMidtermScore = midterm_score,
               @CurrentFinalScore = final_score
        FROM dbo.grades
        WHERE grade_id = @GradeId;
        
        IF @@ROWCOUNT = 0
        BEGIN
            THROW 50001, N'Không tìm thấy điểm số', 1;
        END
        
        -- Map GradeType to midterm_score or final_score
        IF @GradeType IS NOT NULL AND @Score IS NOT NULL
        BEGIN
            IF @GradeType IN ('midterm', 'Midterm', 'MIDTERM')
            BEGIN
                SET @ActualMidtermScore = @Score;
                SET @ActualFinalScore = @CurrentFinalScore; -- Keep existing final score
            END
            ELSE IF @GradeType IN ('final', 'Final', 'FINAL')
            BEGIN
                SET @ActualFinalScore = @Score;
                SET @ActualMidtermScore = @CurrentMidtermScore; -- Keep existing midterm score
            END
            -- Note: assignment, quiz, project are not stored in grades table
        END
        ELSE IF @MidtermScore IS NOT NULL OR @FinalScore IS NOT NULL
        BEGIN
            -- Legacy mode: use provided midterm/final scores
            SET @ActualMidtermScore = ISNULL(@MidtermScore, @CurrentMidtermScore);
            SET @ActualFinalScore = ISNULL(@FinalScore, @CurrentFinalScore);
        END
        ELSE
        BEGIN
            THROW 50001, N'Phải cung cấp điểm để cập nhật', 1;
        END
        
        -- Update grade
        UPDATE dbo.grades
        SET midterm_score = @ActualMidtermScore,
            final_score = @ActualFinalScore,
            updated_at = GETDATE(),
            updated_by = @UpdatedBy
        WHERE grade_id = @GradeId;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

-- ===========================================
-- RETAKE RECORDS STORED PROCEDURES
-- ===========================================

-- 2.1. CREATE RETAKE RECORD
IF OBJECT_ID('sp_CreateRetakeRecord', 'P') IS NOT NULL DROP PROCEDURE sp_CreateRetakeRecord;
GO
CREATE PROCEDURE sp_CreateRetakeRecord
    @RetakeId VARCHAR(50),
    @EnrollmentId VARCHAR(50),
    @StudentId VARCHAR(50),
    @ClassId VARCHAR(50),
    @SubjectId VARCHAR(50),
    @Reason NVARCHAR(20),
    @ThresholdValue DECIMAL(5,2) = NULL,
    @CurrentValue DECIMAL(5,2) = NULL,
    @CreatedBy VARCHAR(50) = 'system'
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate reason
    IF @Reason NOT IN ('ATTENDANCE', 'GRADE', 'BOTH')
    BEGIN
        RAISERROR('Invalid reason. Must be ATTENDANCE, GRADE, or BOTH', 16, 1);
        RETURN;
    END
    
    -- Check if retake record already exists for this enrollment
    IF EXISTS (SELECT 1 FROM dbo.retake_records 
               WHERE enrollment_id = @EnrollmentId 
               AND deleted_at IS NULL
               AND status IN ('PENDING', 'APPROVED'))
    BEGIN
        RAISERROR('Retake record already exists for this enrollment', 16, 1);
        RETURN;
    END
    
    INSERT INTO dbo.retake_records (
        retake_id, enrollment_id, student_id, class_id, subject_id,
        reason, threshold_value, current_value, status,
        created_at, created_by
    )
    VALUES (
        @RetakeId, @EnrollmentId, @StudentId, @ClassId, @SubjectId,
        @Reason, @ThresholdValue, @CurrentValue, 'PENDING',
        GETDATE(), @CreatedBy
    );
    
    SELECT @RetakeId as retake_id;
END
GO

-- 2.2. GET RETAKE RECORD BY ID
IF OBJECT_ID('sp_GetRetakeRecordById', 'P') IS NOT NULL DROP PROCEDURE sp_GetRetakeRecordById;
GO
CREATE PROCEDURE sp_GetRetakeRecordById
    @RetakeId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        r.retake_id,
        r.enrollment_id,
        r.student_id,
        s.student_code,
        s.full_name as student_name,
        r.class_id,
        c.class_code,
        c.class_name,
        r.subject_id,
        sub.subject_code,
        sub.subject_name,
        r.reason,
        r.threshold_value,
        r.current_value,
        r.status,
        r.advisor_notes,
        r.created_at,
        r.created_by,
        r.updated_at,
        r.updated_by,
        r.resolved_at,
        r.resolved_by,
        -- Additional info
        e.enrollment_date,
        sy.year_code as school_year_code,
        c.semester
    FROM dbo.retake_records r
    INNER JOIN dbo.students s ON r.student_id = s.student_id
    INNER JOIN dbo.classes c ON r.class_id = c.class_id
    INNER JOIN dbo.subjects sub ON r.subject_id = sub.subject_id
    INNER JOIN dbo.enrollments e ON r.enrollment_id = e.enrollment_id
    LEFT JOIN dbo.school_years sy ON c.school_year_id = sy.school_year_id
    WHERE r.retake_id = @RetakeId
        AND r.deleted_at IS NULL;
END
GO

-- 2.3. GET RETAKE RECORDS BY STUDENT
IF OBJECT_ID('sp_GetRetakeRecordsByStudent', 'P') IS NOT NULL DROP PROCEDURE sp_GetRetakeRecordsByStudent;
GO
CREATE PROCEDURE sp_GetRetakeRecordsByStudent
    @StudentId VARCHAR(50),
    @Status NVARCHAR(20) = NULL,
    @Page INT = 1,
    @PageSize INT = 50
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Offset INT = (@Page - 1) * @PageSize;
    
    -- Get retake records
    SELECT 
        r.retake_id,
        r.enrollment_id,
        r.student_id,
        r.class_id,
        c.class_code,
        c.class_name,
        r.subject_id,
        sub.subject_code,
        sub.subject_name,
        r.reason,
        r.threshold_value,
        r.current_value,
        r.status,
        r.advisor_notes,
        r.created_at,
        r.updated_at,
        r.resolved_at,
        sy.year_code as school_year_code,
        c.semester
    FROM dbo.retake_records r
    INNER JOIN dbo.classes c ON r.class_id = c.class_id
    INNER JOIN dbo.subjects sub ON r.subject_id = sub.subject_id
    LEFT JOIN dbo.school_years sy ON c.school_year_id = sy.school_year_id
    WHERE r.student_id = @StudentId
        AND r.deleted_at IS NULL
        AND (@Status IS NULL OR r.status = @Status)
    ORDER BY r.created_at DESC
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;
    
    -- Get total count
    SELECT COUNT(*) as total_count
    FROM dbo.retake_records r
    WHERE r.student_id = @StudentId
        AND r.deleted_at IS NULL
        AND (@Status IS NULL OR r.status = @Status);
END
GO

-- 2.4. GET RETAKE RECORDS BY CLASS
IF OBJECT_ID('sp_GetRetakeRecordsByClass', 'P') IS NOT NULL DROP PROCEDURE sp_GetRetakeRecordsByClass;
GO
CREATE PROCEDURE sp_GetRetakeRecordsByClass
    @ClassId VARCHAR(50),
    @Status NVARCHAR(20) = NULL,
    @Page INT = 1,
    @PageSize INT = 50
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Offset INT = (@Page - 1) * @PageSize;
    
    -- Get retake records
    SELECT 
        r.retake_id,
        r.enrollment_id,
        r.student_id,
        s.student_code,
        s.full_name as student_name,
        r.class_id,
        c.class_code,
        c.class_name,
        r.subject_id,
        sub.subject_code,
        sub.subject_name,
        r.reason,
        r.threshold_value,
        r.current_value,
        r.status,
        r.advisor_notes,
        r.created_at,
        r.updated_at,
        r.resolved_at,
        r.resolved_by,
        sy.year_code as school_year_code,
        c.semester
    FROM dbo.retake_records r
    INNER JOIN dbo.students s ON r.student_id = s.student_id
    INNER JOIN dbo.classes c ON r.class_id = c.class_id
    INNER JOIN dbo.subjects sub ON r.subject_id = sub.subject_id
    LEFT JOIN dbo.school_years sy ON c.school_year_id = sy.school_year_id
    WHERE r.class_id = @ClassId
        AND r.deleted_at IS NULL
        AND (@Status IS NULL OR r.status = @Status)
    ORDER BY r.created_at DESC
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;
    
    -- Get total count
    SELECT COUNT(*) as total_count
    FROM dbo.retake_records r
    WHERE r.class_id = @ClassId
        AND r.deleted_at IS NULL
        AND (@Status IS NULL OR r.status = @Status);
END
GO

-- 2.4.1. GET ALL RETAKE RECORDS (for admin/advisor)
IF OBJECT_ID('sp_GetAllRetakeRecords', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllRetakeRecords;
GO
CREATE PROCEDURE sp_GetAllRetakeRecords
    @Status NVARCHAR(20) = NULL,
    @Page INT = 1,
    @PageSize INT = 50
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Offset INT = (@Page - 1) * @PageSize;
    
    -- Get retake records
    SELECT 
        r.retake_id,
        r.enrollment_id,
        r.student_id,
        s.student_code,
        s.full_name as student_name,
        r.class_id,
        c.class_code,
        c.class_name,
        r.subject_id,
        sub.subject_code,
        sub.subject_name,
        r.reason,
        r.threshold_value,
        r.current_value,
        r.status,
        r.advisor_notes,
        r.created_at,
        r.updated_at,
        r.resolved_at,
        r.resolved_by,
        sy.year_code as school_year_code,
        c.semester
    FROM dbo.retake_records r
    INNER JOIN dbo.students s ON r.student_id = s.student_id
    INNER JOIN dbo.classes c ON r.class_id = c.class_id
    INNER JOIN dbo.subjects sub ON r.subject_id = sub.subject_id
    LEFT JOIN dbo.school_years sy ON c.school_year_id = sy.school_year_id
    WHERE r.deleted_at IS NULL
        AND (@Status IS NULL OR r.status = @Status)
    ORDER BY r.created_at DESC
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;
    
    -- Get total count
    SELECT COUNT(*) as total_count
    FROM dbo.retake_records r
    WHERE r.deleted_at IS NULL
        AND (@Status IS NULL OR r.status = @Status);
END
GO

-- 2.5. GET RETAKE RECORD BY ENROLLMENT
IF OBJECT_ID('sp_GetRetakeRecordByEnrollment', 'P') IS NOT NULL DROP PROCEDURE sp_GetRetakeRecordByEnrollment;
GO
CREATE PROCEDURE sp_GetRetakeRecordByEnrollment
    @EnrollmentId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        r.retake_id,
        r.enrollment_id,
        r.student_id,
        r.class_id,
        r.subject_id,
        r.reason,
        r.threshold_value,
        r.current_value,
        r.status,
        r.advisor_notes,
        r.created_at,
        r.updated_at,
        r.resolved_at
    FROM dbo.retake_records r
    WHERE r.enrollment_id = @EnrollmentId
        AND r.deleted_at IS NULL;
END
GO

-- 2.6. UPDATE RETAKE STATUS
IF OBJECT_ID('sp_UpdateRetakeStatus', 'P') IS NOT NULL DROP PROCEDURE sp_UpdateRetakeStatus;
GO
CREATE PROCEDURE sp_UpdateRetakeStatus
    @RetakeId VARCHAR(50),
    @Status NVARCHAR(20),
    @AdvisorNotes NVARCHAR(1000) = NULL,
    @UpdatedBy VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate status
    IF @Status NOT IN ('PENDING', 'APPROVED', 'REJECTED', 'COMPLETED')
    BEGIN
        RAISERROR('Invalid status. Must be PENDING, APPROVED, REJECTED, or COMPLETED', 16, 1);
        RETURN;
    END
    
    UPDATE dbo.retake_records
    SET 
        status = @Status,
        advisor_notes = ISNULL(@AdvisorNotes, advisor_notes),
        updated_at = GETDATE(),
        updated_by = @UpdatedBy,
        resolved_at = CASE WHEN @Status IN ('APPROVED', 'REJECTED', 'COMPLETED') THEN GETDATE() ELSE resolved_at END,
        resolved_by = CASE WHEN @Status IN ('APPROVED', 'REJECTED', 'COMPLETED') THEN @UpdatedBy ELSE resolved_by END
    WHERE retake_id = @RetakeId
        AND deleted_at IS NULL;
    
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('Retake record not found or already deleted', 16, 1);
        RETURN;
    END
END
GO

-- 2.7. CHECK RETAKE REQUIRED (Helper function)
IF OBJECT_ID('sp_CheckRetakeRequired', 'P') IS NOT NULL DROP PROCEDURE sp_CheckRetakeRequired;
GO
CREATE PROCEDURE sp_CheckRetakeRequired
    @EnrollmentId VARCHAR(50),
    @AttendanceThreshold DECIMAL(5,2) = 20.0,
    @GradeThreshold DECIMAL(4,2) = 5.0
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @StudentId VARCHAR(50);
    DECLARE @ClassId VARCHAR(50);
    DECLARE @SubjectId VARCHAR(50);
    DECLARE @AbsenceRate DECIMAL(5,2);
    DECLARE @TotalScore DECIMAL(4,2);
    DECLARE @Reason NVARCHAR(20) = NULL;
    DECLARE @CurrentValue DECIMAL(5,2) = NULL;
    
    -- Get enrollment info
    SELECT 
        @StudentId = e.student_id,
        @ClassId = e.class_id,
        @SubjectId = c.subject_id
    FROM dbo.enrollments e
    INNER JOIN dbo.classes c ON e.class_id = c.class_id
    WHERE e.enrollment_id = @EnrollmentId
        AND e.deleted_at IS NULL;
    
    IF @StudentId IS NULL
    BEGIN
        SELECT 'NOT_FOUND' as result, NULL as reason, NULL as current_value;
        RETURN;
    END
    
    -- Check if retake already exists
    IF EXISTS (SELECT 1 FROM dbo.retake_records 
               WHERE enrollment_id = @EnrollmentId 
               AND deleted_at IS NULL
               AND status IN ('PENDING', 'APPROVED'))
    BEGIN
        SELECT 'EXISTS' as result, NULL as reason, NULL as current_value;
        RETURN;
    END
    
    -- Calculate absence rate
    SELECT @AbsenceRate = CAST(ROUND((COUNT(CASE WHEN a.status = 'Absent' THEN 1 END) * 100.0 / 
                                     NULLIF(COUNT(a.attendance_id), 0)), 2) AS DECIMAL(5,2))
    FROM dbo.attendances a
    WHERE a.enrollment_id = @EnrollmentId
        AND a.deleted_at IS NULL;
    
    -- Get total score
    SELECT @TotalScore = g.total_score
    FROM dbo.grades g
    WHERE g.enrollment_id = @EnrollmentId
        AND g.total_score IS NOT NULL;
    
    -- Determine reason
    IF @AbsenceRate > @AttendanceThreshold AND (@TotalScore IS NULL OR @TotalScore < @GradeThreshold)
    BEGIN
        SET @Reason = 'BOTH';
        SET @CurrentValue = @AbsenceRate; -- Use absence rate as primary value
    END
    ELSE IF @AbsenceRate > @AttendanceThreshold
    BEGIN
        SET @Reason = 'ATTENDANCE';
        SET @CurrentValue = @AbsenceRate;
    END
    ELSE IF @TotalScore IS NOT NULL AND @TotalScore < @GradeThreshold
    BEGIN
        SET @Reason = 'GRADE';
        SET @CurrentValue = @TotalScore;
    END
    
    -- Return result
    IF @Reason IS NOT NULL
    BEGIN
        SELECT 'REQUIRED' as result, @Reason as reason, @CurrentValue as current_value,
               @StudentId as student_id, @ClassId as class_id, @SubjectId as subject_id,
               CASE 
                   WHEN @Reason = 'ATTENDANCE' THEN @AttendanceThreshold
                   WHEN @Reason = 'GRADE' THEN @GradeThreshold
                   ELSE @AttendanceThreshold
               END as threshold_value;
    END
    ELSE
    BEGIN
        SELECT 'NOT_REQUIRED' as result, NULL as reason, NULL as current_value;
    END
END
GO

PRINT '========================================';
PRINT '[OK] Academic Operations SPs completed';
PRINT '========================================';
GO
