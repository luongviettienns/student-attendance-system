-- ====================================
-- 1. Tạo Database EducationManagement
-- ====================================
USE master;
GO

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'EducationManagement')
BEGIN
    CREATE DATABASE EducationManagement;
END
GO

USE EducationManagement;
GO

-- ====================================
-- Bảng Roles (chuẩn BTL)
-- ====================================
IF OBJECT_ID('dbo.roles', 'U') IS NOT NULL
    DROP TABLE dbo.roles;
GO

CREATE TABLE dbo.roles (
    role_id      VARCHAR(50) NOT NULL PRIMARY KEY,        -- Khóa chính
    role_name    NVARCHAR(100) NOT NULL UNIQUE,           -- Tên vai trò (Admin, Lecturer, Student, Advisor)
    description  NVARCHAR(255) NULL,                      -- Mô tả chi tiết

    -- Audit
    created_at   DATETIME NOT NULL DEFAULT(GETDATE()),
    created_by   VARCHAR(50) NULL,
    updated_at   DATETIME NULL,
    updated_by   VARCHAR(50) NULL,

    -- Soft delete
    is_active    BIT NOT NULL DEFAULT 1,
    deleted_at   DATETIME NULL,
    deleted_by   VARCHAR(50) NULL
);
GO

-- Seed data cho các vai trò mặc định
INSERT INTO dbo.roles (role_id, role_name, description, created_by)
VALUES
('role-001', N'Admin',    N'Quản trị hệ thống', 'system'),
('role-002', N'Lecturer', N'Giảng viên',         'system'),
('role-003', N'Student',  N'Sinh viên',          'system'),
('role-004', N'Advisor',  N'Cố vấn học tập',     'system');
GO
-- ====================================
-- Bảng Users (chuẩn BTL)
-- ====================================
IF OBJECT_ID('dbo.users', 'U') IS NOT NULL
    DROP TABLE dbo.users;
GO

CREATE TABLE dbo.users (
    user_id        VARCHAR(50) NOT NULL PRIMARY KEY,     -- Khóa chính
    username       VARCHAR(50) NOT NULL UNIQUE,          -- Tài khoản đăng nhập
    password_hash  VARCHAR(255) NOT NULL,                -- Mật khẩu (đã hash)
    email          VARCHAR(150) NOT NULL UNIQUE,         -- Email (dùng cho login/khôi phục)
    phone          VARCHAR(20) NULL,                     -- SĐT
    full_name      NVARCHAR(150) NOT NULL,               -- Họ tên
    avatar_url     VARCHAR(300) NULL,                    -- Ảnh đại diện

    -- RBAC
    role_id        VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES dbo.roles(role_id),

    -- Trạng thái
    is_active      BIT NOT NULL DEFAULT 1,               -- Đang hoạt động
    last_login_at  DATETIME NULL,                        -- Lần đăng nhập cuối

    -- Audit
    created_at     DATETIME NOT NULL DEFAULT(GETDATE()),
    created_by     VARCHAR(50) NULL,
    updated_at     DATETIME NULL,
    updated_by     VARCHAR(50) NULL,

    -- Soft delete
    deleted_at     DATETIME NULL,
    deleted_by     VARCHAR(50) NULL
);
GO

-- Seed data: Tài khoản admin mặc định
--TK admin
INSERT INTO dbo.users (user_id, username, password_hash, email, full_name, role_id, is_active, created_by)
VALUES
('user-001', 'admin', '$2b$12$wQ8PKj60xkkAo7df4YyF5OZiLPG3hAJIMLeKMmxy1g6PUP.pWtUs6', --admin123
 'admin@edu.com', N'System Administrator', 'role-001', 1, 'system');
GO
--TK stu01
INSERT INTO dbo.users (user_id, username, password_hash, email, full_name, role_id, is_active, created_by)
VALUES
('user-002', 'sv2024001', '$2b$12$wQ8PKj60xkkAo7df4YyF5OZiLPG3hAJIMLeKMmxy1g6PUP.pWtUs6', 
 'sv2024001@edu.com', N'Nguyễn Văn A', 'role-003', 1, 'system');

-- ====================================
-- Bảng Students (chuẩn BTL)
-- ====================================
IF OBJECT_ID('dbo.students', 'U') IS NOT NULL
    DROP TABLE dbo.students;
GO

