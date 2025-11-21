-- ===========================================
-- 🎓 HỆ THỐNG QUẢN LÝ ĐIỂM DANH SINH VIÊN
-- 📋 File: TẠO BẢNG VÀ STORED PROCEDURES CHO LỊCH THI
-- ===========================================

USE EducationManagement;
GO

-- ===========================================
-- BƯỚC 1: BỔ SUNG CÁC TRƯỜNG ĐIỂM VÀO BẢNG GRADES
-- ===========================================

-- Thêm cột attendance_score (điểm chuyên cần) nếu chưa có
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID('dbo.grades') 
    AND name = 'attendance_score'
)
BEGIN
    ALTER TABLE dbo.grades 
    ADD attendance_score DECIMAL(4,2) NULL CHECK (attendance_score >= 0 AND attendance_score <= 10);
    PRINT '✓ Added column: grades.attendance_score';
END
ELSE
BEGIN
    PRINT '✓ Column already exists: grades.attendance_score';
END
GO

-- Thêm cột assignment_score (điểm bài tập) nếu chưa có
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID('dbo.grades') 
    AND name = 'assignment_score'
)
BEGIN
    ALTER TABLE dbo.grades 
    ADD assignment_score DECIMAL(4,2) NULL CHECK (assignment_score >= 0 AND assignment_score <= 10);
    PRINT '✓ Added column: grades.assignment_score';
END
ELSE
BEGIN
    PRINT '✓ Column already exists: grades.assignment_score';
END
GO

-- ===========================================
-- BƯỚC 2: TẠO BẢNG EXAM_SCHEDULES
-- ===========================================

IF OBJECT_ID('dbo.exam_schedules', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.exam_schedules (
        exam_id VARCHAR(50) PRIMARY KEY,
        class_id VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES dbo.classes(class_id),
        subject_id VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES dbo.subjects(subject_id),
        exam_date DATE NOT NULL,
        exam_time TIME NOT NULL, -- Giờ bắt đầu
        end_time TIME NOT NULL, -- Giờ kết thúc
        room_id VARCHAR(50) NULL FOREIGN KEY REFERENCES dbo.rooms(room_id),
        exam_type NVARCHAR(20) NOT NULL CHECK (exam_type IN ('GIỮA_HỌC_PHẦN', 'KẾT_THÚC_HỌC_PHẦN')),
        session_no INT NULL, -- Ca thi (1, 2, 3, ...)
        proctor_lecturer_id VARCHAR(50) NULL FOREIGN KEY REFERENCES dbo.lecturers(lecturer_id),
        duration INT NOT NULL, -- Thời lượng thi (phút)
        max_students INT NULL, -- Số lượng tối đa sinh viên trong ca thi này
        notes NVARCHAR(500) NULL,
        status NVARCHAR(20) NOT NULL DEFAULT 'PLANNED' CHECK (status IN ('PLANNED', 'CONFIRMED', 'COMPLETED', 'CANCELLED')),
        school_year_id VARCHAR(50) NULL FOREIGN KEY REFERENCES dbo.school_years(school_year_id),
        semester INT NULL,
        created_at DATETIME NOT NULL DEFAULT(GETDATE()),
        created_by VARCHAR(50) NULL,
        updated_at DATETIME NULL,
        updated_by VARCHAR(50) NULL,
        deleted_at DATETIME NULL,
        deleted_by VARCHAR(50) NULL,
        -- Constraints
        CONSTRAINT CHK_Exam_Time_Range CHECK (end_time > exam_time),
        CONSTRAINT CHK_Exam_Duration CHECK (duration > 0 AND duration <= 600) -- Tối đa 10 giờ
    );
    PRINT '✓ Table created: exam_schedules';
END
ELSE
BEGIN
    PRINT '✓ Table already exists: exam_schedules';
END
GO

-- ===========================================
-- BƯỚC 3: TẠO BẢNG EXAM_ASSIGNMENTS
-- ===========================================

IF OBJECT_ID('dbo.exam_assignments', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.exam_assignments (
        assignment_id VARCHAR(50) PRIMARY KEY,
        exam_id VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES dbo.exam_schedules(exam_id),
        enrollment_id VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES dbo.enrollments(enrollment_id),
        student_id VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES dbo.students(student_id),
        seat_number INT NULL, -- Số ghế (nếu có)
        status NVARCHAR(20) NULL DEFAULT 'ASSIGNED' CHECK (status IN ('ASSIGNED', 'NOT_QUALIFIED', 'ATTENDED', 'ABSENT', 'EXCUSED')),
        -- NOT_QUALIFIED: Không đủ điều kiện dự thi (vắng mặt > 20%)
        -- ASSIGNED: Đã phân vào ca thi và đủ điều kiện
        -- ATTENDED: Đã dự thi
        -- ABSENT: Vắng thi không lý do
        -- EXCUSED: Vắng thi có lý do
        notes NVARCHAR(500) NULL,
        created_at DATETIME NOT NULL DEFAULT(GETDATE()),
        created_by VARCHAR(50) NULL,
        deleted_at DATETIME NULL,
        deleted_by VARCHAR(50) NULL
    );
    PRINT '✓ Table created: exam_assignments';
END
ELSE
BEGIN
    PRINT '✓ Table already exists: exam_assignments';
END
GO

-- ===========================================
-- BƯỚC 4: TẠO INDEXES
-- ===========================================

-- Indexes cho exam_schedules
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ExamSchedules_Date' AND object_id = OBJECT_ID('exam_schedules'))
    CREATE INDEX IX_ExamSchedules_Date ON exam_schedules(exam_date, school_year_id, semester);
PRINT '✓ Index created: IX_ExamSchedules_Date';

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ExamSchedules_Room_Time' AND object_id = OBJECT_ID('exam_schedules'))
    CREATE INDEX IX_ExamSchedules_Room_Time ON exam_schedules(room_id, exam_date, exam_time);
PRINT '✓ Index created: IX_ExamSchedules_Room_Time';

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ExamSchedules_Class' AND object_id = OBJECT_ID('exam_schedules'))
    CREATE INDEX IX_ExamSchedules_Class ON exam_schedules(class_id, exam_type);
PRINT '✓ Index created: IX_ExamSchedules_Class';

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ExamSchedules_Subject' AND object_id = OBJECT_ID('exam_schedules'))
    CREATE INDEX IX_ExamSchedules_Subject ON exam_schedules(subject_id, exam_date);
PRINT '✓ Index created: IX_ExamSchedules_Subject';

-- Indexes cho exam_assignments
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ExamAssignments_Exam' AND object_id = OBJECT_ID('exam_assignments'))
    CREATE INDEX IX_ExamAssignments_Exam ON exam_assignments(exam_id);
PRINT '✓ Index created: IX_ExamAssignments_Exam';

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ExamAssignments_Student' AND object_id = OBJECT_ID('exam_assignments'))
    CREATE INDEX IX_ExamAssignments_Student ON exam_assignments(student_id, exam_id);
PRINT '✓ Index created: IX_ExamAssignments_Student';

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ExamAssignments_Enrollment' AND object_id = OBJECT_ID('exam_assignments'))
    CREATE INDEX IX_ExamAssignments_Enrollment ON exam_assignments(enrollment_id);
PRINT '✓ Index created: IX_ExamAssignments_Enrollment';

GO

PRINT '';
PRINT '========================================';
PRINT '✅ DATABASE SCHEMA FOR EXAM SCHEDULES COMPLETED!';
PRINT '========================================';
PRINT '';

