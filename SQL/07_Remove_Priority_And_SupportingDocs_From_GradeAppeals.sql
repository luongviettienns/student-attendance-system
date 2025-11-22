-- ===========================================
-- 07_Remove_Priority_And_SupportingDocs_From_GradeAppeals.sql
-- ===========================================
-- Description: Remove priority and supporting_docs columns from grade_appeals table
-- ===========================================

USE EducationManagement;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

PRINT '========================================';
PRINT 'Starting: 07_Remove_Priority_And_SupportingDocs_From_GradeAppeals.sql';
PRINT 'Remove priority and supporting_docs from grade_appeals';
PRINT '========================================';
GO

-- Remove CHECK constraint for priority if it exists
IF EXISTS (SELECT * FROM sys.check_constraints WHERE parent_object_id = OBJECT_ID('dbo.grade_appeals') AND name = 'CHK_Appeal_Priority')
BEGIN
    ALTER TABLE dbo.grade_appeals
    DROP CONSTRAINT CHK_Appeal_Priority;
    PRINT '✅ Dropped CHECK constraint CHK_Appeal_Priority';
END
ELSE
BEGIN
    PRINT 'CHECK constraint CHK_Appeal_Priority does not exist';
END
GO

-- Remove DEFAULT constraint for priority if it exists
DECLARE @PriorityDefaultConstraintName NVARCHAR(200);
SELECT @PriorityDefaultConstraintName = name
FROM sys.default_constraints
WHERE parent_object_id = OBJECT_ID('dbo.grade_appeals')
    AND parent_column_id = (SELECT column_id FROM sys.columns WHERE object_id = OBJECT_ID('dbo.grade_appeals') AND name = 'priority');

IF @PriorityDefaultConstraintName IS NOT NULL
BEGIN
    DECLARE @DropPriorityDefaultSQL NVARCHAR(MAX) = 'ALTER TABLE dbo.grade_appeals DROP CONSTRAINT ' + QUOTENAME(@PriorityDefaultConstraintName);
    EXEC sp_executesql @DropPriorityDefaultSQL;
    PRINT '✅ Dropped DEFAULT constraint ' + @PriorityDefaultConstraintName + ' for priority column';
END
ELSE
BEGIN
    PRINT 'No DEFAULT constraint found for priority column';
END
GO

-- Remove priority column
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.grade_appeals') AND name = 'priority')
BEGIN
    ALTER TABLE dbo.grade_appeals
    DROP COLUMN priority;
    PRINT '✅ Dropped column priority from dbo.grade_appeals';
END
ELSE
BEGIN
    PRINT 'Column priority does not exist in dbo.grade_appeals';
END
GO

-- Remove supporting_docs column
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.grade_appeals') AND name = 'supporting_docs')
BEGIN
    ALTER TABLE dbo.grade_appeals
    DROP COLUMN supporting_docs;
    PRINT '✅ Dropped column supporting_docs from dbo.grade_appeals';
END
ELSE
BEGIN
    PRINT 'Column supporting_docs does not exist in dbo.grade_appeals';
END
GO

PRINT '========================================';
PRINT 'Completed: 07_Remove_Priority_And_SupportingDocs_From_GradeAppeals.sql';
PRINT '========================================';
GO

