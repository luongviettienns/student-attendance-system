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
-- 0.5. KIỂM TRA VÀ TẠO DỮ LIỆU CƠ BẢN (nếu chưa có)
-- ===========================================
PRINT '🔍 Kiểm tra dữ liệu cơ bản...';

-- Kiểm tra và tạo Faculty nếu chưa có
IF NOT EXISTS (SELECT 1 FROM faculties WHERE faculty_id = 'FAC001')
BEGIN
    INSERT INTO dbo.faculties (faculty_id, faculty_code, faculty_name, description, is_active) VALUES
    ('FAC001', 'CNTT', N'Công nghệ Thông tin', N'Khoa Công nghệ Thông tin', 1);
    PRINT '   ✅ Đã tạo FAC001';
END

-- Kiểm tra và tạo Department nếu chưa có
IF NOT EXISTS (SELECT 1 FROM departments WHERE department_id = 'DEPT001')
BEGIN
    IF EXISTS (SELECT 1 FROM faculties WHERE faculty_id = 'FAC001')
    BEGIN
        INSERT INTO dbo.departments (department_id, department_code, department_name, faculty_id, description) VALUES
        ('DEPT001', 'DEPT001', N'Khoa học Máy tính', 'FAC001', N'Bộ môn Khoa học Máy tính');
        PRINT '   ✅ Đã tạo DEPT001';
    END
    ELSE
    BEGIN
        PRINT '   ❌ Lỗi: FAC001 không tồn tại, không thể tạo DEPT001';
        RAISERROR('FAC001 must exist before creating DEPT001', 16, 1);
    END
END

-- Kiểm tra và tạo Academic Year nếu chưa có
IF NOT EXISTS (SELECT 1 FROM academic_years WHERE academic_year_id = 'AY2021')
BEGIN
    INSERT INTO dbo.academic_years (academic_year_id, year_name, cohort_code, start_year, end_year, duration_years, is_active, created_at, created_by)
    VALUES ('AY2021', '2021-2025', 'K21', 2021, 2025, 4, 0, GETDATE(), 'system');
    PRINT '   ✅ Đã tạo AY2021';
END

-- Kiểm tra và tạo Student STU001 nếu chưa có
IF NOT EXISTS (SELECT 1 FROM students WHERE student_id = 'STU001')
BEGIN
    -- Kiểm tra các dependencies
    IF NOT EXISTS (SELECT 1 FROM users WHERE user_id = 'USER003')
    BEGIN
        -- Tạo user nếu chưa có
        IF NOT EXISTS (SELECT 1 FROM roles WHERE role_id = 'ROLE_STUDENT')
        BEGIN
            INSERT INTO dbo.roles (role_id, role_name, description, is_active) VALUES
            ('ROLE_STUDENT', N'Student', N'Sinh viên', 1);
        END
        
        INSERT INTO dbo.users (user_id, username, password_hash, email, phone, full_name, role_id, is_active) VALUES
        ('USER003', 'student_k21_01', '$2a$10$Ya6MFL1CGpg2/y088u6t7.ACYkMJdmA1869rbBmAnyn6OQi0hTBue', 'student.k21.01@example.com', '0903333333', N'Lê Văn An', 'ROLE_STUDENT', 1);
        PRINT '   ✅ Đã tạo USER003';
    END
    
    IF NOT EXISTS (SELECT 1 FROM majors WHERE major_id = 'MAJ001')
    BEGIN
        IF EXISTS (SELECT 1 FROM faculties WHERE faculty_id = 'FAC001')
        BEGIN
            INSERT INTO dbo.majors (major_id, major_name, major_code, faculty_id, description) VALUES
            ('MAJ001', N'Công nghệ Phần mềm', 'SE', 'FAC001', N'Chuyên ngành Công nghệ Phần mềm');
            PRINT '   ✅ Đã tạo MAJ001';
        END
    END
    
    -- Tạo student
    IF EXISTS (SELECT 1 FROM academic_years WHERE academic_year_id = 'AY2021')
        AND EXISTS (SELECT 1 FROM users WHERE user_id = 'USER003')
        AND EXISTS (SELECT 1 FROM majors WHERE major_id = 'MAJ001')
    BEGIN
        INSERT INTO dbo.students (student_id, user_id, student_code, full_name, gender, date_of_birth, email, phone, major_id, academic_year_id, is_active) VALUES
        ('STU001', 'USER003', 'SV2021001', N'Lê Văn An', N'Nam', '2003-05-15', 'student.k21.01@example.com', '0903333333', 'MAJ001', 'AY2021', 1);
        PRINT '   ✅ Đã tạo STU001';
    END
    ELSE
    BEGIN
        PRINT '   ⚠️  Không thể tạo STU001: thiếu dependencies (AY2021, USER003, hoặc MAJ001)';
    END
