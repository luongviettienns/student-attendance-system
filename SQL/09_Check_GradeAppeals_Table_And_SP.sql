-- ===========================================
-- 09_Check_GradeAppeals_Table_And_SP.sql
-- ===========================================
-- Description: Check grade_appeals table structure and stored procedure
-- ===========================================

USE EducationManagement;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

PRINT '========================================';
PRINT 'Starting: 09_Check_GradeAppeals_Table_And_SP.sql';
PRINT 'Check grade_appeals table and stored procedure';
PRINT '========================================';
GO

-- Check table structure
PRINT '';
PRINT '=== Checking grade_appeals table structure ===';
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo' 
    AND TABLE_NAME = 'grade_appeals'
ORDER BY ORDINAL_POSITION;
GO

-- Check for triggers
PRINT '';
PRINT '=== Checking for triggers on grade_appeals ===';
SELECT 
    t.name AS trigger_name,
    t.is_disabled,
    OBJECT_DEFINITION(t.object_id) AS trigger_definition
FROM sys.triggers t
INNER JOIN sys.tables tb ON t.parent_id = tb.object_id
WHERE tb.name = 'grade_appeals';
GO

-- Check stored procedure definition
PRINT '';
PRINT '=== Checking sp_CreateGradeAppeal definition ===';
IF OBJECT_ID('sp_CreateGradeAppeal', 'P') IS NOT NULL
BEGIN
    SELECT OBJECT_DEFINITION(OBJECT_ID('sp_CreateGradeAppeal')) AS procedure_definition;
END
ELSE
BEGIN
    PRINT '❌ sp_CreateGradeAppeal does not exist!';
END
GO

-- Check for constraints
PRINT '';
PRINT '=== Checking constraints on grade_appeals ===';
SELECT 
    c.name AS constraint_name,
    c.type_desc AS constraint_type,
    OBJECT_DEFINITION(c.object_id) AS constraint_definition
FROM sys.objects c
INNER JOIN sys.tables t ON c.parent_object_id = t.object_id
WHERE t.name = 'grade_appeals'
    AND c.type IN ('C', 'D', 'F', 'PK', 'UQ');
GO

-- Try to test INSERT (will rollback)
PRINT '';
PRINT '=== Testing INSERT (will rollback) ===';
BEGIN TRANSACTION;
BEGIN TRY
    INSERT INTO dbo.grade_appeals (
        appeal_id, grade_id, enrollment_id, student_id, class_id,
        appeal_reason, current_score, expected_score, component_type,
        status, created_at, created_by
    )
    VALUES (
        'TEST_APPEAL_001', 'GRD_FT_001', 'ENR_FT_001', 'STU_K24_001', 'CLS_SE101_2024',
        'Test appeal reason', 8.5, 9.0, 'MIDTERM',
        'PENDING', GETDATE(), 'TEST_USER'
    );
    
    PRINT '✅ Test INSERT succeeded';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorLine INT = ERROR_LINE();
    PRINT '❌ Test INSERT failed:';
    PRINT '   Error: ' + @ErrorMsg;
    PRINT '   Line: ' + CAST(@ErrorLine AS NVARCHAR(10));
    ROLLBACK TRANSACTION;
END CATCH
GO

PRINT '';
PRINT '========================================';
PRINT 'Completed: 09_Check_GradeAppeals_Table_And_SP.sql';
PRINT '========================================';
GO

