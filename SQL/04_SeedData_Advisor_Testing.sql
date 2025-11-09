-- ===========================================
-- 🎓 SEED DATA CHO TESTING CHỨC NĂNG CỐ VẤN (ADVISOR)
-- ===========================================
-- 
-- Mục đích: Tạo dữ liệu đầy đủ để test các chức năng của Advisor:
-- 1. Dashboard Stats (thống kê tổng quan)
-- 2. Warning Students (sinh viên cần cảnh báo)
-- 3. Student Detail (chi tiết sinh viên)
-- 4. Student Grades (điểm số)
-- 5. Student Attendance (điểm danh)
--
-- Các trường hợp test:
-- - Sinh viên có GPA cao (>= 3.5) - Excellent students
-- - Sinh viên có GPA thấp (< 2.0) - Low GPA warning
-- - Sinh viên có attendance tốt (> 80%)
-- - Sinh viên có attendance xấu (< 80%, > 20% absent) - Attendance warning
-- - Sinh viên có cả 2 vấn đề (GPA thấp + attendance xấu) - Both warnings
--
-- ===========================================

USE EducationManagement;
GO

SET QUOTED_IDENTIFIER ON;
GO

PRINT '🌱 Bắt đầu seed data cho Advisor testing...';
GO

-- ===========================================
-- 1. THÊM SINH VIÊN MỚI VỚI CÁC TRẠNG THÁI KHÁC NHAU
-- ===========================================
PRINT '👨‍🎓 Seeding Students for Advisor Testing...';

-- Lấy admin_class_id từ bảng có sẵn (hoặc NULL nếu không có)
DECLARE @AdminClassId1 VARCHAR(50) = (SELECT TOP 1 admin_class_id FROM administrative_classes WHERE deleted_at IS NULL ORDER BY created_at);
DECLARE @AdminClassId2 VARCHAR(50) = (SELECT TOP 1 admin_class_id FROM administrative_classes WHERE deleted_at IS NULL ORDER BY created_at DESC);
-- Nếu không có admin_class, dùng NULL (cho phép NULL trong FK)
IF @AdminClassId1 IS NULL SET @AdminClassId1 = NULL;
IF @AdminClassId2 IS NULL SET @AdminClassId2 = NULL;

-- Sinh viên có GPA cao (>= 3.5) - Excellent student
IF NOT EXISTS (SELECT 1 FROM users WHERE user_id = 'USER009')
BEGIN
    INSERT INTO dbo.users (user_id, username, password_hash, email, phone, full_name, role_id, is_active) VALUES
    ('USER009', 'student_excellent', '$2a$10$Ya6MFL1CGpg2/y088u6t7.ACYkMJdmA1869rbBmAnyn6OQi0hTBue', 'student.excellent@example.com', '0909999999', N'Nguyễn Thị Xuất Sắc', 'ROLE_STUDENT', 1);
END

IF NOT EXISTS (SELECT 1 FROM students WHERE student_id = 'STU006')
BEGIN
    INSERT INTO dbo.students (student_id, student_code, full_name, gender, date_of_birth, email, phone, address, faculty_id, major_id, admin_class_id, academic_year_id, user_id) VALUES
    ('STU006', 'SV2021006', N'Nguyễn Thị Xuất Sắc', N'Nữ', '2003-01-15', 'student.excellent@example.com', '0909999999', N'Hà Nội', 'FAC001', 'MAJ001', @AdminClassId1, 'AY2021', 'USER009');
END

-- Sinh viên có GPA thấp (< 2.0) - Low GPA warning
IF NOT EXISTS (SELECT 1 FROM users WHERE user_id = 'USER010')
BEGIN
    INSERT INTO dbo.users (user_id, username, password_hash, email, phone, full_name, role_id, is_active) VALUES
    ('USER010', 'student_low_gpa', '$2a$10$Ya6MFL1CGpg2/y088u6t7.ACYkMJdmA1869rbBmAnyn6OQi0hTBue', 'student.lowgpa@example.com', '0910000000', N'Trần Văn Yếu', 'ROLE_STUDENT', 1);