END

-- Kiểm tra và tạo Lecturer LEC001 nếu chưa có
IF NOT EXISTS (SELECT 1 FROM lecturers WHERE lecturer_id = 'LEC001')
BEGIN
    IF NOT EXISTS (SELECT 1 FROM users WHERE user_id = 'USER002')
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM roles WHERE role_id = 'ROLE_LECTURER')
        BEGIN
            INSERT INTO dbo.roles (role_id, role_name, description, is_active) VALUES
            ('ROLE_LECTURER', N'Lecturer', N'Giảng viên', 1);
        END
        
        INSERT INTO dbo.users (user_id, username, password_hash, email, phone, full_name, role_id, is_active) VALUES
        ('USER002', 'lecturer01', '$2a$10$Ya6MFL1CGpg2/y088u6t7.ACYkMJdmA1869rbBmAnyn6OQi0hTBue', 'lecturer01@example.com', '0902222222', N'Trần Thị Hoa', 'ROLE_LECTURER', 1);
        PRINT '   ✅ Đã tạo USER002';
    END
    
    IF EXISTS (SELECT 1 FROM departments WHERE department_id = 'DEPT001')
        AND EXISTS (SELECT 1 FROM users WHERE user_id = 'USER002')
    BEGIN
        INSERT INTO dbo.lecturers (lecturer_id, lecturer_code, full_name, email, phone, department_id, user_id) VALUES
        ('LEC001', 'GV001', N'Trần Thị Hoa', 'lecturer01@example.com', '0902222222', 'DEPT001', 'USER002');
        PRINT '   ✅ Đã tạo LEC001';
    END
END
GO

-- ===========================================
-- 1. TẠO THÊM MÔN HỌC (nếu chưa có)
-- ===========================================
PRINT '📖 Tạo thêm môn học...';

-- Đảm bảo DEPT001 tồn tại
IF NOT EXISTS (SELECT 1 FROM departments WHERE department_id = 'DEPT001')
BEGIN
    PRINT '   ❌ Lỗi: DEPT001 không tồn tại, không thể tạo môn học';
    RAISERROR('DEPT001 must exist before creating subjects', 16, 1);
END
ELSE
BEGIN
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
END
GO

-- ===========================================
-- 2. TẠO CÁC NĂM HỌC (nếu chưa có)
-- ===========================================
PRINT '📅 Kiểm tra và tạo năm học...';

-- Đảm bảo AY2021 tồn tại
IF NOT EXISTS (SELECT 1 FROM academic_years WHERE academic_year_id = 'AY2021')
BEGIN
    PRINT '   ❌ Lỗi: AY2021 không tồn tại, không thể tạo năm học';
    RAISERROR('AY2021 must exist before creating school years', 16, 1);
END
ELSE
BEGIN
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
    ELSE
        PRINT '   ⚠️  Năm học 2021-2022 đã tồn tại';

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
    ELSE
        PRINT '   ⚠️  Năm học 2022-2023 đã tồn tại';

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
    ELSE
        PRINT '   ⚠️  Năm học 2023-2024 đã tồn tại';
END
GO

-- ===========================================
-- 3. TẠO LỚP HỌC CHO CÁC NĂM HỌC TRƯỚC
-- ===========================================
PRINT '🏫 Tạo lớp học cho các năm học...';

-- Đảm bảo các subjects cơ bản tồn tại (SUB001, SUB002, SUB003, SUB004)
IF NOT EXISTS (SELECT 1 FROM subjects WHERE subject_id = 'SUB001')
BEGIN
    IF EXISTS (SELECT 1 FROM departments WHERE department_id = 'DEPT001')
    BEGIN
        INSERT INTO dbo.subjects (subject_id, subject_code, subject_name, credits, department_id, description) VALUES
        ('SUB001', 'CS101', N'Lập trình C#', 3, 'DEPT001', N'Nhập môn lập trình C# - Năm 1'),
        ('SUB002', 'CS102', N'Cơ sở dữ liệu', 3, 'DEPT001', N'Hệ quản trị cơ sở dữ liệu - Năm 1'),
        ('SUB003', 'CS201', N'Cấu trúc dữ liệu', 4, 'DEPT001', N'Cấu trúc dữ liệu và giải thuật - Năm 2'),
        ('SUB004', 'CS301', N'Công nghệ Web', 4, 'DEPT001', N'Lập trình Web nâng cao - Năm 3');
        PRINT '   ✅ Đã tạo các môn học cơ bản (SUB001-SUB004)';
    END
