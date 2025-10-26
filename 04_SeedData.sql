-- ===========================================
-- 🎓 HỆ THỐNG QUẢN LÝ ĐIỂM DANH SINH VIÊN
-- 📋 File 4/4: SEED DATA MẪU (ĐẦY ĐỦ)
-- ===========================================

USE EducationManagement;
GO

PRINT '🌱 Bắt đầu seed data...';
PRINT '';

-- ===========================================
-- 1. ROLES (Vai trò)
-- ===========================================
PRINT '📋 1/13: Thêm Roles...';

INSERT INTO dbo.roles (role_id, role_name, description, created_by)
VALUES
('role-001', N'Admin',    N'Quản trị hệ thống', 'system'),
('role-002', N'Lecturer', N'Giảng viên',         'system'),
('role-003', N'Student',  N'Sinh viên',          'system'),
('role-004', N'Advisor',  N'Cố vấn học tập',     'system');

PRINT '✅ Đã thêm 4 roles';
GO

-- ===========================================
-- 2. USERS (Người dùng mẫu)
-- ===========================================
PRINT '📋 2/13: Thêm Users...';

-- Password cho tất cả: Admin@123
-- Hash: $2a$10$qtPZ9X2t5XJPO02yra9PT.Byxy9LXa1gN4O2q.HRq1Y6T59.QQfES (BCrypt.Net compatible)

INSERT INTO dbo.users (user_id, username, password_hash, email, full_name, role_id, avatar_url, created_by)
VALUES
-- Admin
('user-001', 'admin', '$2a$10$qtPZ9X2t5XJPO02yra9PT.Byxy9LXa1gN4O2q.HRq1Y6T59.QQfES', 
 'admin@edu.vn', N'System Administrator', 'role-001', '/avatars/default.png', 'system'),

-- Lecturers
('user-002', 'gv001', '$2a$10$qtPZ9X2t5XJPO02yra9PT.Byxy9LXa1gN4O2q.HRq1Y6T59.QQfES',
 'gv001@edu.vn', N'Nguyễn Văn An', 'role-002', '/avatars/default.png', 'system'),
('user-003', 'gv002', '$2a$10$qtPZ9X2t5XJPO02yra9PT.Byxy9LXa1gN4O2q.HRq1Y6T59.QQfES',
 'gv002@edu.vn', N'Trần Thị Bình', 'role-002', '/avatars/default.png', 'system'),
('user-004', 'gv003', '$2a$10$qtPZ9X2t5XJPO02yra9PT.Byxy9LXa1gN4O2q.HRq1Y6T59.QQfES',
 'gv003@edu.vn', N'Lê Văn Cường', 'role-002', '/avatars/default.png', 'system'),

-- Students  
('user-005', 'sv2024001', '$2a$10$qtPZ9X2t5XJPO02yra9PT.Byxy9LXa1gN4O2q.HRq1Y6T59.QQfES',
 'sv2024001@edu.vn', N'Phạm Minh Đức', 'role-003', '/avatars/default.png', 'system'),
('user-006', 'sv2024002', '$2a$10$qtPZ9X2t5XJPO02yra9PT.Byxy9LXa1gN4O2q.HRq1Y6T59.QQfES',
 'sv2024002@edu.vn', N'Hoàng Thị Hoa', 'role-003', '/avatars/default.png', 'system'),
('user-007', 'sv2024003', '$2a$10$qtPZ9X2t5XJPO02yra9PT.Byxy9LXa1gN4O2q.HRq1Y6T59.QQfES',
 'sv2024003@edu.vn', N'Đặng Văn Kiên', 'role-003', '/avatars/default.png', 'system'),
('user-008', 'sv2024004', '$2a$10$qtPZ9X2t5XJPO02yra9PT.Byxy9LXa1gN4O2q.HRq1Y6T59.QQfES',
 'sv2024004@edu.vn', N'Vũ Thị Lan', 'role-003', '/avatars/default.png', 'system'),
('user-009', 'sv2024005', '$2a$10$qtPZ9X2t5XJPO02yra9PT.Byxy9LXa1gN4O2q.HRq1Y6T59.QQfES',
 'sv2024005@edu.vn', N'Bùi Văn Nam', 'role-003', '/avatars/default.png', 'system');

PRINT '✅ Đã thêm 9 users (1 admin, 3 lecturers, 5 students)';
GO

