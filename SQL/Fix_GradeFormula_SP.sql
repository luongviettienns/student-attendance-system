-- ===========================================
-- Script FIX: Tạo Stored Procedure cho Grade Formula Config
-- Chạy script này trong SQL Server Management Studio
-- ===========================================

USE EducationManagement;
GO

PRINT '========================================';
PRINT 'Bắt đầu kiểm tra và tạo Stored Procedure...';
PRINT '========================================';
GO

-- Xóa stored procedure cũ nếu có (để tạo lại)
IF OBJECT_ID('sp_GetAllGradeFormulaConfigs', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE sp_GetAllGradeFormulaConfigs;
    PRINT '✅ Đã xóa stored procedure cũ';
END
GO

-- Tạo stored procedure mới
CREATE PROCEDURE sp_GetAllGradeFormulaConfigs
    @Page INT = 1,
    @PageSize INT = 20,
    @SubjectId VARCHAR(50) = NULL,
    @ClassId VARCHAR(50) = NULL,
    @SchoolYearId VARCHAR(50) = NULL,
    @IsDefault BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Offset INT = (@Page - 1) * @PageSize;
    
    -- Get total count (Result Set 1)
    SELECT COUNT(*) as total_count
    FROM dbo.grade_formula_config c
    WHERE c.deleted_at IS NULL
        AND (@SubjectId IS NULL OR c.subject_id = @SubjectId)
        AND (@ClassId IS NULL OR c.class_id = @ClassId)
        AND (@SchoolYearId IS NULL OR c.school_year_id = @SchoolYearId)
        AND (@IsDefault IS NULL OR c.is_default = @IsDefault);
    
    -- Get paginated results (Result Set 2)
    SELECT 
        c.config_id,
        c.subject_id,
        c.class_id,
        c.school_year_id,
        c.midterm_weight,
        c.final_weight,
        c.assignment_weight,
        c.quiz_weight,
        c.project_weight,
        c.custom_formula,
        c.rounding_method,
        c.decimal_places,
        c.description,
        c.is_default,
        c.created_at,
        c.created_by,
        c.updated_at,
        c.updated_by,
        -- Subject info
        sub.subject_code,
        sub.subject_name,
        -- Class info
        cl.class_code,
        cl.class_name,
        -- School year info
        sy.year_code,
        sy.year_name
    FROM dbo.grade_formula_config c
    LEFT JOIN dbo.subjects sub ON c.subject_id = sub.subject_id
    LEFT JOIN dbo.classes cl ON c.class_id = cl.class_id
    LEFT JOIN dbo.school_years sy ON c.school_year_id = sy.school_year_id
    WHERE c.deleted_at IS NULL
        AND (@SubjectId IS NULL OR c.subject_id = @SubjectId)
        AND (@ClassId IS NULL OR c.class_id = @ClassId)
        AND (@SchoolYearId IS NULL OR c.school_year_id = @SchoolYearId)
        AND (@IsDefault IS NULL OR c.is_default = @IsDefault)
    ORDER BY c.is_default DESC, c.created_at DESC
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO

PRINT '✅ Đã tạo stored procedure sp_GetAllGradeFormulaConfigs thành công!';
GO

-- Test stored procedure
PRINT '';
PRINT 'Đang test stored procedure...';
EXEC sp_GetAllGradeFormulaConfigs @Page = 1, @PageSize = 20;
GO

PRINT '';
PRINT '========================================';
PRINT 'Hoàn thành! Stored procedure đã sẵn sàng.';
PRINT '========================================';
GO