END

-- Kiểm tra các dependencies trước khi tạo classes
IF EXISTS (SELECT 1 FROM subjects WHERE subject_id IN ('SUB001', 'SUB002', 'SUB003', 'SUB004', 'SUB005', 'SUB006', 'SUB007', 'SUB008'))
    AND EXISTS (SELECT 1 FROM lecturers WHERE lecturer_id = 'LEC001')
    AND EXISTS (SELECT 1 FROM academic_years WHERE academic_year_id = 'AY2021')
    AND EXISTS (SELECT 1 FROM school_years WHERE school_year_id IN ('SY2021', 'SY2022', 'SY2023'))
BEGIN
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
END
ELSE
BEGIN
    PRINT '   ⚠️  Không thể tạo lớp học: thiếu dependencies (subjects, lecturer, academic_year, hoặc school_years)';
END
GO

-- ===========================================
-- 4. TẠO ENROLLMENTS CHO SINH VIÊN STU001
-- ===========================================
PRINT '📝 Tạo enrollments cho STU001...';

-- Kiểm tra STU001 và các classes tồn tại
IF EXISTS (SELECT 1 FROM students WHERE student_id = 'STU001')
    AND EXISTS (SELECT 1 FROM classes WHERE class_id IN ('CLS-DEMO-2021-HK1-1', 'CLS-DEMO-2021-HK1-2', 'CLS-DEMO-2021-HK1-3', 
                                                          'CLS-DEMO-2021-HK2-1', 'CLS-DEMO-2021-HK2-2',
                                                          'CLS-DEMO-2022-HK1-1', 'CLS-DEMO-2022-HK1-2',
                                                          'CLS-DEMO-2022-HK2-1',
                                                          'CLS-DEMO-2023-HK1-1', 'CLS-DEMO-2023-HK1-2'))
BEGIN
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
END
ELSE
BEGIN
    PRINT '   ⚠️  Không thể tạo enrollments: STU001 hoặc các classes không tồn tại';
END
GO

-- ===========================================
-- 5. TẠO ĐIỂM CHO CÁC MÔN HỌC
-- ===========================================
PRINT '💯 Tạo điểm cho các môn học...';

-- Kiểm tra enrollments tồn tại
IF EXISTS (SELECT 1 FROM enrollments WHERE enrollment_id IN ('ENR-DEMO-2021-HK1-1', 'ENR-DEMO-2021-HK1-2', 'ENR-DEMO-2021-HK1-3',
                                                               'ENR-DEMO-2021-HK2-1', 'ENR-DEMO-2021-HK2-2',
                                                               'ENR-DEMO-2022-HK1-1', 'ENR-DEMO-2022-HK1-2',
                                                               'ENR-DEMO-2022-HK2-1',
                                                               'ENR-DEMO-2023-HK1-1', 'ENR-DEMO-2023-HK1-2'))
BEGIN
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
END
ELSE
BEGIN
    PRINT '   ⚠️  Không thể tạo điểm: enrollments không tồn tại';
END
GO

-- ===========================================
-- 6. TÍNH GPA CHO TỪNG HỌC KỲ/NĂM HỌC
-- ===========================================
PRINT '📊 Tính GPA cho từng học kỳ/năm học...';

-- Đảm bảo school_years có academic_year_id được set
UPDATE school_years 
SET academic_year_id = 'AY2021'
WHERE school_year_id IN ('SY2021', 'SY2022', 'SY2023')
  AND (academic_year_id IS NULL OR academic_year_id != 'AY2021');

-- Kiểm tra STU001 tồn tại và có academic_year_id
IF EXISTS (SELECT 1 FROM students WHERE student_id = 'STU001')
    AND EXISTS (SELECT 1 FROM school_years WHERE school_year_id IN ('SY2021', 'SY2022', 'SY2023') AND academic_year_id = 'AY2021')
BEGIN
    BEGIN TRY
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
    END TRY
    BEGIN CATCH
        PRINT CONCAT('   ❌ Lỗi khi tính GPA: ', ERROR_MESSAGE());
    END CATCH
END
ELSE
BEGIN
    PRINT '   ⚠️  Không thể tính GPA: STU001 hoặc school_years không tồn tại hoặc thiếu academic_year_id';
END
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