-- ===========================================
-- 3. FACULTIES (Khoa)
-- ===========================================
PRINT '📋 3/13: Thêm Faculties...';

INSERT INTO dbo.faculties (faculty_id, faculty_code, faculty_name, description, is_active, created_by)
VALUES
('faculty-001', 'CNTT', N'Khoa Công nghệ Thông tin', 
 N'Đào tạo các chuyên ngành về công nghệ thông tin, phần mềm, mạng máy tính', 1, 'system'),
('faculty-002', 'KTE', N'Khoa Kinh tế', 
 N'Đào tạo các chuyên ngành kinh tế, quản trị kinh doanh', 1, 'system'),
('faculty-003', 'KYT', N'Khoa Kỹ thuật', 
 N'Đào tạo các chuyên ngành kỹ thuật cơ khí, điện, xây dựng', 1, 'system');

PRINT '✅ Đã thêm 3 faculties';
GO

-- ===========================================
-- 4. DEPARTMENTS (Bộ môn)
-- ===========================================
PRINT '📋 4/13: Thêm Departments...';

INSERT INTO dbo.departments (department_id, department_name, faculty_id, description, created_by)
VALUES
-- CNTT
('dept-001', N'Bộ môn Công nghệ Phần mềm', 'faculty-001', 
 N'Chuyên về phát triển phần mềm, ứng dụng', 'system'),
('dept-002', N'Bộ môn Mạng máy tính', 'faculty-001', 
 N'Chuyên về mạng, bảo mật, hạ tầng', 'system'),
('dept-003', N'Bộ môn Khoa học máy tính', 'faculty-001', 
 N'Chuyên về thuật toán, AI, ML', 'system'),

-- Kinh tế
('dept-004', N'Bộ môn Quản trị Kinh doanh', 'faculty-002', 
 N'Chuyên về quản trị, điều hành doanh nghiệp', 'system'),
('dept-005', N'Bộ môn Tài chính Ngân hàng', 'faculty-002', 
 N'Chuyên về tài chính, ngân hàng, đầu tư', 'system');

PRINT '✅ Đã thêm 5 departments';
GO

-- ===========================================
-- 5. MAJORS (Ngành học)
-- ===========================================
PRINT '📋 5/13: Thêm Majors...';

INSERT INTO dbo.majors (major_id, major_name, major_code, faculty_id, description, created_by)
VALUES
-- CNTT
('major-001', N'Công nghệ Thông tin', 'IT', 'faculty-001', 
 N'Chuyên ngành CNTT tổng hợp', 'system'),
('major-002', N'Hệ thống Thông tin', 'IS', 'faculty-001', 
 N'Chuyên về hệ thống thông tin quản lý', 'system'),
('major-003', N'Khoa học Máy tính', 'CS', 'faculty-001', 
 N'Chuyên về khoa học máy tính và AI', 'system'),
('major-004', N'An toàn Thông tin', 'SEC', 'faculty-001', 
 N'Chuyên về bảo mật, an ninh mạng', 'system'),

-- Kinh tế
('major-005', N'Quản trị Kinh doanh', 'BA', 'faculty-002', 
 N'Chuyên về quản trị doanh nghiệp', 'system'),
('major-006', N'Tài chính Ngân hàng', 'FIN', 'faculty-002', 
 N'Chuyên về tài chính và ngân hàng', 'system');

PRINT '✅ Đã thêm 6 majors';
GO

-- ===========================================
-- 6. ACADEMIC YEARS (Niên khóa)
-- ===========================================
PRINT '📋 6/13: Thêm Academic Years...';

INSERT INTO dbo.academic_years (academic_year_id, year_name, start_year, end_year, is_active, created_by)
VALUES
('ay-001', N'2022-2023', 2022, 2023, 0, 'system'),
('ay-002', N'2023-2024', 2023, 2024, 0, 'system'),
('ay-003', N'2024-2025', 2024, 2025, 1, 'system'),
('ay-004', N'2025-2026', 2025, 2026, 0, 'system');

PRINT '✅ Đã thêm 4 academic years';
GO

-- ===========================================
-- 7. LECTURERS (Giảng viên)
-- ===========================================
PRINT '📋 7/13: Thêm Lecturers...';

INSERT INTO dbo.lecturers (lecturer_id, lecturer_code, full_name, email, phone, 
                           department_id, user_id, created_by)
