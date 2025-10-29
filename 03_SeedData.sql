-- ===========================================
-- 🎓 HỆ THỐNG QUẢN LÝ ĐIỂM DANH SINH VIÊN
-- 📋 File 3: SEED DATA - MINIMAL (DEMO ONLY)
-- ===========================================

USE EducationManagement;
GO

SET QUOTED_IDENTIFIER ON;
GO

PRINT '🌱 Bắt đầu seed data (minimal)...';
GO

-- ===========================================
-- 1. ROLES (4 roles)
-- ===========================================
PRINT '👥 Seeding Roles...';

INSERT INTO dbo.roles (role_id, role_name, description, is_active) VALUES
('ROLE_ADMIN', N'Admin', N'Quản trị viên hệ thống', 1),
('ROLE_LECTURER', N'Lecturer', N'Giảng viên', 1),
('ROLE_STUDENT', N'Student', N'Sinh viên', 1),
('ROLE_ADVISOR', N'Advisor', N'Cố vấn học tập', 1);

PRINT '   ✅ 4 roles created';
GO

-- ===========================================
-- 2. USERS (4 users: 1 admin, 1 lecturer, 2 students)
-- ===========================================
PRINT '👤 Seeding Users...';

-- Password hash (BCrypt workFactor 12)
-- Hash: $2b$12$8HoLKV3tszmWbxEa1OWy8u973bS4UCVLXd3JJQ9JaF0vXFaQyKydK
INSERT INTO dbo.users (user_id, username, password_hash, email, phone, full_name, role_id, is_active) VALUES
('USER001', 'admin', '$2b$12$8HoLKV3tszmWbxEa1OWy8u973bS4UCVLXd3JJQ9JaF0vXFaQyKydK', 'admin@example.com', '0901234567', N'Nguyễn Văn Admin', 'ROLE_ADMIN', 1),
('USER002', 'lecturer01', '$2b$12$8HoLKV3tszmWbxEa1OWy8u973bS4UCVLXd3JJQ9JaF0vXFaQyKydK', 'lecturer01@example.com', '0902222222', N'Trần Thị Hoa', 'ROLE_LECTURER', 1),
('USER003', 'student01', '$2b$12$8HoLKV3tszmWbxEa1OWy8u973bS4UCVLXd3JJQ9JaF0vXFaQyKydK', 'student01@example.com', '0903333333', N'Lê Văn An', 'ROLE_STUDENT', 1),
('USER004', 'student02', '$2b$12$8HoLKV3tszmWbxEa1OWy8u973bS4UCVLXd3JJQ9JaF0vXFaQyKydK', 'student02@example.com', '0904444444', N'Phạm Thị Bình', 'ROLE_STUDENT', 1);

PRINT '   ✅ 4 users created (Password hash updated)';
GO

-- ===========================================
-- 3. FACULTIES (1 faculty)
-- ===========================================
PRINT '🏛️  Seeding Faculties...';

INSERT INTO dbo.faculties (faculty_id, faculty_code, faculty_name, description, is_active) VALUES
('FAC001', 'CNTT', N'Công nghệ Thông tin', N'Khoa Công nghệ Thông tin', 1);

PRINT '   ✅ 1 faculty created';
GO

-- ===========================================
-- 4. DEPARTMENTS (2 departments)
-- ===========================================
PRINT '🏢 Seeding Departments...';

INSERT INTO dbo.departments (department_id, department_code, department_name, faculty_id, description) VALUES
('DEPT001', 'DEPT001', N'Khoa học Máy tính', 'FAC001', N'Bộ môn Khoa học Máy tính'),
('DEPT002', 'DEPT002', N'Hệ thống Thông tin', 'FAC001', N'Bộ môn Hệ thống Thông tin');

PRINT '   ✅ 2 departments created';
GO

-- ===========================================
-- 5. MAJORS (2 majors)
-- ===========================================
PRINT '📚 Seeding Majors...';

INSERT INTO dbo.majors (major_id, major_name, major_code, faculty_id, description) VALUES
('MAJ001', N'Công nghệ Phần mềm', 'SE', 'FAC001', N'Chuyên ngành Công nghệ Phần mềm'),
('MAJ002', N'Khoa học Dữ liệu', 'DS', 'FAC001', N'Chuyên ngành Khoa học Dữ liệu');

PRINT '   ✅ 2 majors created';
GO

-- ===========================================
-- 6. ACADEMIC YEARS (1 year)
-- ===========================================
PRINT '📅 Seeding Academic Years...';

INSERT INTO dbo.academic_years (academic_year_id, year_name, start_year, end_year, is_active) VALUES
('AY2024', N'2024-2025', 2024, 2025, 1);

PRINT '   ✅ 1 academic year created';
GO

-- ===========================================
-- 7. LECTURERS (1 lecturer)
-- ===========================================
PRINT '👨‍🏫 Seeding Lecturers...';

INSERT INTO dbo.lecturers (lecturer_id, lecturer_code, full_name, email, phone, department_id, user_id) VALUES
('LEC001', 'GV001', N'Trần Thị Hoa', 'lecturer01@example.com', '0902222222', 'DEPT001', 'USER002');

PRINT '   ✅ 1 lecturer created';
GO

-- ===========================================
-- 8. STUDENTS (2 students)
-- ===========================================
PRINT '👨‍🎓 Seeding Students...';

