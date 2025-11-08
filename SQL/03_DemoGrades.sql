-- ===========================================
-- 🎓 DEMO DATA: Tạo dữ liệu điểm đầy đủ cho 1 sinh viên
-- Mục đích: Demo tính điểm theo kỳ, theo năm, tích lũy
-- Sinh viên: STU001 (Lê Văn An - K21, năm 4)
-- ===========================================

USE EducationManagement;
GO

SET QUOTED_IDENTIFIER ON;
GO

PRINT '🎯 Bắt đầu tạo dữ liệu demo điểm cho sinh viên STU001...';
GO

-- ===========================================
-- 0. CLEANUP: Xóa dữ liệu demo cũ (nếu có)
-- ===========================================
PRINT '🧹 Dọn dẹp dữ liệu demo cũ...';

-- Xóa grades demo
DELETE FROM grades WHERE grade_id LIKE 'GRD-DEMO-%';
PRINT '   ✅ Đã xóa grades demo cũ';

-- Xóa enrollments demo
DELETE FROM enrollments WHERE enrollment_id LIKE 'ENR-DEMO-%';
PRINT '   ✅ Đã xóa enrollments demo cũ';

-- Xóa classes demo
DELETE FROM classes WHERE class_id LIKE 'CLS-DEMO-%';
PRINT '   ✅ Đã xóa classes demo cũ';

-- Xóa GPAs demo cho STU001
DELETE FROM gpas WHERE student_id = 'STU001' AND school_year_id IN ('SY2021', 'SY2022', 'SY2023');
PRINT '   ✅ Đã xóa GPAs demo cũ';
GO

-- ===========================================
-- 1. TẠO THÊM MÔN HỌC (nếu chưa có)
-- ===========================================
PRINT '📖 Tạo thêm môn học...';

IF NOT EXISTS (SELECT 1 FROM subjects WHERE subject_id = 'SUB005')
BEGIN
    INSERT INTO dbo.subjects (subject_id, subject_code, subject_name, credits, department_id, description) VALUES
    ('SUB005', 'MATH101', N'Toán cao cấp', 3, 'DEPT001', N'Toán cao cấp - Năm 1'),
    ('SUB006', 'ENG101', N'Tiếng Anh cơ bản', 2, 'DEPT001', N'Tiếng Anh cơ bản - Năm 1'),
    ('SUB007', 'CS202', N'Lập trình hướng đối tượng', 4, 'DEPT001', N'OOP - Năm 2'),
    ('SUB008', 'CS302', N'Đồ án phần mềm', 3, 'DEPT001', N'Đồ án - Năm 3');
    
    PRINT '   ✅ Đã tạo thêm 4 môn học';
END
ELSE
    PRINT '   ⚠️  Môn học đã tồn tại';
GO

-- ===========================================
-- 2. TẠO CÁC NĂM HỌC (nếu chưa có)
-- ===========================================
PRINT '📅 Kiểm tra và tạo năm học...';

-- Năm học 2021-2022 (Năm 1 của K21)
DECLARE @SY2021 VARCHAR(50) = 'SY2021';
IF NOT EXISTS (SELECT 1 FROM school_years WHERE school_year_id = @SY2021)
BEGIN
    INSERT INTO school_years (
        school_year_id, year_code, year_name, academic_year_id,
        start_date, end_date,
        semester1_start, semester1_end,
        semester2_start, semester2_end,
        is_active, current_semester, created_at)
    VALUES (
        @SY2021, 'SY2021', '2021-2022', 'AY2021',
        '2021-09-01', '2022-08-31',
        '2021-09-01', '2021-12-31',
        '2022-01-01', '2022-05-31',
        0, 1, GETDATE()
    );
    PRINT '   ✅ Đã tạo năm học 2021-2022';
END

-- Năm học 2022-2023 (Năm 2 của K21)
DECLARE @SY2022 VARCHAR(50) = 'SY2022';
IF NOT EXISTS (SELECT 1 FROM school_years WHERE school_year_id = @SY2022)
BEGIN
    INSERT INTO school_years (
        school_year_id, year_code, year_name, academic_year_id,
        start_date, end_date,
        semester1_start, semester1_end,
        semester2_start, semester2_end,
        is_active, current_semester, created_at)
    VALUES (
        @SY2022, 'SY2022', '2022-2023', 'AY2021',
        '2022-09-01', '2023-08-31',
        '2022-09-01', '2022-12-31',
        '2023-01-01', '2023-05-31',
        0, 1, GETDATE()
    );
    PRINT '   ✅ Đã tạo năm học 2022-2023';
