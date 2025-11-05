-- ===========================================
-- 02i_SP_Grades.sql
-- ===========================================
-- Description: Grades Management SPs, GPAs Management SPs
-- Generated from: SQL/02_StoredProcedures.sql
-- ===========================================

USE EducationManagement;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

PRINT '========================================';
PRINT 'Starting: 02i_SP_Grades.sql';
PRINT '========================================';
GO

-- ===========================================
-- 12. GRADES MANAGEMENT
-- ===========================================

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

IF OBJECT_ID('sp_GetGradesByClass', 'P') IS NOT NULL DROP PROCEDURE sp_GetGradesByClass;
GO
CREATE PROCEDURE sp_GetGradesByClass
    @ClassId VARCHAR(50)
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
        s.full_name as student_name
    FROM dbo.grades g
    INNER JOIN dbo.enrollments e ON g.enrollment_id = e.enrollment_id
    INNER JOIN dbo.students s ON e.student_id = s.student_id
    WHERE e.class_id = @ClassId
    ORDER BY s.student_code;
END
GO

IF OBJECT_ID('sp_CreateGrade', 'P') IS NOT NULL DROP PROCEDURE sp_CreateGrade;
GO
CREATE PROCEDURE sp_CreateGrade
    @GradeId VARCHAR(50),
    @EnrollmentId VARCHAR(50),
    @MidtermScore DECIMAL(4,2) = NULL,
    @FinalScore DECIMAL(4,2) = NULL,
    @CreatedBy VARCHAR(50) = 'system'
AS
BEGIN
    INSERT INTO dbo.grades (grade_id, enrollment_id, midterm_score, final_score,
                            created_at, created_by)
    VALUES (@GradeId, @EnrollmentId, @MidtermScore, @FinalScore, GETDATE(), @CreatedBy);
END
GO

IF OBJECT_ID('sp_UpdateGrade', 'P') IS NOT NULL DROP PROCEDURE sp_UpdateGrade;
GO
CREATE PROCEDURE sp_UpdateGrade
    @GradeId VARCHAR(50),
    @MidtermScore DECIMAL(4,2) = NULL,
    @FinalScore DECIMAL(4,2) = NULL,
    @UpdatedBy VARCHAR(50) = 'system'
AS
BEGIN
    UPDATE dbo.grades
    SET midterm_score = @MidtermScore, final_score = @FinalScore,
        updated_at = GETDATE(), updated_by = @UpdatedBy
    WHERE grade_id = @GradeId;
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

-- NEW: Get grades by student + school year + semester
IF OBJECT_ID('sp_GetGradesByStudentSchoolYear', 'P') IS NOT NULL DROP PROCEDURE sp_GetGradesByStudentSchoolYear;
GO
CREATE PROCEDURE sp_GetGradesByStudentSchoolYear
    @StudentId VARCHAR(50),
    @SchoolYearId VARCHAR(50) = NULL,
    @Semester VARCHAR(20) = NULL
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
        AND (@Semester IS NULL OR c.semester = @Semester)
        AND e.deleted_at IS NULL
    ORDER BY sy.start_date DESC, c.semester, sub.subject_name;
END
GO

PRINT '[OK] Grades Management SPs created';
GO

-- ===========================================
-- 14. GPAS MANAGEMENT
-- ===========================================

IF OBJECT_ID('sp_GetGPAsByStudent', 'P') IS NOT NULL DROP PROCEDURE sp_GetGPAsByStudent;
GO
CREATE PROCEDURE sp_GetGPAsByStudent
    @StudentId VARCHAR(50),
    @AcademicYearId VARCHAR(50) = NULL
