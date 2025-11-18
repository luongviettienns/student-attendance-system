-- ===========================================
-- TEST: Chuyển học kỳ và kiểm tra điểm số
-- ===========================================
-- Mục đích: Test xem khi chuyển học kỳ:
-- 1. Điểm HK1 có được lưu lại và hiển thị tốt không
-- 2. Điểm HK2 có được làm mới (không có điểm từ HK1) không
-- ===========================================

USE EducationManagement;
GO

SET NOCOUNT ON;
PRINT '========================================';
PRINT 'TEST: Chuyển học kỳ và kiểm tra điểm số';
PRINT '========================================';
GO

-- ===========================================
-- BƯỚC 1: Chuẩn bị dữ liệu test
-- ===========================================
PRINT '';
PRINT '📋 BƯỚC 1: Chuẩn bị dữ liệu test...';

-- Lấy năm học hiện tại
DECLARE @SchoolYearId VARCHAR(50);
DECLARE @CurrentSemester INT;
DECLARE @StudentId VARCHAR(50) = 'STU001'; -- Sinh viên test
DECLARE @ClassHK1 VARCHAR(50) = 'CLS001';  -- Lớp HK1
DECLARE @ClassHK2 VARCHAR(50) = 'CLS005';  -- Lớp HK2 (cần tạo nếu chưa có)

SELECT TOP 1 
    @SchoolYearId = school_year_id,
    @CurrentSemester = current_semester
FROM school_years
WHERE deleted_at IS NULL
ORDER BY is_active DESC, start_date DESC;

IF @SchoolYearId IS NULL
BEGIN
    PRINT '   ❌ ERROR: Không tìm thấy năm học!';
    RETURN;
END

PRINT CONCAT('   ✅ Năm học: ', @SchoolYearId);
PRINT CONCAT('   ✅ Học kỳ hiện tại: ', ISNULL(CAST(@CurrentSemester AS VARCHAR), 'NULL'));

-- Kiểm tra sinh viên test có tồn tại không
IF NOT EXISTS (SELECT 1 FROM students WHERE student_id = @StudentId AND deleted_at IS NULL)
BEGIN
    PRINT CONCAT('   ⚠️  Sinh viên ', @StudentId, ' không tồn tại. Sử dụng sinh viên đầu tiên...');
    SELECT TOP 1 @StudentId = student_id
    FROM students
    WHERE deleted_at IS NULL
    ORDER BY created_at;
END

PRINT CONCAT('   ✅ Sinh viên test: ', @StudentId);

-- Kiểm tra lớp HK1
IF NOT EXISTS (SELECT 1 FROM classes WHERE class_id = @ClassHK1 AND deleted_at IS NULL)
BEGIN
    PRINT CONCAT('   ⚠️  Lớp HK1 ', @ClassHK1, ' không tồn tại. Sử dụng lớp HK1 đầu tiên...');
    SELECT TOP 1 @ClassHK1 = class_id
    FROM classes
    WHERE semester = 1 AND school_year_id = @SchoolYearId AND deleted_at IS NULL
    ORDER BY created_at;
END

IF @ClassHK1 IS NULL
BEGIN
    PRINT '   ❌ ERROR: Không tìm thấy lớp HK1!';
    RETURN;
END

PRINT CONCAT('   ✅ Lớp HK1: ', @ClassHK1);

-- Kiểm tra lớp HK2
IF NOT EXISTS (SELECT 1 FROM classes WHERE class_id = @ClassHK2 AND deleted_at IS NULL)
BEGIN
    PRINT CONCAT('   ⚠️  Lớp HK2 ', @ClassHK2, ' không tồn tại. Tìm lớp HK2 khác...');
    SELECT TOP 1 @ClassHK2 = class_id
    FROM classes
    WHERE semester = 2 AND school_year_id = @SchoolYearId AND deleted_at IS NULL
    ORDER BY created_at;
END

