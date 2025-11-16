-- =============================================
-- 🔧 FIX PASSWORD CHO USER advisor_toan
-- Kiểm tra và cập nhật password hash nếu cần
-- =============================================

USE EducationManagement;
GO

SET QUOTED_IDENTIFIER ON;
GO

PRINT '========================================';
PRINT '🔧 FIX PASSWORD CHO advisor_toan';
PRINT '========================================';
PRINT '';

-- =============================================
-- 1. KIỂM TRA THÔNG TIN USER HIỆN TẠI
-- =============================================
PRINT '📋 Step 1: Kiểm tra thông tin user hiện tại...';
PRINT '';

SELECT 
    user_id,
    username,
    email,
    full_name,
    role_id,
    is_active,
    LEN(password_hash) AS password_hash_length,
    LEFT(password_hash, 10) AS password_hash_prefix,
    password_hash
FROM dbo.users
WHERE username = 'advisor_toan' OR user_id = 'USR_ADV_01';

PRINT '';

-- =============================================
-- 2. CẬP NHẬT PASSWORD HASH
-- =============================================
PRINT '🔧 Step 2: Cập nhật password hash...';
PRINT '';

-- Password: password123
-- Hash: $2a$10$Ya6MFL1CGpg2/y088u6t7.ACYkMJdmA1869rbBmAnyn6OQi0hTBue
-- Hash này đã được tạo với BCrypt work factor 10

UPDATE dbo.users
SET password_hash = '$2a$10$Ya6MFL1CGpg2/y088u6t7.ACYkMJdmA1869rbBmAnyn6OQi0hTBue',
    updated_at = GETDATE(),
    updated_by = 'fix_password_script'
WHERE (username = 'advisor_toan' OR user_id = 'USR_ADV_01')
AND password_hash != '$2a$10$Ya6MFL1CGpg2/y088u6t7.ACYkMJdmA1869rbBmAnyn6OQi0hTBue';

IF @@ROWCOUNT > 0
BEGIN
    PRINT '   ✅ Đã cập nhật password hash';
END
ELSE
BEGIN
    PRINT '   ℹ️  Password hash đã đúng, không cần cập nhật';
END
PRINT '';

-- =============================================
-- 3. KIỂM TRA LẠI SAU KHI CẬP NHẬT
-- =============================================
PRINT '📋 Step 3: Kiểm tra lại sau khi cập nhật...';
PRINT '';

SELECT 
    user_id,
    username,
    LEN(password_hash) AS password_hash_length,
    LEFT(password_hash, 10) AS password_hash_prefix,
    CASE 
        WHEN password_hash = '$2a$10$Ya6MFL1CGpg2/y088u6t7.ACYkMJdmA1869rbBmAnyn6OQi0hTBue' THEN '✅ Đúng'
        ELSE '❌ Sai'
    END AS hash_status
FROM dbo.users
WHERE username = 'advisor_toan' OR user_id = 'USR_ADV_01';

PRINT '';

-- =============================================
-- 4. KIỂM TRA TẤT CẢ USERS CÓ PASSWORD HASH LỖI
-- =============================================
PRINT '📋 Step 4: Kiểm tra tất cả users có password hash lỗi...';
PRINT '';

SELECT 
    user_id,
    username,
    email,
    role_id,
    LEN(password_hash) AS password_hash_length,
    CASE 
        WHEN password_hash IS NULL THEN '❌ NULL'
        WHEN LEN(password_hash) != 60 THEN '❌ Độ dài sai (phải là 60)'
        WHEN password_hash NOT LIKE '$2a$%' AND password_hash NOT LIKE '$2b$%' THEN '❌ Format sai'
        ELSE '✅ OK'
    END AS hash_status
FROM dbo.users
WHERE deleted_at IS NULL
AND (
    password_hash IS NULL 
    OR LEN(password_hash) != 60
    OR (password_hash NOT LIKE '$2a$%' AND password_hash NOT LIKE '$2b$%')
);

PRINT '';

PRINT '========================================';
PRINT '✅ HOÀN THÀNH!';
PRINT '========================================';
PRINT '💡 Thông tin:';
PRINT '   - Username: advisor_toan';
PRINT '   - Password: password123';
PRINT '   - Hash: $2a$10$Ya6MFL1CGpg2/y088u6t7.ACYkMJdmA1869rbBmAnyn6OQi0hTBue';
PRINT '   - User ID: USR_ADV_01';
PRINT '========================================';
PRINT '';
GO

