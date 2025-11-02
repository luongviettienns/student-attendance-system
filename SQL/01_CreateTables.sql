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
    department_code VARCHAR(20) NOT NULL UNIQUE,
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
    cohort_code        NVARCHAR(10) NULL,
    start_year         INT NOT NULL,
    end_year           INT NOT NULL,
    duration_years     INT NOT NULL DEFAULT 4,
    description        NVARCHAR(500) NULL,
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
-- 6A. BẢNG SCHOOL_YEARS (Năm học - 1 năm = 2 học kỳ)
-- ===========================================
IF OBJECT_ID('dbo.school_years', 'U') IS NOT NULL DROP TABLE dbo.school_years;
GO

CREATE TABLE dbo.school_years (
    school_year_id    VARCHAR(50) PRIMARY KEY,
    year_code         NVARCHAR(20) NOT NULL UNIQUE,
    year_name         NVARCHAR(100) NOT NULL,
    academic_year_id  VARCHAR(50) NULL FOREIGN KEY REFERENCES dbo.academic_years(academic_year_id),
    start_date        DATE NOT NULL,
    end_date          DATE NOT NULL,
    semester1_start   DATE NULL,
    semester1_end     DATE NULL,
    semester2_start   DATE NULL,
    semester2_end     DATE NULL,
    is_active         BIT NOT NULL DEFAULT 0,
    current_semester  INT NULL,
    created_at        DATETIME NOT NULL DEFAULT(GETDATE()),
    created_by        VARCHAR(50) NULL,
    updated_at        DATETIME NULL,
    updated_by        VARCHAR(50) NULL,
    deleted_at        DATETIME NULL,
    deleted_by        VARCHAR(50) NULL
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
    school_year_id   VARCHAR(50) NULL FOREIGN KEY REFERENCES dbo.school_years(school_year_id),
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

PRINT '✅ Đã tạo xong các bảng core system!';
GO

-- #############################################################################
-- PHASE 1: ENROLLMENT SYSTEM - TABLES
-- #############################################################################

PRINT '';
PRINT '========================================';
PRINT 'Starting: PHASE 1 - Enrollment Tables';
PRINT 'Purpose: Create enrollment system tables';
PRINT '========================================';
GO

-- =============================================
-- 1. CREATE TABLE: administrative_classes
-- =============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'administrative_classes')
BEGIN
    PRINT 'Creating table: administrative_classes';
    
    CREATE TABLE dbo.administrative_classes (
        -- Primary Key
        admin_class_id      VARCHAR(50) PRIMARY KEY,
        
        -- Basic Information
        class_code          VARCHAR(20) NOT NULL UNIQUE,
        class_name          NVARCHAR(150) NOT NULL,
        
        -- Foreign Keys
        major_id            VARCHAR(50) NULL,
        advisor_id          VARCHAR(50) NULL,
        academic_year_id    VARCHAR(50) NULL,
        
        -- Class Details
        cohort_year         INT NOT NULL CHECK (cohort_year >= 2000 AND cohort_year <= 2100),
        max_students        INT DEFAULT 50 CHECK (max_students > 0 AND max_students <= 200),
        current_students    INT DEFAULT 0 CHECK (current_students >= 0),
        
        -- Description
        description         NVARCHAR(500) NULL,
        
        -- Audit Fields
        is_active           BIT DEFAULT 1,
        created_at          DATETIME DEFAULT GETDATE(),
        created_by          VARCHAR(50) NULL,
        updated_at          DATETIME NULL,
        updated_by          VARCHAR(50) NULL,
        deleted_at          DATETIME NULL,
        deleted_by          VARCHAR(50) NULL,
        
        -- Constraints
        CONSTRAINT CHK_AdminClass_CurrentNotExceedMax CHECK (current_students <= max_students),
        CONSTRAINT FK_AdminClass_Major FOREIGN KEY (major_id) REFERENCES majors(major_id),
        CONSTRAINT FK_AdminClass_Advisor FOREIGN KEY (advisor_id) REFERENCES lecturers(lecturer_id),
        CONSTRAINT FK_AdminClass_AcademicYear FOREIGN KEY (academic_year_id) REFERENCES academic_years(academic_year_id)
    );
    
    PRINT '✓ Table created: administrative_classes';
