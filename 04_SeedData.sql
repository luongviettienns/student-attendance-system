-- ===========================================
-- 🎓 HỆ THỐNG QUẢN LÝ ĐIỂM DANH SINH VIÊN
-- 📋 File 4/4: SEED DATA MẪU
-- ===========================================

USE EducationManagement;
GO

PRINT '🌱 Bắt đầu seed data...';

-- ===========================================
-- 1. ROLES (Vai trò)
-- ===========================================
INSERT INTO dbo.roles (role_id, role_name, description, created_by)
VALUES
('role-001', N'Admin',    N'Quản trị hệ thống', 'system'),
('role-002', N'Lecturer', N'Giảng viên',         'system'),
('role-003', N'Student',  N'Sinh viên',          'system'),
('role-004', N'Advisor',  N'Cố vấn học tập',     'system');

PRINT '✅ Đã thêm 4 roles';

-- ===========================================
-- 2. USERS (Người dùng mẫu)
-- ===========================================
-- Password cho tất cả: Admin@123
INSERT INTO dbo.users (user_id, username, password_hash, email, full_name, role_id, avatar_url, created_by)
VALUES
('user-001', 'admin', '$2b$12$wQ8PKj60xkkAo7df4YyF5OZiLPG3hAJIMLeKMmxy1g6PUP.pWtUs6', 
 'admin@edu.com', N'System Administrator', 'role-001', '/avatars/default.png', 'system'),
('user-002', 'sv2024001', '$2b$12$wQ8PKj60xkkAo7df4YyF5OZiLPG3hAJIMLeKMmxy1g6PUP.pWtUs6', 
 'sv2024001@edu.com', N'Nguyễn Văn A', 'role-003', '/avatars/default.png', 'system'),
('user-003', 'gv001', '$2b$12$wQ8PKj60xkkAo7df4YyF5OZiLPG3hAJIMLeKMmxy1g6PUP.pWtUs6',
 'gv001@edu.com', N'Trần Thị B', 'role-002', '/avatars/default.png', 'system');

PRINT '✅ Đã thêm 3 users (admin, sinh viên, giảng viên)';

-- ===========================================
-- 3. FACULTIES (Khoa)
-- ===========================================
INSERT INTO dbo.faculties (faculty_id, faculty_name, description, created_by)
VALUES
('faculty-001', N'Khoa Công nghệ Thông tin', N'Đào tạo chuyên ngành CNTT', 'system'),
('faculty-002', N'Khoa Kinh tế', N'Đào tạo chuyên ngành Kinh tế', 'system');

PRINT '✅ Đã thêm 2 faculties';

-- ===========================================
-- 4. DEPARTMENTS (Bộ môn)
-- ===========================================
INSERT INTO dbo.departments (department_id, department_name, faculty_id, created_by)
VALUES
('dept-001', N'Bộ môn Công nghệ Phần mềm', 'faculty-001', 'system'),
('dept-002', N'Bộ môn Mạng máy tính', 'faculty-001', 'system');

PRINT '✅ Đã thêm 2 departments';

-- ===========================================
-- 5. MAJORS (Ngành học)
-- ===========================================
INSERT INTO dbo.majors (major_id, major_name, major_code, faculty_id, created_by)
VALUES
('major-001', N'Công nghệ Thông tin', 'IT', 'faculty-001', 'system'),
('major-002', N'Hệ thống Thông tin', 'IS', 'faculty-001', 'system'),
('major-003', N'Quản trị Kinh doanh', 'BA', 'faculty-002', 'system');

PRINT '✅ Đã thêm 3 majors';

-- ===========================================
-- 6. ACADEMIC YEARS (Niên khóa)
-- ===========================================
INSERT INTO dbo.academic_years (academic_year_id, year_name, start_year, end_year, is_active, created_by)
VALUES
('ay-001', N'2023-2024', 2023, 2024, 0, 'system'),
('ay-002', N'2024-2025', 2024, 2025, 1, 'system');

PRINT '✅ Đã thêm 2 academic years';

-- ===========================================
-- 7. STUDENTS (Sinh viên)
-- ===========================================
INSERT INTO dbo.students (student_id, student_code, full_name, date_of_birth, gender, 
                          email, phone, major_id, academic_year_id, user_id, created_by)
VALUES
('student-001', 'SV2024001', N'Nguyễn Văn A', '2005-01-15', N'Nam', 
 'sv2024001@edu.com', '0901234567', 'major-001', 'ay-002', 'user-002', 'system'),