VALUES
('lecturer-001', 'GV001', N'Nguyễn Văn An', 'gv001@edu.vn', '0912345678', 
 'dept-001', 'user-002', 'system'),
('lecturer-002', 'GV002', N'Trần Thị Bình', 'gv002@edu.vn', '0912345679', 
 'dept-002', 'user-003', 'system'),
('lecturer-003', 'GV003', N'Lê Văn Cường', 'gv003@edu.vn', '0912345680', 
 'dept-003', 'user-004', 'system');

PRINT '✅ Đã thêm 3 lecturers';
GO

-- ===========================================
-- 8. STUDENTS (Sinh viên)
-- ===========================================
PRINT '📋 8/13: Thêm Students...';

INSERT INTO dbo.students (student_id, student_code, full_name, date_of_birth, gender, 
                          email, phone, major_id, academic_year_id, user_id, created_by)
VALUES
('student-001', 'SV2024001', N'Phạm Minh Đức', '2005-01-15', N'Nam', 
 'sv2024001@edu.vn', '0901234567', 'major-001', 'ay-003', 'user-005', 'system'),
 
('student-002', 'SV2024002', N'Hoàng Thị Hoa', '2005-03-20', N'Nữ',
 'sv2024002@edu.vn', '0901234568', 'major-001', 'ay-003', 'user-006', 'system'),
 
('student-003', 'SV2024003', N'Đặng Văn Kiên', '2005-05-10', N'Nam',
 'sv2024003@edu.vn', '0901234569', 'major-002', 'ay-003', 'user-007', 'system'),
 
('student-004', 'SV2024004', N'Vũ Thị Lan', '2005-07-25', N'Nữ',
 'sv2024004@edu.vn', '0901234570', 'major-003', 'ay-003', 'user-008', 'system'),
 
('student-005', 'SV2024005', N'Bùi Văn Nam', '2005-09-30', N'Nam',
 'sv2024005@edu.vn', '0901234571', 'major-001', 'ay-003', 'user-009', 'system');

PRINT '✅ Đã thêm 5 students';
GO

-- ===========================================
-- 9. SUBJECTS (Môn học)
-- ===========================================
PRINT '📋 9/13: Thêm Subjects...';

INSERT INTO dbo.subjects (subject_id, subject_code, subject_name, credits, 
                          department_id, description, created_by)
VALUES
-- Bộ môn Công nghệ Phần mềm
('subject-001', 'IT101', N'Lập trình căn bản', 3, 'dept-001', 
 N'Học các khái niệm cơ bản về lập trình', 'system'),
('subject-002', 'IT102', N'Cơ sở dữ liệu', 4, 'dept-001', 
 N'Học về thiết kế và quản lý CSDL', 'system'),
('subject-003', 'IT201', N'Lập trình hướng đối tượng', 3, 'dept-001', 
 N'OOP với Java/C#', 'system'),
('subject-004', 'IT202', N'Lập trình Web', 3, 'dept-001', 
 N'Phát triển web với HTML, CSS, JS', 'system'),
('subject-005', 'IT301', N'Công nghệ phần mềm', 4, 'dept-001', 
 N'Quy trình phát triển phần mềm', 'system'),

-- Bộ môn Mạng máy tính
('subject-006', 'NET101', N'Mạng máy tính cơ bản', 3, 'dept-002', 
 N'Kiến thức nền tảng về mạng', 'system'),
('subject-007', 'NET201', N'An ninh mạng', 3, 'dept-002', 
 N'Bảo mật và an toàn mạng', 'system'),

-- Bộ môn Khoa học máy tính
('subject-008', 'CS101', N'Cấu trúc dữ liệu và giải thuật', 4, 'dept-003', 
 N'CTDL và thuật toán cơ bản', 'system'),
('subject-009', 'CS201', N'Trí tuệ nhân tạo', 3, 'dept-003', 
 N'Nhập môn AI và ML', 'system'),
('subject-010', 'CS301', N'Machine Learning', 3, 'dept-003', 
 N'Học máy nâng cao', 'system');

PRINT '✅ Đã thêm 10 subjects';
GO

-- ===========================================
-- 10. CLASSES (Lớp học phần)
-- ===========================================
PRINT '📋 10/13: Thêm Classes...';

