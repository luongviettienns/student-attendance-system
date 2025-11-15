-- ===========================================
-- 🎓 HỆ THỐNG QUẢN LÝ ĐIỂM DANH SINH VIÊN
-- 📋 File: MINIMAL SETUP - CHỈ TẠO ADMIN VÀ ROLES
-- ===========================================
-- 
-- Script này chỉ tạo:
-- 1. 4 Roles (Admin, Lecturer, Student, Advisor)
-- 2. 1 Admin User (để đăng nhập và thêm dữ liệu từ frontend)
-- 3. Tất cả Permissions (để menu hoạt động đúng)
-- 4. Role-Permission mappings
--
-- Sau khi chạy script này, bạn có thể:
-- - Đăng nhập với tài khoản admin
-- - Thêm dữ liệu từ frontend: Faculties, Departments, Majors, 
--   Academic Years, School Years, Subjects, Students, Lecturers, etc.
--
-- ===========================================

USE EducationManagement;
GO

SET QUOTED_IDENTIFIER ON;
GO

PRINT '';
PRINT '╔════════════════════════════════════════════════╗';
PRINT '║     🚀 MINIMAL SETUP - ADMIN ONLY              ║';
PRINT '╚════════════════════════════════════════════════╝';
PRINT '';
PRINT '⚠️  Script này chỉ tạo roles, permissions và admin user';
PRINT '📝 Bạn sẽ cần thêm dữ liệu từ frontend sau khi đăng nhập';
PRINT '';
GO

-- ===========================================
-- 1. ROLES (4 roles)
-- ===========================================
PRINT '👥 Creating Roles...';

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
-- 2. ADMIN USER
-- ===========================================
PRINT '👤 Creating Admin User...';

-- Admin password: "admin123" 
-- BCrypt hash: $2a$10$h5gvrNjE2bhwhHn6Ofofq.Ppr0hvpLY5Q3mbY1OjkkGL8CMxm2VBm

IF NOT EXISTS (SELECT 1 FROM users WHERE user_id = 'USER001')
BEGIN
    INSERT INTO dbo.users (user_id, username, password_hash, email, phone, full_name, role_id, is_active) VALUES
    ('USER001', 'admin', '$2a$10$h5gvrNjE2bhwhHn6Ofofq.Ppr0hvpLY5Q3mbY1OjkkGL8CMxm2VBm', 'admin@example.com', '0901234567', N'Nguyễn Văn Admin', 'ROLE_ADMIN', 1);
    PRINT '   ✅ Admin user created';
    PRINT '   📧 Username: admin';
    PRINT '   🔑 Password: admin123';
END
ELSE
    PRINT '   ⚠️  Admin user already exists';
GO

-- ===========================================
-- 3. PERMISSIONS (Menu Permissions)
-- ===========================================
PRINT '🔐 Creating Permissions...';

-- Student Parent Permissions
IF NOT EXISTS (SELECT 1 FROM permissions WHERE permission_code = 'STUDENT_SECTION_OVERVIEW')
BEGIN
    INSERT INTO dbo.permissions (permission_id, permission_code, permission_name, parent_code, icon, sort_order, description, is_active) VALUES
    ('PERM_STU_OVERVIEW', 'STUDENT_SECTION_OVERVIEW', N'TỔNG QUAN', NULL, 'fas fa-home', 1, N'Menu section tổng quan cho sinh viên', 1),
    ('PERM_STU_STUDY', 'STUDENT_SECTION_STUDY', N'HỌC TẬP', NULL, 'fas fa-book', 2, N'Menu section học tập cho sinh viên', 1),
    ('PERM_STU_PROFILE', 'STUDENT_SECTION_PROFILE', N'CÁ NHÂN', NULL, 'fas fa-user', 3, N'Menu section cá nhân cho sinh viên', 1),
    ('PERM_STU_SYSTEM', 'STUDENT_SECTION_SYSTEM', N'HỆ THỐNG', NULL, 'fas fa-cog', 4, N'Menu section hệ thống cho sinh viên', 1);
END