INSERT INTO dbo.students (student_id, user_id, student_code, full_name, gender, date_of_birth, email, phone, major_id, academic_year_id, is_active) VALUES
('STU001', 'USER003', 'SV2024001', N'Lê Văn An', N'Nam', '2003-05-15', 'student01@example.com', '0903333333', 'MAJ001', 'AY2024', 1),
('STU002', 'USER004', 'SV2024002', N'Phạm Thị Bình', N'Nữ', '2003-08-20', 'student02@example.com', '0904444444', 'MAJ001', 'AY2024', 1);

PRINT '   ✅ 2 students created';
GO

-- ===========================================
-- 9. SUBJECTS (2 subjects)
-- ===========================================
PRINT '📖 Seeding Subjects...';

INSERT INTO dbo.subjects (subject_id, subject_code, subject_name, credits, department_id, description) VALUES
('SUB001', 'CS101', N'Lập trình C#', 3, 'DEPT001', N'Nhập môn lập trình C#'),
('SUB002', 'CS102', N'Cơ sở dữ liệu', 3, 'DEPT001', N'Hệ quản trị cơ sở dữ liệu');

PRINT '   ✅ 2 subjects created';
GO

-- ===========================================
-- 10. CLASSES (2 classes)
-- ===========================================
PRINT '🏫 Seeding Classes...';

INSERT INTO dbo.classes (class_id, class_code, class_name, subject_id, lecturer_id, academic_year_id, semester, max_students, schedule, room) VALUES
('CLS001', 'CS101-01', N'Lập trình C# - Lớp 01', 'SUB001', 'LEC001', 'AY2024', 1, 40, N'Thứ 2, 7:00-9:00', 'A101'),
('CLS002', 'CS102-01', N'Cơ sở dữ liệu - Lớp 01', 'SUB002', 'LEC001', 'AY2024', 1, 40, N'Thứ 4, 7:00-9:00', 'A102');

PRINT '   ✅ 2 classes created';
GO

-- ===========================================
-- 11. ENROLLMENTS (2 students x 2 classes = 4 enrollments)
-- ===========================================
PRINT '📝 Seeding Enrollments...';

INSERT INTO dbo.enrollments (enrollment_id, student_id, class_id, status, enrollment_date) VALUES
('ENR001', 'STU001', 'CLS001', N'Đang học', GETDATE()),
('ENR002', 'STU001', 'CLS002', N'Đang học', GETDATE()),
('ENR003', 'STU002', 'CLS001', N'Đang học', GETDATE()),
('ENR004', 'STU002', 'CLS002', N'Đang học', GETDATE());

PRINT '   ✅ 4 enrollments created';
GO

-- ===========================================
-- 12. GRADES (Sample grades)
-- ===========================================
PRINT '💯 Seeding Grades...';

INSERT INTO dbo.grades (grade_id, enrollment_id, midterm_score, final_score, total_score, letter_grade) VALUES
('GRD001', 'ENR001', 8.5, 9.0, 8.8, 'A'),
('GRD002', 'ENR002', 7.0, 7.5, 7.3, 'B'),
('GRD003', 'ENR003', 6.5, 7.0, 6.8, 'C'),
('GRD004', 'ENR004', 8.0, 8.5, 8.3, 'A');

PRINT '   ✅ 4 grades created';
GO

-- ===========================================
-- 13. PERMISSIONS (Essential permissions only)
-- ===========================================
PRINT '🔐 Seeding Permissions...';

-- Admin permissions
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
GO

-- ===========================================
-- 14. ROLE_PERMISSIONS (Assign permissions to roles)
-- ===========================================
PRINT '🔗 Assigning Permissions to Roles...';

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
GO

-- ===========================================
-- 15. SAMPLE NOTIFICATION
-- ===========================================
PRINT '🔔 Seeding Notifications...';

INSERT INTO dbo.notifications (notification_id, user_id, title, message, is_read) VALUES
('NOTIF001', 'USER003', N'Chào mừng', N'Chào mừng bạn đến với hệ thống quản lý điểm danh!', 0),
('NOTIF002', 'USER004', N'Chào mừng', N'Chào mừng bạn đến với hệ thống quản lý điểm danh!', 0);

PRINT '   ✅ 2 notifications created';
GO

PRINT '';
PRINT '╔════════════════════════════════════════════════╗';
PRINT '║        ✅ SEED DATA COMPLETED (MINIMAL)        ║';
PRINT '╚════════════════════════════════════════════════╝';
PRINT '';
PRINT '📊 Summary:';
PRINT '   ✅ 4 Roles';
PRINT '   ✅ 4 Users (1 Admin, 1 Lecturer, 2 Students)';
PRINT '   ✅ 1 Faculty';
PRINT '   ✅ 2 Departments';
PRINT '   ✅ 2 Majors';
PRINT '   ✅ 1 Academic Year';
PRINT '   ✅ 1 Lecturer';
PRINT '   ✅ 2 Students';
PRINT '   ✅ 2 Subjects';
PRINT '   ✅ 2 Classes';
PRINT '   ✅ 4 Enrollments';
PRINT '   ✅ 4 Grades';
PRINT '   ✅ 10 Permissions';
PRINT '';
PRINT '🔑 Login Credentials:';
PRINT '   👤 Admin:    admin / [password hash đã cập nhật]';
PRINT '   👨‍🏫 Lecturer: lecturer01 / [password hash đã cập nhật]';
PRINT '   👨‍🎓 Student1: student01 / [password hash đã cập nhật]';
PRINT '   👨‍🎓 Student2: student02 / [password hash đã cập nhật]';
PRINT '';
PRINT '🎯 Ready for DEMO!';
PRINT '';