CREATE TABLE dbo.students (
    student_id       VARCHAR(50) NOT NULL PRIMARY KEY,         -- Khóa chính
    user_id          VARCHAR(50) NOT NULL UNIQUE,              -- FK tới users (1 user = 1 sinh viên)
    student_code     VARCHAR(20) NOT NULL UNIQUE,              -- Mã sinh viên
    full_name        NVARCHAR(150) NOT NULL,                   -- Họ tên
    gender           NVARCHAR(10) NULL,                        -- Giới tính
    dob              DATE NULL,                                -- Ngày sinh
    email            VARCHAR(150) NULL,                        -- Email liên hệ
    phone            VARCHAR(20) NULL,                         -- SĐT
    faculty_id       VARCHAR(50) NULL,                         -- FK sau này tới bảng faculties
    major_id         VARCHAR(50) NULL,                         -- FK sau này tới bảng majors
    academic_year_id VARCHAR(50) NULL,                         -- FK sau này tới bảng academic_years
    cohort_year      VARCHAR(10) NULL,                         -- Năm nhập học

    -- Trạng thái
    is_active        BIT NOT NULL DEFAULT 1,

    -- Audit
    created_at       DATETIME NOT NULL DEFAULT(GETDATE()),
    created_by       VARCHAR(50) NULL,
    updated_at       DATETIME NULL,
    updated_by       VARCHAR(50) NULL,

    -- Soft delete
    deleted_at       DATETIME NULL,
    deleted_by       VARCHAR(50) NULL,

    -- Ràng buộc khóa ngoại
    CONSTRAINT FK_students_users FOREIGN KEY (user_id) REFERENCES dbo.users(user_id)
);
GO

-- Seed data mẫu cho 1 sinh viên
INSERT INTO dbo.students (student_id, user_id, student_code, full_name, gender, dob, email, phone, cohort_year, created_by)
VALUES
('stu-001', 'user-002', 'SV2024001', N'Nguyễn Văn A', N'Nam', '2004-05-12', 'vana.sv@edu.com', '0912345678', '2024', 'system');
GO
-- ====================================
-- Bảng Student Profiles (chi tiết sinh viên)
-- ====================================
IF OBJECT_ID('dbo.student_profiles', 'U') IS NOT NULL
    DROP TABLE dbo.student_profiles;
GO

CREATE TABLE dbo.student_profiles (
    student_id       VARCHAR(50) NOT NULL PRIMARY KEY,        -- Khóa chính, đồng thời FK
    nationality      NVARCHAR(50) NULL,                       -- Quốc tịch
    ethnicity        NVARCHAR(30) NULL,                       -- Dân tộc
    religion         NVARCHAR(50) NULL,                       -- Tôn giáo
    hometown         NVARCHAR(250) NULL,                      -- Quê quán
    current_address  NVARCHAR(250) NULL,                      -- Địa chỉ hiện tại
    bank_no          VARCHAR(30) NULL,                        -- Số tài khoản
    bank_name        NVARCHAR(100) NULL,                      -- Tên ngân hàng
    insurance_no     VARCHAR(30) NULL,                        -- Số bảo hiểm
    issue_place      NVARCHAR(100) NULL,                      -- Nơi cấp CMND/CCCD
    issue_date       DATE NULL,                               -- Ngày cấp
    facebook         NVARCHAR(200) NULL,                      -- Facebook

    -- Audit
    created_at       DATETIME NOT NULL DEFAULT(GETDATE()),
    created_by       VARCHAR(50) NULL,
    updated_at       DATETIME NULL,
    updated_by       VARCHAR(50) NULL,

    -- Soft delete
    is_active        BIT NOT NULL DEFAULT 1,
    deleted_at       DATETIME NULL,
    deleted_by       VARCHAR(50) NULL,

    CONSTRAINT FK_student_profiles_students FOREIGN KEY (student_id) REFERENCES dbo.students(student_id)
);
GO

-- Seed data: bổ sung profile cho sinh viên stu-001
INSERT INTO dbo.student_profiles (student_id, nationality, ethnicity, religion, hometown, current_address, created_by)
VALUES
('stu-001', N'Việt Nam', N'Kinh', N'Không', N'Hà Nội', N'Cầu Giấy, Hà Nội', 'system');
GO

-- ====================================
-- Bảng Student Family (thông tin người thân của sinh viên)
-- ====================================
IF OBJECT_ID('dbo.student_family', 'U') IS NOT NULL
    DROP TABLE dbo.student_family;
GO