-- Student Child Permissions
IF NOT EXISTS (SELECT 1 FROM permissions WHERE permission_code = 'STUDENT_DASHBOARD')
BEGIN
    INSERT INTO dbo.permissions (permission_id, permission_code, permission_name, parent_code, icon, sort_order, description, is_active) VALUES
    ('PERM_STU_DASHBOARD', 'STUDENT_DASHBOARD', N'Dashboard', 'STUDENT_SECTION_OVERVIEW', 'fas fa-tachometer-alt', 1, N'Dashboard sinh viên', 1),
    ('PERM_STU_TIMETABLE', 'STUDENT_TIMETABLE', N'Thời khóa biểu', 'STUDENT_SECTION_STUDY', 'fas fa-calendar-alt', 1, N'Xem thời khóa biểu', 1),
    ('PERM_STU_SCHEDULE', 'STUDENT_SCHEDULE', N'Lịch học', 'STUDENT_SECTION_STUDY', 'fas fa-calendar', 2, N'Xem lịch học', 1),
    ('PERM_STU_GRADES', 'STUDENT_GRADES', N'Kết quả học tập', 'STUDENT_SECTION_STUDY', 'fas fa-graduation-cap', 3, N'Xem bảng điểm', 1),
    ('PERM_STU_ATTENDANCE', 'STUDENT_ATTENDANCE', N'Điểm danh', 'STUDENT_SECTION_STUDY', 'fas fa-clipboard-check', 4, N'Xem lịch sử điểm danh', 1),
    ('PERM_STU_ENROLLMENT', 'STUDENT_ENROLLMENT', N'Đăng ký học phần', 'STUDENT_SECTION_STUDY', 'fas fa-edit', 5, N'Đăng ký học phần', 1),
    ('PERM_STU_RETAKES', 'STUDENT_RETAKES', N'Học lại', 'STUDENT_SECTION_STUDY', 'fas fa-redo', 6, N'Xem danh sách môn học lại', 1),
    ('PERM_STU_APPEALS', 'STUDENT_APPEALS', N'Phúc khảo', 'STUDENT_SECTION_STUDY', 'fas fa-gavel', 7, N'Yêu cầu phúc khảo điểm', 1),
    ('PERM_STU_REPORTS', 'STUDENT_REPORTS', N'Báo cáo', 'STUDENT_SECTION_STUDY', 'fas fa-chart-bar', 8, N'Xem báo cáo học tập', 1),
    ('PERM_STU_PROFILE_ITEM', 'STUDENT_PROFILE', N'Thông tin cá nhân', 'STUDENT_SECTION_PROFILE', 'fas fa-user', 1, N'Quản lý thông tin cá nhân', 1),
    ('PERM_STU_NOTIFICATIONS', 'STUDENT_NOTIFICATIONS', N'Thông báo', 'STUDENT_SECTION_SYSTEM', 'fas fa-bell', 1, N'Xem thông báo', 1);
END

-- Lecturer Parent Permissions
IF NOT EXISTS (SELECT 1 FROM permissions WHERE permission_code = 'TEACHER_SECTION_OVERVIEW')
BEGIN
    INSERT INTO dbo.permissions (permission_id, permission_code, permission_name, parent_code, icon, sort_order, description, is_active) VALUES
    ('PERM_TCH_OVERVIEW', 'TEACHER_SECTION_OVERVIEW', N'TỔNG QUAN', NULL, 'fas fa-home', 1, N'Menu section tổng quan cho giảng viên', 1),
    ('PERM_TCH_TEACHING', 'TEACHER_SECTION_TEACHING', N'GIẢNG DẠY', NULL, 'fas fa-chalkboard-teacher', 2, N'Menu section giảng dạy', 1),
    ('PERM_TCH_SYSTEM', 'TEACHER_SECTION_SYSTEM', N'HỆ THỐNG', NULL, 'fas fa-cog', 3, N'Menu section hệ thống cho giảng viên', 1);
END

