-- ===========================================
-- Script Test Stored Procedure Grade Formula
-- ===========================================

USE EducationManagement;
GO

PRINT '========================================';
PRINT 'Bắt đầu kiểm tra...';
PRINT '========================================';
GO

-- 1. Kiểm tra bảng có tồn tại không
PRINT '';
PRINT '1. Kiểm tra bảng grade_formula_config:';
IF OBJECT_ID('dbo.grade_formula_config', 'U') IS NOT NULL
BEGIN
    PRINT '   ✅ Bảng grade_formula_config TỒN TẠI';
    
    -- Đếm số bản ghi
    DECLARE @Count INT;
    SELECT @Count = COUNT(*) FROM dbo.grade_formula_config WHERE deleted_at IS NULL;
    PRINT '   📊 Số bản ghi (chưa xóa): ' + CAST(@Count AS VARCHAR(10));
END
ELSE
BEGIN
    PRINT '   ❌ Bảng grade_formula_config KHÔNG TỒN TẠI!';
    PRINT '   ⚠️  Cần chạy script: SQL/01_CreateTables.sql';
END
GO

-- 2. Kiểm tra stored procedure có tồn tại không
PRINT '';
PRINT '2. Kiểm tra stored procedure sp_GetAllGradeFormulaConfigs:';
IF OBJECT_ID('sp_GetAllGradeFormulaConfigs', 'P') IS NOT NULL
BEGIN
    PRINT '   ✅ Stored Procedure sp_GetAllGradeFormulaConfigs TỒN TẠI';
    
    -- Test gọi stored procedure
    PRINT '';
    PRINT '3. Test gọi stored procedure với tham số mặc định:';
    BEGIN TRY
        DECLARE @Page INT = 1;
        DECLARE @PageSize INT = 20;
        
        -- Gọi stored procedure
        EXEC sp_GetAllGradeFormulaConfigs 
            @Page = @Page,
            @PageSize = @PageSize,
            @SubjectId = NULL,
            @ClassId = NULL,
            @SchoolYearId = NULL,
            @IsDefault = NULL;
        
        PRINT '   ✅ Stored Procedure chạy THÀNH CÔNG!';
    END TRY
    BEGIN CATCH
        PRINT '   ❌ LỖI khi gọi stored procedure:';
        PRINT '   Error Message: ' + ERROR_MESSAGE();
        PRINT '   Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
        PRINT '   Error Line: ' + CAST(ERROR_LINE() AS VARCHAR(10));
    END CATCH
END
ELSE
BEGIN
    PRINT '   ❌ Stored Procedure sp_GetAllGradeFormulaConfigs KHÔNG TỒN TẠI!';
    PRINT '   ⚠️  Cần chạy script: SQL/Check_And_Create_GradeFormula_SP.sql';
    PRINT '   ⚠️  Hoặc: SQL/02_SP_Grade_Appeals_And_Formula.sql';
END
GO

PRINT '';
PRINT '========================================';
PRINT 'Hoàn thành kiểm tra!';
PRINT '========================================';
GO

