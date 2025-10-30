-- =============================================
-- 🎓 EDUCATION MANAGEMENT SYSTEM
-- 📦 RUN ALL SETUP SCRIPT
-- =============================================
-- Chạy file này để setup TOÀN BỘ database
-- Thời gian: ~1-2 phút
-- =============================================

USE master;
GO

SET NOCOUNT ON;
GO

PRINT '';
PRINT '═══════════════════════════════════════════════════════════════';
PRINT '    🎓 EDUCATION MANAGEMENT SYSTEM - DATABASE SETUP';
PRINT '═══════════════════════════════════════════════════════════════';
PRINT '';
PRINT '   📋 Chuẩn bị chạy 5 bước:';
PRINT '      1. Create Tables (Core + Phase 1)';
PRINT '      2. Create Stored Procedures (Core + Phase 2)';
PRINT '      3. Import Sample Data';
PRINT '      4. Create Indexes';
PRINT '      5. Create Views';
PRINT '';
PRINT '   ⏱️  Thời gian ước tính: 1-2 phút';
PRINT '';
PRINT '═══════════════════════════════════════════════════════════════';
PRINT '';

WAITFOR DELAY '00:00:02';

-- =============================================
-- STEP 0: RESET DATABASE (Optional - uncomment nếu cần)
-- =============================================
-- :r 00_ResetData.sql

-- =============================================
-- STEP 1: CREATE TABLES
-- =============================================
PRINT '';
PRINT '┌─────────────────────────────────────────────────────────────┐';
PRINT '│ STEP 1/5: Creating Tables...                              │';
PRINT '└─────────────────────────────────────────────────────────────┘';
PRINT '';

:r 01_CreateTables.sql

-- =============================================
-- STEP 2: CREATE STORED PROCEDURES
-- =============================================
PRINT '';
PRINT '┌─────────────────────────────────────────────────────────────┐';
PRINT '│ STEP 2/5: Creating Stored Procedures...                   │';
PRINT '└─────────────────────────────────────────────────────────────┘';
PRINT '';

:r 02_StoredProcedures.sql

-- =============================================
-- STEP 3: SEED DATA
-- =============================================
PRINT '';
PRINT '┌─────────────────────────────────────────────────────────────┐';
PRINT '│ STEP 3/5: Importing Sample Data...                        │';
PRINT '└─────────────────────────────────────────────────────────────┘';
PRINT '';

:r 03_SeedData.sql

-- =============================================
-- STEP 4: CREATE INDEXES
-- =============================================
PRINT '';
PRINT '┌─────────────────────────────────────────────────────────────┐';
PRINT '│ STEP 4/5: Creating Indexes...                             │';
PRINT '└─────────────────────────────────────────────────────────────┘';
PRINT '';

:r 04_Indexes.sql

-- =============================================
-- STEP 5: CREATE VIEWS
-- =============================================
PRINT '';
PRINT '┌─────────────────────────────────────────────────────────────┐';
PRINT '│ STEP 5/5: Creating Views...                               │';
PRINT '└─────────────────────────────────────────────────────────────┘';
PRINT '';

:r 05_Views.sql

-- =============================================
-- VERIFICATION
-- =============================================
PRINT '';
PRINT '┌─────────────────────────────────────────────────────────────┐';
PRINT '│ VERIFICATION                                               │';
PRINT '└─────────────────────────────────────────────────────────────┘';
PRINT '';

USE EducationManagement;
GO

DECLARE @TableCount INT, @SPCount INT, @IndexCount INT, @ViewCount INT;
DECLARE @StudentCount INT, @ClassCount INT, @SubjectCount INT;

-- Count objects
SELECT @TableCount = COUNT(*) FROM sys.tables WHERE type = 'U';
SELECT @SPCount = COUNT(*) FROM sys.procedures WHERE type = 'P';
SELECT @IndexCount = COUNT(*) FROM sys.indexes WHERE type > 0;
SELECT @ViewCount = COUNT(*) FROM sys.views;

-- Count sample data
SELECT @StudentCount = COUNT(*) FROM students;
SELECT @ClassCount = COUNT(*) FROM classes;
SELECT @SubjectCount = COUNT(*) FROM subjects;

PRINT '  📊 Database Objects:';
PRINT '     ✓ Tables: ' + CAST(@TableCount AS VARCHAR(10)) + ' (Expected: 16)';
PRINT '     ✓ Stored Procedures: ' + CAST(@SPCount AS VARCHAR(10)) + ' (Expected: 130+)';
PRINT '     ✓ Indexes: ' + CAST(@IndexCount AS VARCHAR(10)) + ' (Expected: 50+)';
PRINT '     ✓ Views: ' + CAST(@ViewCount AS VARCHAR(10));
PRINT '';
PRINT '  📦 Sample Data:';
PRINT '     ✓ Students: ' + CAST(@StudentCount AS VARCHAR(10));
PRINT '     ✓ Classes: ' + CAST(@ClassCount AS VARCHAR(10));
PRINT '     ✓ Subjects: ' + CAST(@SubjectCount AS VARCHAR(10));
PRINT '';

-- =============================================
-- COMPLETE
-- =============================================
PRINT '';
PRINT '═══════════════════════════════════════════════════════════════';
PRINT '    ✅ SETUP HOÀN TẤT!';
PRINT '═══════════════════════════════════════════════════════════════';
PRINT '';
PRINT '   📊 Database: EducationManagement';
PRINT '   📦 Tables: ' + CAST(@TableCount AS VARCHAR(10)) + ' (Core + Phase 1)';
PRINT '   ⚙️  SPs: ' + CAST(@SPCount AS VARCHAR(10)) + ' (Core + Phase 2)';
PRINT '';
PRINT '   🔐 Default Login:';
PRINT '      👤 Username: admin';
PRINT '      🔑 Password: admin123';
PRINT '';
PRINT '   🚀 Next Steps:';
PRINT '      1. Start Backend: dotnet run';
PRINT '      2. Open Frontend: AdminFrontend/index.html';
PRINT '      3. Login & Start Using!';
PRINT '';
PRINT '   📚 Features Included:';
PRINT '      ✅ Core Management System';
PRINT '      ✅ Phase 1: Enrollment Tables';
PRINT '      ✅ Phase 2: Enrollment SPs';
PRINT '      ✅ Sample Data';
PRINT '      ✅ Optimized Indexes';
PRINT '';
PRINT '═══════════════════════════════════════════════════════════════';
PRINT '';
GO