END

IF NOT EXISTS (SELECT 1 FROM students WHERE student_id = 'STU007')
BEGIN
    INSERT INTO dbo.students (student_id, student_code, full_name, gender, date_of_birth, email, phone, address, faculty_id, major_id, admin_class_id, academic_year_id, user_id) VALUES
    ('STU007', 'SV2022007', N'Trần Văn Yếu', N'Nam', '2004-02-20', 'student.lowgpa@example.com', '0910000000', N'Hà Nội', 'FAC001', 'MAJ001', @AdminClassId1, 'AY2022', 'USER010');
END

-- Sinh viên có attendance xấu (< 80%, > 20% absent) - Attendance warning
IF NOT EXISTS (SELECT 1 FROM users WHERE user_id = 'USER011')
BEGIN
    INSERT INTO dbo.users (user_id, username, password_hash, email, phone, full_name, role_id, is_active) VALUES
    ('USER011', 'student_bad_attendance', '$2a$10$Ya6MFL1CGpg2/y088u6t7.ACYkMJdmA1869rbBmAnyn6OQi0hTBue', 'student.badatt@example.com', '0911111111', N'Lê Thị Vắng Mặt', 'ROLE_STUDENT', 1);
END

IF NOT EXISTS (SELECT 1 FROM students WHERE student_id = 'STU008')
BEGIN
    INSERT INTO dbo.students (student_id, student_code, full_name, gender, date_of_birth, email, phone, address, faculty_id, major_id, admin_class_id, academic_year_id, user_id) VALUES
    ('STU008', 'SV2023008', N'Lê Thị Vắng Mặt', N'Nữ', '2005-03-25', 'student.badatt@example.com', '0911111111', N'Hà Nội', 'FAC001', 'MAJ001', @AdminClassId2, 'AY2023', 'USER011');
END

-- Sinh viên có CẢ 2 vấn đề (GPA thấp + attendance xấu) - Both warnings
IF NOT EXISTS (SELECT 1 FROM users WHERE user_id = 'USER012')
BEGIN
    INSERT INTO dbo.users (user_id, username, password_hash, email, phone, full_name, role_id, is_active) VALUES
    ('USER012', 'student_both_warnings', '$2a$10$Ya6MFL1CGpg2/y088u6t7.ACYkMJdmA1869rbBmAnyn6OQi0hTBue', 'student.both@example.com', '0912222222', N'Phạm Văn Cảnh Báo', 'ROLE_STUDENT', 1);
END

IF NOT EXISTS (SELECT 1 FROM students WHERE student_id = 'STU009')
BEGIN
    INSERT INTO dbo.students (student_id, student_code, full_name, gender, date_of_birth, email, phone, address, faculty_id, major_id, admin_class_id, academic_year_id, user_id) VALUES
    ('STU009', 'SV2024009', N'Phạm Văn Cảnh Báo', N'Nam', '2006-04-10', 'student.both@example.com', '0912222222', N'Hà Nội', 'FAC001', 'MAJ001', @AdminClassId2, 'AY2024', 'USER012');
END

-- Sinh viên bình thường (GPA OK, attendance OK)
IF NOT EXISTS (SELECT 1 FROM users WHERE user_id = 'USER013')
BEGIN
    INSERT INTO dbo.users (user_id, username, password_hash, email, phone, full_name, role_id, is_active) VALUES
    ('USER013', 'student_normal', '$2a$10$Ya6MFL1CGpg2/y088u6t7.ACYkMJdmA1869rbBmAnyn6OQi0hTBue', 'student.normal@example.com', '0913333333', N'Hoàng Thị Bình Thường', 'ROLE_STUDENT', 1);
END

IF NOT EXISTS (SELECT 1 FROM students WHERE student_id = 'STU010')
BEGIN
    INSERT INTO dbo.students (student_id, student_code, full_name, gender, date_of_birth, email, phone, address, faculty_id, major_id, admin_class_id, academic_year_id, user_id) VALUES
    ('STU010', 'SV2021010', N'Hoàng Thị Bình Thường', N'Nữ', '2003-05-15', 'student.normal@example.com', '0913333333', N'Hà Nội', 'FAC001', 'MAJ001', @AdminClassId1, 'AY2021', 'USER013');
