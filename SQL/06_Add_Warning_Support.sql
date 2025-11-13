-- ===========================================
-- 06_Add_Warning_Support.sql
-- ===========================================
-- Description: Add support for auto warning system
-- Date: $(date)
-- ===========================================

PRINT 'Starting: 06_Add_Warning_Support.sql';
PRINT 'Adding warning support fields and indexes';
GO

-- ===========================================
-- 1. ADD last_warning_sent FIELD TO students TABLE
-- ===========================================
IF NOT EXISTS (
    SELECT 1 
    FROM sys.columns 
    WHERE object_id = OBJECT_ID('dbo.students') 
    AND name = 'last_warning_sent'
)
BEGIN
    ALTER TABLE dbo.students 
    ADD last_warning_sent DATETIME NULL;
    
    PRINT '✅ Added last_warning_sent field to students table';
END
ELSE
BEGIN
    PRINT '⚠️ Field last_warning_sent already exists in students table';
END
GO

-- ===========================================
-- 2. CREATE INDEX FOR PERFORMANCE
-- ===========================================
IF NOT EXISTS (
    SELECT 1 
    FROM sys.indexes 
    WHERE name = 'IX_Students_LastWarningSent' 
    AND object_id = OBJECT_ID('dbo.students')
)
BEGIN
    CREATE INDEX IX_Students_LastWarningSent 
    ON dbo.students(last_warning_sent);
    
    PRINT '✅ Created index IX_Students_LastWarningSent';
END
ELSE
BEGIN
    PRINT '⚠️ Index IX_Students_LastWarningSent already exists';
END
GO

-- ===========================================
-- 3. ADD CONFIGURATION TO appsettings.json (Manual step)
-- ===========================================
-- Note: Add these to appsettings.json manually:
-- {
--   "Advisor": {
--     "WarningThresholds": {
--       "Attendance": "20.0",
--       "Gpa": "2.0"
--     },
--     "WarningSettings": {
--       "MinDaysBetweenWarnings": "7"
--     }
--   }
-- }

PRINT '[OK] Warning support setup completed';
PRINT 'Note: Remember to add configuration to appsettings.json';
GO

