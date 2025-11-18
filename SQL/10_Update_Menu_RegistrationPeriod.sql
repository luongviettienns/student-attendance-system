-- ============================================================
-- 📋 CẬP NHẬT MENU: GỘP "ĐỢT ĐĂNG KÝ HỌC PHẦN" VÀ "QUẢN LÝ ĐỢT ĐĂNG KÝ HỌC LẠI"
-- ============================================================
-- Mục đích:
-- 1. Đổi tên "Đợt đăng ký học phần" thành "Đợt đăng ký học phần/học lại"
-- 2. Xóa/Ẩn "Quản lý đợt đăng ký học lại" khỏi sidebar menu
-- ============================================================

USE EducationManagement;
GO

BEGIN TRANSACTION;
BEGIN TRY
    -- ============================================================
    -- 🔹 BƯỚC 1: ĐỔI TÊN "Đợt đăng ký học phần" THÀNH "Đợt đăng ký học phần/học lại"
    -- ============================================================
    UPDATE dbo.permissions
    SET permission_name = N'Đợt đăng ký học phần/học lại',
        description = N'Quản lý đợt đăng ký học phần thường và học lại'
    WHERE permission_code = 'ADMIN_REGISTRATION_PERIODS';
    
    PRINT N'✅ Đã đổi tên "Đợt đăng ký học phần" thành "Đợt đăng ký học phần/học lại"';
    
    -- ============================================================
    -- 🔹 BƯỚC 2: XÓA/ẨN "Quản lý đợt đăng ký học lại" KHỎI MENU
    -- Cách 1: Xóa khỏi role_permissions (không xóa permission vì có thể cần cho code)
    -- Cách 2: Set is_active = 0 để ẩn khỏi menu
    -- ============================================================
    
    -- Option 1: Ẩn khỏi menu bằng cách set is_active = 0
    UPDATE dbo.permissions
    SET is_active = 0,
        description = N'Đã gộp vào "Đợt đăng ký học phần/học lại" - Ẩn khỏi menu'
    WHERE permission_code = 'MANAGE_REGISTRATION_PERIODS';
    
    PRINT N'✅ Đã ẩn "Quản lý đợt đăng ký học lại" khỏi menu (is_active = 0)';
    
    -- Option 2: Xóa khỏi role_permissions (nếu muốn xóa hoàn toàn khỏi roles)
    -- Uncomment nếu muốn xóa khỏi roles
    /*
    DELETE FROM dbo.role_permissions
    WHERE permission_code = 'MANAGE_REGISTRATION_PERIODS';
    
    PRINT N'✅ Đã xóa "Quản lý đợt đăng ký học lại" khỏi role_permissions';
    */
    
    -- ============================================================
    -- 🔹 BƯỚC 3: KIỂM TRA KẾT QUẢ
    -- ============================================================
    SELECT 
        permission_code,
        permission_name,
        parent_code,
        icon,
        sort_order,
        is_active,
        description
    FROM dbo.permissions
    WHERE permission_code IN ('ADMIN_REGISTRATION_PERIODS', 'MANAGE_REGISTRATION_PERIODS')
    ORDER BY sort_order;
    
    COMMIT TRANSACTION;
    PRINT N'✅ Hoàn thành cập nhật menu!';
    
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    
    PRINT N'❌ Lỗi: ' + @ErrorMessage;
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH;
GO

