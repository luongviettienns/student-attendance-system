-- ===========================================
-- 🎓 HỆ THỐNG QUẢN LÝ ĐIỂM DANH SINH VIÊN
-- 📋 File 1/4: TẠO CÁC BẢNG (CREATE TABLES)
-- ===========================================

USE master;
GO

-- Tạo database nếu chưa có
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'EducationManagement')
BEGIN
    CREATE DATABASE EducationManagement;
END
GO

USE EducationManagement;
GO

-- ===========================================
-- 1. BẢNG ROLES (Vai trò người dùng)
-- ===========================================
IF OBJECT_ID('dbo.roles', 'U') IS NOT NULL DROP TABLE dbo.roles;
GO

CREATE TABLE dbo.roles (
    role_id      VARCHAR(50) PRIMARY KEY,
    role_name    NVARCHAR(100) NOT NULL UNIQUE,
    description  NVARCHAR(255) NULL,
    created_at   DATETIME NOT NULL DEFAULT(GETDATE()),
    created_by   VARCHAR(50) NULL,
    updated_at   DATETIME NULL,
    updated_by   VARCHAR(50) NULL,
    is_active    BIT NOT NULL DEFAULT 1,
    deleted_at   DATETIME NULL,
    deleted_by   VARCHAR(50) NULL
);
GO

-- ===========================================
-- 2. BẢNG USERS (Người dùng)
-- ===========================================
IF OBJECT_ID('dbo.users', 'U') IS NOT NULL DROP TABLE dbo.users;
GO

CREATE TABLE dbo.users (
    user_id        VARCHAR(50) PRIMARY KEY,
    username       VARCHAR(50) NOT NULL UNIQUE,
    password_hash  VARCHAR(255) NOT NULL,
    email          VARCHAR(150) NOT NULL UNIQUE,
    phone          VARCHAR(20) NULL,
    full_name      NVARCHAR(150) NOT NULL,
    avatar_url     VARCHAR(300) NULL,
    role_id        VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES dbo.roles(role_id),
    is_active      BIT NOT NULL DEFAULT 1,
    last_login_at  DATETIME NULL,
    created_at     DATETIME NOT NULL DEFAULT(GETDATE()),
    created_by     VARCHAR(50) NULL,
    updated_at     DATETIME NULL,
    updated_by     VARCHAR(50) NULL,
    deleted_at     DATETIME NULL,
    deleted_by     VARCHAR(50) NULL
);
GO

-- ===========================================
-- 3. BẢNG FACULTIES (Khoa)
-- ===========================================
IF OBJECT_ID('dbo.faculties', 'U') IS NOT NULL DROP TABLE dbo.faculties;
GO

CREATE TABLE dbo.faculties (
    faculty_id   VARCHAR(50) PRIMARY KEY,
    faculty_code VARCHAR(20) NOT NULL UNIQUE,
    faculty_name NVARCHAR(150) NOT NULL UNIQUE,
    description  NVARCHAR(500) NULL,
    is_active    BIT NOT NULL DEFAULT 1,
    created_at   DATETIME NOT NULL DEFAULT(GETDATE()),
    created_by   VARCHAR(50) NULL,
    updated_at   DATETIME NULL,
    updated_by   VARCHAR(50) NULL,
    deleted_at   DATETIME NULL,
    deleted_by   VARCHAR(50) NULL
);
GO

-- ===========================================
-- 4. BẢNG DEPARTMENTS (Bộ môn)
-- ===========================================
IF OBJECT_ID('dbo.departments', 'U') IS NOT NULL DROP TABLE dbo.departments;
GO

CREATE TABLE dbo.departments (
    department_id   VARCHAR(50) PRIMARY KEY,
    department_name NVARCHAR(150) NOT NULL,
    faculty_id      VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES dbo.faculties(faculty_id),
    description     NVARCHAR(500) NULL,
    created_at      DATETIME NOT NULL DEFAULT(GETDATE()),
    created_by      VARCHAR(50) NULL,
    updated_at      DATETIME NULL,
    updated_by      VARCHAR(50) NULL,
    deleted_at      DATETIME NULL,
    deleted_by      VARCHAR(50) NULL
);
GO

-- ===========================================
-- 5. BẢNG MAJORS (Ngành học)
-- ===========================================
IF OBJECT_ID('dbo.majors', 'U') IS NOT NULL DROP TABLE dbo.majors;
GO

