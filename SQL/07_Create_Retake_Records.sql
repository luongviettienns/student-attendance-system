-- ===========================================
-- 07_Create_Retake_Records.sql
-- ===========================================
-- Description: Retake Records Management
-- Date: 2024
-- ===========================================

USE EducationManagement;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

PRINT '========================================';
PRINT 'Starting: 07_Create_Retake_Records.sql';
PRINT 'Retake Records Table and Stored Procedures';
PRINT '========================================';
GO

-- ===========================================
-- 1. BẢNG RETAKE_RECORDS (Học lại)
-- ===========================================
IF OBJECT_ID('dbo.retake_records', 'U') IS NOT NULL DROP TABLE dbo.retake_records;
GO

CREATE TABLE dbo.retake_records (
    retake_id          VARCHAR(50) PRIMARY KEY,
    enrollment_id      VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES dbo.enrollments(enrollment_id),
    student_id         VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES dbo.students(student_id),
    class_id           VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES dbo.classes(class_id),
    subject_id         VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES dbo.subjects(subject_id),
    
    -- Thông tin học lại
    reason             NVARCHAR(20) NOT NULL, -- ATTENDANCE, GRADE, BOTH
    threshold_value    DECIMAL(5,2) NULL,     -- Giá trị ngưỡng (20% cho vắng, 4.0 cho điểm)
    current_value      DECIMAL(5,2) NULL,     -- Giá trị hiện tại (absence rate hoặc grade)
    
    -- Workflow
    status             NVARCHAR(20) NOT NULL DEFAULT 'PENDING', -- PENDING, APPROVED, REJECTED, COMPLETED
    advisor_notes      NVARCHAR(1000) NULL,   -- Ghi chú từ advisor
    
    -- Audit fields
    created_at         DATETIME NOT NULL DEFAULT(GETDATE()),
    created_by         VARCHAR(50) NULL,      -- System hoặc user tạo
    updated_at         DATETIME NULL,
    updated_by         VARCHAR(50) NULL,
    resolved_at       DATETIME NULL,
    resolved_by        VARCHAR(50) NULL,     -- Advisor ID
    deleted_at         DATETIME NULL,
    deleted_by         VARCHAR(50) NULL,
    
    -- Constraints
    CONSTRAINT CHK_Retake_Reason CHECK (reason IN ('ATTENDANCE', 'GRADE', 'BOTH')),
    CONSTRAINT CHK_Retake_Status CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED', 'COMPLETED'))
);
GO

-- Indexes for retake_records
CREATE INDEX IX_Retake_Student ON retake_records(student_id, status);
CREATE INDEX IX_Retake_Enrollment ON retake_records(enrollment_id);
CREATE INDEX IX_Retake_Class ON retake_records(class_id, status);
CREATE INDEX IX_Retake_Status ON retake_records(status, created_at);
CREATE INDEX IX_Retake_Subject ON retake_records(subject_id);
GO

PRINT '✅ Table created: retake_records';
GO

-- ===========================================
-- 2. STORED PROCEDURES
-- ===========================================

-- 2.1. CREATE RETAKE RECORD
IF OBJECT_ID('sp_CreateRetakeRecord', 'P') IS NOT NULL DROP PROCEDURE sp_CreateRetakeRecord;
GO
CREATE PROCEDURE sp_CreateRetakeRecord
    @RetakeId VARCHAR(50),
    @EnrollmentId VARCHAR(50),
    @StudentId VARCHAR(50),
    @ClassId VARCHAR(50),
    @SubjectId VARCHAR(50),
    @Reason NVARCHAR(20),
    @ThresholdValue DECIMAL(5,2) = NULL,
    @CurrentValue DECIMAL(5,2) = NULL,
    @CreatedBy VARCHAR(50) = 'system'
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate reason
    IF @Reason NOT IN ('ATTENDANCE', 'GRADE', 'BOTH')
    BEGIN
        RAISERROR('Invalid reason. Must be ATTENDANCE, GRADE, or BOTH', 16, 1);
        RETURN;
    END
    
    -- Check if retake record already exists for this enrollment
    IF EXISTS (SELECT 1 FROM dbo.retake_records 
               WHERE enrollment_id = @EnrollmentId 
               AND deleted_at IS NULL
               AND status IN ('PENDING', 'APPROVED'))
    BEGIN
        RAISERROR('Retake record already exists for this enrollment', 16, 1);
        RETURN;
    END
    
    INSERT INTO dbo.retake_records (
        retake_id, enrollment_id, student_id, class_id, subject_id,
        reason, threshold_value, current_value, status,
        created_at, created_by
    )
    VALUES (
        @RetakeId, @EnrollmentId, @StudentId, @ClassId, @SubjectId,
        @Reason, @ThresholdValue, @CurrentValue, 'PENDING',
        GETDATE(), @CreatedBy
    );
    
    SELECT @RetakeId as retake_id;