-- Lecturer Child Permissions
IF NOT EXISTS (SELECT 1 FROM permissions WHERE permission_code = 'TEACHER_DASHBOARD')
BEGIN
    INSERT INTO dbo.permissions (permission_id, permission_code, permission_name, parent_code, icon, sort_order, description, is_active) VALUES
    ('PERM_TCH_DASHBOARD', 'TEACHER_DASHBOARD', N'Dashboard', 'TEACHER_SECTION_OVERVIEW', 'fas fa-tachometer-alt', 1, N'Dashboard giảng viên', 1),
    ('PERM_TCH_ATTENDANCE', 'TEACHER_ATTENDANCE', N'Điểm danh', 'TEACHER_SECTION_TEACHING', 'fas fa-clipboard-check', 1, N'Điểm danh lớp học', 1),
    ('PERM_TCH_GRADES', 'TEACHER_GRADES', N'Nhập điểm', 'TEACHER_SECTION_TEACHING', 'fas fa-edit', 2, N'Nhập điểm cho sinh viên', 1),
    ('PERM_TCH_APPEALS', 'TEACHER_APPEALS', N'Phúc khảo', 'TEACHER_SECTION_TEACHING', 'fas fa-gavel', 3, N'Xử lý phúc khảo điểm', 1),
    ('PERM_TCH_TIMETABLE', 'TEACHER_TIMETABLE', N'Thời khóa biểu', 'TEACHER_SECTION_TEACHING', 'fas fa-calendar-alt', 4, N'Xem thời khóa biểu giảng dạy', 1),
    ('PERM_TCH_REPORTS', 'TEACHER_REPORTS', N'Báo cáo', 'TEACHER_SECTION_TEACHING', 'fas fa-chart-bar', 5, N'Xem báo cáo giảng dạy', 1),
    ('PERM_TCH_NOTIFICATIONS', 'TEACHER_NOTIFICATIONS', N'Thông báo', 'TEACHER_SECTION_SYSTEM', 'fas fa-bell', 1, N'Xem thông báo', 1);
END

-- Advisor Parent Permissions
IF NOT EXISTS (SELECT 1 FROM permissions WHERE permission_code = 'ADVISOR_SECTION_OVERVIEW')
BEGIN
    INSERT INTO dbo.permissions (permission_id, permission_code, permission_name, parent_code, icon, sort_order, description, is_active) VALUES
    ('PERM_ADV_OVERVIEW', 'ADVISOR_SECTION_OVERVIEW', N'TỔNG QUAN', NULL, 'fas fa-home', 1, N'Menu section tổng quan cho cố vấn', 1),
    ('PERM_ADV_ADVISING', 'ADVISOR_SECTION_ADVISING', N'CỐ VẤN', NULL, 'fas fa-user-graduate', 2, N'Menu section cố vấn học tập', 1),
    ('PERM_ADV_SYSTEM', 'ADVISOR_SECTION_SYSTEM', N'HỆ THỐNG', NULL, 'fas fa-cog', 3, N'Menu section hệ thống cho cố vấn', 1);
END

-- Advisor Child Permissions
IF NOT EXISTS (SELECT 1 FROM permissions WHERE permission_code = 'ADVISOR_DASHBOARD')
BEGIN
    INSERT INTO dbo.permissions (permission_id, permission_code, permission_name, parent_code, icon, sort_order, description, is_active) VALUES
    ('PERM_ADV_DASHBOARD', 'ADVISOR_DASHBOARD', N'Dashboard', 'ADVISOR_SECTION_OVERVIEW', 'fas fa-tachometer-alt', 1, N'Dashboard cố vấn', 1),
    ('PERM_ADV_STUDENTS', 'ADVISOR_STUDENTS', N'Sinh viên', 'ADVISOR_SECTION_ADVISING', 'fas fa-user-graduate', 1, N'Quản lý sinh viên được phụ trách', 1),
    ('PERM_ADV_WARNINGS', 'ADVISOR_WARNINGS', N'Cảnh báo', 'ADVISOR_SECTION_ADVISING', 'fas fa-exclamation-triangle', 2, N'Cảnh báo và gửi email cho sinh viên', 1),
    ('PERM_ADV_APPEALS', 'ADVISOR_APPEALS', N'Phúc khảo', 'ADVISOR_SECTION_ADVISING', 'fas fa-gavel', 3, N'Quản lý phúc khảo điểm', 1),
    ('PERM_ADV_GRADE_FORMULA', 'ADVISOR_GRADE_FORMULA', N'Công thức điểm', 'ADVISOR_SECTION_ADVISING', 'fas fa-calculator', 4, N'Cấu hình công thức tính điểm', 1),
    ('PERM_ADV_ENROLLMENTS', 'ADVISOR_ENROLLMENTS', N'Duyệt đăng ký', 'ADVISOR_SECTION_ADVISING', 'fas fa-clipboard-check', 5, N'Duyệt và quản lý đăng ký học phần của sinh viên', 1),
    ('PERM_ADV_RETAKES', 'ADVISOR_RETAKES', N'Học lại', 'ADVISOR_SECTION_ADVISING', 'fas fa-redo', 6, N'Quản lý môn học lại của sinh viên', 1),
    ('PERM_ADV_REPORTS', 'ADVISOR_REPORTS', N'Báo cáo', 'ADVISOR_SECTION_ADVISING', 'fas fa-chart-bar', 7, N'Xem báo cáo cố vấn học tập', 1),
    ('PERM_ADV_NOTIFICATIONS', 'ADVISOR_NOTIFICATIONS', N'Thông báo', 'ADVISOR_SECTION_SYSTEM', 'fas fa-bell', 1, N'Xem thông báo', 1);