END
ELSE
BEGIN
    PRINT '✓ Table already exists: administrative_classes';
END
GO

-- Create indexes for administrative_classes
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_AdminClass_ClassCode' AND object_id = OBJECT_ID('administrative_classes'))
    CREATE INDEX IX_AdminClass_ClassCode ON administrative_classes(class_code);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_AdminClass_Major' AND object_id = OBJECT_ID('administrative_classes'))
    CREATE INDEX IX_AdminClass_Major ON administrative_classes(major_id);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_AdminClass_CohortYear' AND object_id = OBJECT_ID('administrative_classes'))
    CREATE INDEX IX_AdminClass_CohortYear ON administrative_classes(cohort_year);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_AdminClass_Advisor' AND object_id = OBJECT_ID('administrative_classes'))
    CREATE INDEX IX_AdminClass_Advisor ON administrative_classes(advisor_id);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_AdminClass_AcademicYear' AND object_id = OBJECT_ID('administrative_classes'))
    CREATE INDEX IX_AdminClass_AcademicYear ON administrative_classes(academic_year_id);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_AdminClass_Active' AND object_id = OBJECT_ID('administrative_classes'))
    CREATE INDEX IX_AdminClass_Active ON administrative_classes(is_active, deleted_at);

PRINT '✓ Indexes created for administrative_classes';
GO

-- Update students table to add admin_class_id
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('students') AND name = 'admin_class_id')
BEGIN
    ALTER TABLE students ADD admin_class_id VARCHAR(50) NULL;
    PRINT '✓ Added column: students.admin_class_id';
    
    ALTER TABLE students 
    ADD CONSTRAINT FK_Student_AdminClass 
    FOREIGN KEY (admin_class_id) REFERENCES administrative_classes(admin_class_id);
    PRINT '✓ Added FK: FK_Student_AdminClass';
    
    CREATE INDEX IX_Student_AdminClass ON students(admin_class_id);
    PRINT '✓ Created index: IX_Student_AdminClass';
END
ELSE
BEGIN
    PRINT '✓ Column already exists: students.admin_class_id';
END
GO

-- =============================================
-- 2. CREATE TABLE: registration_periods
-- =============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'registration_periods')
BEGIN
    PRINT 'Creating table: registration_periods';
    
    CREATE TABLE dbo.registration_periods (
        -- Primary Key
        period_id           VARCHAR(50) PRIMARY KEY,
        
        -- Basic Information
        period_name         NVARCHAR(200) NOT NULL,
        
        -- Foreign Keys
        academic_year_id    VARCHAR(50) NOT NULL,
        
        -- Period Details
        semester            INT NOT NULL CHECK (semester IN (1, 2, 3)),
        start_date          DATETIME NOT NULL,
        end_date            DATETIME NOT NULL,
        status              NVARCHAR(20) DEFAULT 'UPCOMING' CHECK (status IN ('UPCOMING', 'OPEN', 'CLOSED')),
        
        -- Description
        description         NVARCHAR(500) NULL,
        
        -- Audit Fields
        is_active           BIT DEFAULT 1,
        created_at          DATETIME DEFAULT GETDATE(),
        created_by          VARCHAR(50) NULL,
        updated_at          DATETIME NULL,
        updated_by          VARCHAR(50) NULL,
        deleted_at          DATETIME NULL,
        deleted_by          VARCHAR(50) NULL,
        
        -- Constraints
        CONSTRAINT CHK_Period_DateRange CHECK (start_date < end_date),
        CONSTRAINT FK_Period_AcademicYear FOREIGN KEY (academic_year_id) REFERENCES academic_years(academic_year_id)
    );
    
    PRINT '✓ Table created: registration_periods';