CREATE TABLE dbo.majors (
    major_id     VARCHAR(50) PRIMARY KEY,
    major_name   NVARCHAR(150) NOT NULL,
    major_code   VARCHAR(20) NOT NULL UNIQUE,
    faculty_id   VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES dbo.faculties(faculty_id),
    description  NVARCHAR(500) NULL,
    created_at   DATETIME NOT NULL DEFAULT(GETDATE()),
    created_by   VARCHAR(50) NULL,
    updated_at   DATETIME NULL,
    updated_by   VARCHAR(50) NULL,
    deleted_at   DATETIME NULL,
    deleted_by   VARCHAR(50) NULL
);
GO

-- ===========================================
-- 6. BẢNG ACADEMIC_YEARS (Niên khóa)
-- ===========================================
IF OBJECT_ID('dbo.academic_years', 'U') IS NOT NULL DROP TABLE dbo.academic_years;
GO

CREATE TABLE dbo.academic_years (
    academic_year_id   VARCHAR(50) PRIMARY KEY,
    year_name          NVARCHAR(50) NOT NULL UNIQUE,
    start_year         INT NOT NULL,
    end_year           INT NOT NULL,
    is_active          BIT NOT NULL DEFAULT 0,
    created_at         DATETIME NOT NULL DEFAULT(GETDATE()),
    created_by         VARCHAR(50) NULL,
    updated_at         DATETIME NULL,
    updated_by         VARCHAR(50) NULL,
    deleted_at         DATETIME NULL,
    deleted_by         VARCHAR(50) NULL
);
GO

-- ===========================================
-- 7. BẢNG STUDENTS (Sinh viên)
-- ===========================================
IF OBJECT_ID('dbo.students', 'U') IS NOT NULL DROP TABLE dbo.students;
GO

CREATE TABLE dbo.students (
    student_id       VARCHAR(50) PRIMARY KEY,
    student_code     VARCHAR(20) NOT NULL UNIQUE,
    full_name        NVARCHAR(150) NOT NULL,
    date_of_birth    DATE NULL,
    gender           NVARCHAR(10) NULL,
    email            VARCHAR(150) NULL,
    phone            VARCHAR(20) NULL,
    address          NVARCHAR(300) NULL,
    major_id         VARCHAR(50) NULL FOREIGN KEY REFERENCES dbo.majors(major_id),
    academic_year_id VARCHAR(50) NULL FOREIGN KEY REFERENCES dbo.academic_years(academic_year_id),
    advisor_id       VARCHAR(50) NULL,
    user_id          VARCHAR(50) NULL FOREIGN KEY REFERENCES dbo.users(user_id),
    is_active        BIT NOT NULL DEFAULT 1,
    created_at       DATETIME NOT NULL DEFAULT(GETDATE()),
    created_by       VARCHAR(50) NULL,
    updated_at       DATETIME NULL,
    updated_by       VARCHAR(50) NULL,
    deleted_at       DATETIME NULL,
    deleted_by       VARCHAR(50) NULL
);
GO

-- ===========================================
-- 8. BẢNG LECTURERS (Giảng viên)
-- ===========================================
IF OBJECT_ID('dbo.lecturers', 'U') IS NOT NULL DROP TABLE dbo.lecturers;
GO

CREATE TABLE dbo.lecturers (
    lecturer_id   VARCHAR(50) PRIMARY KEY,
    lecturer_code VARCHAR(20) NOT NULL UNIQUE,
    full_name     NVARCHAR(150) NOT NULL,
    email         VARCHAR(150) NULL,
    phone         VARCHAR(20) NULL,
    department_id VARCHAR(50) NULL FOREIGN KEY REFERENCES dbo.departments(department_id),
    user_id       VARCHAR(50) NULL FOREIGN KEY REFERENCES dbo.users(user_id),
    is_active     BIT NOT NULL DEFAULT 1,
    created_at    DATETIME NOT NULL DEFAULT(GETDATE()),
    created_by    VARCHAR(50) NULL,
    updated_at    DATETIME NULL,
    updated_by    VARCHAR(50) NULL,
    deleted_at    DATETIME NULL,
    deleted_by    VARCHAR(50) NULL
);
GO

-- ===========================================
-- 9. BẢNG SUBJECTS (Môn học)
-- ===========================================
IF OBJECT_ID('dbo.subjects', 'U') IS NOT NULL DROP TABLE dbo.subjects;
GO

CREATE TABLE dbo.subjects (
    subject_id    VARCHAR(50) PRIMARY KEY,
    subject_code  VARCHAR(20) NOT NULL UNIQUE,
    subject_name  NVARCHAR(200) NOT NULL,
    credits       INT NOT NULL,
    department_id VARCHAR(50) NULL FOREIGN KEY REFERENCES dbo.departments(department_id),
    description   NVARCHAR(500) NULL,
    created_at    DATETIME NOT NULL DEFAULT(GETDATE()),
    created_by    VARCHAR(50) NULL,
    updated_at    DATETIME NULL,
    updated_by    VARCHAR(50) NULL,
    deleted_at    DATETIME NULL,
    deleted_by    VARCHAR(50) NULL
);
GO