END
GO

-- 2.2. GET RETAKE RECORD BY ID
IF OBJECT_ID('sp_GetRetakeRecordById', 'P') IS NOT NULL DROP PROCEDURE sp_GetRetakeRecordById;
GO
CREATE PROCEDURE sp_GetRetakeRecordById
    @RetakeId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        r.retake_id,
        r.enrollment_id,
        r.student_id,
        s.student_code,
        s.full_name as student_name,
        r.class_id,
        c.class_code,
        c.class_name,
        r.subject_id,
        sub.subject_code,
        sub.subject_name,
        r.reason,
        r.threshold_value,
        r.current_value,
        r.status,
        r.advisor_notes,
        r.created_at,
        r.created_by,
        r.updated_at,
        r.updated_by,
        r.resolved_at,
        r.resolved_by,
        -- Additional info
        e.enrollment_date,
        sy.year_code as school_year_code,
        c.semester
    FROM dbo.retake_records r
    INNER JOIN dbo.students s ON r.student_id = s.student_id
    INNER JOIN dbo.classes c ON r.class_id = c.class_id
    INNER JOIN dbo.subjects sub ON r.subject_id = sub.subject_id
    INNER JOIN dbo.enrollments e ON r.enrollment_id = e.enrollment_id
    LEFT JOIN dbo.school_years sy ON c.school_year_id = sy.school_year_id
    WHERE r.retake_id = @RetakeId
        AND r.deleted_at IS NULL;
END
GO

-- 2.3. GET RETAKE RECORDS BY STUDENT
IF OBJECT_ID('sp_GetRetakeRecordsByStudent', 'P') IS NOT NULL DROP PROCEDURE sp_GetRetakeRecordsByStudent;
GO
CREATE PROCEDURE sp_GetRetakeRecordsByStudent
    @StudentId VARCHAR(50),
    @Status NVARCHAR(20) = NULL,
    @Page INT = 1,
    @PageSize INT = 50
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Offset INT = (@Page - 1) * @PageSize;
    
    -- Get retake records
    SELECT 
        r.retake_id,
        r.enrollment_id,
        r.student_id,
        r.class_id,
        c.class_code,
        c.class_name,
        r.subject_id,
        sub.subject_code,
        sub.subject_name,
        r.reason,
        r.threshold_value,
        r.current_value,
        r.status,
        r.advisor_notes,
        r.created_at,
        r.updated_at,
        r.resolved_at,
        sy.year_code as school_year_code,
        c.semester
    FROM dbo.retake_records r
    INNER JOIN dbo.classes c ON r.class_id = c.class_id
    INNER JOIN dbo.subjects sub ON r.subject_id = sub.subject_id
    LEFT JOIN dbo.school_years sy ON c.school_year_id = sy.school_year_id
    WHERE r.student_id = @StudentId
        AND r.deleted_at IS NULL
        AND (@Status IS NULL OR r.status = @Status)
    ORDER BY r.created_at DESC
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;
    
    -- Get total count
    SELECT COUNT(*) as total_count
    FROM dbo.retake_records r
    WHERE r.student_id = @StudentId
        AND r.deleted_at IS NULL
        AND (@Status IS NULL OR r.status = @Status);
