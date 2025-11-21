-- ===========================================
-- 🎓 HỆ THỐNG QUẢN LÝ ĐIỂM DANH SINH VIÊN
-- 📋 File: PERMISSIONS CHO ĐỢT ĐĂNG KÝ HỌC LẠI
-- ===========================================

USE EducationManagement;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

PRINT '========================================';
PRINT 'Starting: 09_Permissions_RetakeRegistration.sql';
PRINT 'Retake Registration Permissions';
PRINT '========================================';
GO

-- ===========================================
-- 1. THÊM PARENT PERMISSION: MANAGE_REGISTRATION_PERIODS
-- ===========================================

IF NOT EXISTS (SELECT 1 FROM dbo.permissions WHERE permission_code = 'MANAGE_REGISTRATION_PERIODS')
BEGIN
    INSERT INTO dbo.permissions (
        permission_id, 
        permission_code, 
        permission_name, 
        parent_code, 
        icon, 
        sort_order, 
        description, 
        is_active,
        created_by
    )
    VALUES (
        'PERM_ADM_MANAGE_RET_PERIODS',
        'MANAGE_REGISTRATION_PERIODS',
        N'Quản lý đợt đăng ký học lại',
        'ADMIN_SECTION_ENROLLMENT',
        'fas fa-redo',
        2,
        N'Quản lý đợt đăng ký học lại (tab phụ trong quản lý đợt đăng ký)',
        1,
        'system'
    );
    PRINT '✓ Added parent permission: MANAGE_REGISTRATION_PERIODS';
END
ELSE
BEGIN
    PRINT '✓ Permission already exists: MANAGE_REGISTRATION_PERIODS';
END
GO

-- ===========================================
-- 2. THÊM RETake PERIOD PERMISSIONS
-- ===========================================

-- View Retake Periods
IF NOT EXISTS (SELECT 1 FROM dbo.permissions WHERE permission_code = 'VIEW_RETAKE_PERIODS')
BEGIN
    INSERT INTO dbo.permissions (
        permission_id, permission_code, permission_name, parent_code, icon, sort_order, description, is_active, created_by
    )
    VALUES (
        'PERM_RET_PER_VIEW', 'VIEW_RETAKE_PERIODS', N'Xem đợt đăng ký học lại', 
        'MANAGE_REGISTRATION_PERIODS', 'fas fa-calendar-alt', 1, 
        N'Xem danh sách đợt đăng ký học lại', 1, 'system'
    );
    PRINT '✓ Added permission: VIEW_RETAKE_PERIODS';
END
GO

-- Create Retake Periods
IF NOT EXISTS (SELECT 1 FROM dbo.permissions WHERE permission_code = 'CREATE_RETAKE_PERIODS')
BEGIN
    INSERT INTO dbo.permissions (
        permission_id, permission_code, permission_name, parent_code, icon, sort_order, description, is_active, created_by
    )
    VALUES (
        'PERM_RET_PER_CREATE', 'CREATE_RETAKE_PERIODS', N'Tạo đợt đăng ký học lại', 
        'MANAGE_REGISTRATION_PERIODS', 'fas fa-plus', 2, 
        N'Tạo đợt đăng ký học lại mới', 1, 'system'
    );
    PRINT '✓ Added permission: CREATE_RETAKE_PERIODS';
END
GO

-- Edit Retake Periods
IF NOT EXISTS (SELECT 1 FROM dbo.permissions WHERE permission_code = 'EDIT_RETAKE_PERIODS')
BEGIN
    INSERT INTO dbo.permissions (
        permission_id, permission_code, permission_name, parent_code, icon, sort_order, description, is_active, created_by
    )
    VALUES (
        'PERM_RET_PER_EDIT', 'EDIT_RETAKE_PERIODS', N'Sửa đợt đăng ký học lại', 
        'MANAGE_REGISTRATION_PERIODS', 'fas fa-edit', 3, 
        N'Sửa thông tin đợt đăng ký học lại', 1, 'system'
    );
    PRINT '✓ Added permission: EDIT_RETAKE_PERIODS';
END
GO