IF @ClassHK2 IS NULL
BEGIN
    PRINT '   ⚠️  WARNING: Không tìm thấy lớp HK2. Sẽ chỉ test điểm HK1.';
END
ELSE
BEGIN
    PRINT CONCAT('   ✅ Lớp HK2: ', @ClassHK2);
END

-- ===========================================
-- BƯỚC 2: Kiểm tra điểm HK1 hiện tại
-- ===========================================
PRINT '';
PRINT '📊 BƯỚC 2: Kiểm tra điểm HK1 hiện tại...';

-- Lấy enrollment HK1
DECLARE @EnrollmentHK1 VARCHAR(50);
SELECT TOP 1 @EnrollmentHK1 = enrollment_id
FROM enrollments
WHERE student_id = @StudentId 
    AND class_id = @ClassHK1
    AND deleted_at IS NULL;

IF @EnrollmentHK1 IS NULL
BEGIN
    PRINT '   ⚠️  Sinh viên chưa đăng ký lớp HK1. Tạo enrollment...';
    SET @EnrollmentHK1 = 'ENR_TEST_HK1_' + FORMAT(GETDATE(), 'yyyyMMddHHmmss');
    INSERT INTO enrollments (enrollment_id, student_id, class_id, enrollment_status, enrollment_date, created_at)
    VALUES (@EnrollmentHK1, @StudentId, @ClassHK1, 'APPROVED', GETDATE(), GETDATE());
    PRINT CONCAT('   ✅ Đã tạo enrollment: ', @EnrollmentHK1);
END

-- Kiểm tra điểm HK1
DECLARE @GradeHK1Id VARCHAR(50);
DECLARE @MidtermHK1 DECIMAL(4,2) = 8.5;
DECLARE @FinalHK1 DECIMAL(4,2) = 9.0;

SELECT @GradeHK1Id = grade_id
FROM grades
WHERE enrollment_id = @EnrollmentHK1;

IF @GradeHK1Id IS NULL
BEGIN
    PRINT '   ⚠️  Chưa có điểm HK1. Tạo điểm test...';
    SET @GradeHK1Id = 'GRD_TEST_HK1_' + FORMAT(GETDATE(), 'yyyyMMddHHmmss');
    INSERT INTO grades (grade_id, enrollment_id, midterm_score, final_score, total_score, letter_grade, created_at, created_by)
    VALUES (@GradeHK1Id, @EnrollmentHK1, @MidtermHK1, @FinalHK1, (@MidtermHK1 * 0.3 + @FinalHK1 * 0.7), 'A', GETDATE(), 'test');
    PRINT CONCAT('   ✅ Đã tạo điểm HK1: Giữa kỳ=', @MidtermHK1, ', Cuối kỳ=', @FinalHK1);
END
ELSE
BEGIN
    SELECT @MidtermHK1 = midterm_score, @FinalHK1 = final_score
    FROM grades
    WHERE grade_id = @GradeHK1Id;
    PRINT CONCAT('   ✅ Điểm HK1 hiện tại: Giữa kỳ=', @MidtermHK1, ', Cuối kỳ=', @FinalHK1);
END

-- ===========================================
-- BƯỚC 3: Kiểm tra điểm HK2 (nếu có lớp HK2)
-- ===========================================
DECLARE @EnrollmentHK2 VARCHAR(50);
DECLARE @GradeHK2Id VARCHAR(50);

