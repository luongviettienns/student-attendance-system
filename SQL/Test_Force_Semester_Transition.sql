-- ===========================================
-- SCRIPT TEST: Force chuyển học kỳ để test
-- ===========================================
-- Mục đích: Giả lập thời gian để test chuyển học kỳ
-- Cách dùng: Chạy script này để tạm thời thay đổi ngày tháng của năm học
--            Sau khi test xong, chạy script khôi phục
-- ===========================================

USE EducationManagement;
GO

SET NOCOUNT ON;
PRINT '========================================';
PRINT 'SCRIPT TEST: Force chuyển học kỳ';
PRINT '========================================';
GO

-- ===========================================
-- BƯỚC 1: Lưu trữ dữ liệu gốc
-- ===========================================
PRINT '';
PRINT '📋 BƯỚC 1: Lưu trữ dữ liệu gốc...';

-- Tạo bảng tạm để lưu dữ liệu gốc
IF OBJECT_ID('tempdb..#OriginalSchoolYearDates', 'U') IS NOT NULL
    DROP TABLE #OriginalSchoolYearDates;
GO

CREATE TABLE #OriginalSchoolYearDates (
    school_year_id VARCHAR(50),
    original_semester1_start DATE,
    original_semester1_end DATE,
    original_semester2_start DATE,
    original_semester2_end DATE,
    original_current_semester INT,
    backup_time DATETIME DEFAULT GETDATE()
);

-- Lưu dữ liệu gốc
INSERT INTO #OriginalSchoolYearDates (
    school_year_id,
    original_semester1_start,
    original_semester1_end,
    original_semester2_start,
    original_semester2_end,
    original_current_semester
)
SELECT 
    school_year_id,
    semester1_start,
    semester1_end,
    semester2_start,
    semester2_end,
    current_semester
FROM school_years
WHERE deleted_at IS NULL
    AND is_active = 1;

PRINT CONCAT('   ✅ Đã lưu dữ liệu gốc của ', @@ROWCOUNT, ' năm học');

-- ===========================================
-- BƯỚC 2: Giả lập thời gian để test chuyển HK1 → HK2
-- ===========================================
PRINT '';
PRINT '🔄 BƯỚC 2: Giả lập thời gian để test chuyển HK1 → HK2...';
PRINT '   (Thiết lập ngày hiện tại nằm trong khoảng HK2)';

-- Lấy năm học active
DECLARE @SchoolYearId VARCHAR(50);
DECLARE @Today DATE = CAST(GETDATE() AS DATE);
DECLARE @CurrentYear INT = YEAR(@Today);
DECLARE @TestDate DATE; -- Ngày giả lập để test

SELECT TOP 1 @SchoolYearId = school_year_id
FROM school_years
WHERE deleted_at IS NULL
    AND is_active = 1
ORDER BY start_date DESC;

IF @SchoolYearId IS NULL
BEGIN
    PRINT '   ❌ ERROR: Không tìm thấy năm học active!';
    RETURN;
END

PRINT CONCAT('   ✅ Năm học được chọn: ', @SchoolYearId);

-- Thiết lập ngày test: Giả sử hôm nay là tháng 3 (nằm trong HK2: Tháng 2-6)
-- Nếu đang ở HK1 (Tháng 9-1), ta sẽ set ngày test là tháng 3
SET @TestDate = DATEFROMPARTS(@CurrentYear, 3, 15); -- 15/3 (nằm trong HK2)

PRINT CONCAT('   📅 Ngày hiện tại thực tế: ', FORMAT(@Today, 'dd/MM/yyyy'));
PRINT CONCAT('   📅 Ngày giả lập để test: ', FORMAT(@TestDate, 'dd/MM/yyyy'));

-- Cập nhật semester dates để @TestDate nằm trong HK2
UPDATE school_years
SET 
    -- HK1: Tháng 9 năm trước - Tháng 1 năm hiện tại
    semester1_start = DATEFROMPARTS(@CurrentYear - 1, 9, 1),
    semester1_end = DATEFROMPARTS(@CurrentYear, 1, 31),
    -- HK2: Tháng 2 - Tháng 6 năm hiện tại
    semester2_start = DATEFROMPARTS(@CurrentYear, 2, 1),
    semester2_end = DATEFROMPARTS(@CurrentYear, 6, 30),
    updated_at = GETDATE(),
    updated_by = 'test_force_transition'
WHERE school_year_id = @SchoolYearId;

PRINT '   ✅ Đã cập nhật ngày tháng năm học để test';
PRINT '   📊 Thông tin năm học sau khi cập nhật:';

SELECT 
    school_year_id,
    year_code,
    FORMAT(semester1_start, 'dd/MM/yyyy') AS HK1_Start,
    FORMAT(semester1_end, 'dd/MM/yyyy') AS HK1_End,
    FORMAT(semester2_start, 'dd/MM/yyyy') AS HK2_Start,
    FORMAT(semester2_end, 'dd/MM/yyyy') AS HK2_End,
    current_semester AS CurrentSemester,
    CASE 
        WHEN @TestDate BETWEEN semester1_start AND semester1_end THEN 1
        WHEN @TestDate BETWEEN semester2_start AND semester2_end THEN 2
        ELSE NULL
    END AS DetectedSemester