END
GO

-- 2.4. GET RETAKE RECORDS BY CLASS
IF OBJECT_ID('sp_GetRetakeRecordsByClass', 'P') IS NOT NULL DROP PROCEDURE sp_GetRetakeRecordsByClass;
GO
CREATE PROCEDURE sp_GetRetakeRecordsByClass
    @ClassId VARCHAR(50),
    @Status NVARCHAR(20) = NULL,
    @Page INT = 1,
    @PageSize INT = 50
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Offset INT = (@Page - 1) * @PageSize;
    
    -- Get retake records
    SELECT 
        r.retake_id,
        r.enrollment_id,
        r.student_id,
        s.student_code,
        s.full_name as student_name,
        r.class_id,
        c.class_code,
        c.class_name,
        r.subject_id,
        sub.subject_code,
        sub.subject_name,
        r.reason,
        r.threshold_value,
        r.current_value,
        r.status,
        r.advisor_notes,
        r.created_at,
        r.updated_at,
        r.resolved_at,
        r.resolved_by
    FROM dbo.retake_records r
    INNER JOIN dbo.students s ON r.student_id = s.student_id
    INNER JOIN dbo.classes c ON r.class_id = c.class_id
    INNER JOIN dbo.subjects sub ON r.subject_id = sub.subject_id
    WHERE r.class_id = @ClassId
        AND r.deleted_at IS NULL
        AND (@Status IS NULL OR r.status = @Status)
    ORDER BY r.created_at DESC
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;
    
    -- Get total count
    SELECT COUNT(*) as total_count
    FROM dbo.retake_records r
    WHERE r.class_id = @ClassId
        AND r.deleted_at IS NULL
        AND (@Status IS NULL OR r.status = @Status);
END
GO

-- 2.5. GET RETAKE RECORD BY ENROLLMENT
IF OBJECT_ID('sp_GetRetakeRecordByEnrollment', 'P') IS NOT NULL DROP PROCEDURE sp_GetRetakeRecordByEnrollment;
GO
CREATE PROCEDURE sp_GetRetakeRecordByEnrollment
    @EnrollmentId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        r.retake_id,
        r.enrollment_id,
        r.student_id,
        r.class_id,
        r.subject_id,
        r.reason,
        r.threshold_value,
        r.current_value,
        r.status,
        r.advisor_notes,
        r.created_at,
        r.updated_at,
        r.resolved_at
    FROM dbo.retake_records r
    WHERE r.enrollment_id = @EnrollmentId
        AND r.deleted_at IS NULL;
END
GO

-- 2.6. UPDATE RETAKE STATUS
IF OBJECT_ID('sp_UpdateRetakeStatus', 'P') IS NOT NULL DROP PROCEDURE sp_UpdateRetakeStatus;
GO
CREATE PROCEDURE sp_UpdateRetakeStatus
    @RetakeId VARCHAR(50),
    @Status NVARCHAR(20),
    @AdvisorNotes NVARCHAR(1000) = NULL,
    @UpdatedBy VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate status
    IF @Status NOT IN ('PENDING', 'APPROVED', 'REJECTED', 'COMPLETED')
    BEGIN
        RAISERROR('Invalid status. Must be PENDING, APPROVED, REJECTED, or COMPLETED', 16, 1);
        RETURN;
    END
    
    UPDATE dbo.retake_records
    SET 
        status = @Status,
        advisor_notes = ISNULL(@AdvisorNotes, advisor_notes),
        updated_at = GETDATE(),
        updated_by = @UpdatedBy,
        resolved_at = CASE WHEN @Status IN ('APPROVED', 'REJECTED', 'COMPLETED') THEN GETDATE() ELSE resolved_at END,
        resolved_by = CASE WHEN @Status IN ('APPROVED', 'REJECTED', 'COMPLETED') THEN @UpdatedBy ELSE resolved_by END
    WHERE retake_id = @RetakeId
        AND deleted_at IS NULL;
    
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('Retake record not found or already deleted', 16, 1);
        RETURN;
    END