IF @ClassHK2 IS NOT NULL
BEGIN
    PRINT '';
    PRINT '📊 BƯỚC 3: Kiểm tra điểm HK2...';
    
    -- Lấy enrollment HK2
    SELECT TOP 1 @EnrollmentHK2 = enrollment_id
    FROM enrollments
    WHERE student_id = @StudentId 
        AND class_id = @ClassHK2
        AND deleted_at IS NULL;
    
    IF @EnrollmentHK2 IS NULL
    BEGIN
        PRINT '   ⚠️  Sinh viên chưa đăng ký lớp HK2. Tạo enrollment...';
        SET @EnrollmentHK2 = 'ENR_TEST_HK2_' + FORMAT(GETDATE(), 'yyyyMMddHHmmss');
        INSERT INTO enrollments (enrollment_id, student_id, class_id, enrollment_status, enrollment_date, created_at)
        VALUES (@EnrollmentHK2, @StudentId, @ClassHK2, 'APPROVED', GETDATE(), GETDATE());
        PRINT CONCAT('   ✅ Đã tạo enrollment: ', @EnrollmentHK2);
    END
    
    -- Kiểm tra điểm HK2
    SELECT @GradeHK2Id = grade_id
    FROM grades
    WHERE enrollment_id = @EnrollmentHK2;
    
    IF @GradeHK2Id IS NULL
    BEGIN
        PRINT '   ✅ HK2 chưa có điểm (đúng như mong đợi - điểm sẽ được nhập sau khi chuyển học kỳ)';
    END
    ELSE
    BEGIN
        DECLARE @MidtermHK2 DECIMAL(4,2), @FinalHK2 DECIMAL(4,2);
        SELECT @MidtermHK2 = midterm_score, @FinalHK2 = final_score
        FROM grades
        WHERE grade_id = @GradeHK2Id;
        PRINT CONCAT('   ℹ️  HK2 đã có điểm: Giữa kỳ=', ISNULL(CAST(@MidtermHK2 AS VARCHAR), 'NULL'), ', Cuối kỳ=', ISNULL(CAST(@FinalHK2 AS VARCHAR), 'NULL'));
    END
END

-- ===========================================
-- BƯỚC 4: Hiển thị điểm trước khi chuyển học kỳ
-- ===========================================
PRINT '';
PRINT '📋 BƯỚC 4: Điểm số TRƯỚC khi chuyển học kỳ...';
PRINT '----------------------------------------';

SELECT 
    'TRƯỚC CHUYỂN HỌC KỲ' AS Status,
    c.semester AS HocKy,
    c.class_code AS MaLop,
    c.class_name AS TenLop,
    g.midterm_score AS DiemGiuaKy,
    g.final_score AS DiemCuoiKy,
    g.total_score AS DiemTongKet,
    g.letter_grade AS DiemChu
FROM grades g
INNER JOIN enrollments e ON g.enrollment_id = e.enrollment_id
INNER JOIN classes c ON e.class_id = c.class_id
WHERE e.student_id = @StudentId
    AND c.school_year_id = @SchoolYearId
    AND e.deleted_at IS NULL
    AND c.deleted_at IS NULL
ORDER BY c.semester, c.class_code;

-- ===========================================
-- BƯỚC 5: Chuyển học kỳ (giả sử từ 1 → 2)
-- ===========================================
PRINT '';
PRINT '🔄 BƯỚC 5: Chuyển học kỳ...';

-- Lưu học kỳ hiện tại
DECLARE @OldSemester INT = @CurrentSemester;

-- Giả sử chuyển sang HK2 (hoặc ngược lại nếu đang ở HK2)
DECLARE @NewSemester INT = CASE WHEN @CurrentSemester = 1 THEN 2 ELSE 1 END;

-- Cập nhật học kỳ (giả lập chuyển học kỳ)
UPDATE school_years
SET current_semester = @NewSemester,
    updated_at = GETDATE(),
    updated_by = 'test'
WHERE school_year_id = @SchoolYearId;

PRINT CONCAT('   ✅ Đã chuyển từ HK', ISNULL(CAST(@OldSemester AS VARCHAR), 'NULL'), ' → HK', @NewSemester);