FROM school_years
WHERE school_year_id = @SchoolYearId;

-- ===========================================
-- BƯỚC 3: Chạy stored procedure chuyển học kỳ
-- ===========================================
PRINT '';
PRINT '🔄 BƯỚC 3: Chạy stored procedure chuyển học kỳ...';
PRINT '   (Lưu ý: Stored procedure sẽ dùng GETDATE() thực tế, không dùng @TestDate)';
PRINT '   ⚠️  Cần sửa stored procedure tạm thời hoặc dùng cách khác');

-- Vì stored procedure dùng GETDATE() thực tế, ta cần một cách khác
-- Option 1: Tạm thời sửa stored procedure (không khuyến nghị)
-- Option 2: Force update current_semester trực tiếp (để test UI)

PRINT '';
PRINT '💡 GIẢI PHÁP: Force update current_semester để test UI';
PRINT '   (Chỉ dùng cho test, không dùng trong production)';

-- Lưu current_semester hiện tại
DECLARE @OldSemester INT;
SELECT @OldSemester = current_semester
FROM school_years
WHERE school_year_id = @SchoolYearId;

PRINT CONCAT('   📊 Học kỳ hiện tại: ', ISNULL(CAST(@OldSemester AS VARCHAR), 'NULL'));

-- Force chuyển sang HK2 (nếu đang ở HK1)
IF @OldSemester = 1 OR @OldSemester IS NULL
BEGIN
    UPDATE school_years
    SET current_semester = 2,
        updated_at = GETDATE(),
        updated_by = 'test_force_transition'
    WHERE school_year_id = @SchoolYearId;
    
    PRINT '   ✅ Đã force chuyển sang HK2 (để test)';
    
    -- Tính GPA cho HK1 trước khi chuyển (nếu có)
    IF @OldSemester = 1
    BEGIN
        PRINT '   📊 Tính GPA cho HK1...';
        BEGIN TRY
            EXEC sp_CalculateAllStudentGPA 
                @AcademicYearId = @SchoolYearId,
                @Semester = 1,
                @CreatedBy = 'test_force_transition';
            PRINT '   ✅ Đã tính GPA cho HK1';
        END TRY
        BEGIN CATCH
            PRINT CONCAT('   ⚠️  Lỗi khi tính GPA: ', ERROR_MESSAGE());
        END CATCH
    END
END
ELSE
BEGIN
    PRINT CONCAT('   ℹ️  Đang ở HK', @OldSemester, ', không cần chuyển');
END

-- ===========================================
-- BƯỚC 4: Hiển thị kết quả
-- ===========================================
PRINT '';
PRINT '========================================';
PRINT '📊 KẾT QUẢ SAU KHI FORCE CHUYỂN HỌC KỲ';
PRINT '========================================';

SELECT 
    school_year_id AS NămHọcID,
    year_code AS MãNămHọc,
    current_semester AS HọcKỳHiệnTại,
    CASE 
        WHEN current_semester = 1 THEN N'Học kỳ 1'
        WHEN current_semester = 2 THEN N'Học kỳ 2'
        ELSE N'Chưa xác định'
    END AS TênHọcKỳ,
    FORMAT(semester1_start, 'dd/MM/yyyy') AS HK1_BắtĐầu,
    FORMAT(semester1_end, 'dd/MM/yyyy') AS HK1_KếtThúc,
    FORMAT(semester2_start, 'dd/MM/yyyy') AS HK2_BắtĐầu,
    FORMAT(semester2_end, 'dd/MM/yyyy') AS HK2_KếtThúc
FROM school_years
WHERE school_year_id = @SchoolYearId;

-- ===========================================
-- BƯỚC 5: Hướng dẫn khôi phục
-- ===========================================
PRINT '';
PRINT '========================================';
PRINT '📋 HƯỚNG DẪN KHÔI PHỤC';
PRINT '========================================';
PRINT 'Sau khi test xong, chạy script: SQL/Restore_SchoolYear_Dates.sql';
PRINT 'Hoặc chạy lệnh sau để khôi phục:';
PRINT '';
PRINT 'UPDATE school_years';
PRINT 'SET ';
PRINT '    semester1_start = (SELECT original_semester1_start FROM #OriginalSchoolYearDates WHERE school_year_id = school_years.school_year_id),';
PRINT '    semester1_end = (SELECT original_semester1_end FROM #OriginalSchoolYearDates WHERE school_year_id = school_years.school_year_id),';
PRINT '    semester2_start = (SELECT original_semester2_start FROM #OriginalSchoolYearDates WHERE school_year_id = school_years.school_year_id),';
PRINT '    semester2_end = (SELECT original_semester2_end FROM #OriginalSchoolYearDates WHERE school_year_id = school_years.school_year_id),';
PRINT '    current_semester = (SELECT original_current_semester FROM #OriginalSchoolYearDates WHERE school_year_id = school_years.school_year_id)';
PRINT 'WHERE school_year_id IN (SELECT school_year_id FROM #OriginalSchoolYearDates);';
PRINT '';
PRINT '========================================';
PRINT '✅ SCRIPT HOÀN TẤT';
PRINT '========================================';
PRINT 'Bây giờ bạn có thể test chuyển học kỳ trên UI!';
PRINT 'Học kỳ hiện tại đã được force chuyển sang HK2 (để test)';
GO