END

PRINT '   ✅ 5 students created for testing';
GO

-- ===========================================
-- 2. THÊM ENROLLMENTS CHO CÁC SINH VIÊN MỚI
-- ===========================================
PRINT '📚 Seeding Enrollments for testing students...';

-- Lấy class_id từ các lớp hiện có (giả sử có ít nhất 1 lớp)
DECLARE @ClassId1 VARCHAR(50) = (SELECT TOP 1 class_id FROM classes WHERE deleted_at IS NULL ORDER BY created_at);

IF @ClassId1 IS NOT NULL
BEGIN
    -- Excellent student - enroll vào 1 lớp
    IF NOT EXISTS (SELECT 1 FROM enrollments WHERE student_id = 'STU006' AND class_id = @ClassId1)
    BEGIN
        INSERT INTO dbo.enrollments (enrollment_id, student_id, class_id, enrollment_date, status) VALUES
        ('ENR007', 'STU006', @ClassId1, GETDATE(), 'Enrolled');
    END
    
    -- Low GPA student - enroll vào 1 lớp
    IF NOT EXISTS (SELECT 1 FROM enrollments WHERE student_id = 'STU007' AND class_id = @ClassId1)
    BEGIN
        INSERT INTO dbo.enrollments (enrollment_id, student_id, class_id, enrollment_date, status) VALUES
        ('ENR008', 'STU007', @ClassId1, GETDATE(), 'Enrolled');
    END
    
    -- Bad attendance student - enroll vào 1 lớp
    IF NOT EXISTS (SELECT 1 FROM enrollments WHERE student_id = 'STU008' AND class_id = @ClassId1)
    BEGIN
        INSERT INTO dbo.enrollments (enrollment_id, student_id, class_id, enrollment_date, status) VALUES
        ('ENR009', 'STU008', @ClassId1, GETDATE(), 'Enrolled');
    END
    
    -- Both warnings student - enroll vào 1 lớp
    IF NOT EXISTS (SELECT 1 FROM enrollments WHERE student_id = 'STU009' AND class_id = @ClassId1)
    BEGIN
        INSERT INTO dbo.enrollments (enrollment_id, student_id, class_id, enrollment_date, status) VALUES
        ('ENR010', 'STU009', @ClassId1, GETDATE(), 'Enrolled');
    END
    
    -- Normal student - enroll vào 1 lớp
    IF NOT EXISTS (SELECT 1 FROM enrollments WHERE student_id = 'STU010' AND class_id = @ClassId1)
    BEGIN
        INSERT INTO dbo.enrollments (enrollment_id, student_id, class_id, enrollment_date, status) VALUES
        ('ENR011', 'STU010', @ClassId1, GETDATE(), 'Enrolled');
    END
    
    PRINT '   ✅ 5 enrollments created';
END
ELSE
BEGIN
    PRINT '   ⚠️  No classes found. Please run main seed data first.';
END
GO

-- ===========================================
-- 3. THÊM ĐIỂM SỐ (GRADES) ĐỂ TẠO CÁC TRƯỜNG HỢP GPA KHÁC NHAU
-- ===========================================
PRINT '📊 Seeding Grades for testing...';

-- Lấy enrollment_id và class_id từ enrollments vừa tạo (trong cùng batch)
DECLARE @EnrExcellent VARCHAR(50);
DECLARE @EnrLowGPA VARCHAR(50);
DECLARE @EnrBadAtt VARCHAR(50);
DECLARE @EnrBoth VARCHAR(50);
DECLARE @EnrNormal VARCHAR(50);
DECLARE @ClassIdForAtt VARCHAR(50);