INSERT INTO dbo.classes (class_id, class_code, class_name, subject_id, lecturer_id,
                         academic_year_id, semester, max_students, schedule, room, created_by)
VALUES
-- Học kỳ 1, năm 2024-2025
('class-001', 'IT101-01', N'Lập trình căn bản - Lớp 01', 'subject-001', 'lecturer-001',
 'ay-003', 1, 40, N'Thứ 2, 7:00-9:00', 'A101', 'system'),
 
('class-002', 'IT102-01', N'Cơ sở dữ liệu - Lớp 01', 'subject-002', 'lecturer-001',
 'ay-003', 1, 35, N'Thứ 3, 7:00-9:00', 'A102', 'system'),
 
('class-003', 'IT201-01', N'Lập trình hướng đối tượng - Lớp 01', 'subject-003', 'lecturer-001',
 'ay-003', 1, 35, N'Thứ 4, 13:00-15:00', 'A103', 'system'),
 
('class-004', 'NET101-01', N'Mạng máy tính cơ bản - Lớp 01', 'subject-006', 'lecturer-002',
 'ay-003', 1, 40, N'Thứ 5, 7:00-9:00', 'B101', 'system'),
 
('class-005', 'CS101-01', N'Cấu trúc dữ liệu và giải thuật - Lớp 01', 'subject-008', 'lecturer-003',
 'ay-003', 1, 35, N'Thứ 6, 7:00-9:00', 'C101', 'system');

PRINT '✅ Đã thêm 5 classes';
GO

-- ===========================================
-- 11. ENROLLMENTS (Đăng ký học phần)
-- ===========================================
PRINT '📋 11/13: Thêm Enrollments...';

INSERT INTO dbo.enrollments (enrollment_id, student_id, class_id, status, created_by)
VALUES
-- Student 001 đăng ký 3 môn
('enroll-001', 'student-001', 'class-001', N'Đang học', 'system'),
('enroll-002', 'student-001', 'class-002', N'Đang học', 'system'),
('enroll-003', 'student-001', 'class-004', N'Đang học', 'system'),

-- Student 002 đăng ký 3 môn
('enroll-004', 'student-002', 'class-001', N'Đang học', 'system'),
('enroll-005', 'student-002', 'class-003', N'Đang học', 'system'),
('enroll-006', 'student-002', 'class-005', N'Đang học', 'system'),

-- Student 003 đăng ký 2 môn
('enroll-007', 'student-003', 'class-002', N'Đang học', 'system'),
('enroll-008', 'student-003', 'class-004', N'Đang học', 'system'),

-- Student 004 đăng ký 2 môn
('enroll-009', 'student-004', 'class-003', N'Đang học', 'system'),
('enroll-010', 'student-004', 'class-005', N'Đang học', 'system'),

-- Student 005 đăng ký 3 môn
('enroll-011', 'student-005', 'class-001', N'Đang học', 'system'),
('enroll-012', 'student-005', 'class-002', N'Đang học', 'system'),
('enroll-013', 'student-005', 'class-004', N'Đang học', 'system');

PRINT '✅ Đã thêm 13 enrollments';
GO

-- ===========================================
-- 12. ATTENDANCES (Điểm danh mẫu)
-- ===========================================
PRINT '📋 12/13: Thêm Attendances...';

-- Điểm danh ngày 2024-10-21 cho class IT101-01
INSERT INTO dbo.attendances (attendance_id, enrollment_id, class_id, attendance_date, status, created_by)
VALUES
('attend-001', 'enroll-001', 'class-001', '2024-10-21 07:00:00', N'Có mặt', 'system'),
('attend-002', 'enroll-004', 'class-001', '2024-10-21 07:00:00', N'Có mặt', 'system'),
('attend-003', 'enroll-011', 'class-001', '2024-10-21 07:00:00', N'Vắng có phép', 'system'),

-- Điểm danh ngày 2024-10-22 cho class IT102-01
('attend-004', 'enroll-002', 'class-002', '2024-10-22 07:00:00', N'Có mặt', 'system'),
('attend-005', 'enroll-007', 'class-002', '2024-10-22 07:00:00', N'Có mặt', 'system'),
('attend-006', 'enroll-012', 'class-002', '2024-10-22 07:00:00', N'Có mặt', 'system'),

