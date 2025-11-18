-- ===========================================
-- SCRIPT KHÔI PHỤC: Khôi phục ngày tháng năm học về trạng thái gốc
-- ===========================================
-- Mục đích: Khôi phục dữ liệu năm học về trạng thái ban đầu sau khi test
-- Cách dùng: Chạy script này sau khi test xong
-- ===========================================

USE EducationManagement;
GO

SET NOCOUNT ON;
PRINT '========================================';
PRINT 'SCRIPT KHÔI PHỤC: Khôi phục ngày tháng năm học';
PRINT '========================================';
GO

-- Kiểm tra xem có bảng tạm lưu dữ liệu gốc không
IF OBJECT_ID('tempdb..#OriginalSchoolYearDates', 'U') IS NULL
BEGIN
    PRINT '❌ ERROR: Không tìm thấy dữ liệu backup!';
    PRINT '   Vui lòng chạy lại script Test_Force_Semester_Transition.sql trước';
    RETURN;
END

PRINT '';
PRINT '📋 Đang khôi phục dữ liệu...';

-- Khôi phục dữ liệu
UPDATE sy
SET 
    sy.semester1_start = backup.original_semester1_start,
    sy.semester1_end = backup.original_semester1_end,
    sy.semester2_start = backup.original_semester2_start,
    sy.semester2_end = backup.original_semester2_end,
    sy.current_semester = backup.original_current_semester,
    sy.updated_at = GETDATE(),
    sy.updated_by = 'restore_after_test'
FROM school_years sy
INNER JOIN #OriginalSchoolYearDates backup ON sy.school_year_id = backup.school_year_id
WHERE sy.deleted_at IS NULL;

DECLARE @RestoredCount INT = @@ROWCOUNT;

IF @RestoredCount > 0
BEGIN
    PRINT CONCAT('   ✅ Đã khôi phục ', @RestoredCount, ' năm học');
    
    -- Hiển thị dữ liệu đã khôi phục
    PRINT '';
    PRINT '📊 Dữ liệu đã khôi phục:';
    
    SELECT 
        sy.school_year_id AS NămHọcID,
        sy.year_code AS MãNămHọc,
        sy.current_semester AS HọcKỳHiệnTại,
        CASE 
            WHEN sy.current_semester = 1 THEN N'Học kỳ 1'
            WHEN sy.current_semester = 2 THEN N'Học kỳ 2'
            ELSE N'Chưa xác định'
        END AS TênHọcKỳ,
        FORMAT(sy.semester1_start, 'dd/MM/yyyy') AS HK1_BắtĐầu,
        FORMAT(sy.semester1_end, 'dd/MM/yyyy') AS HK1_KếtThúc,
        FORMAT(sy.semester2_start, 'dd/MM/yyyy') AS HK2_BắtĐầu,
        FORMAT(sy.semester2_end, 'dd/MM/yyyy') AS HK2_KếtThúc
    FROM school_years sy
    INNER JOIN #OriginalSchoolYearDates backup ON sy.school_year_id = backup.school_year_id
    WHERE sy.deleted_at IS NULL;
END
ELSE
BEGIN
    PRINT '   ⚠️  Không có dữ liệu nào được khôi phục';
END

-- Xóa bảng tạm
DROP TABLE #OriginalSchoolYearDates;

PRINT '';
PRINT '========================================';
PRINT '✅ KHÔI PHỤC HOÀN TẤT';
PRINT '========================================';
GO