END
ELSE
BEGIN
    PRINT '✓ Table already exists: registration_periods';
END
GO

-- Create indexes for registration_periods
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Period_AcademicYearSemester' AND object_id = OBJECT_ID('registration_periods'))
    CREATE INDEX IX_Period_AcademicYearSemester ON registration_periods(academic_year_id, semester);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Period_Status' AND object_id = OBJECT_ID('registration_periods'))
    CREATE INDEX IX_Period_Status ON registration_periods(status);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Period_DateRange' AND object_id = OBJECT_ID('registration_periods'))
    CREATE INDEX IX_Period_DateRange ON registration_periods(start_date, end_date);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Period_Active' AND object_id = OBJECT_ID('registration_periods'))
    CREATE INDEX IX_Period_Active ON registration_periods(is_active, deleted_at, status);

-- Unique constraint: prevent multiple OPEN periods
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'UQ_Period_AcademicYearSemester' AND object_id = OBJECT_ID('registration_periods'))
    CREATE UNIQUE INDEX UQ_Period_AcademicYearSemester 
    ON registration_periods(academic_year_id, semester, is_active) 
    WHERE is_active = 1 AND deleted_at IS NULL AND status = 'OPEN';

PRINT '✓ Indexes created for registration_periods';
GO

-- =============================================
-- 3. UPDATE TABLE: classes (add current_enrollment)
-- =============================================

PRINT 'Updating classes table...';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('classes') AND name = 'current_enrollment')
BEGIN
    ALTER TABLE classes ADD current_enrollment INT DEFAULT 0 NOT NULL;
    PRINT '✓ Added column: classes.current_enrollment';
END
ELSE
BEGIN
    PRINT '✓ Column already exists: classes.current_enrollment';
END
GO

-- Add constraints
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE name = 'CHK_Class_EnrollmentNotExceedMax')
BEGIN
    ALTER TABLE classes 
    ADD CONSTRAINT CHK_Class_EnrollmentNotExceedMax 
    CHECK (current_enrollment <= max_students);
    PRINT '✓ Added constraint: CHK_Class_EnrollmentNotExceedMax';
END

IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE name = 'CHK_Class_EnrollmentNonNegative')
BEGIN
    ALTER TABLE classes 
    ADD CONSTRAINT CHK_Class_EnrollmentNonNegative 
    CHECK (current_enrollment >= 0);
    PRINT '✓ Added constraint: CHK_Class_EnrollmentNonNegative';
END
GO

-- Create index
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Class_CurrentEnrollment' AND object_id = OBJECT_ID('classes'))
BEGIN
    CREATE INDEX IX_Class_CurrentEnrollment ON classes(current_enrollment, max_students);
    PRINT '✓ Created index: IX_Class_CurrentEnrollment';
END
GO

-- Update existing data
UPDATE c
SET c.current_enrollment = ISNULL(e.enrollment_count, 0)
FROM classes c
LEFT JOIN (
    SELECT 
        class_id,
        COUNT(*) AS enrollment_count
    FROM enrollments
    WHERE deleted_at IS NULL
    GROUP BY class_id
) e ON c.class_id = e.class_id
WHERE c.deleted_at IS NULL;

PRINT '✓ Updated existing enrollment counts';
GO

-- =============================================
-- 4. UPDATE TABLE: enrollments (add status fields)
-- =============================================

PRINT 'Updating enrollments table...';

-- Add enrollment_status column
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('enrollments') AND name = 'enrollment_status')
BEGIN
    ALTER TABLE enrollments ADD enrollment_status NVARCHAR(20) DEFAULT 'APPROVED' NOT NULL;
    PRINT '✓ Added column: enrollments.enrollment_status';
END