CREATE TABLE dbo.student_family (
    student_family_id VARCHAR(50) NOT NULL PRIMARY KEY,       -- Khóa chính
    student_id        VARCHAR(50) NOT NULL,                   -- FK tới students
    relation_type     NVARCHAR(30) NOT NULL,                  -- Quan hệ (Cha, Mẹ, Người bảo hộ...)
    full_name         NVARCHAR(150) NOT NULL,                 -- Họ tên
    birth_year        INT NULL,                               -- Năm sinh
    phone             VARCHAR(20) NULL,                       -- SĐT
    nationality       NVARCHAR(50) NULL,                      -- Quốc tịch
    ethnicity         NVARCHAR(30) NULL,                      -- Dân tộc
    religion          NVARCHAR(50) NULL,                      -- Tôn giáo
    permanent_address NVARCHAR(250) NULL,                     -- Địa chỉ thường trú
    job               NVARCHAR(150) NULL,                     -- Nghề nghiệp

    -- Audit
    created_at        DATETIME NOT NULL DEFAULT(GETDATE()),
    created_by        VARCHAR(50) NULL,
    updated_at        DATETIME NULL,
    updated_by        VARCHAR(50) NULL,

    -- Soft delete
    is_active         BIT NOT NULL DEFAULT 1,
    deleted_at        DATETIME NULL,
    deleted_by        VARCHAR(50) NULL,

    CONSTRAINT FK_student_family_students FOREIGN KEY (student_id) REFERENCES dbo.students(student_id)
);
GO

-- Seed data: thêm người thân cho sinh viên stu-001
INSERT INTO dbo.student_family (student_family_id, student_id, relation_type, full_name, birth_year, phone, job, created_by)
VALUES
('stufam-001', 'stu-001', N'Cha', N'Nguyễn Văn B', 1975, '0909123456', N'Kỹ sư xây dựng', 'system'),
('stufam-002', 'stu-001', N'Mẹ', N'Trần Thị C', 1978, '0912233445', N'Giáo viên', 'system');
GO
-- ====================================
-- Bảng Faculties (Khoa)
-- ====================================
IF OBJECT_ID('dbo.faculties', 'U') IS NOT NULL
    DROP TABLE dbo.faculties;
GO

CREATE TABLE dbo.faculties (
    faculty_id   VARCHAR(50) NOT NULL PRIMARY KEY,
    faculty_code VARCHAR(20) NOT NULL UNIQUE,
    faculty_name NVARCHAR(200) NOT NULL,
    description  NVARCHAR(255) NULL,

    -- Audit
    created_at   DATETIME NOT NULL DEFAULT(GETDATE()),
    created_by   VARCHAR(50) NULL,
    updated_at   DATETIME NULL,
    updated_by   VARCHAR(50) NULL,

    -- Soft delete
    is_active    BIT NOT NULL DEFAULT 1,
    deleted_at   DATETIME NULL,
    deleted_by   VARCHAR(50) NULL
);
GO

-- Seed data Khoa
INSERT INTO dbo.faculties (faculty_id, faculty_code, faculty_name, created_by)
VALUES
('fac-001', 'CS', N'Công nghệ thông tin', 'system'),
('fac-002', 'ENG', N'Ngoại ngữ', 'system');
GO


-- ====================================
-- Bảng Majors (Ngành học)
-- ====================================
IF OBJECT_ID('dbo.majors', 'U') IS NOT NULL
    DROP TABLE dbo.majors;
GO

CREATE TABLE dbo.majors (
    major_id     VARCHAR(50) NOT NULL PRIMARY KEY,
    major_code   VARCHAR(20) NOT NULL UNIQUE,
    major_name   NVARCHAR(200) NOT NULL,
    faculty_id   VARCHAR(50) NOT NULL,

    -- Audit
    created_at   DATETIME NOT NULL DEFAULT(GETDATE()),
    created_by   VARCHAR(50) NULL,
    updated_at   DATETIME NULL,
    updated_by   VARCHAR(50) NULL,

    -- Soft delete
    is_active    BIT NOT NULL DEFAULT 1,
    deleted_at   DATETIME NULL,
    deleted_by   VARCHAR(50) NULL,

    CONSTRAINT FK_majors_faculties FOREIGN KEY (faculty_id) REFERENCES dbo.faculties(faculty_id)
);
GO

-- Seed data Ngành
INSERT INTO dbo.majors (major_id, major_code, major_name, faculty_id, created_by)
VALUES
('maj-001', 'SE', N'Kỹ thuật phần mềm', 'fac-001', 'system'),
('maj-002', 'EL', N'Ngôn ngữ Anh', 'fac-002', 'system');
GO


-- ====================================
-- Bảng Academic Years (Niên khóa)
-- ====================================
IF OBJECT_ID('dbo.academic_years', 'U') IS NOT NULL
    DROP TABLE dbo.academic_years;
GO

CREATE TABLE dbo.academic_years (
    academic_year_id VARCHAR(50) NOT NULL PRIMARY KEY,
    year_code        VARCHAR(20) NOT NULL UNIQUE,   -- Ví dụ: 2024-2025
    description      NVARCHAR(255) NULL,

    -- Audit
    created_at       DATETIME NOT NULL DEFAULT(GETDATE()),
    created_by       VARCHAR(50) NULL,
    updated_at       DATETIME NULL,
    updated_by       VARCHAR(50) NULL,

    -- Soft delete
    is_active        BIT NOT NULL DEFAULT 1,
    deleted_at       DATETIME NULL,
    deleted_by       VARCHAR(50) NULL
);
GO

