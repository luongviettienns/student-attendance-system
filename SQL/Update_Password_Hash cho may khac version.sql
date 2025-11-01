-- ===========================================
-- 🔧 UPDATE PASSWORD HASH - Fix login issue
-- ===========================================
-- Hash cũ: $2b$12$8HoLKV3tszmWbxEa1OWy8u973bS4UCVLXd3JJQ9JaF0vXFaQyKydK (không verify được)
-- Hash mới: $2a$10$kWP4GtGAKfoyk5vgCqZYuOoXsWpA9uUmAAUBWkrt4ntUiACF2n.pu (verify thành công với password123)
-- ===========================================

USE EducationManagement;
GO

PRINT '========================================';
PRINT '🔧 Cập nhật password hash cho student_k21_01';
PRINT '========================================';
GO

-- 1. Kiểm tra hash hiện tại
PRINT '';
PRINT '1️⃣ Hash hiện tại:';
SELECT 
    user_id,
    username,
    password_hash,
    LEN(password_hash) as hash_length
FROM dbo.users
WHERE username = 'admin';
GO

-- 2. Cập nhật hash mới (được tạo từ password123 với workFactor 12, verify thành công)
-- Format: $2a$12$ (BCrypt.Net-Next tạo $2a$ thay vì $2b$, nhưng vẫn tương thích)
PRINT '';
PRINT '2️⃣ Cập nhật hash mới...';
UPDATE dbo.users
SET password_hash = '$2a$12$T4SCMJNUJ/uEv7yBVvvTy.AqH4R8mhDzBq0e0/35lye5fwWBLHKqa'
WHERE username = 'admin';

IF @@ROWCOUNT > 0
    PRINT '   ✅ Đã cập nhật password hash';
ELSE
    PRINT '   ⚠️  Không tìm thấy user để cập nhật';
GO

-- 3. Kiểm tra lại
PRINT '';
PRINT '3️⃣ Hash sau khi cập nhật:';
SELECT 
    user_id,
    username,
    password_hash,
    LEN(password_hash) as hash_length,
    SUBSTRING(password_hash, 1, 7) as hash_format
FROM dbo.users
WHERE username = 'student_k21_01';
GO

PRINT '';
PRINT '========================================';
PRINT '✅ Hoàn tất!';
PRINT '';
PRINT '📝 Bước tiếp theo:';
PRINT '   1. Test login với username: student_k21_01';
PRINT '   2. Password: password123';
PRINT '   3. Hoặc test qua endpoint:';
PRINT '      GET /api-edu/auth/debug/test-login?username=student_k21_01&password=password123';
PRINT '========================================';
GO