SELECT @EnrExcellent = enrollment_id FROM enrollments WHERE student_id = 'STU006' AND deleted_at IS NULL;
SELECT @EnrLowGPA = enrollment_id FROM enrollments WHERE student_id = 'STU007' AND deleted_at IS NULL;
SELECT @EnrBadAtt = enrollment_id FROM enrollments WHERE student_id = 'STU008' AND deleted_at IS NULL;
SELECT @EnrBoth = enrollment_id FROM enrollments WHERE student_id = 'STU009' AND deleted_at IS NULL;
SELECT @EnrNormal = enrollment_id FROM enrollments WHERE student_id = 'STU010' AND deleted_at IS NULL;
SELECT @ClassIdForAtt = class_id FROM enrollments WHERE student_id = 'STU006' AND deleted_at IS NULL;

-- Excellent student: Điểm cao (GPA >= 3.5)
-- total_score = 9.2/10 -> GPA ~ 3.5/4.0
IF @EnrExcellent IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM grades WHERE enrollment_id = @EnrExcellent)
    BEGIN
        INSERT INTO dbo.grades (grade_id, enrollment_id, midterm_score, final_score, total_score) VALUES
        ('GRD007', @EnrExcellent, 9.0, 9.5, 9.2);
    END
END

-- Low GPA student: Điểm thấp (GPA < 2.0)
-- total_score = 3.8/10 -> GPA ~ 1.5/4.0
IF @EnrLowGPA IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM grades WHERE enrollment_id = @EnrLowGPA)
    BEGIN
        INSERT INTO dbo.grades (grade_id, enrollment_id, midterm_score, final_score, total_score) VALUES
        ('GRD008', @EnrLowGPA, 4.0, 3.5, 3.8);
    END
END

-- Bad attendance student: Điểm bình thường (GPA OK, nhưng attendance xấu)
-- total_score = 6.8/10 -> GPA ~ 2.7/4.0
IF @EnrBadAtt IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM grades WHERE enrollment_id = @EnrBadAtt)
    BEGIN
        INSERT INTO dbo.grades (grade_id, enrollment_id, midterm_score, final_score, total_score) VALUES
        ('GRD009', @EnrBadAtt, 7.0, 6.5, 6.8);
    END
END

-- Both warnings student: Điểm thấp (GPA < 2.0) + attendance xấu
-- total_score = 3.3/10 -> GPA ~ 1.3/4.0
IF @EnrBoth IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM grades WHERE enrollment_id = @EnrBoth)
    BEGIN
        INSERT INTO dbo.grades (grade_id, enrollment_id, midterm_score, final_score, total_score) VALUES
        ('GRD010', @EnrBoth, 3.5, 3.0, 3.3);
    END
END

-- Normal student: Điểm bình thường (GPA OK)
-- total_score = 7.3/10 -> GPA ~ 2.9/4.0
IF @EnrNormal IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM grades WHERE enrollment_id = @EnrNormal)
    BEGIN
        INSERT INTO dbo.grades (grade_id, enrollment_id, midterm_score, final_score, total_score) VALUES
        ('GRD011', @EnrNormal, 7.5, 7.0, 7.3);
    END
END

PRINT '   ✅ 5 grades created';
GO

-- ===========================================
-- 4. THÊM ĐIỂM DANH (ATTENDANCE) ĐỂ TẠO CÁC TRƯỜNG HỢP ATTENDANCE KHÁC NHAU
-- ===========================================
PRINT '📝 Seeding Attendance records for testing...';

-- Lấy lại enrollment_id và class_id
DECLARE @EnrExcellent2 VARCHAR(50);
DECLARE @EnrLowGPA2 VARCHAR(50);
DECLARE @EnrBadAtt2 VARCHAR(50);
DECLARE @EnrBoth2 VARCHAR(50);
DECLARE @EnrNormal2 VARCHAR(50);
DECLARE @ClassIdForAtt2 VARCHAR(50);