-- Seed data Niên khóa
INSERT INTO dbo.academic_years (academic_year_id, year_code, description, created_by)
VALUES
('acy-001', '2024-2025', N'Niên khóa 2024-2025', 'system'),
('acy-002', '2025-2026', N'Niên khóa 2025-2026', 'system');
GO
-- ====================================
-- Bảng Configs (cấu hình hệ thống)
-- ====================================
IF OBJECT_ID('dbo.configs', 'U') IS NOT NULL
    DROP TABLE dbo.configs;
GO

CREATE TABLE dbo.configs (
    config_key    VARCHAR(100) NOT NULL PRIMARY KEY,   -- Khóa cấu hình
    config_value  NVARCHAR(1000) NOT NULL,             -- Giá trị (string/JSON)

    -- Audit
    created_at    DATETIME NOT NULL DEFAULT(GETDATE()),
    created_by    VARCHAR(50) NULL,
    updated_at    DATETIME NULL,
    updated_by    VARCHAR(50) NULL,

    -- Soft delete
    is_active     BIT NOT NULL DEFAULT 1,
    deleted_at    DATETIME NULL,
    deleted_by    VARCHAR(50) NULL
);
GO

-- Seed data cho các cấu hình mặc định
INSERT INTO dbo.configs (config_key, config_value, created_by)
VALUES
('ATTENDANCE_THRESHOLD_PERCENT', '20', 'system'),   -- Vắng quá 20% sẽ cảnh báo
('GRADE_FORMULA_JSON', '{"quiz":0.2,"midterm":0.3,"final":0.5}', 'system'); -- Công thức điểm
GO
-- ====================================
-- Bảng Audit Logs (ghi lịch sử thao tác)
-- ====================================
IF OBJECT_ID('dbo.audit_logs', 'U') IS NOT NULL
    DROP TABLE dbo.audit_logs;
GO

CREATE TABLE dbo.audit_logs (
    log_id       VARCHAR(50) NOT NULL PRIMARY KEY,   -- Khóa chính (UUID)
    user_id      VARCHAR(50) NULL,                   -- Ai thực hiện (FK users)
    action       VARCHAR(50) NOT NULL,               -- Hành động (INSERT/UPDATE/DELETE/LOGIN...)
    table_name   VARCHAR(100) NOT NULL,              -- Bảng tác động
    record_id    VARCHAR(50) NULL,                   -- ID bản ghi bị tác động
    old_values   NVARCHAR(MAX) NULL,                 -- Giá trị trước khi thay đổi
    new_values   NVARCHAR(MAX) NULL,                 -- Giá trị sau khi thay đổi
    ip_address   VARCHAR(50) NULL,                   -- Địa chỉ IP
    user_agent   NVARCHAR(500) NULL,                 -- Trình duyệt/thiết bị

    -- Audit log cũng cần audit!
    created_at   DATETIME NOT NULL DEFAULT(GETDATE()), 
    created_by   VARCHAR(50) NULL,
    updated_at   DATETIME NULL,
    updated_by   VARCHAR(50) NULL,

    -- Soft delete
    is_active    BIT NOT NULL DEFAULT 1,
    deleted_at   DATETIME NULL,
    deleted_by   VARCHAR(50) NULL,

    CONSTRAINT FK_auditlogs_users FOREIGN KEY (user_id) REFERENCES dbo.users(user_id)
);
GO
-- ====================================
-- Bảng Subjects (môn học)
-- ====================================
IF OBJECT_ID('dbo.subjects', 'U') IS NOT NULL
    DROP TABLE dbo.subjects;
GO

CREATE TABLE dbo.subjects (
    subject_id    VARCHAR(50) NOT NULL PRIMARY KEY,     -- Khóa chính
    subject_code  VARCHAR(20) NOT NULL UNIQUE,          -- Mã môn học (CS101, MATH101)
    subject_name  NVARCHAR(200) NOT NULL,               -- Tên môn học
    credits       INT NOT NULL,                         -- Số tín chỉ
    description   NVARCHAR(500) NULL,                   -- Mô tả

    -- Audit
    created_at    DATETIME NOT NULL DEFAULT(GETDATE()),
    created_by    VARCHAR(50) NULL,
    updated_at    DATETIME NULL,
    updated_by    VARCHAR(50) NULL,

    -- Soft delete
    is_active     BIT NOT NULL DEFAULT 1,
    deleted_at    DATETIME NULL,
    deleted_by    VARCHAR(50) NULL
);
GO

