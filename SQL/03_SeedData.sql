-- ===========================================
-- 🎓 HỆ THỐNG QUẢN LÝ ĐIỂM DANH SINH VIÊN
-- 📋 File 7: SEED DATA - UPDATED WITH COHORTS & SCHOOL YEARS
-- ===========================================
-- 
-- CẤU TRÚC MỚI:
-- - ACADEMIC YEARS = NIÊN KHÓA (4 năm): K21, K22, K23, K24
-- - SCHOOL YEARS = NĂM HỌC (1 năm = 2 học kỳ): 2024-2025
-- - SEMESTERS = HỌC KỲ: CHỈ CÓ HK1 (Sep-Jan) và HK2 (Feb-Jun)
--
-- ===========================================

USE EducationManagement;
GO

SET QUOTED_IDENTIFIER ON;
GO

PRINT '🌱 Bắt đầu seed data (updated with automation)...';
GO

-- ===========================================
-- CLEAR OLD DATA (OPTIONAL - Comment out if you want to keep existing data)
-- ===========================================
-- PRINT '🗑️  Clearing old data...';
-- DELETE FROM gpas;
-- DELETE FROM grades;
-- DELETE FROM enrollments;
-- DELETE FROM classes;
-- DELETE FROM school_years;
-- DELETE FROM students;
-- DELETE FROM lecturers;
-- DELETE FROM subjects;
-- DELETE FROM majors;
-- DELETE FROM departments;
-- DELETE FROM faculties;
-- DELETE FROM academic_years;
-- DELETE FROM role_permissions;
-- DELETE FROM permissions;
-- DELETE FROM users;
-- DELETE FROM roles;
-- PRINT '   ✅ Old data cleared';
-- GO

-- ===========================================
-- 1. ROLES (4 roles) - SAME AS BEFORE
-- ===========================================
PRINT '👥 Seeding Roles...';

IF NOT EXISTS (SELECT 1 FROM roles WHERE role_id = 'ROLE_ADMIN')
BEGIN
    INSERT INTO dbo.roles (role_id, role_name, description, is_active) VALUES
    ('ROLE_ADMIN', N'Admin', N'Quản trị viên hệ thống', 1),
    ('ROLE_LECTURER', N'Lecturer', N'Giảng viên', 1),
    ('ROLE_STUDENT', N'Student', N'Sinh viên', 1),
    ('ROLE_ADVISOR', N'Advisor', N'Cố vấn học tập', 1);
    PRINT '   ✅ 4 roles created';
END
ELSE
    PRINT '   ⚠️  Roles already exist';
GO

-- ===========================================
-- 2. USERS - UPDATED
-- ===========================================
PRINT '👤 Seeding Users...';

