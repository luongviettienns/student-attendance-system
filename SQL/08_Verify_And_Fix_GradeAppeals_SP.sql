-- ===========================================
-- 08_Verify_And_Fix_GradeAppeals_SP.sql
-- ===========================================
-- Description: Verify and fix sp_CreateGradeAppeal to ensure it doesn't reference deleted columns
-- ===========================================

USE EducationManagement;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

PRINT '========================================';
PRINT 'Starting: 08_Verify_And_Fix_GradeAppeals_SP.sql';
PRINT 'Verify and fix grade appeals stored procedures';
PRINT '========================================';
GO

-- Drop and recreate sp_CreateGradeAppeal to ensure it's correct
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

-- Verify the procedure was created correctly
IF OBJECT_ID('sp_CreateGradeAppeal', 'P') IS NOT NULL
BEGIN
    PRINT '✅ Verification: sp_CreateGradeAppeal exists';
END
ELSE
BEGIN
    PRINT '❌ ERROR: sp_CreateGradeAppeal was not created!';
END
GO

PRINT '========================================';
PRINT 'Completed: 08_Verify_And_Fix_GradeAppeals_SP.sql';
PRINT '========================================';
GO