SELECT @EnrExcellent2 = enrollment_id, @ClassIdForAtt2 = class_id FROM enrollments WHERE student_id = 'STU006' AND deleted_at IS NULL;
SELECT @EnrLowGPA2 = enrollment_id FROM enrollments WHERE student_id = 'STU007' AND deleted_at IS NULL;
SELECT @EnrBadAtt2 = enrollment_id FROM enrollments WHERE student_id = 'STU008' AND deleted_at IS NULL;
SELECT @EnrBoth2 = enrollment_id FROM enrollments WHERE student_id = 'STU009' AND deleted_at IS NULL;
SELECT @EnrNormal2 = enrollment_id FROM enrollments WHERE student_id = 'STU010' AND deleted_at IS NULL;

-- Excellent student: Attendance tốt (> 80%)
-- 10 buổi: 9 Present, 1 Late -> 100% attendance
IF @EnrExcellent2 IS NOT NULL AND @ClassIdForAtt2 IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM attendances WHERE enrollment_id = @EnrExcellent2)
    BEGIN
        INSERT INTO dbo.attendances (attendance_id, enrollment_id, class_id, attendance_date, status, note) VALUES
        ('ATT007', @EnrExcellent2, @ClassIdForAtt2, DATEADD(day, -20, GETDATE()), 'Present', NULL),
        ('ATT008', @EnrExcellent2, @ClassIdForAtt2, DATEADD(day, -18, GETDATE()), 'Present', NULL),
        ('ATT009', @EnrExcellent2, @ClassIdForAtt2, DATEADD(day, -16, GETDATE()), 'Present', NULL),
        ('ATT010', @EnrExcellent2, @ClassIdForAtt2, DATEADD(day, -14, GETDATE()), 'Present', NULL),
        ('ATT011', @EnrExcellent2, @ClassIdForAtt2, DATEADD(day, -12, GETDATE()), 'Present', NULL),
        ('ATT012', @EnrExcellent2, @ClassIdForAtt2, DATEADD(day, -10, GETDATE()), 'Present', NULL),
        ('ATT013', @EnrExcellent2, @ClassIdForAtt2, DATEADD(day, -8, GETDATE()), 'Present', NULL),
        ('ATT014', @EnrExcellent2, @ClassIdForAtt2, DATEADD(day, -6, GETDATE()), 'Present', NULL),
        ('ATT015', @EnrExcellent2, @ClassIdForAtt2, DATEADD(day, -4, GETDATE()), 'Present', NULL),
        ('ATT016', @EnrExcellent2, @ClassIdForAtt2, DATEADD(day, -2, GETDATE()), 'Late', NULL);
    END
END

-- Low GPA student: Attendance tốt (> 80%) nhưng GPA thấp
-- 10 buổi: 8 Present, 2 Late -> 100% attendance
IF @EnrLowGPA2 IS NOT NULL AND @ClassIdForAtt2 IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM attendances WHERE enrollment_id = @EnrLowGPA2)
    BEGIN
        INSERT INTO dbo.attendances (attendance_id, enrollment_id, class_id, attendance_date, status, note) VALUES
        ('ATT017', @EnrLowGPA2, @ClassIdForAtt2, DATEADD(day, -20, GETDATE()), 'Present', NULL),
        ('ATT018', @EnrLowGPA2, @ClassIdForAtt2, DATEADD(day, -18, GETDATE()), 'Present', NULL),
        ('ATT019', @EnrLowGPA2, @ClassIdForAtt2, DATEADD(day, -16, GETDATE()), 'Present', NULL),
        ('ATT020', @EnrLowGPA2, @ClassIdForAtt2, DATEADD(day, -14, GETDATE()), 'Present', NULL),
        ('ATT021', @EnrLowGPA2, @ClassIdForAtt2, DATEADD(day, -12, GETDATE()), 'Present', NULL),
        ('ATT022', @EnrLowGPA2, @ClassIdForAtt2, DATEADD(day, -10, GETDATE()), 'Present', NULL),
        ('ATT023', @EnrLowGPA2, @ClassIdForAtt2, DATEADD(day, -8, GETDATE()), 'Present', NULL),
        ('ATT024', @EnrLowGPA2, @ClassIdForAtt2, DATEADD(day, -6, GETDATE()), 'Present', NULL),
        ('ATT025', @EnrLowGPA2, @ClassIdForAtt2, DATEADD(day, -4, GETDATE()), 'Late', NULL),
        ('ATT026', @EnrLowGPA2, @ClassIdForAtt2, DATEADD(day, -2, GETDATE()), 'Late', NULL);
    END