-- Seed data một số môn học cơ bản
INSERT INTO dbo.subjects (subject_id, subject_code, subject_name, credits, description, created_by)
VALUES
('subj-001', 'CS101',  N'Nhập môn Công nghệ thông tin', 3, N'Các khái niệm cơ bản về CNTT', 'system'),
('subj-002', 'MATH101',N'Giải tích I', 4, N'Đạo hàm, tích phân và ứng dụng', 'system'),
('subj-003', 'ENG101', N'Tiếng Anh cơ bản', 3, N'Kỹ năng tiếng Anh nền tảng', 'system'),
('subj-004', 'PHYS101',N'Vật lý đại cương I', 4, N'Cơ học và nhiệt học', 'system');
GO
-- ====================================
-- Bảng Classes (lớp học phần)
-- ====================================
IF OBJECT_ID('dbo.classes', 'U') IS NOT NULL
    DROP TABLE dbo.classes;
GO

CREATE TABLE dbo.classes (
    class_id        VARCHAR(50) NOT NULL PRIMARY KEY,        -- Khóa chính
    class_code      VARCHAR(20) NOT NULL UNIQUE,             -- Mã lớp học phần (CS101-01)
    class_name      NVARCHAR(200) NOT NULL,                  -- Tên lớp học phần
    subject_id      VARCHAR(50) NOT NULL,                    -- FK tới subjects
    lecturer_id     VARCHAR(50) NOT NULL,                    -- FK tới users (vai trò Lecturer)
    semester        VARCHAR(20) NOT NULL,                    -- Học kỳ (Fall 2024, Spring 2025...)
    academic_year_id VARCHAR(50) NOT NULL,                   -- FK tới academic_years
    max_students    INT NOT NULL DEFAULT 50,                 -- Sĩ số tối đa

    -- Audit
    created_at      DATETIME NOT NULL DEFAULT(GETDATE()),
    created_by      VARCHAR(50) NULL,
    updated_at      DATETIME NULL,
    updated_by      VARCHAR(50) NULL,

    -- Soft delete
    is_active       BIT NOT NULL DEFAULT 1,
    deleted_at      DATETIME NULL,
    deleted_by      VARCHAR(50) NULL,

    -- Ràng buộc
    CONSTRAINT FK_classes_subjects FOREIGN KEY (subject_id) REFERENCES dbo.subjects(subject_id),
    CONSTRAINT FK_classes_lecturers FOREIGN KEY (lecturer_id) REFERENCES dbo.users(user_id),
    CONSTRAINT FK_classes_academicyears FOREIGN KEY (academic_year_id) REFERENCES dbo.academic_years(academic_year_id)
);
GO

-- Seed data: mở một vài lớp học phần
INSERT INTO dbo.classes (class_id, class_code, class_name, subject_id, lecturer_id, semester, academic_year_id, created_by)
VALUES
('class-001', 'CS101-01', N'Nhập môn CNTT - Nhóm 1', 'subj-001', 'user-001', 'Fall 2024', 'acy-001', 'system'),
('class-002', 'MATH101-01', N'Giải tích I - Nhóm 1', 'subj-002', 'user-001', 'Fall 2024', 'acy-001', 'system');
GO
-- ====================================
-- Bảng Schedules (lịch học/thi của lớp)
-- ====================================
IF OBJECT_ID('dbo.schedules', 'U') IS NOT NULL
    DROP TABLE dbo.schedules;
GO

CREATE TABLE dbo.schedules (
    schedule_id   VARCHAR(50) NOT NULL PRIMARY KEY,    -- Khóa chính
    class_id      VARCHAR(50) NOT NULL,                -- FK tới classes
    room          NVARCHAR(50) NULL,                   -- Phòng học
    day_of_week   NVARCHAR(20) NULL,                   -- Thứ (Monday, Tuesday...)
    start_time    DATETIME NOT NULL,                   -- Thời gian bắt đầu
    end_time      DATETIME NOT NULL,                   -- Thời gian kết thúc
    schedule_type VARCHAR(20) NOT NULL DEFAULT 'Lecture', -- Loại: Lecture, Lab, Exam

    -- Audit
    created_at    DATETIME NOT NULL DEFAULT(GETDATE()),
    created_by    VARCHAR(50) NULL,
    updated_at    DATETIME NULL,
    updated_by    VARCHAR(50) NULL,

    -- Soft delete
    is_active     BIT NOT NULL DEFAULT 1,
    deleted_at    DATETIME NULL,
    deleted_by    VARCHAR(50) NULL,

    CONSTRAINT FK_schedules_classes FOREIGN KEY (class_id) REFERENCES dbo.classes(class_id)
);
GO