-- Add drop_deadline column
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('enrollments') AND name = 'drop_deadline')
BEGIN
    ALTER TABLE enrollments ADD drop_deadline DATE NULL;
    PRINT '✓ Added column: enrollments.drop_deadline';
END

-- Add notes column
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('enrollments') AND name = 'notes')
BEGIN
    ALTER TABLE enrollments ADD notes NVARCHAR(500) NULL;
    PRINT '✓ Added column: enrollments.notes';
END

-- Add drop_reason column
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('enrollments') AND name = 'drop_reason')
BEGIN
    ALTER TABLE enrollments ADD drop_reason NVARCHAR(500) NULL;
    PRINT '✓ Added column: enrollments.drop_reason';
END
GO

-- Add check constraint
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE name = 'CHK_Enrollment_Status')
BEGIN
    ALTER TABLE enrollments 
    ADD CONSTRAINT CHK_Enrollment_Status 
    CHECK (enrollment_status IN ('PENDING', 'APPROVED', 'DROPPED', 'WITHDRAWN'));
    PRINT '✓ Added constraint: CHK_Enrollment_Status';
END
GO

-- Create indexes
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Enrollment_Status' AND object_id = OBJECT_ID('enrollments'))
    CREATE INDEX IX_Enrollment_Status ON enrollments(enrollment_status);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Enrollment_StatusActive' AND object_id = OBJECT_ID('enrollments'))
    CREATE INDEX IX_Enrollment_StatusActive ON enrollments(enrollment_status, deleted_at);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Enrollment_DropDeadline' AND object_id = OBJECT_ID('enrollments'))
    CREATE INDEX IX_Enrollment_DropDeadline ON enrollments(drop_deadline);

PRINT '✓ Indexes created for enrollments';
GO

-- Migrate existing data
UPDATE enrollments
SET enrollment_status = 'APPROVED'
WHERE enrollment_status IS NULL OR enrollment_status = 'APPROVED';

UPDATE e
SET e.drop_deadline = CAST(DATEADD(WEEK, 2, e.enrollment_date) AS DATE)
FROM enrollments e
WHERE e.drop_deadline IS NULL
AND e.enrollment_status = 'APPROVED'
AND e.deleted_at IS NULL
AND e.enrollment_date IS NOT NULL;

PRINT '✓ Migrated existing enrollment data';
GO

-- =============================================
-- 5. CREATE TABLE: subject_prerequisites
-- =============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'subject_prerequisites')
BEGIN
    PRINT 'Creating table: subject_prerequisites';
    
    CREATE TABLE dbo.subject_prerequisites (
        -- Primary Key
        prerequisite_id         VARCHAR(50) PRIMARY KEY,
        
        -- Foreign Keys
        subject_id              VARCHAR(50) NOT NULL,
        prerequisite_subject_id VARCHAR(50) NOT NULL,
        
        -- Prerequisite Details
        minimum_grade           DECIMAL(4,2) DEFAULT 4.0 CHECK (minimum_grade >= 0 AND minimum_grade <= 10),
        is_required             BIT DEFAULT 1,
        
        -- Description
        description             NVARCHAR(500) NULL,
        
        -- Audit Fields
        is_active               BIT DEFAULT 1,
        created_at              DATETIME DEFAULT GETDATE(),
        created_by              VARCHAR(50) NULL,
        updated_at              DATETIME NULL,
        updated_by              VARCHAR(50) NULL,
        deleted_at              DATETIME NULL,
        deleted_by              VARCHAR(50) NULL,
        
        -- Constraints
        CONSTRAINT CHK_Prerequisite_NotSelf CHECK (subject_id != prerequisite_subject_id),
        CONSTRAINT FK_Prerequisite_Subject FOREIGN KEY (subject_id) REFERENCES subjects(subject_id),
        CONSTRAINT FK_Prerequisite_PrereqSubject FOREIGN KEY (prerequisite_subject_id) REFERENCES subjects(subject_id),
        CONSTRAINT UQ_Prerequisite_Pair UNIQUE (subject_id, prerequisite_subject_id)
    );
    
    PRINT '✓ Table created: subject_prerequisites';