('student-002', 'SV2024002', N'Trần Thị B', '2005-03-20', N'Nữ',
 'sv2024002@edu.com', '0901234568', 'major-001', 'ay-002', NULL, 'system');

PRINT '✅ Đã thêm 2 students';

-- ===========================================
-- 8. LECTURERS (Giảng viên)
-- ===========================================
INSERT INTO dbo.lecturers (lecturer_id, lecturer_code, full_name, email, phone, 
                           department_id, user_id, created_by)
VALUES
('lecturer-001', 'GV001', N'Trần Thị B', 'gv001@edu.com', '0912345678', 
 'dept-001', 'user-003', 'system');

PRINT '✅ Đã thêm 1 lecturer';

-- ===========================================
-- 9. SUBJECTS (Môn học)
-- ===========================================
INSERT INTO dbo.subjects (subject_id, subject_code, subject_name, credits, 
                          department_id, created_by)
VALUES
('subject-001', 'IT101', N'Lập trình căn bản', 3, 'dept-001', 'system'),
('subject-002', 'IT102', N'Cơ sở dữ liệu', 4, 'dept-001', 'system'),
('subject-003', 'IT201', N'Lập trình hướng đối tượng', 3, 'dept-001', 'system');

PRINT '✅ Đã thêm 3 subjects';

-- ===========================================
-- 10. CLASSES (Lớp học phần)
-- ===========================================
INSERT INTO dbo.classes (class_id, class_code, class_name, subject_id, lecturer_id,
                         academic_year_id, semester, max_students, created_by)
VALUES
('class-001', 'IT101-01', N'Lập trình căn bản - Lớp 01', 'subject-001', 'lecturer-001',
 'ay-002', 1, 40, 'system'),
('class-002', 'IT102-01', N'Cơ sở dữ liệu - Lớp 01', 'subject-002', 'lecturer-001',
 'ay-002', 1, 35, 'system');

PRINT '✅ Đã thêm 2 classes';

-- ===========================================
-- 11. ENROLLMENTS (Đăng ký học phần)
-- ===========================================
INSERT INTO dbo.enrollments (enrollment_id, student_id, class_id, status, created_by)
VALUES
('enroll-001', 'student-001', 'class-001', N'Đang học', 'system'),
('enroll-002', 'student-001', 'class-002', N'Đang học', 'system'),
('enroll-003', 'student-002', 'class-001', N'Đang học', 'system');

PRINT '✅ Đã thêm 3 enrollments';

-- ===========================================
-- 12. ATTENDANCES (Điểm danh mẫu)
-- ===========================================
INSERT INTO dbo.attendances (attendance_id, enrollment_id, class_id, attendance_date, 
                             status, created_by)
VALUES
('attend-001', 'enroll-001', 'class-001', '2024-10-01 08:00:00', N'Có mặt', 'system'),
('attend-002', 'enroll-002', 'class-002', '2024-10-01 10:00:00', N'Có mặt', 'system'),
('attend-003', 'enroll-003', 'class-001', '2024-10-01 08:00:00', N'Vắng', 'system');

PRINT '✅ Đã thêm 3 attendance records';

-- ===========================================
-- 13. GRADES (Điểm số mẫu)
-- ===========================================
INSERT INTO dbo.grades (grade_id, enrollment_id, midterm_score, final_score, created_by)
VALUES
('grade-001', 'enroll-001', 8.5, 9.0, 'system'),
('grade-002', 'enroll-002', 7.0, 8.0, 'system');

PRINT '✅ Đã thêm 2 grade records';

-- ===========================================
PRINT '';
PRINT '🎉 HOÀN THÀNH SEED DATA!';
PRINT '📊 Tổng kết:';
PRINT '   - 4 Roles';
PRINT '   - 3 Users';
PRINT '   - 2 Faculties';
PRINT '   - 2 Departments';
PRINT '   - 3 Majors';
PRINT '   - 2 Academic Years';
PRINT '   - 2 Students';
PRINT '   - 1 Lecturer';
PRINT '   - 3 Subjects';
PRINT '   - 2 Classes';
PRINT '   - 3 Enrollments';
PRINT '   - 3 Attendance Records';
PRINT '   - 2 Grade Records';
PRINT '';
PRINT '🔐 Tài khoản đăng nhập:';
PRINT '   Admin:    username: admin      | password: Admin@123';
PRINT '   Student:  username: sv2024001  | password: Admin@123';
PRINT '   Lecturer: username: gv001      | password: Admin@123';