-- Điểm danh ngày 2024-10-23 cho class IT201-01
('attend-007', 'enroll-005', 'class-003', '2024-10-23 13:00:00', N'Có mặt', 'system'),
('attend-008', 'enroll-009', 'class-003', '2024-10-23 13:00:00', N'Vắng', 'system');

PRINT '✅ Đã thêm 8 attendance records';
GO

-- ===========================================
-- 13. GRADES (Điểm số mẫu)
-- ===========================================
PRINT '📋 13/13: Thêm Grades...';

INSERT INTO dbo.grades (grade_id, enrollment_id, midterm_score, final_score, created_by)
VALUES
-- Student 001
('grade-001', 'enroll-001', 8.5, 9.0, 'system'),  -- IT101
('grade-002', 'enroll-002', 7.5, 8.5, 'system'),  -- IT102

-- Student 002
('grade-003', 'enroll-004', 9.0, 9.5, 'system'),  -- IT101
('grade-004', 'enroll-005', 8.0, 8.5, 'system'),  -- IT201

-- Student 003
('grade-005', 'enroll-007', 7.0, 7.5, 'system'),  -- IT102
('grade-006', 'enroll-008', 6.5, 7.0, 'system');  -- NET101

PRINT '✅ Đã thêm 6 grade records';
GO

-- ===========================================
-- HIỂN THỊ THỐNG KÊ
-- ===========================================
PRINT '';
PRINT '╔══════════════════════════════════════════════════════════════════╗';
PRINT '║                                                                  ║';
PRINT '║                  🎉 HOÀN THÀNH SEED DATA!                       ║';
PRINT '║                                                                  ║';
PRINT '╚══════════════════════════════════════════════════════════════════╝';
PRINT '';
PRINT '📊 TỔNG KẾT DỮ LIỆU:';
PRINT '   ✅  4 Roles';
PRINT '   ✅  9 Users (1 admin, 3 lecturers, 5 students)';
PRINT '   ✅  3 Faculties';
PRINT '   ✅  5 Departments';
PRINT '   ✅  6 Majors';
PRINT '   ✅  4 Academic Years';
PRINT '   ✅  3 Lecturers';
PRINT '   ✅  5 Students';
PRINT '   ✅ 10 Subjects';
PRINT '   ✅  5 Classes';
PRINT '   ✅ 13 Enrollments';
PRINT '   ✅  8 Attendance Records';
PRINT '   ✅  6 Grade Records';
PRINT '';
PRINT '🔐 TÀI KHOẢN ĐĂNG NHẬP:';
PRINT '   👤 Admin:';
PRINT '      - Username: admin';
PRINT '      - Password: Admin@123';
PRINT '      - Email: admin@edu.vn';
PRINT '';
PRINT '   👨‍🏫 Lecturers:';
PRINT '      - Username: gv001 | Password: Admin@123 | Nguyễn Văn An';
PRINT '      - Username: gv002 | Password: Admin@123 | Trần Thị Bình';
PRINT '      - Username: gv003 | Password: Admin@123 | Lê Văn Cường';
PRINT '';
PRINT '   👨‍🎓 Students:';
PRINT '      - Username: sv2024001 | Password: Admin@123 | Phạm Minh Đức';
PRINT '      - Username: sv2024002 | Password: Admin@123 | Hoàng Thị Hoa';
PRINT '      - Username: sv2024003 | Password: Admin@123 | Đặng Văn Kiên';
PRINT '      - Username: sv2024004 | Password: Admin@123 | Vũ Thị Lan';
PRINT '      - Username: sv2024005 | Password: Admin@123 | Bùi Văn Nam';
PRINT '';
-- ===========================================
-- 14. PERMISSIONS (Quyền hạn hệ thống)
-- ===========================================
PRINT '📋 14/14: Thêm Permissions...';

-- Quản lý người dùng
INSERT INTO dbo.permissions (permission_id, permission_code, permission_name, description, created_by) VALUES
('perm-001', 'VIEW_USERS', N'Xem danh sách người dùng', N'Cho phép xem danh sách tất cả người dùng trong hệ thống', 'system'),
('perm-002', 'CREATE_USERS', N'Tạo người dùng mới', N'Cho phép tạo tài khoản người dùng mới', 'system'),
('perm-003', 'EDIT_USERS', N'Chỉnh sửa người dùng', N'Cho phép chỉnh sửa thông tin người dùng', 'system'),
('perm-004', 'DELETE_USERS', N'Xóa người dùng', N'Cho phép xóa người dùng khỏi hệ thống', 'system'),
('perm-005', 'TOGGLE_USER_STATUS', N'Bật/Tắt trạng thái người dùng', N'Cho phép kích hoạt hoặc vô hiệu hóa tài khoản', 'system'),