END

-- Bad attendance student: Attendance xấu (< 80%, > 20% absent)
-- 10 buổi: 5 Present, 1 Late, 4 Absent -> 60% attendance, 40% absent
IF @EnrBadAtt2 IS NOT NULL AND @ClassIdForAtt2 IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM attendances WHERE enrollment_id = @EnrBadAtt2)
    BEGIN
        INSERT INTO dbo.attendances (attendance_id, enrollment_id, class_id, attendance_date, status, note) VALUES
        ('ATT027', @EnrBadAtt2, @ClassIdForAtt2, DATEADD(day, -20, GETDATE()), 'Present', NULL),
        ('ATT028', @EnrBadAtt2, @ClassIdForAtt2, DATEADD(day, -18, GETDATE()), 'Absent', NULL),
        ('ATT029', @EnrBadAtt2, @ClassIdForAtt2, DATEADD(day, -16, GETDATE()), 'Present', NULL),
        ('ATT030', @EnrBadAtt2, @ClassIdForAtt2, DATEADD(day, -14, GETDATE()), 'Absent', NULL),
        ('ATT031', @EnrBadAtt2, @ClassIdForAtt2, DATEADD(day, -12, GETDATE()), 'Present', NULL),
        ('ATT032', @EnrBadAtt2, @ClassIdForAtt2, DATEADD(day, -10, GETDATE()), 'Absent', NULL),
        ('ATT033', @EnrBadAtt2, @ClassIdForAtt2, DATEADD(day, -8, GETDATE()), 'Present', NULL),
        ('ATT034', @EnrBadAtt2, @ClassIdForAtt2, DATEADD(day, -6, GETDATE()), 'Absent', NULL),
        ('ATT035', @EnrBadAtt2, @ClassIdForAtt2, DATEADD(day, -4, GETDATE()), 'Present', NULL),
        ('ATT036', @EnrBadAtt2, @ClassIdForAtt2, DATEADD(day, -2, GETDATE()), 'Late', NULL);
    END
END

-- Both warnings student: GPA thấp + Attendance xấu
-- 10 buổi: 4 Present, 1 Late, 5 Absent -> 50% attendance, 50% absent
IF @EnrBoth2 IS NOT NULL AND @ClassIdForAtt2 IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM attendances WHERE enrollment_id = @EnrBoth2)
    BEGIN
        INSERT INTO dbo.attendances (attendance_id, enrollment_id, class_id, attendance_date, status, note) VALUES
        ('ATT037', @EnrBoth2, @ClassIdForAtt2, DATEADD(day, -20, GETDATE()), 'Present', NULL),
        ('ATT038', @EnrBoth2, @ClassIdForAtt2, DATEADD(day, -18, GETDATE()), 'Absent', NULL),
        ('ATT039', @EnrBoth2, @ClassIdForAtt2, DATEADD(day, -16, GETDATE()), 'Absent', NULL),
        ('ATT040', @EnrBoth2, @ClassIdForAtt2, DATEADD(day, -14, GETDATE()), 'Present', NULL),
        ('ATT041', @EnrBoth2, @ClassIdForAtt2, DATEADD(day, -12, GETDATE()), 'Absent', NULL),
        ('ATT042', @EnrBoth2, @ClassIdForAtt2, DATEADD(day, -10, GETDATE()), 'Present', NULL),
        ('ATT043', @EnrBoth2, @ClassIdForAtt2, DATEADD(day, -8, GETDATE()), 'Absent', NULL),
        ('ATT044', @EnrBoth2, @ClassIdForAtt2, DATEADD(day, -6, GETDATE()), 'Absent', NULL),
        ('ATT045', @EnrBoth2, @ClassIdForAtt2, DATEADD(day, -4, GETDATE()), 'Present', NULL),
        ('ATT046', @EnrBoth2, @ClassIdForAtt2, DATEADD(day, -2, GETDATE()), 'Late', NULL);
    END
