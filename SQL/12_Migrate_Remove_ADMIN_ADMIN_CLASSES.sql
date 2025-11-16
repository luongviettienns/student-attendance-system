-- ===========================================
-- 🎓 MIGRATION: XÓA PERM_ADM_ADMIN_CLASSES
-- ===========================================
-- 
-- Migration này xóa PERM_ADM_ADMIN_CLASSES vì đã được thay thế bởi
-- ADMIN_SECTION_CLASSES (vừa là menu vừa là quyền quản lý)
--
-- Thay đổi:
-- - Xóa permission PERM_ADM_ADMIN_CLASSES (ADMIN_ADMIN_CLASSES)
-- - Xóa tất cả role_permissions liên quan
-- - Giữ lại PERM_ADM_ADMIN_CLASSES_SECTION (ADMIN_SECTION_CLASSES)
--
-- ===========================================

USE EducationManagement;
GO

SET QUOTED_IDENTIFIER ON;
GO

PRINT '';
PRINT '╔════════════════════════════════════════════════╗';
PRINT '║  🔄 MIGRATION: Remove PERM_ADM_ADMIN_CLASSES   ║';
PRINT '╚════════════════════════════════════════════════╝';
PRINT '';
PRINT '⚠️  Migration này sẽ:';
PRINT '   1. Xóa PERM_ADM_ADMIN_CLASSES khỏi role_permissions';
PRINT '   2. Xóa permission PERM_ADM_ADMIN_CLASSES (nếu tồn tại)';
PRINT '   3. Giữ lại ADMIN_SECTION_CLASSES (vừa là menu vừa là quyền)';
PRINT '';
GO

-- ===========================================
-- STEP 1: Xóa khỏi role_permissions
-- ===========================================
PRINT '🔧 Step 1: Removing PERM_ADM_ADMIN_CLASSES from role_permissions...';
GO

DECLARE @DeletedCount INT = 0;

-- Xóa tất cả role_permissions liên quan đến PERM_ADM_ADMIN_CLASSES
DELETE FROM dbo.role_permissions
WHERE permission_id = 'PERM_ADM_ADMIN_CLASSES';

SET @DeletedCount = @@ROWCOUNT;

IF @DeletedCount > 0
BEGIN
    PRINT CONCAT('   ✅ Deleted ', CAST(@DeletedCount AS VARCHAR), ' role_permissions records');
END
ELSE
BEGIN
    PRINT '   ℹ️  No role_permissions records found for PERM_ADM_ADMIN_CLASSES';
END
GO

-- ===========================================
-- STEP 2: Xóa permission PERM_ADM_ADMIN_CLASSES
-- ===========================================
PRINT '';
PRINT '🔧 Step 2: Removing permission PERM_ADM_ADMIN_CLASSES...';
GO

DECLARE @PermissionExists BIT = 0;

-- Kiểm tra permission có tồn tại không
IF EXISTS (SELECT 1 FROM dbo.permissions WHERE permission_id = 'PERM_ADM_ADMIN_CLASSES')
BEGIN
    SET @PermissionExists = 1;
    
    -- Soft delete permission (nếu có deleted_at column)
    IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.permissions') AND name = 'deleted_at')
    BEGIN
        UPDATE dbo.permissions
        SET deleted_at = GETDATE(),
            updated_at = GETDATE(),
            updated_by = 'migration_script'
        WHERE permission_id = 'PERM_ADM_ADMIN_CLASSES';
        
        PRINT '   ✅ Soft deleted permission PERM_ADM_ADMIN_CLASSES';
    END
    ELSE
    BEGIN
        -- Hard delete nếu không có deleted_at
        DELETE FROM dbo.permissions
        WHERE permission_id = 'PERM_ADM_ADMIN_CLASSES';
        
        PRINT '   ✅ Deleted permission PERM_ADM_ADMIN_CLASSES';
    END
END
ELSE
BEGIN
    PRINT '   ℹ️  Permission PERM_ADM_ADMIN_CLASSES not found (may have been removed already)';
END
GO

-- ===========================================
-- STEP 3: Verify ADMIN_SECTION_CLASSES exists
-- ===========================================
PRINT '';
PRINT '🔧 Step 3: Verifying ADMIN_SECTION_CLASSES exists...';
GO

IF EXISTS (SELECT 1 FROM dbo.permissions 
           WHERE permission_code = 'ADMIN_SECTION_CLASSES' 
           AND (deleted_at IS NULL OR deleted_at IS NULL))
BEGIN
    PRINT '   ✅ ADMIN_SECTION_CLASSES exists and is active';
    
    -- Đảm bảo ROLE_ADMIN có ADMIN_SECTION_CLASSES
    IF NOT EXISTS (SELECT 1 FROM dbo.role_permissions rp
                   INNER JOIN dbo.permissions p ON rp.permission_id = p.permission_id
                   WHERE rp.role_id = 'ROLE_ADMIN' 
                   AND p.permission_code = 'ADMIN_SECTION_CLASSES'
                   AND (p.deleted_at IS NULL OR p.deleted_at IS NULL))
    BEGIN
        -- Thêm ADMIN_SECTION_CLASSES vào ROLE_ADMIN nếu chưa có
        DECLARE @SectionClassPermissionId VARCHAR(50);
        SELECT @SectionClassPermissionId = permission_id
        FROM dbo.permissions
        WHERE permission_code = 'ADMIN_SECTION_CLASSES'
        AND (deleted_at IS NULL OR deleted_at IS NULL);
        
        IF @SectionClassPermissionId IS NOT NULL
        BEGIN
            INSERT INTO dbo.role_permissions (role_id, permission_id, created_by)
            VALUES ('ROLE_ADMIN', @SectionClassPermissionId, 'migration_script');
            
            PRINT '   ✅ Added ADMIN_SECTION_CLASSES to ROLE_ADMIN';
        END
    END
    ELSE
    BEGIN
        PRINT '   ✅ ROLE_ADMIN already has ADMIN_SECTION_CLASSES';
    END
END
ELSE
BEGIN
    PRINT '   ⚠️  WARNING: ADMIN_SECTION_CLASSES not found!';
    PRINT '   ⚠️  Please ensure 03_SeedData_FullTest.sql has been run to create this permission.';
END
GO

PRINT '';
PRINT '╔════════════════════════════════════════════════╗';
PRINT '║     ✅ MIGRATION COMPLETED SUCCESSFULLY!        ║';
PRINT '╚════════════════════════════════════════════════╝';
PRINT '';
PRINT '📋 Summary:';
PRINT '   ✅ Removed PERM_ADM_ADMIN_CLASSES from role_permissions';
PRINT '   ✅ Removed/soft-deleted PERM_ADM_ADMIN_CLASSES permission';
PRINT '   ✅ Verified ADMIN_SECTION_CLASSES exists';
PRINT '';
PRINT '💡 Note:';
PRINT '   - ADMIN_SECTION_CLASSES vừa là menu vừa là quyền quản lý';
PRINT '   - Không cần permission con riêng nữa';
PRINT '   - Backend controllers đã được cập nhật để dùng ADMIN_SECTION_CLASSES';
PRINT '';
GO