AS
BEGIN
    SELECT g.*, s.student_code, s.full_name as student_name,
           ay.year_name as academic_year_name
    FROM dbo.gpas g
    INNER JOIN dbo.students s ON g.student_id = s.student_id
    INNER JOIN dbo.academic_years ay ON g.academic_year_id = ay.academic_year_id
    WHERE g.student_id = @StudentId
        AND (@AcademicYearId IS NULL OR g.academic_year_id = @AcademicYearId)
        AND g.deleted_at IS NULL
    ORDER BY ay.start_year DESC, g.semester;
END
GO

IF OBJECT_ID('sp_CalculateGPA', 'P') IS NOT NULL DROP PROCEDURE sp_CalculateGPA;
GO
CREATE PROCEDURE sp_CalculateGPA
    @StudentId VARCHAR(50),
    @AcademicYearId VARCHAR(50),
    @Semester INT = NULL, -- NULL = cáº£ nÄƒm, 1/2/3 = há»c ká»³ cá»¥ thá»ƒ
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
    
    -- TĂ­nh Ä‘iá»ƒm trung bĂ¬nh vĂ  tá»•ng tĂ­n chá»‰
    SELECT 
        @Gpa10 = ROUND(SUM(g.total_score * sub.credits) / NULLIF(SUM(sub.credits), 0), 2),
        @TotalCredits = SUM(sub.credits),
        @AccumulatedCredits = SUM(CASE WHEN g.total_score >= 4.0 THEN sub.credits ELSE 0 END)
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
                    WHEN g.total_score >= 4.0 THEN 1.0
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
        WHEN @Gpa10 >= 8.5 THEN N'Xuáº¥t sáº¯c'
        WHEN @Gpa10 >= 7.0 THEN N'Giá»i'
        WHEN @Gpa10 >= 5.5 THEN N'KhĂ¡'
        WHEN @Gpa10 >= 4.0 THEN N'Trung bĂ¬nh'
        ELSE N'Yáº¿u'
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

-- NEW: Calculate GPA by School Year
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
        @AccumulatedCredits = SUM(CASE WHEN g.total_score >= 4.0 THEN sub.credits ELSE 0 END)
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
        WHEN @Gpa10 >= 9.0 THEN N'Xuáº¥t sáº¯c'
        WHEN @Gpa10 >= 8.0 THEN N'Giá»i'
        WHEN @Gpa10 >= 7.0 THEN N'KhĂ¡'
        WHEN @Gpa10 >= 5.5 THEN N'Trung bĂ¬nh'
        ELSE N'Yáº¿u'
    END;
    
    -- Convert semester string to int (1, 2, or NULL)
    DECLARE @SemesterInt INT = NULL;
    IF @Semester IS NOT NULL AND @Semester IN ('1', '2')
    BEGIN
        SET @SemesterInt = CAST(@Semester AS INT);
    END
    
    -- Insert or update GPA
    IF EXISTS (SELECT 1 FROM dbo.gpas 
               WHERE student_id = @StudentId 
                 AND school_year_id = @SchoolYearId
                 AND ((@SemesterInt IS NULL AND semester IS NULL) OR semester = @SemesterInt))
    BEGIN
        UPDATE dbo.gpas
        SET gpa10 = @Gpa10,
            gpa4 = @Gpa4,
            total_credits = @TotalCredits,
            accumulated_credits = @AccumulatedCredits,
            rank_text = @RankText,
            updated_at = GETDATE(),
            updated_by = @CreatedBy
        WHERE student_id = @StudentId 
          AND school_year_id = @SchoolYearId
          AND ((@SemesterInt IS NULL AND semester IS NULL) OR semester = @SemesterInt);
    END
    ELSE
    BEGIN
        INSERT INTO dbo.gpas (gpa_id, student_id, academic_year_id, school_year_id, semester,
                              gpa10, gpa4, total_credits, accumulated_credits, rank_text,
                              is_active, created_at, created_by)
        VALUES (@GpaId, @StudentId, @AcademicYearId, @SchoolYearId, @SemesterInt,
                @Gpa10, @Gpa4, @TotalCredits, @AccumulatedCredits, @RankText,
                1, GETDATE(), @CreatedBy);
    END