-- ===========================================
-- 10. BẢNG CLASSES (Lớp học phần)
-- ===========================================
IF OBJECT_ID('dbo.classes', 'U') IS NOT NULL DROP TABLE dbo.classes;
GO

CREATE TABLE dbo.classes (
    class_id         VARCHAR(50) PRIMARY KEY,
    class_code       VARCHAR(20) NOT NULL UNIQUE,
    class_name       NVARCHAR(200) NOT NULL,
    subject_id       VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES dbo.subjects(subject_id),
    lecturer_id      VARCHAR(50) NULL FOREIGN KEY REFERENCES dbo.lecturers(lecturer_id),
    academic_year_id VARCHAR(50) NULL FOREIGN KEY REFERENCES dbo.academic_years(academic_year_id),
    semester         INT NULL,
    max_students     INT NULL,
    schedule         NVARCHAR(500) NULL,
    room             NVARCHAR(100) NULL,
    created_at       DATETIME NOT NULL DEFAULT(GETDATE()),
    created_by       VARCHAR(50) NULL,
    updated_at       DATETIME NULL,
    updated_by       VARCHAR(50) NULL,
    deleted_at       DATETIME NULL,
    deleted_by       VARCHAR(50) NULL
);
GO

-- ===========================================
-- 11. BẢNG ENROLLMENTS (Đăng ký học phần)
-- ===========================================
IF OBJECT_ID('dbo.enrollments', 'U') IS NOT NULL DROP TABLE dbo.enrollments;
GO

CREATE TABLE dbo.enrollments (
    enrollment_id   VARCHAR(50) PRIMARY KEY,
    student_id      VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES dbo.students(student_id),
    class_id        VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES dbo.classes(class_id),
    enrollment_date DATETIME NOT NULL DEFAULT(GETDATE()),
    status          NVARCHAR(50) NULL,
    created_at      DATETIME NOT NULL DEFAULT(GETDATE()),
    created_by      VARCHAR(50) NULL,
    deleted_at      DATETIME NULL,
    deleted_by      VARCHAR(50) NULL
);
GO

-- ===========================================
-- 12. BẢNG ATTENDANCES (Điểm danh)
-- ===========================================
IF OBJECT_ID('dbo.attendances', 'U') IS NOT NULL DROP TABLE dbo.attendances;
GO

CREATE TABLE dbo.attendances (
    attendance_id   VARCHAR(50) PRIMARY KEY,
    enrollment_id   VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES dbo.enrollments(enrollment_id),
    class_id        VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES dbo.classes(class_id),
    attendance_date DATETIME NOT NULL,
    status          NVARCHAR(20) NOT NULL,
    note            NVARCHAR(500) NULL,
    created_at      DATETIME NOT NULL DEFAULT(GETDATE()),
    created_by      VARCHAR(50) NULL,
    updated_at      DATETIME NULL,
    updated_by      VARCHAR(50) NULL
);
GO

-- ===========================================
-- 13. BẢNG GRADES (Điểm số)
-- ===========================================
IF OBJECT_ID('dbo.grades', 'U') IS NOT NULL DROP TABLE dbo.grades;
GO

CREATE TABLE dbo.grades (
    grade_id      VARCHAR(50) PRIMARY KEY,
    enrollment_id VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES dbo.enrollments(enrollment_id),
    midterm_score DECIMAL(4,2) NULL,
    final_score   DECIMAL(4,2) NULL,
    total_score   DECIMAL(4,2) NULL,
    letter_grade  VARCHAR(5) NULL,
    created_at    DATETIME NOT NULL DEFAULT(GETDATE()),
    created_by    VARCHAR(50) NULL,
    updated_at    DATETIME NULL,
    updated_by    VARCHAR(50) NULL
);
GO

-- ===========================================
-- 13A. BẢNG GPAS (Điểm trung bình)
-- ===========================================
IF OBJECT_ID('dbo.gpas', 'U') IS NOT NULL DROP TABLE dbo.gpas;
GO