END

-- Admin Parent Permissions
IF NOT EXISTS (SELECT 1 FROM permissions WHERE permission_code = 'ADMIN_SECTION_OVERVIEW')
BEGIN
    INSERT INTO dbo.permissions (permission_id, permission_code, permission_name, parent_code, icon, sort_order, description, is_active) VALUES
    ('PERM_ADM_OVERVIEW', 'ADMIN_SECTION_OVERVIEW', N'TỔNG QUAN', NULL, 'fas fa-home', 1, N'Menu section tổng quan cho admin', 1),
    ('PERM_ADM_USERS', 'ADMIN_SECTION_USERS', N'QUẢN LÝ NGƯỜI DÙNG', NULL, 'fas fa-users', 2, N'Menu section quản lý người dùng', 1),
    ('PERM_ADM_ACADEMIC', 'ADMIN_SECTION_ACADEMIC', N'QUẢN LÝ ĐÀO TẠO', NULL, 'fas fa-graduation-cap', 3, N'Menu section quản lý đào tạo', 1),
    ('PERM_ADM_SUBJECTS', 'ADMIN_SECTION_SUBJECTS', N'HỌC PHẦN', NULL, 'fas fa-book', 4, N'Menu section học phần', 1),
    ('PERM_ADM_ADMIN_CLASSES_SECTION', 'ADMIN_SECTION_CLASSES', N'LỚP HỌC', NULL, 'fas fa-users-class', 5, N'Menu section lớp học', 1),
    ('PERM_ADM_ENROLLMENT', 'ADMIN_SECTION_ENROLLMENT', N'ĐĂNG KÝ HỌC PHẦN', NULL, 'fas fa-clipboard-list', 6, N'Menu section đăng ký học phần', 1),
    ('PERM_ADM_TIMETABLE', 'ADMIN_SECTION_TIMETABLE', N'QUẢN LÝ THỜI KHÓA BIỂU', NULL, 'fas fa-calendar-alt', 7, N'Menu section quản lý thời khóa biểu', 1),
    ('PERM_ADM_SYSTEM', 'ADMIN_SECTION_SYSTEM', N'HỆ THỐNG', NULL, 'fas fa-cog', 8, N'Menu section hệ thống', 1);
END