IF NOT EXISTS (SELECT 1 FROM users WHERE user_id = 'USER001')
BEGIN
    -- Password: "password123" 
    -- BCrypt hash: $2b$12$8HoLKV3tszmWbxEa1OWy8u973bS4UCVLXd3JJQ9JaF0vXFaQyKydK
    INSERT INTO dbo.users (user_id, username, password_hash, email, phone, full_name, role_id, is_active) VALUES
    ('USER001', 'admin', '$2b$12$8HoLKV3tszmWbxEa1OWy8u973bS4UCVLXd3JJQ9JaF0vXFaQyKydK', 'admin@example.com', '0901234567', N'Nguyễn Văn Admin', 'ROLE_ADMIN', 1),
    ('USER002', 'lecturer01', '$2b$12$8HoLKV3tszmWbxEa1OWy8u973bS4UCVLXd3JJQ9JaF0vXFaQyKydK', 'lecturer01@example.com', '0902222222', N'Trần Thị Hoa', 'ROLE_LECTURER', 1),
    ('USER003', 'student_k21_01', '$2b$12$8HoLKV3tszmWbxEa1OWy8u973bS4UCVLXd3JJQ9JaF0vXFaQyKydK', 'student.k21.01@example.com', '0903333333', N'Lê Văn An', 'ROLE_STUDENT', 1),
    ('USER004', 'student_k21_02', '$2b$12$8HoLKV3tszmWbxEa1OWy8u973bS4UCVLXd3JJQ9JaF0vXFaQyKydK', 'student.k21.02@example.com', '0904444444', N'Phạm Thị Bình', 'ROLE_STUDENT', 1),
    ('USER005', 'student_k22_01', '$2b$12$8HoLKV3tszmWbxEa1OWy8u973bS4UCVLXd3JJQ9JaF0vXFaQyKydK', 'student.k22.01@example.com', '0905555555', N'Nguyễn Văn Cường', 'ROLE_STUDENT', 1),
    ('USER006', 'student_k23_01', '$2b$12$8HoLKV3tszmWbxEa1OWy8u973bS4UCVLXd3JJQ9JaF0vXFaQyKydK', 'student.k23.01@example.com', '0906666666', N'Hoàng Thị Dung', 'ROLE_STUDENT', 1),
    ('USER007', 'student_k24_01', '$2b$12$8HoLKV3tszmWbxEa1OWy8u973bS4UCVLXd3JJQ9JaF0vXFaQyKydK', 'student.k24.01@example.com', '0907777777', N'Đinh Văn Em', 'ROLE_STUDENT', 1);
    
    PRINT '   ✅ 7 users created (1 admin, 1 lecturer, 5 students from different cohorts)';
END
ELSE
    PRINT '   ⚠️  Users already exist';
GO

-- ===========================================
-- 3. FACULTIES (1 faculty)
-- ===========================================
PRINT '🏛️  Seeding Faculties...';

IF NOT EXISTS (SELECT 1 FROM faculties WHERE faculty_id = 'FAC001')
BEGIN
    INSERT INTO dbo.faculties (faculty_id, faculty_code, faculty_name, description, is_active) VALUES
    ('FAC001', 'CNTT', N'Công nghệ Thông tin', N'Khoa Công nghệ Thông tin', 1);
    PRINT '   ✅ 1 faculty created';
END
ELSE
    PRINT '   ⚠️  Faculty already exists';
GO

-- ===========================================
-- 4. DEPARTMENTS (2 departments)
-- ===========================================
PRINT '🏢 Seeding Departments...';

IF NOT EXISTS (SELECT 1 FROM departments WHERE department_id = 'DEPT001')
BEGIN
    INSERT INTO dbo.departments (department_id, department_code, department_name, faculty_id, description) VALUES
    ('DEPT001', 'DEPT001', N'Khoa học Máy tính', 'FAC001', N'Bộ môn Khoa học Máy tính'),
    ('DEPT002', 'DEPT002', N'Hệ thống Thông tin', 'FAC001', N'Bộ môn Hệ thống Thông tin');
    PRINT '   ✅ 2 departments created';
END
ELSE
    PRINT '   ⚠️  Departments already exist';
GO

-- ===========================================
-- 5. MAJORS (2 majors)
-- ===========================================
PRINT '📚 Seeding Majors...';

IF NOT EXISTS (SELECT 1 FROM majors WHERE major_id = 'MAJ001')
BEGIN
    INSERT INTO dbo.majors (major_id, major_name, major_code, faculty_id, description) VALUES
    ('MAJ001', N'Công nghệ Phần mềm', 'SE', 'FAC001', N'Chuyên ngành Công nghệ Phần mềm'),
    ('MAJ002', N'Khoa học Dữ liệu', 'DS', 'FAC001', N'Chuyên ngành Khoa học Dữ liệu');
    PRINT '   ✅ 2 majors created';
END
ELSE
    PRINT '   ⚠️  Majors already exist';
GO

-- ===========================================
-- 6. ACADEMIC YEARS (NIÊN KHÓA) - 4 COHORTS
-- ===========================================
PRINT '📅 Seeding Academic Years (Cohorts - 4 years each)...';