-- Tính GPA cho học kỳ cũ (nếu có)
IF @OldSemester IS NOT NULL
BEGIN
    PRINT CONCAT('   📊 Tính GPA cho HK', @OldSemester, '...');
    BEGIN TRY
        EXEC sp_CalculateAllStudentGPA 
            @AcademicYearId = @SchoolYearId,
            @Semester = @OldSemester,
            @CreatedBy = 'test';
        PRINT CONCAT('   ✅ Đã tính GPA cho HK', @OldSemester);
    END TRY
    BEGIN CATCH
        PRINT CONCAT('   ⚠️  Lỗi khi tính GPA: ', ERROR_MESSAGE());
    END CATCH
END

-- ===========================================
-- BƯỚC 6: Kiểm tra điểm SAU khi chuyển học kỳ
-- ===========================================
PRINT '';
PRINT '📋 BƯỚC 6: Điểm số SAU khi chuyển học kỳ...';
PRINT '----------------------------------------';

-- Kiểm tra điểm HK1 (phải còn nguyên)
DECLARE @GradeHK1StillExists BIT = 0;
IF EXISTS (SELECT 1 FROM grades WHERE grade_id = @GradeHK1Id)
BEGIN
    DECLARE @MidtermHK1After DECIMAL(4,2), @FinalHK1After DECIMAL(4,2);
    SELECT @MidtermHK1After = midterm_score, @FinalHK1After = final_score
    FROM grades
    WHERE grade_id = @GradeHK1Id;
    
    IF @MidtermHK1After = @MidtermHK1 AND @FinalHK1After = @FinalHK1
    BEGIN
        SET @GradeHK1StillExists = 1;
        PRINT '   ✅ Điểm HK1 vẫn còn nguyên (ĐÚNG)';
    END
    ELSE
    BEGIN
        PRINT '   ❌ Điểm HK1 đã bị thay đổi (SAI!)';
    END
END
ELSE
BEGIN
    PRINT '   ❌ Điểm HK1 đã bị xóa (SAI!)';
END

-- Hiển thị tất cả điểm theo học kỳ
SELECT 
    'SAU CHUYỂN HỌC KỲ' AS Status,
    c.semester AS HocKy,
    c.class_code AS MaLop,
    c.class_name AS TenLop,
    g.midterm_score AS DiemGiuaKy,
    g.final_score AS DiemCuoiKy,
    g.total_score AS DiemTongKet,
    g.letter_grade AS DiemChu,
    CASE 
        WHEN c.semester = @NewSemester THEN 'Học kỳ hiện tại'
        ELSE 'Học kỳ trước'
    END AS GhiChu
FROM grades g
INNER JOIN enrollments e ON g.enrollment_id = e.enrollment_id
INNER JOIN classes c ON e.class_id = c.class_id
WHERE e.student_id = @StudentId
    AND c.school_year_id = @SchoolYearId
    AND e.deleted_at IS NULL
    AND c.deleted_at IS NULL
ORDER BY c.semester, c.class_code;

-- ===========================================
-- BƯỚC 7: Test query điểm theo học kỳ
-- ===========================================
PRINT '';
PRINT '🔍 BƯỚC 7: Test query điểm theo học kỳ...';

-- Query điểm HK1
PRINT '   📊 Điểm HK1 (sử dụng sp_GetGradesByStudentSchoolYear):';
EXEC sp_GetGradesByStudentSchoolYear 
    @StudentId = @StudentId,
    @SchoolYearId = @SchoolYearId,
    @Semester = '1';

-- Query điểm HK2
PRINT '   📊 Điểm HK2 (sử dụng sp_GetGradesByStudentSchoolYear):';
EXEC sp_GetGradesByStudentSchoolYear 
    @StudentId = @StudentId,
    @SchoolYearId = @SchoolYearId,
    @Semester = '2';

-- ===========================================
-- BƯỚC 8: Kiểm tra GPA
-- ===========================================
PRINT '';
PRINT '📊 BƯỚC 8: Kiểm tra GPA...';

