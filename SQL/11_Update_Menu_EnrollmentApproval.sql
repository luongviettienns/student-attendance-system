-- ============================================================
-- 📋 CẬP NHẬT MENU: GỘP "DUYỆT ĐĂNG KÝ HỌC PHẦN" VÀ "DUYỆT ĐĂNG KÝ HỌC LẠI"
-- ============================================================
-- Mục đích:
-- 1. Tạo/cập nhật permission ADVISOR_ENROLLMENTS với tên "Duyệt đăng ký học phần/học lại"
-- 2. Ẩn permission ADVISOR_RETAKE khỏi sidebar menu (vì đã gộp vào enrollments)
-- ============================================================

USE EducationManagement;
GO

BEGIN TRANSACTION;
BEGIN TRY
    -- ============================================================
    -- 🔹 BƯỚC 1: TẠO/CẬP NHẬT PERMISSION ADVISOR_ENROLLMENTS
    -- ============================================================
    -- Kiểm tra xem permission đã tồn tại chưa
    IF NOT EXISTS (SELECT 1 FROM dbo.permissions WHERE permission_code = 'ADVISOR_ENROLLMENTS')
    BEGIN
        -- Tạo mới permission ADVISOR_ENROLLMENTS
        INSERT INTO dbo.permissions (
            permission_id,
            permission_code,
            permission_name,
            description,
            parent_code,
            icon,
            sort_order,
            is_active,
            created_at,
            created_by
        )
        VALUES (
            'PERM_ADV_ENROLLMENTS',
            'ADVISOR_ENROLLMENTS',
            N'Duyệt đăng ký học phần/học lại',
            N'Duyệt đăng ký học phần thường và đăng ký học lại cho sinh viên',
            'ADVISOR_SECTION_ADVISING',
            'fas fa-clipboard-check',
            5, -- Sort order sau ADVISOR_APPEALS (3) và trước ADVISOR_GRADE_FORMULA (6)
            1,
            GETDATE(),
            'system_update_menu'
        );
        
        PRINT N'✅ Đã tạo permission ADVISOR_ENROLLMENTS mới.';
        
        -- Gán permission cho role Advisor
        IF EXISTS (SELECT 1 FROM dbo.roles WHERE role_name = 'Advisor' AND deleted_at IS NULL)
        BEGIN
            INSERT INTO dbo.role_permissions (role_id, permission_id, created_at, created_by)
            SELECT 
                r.role_id,
                'PERM_ADV_ENROLLMENTS',
                GETDATE(),
                'system_update_menu'
            FROM dbo.roles r
            WHERE r.role_name = 'Advisor' 
                AND r.deleted_at IS NULL
                AND NOT EXISTS (
                    SELECT 1 FROM dbo.role_permissions rp 
                    WHERE rp.role_id = r.role_id 
                        AND rp.permission_id = 'PERM_ADV_ENROLLMENTS'
                );
            
            PRINT N'✅ Đã gán permission ADVISOR_ENROLLMENTS cho role Advisor.';
        END
    END
    ELSE
    BEGIN
        -- Cập nhật permission đã tồn tại
        UPDATE dbo.permissions
        SET permission_name = N'Duyệt đăng ký học phần/học lại',
            description = N'Duyệt đăng ký học phần thường và đăng ký học lại cho sinh viên',
            icon = 'fas fa-clipboard-check',
            sort_order = 5, -- Sau ADVISOR_APPEALS (3) và trước ADVISOR_GRADE_FORMULA (6)
            updated_at = GETDATE(),
            updated_by = 'system_update_menu'
        WHERE permission_code = 'ADVISOR_ENROLLMENTS';
        
        PRINT N'✅ Đã cập nhật permission ADVISOR_ENROLLMENTS.';
    END
    
    -- ============================================================
    -- 🔹 BƯỚC 2: ẨN PERMISSION ADVISOR_RETAKE KHỎI MENU
    -- ============================================================
    -- Set is_active = 0 để ẩn khỏi menu (không xóa vì có thể cần cho code)
    UPDATE dbo.permissions
    SET is_active = 0,
        description = N'Đã gộp vào "Duyệt đăng ký học phần/học lại" - Ẩn khỏi menu',
        updated_at = GETDATE(),
        updated_by = 'system_update_menu'
    WHERE permission_code = 'ADVISOR_RETAKE';
    
    IF @@ROWCOUNT > 0
        PRINT N'✅ Đã ẩn permission ADVISOR_RETAKE khỏi menu (is_active = 0).';
    ELSE
        PRINT N'⚠️ Không tìm thấy permission ADVISOR_RETAKE để ẩn.';
    
    -- ============================================================
    -- 🔹 BƯỚC 3: CẬP NHẬT SORT_ORDER CHO CÁC PERMISSIONS LIÊN QUAN
    -- ============================================================
    -- Đảm bảo sort order đúng:
    -- ADVISOR_STUDENTS: 1
    -- ADVISOR_WARNINGS: 2
    -- ADVISOR_APPEALS: 3
    -- ADVISOR_RETAKE: 4 (ẩn)
    -- ADVISOR_ENROLLMENTS: 5 (mới/cập nhật)
    -- ADVISOR_GRADE_FORMULA: 6
    
    UPDATE dbo.permissions
    SET sort_order = 5,
        updated_at = GETDATE(),
        updated_by = 'system_update_menu'
    WHERE permission_code = 'ADVISOR_ENROLLMENTS';
    
    -- Cập nhật ADVISOR_GRADE_FORMULA nếu cần
    UPDATE dbo.permissions
    SET sort_order = 6,
        updated_at = GETDATE(),
        updated_by = 'system_update_menu'
    WHERE permission_code = 'ADVISOR_GRADE_FORMULA'
        AND (sort_order IS NULL OR sort_order != 6);
    
    -- ============================================================
    -- 🔹 BƯỚC 4: KIỂM TRA KẾT QUẢ
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
    WHERE permission_code IN ('ADVISOR_ENROLLMENTS', 'ADVISOR_RETAKE', 'ADVISOR_APPEALS', 'ADVISOR_GRADE_FORMULA')
        AND deleted_at IS NULL
    ORDER BY 
        CASE WHEN permission_code = 'ADVISOR_STUDENTS' THEN 1
             WHEN permission_code = 'ADVISOR_WARNINGS' THEN 2
             WHEN permission_code = 'ADVISOR_APPEALS' THEN 3
             WHEN permission_code = 'ADVISOR_RETAKE' THEN 4
             WHEN permission_code = 'ADVISOR_ENROLLMENTS' THEN 5
             WHEN permission_code = 'ADVISOR_GRADE_FORMULA' THEN 6
             ELSE 999 END;
    
    COMMIT TRANSACTION;
    PRINT N'✅ Hoàn thành cập nhật menu duyệt đăng ký!';
    
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