-- Delete Retake Periods
IF NOT EXISTS (SELECT 1 FROM dbo.permissions WHERE permission_code = 'DELETE_RETAKE_PERIODS')
BEGIN
    INSERT INTO dbo.permissions (
        permission_id, permission_code, permission_name, parent_code, icon, sort_order, description, is_active, created_by
    )
    VALUES (
        'PERM_RET_PER_DELETE', 'DELETE_RETAKE_PERIODS', N'Xóa đợt đăng ký học lại', 
        'MANAGE_REGISTRATION_PERIODS', 'fas fa-trash', 4, 
        N'Xóa đợt đăng ký học lại', 1, 'system'
    );
    PRINT '✓ Added permission: DELETE_RETAKE_PERIODS';
END
GO

-- Manage Retake Period Classes
IF NOT EXISTS (SELECT 1 FROM dbo.permissions WHERE permission_code = 'MANAGE_RETAKE_PERIOD_CLASSES')
BEGIN
    INSERT INTO dbo.permissions (
        permission_id, permission_code, permission_name, parent_code, icon, sort_order, description, is_active, created_by
    )
    VALUES (
        'PERM_RET_PER_CLASSES', 'MANAGE_RETAKE_PERIOD_CLASSES', N'Quản lý lớp trong đợt đăng ký học lại', 
        'MANAGE_REGISTRATION_PERIODS', 'fas fa-list', 5, 
        N'Thêm/xóa lớp học lại vào đợt đăng ký', 1, 'system'
    );
    PRINT '✓ Added permission: MANAGE_RETAKE_PERIOD_CLASSES';
END
GO

-- ===========================================
-- 3. THÊM STUDENT RETake REGISTRATION PERMISSIONS
-- ===========================================

-- Register for Retake Classes
IF NOT EXISTS (SELECT 1 FROM dbo.permissions WHERE permission_code = 'REGISTER_RETAKE_CLASSES')
BEGIN
    INSERT INTO dbo.permissions (
        permission_id, permission_code, permission_name, parent_code, icon, sort_order, description, is_active, created_by
    )
    VALUES (
        'PERM_RET_REGISTER', 'REGISTER_RETAKE_CLASSES', N'Đăng ký lớp học lại', 
        'STUDENT_SECTION_STUDY', 'fas fa-redo', 1, 
        N'Sinh viên đăng ký lớp học lại', 1, 'system'
    );
    PRINT '✓ Added permission: REGISTER_RETAKE_CLASSES';
END
GO

-- View Failed Subjects
IF NOT EXISTS (SELECT 1 FROM dbo.permissions WHERE permission_code = 'VIEW_FAILED_SUBJECTS')
BEGIN
    INSERT INTO dbo.permissions (
        permission_id, permission_code, permission_name, parent_code, icon, sort_order, description, is_active, created_by
    )
    VALUES (
        'PERM_RET_VIEW_FAILED', 'VIEW_FAILED_SUBJECTS', N'Xem môn trượt', 
        'STUDENT_SECTION_STUDY', 'fas fa-exclamation-triangle', 2, 
        N'Xem danh sách môn học đã trượt', 1, 'system'
    );
    PRINT '✓ Added permission: VIEW_FAILED_SUBJECTS';
END
GO

-- View Retake Classes
IF NOT EXISTS (SELECT 1 FROM dbo.permissions WHERE permission_code = 'VIEW_RETAKE_CLASSES')
BEGIN
    INSERT INTO dbo.permissions (
        permission_id, permission_code, permission_name, parent_code, icon, sort_order, description, is_active, created_by
    )
    VALUES (
        'PERM_RET_VIEW_CLASSES', 'VIEW_RETAKE_CLASSES', N'Xem lớp học lại', 
        'STUDENT_SECTION_STUDY', 'fas fa-list', 3, 
        N'Xem danh sách lớp học lại của môn', 1, 'system'
    );
    PRINT '✓ Added permission: VIEW_RETAKE_CLASSES';
END
GO

-- ===========================================
-- 4. PHÂN QUYỀN CHO ROLE_ADMIN
-- ===========================================

-- Admin gets all retake period management permissions
IF NOT EXISTS (SELECT 1 FROM dbo.role_permissions WHERE role_id = 'ROLE_ADMIN' AND permission_id = 'PERM_ADM_MANAGE_RET_PERIODS')
BEGIN
    INSERT INTO dbo.role_permissions (role_id, permission_id, created_by)
    VALUES ('ROLE_ADMIN', 'PERM_ADM_MANAGE_RET_PERIODS', 'system');
    PRINT '✓ Assigned MANAGE_REGISTRATION_PERIODS to ROLE_ADMIN';