END

-- Normal student: Attendance tốt (> 80%)
-- 10 buổi: 8 Present, 2 Late -> 100% attendance
IF @EnrNormal2 IS NOT NULL AND @ClassIdForAtt2 IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM attendances WHERE enrollment_id = @EnrNormal2)
    BEGIN
        INSERT INTO dbo.attendances (attendance_id, enrollment_id, class_id, attendance_date, status, note) VALUES
        ('ATT047', @EnrNormal2, @ClassIdForAtt2, DATEADD(day, -20, GETDATE()), 'Present', NULL),
        ('ATT048', @EnrNormal2, @ClassIdForAtt2, DATEADD(day, -18, GETDATE()), 'Present', NULL),
        ('ATT049', @EnrNormal2, @ClassIdForAtt2, DATEADD(day, -16, GETDATE()), 'Present', NULL),
        ('ATT050', @EnrNormal2, @ClassIdForAtt2, DATEADD(day, -14, GETDATE()), 'Present', NULL),
        ('ATT051', @EnrNormal2, @ClassIdForAtt2, DATEADD(day, -12, GETDATE()), 'Present', NULL),
        ('ATT052', @EnrNormal2, @ClassIdForAtt2, DATEADD(day, -10, GETDATE()), 'Present', NULL),
        ('ATT053', @EnrNormal2, @ClassIdForAtt2, DATEADD(day, -8, GETDATE()), 'Present', NULL),
        ('ATT054', @EnrNormal2, @ClassIdForAtt2, DATEADD(day, -6, GETDATE()), 'Present', NULL),
        ('ATT055', @EnrNormal2, @ClassIdForAtt2, DATEADD(day, -4, GETDATE()), 'Late', NULL),
        ('ATT056', @EnrNormal2, @ClassIdForAtt2, DATEADD(day, -2, GETDATE()), 'Late', NULL);
    END
END

PRINT '   ✅ 50 attendance records created';
GO

-- ===========================================
-- 5. TẠO GPA RECORDS (OPTIONAL - NẾU HỆ THỐNG DÙNG BẢNG GPAS)
-- ===========================================
PRINT '📈 Seeding GPA records (if gpas table exists)...';

-- Check if gpas table exists
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'gpas')
BEGIN
    -- Lấy academic_year_id từ students (format: AY2021, AY2022, AY2023, AY2024)
    DECLARE @AcadYearK21 VARCHAR(50) = 'AY2021';
    DECLARE @AcadYearK22 VARCHAR(50) = 'AY2022';
    DECLARE @AcadYearK23 VARCHAR(50) = 'AY2023';
    DECLARE @AcadYearK24 VARCHAR(50) = 'AY2024';
    
    -- Excellent student: GPA 3.5
    IF NOT EXISTS (SELECT 1 FROM gpas WHERE student_id = 'STU006' AND (semester IS NULL OR semester = 0))
    BEGIN
        INSERT INTO dbo.gpas (gpa_id, student_id, academic_year_id, semester, gpa10, gpa4, created_at) VALUES
        ('GPA006', 'STU006', @AcadYearK21, 0, 8.75, 3.5, GETDATE());
    END
    
    -- Low GPA student: GPA 1.5
    IF NOT EXISTS (SELECT 1 FROM gpas WHERE student_id = 'STU007' AND (semester IS NULL OR semester = 0))
    BEGIN
        INSERT INTO dbo.gpas (gpa_id, student_id, academic_year_id, semester, gpa10, gpa4, created_at) VALUES
        ('GPA007', 'STU007', @AcadYearK22, 0, 3.75, 1.5, GETDATE());
    END
    
    -- Bad attendance student: GPA 2.7 (OK)
    IF NOT EXISTS (SELECT 1 FROM gpas WHERE student_id = 'STU008' AND (semester IS NULL OR semester = 0))
    BEGIN
        INSERT INTO dbo.gpas (gpa_id, student_id, academic_year_id, semester, gpa10, gpa4, created_at) VALUES
        ('GPA008', 'STU008', @AcadYearK23, 0, 6.75, 2.7, GETDATE());
    END
    
    -- Both warnings student: GPA 1.3
    IF NOT EXISTS (SELECT 1 FROM gpas WHERE student_id = 'STU009' AND (semester IS NULL OR semester = 0))
    BEGIN
        INSERT INTO dbo.gpas (gpa_id, student_id, academic_year_id, semester, gpa10, gpa4, created_at) VALUES
        ('GPA009', 'STU009', @AcadYearK24, 0, 3.25, 1.3, GETDATE());
    END
    
    -- Normal student: GPA 2.9 (OK)
    IF NOT EXISTS (SELECT 1 FROM gpas WHERE student_id = 'STU010' AND (semester IS NULL OR semester = 0))
    BEGIN
        INSERT INTO dbo.gpas (gpa_id, student_id, academic_year_id, semester, gpa10, gpa4, created_at) VALUES
        ('GPA010', 'STU010', @AcadYearK21, 0, 7.25, 2.9, GETDATE());
    END
    
    PRINT '   ✅ 5 GPA records created';