-- Quản lý vai trò & quyền hạn
('perm-006', 'VIEW_ROLES', N'Xem danh sách vai trò', N'Cho phép xem danh sách các vai trò', 'system'),
('perm-007', 'MANAGE_ROLES', N'Quản lý vai trò', N'Cho phép tạo, sửa, xóa vai trò', 'system'),
('perm-008', 'MANAGE_PERMISSIONS', N'Quản lý phân quyền', N'Cho phép gán quyền cho vai trò', 'system'),

-- Quản lý sinh viên
('perm-009', 'VIEW_STUDENTS', N'Xem danh sách sinh viên', N'Cho phép xem danh sách sinh viên', 'system'),
('perm-010', 'CREATE_STUDENTS', N'Tạo sinh viên mới', N'Cho phép thêm sinh viên mới vào hệ thống', 'system'),
('perm-011', 'EDIT_STUDENTS', N'Chỉnh sửa sinh viên', N'Cho phép chỉnh sửa thông tin sinh viên', 'system'),
('perm-012', 'DELETE_STUDENTS', N'Xóa sinh viên', N'Cho phép xóa sinh viên khỏi hệ thống', 'system'),
('perm-013', 'IMPORT_STUDENTS', N'Import sinh viên', N'Cho phép import danh sách sinh viên từ Excel', 'system'),
('perm-014', 'EXPORT_STUDENTS', N'Export sinh viên', N'Cho phép xuất danh sách sinh viên ra Excel', 'system'),

-- Quản lý giảng viên
('perm-015', 'VIEW_LECTURERS', N'Xem danh sách giảng viên', N'Cho phép xem danh sách giảng viên', 'system'),
('perm-016', 'CREATE_LECTURERS', N'Tạo giảng viên mới', N'Cho phép thêm giảng viên mới', 'system'),
('perm-017', 'EDIT_LECTURERS', N'Chỉnh sửa giảng viên', N'Cho phép chỉnh sửa thông tin giảng viên', 'system'),
('perm-018', 'DELETE_LECTURERS', N'Xóa giảng viên', N'Cho phép xóa giảng viên', 'system'),

-- Quản lý tổ chức
('perm-019', 'VIEW_ORGANIZATION', N'Xem cấu trúc tổ chức', N'Cho phép xem khoa, bộ môn, ngành, môn học', 'system'),
('perm-020', 'MANAGE_FACULTIES', N'Quản lý khoa', N'Cho phép tạo, sửa, xóa khoa', 'system'),
('perm-021', 'MANAGE_DEPARTMENTS', N'Quản lý bộ môn', N'Cho phép tạo, sửa, xóa bộ môn', 'system'),
('perm-022', 'MANAGE_MAJORS', N'Quản lý ngành học', N'Cho phép tạo, sửa, xóa ngành học', 'system'),
('perm-023', 'MANAGE_SUBJECTS', N'Quản lý môn học', N'Cho phép tạo, sửa, xóa môn học', 'system'),

-- Điểm danh & nhập điểm
('perm-024', 'TAKE_ATTENDANCE', N'Thực hiện điểm danh', N'Cho phép điểm danh sinh viên trong lớp học', 'system'),
('perm-025', 'VIEW_ATTENDANCE', N'Xem lịch sử điểm danh', N'Cho phép xem lịch sử điểm danh của sinh viên', 'system'),
('perm-026', 'ENTER_GRADES', N'Nhập điểm', N'Cho phép nhập điểm cho sinh viên', 'system'),
('perm-027', 'VIEW_GRADES', N'Xem điểm', N'Cho phép xem điểm của sinh viên', 'system'),
('perm-028', 'EDIT_GRADES', N'Chỉnh sửa điểm', N'Cho phép chỉnh sửa điểm đã nhập', 'system'),