CREATE TABLE dbo.gpas (
    gpa_id           VARCHAR(50) PRIMARY KEY,
    student_id       VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES dbo.students(student_id),
    academic_year_id VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES dbo.academic_years(academic_year_id),
    semester         INT NULL, -- NULL = cả năm học, 1/2/3 = học kỳ cụ thể
    gpa10            DECIMAL(4,2) NULL CHECK (gpa10 >= 0 AND gpa10 <= 10),
    gpa4             DECIMAL(4,2) NULL CHECK (gpa4 >= 0 AND gpa4 <= 4),
    total_credits    INT NULL DEFAULT 0,
    accumulated_credits INT NULL DEFAULT 0,
    rank_text        NVARCHAR(50) NULL, -- Xuất sắc, Giỏi, Khá, Trung bình, Yếu
    is_active        BIT NOT NULL DEFAULT 1,
    created_at       DATETIME NOT NULL DEFAULT(GETDATE()),
    created_by       VARCHAR(50) NULL,
    updated_at       DATETIME NULL,
    updated_by       VARCHAR(50) NULL,
    deleted_at       DATETIME NULL,
    deleted_by       VARCHAR(50) NULL,
    
    -- Unique constraint: Mỗi sinh viên chỉ có 1 GPA cho 1 năm học + học kỳ
    CONSTRAINT uk_gpa_student_year_semester UNIQUE (student_id, academic_year_id, semester)
);
GO

-- ===========================================
-- 14. BẢNG NOTIFICATIONS (Thông báo)
-- ===========================================
IF OBJECT_ID('dbo.notifications', 'U') IS NOT NULL DROP TABLE dbo.notifications;
GO

CREATE TABLE dbo.notifications (
    notification_id   VARCHAR(50) PRIMARY KEY,
    user_id           VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES dbo.users(user_id),
    title             NVARCHAR(200) NOT NULL,
    message           NVARCHAR(MAX) NOT NULL,
    notification_type NVARCHAR(50) NULL,
    is_read           BIT NOT NULL DEFAULT 0,
    created_at        DATETIME NOT NULL DEFAULT(GETDATE())
);
GO

-- ===========================================
-- 15. BẢNG PERMISSIONS (Quyền hạn)
-- ===========================================
IF OBJECT_ID('dbo.permissions', 'U') IS NOT NULL DROP TABLE dbo.permissions;
GO

CREATE TABLE dbo.permissions (
    permission_id   VARCHAR(50) PRIMARY KEY,
    permission_code VARCHAR(100) NOT NULL UNIQUE,
    permission_name NVARCHAR(200) NOT NULL,
    description     NVARCHAR(500) NULL,
    created_at      DATETIME NOT NULL DEFAULT(GETDATE()),
    created_by      VARCHAR(50) NULL,
    updated_at      DATETIME NULL,
    updated_by      VARCHAR(50) NULL
);
GO

-- ===========================================
-- 16. BẢNG ROLE_PERMISSIONS (Liên kết vai trò - quyền)
-- ===========================================
IF OBJECT_ID('dbo.role_permissions', 'U') IS NOT NULL DROP TABLE dbo.role_permissions;
GO

CREATE TABLE dbo.role_permissions (
    role_id       VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES dbo.roles(role_id) ON DELETE CASCADE,
    permission_id VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES dbo.permissions(permission_id) ON DELETE CASCADE,
    created_at    DATETIME NOT NULL DEFAULT(GETDATE()),
    created_by    VARCHAR(50) NULL,
    
    PRIMARY KEY (role_id, permission_id)
);
GO

-- ===========================================
-- 17. BẢNG AUDIT_LOGS (Nhật ký hệ thống)
-- ===========================================
IF OBJECT_ID('dbo.audit_logs', 'U') IS NOT NULL DROP TABLE dbo.audit_logs;
GO

CREATE TABLE dbo.audit_logs (
    log_id       BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id      VARCHAR(50) NULL,
    action       VARCHAR(50) NOT NULL,
    entity_type  VARCHAR(100) NOT NULL,
    entity_id    VARCHAR(50) NULL,
    old_values   NVARCHAR(MAX) NULL,
    new_values   NVARCHAR(MAX) NULL,
    ip_address   VARCHAR(50) NULL,
    user_agent   VARCHAR(500) NULL,
    created_at   DATETIME NOT NULL DEFAULT(GETDATE())
);
GO

-- ===========================================
-- 19. BẢNG REFRESH_TOKENS (JWT Refresh Tokens)
-- ===========================================
IF OBJECT_ID('dbo.refresh_tokens', 'U') IS NOT NULL DROP TABLE dbo.refresh_tokens;
GO

CREATE TABLE dbo.refresh_tokens (
    id                  UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    user_id             VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES dbo.users(user_id) ON DELETE CASCADE,
    token               VARCHAR(500) NOT NULL UNIQUE,
    expires_at          DATETIME NOT NULL,
    created_at          DATETIME NOT NULL DEFAULT(GETDATE()),
    revoked_at          DATETIME NULL,
    replaced_by_token   VARCHAR(500) NULL
);
GO

PRINT '✅ Đã tạo xong tất cả các bảng (bao gồm permissions, role_permissions, và refresh_tokens)!';