-- Seed data: lịch học cho CS101-01
INSERT INTO dbo.schedules (schedule_id, class_id, room, day_of_week, start_time, end_time, schedule_type, created_by)
VALUES
('sched-001', 'class-001', N'Phòng 101', N'Monday', '2024-09-09 08:00:00', '2024-09-09 09:30:00', 'Lecture', 'system'),
('sched-002', 'class-001', N'Phòng 101', N'Wednesday', '2024-09-11 08:00:00', '2024-09-11 09:30:00', 'Lecture', 'system'),
('sched-003', 'class-002', N'Phòng 201', N'Tuesday', '2024-09-10 10:00:00', '2024-09-10 11:30:00', 'Lecture', 'system');
GO
-- ====================================
-- Bảng Enrollments (đăng ký học phần)
-- ====================================
IF OBJECT_ID('dbo.enrollments', 'U') IS NOT NULL
    DROP TABLE dbo.enrollments;
GO

CREATE TABLE dbo.enrollments (
    enrollment_id   VARCHAR(50) NOT NULL PRIMARY KEY,  -- Khóa chính
    student_id      VARCHAR(50) NOT NULL,              -- FK tới students
    class_id        VARCHAR(50) NOT NULL,              -- FK tới classes
    enrollment_date DATETIME NOT NULL DEFAULT(GETDATE()), -- Ngày đăng ký
    status          VARCHAR(20) NOT NULL DEFAULT 'Active', -- Trạng thái
    dropped_date    DATETIME NULL,                     -- Ngày hủy
    dropped_reason  NVARCHAR(500) NULL,                -- Lý do hủy

    -- Audit
    created_at      DATETIME NOT NULL DEFAULT(GETDATE()),
    created_by      VARCHAR(50) NULL,
    updated_at      DATETIME NULL,
    updated_by      VARCHAR(50) NULL,

    -- Soft delete
    is_active       BIT NOT NULL DEFAULT 1,
    deleted_at      DATETIME NULL,
    deleted_by      VARCHAR(50) NULL,

    CONSTRAINT FK_enrollments_students FOREIGN KEY (student_id) REFERENCES dbo.students(student_id),
    CONSTRAINT FK_enrollments_classes FOREIGN KEY (class_id) REFERENCES dbo.classes(class_id),
    CONSTRAINT UQ_enrollments_student_class UNIQUE (student_id, class_id) -- tránh đăng ký trùng
);
GO

-- Seed data: Nguyễn Văn A đăng ký lớp CS101-01
INSERT INTO dbo.enrollments (enrollment_id, student_id, class_id, created_by)
VALUES
('enr-001', 'stu-001', 'class-001', 'system');
GO
-- ====================================
-- Bảng Attendances (điểm danh sinh viên)
-- ====================================
IF OBJECT_ID('dbo.attendances', 'U') IS NOT NULL
    DROP TABLE dbo.attendances;
GO

CREATE TABLE dbo.attendances (
    attendance_id   VARCHAR(50) NOT NULL PRIMARY KEY,    -- Khóa chính
    student_id      VARCHAR(50) NOT NULL,                -- FK tới students
    schedule_id     VARCHAR(50) NOT NULL,                -- FK tới schedules
    attendance_date DATETIME NOT NULL DEFAULT(GETDATE()),-- Ngày điểm danh
    status          VARCHAR(20) NOT NULL,                -- Present/Absent/Late/Excused
    notes           NVARCHAR(500) NULL,                  -- Ghi chú
    marked_by       VARCHAR(50) NULL,                    -- Ai điểm danh (FK users)

    -- Audit
    created_at      DATETIME NOT NULL DEFAULT(GETDATE()),
    created_by      VARCHAR(50) NULL,
    updated_at      DATETIME NULL,
    updated_by      VARCHAR(50) NULL,

    -- Soft delete
    is_active       BIT NOT NULL DEFAULT 1,
    deleted_at      DATETIME NULL,
    deleted_by      VARCHAR(50) NULL,

    CONSTRAINT FK_attendances_students FOREIGN KEY (student_id) REFERENCES dbo.students(student_id),
    CONSTRAINT FK_attendances_schedules FOREIGN KEY (schedule_id) REFERENCES dbo.schedules(schedule_id),
    CONSTRAINT FK_attendances_users FOREIGN KEY (marked_by) REFERENCES dbo.users(user_id),
    CONSTRAINT UQ_attendance_student_schedule UNIQUE (student_id, schedule_id) -- 1 SV chỉ 1 bản ghi/1 lịch
);
GO

-- Seed data: điểm danh Nguyễn Văn A buổi học đầu tiên
INSERT INTO dbo.attendances (attendance_id, student_id, schedule_id, status, marked_by, created_by)
VALUES
('att-001', 'stu-001', 'sched-001', 'Present', 'user-001', 'system');
GO
-- ====================================
-- Bảng Grades (điểm số sinh viên)
-- ====================================
IF OBJECT_ID('dbo.grades', 'U') IS NOT NULL
    DROP TABLE dbo.grades;