-- Quản lý lớp học & lịch học
('perm-029', 'VIEW_CLASSES', N'Xem lớp học', N'Cho phép xem danh sách lớp học', 'system'),
('perm-030', 'MANAGE_CLASSES', N'Quản lý lớp học', N'Cho phép tạo, sửa, xóa lớp học', 'system'),
('perm-031', 'VIEW_SCHEDULES', N'Xem lịch học', N'Cho phép xem lịch học', 'system'),
('perm-032', 'MANAGE_SCHEDULES', N'Quản lý lịch học', N'Cho phép tạo, sửa, xóa lịch học', 'system'),

-- Hệ thống & báo cáo
('perm-033', 'VIEW_AUDIT_LOGS', N'Xem nhật ký hệ thống', N'Cho phép xem lịch sử hoạt động của hệ thống', 'system'),
('perm-034', 'VIEW_REPORTS', N'Xem báo cáo', N'Cho phép xem các báo cáo thống kê', 'system'),
('perm-035', 'EXPORT_REPORTS', N'Xuất báo cáo', N'Cho phép xuất báo cáo ra file', 'system'),
('perm-036', 'MANAGE_NOTIFICATIONS', N'Quản lý thông báo', N'Cho phép tạo và gửi thông báo', 'system'),
('perm-037', 'MANAGE_SYSTEM', N'Quản trị hệ thống', N'Cho phép cấu hình và quản trị toàn bộ hệ thống', 'system'),

-- Cố vấn học tập
('perm-038', 'VIEW_ADVISEES', N'Xem sinh viên cố vấn', N'Cho phép xem danh sách sinh viên được phụ trách', 'system'),
('perm-039', 'MANAGE_ADVISEES', N'Quản lý sinh viên cố vấn', N'Cho phép quản lý sinh viên được phụ trách', 'system');

PRINT '✅ Đã thêm 39 permissions';

-- Gán quyền cho các roles
PRINT '';
PRINT '🔐 Gán permissions cho roles...';

-- Admin: Tất cả quyền
INSERT INTO dbo.role_permissions (role_id, permission_id, created_by)
SELECT 'role-001', permission_id, 'system' FROM dbo.permissions;
PRINT '✅ Admin: Đã gán tất cả 39 permissions';

-- Lecturer: Quyền giảng dạy
INSERT INTO dbo.role_permissions (role_id, permission_id, created_by) VALUES
('role-002', 'perm-009', 'system'), -- VIEW_STUDENTS
('role-002', 'perm-024', 'system'), -- TAKE_ATTENDANCE
('role-002', 'perm-025', 'system'), -- VIEW_ATTENDANCE
('role-002', 'perm-026', 'system'), -- ENTER_GRADES
('role-002', 'perm-027', 'system'), -- VIEW_GRADES
('role-002', 'perm-028', 'system'), -- EDIT_GRADES
('role-002', 'perm-029', 'system'), -- VIEW_CLASSES
('role-002', 'perm-031', 'system'); -- VIEW_SCHEDULES
PRINT '✅ Lecturer: Đã gán 8 permissions';

-- Student: Quyền xem
INSERT INTO dbo.role_permissions (role_id, permission_id, created_by) VALUES
('role-003', 'perm-027', 'system'), -- VIEW_GRADES
('role-003', 'perm-031', 'system'); -- VIEW_SCHEDULES
PRINT '✅ Student: Đã gán 2 permissions';

-- Advisor: Quyền cố vấn
INSERT INTO dbo.role_permissions (role_id, permission_id, created_by) VALUES
('role-004', 'perm-009', 'system'), -- VIEW_STUDENTS
('role-004', 'perm-027', 'system'), -- VIEW_GRADES
('role-004', 'perm-038', 'system'), -- VIEW_ADVISEES
('role-004', 'perm-039', 'system'); -- MANAGE_ADVISEES
PRINT '✅ Advisor: Đã gán 4 permissions';

GO

PRINT '';
PRINT '================================';
PRINT '🎉 HOÀN THÀNH SEED DATA!';
PRINT '================================';
PRINT '';
PRINT '📝 GHI CHÚ:';
PRINT '   - Tất cả mật khẩu đều là: Admin@123';
PRINT '   - Niên khóa hiện tại: 2024-2025';
PRINT '   - Có dữ liệu mẫu về điểm danh và điểm số';
PRINT '   - Đã seed 39 permissions và gán cho các roles';
PRINT '   - Admin có tất cả quyền, Lecturer có 8 quyền, Student có 2 quyền, Advisor có 4 quyền';
PRINT '';
