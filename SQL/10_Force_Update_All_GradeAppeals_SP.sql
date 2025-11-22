-- ===========================================
-- 10_Force_Update_All_GradeAppeals_SP.sql
-- ===========================================
-- Description: Force update ALL grade appeals stored procedures to ensure they're correct
-- ===========================================

USE EducationManagement;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

PRINT '========================================';
PRINT 'Starting: 10_Force_Update_All_GradeAppeals_SP.sql';
PRINT 'Force update all grade appeals stored procedures';
PRINT '========================================';
GO

-- 1. DROP AND RECREATE sp_CreateGradeAppeal
PRINT '';
PRINT '=== 1. Updating sp_CreateGradeAppeal ===';
IF OBJECT_ID('sp_CreateGradeAppeal', 'P') IS NOT NULL 
BEGIN
    DROP PROCEDURE sp_CreateGradeAppeal;
    PRINT '✅ Dropped existing sp_CreateGradeAppeal';
END
GO

CREATE PROCEDURE sp_CreateGradeAppeal
    @AppealId VARCHAR(50),
    @GradeId VARCHAR(50),
    @EnrollmentId VARCHAR(50),
    @StudentId VARCHAR(50),
    @ClassId VARCHAR(50),
    @AppealReason NVARCHAR(1000),
    @CurrentScore DECIMAL(4,2) = NULL,
    @ExpectedScore DECIMAL(4,2) = NULL,
    @ComponentType NVARCHAR(20) = NULL, -- MIDTERM, FINAL, ATTENDANCE, ASSIGNMENT
    @CreatedBy VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Validate grade exists
        IF NOT EXISTS (SELECT 1 FROM dbo.grades WHERE grade_id = @GradeId)
        BEGIN
            THROW 50001, 'Không tìm thấy điểm số', 1;
        END
        
        -- Validate enrollment belongs to student
        IF NOT EXISTS (SELECT 1 FROM dbo.enrollments WHERE enrollment_id = @EnrollmentId AND student_id = @StudentId AND deleted_at IS NULL)
        BEGIN
            THROW 50002, 'Đăng ký học phần không thuộc về sinh viên này', 1;
        END
        
        -- Validate component type
        IF @ComponentType IS NOT NULL AND @ComponentType NOT IN ('MIDTERM', 'FINAL', 'ATTENDANCE', 'ASSIGNMENT')
        BEGIN
            THROW 50003, 'Loại điểm thành phần không hợp lệ. Phải là: MIDTERM, FINAL, ATTENDANCE, hoặc ASSIGNMENT', 1;
        END
        
        -- ✅ INSERT without priority and supporting_docs
        INSERT INTO dbo.grade_appeals (
            appeal_id, grade_id, enrollment_id, student_id, class_id,
            appeal_reason, current_score, expected_score, component_type,
            status, created_at, created_by
        )
        VALUES (
            @AppealId, @GradeId, @EnrollmentId, @StudentId, @ClassId,
            @AppealReason, @CurrentScore, @ExpectedScore, @ComponentType,
            'PENDING', GETDATE(), @CreatedBy
        );
        
        SELECT @AppealId as appeal_id;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        PRINT '❌ Error in sp_CreateGradeAppeal: ' + @ErrorMessage;
        THROW;
    END CATCH
END
GO

PRINT '✅ Created sp_CreateGradeAppeal';
GO

-- 2. DROP AND RECREATE sp_GetGradeAppealById (ensure it doesn't SELECT deleted_by)
PRINT '';
PRINT '=== 2. Updating sp_GetGradeAppealById ===';
IF OBJECT_ID('sp_GetGradeAppealById', 'P') IS NOT NULL 
BEGIN
    DROP PROCEDURE sp_GetGradeAppealById;
    PRINT '✅ Dropped existing sp_GetGradeAppealById';
END
GO

CREATE PROCEDURE sp_GetGradeAppealById
    @AppealId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        a.appeal_id,
        a.grade_id,
        a.enrollment_id,
        a.student_id,
        a.class_id,
        a.appeal_reason,
        a.current_score,
        a.expected_score,
        a.component_type,
        a.status,
        a.lecturer_response,
        a.lecturer_id,
        a.lecturer_decision,
        a.advisor_id,
        a.advisor_response,
        a.advisor_decision,
        a.final_score,
        a.resolution_notes,
        a.created_at,
        a.created_by,
        a.updated_at,
        a.updated_by,
        a.resolved_at,
        a.resolved_by,
        -- Student info
        s.student_code,
        s.full_name as student_name,
        s.email as student_email,
        s.user_id as student_user_id,
        -- Class info
        c.class_code,
        c.class_name,
        sub.subject_name,
        sub.subject_code,
        -- Grade info
        g.midterm_score,
        g.final_score as grade_final_score,
        g.total_score,
        g.letter_grade,
        -- Lecturer info
        l.lecturer_code,
        l.full_name as lecturer_name,
        l.email as lecturer_email,
        l.user_id as lecturer_user_id,
        -- Advisor info
        adv.lecturer_code as advisor_code,
        adv.full_name as advisor_name,
        adv.email as advisor_email,
        adv.user_id as advisor_user_id
    FROM dbo.grade_appeals a
    INNER JOIN dbo.students s ON a.student_id = s.student_id
    INNER JOIN dbo.classes c ON a.class_id = c.class_id
    INNER JOIN dbo.subjects sub ON c.subject_id = sub.subject_id
    INNER JOIN dbo.grades g ON a.grade_id = g.grade_id
    LEFT JOIN dbo.lecturers l ON a.lecturer_id = l.lecturer_id
    LEFT JOIN dbo.lecturers adv ON a.advisor_id = adv.lecturer_id
    WHERE a.appeal_id = @AppealId AND a.deleted_at IS NULL;
END
GO

PRINT '✅ Created sp_GetGradeAppealById';
GO

-- Verify procedures exist
PRINT '';
PRINT '=== Verification ===';
IF OBJECT_ID('sp_CreateGradeAppeal', 'P') IS NOT NULL
    PRINT '✅ sp_CreateGradeAppeal exists';
ELSE
    PRINT '❌ ERROR: sp_CreateGradeAppeal does not exist!';

IF OBJECT_ID('sp_GetGradeAppealById', 'P') IS NOT NULL
    PRINT '✅ sp_GetGradeAppealById exists';
ELSE
    PRINT '❌ ERROR: sp_GetGradeAppealById does not exist!';
GO

PRINT '';
PRINT '========================================';
PRINT 'Completed: 10_Force_Update_All_GradeAppeals_SP.sql';
PRINT '========================================';
GO