END

-- Năm học 2023-2024 (Năm 3 của K21)
DECLARE @SY2023 VARCHAR(50) = 'SY2023';
IF NOT EXISTS (SELECT 1 FROM school_years WHERE school_year_id = @SY2023)
BEGIN
    INSERT INTO school_years (
        school_year_id, year_code, year_name, academic_year_id,
        start_date, end_date,
        semester1_start, semester1_end,
        semester2_start, semester2_end,
        is_active, current_semester, created_at)
    VALUES (
        @SY2023, 'SY2023', '2023-2024', 'AY2021',
        '2023-09-01', '2024-08-31',
        '2023-09-01', '2023-12-31',
        '2024-01-01', '2024-05-31',
        0, 1, GETDATE()
    );
    PRINT '   ✅ Đã tạo năm học 2023-2024';
END
GO

-- ===========================================
-- 3. TẠO LỚP HỌC CHO CÁC NĂM HỌC TRƯỚC
-- ===========================================
PRINT '🏫 Tạo lớp học cho các năm học...';

-- Năm 1 - HK1 2021-2022
IF NOT EXISTS (SELECT 1 FROM classes WHERE class_id = 'CLS-DEMO-2021-HK1-1')
BEGIN
    INSERT INTO dbo.classes (class_id, class_code, class_name, subject_id, lecturer_id, academic_year_id, school_year_id, semester, max_students, schedule, room) VALUES
    ('CLS-DEMO-2021-HK1-1', 'CS101-D21-HK1', N'Lập trình C# - Demo 2021-2022 HK1', 'SUB001', 'LEC001', 'AY2021', 'SY2021', 1, 40, N'Thứ 2, 7:00-9:00', 'A101'),
    ('CLS-DEMO-2021-HK1-2', 'CS102-D21-HK1', N'Cơ sở dữ liệu - Demo 2021-2022 HK1', 'SUB002', 'LEC001', 'AY2021', 'SY2021', 1, 40, N'Thứ 4, 7:00-9:00', 'A102'),
    ('CLS-DEMO-2021-HK1-3', 'MATH101-D21-H1', N'Toán cao cấp - Demo 2021-2022 HK1', 'SUB005', 'LEC001', 'AY2021', 'SY2021', 1, 50, N'Thứ 3, 7:00-9:00', 'B101');
    
    PRINT '   ✅ Đã tạo lớp học năm 1 HK1';
END

-- Năm 1 - HK2 2021-2022
IF NOT EXISTS (SELECT 1 FROM classes WHERE class_id = 'CLS-DEMO-2021-HK2-1')
BEGIN
    INSERT INTO dbo.classes (class_id, class_code, class_name, subject_id, lecturer_id, academic_year_id, school_year_id, semester, max_students, schedule, room) VALUES
    ('CLS-DEMO-2021-HK2-1', 'CS101-D21-HK2', N'Lập trình C# - Demo 2021-2022 HK2', 'SUB001', 'LEC001', 'AY2021', 'SY2021', 2, 40, N'Thứ 2, 7:00-9:00', 'A101'),
    ('CLS-DEMO-2021-HK2-2', 'ENG101-D21-H2', N'Tiếng Anh - Demo 2021-2022 HK2', 'SUB006', 'LEC001', 'AY2021', 'SY2021', 2, 60, N'Thứ 5, 7:00-9:00', 'C101');
    
    PRINT '   ✅ Đã tạo lớp học năm 1 HK2';
END