-- Admin Child Permissions
IF NOT EXISTS (SELECT 1 FROM permissions WHERE permission_code = 'ADMIN_DASHBOARD')
BEGIN
    INSERT INTO dbo.permissions (permission_id, permission_code, permission_name, parent_code, icon, sort_order, description, is_active) VALUES
    ('PERM_ADM_DASHBOARD', 'ADMIN_DASHBOARD', N'Dashboard', 'ADMIN_SECTION_OVERVIEW', 'fas fa-tachometer-alt', 1, N'Dashboard admin', 1),
    ('PERM_ADM_USERS_ITEM', 'ADMIN_USERS', N'Tài khoản', 'ADMIN_SECTION_USERS', 'fas fa-users', 1, N'Quản lý tài khoản', 1),
    ('PERM_ADM_ROLES', 'ADMIN_ROLES', N'Vai trò & quyền', 'ADMIN_SECTION_USERS', 'fas fa-shield-alt', 2, N'Quản lý vai trò và quyền', 1),
    ('PERM_ADM_ORGANIZATION', 'ADMIN_ORGANIZATION', N'Quản lý đào tạo', 'ADMIN_SECTION_ACADEMIC', 'fas fa-sitemap', 1, N'Quản lý tổ chức đào tạo', 1),
    ('PERM_ADM_STUDENTS', 'ADMIN_STUDENTS', N'Sinh viên', 'ADMIN_SECTION_ACADEMIC', 'fas fa-user-graduate', 2, N'Quản lý sinh viên', 1),
    ('PERM_ADM_LECTURERS', 'ADMIN_LECTURERS', N'Giảng viên', 'ADMIN_SECTION_ACADEMIC', 'fas fa-chalkboard-teacher', 3, N'Quản lý giảng viên', 1),
    ('PERM_ADM_ACADEMIC_YEARS', 'ADMIN_ACADEMIC_YEARS', N'Niên khóa', 'ADMIN_SECTION_ACADEMIC', 'fas fa-calendar-alt', 4, N'Quản lý niên khóa', 1),
    ('PERM_ADM_SCHOOL_YEARS', 'ADMIN_SCHOOL_YEARS', N'Năm học', 'ADMIN_SECTION_ACADEMIC', 'fas fa-calendar-check', 5, N'Quản lý năm học', 1),
    ('PERM_ADM_SUBJECT_PREREQUISITES', 'ADMIN_SUBJECT_PREREQUISITES', N'Tiên quyết', 'ADMIN_SECTION_SUBJECTS', 'fas fa-project-diagram', 1, N'Quản lý tiên quyết môn học', 1),
    ('PERM_ADM_CLASSES', 'ADMIN_CLASSES', N'Lớp học phần', 'ADMIN_SECTION_SUBJECTS', 'fas fa-chalkboard', 2, N'Quản lý lớp học phần', 1),
    ('PERM_ADM_ADMIN_CLASSES', 'ADMIN_ADMIN_CLASSES', N'Lớp chính khóa', 'ADMIN_SECTION_CLASSES', 'fas fa-users-class', 1, N'Quản lý lớp chính khóa', 1),
    ('PERM_ADM_REGISTRATION_PERIODS', 'ADMIN_REGISTRATION_PERIODS', N'Đợt đăng ký', 'ADMIN_SECTION_ENROLLMENT', 'fas fa-clock', 1, N'Quản lý đợt đăng ký học phần', 1),
    ('PERM_ADM_ENROLLMENTS', 'ADMIN_ENROLLMENTS', N'Quản lý đăng ký', 'ADMIN_SECTION_ENROLLMENT', 'fas fa-clipboard-list', 2, N'Quản lý đăng ký học phần', 1),
    ('PERM_ADM_TIMETABLE_ITEM', 'ADMIN_TIMETABLE', N'Xếp lịch', 'ADMIN_SECTION_TIMETABLE', 'fas fa-calendar-alt', 1, N'Quản lý thời khóa biểu', 1),
    ('PERM_ADM_REPORTS', 'ADMIN_REPORTS', N'Báo cáo', 'ADMIN_SECTION_TIMETABLE', 'fas fa-chart-bar', 2, N'Xem báo cáo tổng hợp hệ thống', 1),
    ('PERM_ADM_AUDIT_LOGS', 'ADMIN_AUDIT_LOGS', N'Nhật ký hệ thống', 'ADMIN_SECTION_SYSTEM', 'fas fa-history', 1, N'Xem nhật ký hệ thống', 1),
    ('PERM_ADM_NOTIFICATIONS', 'ADMIN_NOTIFICATIONS', N'Thông báo', 'ADMIN_SECTION_SYSTEM', 'fas fa-bell', 2, N'Quản lý thông báo', 1);
END

PRINT '   ✅ Menu permissions created';
GO

-- ===========================================
-- 4. ROLE_PERMISSIONS (Assign Permissions to Roles)
-- ===========================================
PRINT '🔗 Assigning Permissions to Roles...';