END

IF NOT EXISTS (SELECT 1 FROM dbo.role_permissions WHERE role_id = 'ROLE_ADMIN' AND permission_id = 'PERM_RET_PER_VIEW')
BEGIN
    INSERT INTO dbo.role_permissions (role_id, permission_id, created_by)
    VALUES ('ROLE_ADMIN', 'PERM_RET_PER_VIEW', 'system');
    INSERT INTO dbo.role_permissions (role_id, permission_id, created_by)
    VALUES ('ROLE_ADMIN', 'PERM_RET_PER_CREATE', 'system');
    INSERT INTO dbo.role_permissions (role_id, permission_id, created_by)
    VALUES ('ROLE_ADMIN', 'PERM_RET_PER_EDIT', 'system');
    INSERT INTO dbo.role_permissions (role_id, permission_id, created_by)
    VALUES ('ROLE_ADMIN', 'PERM_RET_PER_DELETE', 'system');
    INSERT INTO dbo.role_permissions (role_id, permission_id, created_by)
    VALUES ('ROLE_ADMIN', 'PERM_RET_PER_CLASSES', 'system');
    PRINT '✓ Assigned all retake period permissions to ROLE_ADMIN';
END
GO

-- ===========================================
-- 5. PHÂN QUYỀN CHO ROLE_ADVISOR
-- ===========================================

-- Advisor gets all retake period management permissions
IF NOT EXISTS (SELECT 1 FROM dbo.role_permissions WHERE role_id = 'ROLE_ADVISOR' AND permission_id = 'PERM_ADM_MANAGE_RET_PERIODS')
BEGIN
    INSERT INTO dbo.role_permissions (role_id, permission_id, created_by)
    VALUES ('ROLE_ADVISOR', 'PERM_ADM_MANAGE_RET_PERIODS', 'system');
    PRINT '✓ Assigned MANAGE_REGISTRATION_PERIODS to ROLE_ADVISOR';
END

IF NOT EXISTS (SELECT 1 FROM dbo.role_permissions WHERE role_id = 'ROLE_ADVISOR' AND permission_id = 'PERM_RET_PER_VIEW')
BEGIN
    INSERT INTO dbo.role_permissions (role_id, permission_id, created_by)
    VALUES ('ROLE_ADVISOR', 'PERM_RET_PER_VIEW', 'system');
    INSERT INTO dbo.role_permissions (role_id, permission_id, created_by)
    VALUES ('ROLE_ADVISOR', 'PERM_RET_PER_CREATE', 'system');
    INSERT INTO dbo.role_permissions (role_id, permission_id, created_by)
    VALUES ('ROLE_ADVISOR', 'PERM_RET_PER_EDIT', 'system');
    INSERT INTO dbo.role_permissions (role_id, permission_id, created_by)
    VALUES ('ROLE_ADVISOR', 'PERM_RET_PER_DELETE', 'system');
    INSERT INTO dbo.role_permissions (role_id, permission_id, created_by)
    VALUES ('ROLE_ADVISOR', 'PERM_RET_PER_CLASSES', 'system');
    PRINT '✓ Assigned all retake period permissions to ROLE_ADVISOR';
END
GO

-- ===========================================
-- 6. PHÂN QUYỀN CHO ROLE_STUDENT
-- ===========================================

-- Student gets retake registration permissions
IF NOT EXISTS (SELECT 1 FROM dbo.role_permissions WHERE role_id = 'ROLE_STUDENT' AND permission_id = 'PERM_RET_REGISTER')
BEGIN
    INSERT INTO dbo.role_permissions (role_id, permission_id, created_by)
    VALUES ('ROLE_STUDENT', 'PERM_RET_REGISTER', 'system');
    INSERT INTO dbo.role_permissions (role_id, permission_id, created_by)
    VALUES ('ROLE_STUDENT', 'PERM_RET_VIEW_FAILED', 'system');
    INSERT INTO dbo.role_permissions (role_id, permission_id, created_by)
    VALUES ('ROLE_STUDENT', 'PERM_RET_VIEW_CLASSES', 'system');
    PRINT '✓ Assigned retake registration permissions to ROLE_STUDENT';
END
GO

-- ===========================================

PRINT '========================================';
PRINT 'Completed: 09_Permissions_RetakeRegistration.sql';
PRINT '========================================';
GO