-- Năm 2 - HK1 2022-2023
IF NOT EXISTS (SELECT 1 FROM classes WHERE class_id = 'CLS-DEMO-2022-HK1-1')
BEGIN
    INSERT INTO dbo.classes (class_id, class_code, class_name, subject_id, lecturer_id, academic_year_id, school_year_id, semester, max_students, schedule, room) VALUES
    ('CLS-DEMO-2022-HK1-1', 'CS201-D22-HK1', N'Cấu trúc dữ liệu - Demo 2022-2023 HK1', 'SUB003', 'LEC001', 'AY2021', 'SY2022', 1, 35, N'Thứ 3, 13:00-15:00', 'B201'),
    ('CLS-DEMO-2022-HK1-2', 'CS202-D22-HK1', N'OOP - Demo 2022-2023 HK1', 'SUB007', 'LEC001', 'AY2021', 'SY2022', 1, 35, N'Thứ 4, 13:00-15:00', 'B202');
    
    PRINT '   ✅ Đã tạo lớp học năm 2 HK1';
END

-- Năm 2 - HK2 2022-2023
IF NOT EXISTS (SELECT 1 FROM classes WHERE class_id = 'CLS-DEMO-2022-HK2-1')
BEGIN
    INSERT INTO dbo.classes (class_id, class_code, class_name, subject_id, lecturer_id, academic_year_id, school_year_id, semester, max_students, schedule, room) VALUES
    ('CLS-DEMO-2022-HK2-1', 'CS201-D22-HK2', N'Cấu trúc dữ liệu - Demo 2022-2023 HK2', 'SUB003', 'LEC001', 'AY2021', 'SY2022', 2, 35, N'Thứ 3, 13:00-15:00', 'B201');
    
    PRINT '   ✅ Đã tạo lớp học năm 2 HK2';
END

-- Năm 3 - HK1 2023-2024
IF NOT EXISTS (SELECT 1 FROM classes WHERE class_id = 'CLS-DEMO-2023-HK1-1')
BEGIN
    INSERT INTO dbo.classes (class_id, class_code, class_name, subject_id, lecturer_id, academic_year_id, school_year_id, semester, max_students, schedule, room) VALUES
    ('CLS-DEMO-2023-HK1-1', 'CS301-D23-HK1', N'Công nghệ Web - Demo 2023-2024 HK1', 'SUB004', 'LEC001', 'AY2021', 'SY2023', 1, 30, N'Thứ 5, 15:00-17:00', 'C301'),
    ('CLS-DEMO-2023-HK1-2', 'CS302-D23-HK1', N'Đồ án phần mềm - Demo 2023-2024 HK1', 'SUB008', 'LEC001', 'AY2021', 'SY2023', 1, 25, N'Thứ 6, 15:00-17:00', 'C302');
    
    PRINT '   ✅ Đã tạo lớp học năm 3 HK1';
END
GO

-- ===========================================
-- 4. TẠO ENROLLMENTS CHO SINH VIÊN STU001
-- ===========================================
PRINT '📝 Tạo enrollments cho STU001...';

IF NOT EXISTS (SELECT 1 FROM enrollments WHERE enrollment_id = 'ENR-DEMO-2021-HK1-1')
BEGIN
    -- Năm 1 - HK1 2021-2022
    INSERT INTO dbo.enrollments (enrollment_id, student_id, class_id, status, enrollment_status, enrollment_date) VALUES
    ('ENR-DEMO-2021-HK1-1', 'STU001', 'CLS-DEMO-2021-HK1-1', N'Đã hoàn thành', 'APPROVED', '2021-09-01'),
    ('ENR-DEMO-2021-HK1-2', 'STU001', 'CLS-DEMO-2021-HK1-2', N'Đã hoàn thành', 'APPROVED', '2021-09-01'),
    ('ENR-DEMO-2021-HK1-3', 'STU001', 'CLS-DEMO-2021-HK1-3', N'Đã hoàn thành', 'APPROVED', '2021-09-01'),
    
    -- Năm 1 - HK2 2021-2022
    ('ENR-DEMO-2021-HK2-1', 'STU001', 'CLS-DEMO-2021-HK2-1', N'Đã hoàn thành', 'APPROVED', '2022-02-01'),
    ('ENR-DEMO-2021-HK2-2', 'STU001', 'CLS-DEMO-2021-HK2-2', N'Đã hoàn thành', 'APPROVED', '2022-02-01'),
    
    -- Năm 2 - HK1 2022-2023
    ('ENR-DEMO-2022-HK1-1', 'STU001', 'CLS-DEMO-2022-HK1-1', N'Đã hoàn thành', 'APPROVED', '2022-09-01'),
    ('ENR-DEMO-2022-HK1-2', 'STU001', 'CLS-DEMO-2022-HK1-2', N'Đã hoàn thành', 'APPROVED', '2022-09-01'),
    
    -- Năm 2 - HK2 2022-2023
    ('ENR-DEMO-2022-HK2-1', 'STU001', 'CLS-DEMO-2022-HK2-1', N'Đã hoàn thành', 'APPROVED', '2023-02-01'),
    
    -- Năm 3 - HK1 2023-2024
    ('ENR-DEMO-2023-HK1-1', 'STU001', 'CLS-DEMO-2023-HK1-1', N'Đã hoàn thành', 'APPROVED', '2023-09-01'),
    ('ENR-DEMO-2023-HK1-2', 'STU001', 'CLS-DEMO-2023-HK1-2', N'Đã hoàn thành', 'APPROVED', '2023-09-01');
    
    PRINT '   ✅ Đã tạo 10 enrollments';