-- Use stored procedure to auto-create cohorts
BEGIN TRY
    -- K21: 2021-2025
    EXEC sp_AutoCreateCohort @StartYear = 2021, @DurationYears = 4, @CreatedBy = 'system';
    
    -- K22: 2022-2026
    EXEC sp_AutoCreateCohort @StartYear = 2022, @DurationYears = 4, @CreatedBy = 'system';
    
    -- K23: 2023-2027
    EXEC sp_AutoCreateCohort @StartYear = 2023, @DurationYears = 4, @CreatedBy = 'system';
    
    -- K24: 2024-2028
    EXEC sp_AutoCreateCohort @StartYear = 2024, @DurationYears = 4, @CreatedBy = 'system';
    
    PRINT '   ✅ 4 cohorts created (K21, K22, K23, K24) with 16 school years total';
END TRY
BEGIN CATCH
    PRINT '   ⚠️  Cohorts may already exist: ' + ERROR_MESSAGE();
END CATCH
GO

-- Activate current school year (2024-2025)
UPDATE school_years 
SET is_active = 1, 
    current_semester = 1  -- Assume we're in Semester 1
WHERE school_year_id = 'SY2024';

PRINT '   ✅ Activated school year 2024-2025 (Semester 1)';
GO

-- ===========================================
-- 7. LECTURERS (1 lecturer)
-- ===========================================
PRINT '👨‍🏫 Seeding Lecturers...';

IF NOT EXISTS (SELECT 1 FROM lecturers WHERE lecturer_id = 'LEC001')
BEGIN
    INSERT INTO dbo.lecturers (lecturer_id, lecturer_code, full_name, email, phone, department_id, user_id) VALUES
    ('LEC001', 'GV001', N'Trần Thị Hoa', 'lecturer01@example.com', '0902222222', 'DEPT001', 'USER002');
    PRINT '   ✅ 1 lecturer created';
END
ELSE
    PRINT '   ⚠️  Lecturer already exists';
GO

-- ===========================================
-- 8. STUDENTS - DISTRIBUTED ACROSS COHORTS
-- ===========================================
PRINT '👨‍🎓 Seeding Students (5 students from K21, K22, K23, K24)...';

IF NOT EXISTS (SELECT 1 FROM students WHERE student_id = 'STU001')
BEGIN
    INSERT INTO dbo.students (student_id, user_id, student_code, full_name, gender, date_of_birth, email, phone, major_id, academic_year_id, is_active) VALUES
    -- K21 students (2021-2025) - Year 4 now
    ('STU001', 'USER003', 'SV2021001', N'Lê Văn An', N'Nam', '2003-05-15', 'student.k21.01@example.com', '0903333333', 'MAJ001', 'AY2021', 1),
    ('STU002', 'USER004', 'SV2021002', N'Phạm Thị Bình', N'Nữ', '2003-08-20', 'student.k21.02@example.com', '0904444444', 'MAJ001', 'AY2021', 1),
    
    -- K22 student (2022-2026) - Year 3 now
    ('STU003', 'USER005', 'SV2022001', N'Nguyễn Văn Cường', N'Nam', '2004-03-10', 'student.k22.01@example.com', '0905555555', 'MAJ002', 'AY2022', 1),
    
    -- K23 student (2023-2027) - Year 2 now
    ('STU004', 'USER006', 'SV2023001', N'Hoàng Thị Dung', N'Nữ', '2005-07-25', 'student.k23.01@example.com', '0906666666', 'MAJ001', 'AY2023', 1),
    
    -- K24 student (2024-2028) - Year 1 now (freshman)
    ('STU005', 'USER007', 'SV2024001', N'Đinh Văn Em', N'Nam', '2006-11-30', 'student.k24.01@example.com', '0907777777', 'MAJ002', 'AY2024', 1);
    
    PRINT '   ✅ 5 students created (2 from K21, 1 from K22, 1 from K23, 1 from K24)';
END
ELSE
    PRINT '   ⚠️  Students already exist';