END
GO

PRINT '[OK] GPAs Management SPs created';
GO

-- ===========================================
-- 12. GRADES MANAGEMENT
-- ===========================================

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

IF OBJECT_ID('sp_GetGradesByClass', 'P') IS NOT NULL DROP PROCEDURE sp_GetGradesByClass;
GO
CREATE PROCEDURE sp_GetGradesByClass
    @ClassId VARCHAR(50)
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
        s.full_name as student_name
    FROM dbo.grades g
    INNER JOIN dbo.enrollments e ON g.enrollment_id = e.enrollment_id
    INNER JOIN dbo.students s ON e.student_id = s.student_id
    WHERE e.class_id = @ClassId
    ORDER BY s.student_code;
END
GO

IF OBJECT_ID('sp_CreateGrade', 'P') IS NOT NULL DROP PROCEDURE sp_CreateGrade;
GO
CREATE PROCEDURE sp_CreateGrade
    @GradeId VARCHAR(50),
    @EnrollmentId VARCHAR(50),
    @MidtermScore DECIMAL(4,2) = NULL,
    @FinalScore DECIMAL(4,2) = NULL,
    @CreatedBy VARCHAR(50) = 'system'
AS
BEGIN
    INSERT INTO dbo.grades (grade_id, enrollment_id, midterm_score, final_score,
                            created_at, created_by)
    VALUES (@GradeId, @EnrollmentId, @MidtermScore, @FinalScore, GETDATE(), @CreatedBy);
END
GO

IF OBJECT_ID('sp_UpdateGrade', 'P') IS NOT NULL DROP PROCEDURE sp_UpdateGrade;
GO
CREATE PROCEDURE sp_UpdateGrade
    @GradeId VARCHAR(50),
    @MidtermScore DECIMAL(4,2) = NULL,
    @FinalScore DECIMAL(4,2) = NULL,
    @UpdatedBy VARCHAR(50) = 'system'
AS
BEGIN
    UPDATE dbo.grades
    SET midterm_score = @MidtermScore, final_score = @FinalScore,
        updated_at = GETDATE(), updated_by = @UpdatedBy
    WHERE grade_id = @GradeId;
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

-- NEW: Get grades by student + school year + semester
IF OBJECT_ID('sp_GetGradesByStudentSchoolYear', 'P') IS NOT NULL DROP PROCEDURE sp_GetGradesByStudentSchoolYear;
GO
CREATE PROCEDURE sp_GetGradesByStudentSchoolYear
    @StudentId VARCHAR(50),
    @SchoolYearId VARCHAR(50) = NULL,
    @Semester VARCHAR(20) = NULL
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
        AND (@Semester IS NULL OR c.semester = @Semester)
        AND e.deleted_at IS NULL
    ORDER BY sy.start_date DESC, c.semester, sub.subject_name;
END
GO

PRINT '[OK] Grades Management SPs created';
GO

-- ===========================================
-- 14. GPAS MANAGEMENT
-- ===========================================

IF OBJECT_ID('sp_GetGPAsByStudent', 'P') IS NOT NULL DROP PROCEDURE sp_GetGPAsByStudent;
GO
CREATE PROCEDURE sp_GetGPAsByStudent
    @StudentId VARCHAR(50),
    @AcademicYearId VARCHAR(50) = NULL
AS
BEGIN
    SELECT g.*, s.student_code, s.full_name as student_name,
           ay.year_name as academic_year_name
    FROM dbo.gpas g
    INNER JOIN dbo.students s ON g.student_id = s.student_id
    INNER JOIN dbo.academic_years ay ON g.academic_year_id = ay.academic_year_id
    WHERE g.student_id = @StudentId
        AND (@AcademicYearId IS NULL OR g.academic_year_id = @AcademicYearId)
        AND g.deleted_at IS NULL
    ORDER BY ay.start_year DESC, g.semester;
