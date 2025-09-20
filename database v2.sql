-- Education Management V2 Schema
USE EducationManagement;
GO

-- STUDENTS
IF OBJECT_ID('dbo.students', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.students (
        student_id        VARCHAR(50) NOT NULL PRIMARY KEY,
        code              VARCHAR(20) NOT NULL UNIQUE,
        full_name         NVARCHAR(150) NOT NULL,
        gender            NVARCHAR(10) NULL,
        dob               DATE NULL,
        email             VARCHAR(150) NULL,
        phone             VARCHAR(20) NULL,
        major_id          VARCHAR(50) NULL,
        cohort_year       VARCHAR(10) NULL,
        class_code        VARCHAR(50) NULL,
        is_active         BIT NOT NULL DEFAULT(1),
        created_at        DATETIME NOT NULL DEFAULT(GETDATE())
    );
END
GO

-- STUDENT PROFILES
IF OBJECT_ID('dbo.student_profiles', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.student_profiles (
        student_id        VARCHAR(50) NOT NULL PRIMARY KEY FOREIGN KEY REFERENCES dbo.students(student_id),
        nationality       NVARCHAR(50) NULL,
        ethnicity         NVARCHAR(30) NULL,
        religion          NVARCHAR(50) NULL,
        hometown          NVARCHAR(250) NULL,
        address           NVARCHAR(250) NULL,
        bank_no           VARCHAR(30) NULL,
        bank_name         NVARCHAR(100) NULL,
        insurance_no      VARCHAR(30) NULL,
        issue_place       NVARCHAR(100) NULL,
        issue_date        DATE NULL,
        facebook          NVARCHAR(200) NULL,
        current_address   NVARCHAR(250) NULL,
        birth_province_id VARCHAR(10) NULL,
        birth_district_id VARCHAR(10) NULL,
        birth_ward_id     VARCHAR(10) NULL
    );
END
GO

-- FAMILY
IF OBJECT_ID('dbo.student_family', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.student_family (
        student_family_id VARCHAR(50) NOT NULL PRIMARY KEY,
        student_id        VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES dbo.students(student_id),
        relation_type     NVARCHAR(30) NOT NULL,
        full_name         NVARCHAR(150) NOT NULL,
        birth_year        INT NULL,
        phone             VARCHAR(20) NULL,
        nationality       NVARCHAR(50) NULL,
        ethnicity         NVARCHAR(30) NULL,
        religion          NVARCHAR(50) NULL,
        permanent_address NVARCHAR(250) NULL,
        job               NVARCHAR(150) NULL
    );
END
GO

-- SUBJECTS
IF OBJECT_ID('dbo.subjects', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.subjects (
        subject_id VARCHAR(50) NOT NULL PRIMARY KEY,
        code       VARCHAR(20) NOT NULL UNIQUE,
        name       NVARCHAR(200) NOT NULL,
        credits    INT NOT NULL
    );
END
GO

-- CLASSES
IF OBJECT_ID('dbo.classes', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.classes (
        class_id     VARCHAR(50) NOT NULL PRIMARY KEY,
        subject_id   VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES dbo.subjects(subject_id),
        class_name   NVARCHAR(150) NULL,
        term         VARCHAR(10) NULL,
        school_year  VARCHAR(9) NULL,
        teacher_name NVARCHAR(150) NULL,
        room_default NVARCHAR(50) NULL
    );
END
GO

-- ENROLLMENTS
IF OBJECT_ID('dbo.enrollments', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.enrollments (
        enrollment_id VARCHAR(50) NOT NULL PRIMARY KEY,
        student_id    VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES dbo.students(student_id),
        class_id      VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES dbo.classes(class_id),
        is_optional   BIT NOT NULL DEFAULT(0)
    );
END
GO

-- GRADES
IF OBJECT_ID('dbo.grades', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.grades (
        grade_id       VARCHAR(50) NOT NULL PRIMARY KEY,
        enrollment_id  VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES dbo.enrollments(enrollment_id),
        component      NVARCHAR(MAX) NULL,
        exam_score     DECIMAL(4,2) NULL,
        final10        DECIMAL(4,2) NULL,
        final4         DECIMAL(4,2) NULL,
        letter         VARCHAR(2) NULL,
        note           NVARCHAR(200) NULL
    );
END
GO

-- GPAS
IF OBJECT_ID('dbo.gpas', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.gpas (
        gpa_id        VARCHAR(50) NOT NULL PRIMARY KEY,
        student_id    VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES dbo.students(student_id),
        term          VARCHAR(10) NULL,
        school_year   VARCHAR(9) NULL,
        gpa10         DECIMAL(4,2) NULL,
        gpa4          DECIMAL(4,2) NULL,
        accumulated_credits INT NULL,
        rank_text     NVARCHAR(50) NULL
    );
END
GO

-- SCHEDULES
IF OBJECT_ID('dbo.schedules', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.schedules (
        schedule_id VARCHAR(50) NOT NULL PRIMARY KEY,
        class_id    VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES dbo.classes(class_id),
        week_no     INT NOT NULL,
        week_start  DATE NOT NULL,
        week_end    DATE NOT NULL,
        weekday     TINYINT NOT NULL,
        period_from TINYINT NOT NULL,
        period_to   TINYINT NOT NULL,
        room        NVARCHAR(50) NULL
    );
END
GO

-- EXAMS
IF OBJECT_ID('dbo.exams', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.exams (
        exam_id     VARCHAR(50) NOT NULL PRIMARY KEY,
        class_id    VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES dbo.classes(class_id),
        exam_date   DATE NOT NULL,
        exam_time   TIME NOT NULL,
        attempt     INT NOT NULL DEFAULT(1),
        phase_name  NVARCHAR(50) NULL,
        exam_room   NVARCHAR(50) NULL,
        proctor     NVARCHAR(150) NULL
    );
END
GO

-- EXAM ASSIGNMENTS
IF OBJECT_ID('dbo.exam_assignments', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.exam_assignments (
        exam_assignment_id VARCHAR(50) NOT NULL PRIMARY KEY,
        exam_id    VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES dbo.exams(exam_id),
        student_id VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES dbo.students(student_id),
        reg_no     NVARCHAR(50) NULL,
        note       NVARCHAR(150) NULL
    );
END
GO

-- DISCIPLINES
IF OBJECT_ID('dbo.disciplines', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.disciplines (
        discipline_id VARCHAR(50) NOT NULL PRIMARY KEY,
        student_id    VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES dbo.students(student_id),
        decision_no   NVARCHAR(50) NULL,
        decision_date DATE NULL,
        term          VARCHAR(10) NULL,
        school_year   VARCHAR(9) NULL,
        behavior      NVARCHAR(200) NULL,
        form          NVARCHAR(200) NULL,
        note          NVARCHAR(250) NULL
    );
END
GO

-- ATTENDANCES
IF OBJECT_ID('dbo.attendances', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.attendances (
        attendance_id VARCHAR(50) NOT NULL PRIMARY KEY,
        class_id      VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES dbo.classes(class_id),
        student_id    VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES dbo.students(student_id),
        session_date  DATE NOT NULL,
        period_from   TINYINT NOT NULL,
        period_to     TINYINT NOT NULL,
        status        VARCHAR(10) NOT NULL, -- PRESENT/ABSENT/LATE/EXCUSED
        note          NVARCHAR(200) NULL,
        created_by    VARCHAR(50) NULL,
        created_at    DATETIME NOT NULL DEFAULT(GETDATE())
    );
END
GO

-- APPEALS (Phúc khảo)
IF OBJECT_ID('dbo.appeals', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.appeals (
        appeal_id   VARCHAR(50) NOT NULL PRIMARY KEY,
        student_id  VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES dbo.students(student_id),
        class_id    VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES dbo.classes(class_id),
        reason      NVARCHAR(500) NULL,
        status      VARCHAR(20) NOT NULL DEFAULT('SUBMITTED'), -- SUBMITTED/REVIEWING/APPROVED/REJECTED
        created_at  DATETIME NOT NULL DEFAULT(GETDATE()),
        decided_at  DATETIME NULL,
        decided_by  VARCHAR(50) NULL
    );
END
GO

-- NOTIFICATIONS
IF OBJECT_ID('dbo.notifications', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.notifications (
        notification_id VARCHAR(50) NOT NULL PRIMARY KEY,
        student_id      VARCHAR(50) NULL FOREIGN KEY REFERENCES dbo.students(student_id),
        type            VARCHAR(30) NOT NULL, -- ATTENDANCE_ALERT/GRADE_NOTICE/GENERAL
        title           NVARCHAR(150) NOT NULL,
        content         NVARCHAR(MAX) NOT NULL,
        is_read         BIT NOT NULL DEFAULT(0),
        created_at      DATETIME NOT NULL DEFAULT(GETDATE())
    );
END
GO

-- CONFIGS
IF OBJECT_ID('dbo.configs', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.configs (
        config_key   VARCHAR(50) NOT NULL PRIMARY KEY,
        config_value NVARCHAR(200) NOT NULL
    );
    IF NOT EXISTS (SELECT 1 FROM dbo.configs WHERE config_key = 'ATTENDANCE_THRESHOLD_PERCENT')
        INSERT INTO dbo.configs(config_key, config_value) VALUES ('ATTENDANCE_THRESHOLD_PERCENT', '20');
    IF NOT EXISTS (SELECT 1 FROM dbo.configs WHERE config_key = 'GRADE_FORMULA_JSON')
        INSERT INTO dbo.configs(config_key, config_value) VALUES ('GRADE_FORMULA_JSON', '{"quiz":0.2,"midterm":0.3,"final":0.5}');
END
GO

-- AUDIT LOGS
IF OBJECT_ID('dbo.audit_logs', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.audit_logs (
        audit_id   BIGINT IDENTITY(1,1) PRIMARY KEY,
        entity     VARCHAR(30) NOT NULL,
        entity_id  VARCHAR(50) NOT NULL,
        action     VARCHAR(20) NOT NULL,
        changed_by VARCHAR(50) NOT NULL,
        changed_at DATETIME NOT NULL DEFAULT(GETDATE()),
        before_json NVARCHAR(MAX) NULL,
        after_json  NVARCHAR(MAX) NULL
    );
END
GO