GO

CREATE TABLE dbo.grades (
    grade_id     VARCHAR(50) NOT NULL PRIMARY KEY,     -- Khóa chính
    student_id   VARCHAR(50) NOT NULL,                 -- FK tới students
    class_id     VARCHAR(50) NOT NULL,                 -- FK tới classes
    grade_type   VARCHAR(20) NOT NULL,                 -- Quiz, Midterm, Final...
    score        DECIMAL(5,2) NOT NULL,                -- Điểm đạt được
    max_score    DECIMAL(5,2) NOT NULL DEFAULT 10.0,   -- Thang điểm
    weight       DECIMAL(5,2) NOT NULL DEFAULT 1.0,    -- Trọng số
    notes        NVARCHAR(500) NULL,                   -- Ghi chú
    graded_by    VARCHAR(50) NULL,                     -- Ai nhập điểm (FK users)

    -- Audit
    created_at   DATETIME NOT NULL DEFAULT(GETDATE()),
    created_by   VARCHAR(50) NULL,
    updated_at   DATETIME NULL,
    updated_by   VARCHAR(50) NULL,

    -- Soft delete
    is_active    BIT NOT NULL DEFAULT 1,
    deleted_at   DATETIME NULL,
    deleted_by   VARCHAR(50) NULL,

    CONSTRAINT FK_grades_students FOREIGN KEY (student_id) REFERENCES dbo.students(student_id),
    CONSTRAINT FK_grades_classes FOREIGN KEY (class_id) REFERENCES dbo.classes(class_id),
    CONSTRAINT FK_grades_users FOREIGN KEY (graded_by) REFERENCES dbo.users(user_id),
    CONSTRAINT UQ_grade_student_class_type UNIQUE (student_id, class_id, grade_type) -- tránh trùng điểm
);
GO

-- Seed data: Nguyễn Văn A có điểm quiz đầu tiên
INSERT INTO dbo.grades (grade_id, student_id, class_id, grade_type, score, max_score, weight, graded_by, created_by)
VALUES
('grade-001', 'stu-001', 'class-001', 'Quiz', 8.5, 10, 0.2, 'user-001', 'system');
GO
-- ====================================
-- Bảng Appeals (phúc khảo điểm)
-- ====================================
IF OBJECT_ID('dbo.appeals', 'U') IS NOT NULL
    DROP TABLE dbo.appeals;
GO

CREATE TABLE dbo.appeals (
    appeal_id     VARCHAR(50) NOT NULL PRIMARY KEY,       -- Khóa chính
    student_id    VARCHAR(50) NOT NULL,                   -- FK tới students
    grade_id      VARCHAR(50) NOT NULL,                   -- FK tới grades
    reason        NVARCHAR(1000) NOT NULL,                -- Lý do phúc khảo
    status        VARCHAR(20) NOT NULL DEFAULT 'Pending', -- Trạng thái: Pending/Approved/Rejected
    review_notes  NVARCHAR(1000) NULL,                    -- Ghi chú khi duyệt
    reviewed_by   VARCHAR(50) NULL,                       -- Ai duyệt (FK users)
    reviewed_at   DATETIME NULL,                          -- Thời gian duyệt

    -- Audit
    created_at    DATETIME NOT NULL DEFAULT(GETDATE()),
    created_by    VARCHAR(50) NULL,
    updated_at    DATETIME NULL,
    updated_by    VARCHAR(50) NULL,

    -- Soft delete
    is_active     BIT NOT NULL DEFAULT 1,
    deleted_at    DATETIME NULL,
    deleted_by    VARCHAR(50) NULL,

    CONSTRAINT FK_appeals_students FOREIGN KEY (student_id) REFERENCES dbo.students(student_id),
    CONSTRAINT FK_appeals_grades FOREIGN KEY (grade_id) REFERENCES dbo.grades(grade_id),
    CONSTRAINT FK_appeals_users FOREIGN KEY (reviewed_by) REFERENCES dbo.users(user_id)
);
GO

-- Seed data: Nguyễn Văn A phúc khảo điểm quiz
INSERT INTO dbo.appeals (appeal_id, student_id, grade_id, reason, status, created_by)
VALUES
('apl-001', 'stu-001', 'grade-001', N'Em thấy điểm quiz bị chấm sai, mong thầy cô xem lại.', 'Pending', 'system');
GO
-- ====================================
-- Bảng Notifications (thông báo)
-- ====================================
IF OBJECT_ID('dbo.notifications', 'U') IS NOT NULL
    DROP TABLE dbo.notifications;
GO