-- Student Role
IF NOT EXISTS (SELECT 1 FROM role_permissions WHERE role_id = 'ROLE_STUDENT' AND permission_id = 'PERM_STU_DASHBOARD')
BEGIN
    INSERT INTO dbo.role_permissions (role_id, permission_id) VALUES
    ('ROLE_STUDENT', 'PERM_STU_OVERVIEW'),
    ('ROLE_STUDENT', 'PERM_STU_DASHBOARD'),
    ('ROLE_STUDENT', 'PERM_STU_STUDY'),
    ('ROLE_STUDENT', 'PERM_STU_TIMETABLE'),
    ('ROLE_STUDENT', 'PERM_STU_SCHEDULE'),
    ('ROLE_STUDENT', 'PERM_STU_GRADES'),
    ('ROLE_STUDENT', 'PERM_STU_ATTENDANCE'),
    ('ROLE_STUDENT', 'PERM_STU_ENROLLMENT'),
    ('ROLE_STUDENT', 'PERM_STU_RETAKES'),
    ('ROLE_STUDENT', 'PERM_STU_APPEALS'),
    ('ROLE_STUDENT', 'PERM_STU_REPORTS'),
    ('ROLE_STUDENT', 'PERM_STU_PROFILE'),
    ('ROLE_STUDENT', 'PERM_STU_PROFILE_ITEM'),
    ('ROLE_STUDENT', 'PERM_STU_SYSTEM'),
    ('ROLE_STUDENT', 'PERM_STU_NOTIFICATIONS');
    PRINT '   ✅ Student permissions assigned';
END

-- Lecturer Role
IF NOT EXISTS (SELECT 1 FROM role_permissions WHERE role_id = 'ROLE_LECTURER' AND permission_id = 'PERM_TCH_DASHBOARD')
BEGIN
    INSERT INTO dbo.role_permissions (role_id, permission_id) VALUES
    ('ROLE_LECTURER', 'PERM_TCH_OVERVIEW'),
    ('ROLE_LECTURER', 'PERM_TCH_DASHBOARD'),
    ('ROLE_LECTURER', 'PERM_TCH_TEACHING'),
    ('ROLE_LECTURER', 'PERM_TCH_ATTENDANCE'),
    ('ROLE_LECTURER', 'PERM_TCH_GRADES'),
    ('ROLE_LECTURER', 'PERM_TCH_APPEALS'),
    ('ROLE_LECTURER', 'PERM_TCH_TIMETABLE'),
    ('ROLE_LECTURER', 'PERM_TCH_REPORTS'),
    ('ROLE_LECTURER', 'PERM_TCH_SYSTEM'),
    ('ROLE_LECTURER', 'PERM_TCH_NOTIFICATIONS');
    PRINT '   ✅ Lecturer permissions assigned';
END

-- Advisor Role
IF NOT EXISTS (SELECT 1 FROM role_permissions WHERE role_id = 'ROLE_ADVISOR' AND permission_id = 'PERM_ADV_DASHBOARD')
BEGIN
    INSERT INTO dbo.role_permissions (role_id, permission_id) VALUES
    ('ROLE_ADVISOR', 'PERM_ADV_OVERVIEW'),
    ('ROLE_ADVISOR', 'PERM_ADV_DASHBOARD'),
    ('ROLE_ADVISOR', 'PERM_ADV_ADVISING'),
    ('ROLE_ADVISOR', 'PERM_ADV_STUDENTS'),
    ('ROLE_ADVISOR', 'PERM_ADV_WARNINGS'),
    ('ROLE_ADVISOR', 'PERM_ADV_APPEALS'),
    ('ROLE_ADVISOR', 'PERM_ADV_GRADE_FORMULA'),
    ('ROLE_ADVISOR', 'PERM_ADV_ENROLLMENTS'),
    ('ROLE_ADVISOR', 'PERM_ADV_RETAKES'),
    ('ROLE_ADVISOR', 'PERM_ADV_REPORTS'),
    ('ROLE_ADVISOR', 'PERM_ADV_SYSTEM'),
    ('ROLE_ADVISOR', 'PERM_ADV_NOTIFICATIONS');
    PRINT '   ✅ Advisor permissions assigned';
END