END
ELSE
BEGIN
    PRINT '   ⚠️  gpas table does not exist, skipping GPA records';
    PRINT '   → GPA will be calculated from grades table';
END
GO

PRINT '';
PRINT '╔════════════════════════════════════════════════╗';
PRINT '║  ✅ ADVISOR TESTING SEED DATA COMPLETED       ║';
PRINT '╚════════════════════════════════════════════════╝';
PRINT '';
PRINT '📊 Summary:';
PRINT '   ✅ 5 New Students created:';
PRINT '      👤 STU006 - Nguyễn Thị Xuất Sắc (Excellent: GPA >= 3.5, Attendance > 80%)';
PRINT '      👤 STU007 - Trần Văn Yếu (Low GPA: GPA < 2.0, Attendance OK)';
PRINT '      👤 STU008 - Lê Thị Vắng Mặt (Bad Attendance: < 80%, GPA OK)';
PRINT '      👤 STU009 - Phạm Văn Cảnh Báo (Both: GPA < 2.0 + Attendance < 80%)';
PRINT '      👤 STU010 - Hoàng Thị Bình Thường (Normal: GPA OK, Attendance OK)';
PRINT '';
PRINT '   ✅ 5 Enrollments created';
PRINT '   ✅ 5 Grades created (various scores)';
PRINT '   ✅ 50 Attendance records created (various patterns)';
PRINT '   ✅ 5 GPA records created (if gpas table exists)';
PRINT '';
PRINT '🔑 Test Accounts:';
PRINT '   👤 Excellent Student:  student_excellent / password123';
PRINT '   👤 Low GPA Student:   student_low_gpa / password123';
PRINT '   👤 Bad Attendance:    student_bad_attendance / password123';
PRINT '   👤 Both Warnings:     student_both_warnings / password123';
PRINT '   👤 Normal Student:    student_normal / password123';
PRINT '';
PRINT '📋 Test Cases for Advisor:';
PRINT '   1. Dashboard Stats:';
PRINT '      → Total students should include 5 new students';
PRINT '      → Warning attendance count: 2 (STU008, STU009)';
PRINT '      → Low GPA count: 2 (STU007, STU009)';
PRINT '      → Excellent students count: 1 (STU006)';
PRINT '';
PRINT '   2. Warning Students List:';
PRINT '      → Should show 3 students: STU007, STU008, STU009';
PRINT '      → STU009 should have priority (both warnings)';
PRINT '';
PRINT '   3. Student Detail:';
PRINT '      → Check each student has correct GPA and attendance rate';
PRINT '';
PRINT '   4. Filter by Faculty/Major/Class:';
PRINT '      → Test filtering functionality';
PRINT '';
GO