CREATE TABLE dbo.notifications (
    notification_id VARCHAR(50) NOT NULL PRIMARY KEY,     -- Khóa chính
    recipient_id    VARCHAR(50) NOT NULL,                 -- Ai nhận (FK users)
    title           NVARCHAR(200) NOT NULL,               -- Tiêu đề
    content         NVARCHAR(2000) NOT NULL,              -- Nội dung
    type            VARCHAR(50) NOT NULL,                 -- AttendanceWarning, GradeUpdate, System...
    is_read         BIT NOT NULL DEFAULT 0,               -- Đã đọc chưa
    sent_date       DATETIME NULL,                        -- Thời gian gửi

    -- Audit
    created_at      DATETIME NOT NULL DEFAULT(GETDATE()),
    created_by      VARCHAR(50) NULL,
    updated_at      DATETIME NULL,
    updated_by      VARCHAR(50) NULL,

    -- Soft delete
    is_active       BIT NOT NULL DEFAULT 1,
    deleted_at      DATETIME NULL,
    deleted_by      VARCHAR(50) NULL,

    CONSTRAINT FK_notifications_users FOREIGN KEY (recipient_id) REFERENCES dbo.users(user_id)
);
GO

-- Seed data: cảnh báo chuyên cần cho Nguyễn Văn A
INSERT INTO dbo.notifications (notification_id, recipient_id, title, content, type, created_by)
VALUES
('noti-001', 'user-002', N'Cảnh báo chuyên cần', N'Bạn đã vắng 2 buổi học môn CS101, vui lòng chú ý.', 'AttendanceWarning', 'system');
GO
-- ====================================
-- Bảng GPAs (điểm trung bình)
-- ====================================
IF OBJECT_ID('dbo.gpas', 'U') IS NOT NULL
    DROP TABLE dbo.gpas;
GO

CREATE TABLE dbo.gpas (
    gpa_id        VARCHAR(50) NOT NULL PRIMARY KEY,    -- Khóa chính
    student_id    VARCHAR(50) NOT NULL,                -- FK tới students
    term          VARCHAR(20) NOT NULL,                -- Học kỳ (Fall 2024, Spring 2025...)
    academic_year_id VARCHAR(50) NOT NULL,             -- Niên khóa
    gpa10         DECIMAL(4,2) NULL,                   -- GPA thang 10
    gpa4          DECIMAL(4,2) NULL,                   -- GPA thang 4
    accumulated_credits INT NULL,                      -- Tổng tín chỉ tích lũy
    rank_text     NVARCHAR(50) NULL,                   -- Xếp loại: Xuất sắc, Giỏi, Khá...

    -- Audit
    created_at    DATETIME NOT NULL DEFAULT(GETDATE()),
    created_by    VARCHAR(50) NULL,
    updated_at    DATETIME NULL,
    updated_by    VARCHAR(50) NULL,

    -- Soft delete
    is_active     BIT NOT NULL DEFAULT 1,
    deleted_at    DATETIME NULL,
    deleted_by    VARCHAR(50) NULL,

    CONSTRAINT FK_gpas_students FOREIGN KEY (student_id) REFERENCES dbo.students(student_id),
    CONSTRAINT FK_gpas_academic_years FOREIGN KEY (academic_year_id) REFERENCES dbo.academic_years(academic_year_id)
);
GO
-- ====================================
-- Bảng Notification Jobs (hàng đợi gửi thông báo/email)
-- ====================================
IF OBJECT_ID('dbo.notification_jobs', 'U') IS NOT NULL
    DROP TABLE dbo.notification_jobs;
GO

CREATE TABLE dbo.notification_jobs (
    job_id        VARCHAR(50) NOT NULL PRIMARY KEY,    -- Khóa chính
    notification_id VARCHAR(50) NOT NULL,              -- FK tới notifications
    status        VARCHAR(20) NOT NULL DEFAULT 'Pending', -- Pending, Processing, Sent, Failed
    retry_count   INT NOT NULL DEFAULT 0,              -- Số lần retry
    last_error    NVARCHAR(1000) NULL,                 -- Lỗi lần gần nhất
    processed_at  DATETIME NULL,                       -- Thời gian xử lý xong

    -- Audit
    created_at    DATETIME NOT NULL DEFAULT(GETDATE()),
    created_by    VARCHAR(50) NULL,
    updated_at    DATETIME NULL,
    updated_by    VARCHAR(50) NULL,

    -- Soft delete
    is_active     BIT NOT NULL DEFAULT 1,
    deleted_at    DATETIME NULL,
    deleted_by    VARCHAR(50) NULL,

    CONSTRAINT FK_notification_jobs FOREIGN KEY (notification_id) REFERENCES dbo.notifications(notification_id)
);
GO