-- Admin Role - Assign ALL permissions
IF NOT EXISTS (SELECT 1 FROM role_permissions WHERE role_id = 'ROLE_ADMIN' AND permission_id = 'PERM_ADM_DASHBOARD')
BEGIN
    INSERT INTO dbo.role_permissions (role_id, permission_id) VALUES
    -- Admin Overview
    ('ROLE_ADMIN', 'PERM_ADM_OVERVIEW'),
    ('ROLE_ADMIN', 'PERM_ADM_DASHBOARD'),
    -- Admin Users
    ('ROLE_ADMIN', 'PERM_ADM_USERS'),
    ('ROLE_ADMIN', 'PERM_ADM_USERS_ITEM'),
    ('ROLE_ADMIN', 'PERM_ADM_ROLES'),
    -- Admin Academic
    ('ROLE_ADMIN', 'PERM_ADM_ACADEMIC'),
    ('ROLE_ADMIN', 'PERM_ADM_ORGANIZATION'),
    ('ROLE_ADMIN', 'PERM_ADM_STUDENTS'),
    ('ROLE_ADMIN', 'PERM_ADM_LECTURERS'),
    ('ROLE_ADMIN', 'PERM_ADM_ACADEMIC_YEARS'),
    ('ROLE_ADMIN', 'PERM_ADM_SCHOOL_YEARS'),
    -- Admin Subjects
    ('ROLE_ADMIN', 'PERM_ADM_SUBJECTS'),
    ('ROLE_ADMIN', 'PERM_ADM_SUBJECT_PREREQUISITES'),
    ('ROLE_ADMIN', 'PERM_ADM_CLASSES'),
    -- Admin Classes
    ('ROLE_ADMIN', 'PERM_ADM_ADMIN_CLASSES_SECTION'),
    ('ROLE_ADMIN', 'PERM_ADM_ADMIN_CLASSES'),
    -- Admin Enrollment
    ('ROLE_ADMIN', 'PERM_ADM_ENROLLMENT'),
    ('ROLE_ADMIN', 'PERM_ADM_REGISTRATION_PERIODS'),
    ('ROLE_ADMIN', 'PERM_ADM_ENROLLMENTS'),
    -- Admin Timetable
    ('ROLE_ADMIN', 'PERM_ADM_TIMETABLE'),
    ('ROLE_ADMIN', 'PERM_ADM_TIMETABLE_ITEM'),
    ('ROLE_ADMIN', 'PERM_ADM_REPORTS'),
    -- Admin System
    ('ROLE_ADMIN', 'PERM_ADM_SYSTEM'),
    ('ROLE_ADMIN', 'PERM_ADM_AUDIT_LOGS'),
    ('ROLE_ADMIN', 'PERM_ADM_NOTIFICATIONS');
    PRINT '   ✅ Admin permissions assigned';
END

PRINT '   ✅ All role-permission mappings completed';
GO

-- ===========================================
-- SUMMARY
-- ===========================================
PRINT '';
PRINT '╔════════════════════════════════════════════════╗';
PRINT '║     ✅ MINIMAL SETUP COMPLETED                  ║';
PRINT '╚════════════════════════════════════════════════╝';
PRINT '';
PRINT '📊 Summary:';
PRINT '   ✅ 4 Roles (Admin, Lecturer, Student, Advisor)';
PRINT '   ✅ 1 Admin User';
PRINT '   ✅ 60+ Menu Permissions (bao gồm Reports, Retakes, Appeals)';
PRINT '   ✅ Role-Permission mappings';
PRINT '';
PRINT '🔑 Login Credentials:';
PRINT '   👤 Username: admin';
PRINT '   🔑 Password: admin123';
PRINT '';
PRINT '📝 Next Steps:';
PRINT '   1. Đăng nhập với tài khoản admin';
PRINT '   2. Thêm dữ liệu từ frontend theo thứ tự:';
PRINT '      → Quản lý đào tạo: Khoa → Bộ môn → Ngành học';
PRINT '      → Niên khóa → Năm học';
PRINT '      → Môn học → Lớp học phần';
PRINT '      → Sinh viên → Giảng viên → Cố vấn';
PRINT '      → Đợt đăng ký → Đăng ký học phần';
PRINT '      → Thời khóa biểu';
PRINT '';
PRINT '💡 Tip: Bạn có thể thêm dữ liệu từng bước một';
PRINT '   hoặc import từ Excel nếu có chức năng import.';
PRINT '';
GO

