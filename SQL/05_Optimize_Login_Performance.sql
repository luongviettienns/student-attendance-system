-- =============================================
-- 🚀 OPTIMIZE LOGIN PERFORMANCE
-- Tối ưu stored procedure và index cho login
-- =============================================

USE EducationManagement;
GO

SET QUOTED_IDENTIFIER ON;
GO

PRINT '========================================';
PRINT '🚀 TỐI ƯU PERFORMANCE CHO LOGIN';
PRINT '========================================';

-- =============================================
-- 1. RECREATE STORED PROCEDURE (OPTIMIZED)
-- =============================================
PRINT '';
PRINT '📊 Optimizing sp_GetUserByUsername...';

IF OBJECT_ID('sp_GetUserByUsername', 'P') IS NOT NULL 
    DROP PROCEDURE sp_GetUserByUsername;
GO

CREATE PROCEDURE sp_GetUserByUsername
    @Username VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- ✅ PERFORMANCE: Normalize username in parameter (not in query) to allow index usage
    -- Username should already be normalized to lowercase in code, but ensure here
    DECLARE @NormalizedUsername VARCHAR(50) = LOWER(LTRIM(RTRIM(@Username)));
    
    -- ✅ OPTIMIZED: Direct comparison without LOWER() to use index efficiently
    SELECT u.user_id, u.username, u.password_hash, u.full_name, u.email, 
           u.phone, u.role_id, r.role_name, u.avatar_url, u.is_active, u.last_login_at
    FROM dbo.users u
    LEFT JOIN dbo.roles r ON u.role_id = r.role_id
    WHERE u.username = @NormalizedUsername AND u.deleted_at IS NULL;
END
GO

PRINT '   ✅ Created: sp_GetUserByUsername (OPTIMIZED)';

-- =============================================
-- 2. CREATE DEDICATED INDEX FOR USERNAME LOOKUP
-- =============================================
PRINT '';
PRINT '📊 Creating optimized index for username lookup...';

-- Drop existing index if exists
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Users_Username_Lookup')
BEGIN
    DROP INDEX IX_Users_Username_Lookup ON dbo.users;
    PRINT '   ⚠️  Dropped existing: IX_Users_Username_Lookup';
END

-- Create optimized covering index for login
CREATE NONCLUSTERED INDEX IX_Users_Username_Lookup
ON dbo.users(username)
INCLUDE (user_id, password_hash, full_name, email, phone, role_id, avatar_url, is_active, last_login_at)
WHERE deleted_at IS NULL;

PRINT '   ✅ Created: IX_Users_Username_Lookup (COVERING INDEX for login)';

-- =============================================
-- 3. UPDATE STATISTICS
-- =============================================
PRINT '';
PRINT '📊 Updating statistics...';

UPDATE STATISTICS dbo.users;
PRINT '   ✅ Updated: Statistics for dbo.users';

PRINT '';
PRINT '========================================';
PRINT '✅ HOÀN THÀNH TỐI ƯU LOGIN PERFORMANCE!';
PRINT '========================================';
PRINT '💡 Kết quả mong đợi:';
PRINT '   - Database lookup: 500-600ms → 5-20ms (30-100x nhanh hơn)';
PRINT '   - Total login time: 900ms → 200-300ms (3-4x nhanh hơn)';
PRINT '========================================';
PRINT '';
GO

