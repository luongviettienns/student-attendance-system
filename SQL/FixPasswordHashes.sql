-- ===========================================
-- 🔧 Script sửa password hash cho các user
-- ===========================================
-- Hash cũ không khớp với password123
-- Cập nhật với hash mới đã verify
-- ===========================================

USE EducationManagement;
GO

PRINT '═══════════════════════════════════════════════';
PRINT '🔧 CẬP NHẬT PASSWORD HASH CHO CÁC USER';
PRINT '═══════════════════════════════════════════════';
GO

-- Hash mới cho password123 (đã verify)
DECLARE @Password123Hash VARCHAR(255) = '$2a$10$Ya6MFL1CGpg2/y088u6t7.ACYkMJdmA1869rbBmAnyn6OQi0hTBue';

-- Hash cho admin123 (đã có sẵn)
DECLARE @Admin123Hash VARCHAR(255) = '$2a$10$h5gvrNjE2bhwhHn6Ofofq.Ppr0hvpLY5Q3mbY1OjkkGL8CMxm2VBm';

PRINT '';
PRINT '📋 Cập nhật password hash...';
PRINT '';

-- Cập nhật admin
UPDATE users
SET password_hash = @Admin123Hash,
    updated_at = GETDATE(),
    updated_by = 'system'
WHERE username = 'admin' AND deleted_at IS NULL;

IF @@ROWCOUNT > 0
    PRINT '   ✅ Đã cập nhật admin (admin123)';
ELSE
    PRINT '   ⚠️  Không tìm thấy admin';

-- Cập nhật lecturer01
UPDATE users
SET password_hash = @Password123Hash,
    updated_at = GETDATE(),
    updated_by = 'system'
WHERE username = 'lecturer01' AND deleted_at IS NULL;

IF @@ROWCOUNT > 0
    PRINT '   ✅ Đã cập nhật lecturer01 (password123)';
ELSE
    PRINT '   ⚠️  Không tìm thấy lecturer01';

-- Cập nhật tất cả students
UPDATE users
SET password_hash = @Password123Hash,
    updated_at = GETDATE(),
    updated_by = 'system'
WHERE username LIKE 'student_%' AND deleted_at IS NULL;

DECLARE @StudentCount INT = @@ROWCOUNT;
IF @StudentCount > 0
    PRINT CONCAT('   ✅ Đã cập nhật ', @StudentCount, ' students (password123)');
ELSE
    PRINT '   ⚠️  Không tìm thấy students';

PRINT '';
PRINT '═══════════════════════════════════════════════';
PRINT '✅ HOÀN TẤT';
PRINT '═══════════════════════════════════════════════';
PRINT '';
PRINT '🔑 Thông tin đăng nhập:';
PRINT '   👤 Admin:        admin / admin123';
PRINT '   👨‍🏫 Lecturer:     lecturer01 / password123';
PRINT '   👨‍🎓 Students:     student_k21_01, ... / password123';
PRINT '';
GO