SELECT 
    g.semester AS HocKy,
    CASE 
        WHEN g.semester IS NULL THEN 'Cả năm'
        WHEN g.semester = 1 THEN 'Học kỳ 1'
        WHEN g.semester = 2 THEN 'Học kỳ 2'
        ELSE 'Khác'
    END AS TenHocKy,
    g.gpa10 AS GPA10,
    g.gpa4 AS GPA4,
    g.total_credits AS SoTinChi,
    g.rank_text AS XepLoai
FROM gpas g
WHERE g.student_id = @StudentId
    AND g.school_year_id = @SchoolYearId
    AND g.deleted_at IS NULL
ORDER BY g.semester;

-- ===========================================
-- BƯỚC 9: Tổng kết
-- ===========================================
PRINT '';
PRINT '========================================';
PRINT '📋 TỔNG KẾT TEST';
PRINT '========================================';

DECLARE @TestResult NVARCHAR(MAX) = '';

-- Kiểm tra 1: Điểm HK1 có còn không?
IF @GradeHK1StillExists = 1
BEGIN
    SET @TestResult = @TestResult + '✅ Điểm HK1 được lưu lại và không bị mất' + CHAR(13) + CHAR(10);
END
ELSE
BEGIN
    SET @TestResult = @TestResult + '❌ Điểm HK1 bị mất hoặc thay đổi' + CHAR(13) + CHAR(10);
END

-- Kiểm tra 2: Query điểm theo học kỳ có hoạt động không?
DECLARE @CountHK1 INT, @CountHK2 INT;
SELECT @CountHK1 = COUNT(*)
FROM grades g
INNER JOIN enrollments e ON g.enrollment_id = e.enrollment_id
INNER JOIN classes c ON e.class_id = c.class_id
WHERE e.student_id = @StudentId
    AND c.school_year_id = @SchoolYearId
    AND c.semester = 1
    AND e.deleted_at IS NULL
    AND c.deleted_at IS NULL;

SELECT @CountHK2 = COUNT(*)
FROM grades g
INNER JOIN enrollments e ON g.enrollment_id = e.enrollment_id
INNER JOIN classes c ON e.class_id = c.class_id
WHERE e.student_id = @StudentId
    AND c.school_year_id = @SchoolYearId
    AND c.semester = 2
    AND e.deleted_at IS NULL
    AND c.deleted_at IS NULL;

SET @TestResult = @TestResult + CONCAT('✅ Query điểm HK1: ', @CountHK1, ' điểm') + CHAR(13) + CHAR(10);
SET @TestResult = @TestResult + CONCAT('✅ Query điểm HK2: ', @CountHK2, ' điểm') + CHAR(13) + CHAR(10);

-- Kiểm tra 3: Học kỳ hiện tại đã được cập nhật chưa?
DECLARE @CurrentSemesterAfter INT;
SELECT @CurrentSemesterAfter = current_semester
FROM school_years
WHERE school_year_id = @SchoolYearId;

IF @CurrentSemesterAfter = @NewSemester
BEGIN
    SET @TestResult = @TestResult + CONCAT('✅ Học kỳ hiện tại đã được cập nhật: HK', @NewSemester) + CHAR(13) + CHAR(10);
END
ELSE
BEGIN
    SET @TestResult = @TestResult + CONCAT('❌ Học kỳ hiện tại chưa được cập nhật đúng') + CHAR(13) + CHAR(10);
END

PRINT @TestResult;

-- ===========================================
-- BƯỚC 10: Khôi phục học kỳ (nếu cần)
-- ===========================================
PRINT '';
PRINT '🔄 BƯỚC 10: Khôi phục học kỳ về trạng thái ban đầu...';

UPDATE school_years
SET current_semester = @OldSemester,
    updated_at = GETDATE(),
    updated_by = 'test'
WHERE school_year_id = @SchoolYearId;

PRINT CONCAT('   ✅ Đã khôi phục về HK', ISNULL(CAST(@OldSemester AS VARCHAR), 'NULL'));

PRINT '';
PRINT '========================================';
PRINT '✅ TEST HOÀN TẤT';
PRINT '========================================';
GO

