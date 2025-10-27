-- ===========================================
-- 🎓 HỆ THỐNG QUẢN LÝ ĐIỂM DANH SINH VIÊN
-- 📋 RESET DATA - XÓA TOÀN BỘ DỮ LIỆU
-- ===========================================
-- 
-- Script này xóa toàn bộ dữ liệu trong database
-- nhưng GIỮ NGUYÊN cấu trúc bảng
-- 
-- ⚠️ CẢNH BÁO: Script này sẽ XÓA TẤT CẢ dữ liệu!
-- Chỉ sử dụng trong môi trường development/testing
-- 
-- ===========================================

USE EducationManagement;
GO

PRINT '';
PRINT '╔══════════════════════════════════════════════════════════════════╗';
PRINT '║                                                                  ║';
PRINT '║                  ⚠️  CẢNH BÁO: RESET DATA                       ║';
PRINT '║                                                                  ║';
PRINT '║          Script này sẽ XÓA TOÀN BỘ dữ liệu trong database!      ║';
PRINT '║          Chỉ sử dụng trong môi trường Development/Testing        ║';
PRINT '║                                                                  ║';
PRINT '╚══════════════════════════════════════════════════════════════════╝';
PRINT '';

-- Đợi 3 giây để user có thể hủy nếu chạy nhầm
WAITFOR DELAY '00:00:03';

PRINT '🗑️  Bắt đầu xóa dữ liệu...';
PRINT '';

-- ===========================================
-- TẮT FOREIGN KEY CONSTRAINTS
-- ===========================================
PRINT '🔓 Tạm thời tắt Foreign Key Constraints...';

-- Disable all constraints
EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';

PRINT '✅ Đã tắt Foreign Key Constraints';
PRINT '';

-- ===========================================
-- XÓA DỮ LIỆU THEO THỨ TỰ DEPENDENCIES
-- ===========================================

PRINT '📋 1/17: Xóa Audit Logs...';
DELETE FROM dbo.audit_logs;
PRINT '   ✅ Đã xóa audit_logs';

PRINT '📋 2/17: Xóa Notifications...';
DELETE FROM dbo.notifications;
PRINT '   ✅ Đã xóa notifications';

PRINT '📋 3/17: Xóa Grades...';
DELETE FROM dbo.grades;
PRINT '   ✅ Đã xóa grades';

PRINT '📋 4/17: Xóa Attendances...';
DELETE FROM dbo.attendances;
PRINT '   ✅ Đã xóa attendances';

PRINT '📋 5/17: Xóa Enrollments...';
DELETE FROM dbo.enrollments;
PRINT '   ✅ Đã xóa enrollments';

PRINT '📋 6/17: Xóa Classes...';
DELETE FROM dbo.classes;
PRINT '   ✅ Đã xóa classes';

PRINT '📋 7/17: Xóa Students...';
DELETE FROM dbo.students;
PRINT '   ✅ Đã xóa students';

PRINT '📋 8/17: Xóa Lecturers...';
DELETE FROM dbo.lecturers;
PRINT '   ✅ Đã xóa lecturers';

PRINT '📋 9/17: Xóa Subjects...';
DELETE FROM dbo.subjects;
PRINT '   ✅ Đã xóa subjects';

PRINT '📋 10/17: Xóa Majors...';
DELETE FROM dbo.majors;
PRINT '   ✅ Đã xóa majors';

PRINT '📋 11/17: Xóa Departments...';
DELETE FROM dbo.departments;
PRINT '   ✅ Đã xóa departments';

PRINT '📋 12/17: Xóa Faculties...';
DELETE FROM dbo.faculties;
PRINT '   ✅ Đã xóa faculties';

PRINT '📋 13/17: Xóa Academic Years...';
DELETE FROM dbo.academic_years;
PRINT '   ✅ Đã xóa academic_years';

PRINT '📋 14/17: Xóa Users...';
DELETE FROM dbo.users;
PRINT '   ✅ Đã xóa users';

PRINT '📋 15/17: Xóa Role Permissions...';
DELETE FROM dbo.role_permissions;
PRINT '   ✅ Đã xóa role_permissions';

PRINT '📋 16/17: Xóa Permissions...';
DELETE FROM dbo.permissions;
PRINT '   ✅ Đã xóa permissions';

PRINT '📋 17/17: Xóa Roles...';
DELETE FROM dbo.roles;
PRINT '   ✅ Đã xóa roles';

PRINT '';

-- ===========================================
-- RESET IDENTITY COLUMNS (nếu có)
-- ===========================================
PRINT '🔄 Reset Identity Columns...';

-- Reset identity cho audit_logs (có IDENTITY)
IF EXISTS (SELECT * FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.audit_logs'))
BEGIN
    DBCC CHECKIDENT ('dbo.audit_logs', RESEED, 0);
    PRINT '   ✅ Reset identity: audit_logs';
END

PRINT '';

-- ===========================================
-- BẬT LẠI FOREIGN KEY CONSTRAINTS
-- ===========================================
PRINT '🔐 Bật lại Foreign Key Constraints...';

-- Enable all constraints và kiểm tra dữ liệu
EXEC sp_MSforeachtable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL';

PRINT '✅ Đã bật Foreign Key Constraints';
PRINT '';

-- ===========================================
-- KIỂM TRA KẾT QUẢ
-- ===========================================
PRINT '📊 KIỂM TRA KẾT QUẢ:';
PRINT '';

DECLARE @TableName NVARCHAR(128);
DECLARE @RowCount INT;
DECLARE @SQL NVARCHAR(MAX);

DECLARE table_cursor CURSOR FOR
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE' 
  AND TABLE_SCHEMA = 'dbo'
ORDER BY TABLE_NAME;

OPEN table_cursor;
FETCH NEXT FROM table_cursor INTO @TableName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL = N'SELECT @Count = COUNT(*) FROM dbo.' + QUOTENAME(@TableName);
    EXEC sp_executesql @SQL, N'@Count INT OUTPUT', @Count = @RowCount OUTPUT;
    
    PRINT '   ' + CAST(@RowCount AS NVARCHAR(10)) + ' rows - ' + @TableName;
    
    FETCH NEXT FROM table_cursor INTO @TableName;
END

CLOSE table_cursor;
DEALLOCATE table_cursor;

PRINT '';
PRINT '╔══════════════════════════════════════════════════════════════════╗';
PRINT '║                                                                  ║';
PRINT '║                  ✅ HOÀN THÀNH RESET DATA!                      ║';
PRINT '║                                                                  ║';
PRINT '║          Database đã sạch sẽ, sẵn sàng cho dữ liệu mới          ║';
PRINT '║                                                                  ║';
PRINT '╚══════════════════════════════════════════════════════════════════╝';
PRINT '';
PRINT '💡 BƯỚC TIẾP THEO:';
PRINT '   Chạy script seed data để tạo dữ liệu mới:';
PRINT '   > sqlcmd -S localhost -i 04_SeedData.sql';
PRINT '';
PRINT '📝 GHI CHÚ:';
PRINT '   - Cấu trúc bảng vẫn còn nguyên';
PRINT '   - Foreign Keys đã được kiểm tra và hoạt động bình thường';
PRINT '   - Identity columns đã được reset về 0';
PRINT '';
GO