END
GO

IF OBJECT_ID('sp_CalculateGPA', 'P') IS NOT NULL DROP PROCEDURE sp_CalculateGPA;
GO
CREATE PROCEDURE sp_CalculateGPA
    @StudentId VARCHAR(50),
    @AcademicYearId VARCHAR(50),
    @Semester INT = NULL, -- NULL = cáº£ nÄƒm, 1/2/3 = há»c ká»³ cá»¥ thá»ƒ
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
    
    -- TĂ­nh Ä‘iá»ƒm trung bĂ¬nh vĂ  tá»•ng tĂ­n chá»‰
    SELECT 
        @Gpa10 = ROUND(SUM(g.total_score * sub.credits) / NULLIF(SUM(sub.credits), 0), 2),
        @TotalCredits = SUM(sub.credits),
        @AccumulatedCredits = SUM(CASE WHEN g.total_score >= 4.0 THEN sub.credits ELSE 0 END)
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
                    WHEN g.total_score >= 4.0 THEN 1.0
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
        WHEN @Gpa10 >= 8.5 THEN N'Xuáº¥t sáº¯c'
        WHEN @Gpa10 >= 7.0 THEN N'Giá»i'
        WHEN @Gpa10 >= 5.5 THEN N'KhĂ¡'
        WHEN @Gpa10 >= 4.0 THEN N'Trung bĂ¬nh'
        ELSE N'Yáº¿u'
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

-- NEW: Calculate GPA by School Year
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
        @AccumulatedCredits = SUM(CASE WHEN g.total_score >= 4.0 THEN sub.credits ELSE 0 END)
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
        WHEN @Gpa10 >= 9.0 THEN N'Xuáº¥t sáº¯c'
        WHEN @Gpa10 >= 8.0 THEN N'Giá»i'
        WHEN @Gpa10 >= 7.0 THEN N'KhĂ¡'
        WHEN @Gpa10 >= 5.5 THEN N'Trung bĂ¬nh'
        ELSE N'Yáº¿u'
    END;
    
    -- Convert semester string to int (1, 2, or NULL)
    DECLARE @SemesterInt INT = NULL;
    IF @Semester IS NOT NULL AND @Semester IN ('1', '2')
    BEGIN
        SET @SemesterInt = CAST(@Semester AS INT);
    END
    
    -- Insert or update GPA
    IF EXISTS (SELECT 1 FROM dbo.gpas 
               WHERE student_id = @StudentId 
                 AND school_year_id = @SchoolYearId
                 AND ((@SemesterInt IS NULL AND semester IS NULL) OR semester = @SemesterInt))
    BEGIN
        UPDATE dbo.gpas
        SET gpa10 = @Gpa10,
            gpa4 = @Gpa4,
            total_credits = @TotalCredits,
            accumulated_credits = @AccumulatedCredits,
            rank_text = @RankText,
            updated_at = GETDATE(),
            updated_by = @CreatedBy
        WHERE student_id = @StudentId 
          AND school_year_id = @SchoolYearId
          AND ((@SemesterInt IS NULL AND semester IS NULL) OR semester = @SemesterInt);
    END
    ELSE
    BEGIN
        INSERT INTO dbo.gpas (gpa_id, student_id, academic_year_id, school_year_id, semester,
                              gpa10, gpa4, total_credits, accumulated_credits, rank_text,
                              is_active, created_at, created_by)
        VALUES (@GpaId, @StudentId, @AcademicYearId, @SchoolYearId, @SemesterInt,
                @Gpa10, @Gpa4, @TotalCredits, @AccumulatedCredits, @RankText,
                1, GETDATE(), @CreatedBy);
    END
END
GO

PRINT '[OK] GPAs Management SPs created';
GO

PRINT '[OK] Grades Management SPs, GPAs Management SPs completed';
GO