GO

-- ===========================================
-- 9. SUBJECTS (4 subjects - for different years)
-- ===========================================
PRINT '📖 Seeding Subjects...';

IF NOT EXISTS (SELECT 1 FROM subjects WHERE subject_id = 'SUB001')
BEGIN
    INSERT INTO dbo.subjects (subject_id, subject_code, subject_name, credits, department_id, description) VALUES
    ('SUB001', 'CS101', N'Lập trình C#', 3, 'DEPT001', N'Nhập môn lập trình C# - Năm 1'),
    ('SUB002', 'CS102', N'Cơ sở dữ liệu', 3, 'DEPT001', N'Hệ quản trị cơ sở dữ liệu - Năm 1'),
    ('SUB003', 'CS201', N'Cấu trúc dữ liệu', 4, 'DEPT001', N'Cấu trúc dữ liệu và giải thuật - Năm 2'),
    ('SUB004', 'CS301', N'Công nghệ Web', 4, 'DEPT001', N'Lập trình Web nâng cao - Năm 3');
    PRINT '   ✅ 4 subjects created';
END
ELSE
    PRINT '   ⚠️  Subjects already exist';
GO

-- ===========================================
-- 10. CLASSES - FOR SCHOOL YEAR 2024-2025 (SEMESTER 1)
-- ===========================================
PRINT '🏫 Seeding Classes (School Year 2024-2025, Semester 1)...';

IF NOT EXISTS (SELECT 1 FROM classes WHERE class_id = 'CLS001')
BEGIN
    -- Link to NEW school_year_id instead of old academic_year_id
    INSERT INTO dbo.classes (class_id, class_code, class_name, subject_id, lecturer_id, academic_year_id, school_year_id, semester, max_students, schedule, room) VALUES
    -- Semester 1 classes for 2024-2025
    ('CLS001', 'CS101-01-2024', N'Lập trình C# - Lớp 01 (2024-2025 HK1)', 'SUB001', 'LEC001', 'AY2024', 'SY2024', 1, 40, N'Thứ 2, 7:00-9:00', 'A101'),
    ('CLS002', 'CS102-01-2024', N'Cơ sở dữ liệu - Lớp 01 (2024-2025 HK1)', 'SUB002', 'LEC001', 'AY2024', 'SY2024', 1, 40, N'Thứ 4, 7:00-9:00', 'A102'),
    ('CLS003', 'CS201-01-2024', N'Cấu trúc dữ liệu - Lớp 01 (2024-2025 HK1)', 'SUB003', 'LEC001', 'AY2023', 'SY2024', 1, 35, N'Thứ 3, 13:00-15:00', 'B201'),
    ('CLS004', 'CS301-01-2024', N'Công nghệ Web - Lớp 01 (2024-2025 HK1)', 'SUB004', 'LEC001', 'AY2022', 'SY2024', 1, 30, N'Thứ 5, 15:00-17:00', 'C301');
    
    PRINT '   ✅ 4 classes created for 2024-2025 Semester 1';
END
ELSE
    PRINT '   ⚠️  Classes already exist';
GO

-- ===========================================
-- 11. ENROLLMENTS - Students register for classes
-- ===========================================
PRINT '📝 Seeding Enrollments...';

IF NOT EXISTS (SELECT 1 FROM enrollments WHERE enrollment_id = 'ENR001')
BEGIN
    INSERT INTO dbo.enrollments (enrollment_id, student_id, class_id, status, enrollment_date) VALUES
    -- K24 student (freshman) takes year 1 courses
    ('ENR001', 'STU005', 'CLS001', N'Đang học', GETDATE()),  -- CS101
    ('ENR002', 'STU005', 'CLS002', N'Đang học', GETDATE()),  -- CS102
    
    -- K23 student (year 2) takes year 2 course
    ('ENR003', 'STU004', 'CLS003', N'Đang học', GETDATE()),  -- CS201
    
    -- K22 student (year 3) takes year 3 course
    ('ENR004', 'STU003', 'CLS004', N'Đang học', GETDATE()),  -- CS301
    
    -- K21 students (year 4) also take some courses
    ('ENR005', 'STU001', 'CLS004', N'Đang học', GETDATE()),  -- CS301
    ('ENR006', 'STU002', 'CLS003', N'Đang học', GETDATE());  -- CS201
    
    PRINT '   ✅ 6 enrollments created';