END
ELSE
    PRINT '   ⚠️  Enrollments đã tồn tại';
GO

-- ===========================================
-- 5. TẠO ĐIỂM CHO CÁC MÔN HỌC
-- ===========================================
PRINT '💯 Tạo điểm cho các môn học...';

IF NOT EXISTS (SELECT 1 FROM grades WHERE grade_id = 'GRD-DEMO-2021-HK1-1')
BEGIN
    INSERT INTO dbo.grades (grade_id, enrollment_id, midterm_score, final_score, total_score, letter_grade) VALUES
    -- Năm 1 - HK1 2021-2022
    ('GRD-DEMO-2021-HK1-1', 'ENR-DEMO-2021-HK1-1', 8.0, 8.5, 8.3, 'A'),  -- CS101: 8.3
    ('GRD-DEMO-2021-HK1-2', 'ENR-DEMO-2021-HK1-2', 7.5, 8.0, 7.8, 'B'),  -- CS102: 7.8
    ('GRD-DEMO-2021-HK1-3', 'ENR-DEMO-2021-HK1-3', 9.0, 9.0, 9.0, 'A'),  -- MATH: 9.0
    
    -- Năm 1 - HK2 2021-2022
    ('GRD-DEMO-2021-HK2-1', 'ENR-DEMO-2021-HK2-1', 8.5, 9.0, 8.8, 'A'),  -- CS101 (HK2): 8.8
    ('GRD-DEMO-2021-HK2-2', 'ENR-DEMO-2021-HK2-2', 7.0, 7.5, 7.3, 'B'),  -- ENG: 7.3
    
    -- Năm 2 - HK1 2022-2023
    ('GRD-DEMO-2022-HK1-1', 'ENR-DEMO-2022-HK1-1', 8.0, 8.5, 8.3, 'A'),  -- CS201: 8.3
    ('GRD-DEMO-2022-HK1-2', 'ENR-DEMO-2022-HK1-2', 7.5, 8.0, 7.8, 'B'),  -- CS202: 7.8
    
    -- Năm 2 - HK2 2022-2023
    ('GRD-DEMO-2022-HK2-1', 'ENR-DEMO-2022-HK2-1', 9.0, 9.5, 9.3, 'A'),  -- CS201 (HK2): 9.3
    
    -- Năm 3 - HK1 2023-2024
    ('GRD-DEMO-2023-HK1-1', 'ENR-DEMO-2023-HK1-1', 8.5, 9.0, 8.8, 'A'),  -- CS301: 8.8
    ('GRD-DEMO-2023-HK1-2', 'ENR-DEMO-2023-HK1-2', 9.0, 9.0, 9.0, 'A');  -- CS302: 9.0
    
    PRINT '   ✅ Đã tạo 10 điểm';
END
ELSE
    PRINT '   ⚠️  Điểm đã tồn tại';
GO

-- ===========================================
-- 6. TÍNH GPA CHO TỪNG HỌC KỲ/NĂM HỌC
-- ===========================================
PRINT '📊 Tính GPA cho từng học kỳ/năm học...';

-- Năm 1 - HK1 2021-2022
EXEC sp_CalculateGPABySchoolYear @StudentId = 'STU001', @SchoolYearId = 'SY2021', @Semester = '1', @CreatedBy = 'system';
PRINT '   ✅ Đã tính GPA năm 1 HK1';