END
ELSE
BEGIN
    PRINT '✓ Table already exists: subject_prerequisites';
END
GO

-- Create indexes for subject_prerequisites
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Prerequisite_Subject' AND object_id = OBJECT_ID('subject_prerequisites'))
    CREATE INDEX IX_Prerequisite_Subject ON subject_prerequisites(subject_id);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Prerequisite_PrereqSubject' AND object_id = OBJECT_ID('subject_prerequisites'))
    CREATE INDEX IX_Prerequisite_PrereqSubject ON subject_prerequisites(prerequisite_subject_id);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Prerequisite_ActiveRequired' AND object_id = OBJECT_ID('subject_prerequisites'))
    CREATE INDEX IX_Prerequisite_ActiveRequired ON subject_prerequisites(is_active, is_required, deleted_at);

PRINT '✓ Indexes created for subject_prerequisites';
GO

-- Create trigger to prevent circular dependencies
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_PreventCircularPrerequisites')
BEGIN
    EXEC('
    CREATE TRIGGER trg_PreventCircularPrerequisites
    ON subject_prerequisites
    AFTER INSERT, UPDATE
    AS
    BEGIN
        SET NOCOUNT ON;
        
        DECLARE @SubjectId VARCHAR(50);
        DECLARE @PrereqId VARCHAR(50);
        
        SELECT @SubjectId = subject_id, @PrereqId = prerequisite_subject_id
        FROM inserted;
        
        DECLARE @HasCircular BIT = 0;
        
        WITH PrereqChain AS (
            SELECT 
                subject_id,
                prerequisite_subject_id,
                1 AS level
            FROM subject_prerequisites
            WHERE subject_id = @PrereqId
            AND is_active = 1
            AND deleted_at IS NULL
            
            UNION ALL
            
            SELECT 
                sp.subject_id,
                sp.prerequisite_subject_id,
                pc.level + 1
            FROM subject_prerequisites sp
            INNER JOIN PrereqChain pc ON sp.subject_id = pc.prerequisite_subject_id
            WHERE sp.is_active = 1
            AND sp.deleted_at IS NULL
            AND pc.level < 10
        )
        SELECT @HasCircular = 1
        FROM PrereqChain
        WHERE prerequisite_subject_id = @SubjectId;
        
        IF @HasCircular = 1
        BEGIN
            ROLLBACK TRANSACTION;
            THROW 50001, ''Không thể tạo điều kiện tiên quyết: Phát hiện vòng lặp phụ thuộc (circular dependency)'', 1;
        END
    END
    ');
    PRINT '✓ Created trigger: trg_PreventCircularPrerequisites';
END
GO

-- #############################################################################
-- PHASE 1 COMPLETE
-- #############################################################################

PRINT '';
PRINT '========================================';
PRINT '✅ PHASE 1 COMPLETED!';
PRINT '========================================';
PRINT '✓ administrative_classes';
PRINT '✓ registration_periods';
PRINT '✓ classes (updated)';
PRINT '✓ enrollments (updated)';
PRINT '✓ subject_prerequisites';
PRINT '========================================';
PRINT '';

-- ===========================================
-- ALTER TABLES: Add school_year_id to gpas
-- ===========================================
-- Add school_year_id column to gpas table if not exists
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID('dbo.gpas') 
    AND name = 'school_year_id'
)
BEGIN
    ALTER TABLE dbo.gpas 
    ADD school_year_id VARCHAR(50) NULL 
        FOREIGN KEY REFERENCES dbo.school_years(school_year_id);
    
    PRINT '✅ Added school_year_id to gpas table';
END
ELSE
BEGIN
    PRINT 'ℹ️  Column school_year_id already exists in gpas table';
END
GO