END
ELSE
    PRINT '   ⚠️  Enrollments already exist';
GO

-- ===========================================
-- 12. GRADES - Sample grades for current semester
-- ===========================================
PRINT '💯 Seeding Grades...';

IF NOT EXISTS (SELECT 1 FROM grades WHERE grade_id = 'GRD001')
BEGIN
    INSERT INTO dbo.grades (grade_id, enrollment_id, midterm_score, final_score, total_score, letter_grade) VALUES
    ('GRD001', 'ENR001', 8.5, 9.0, 8.8, 'A'),
    ('GRD002', 'ENR002', 7.0, 7.5, 7.3, 'B'),
    ('GRD003', 'ENR003', 9.0, 9.5, 9.3, 'A'),
    ('GRD004', 'ENR004', 6.5, 7.0, 6.8, 'C'),
    ('GRD005', 'ENR005', 8.0, 8.5, 8.3, 'A'),
    ('GRD006', 'ENR006', 7.5, 8.0, 7.8, 'B');
    
    PRINT '   ✅ 6 grades created';
END
ELSE
    PRINT '   ⚠️  Grades already exist';
GO

-- ===========================================
-- 13. PERMISSIONS (Essential permissions only)
-- ===========================================
PRINT '🔐 Seeding Permissions...';

IF NOT EXISTS (SELECT 1 FROM permissions WHERE permission_id = 'PERM001')
BEGIN
    INSERT INTO dbo.permissions (permission_id, permission_code, permission_name, description) VALUES
    ('PERM001', 'USER_VIEW', N'Xem người dùng', N'Xem danh sách người dùng'),
    ('PERM002', 'USER_CREATE', N'Tạo người dùng', N'Tạo người dùng mới'),
    ('PERM003', 'USER_UPDATE', N'Sửa người dùng', N'Cập nhật thông tin người dùng'),
    ('PERM004', 'USER_DELETE', N'Xóa người dùng', N'Xóa người dùng'),
    ('PERM005', 'STUDENT_VIEW', N'Xem sinh viên', N'Xem danh sách sinh viên'),
    ('PERM006', 'STUDENT_MANAGE', N'Quản lý sinh viên', N'Thêm/sửa/xóa sinh viên'),
    ('PERM007', 'CLASS_VIEW', N'Xem lớp học', N'Xem danh sách lớp học'),
    ('PERM008', 'CLASS_MANAGE', N'Quản lý lớp học', N'Thêm/sửa/xóa lớp học'),
    ('PERM009', 'GRADE_VIEW', N'Xem điểm', N'Xem điểm sinh viên'),
    ('PERM010', 'GRADE_MANAGE', N'Quản lý điểm', N'Nhập/sửa điểm');
    
    PRINT '   ✅ 10 permissions created';
END
ELSE
    PRINT '   ⚠️  Permissions already exist';
GO

-- ===========================================
-- 14. ROLE_PERMISSIONS
-- ===========================================
PRINT '🔗 Assigning Permissions to Roles...';