END
GO

-- 2.7. CHECK RETAKE REQUIRED (Helper function)
IF OBJECT_ID('sp_CheckRetakeRequired', 'P') IS NOT NULL DROP PROCEDURE sp_CheckRetakeRequired;
GO
CREATE PROCEDURE sp_CheckRetakeRequired
    @EnrollmentId VARCHAR(50),
    @AttendanceThreshold DECIMAL(5,2) = 20.0,
    @GradeThreshold DECIMAL(4,2) = 4.0
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @StudentId VARCHAR(50);
    DECLARE @ClassId VARCHAR(50);
    DECLARE @SubjectId VARCHAR(50);
    DECLARE @AbsenceRate DECIMAL(5,2);
    DECLARE @TotalScore DECIMAL(4,2);
    DECLARE @Reason NVARCHAR(20) = NULL;
    DECLARE @CurrentValue DECIMAL(5,2) = NULL;
    
    -- Get enrollment info
    SELECT 
        @StudentId = e.student_id,
        @ClassId = e.class_id,
        @SubjectId = c.subject_id
    FROM dbo.enrollments e
    INNER JOIN dbo.classes c ON e.class_id = c.class_id
    WHERE e.enrollment_id = @EnrollmentId
        AND e.deleted_at IS NULL;
    
    IF @StudentId IS NULL
    BEGIN
        SELECT 'NOT_FOUND' as result, NULL as reason, NULL as current_value;
        RETURN;
    END
    
    -- Check if retake already exists
    IF EXISTS (SELECT 1 FROM dbo.retake_records 
               WHERE enrollment_id = @EnrollmentId 
               AND deleted_at IS NULL
               AND status IN ('PENDING', 'APPROVED'))
    BEGIN
        SELECT 'EXISTS' as result, NULL as reason, NULL as current_value;
        RETURN;
    END
    
    -- Calculate absence rate
    SELECT @AbsenceRate = CAST(ROUND((COUNT(CASE WHEN a.status = 'Absent' THEN 1 END) * 100.0 / 
                                     NULLIF(COUNT(a.attendance_id), 0)), 2) AS DECIMAL(5,2))
    FROM dbo.attendances a
    WHERE a.enrollment_id = @EnrollmentId
        AND a.deleted_at IS NULL;
    
    -- Get total score
    SELECT @TotalScore = g.total_score
    FROM dbo.grades g
    WHERE g.enrollment_id = @EnrollmentId
        AND g.total_score IS NOT NULL;
    
    -- Determine reason
    IF @AbsenceRate > @AttendanceThreshold AND (@TotalScore IS NULL OR @TotalScore < @GradeThreshold)
    BEGIN
        SET @Reason = 'BOTH';
        SET @CurrentValue = @AbsenceRate; -- Use absence rate as primary value
    END
    ELSE IF @AbsenceRate > @AttendanceThreshold
    BEGIN
        SET @Reason = 'ATTENDANCE';
        SET @CurrentValue = @AbsenceRate;
    END
    ELSE IF @TotalScore IS NOT NULL AND @TotalScore < @GradeThreshold
    BEGIN
        SET @Reason = 'GRADE';
        SET @CurrentValue = @TotalScore;
    END
    
    -- Return result
    IF @Reason IS NOT NULL
    BEGIN
        SELECT 'REQUIRED' as result, @Reason as reason, @CurrentValue as current_value,
               @StudentId as student_id, @ClassId as class_id, @SubjectId as subject_id,
               CASE 
                   WHEN @Reason = 'ATTENDANCE' THEN @AttendanceThreshold
                   WHEN @Reason = 'GRADE' THEN @GradeThreshold
                   ELSE @AttendanceThreshold
               END as threshold_value;
    END
    ELSE
    BEGIN
        SELECT 'NOT_REQUIRED' as result, NULL as reason, NULL as current_value;
    END
END
GO

PRINT '[OK] Retake Records SPs completed';
GO

PRINT '========================================';
PRINT 'Completed: 07_Create_Retake_Records.sql';
PRINT '========================================';
GO