-- Năm 1 - HK2 2021-2022
EXEC sp_CalculateGPABySchoolYear @StudentId = 'STU001', @SchoolYearId = 'SY2021', @Semester = '2', @CreatedBy = 'system';
PRINT '   ✅ Đã tính GPA năm 1 HK2';

-- Năm 1 - Cả năm 2021-2022
EXEC sp_CalculateGPABySchoolYear @StudentId = 'STU001', @SchoolYearId = 'SY2021', @Semester = NULL, @CreatedBy = 'system';
PRINT '   ✅ Đã tính GPA năm 1 cả năm';

-- Năm 2 - HK1 2022-2023
EXEC sp_CalculateGPABySchoolYear @StudentId = 'STU001', @SchoolYearId = 'SY2022', @Semester = '1', @CreatedBy = 'system';
PRINT '   ✅ Đã tính GPA năm 2 HK1';

-- Năm 2 - HK2 2022-2023
EXEC sp_CalculateGPABySchoolYear @StudentId = 'STU001', @SchoolYearId = 'SY2022', @Semester = '2', @CreatedBy = 'system';
PRINT '   ✅ Đã tính GPA năm 2 HK2';

-- Năm 2 - Cả năm 2022-2023
EXEC sp_CalculateGPABySchoolYear @StudentId = 'STU001', @SchoolYearId = 'SY2022', @Semester = NULL, @CreatedBy = 'system';
PRINT '   ✅ Đã tính GPA năm 2 cả năm';

-- Năm 3 - HK1 2023-2024
EXEC sp_CalculateGPABySchoolYear @StudentId = 'STU001', @SchoolYearId = 'SY2023', @Semester = '1', @CreatedBy = 'system';
PRINT '   ✅ Đã tính GPA năm 3 HK1';

-- Năm 3 - Cả năm 2023-2024
EXEC sp_CalculateGPABySchoolYear @StudentId = 'STU001', @SchoolYearId = 'SY2023', @Semester = NULL, @CreatedBy = 'system';
PRINT '   ✅ Đã tính GPA năm 3 cả năm';
GO

-- ===========================================
-- 7. HIỂN THỊ KẾT QUẢ
-- ===========================================
PRINT '';
PRINT '╔════════════════════════════════════════════════╗';
PRINT '║     ✅ DEMO DATA CREATED SUCCESSFULLY         ║';
PRINT '╚════════════════════════════════════════════════╝';
PRINT '';
PRINT '📊 Tóm tắt dữ liệu demo cho STU001 (Lê Văn An - K21):';
PRINT '';
PRINT '   📚 Số môn học: 10 môn';
PRINT '   📅 Năm học: 3 năm (2021-2022, 2022-2023, 2023-2024)';
PRINT '   🎓 Học kỳ: 5 học kỳ (HK1 năm 1, HK2 năm 1, HK1 năm 2, HK2 năm 2, HK1 năm 3)';
PRINT '';
PRINT '📋 Chi tiết:';
PRINT '   • Năm 1 HK1: CS101 (8.3), CS102 (7.8), MATH101 (9.0)';
PRINT '   • Năm 1 HK2: CS101 (8.8), ENG101 (7.3)';
PRINT '   • Năm 2 HK1: CS201 (8.3), CS202 (7.8)';
PRINT '   • Năm 2 HK2: CS201 (9.3)';
PRINT '   • Năm 3 HK1: CS301 (8.8), CS302 (9.0)';
PRINT '';
PRINT '🎯 Bây giờ bạn có thể test:';
PRINT '   1. Xem điểm theo học kỳ (chọn từng HK1, HK2)';
PRINT '   2. Xem điểm theo năm học (chọn từng năm)';
PRINT '   3. Xem GPA tích lũy (từ tất cả các năm)';
PRINT '   4. Xem transcript (tất cả học kỳ)';
PRINT '';
PRINT '🔑 Đăng nhập: student_k21_01 / password123';
PRINT '';

-- Hiển thị GPA tích lũy (sử dụng stored procedure)
PRINT '📈 GPA Tích lũy:';
EXEC sp_GetCumulativeGPA @StudentId = 'STU001';
GO

-- Hiển thị transcript
PRINT '';
PRINT '📋 Transcript (Bảng điểm tổng hợp):';
EXEC sp_GetStudentTranscript @StudentId = 'STU001';
GO