IF NOT EXISTS (SELECT 1 FROM role_permissions WHERE role_id = 'ROLE_ADMIN' AND permission_id = 'PERM001')
BEGIN
    -- Admin: All permissions
    INSERT INTO dbo.role_permissions (role_id, permission_id) VALUES
    ('ROLE_ADMIN', 'PERM001'), ('ROLE_ADMIN', 'PERM002'), ('ROLE_ADMIN', 'PERM003'),
    ('ROLE_ADMIN', 'PERM004'), ('ROLE_ADMIN', 'PERM005'), ('ROLE_ADMIN', 'PERM006'),
    ('ROLE_ADMIN', 'PERM007'), ('ROLE_ADMIN', 'PERM008'), ('ROLE_ADMIN', 'PERM009'),
    ('ROLE_ADMIN', 'PERM010');
    
    -- Lecturer: View students, manage grades
    INSERT INTO dbo.role_permissions (role_id, permission_id) VALUES
    ('ROLE_LECTURER', 'PERM005'), ('ROLE_LECTURER', 'PERM007'),
    ('ROLE_LECTURER', 'PERM009'), ('ROLE_LECTURER', 'PERM010');
    
    -- Student: View only
    INSERT INTO dbo.role_permissions (role_id, permission_id) VALUES
    ('ROLE_STUDENT', 'PERM007'), ('ROLE_STUDENT', 'PERM009');
    
    PRINT '   ✅ Permissions assigned to roles';
END
ELSE
    PRINT '   ⚠️  Role permissions already assigned';
GO

-- ===========================================
-- 15. SAMPLE NOTIFICATION
-- ===========================================
PRINT '🔔 Seeding Notifications...';

IF NOT EXISTS (SELECT 1 FROM notifications WHERE notification_id = 'NOTIF001')
BEGIN
    INSERT INTO dbo.notifications (notification_id, user_id, title, message, is_read) VALUES
    ('NOTIF001', 'USER003', N'Chào mừng K21', N'Chào mừng bạn đến với năm cuối cùng của Khóa 21!', 0),
    ('NOTIF002', 'USER007', N'Chào mừng K24', N'Chào mừng tân sinh viên Khóa 24! Chúc bạn có 4 năm học tập thật tốt!', 0);
    
    PRINT '   ✅ 2 notifications created';
END
ELSE
    PRINT '   ⚠️  Notifications already exist';
GO

PRINT '';
PRINT '╔════════════════════════════════════════════════╗';
PRINT '║     ✅ SEED DATA COMPLETED (AUTOMATED)         ║';
PRINT '╚════════════════════════════════════════════════╝';
PRINT '';
PRINT '📊 Summary:';
PRINT '   ✅ 4 Roles';
PRINT '   ✅ 7 Users (1 Admin, 1 Lecturer, 5 Students)';
PRINT '   ✅ 1 Faculty';
PRINT '   ✅ 2 Departments';
PRINT '   ✅ 2 Majors';
PRINT '   ✅ 4 Cohorts (K21, K22, K23, K24) - 16 school years total';
PRINT '   ✅ Active: School Year 2024-2025, Semester 1';
PRINT '   ✅ 1 Lecturer';
PRINT '   ✅ 5 Students (distributed across K21-K24)';
PRINT '   ✅ 4 Subjects (year 1-3 courses)';
PRINT '   ✅ 4 Classes (2024-2025 HK1)';
PRINT '   ✅ 6 Enrollments';
PRINT '   ✅ 6 Grades';
PRINT '   ✅ 10 Permissions';
PRINT '';
PRINT '🔑 Login Credentials (all use password: password123):';
PRINT '   👤 Admin:        admin';
PRINT '   👨‍🏫 Lecturer:     lecturer01';
PRINT '   👨‍🎓 Student K21:  student_k21_01, student_k21_02 (Year 4)';
PRINT '   👨‍🎓 Student K22:  student_k22_01 (Year 3)';
PRINT '   👨‍🎓 Student K23:  student_k23_01 (Year 2)';
PRINT '   👨‍🎓 Student K24:  student_k24_01 (Year 1 - Freshman)';
PRINT '';
PRINT '🎯 Test Automation:';
PRINT '   • EXEC sp_GetCurrentSchoolYearAndSemester;';
PRINT '   • EXEC sp_AutoTransitionSemester;';
PRINT '   • EXEC sp_AutoCreateCohort @StartYear = 2025;';
PRINT '';
GO

