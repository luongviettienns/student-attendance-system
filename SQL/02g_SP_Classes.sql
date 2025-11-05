-- ===========================================
-- 02g_SP_Classes.sql
-- ===========================================
-- Description: Classes Management SPs, Enrollments Management SPs
-- Generated from: SQL/02_StoredProcedures.sql
-- ===========================================

USE EducationManagement;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

PRINT '========================================';
PRINT 'Starting: 02g_SP_Classes.sql';
PRINT '========================================';
GO

-- ===========================================
-- 9. CLASSES MANAGEMENT
-- ===========================================

IF OBJECT_ID('sp_GetAllClasses', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllClasses;
GO
CREATE PROCEDURE sp_GetAllClasses
AS
BEGIN
    SELECT c.*, s.subject_name, l.full_name as lecturer_name, ay.year_name
    FROM dbo.classes c
    LEFT JOIN dbo.subjects s ON c.subject_id = s.subject_id
    LEFT JOIN dbo.lecturers l ON c.lecturer_id = l.lecturer_id
    LEFT JOIN dbo.academic_years ay ON c.academic_year_id = ay.academic_year_id
    WHERE c.deleted_at IS NULL
    ORDER BY c.created_at DESC;
END
GO

IF OBJECT_ID('sp_GetClassById', 'P') IS NOT NULL DROP PROCEDURE sp_GetClassById;
GO
CREATE PROCEDURE sp_GetClassById
    @ClassId VARCHAR(50)
AS
BEGIN
    SELECT c.*, s.subject_name, l.full_name as lecturer_name, ay.year_name
    FROM dbo.classes c
    LEFT JOIN dbo.subjects s ON c.subject_id = s.subject_id
    LEFT JOIN dbo.lecturers l ON c.lecturer_id = l.lecturer_id
    LEFT JOIN dbo.academic_years ay ON c.academic_year_id = ay.academic_year_id
    WHERE c.class_id = @ClassId AND c.deleted_at IS NULL;
END
GO

IF OBJECT_ID('sp_CreateClass', 'P') IS NOT NULL DROP PROCEDURE sp_CreateClass;
GO
CREATE PROCEDURE sp_CreateClass
    @ClassId VARCHAR(50),
    @ClassCode VARCHAR(20),
    @ClassName NVARCHAR(200),
    @SubjectId VARCHAR(50),
    @LecturerId VARCHAR(50) = NULL,
    @AcademicYearId VARCHAR(50) = NULL,
    @Semester INT = NULL,
    @MaxStudents INT = NULL,
    @Schedule NVARCHAR(500) = NULL,
    @Room NVARCHAR(100) = NULL,
    @CreatedBy VARCHAR(50) = 'system'
AS
BEGIN
    INSERT INTO dbo.classes (class_id, class_code, class_name, subject_id, lecturer_id,
                             academic_year_id, semester, max_students, schedule, room,
                             created_at, created_by)
    VALUES (@ClassId, @ClassCode, @ClassName, @SubjectId, @LecturerId, @AcademicYearId,
            @Semester, @MaxStudents, @Schedule, @Room, GETDATE(), @CreatedBy);
    SELECT @ClassId AS class_id;
END
GO

IF OBJECT_ID('sp_UpdateClass', 'P') IS NOT NULL DROP PROCEDURE sp_UpdateClass;
GO
CREATE PROCEDURE sp_UpdateClass
    @ClassId VARCHAR(50),
    @ClassCode VARCHAR(20),
    @ClassName NVARCHAR(200),
    @SubjectId VARCHAR(50),
    @LecturerId VARCHAR(50) = NULL,
    @Semester INT = NULL,
    @AcademicYearId VARCHAR(50) = NULL,
    @MaxStudents INT = NULL,
    @Schedule NVARCHAR(500) = NULL,
    @Room NVARCHAR(100) = NULL,
    @UpdatedBy VARCHAR(50) = 'system'
AS
BEGIN
    UPDATE dbo.classes
    SET class_code = @ClassCode, class_name = @ClassName, subject_id = @SubjectId,
        lecturer_id = @LecturerId, semester = @Semester, academic_year_id = @AcademicYearId,
        max_students = @MaxStudents, schedule = @Schedule, room = @Room, 
        updated_at = GETDATE(), updated_by = @UpdatedBy
    WHERE class_id = @ClassId AND deleted_at IS NULL;
END
GO

IF OBJECT_ID('sp_DeleteClass', 'P') IS NOT NULL DROP PROCEDURE sp_DeleteClass;
GO
CREATE PROCEDURE sp_DeleteClass
    @ClassId VARCHAR(50),
    @DeletedBy VARCHAR(50) = 'system'
AS
BEGIN
    UPDATE dbo.classes
    SET deleted_at = GETDATE(), deleted_by = @DeletedBy
    WHERE class_id = @ClassId;
END
GO

PRINT '[OK] Classes Management SPs created';
GO

-- ===========================================
-- 10. ENROLLMENTS MANAGEMENT
-- ===========================================

IF OBJECT_ID('sp_GetEnrollmentsByClass', 'P') IS NOT NULL DROP PROCEDURE sp_GetEnrollmentsByClass;
GO
CREATE PROCEDURE sp_GetEnrollmentsByClass
    @ClassId VARCHAR(50)
AS
BEGIN
    SELECT e.*, s.student_code, s.full_name as student_name
    FROM dbo.enrollments e
    LEFT JOIN dbo.students s ON e.student_id = s.student_id
    WHERE e.class_id = @ClassId AND e.deleted_at IS NULL
    ORDER BY s.student_code;
END
GO

IF OBJECT_ID('sp_CreateEnrollment', 'P') IS NOT NULL DROP PROCEDURE sp_CreateEnrollment;
GO
CREATE PROCEDURE sp_CreateEnrollment
    @EnrollmentId VARCHAR(50),
    @StudentId VARCHAR(50),
    @ClassId VARCHAR(50),
    @Status NVARCHAR(50) = N'Äang há»c',
    @CreatedBy VARCHAR(50) = 'system'
AS
BEGIN
    INSERT INTO dbo.enrollments (enrollment_id, student_id, class_id, status,
                                  enrollment_date, created_at, created_by)
    VALUES (@EnrollmentId, @StudentId, @ClassId, @Status, GETDATE(), GETDATE(), @CreatedBy);
END
GO

IF OBJECT_ID('sp_DeleteEnrollment', 'P') IS NOT NULL DROP PROCEDURE sp_DeleteEnrollment;
GO
CREATE PROCEDURE sp_DeleteEnrollment
    @EnrollmentId VARCHAR(50),
    @DeletedBy VARCHAR(50) = 'system'
AS
BEGIN
    UPDATE dbo.enrollments
    SET deleted_at = GETDATE(), deleted_by = @DeletedBy
    WHERE enrollment_id = @EnrollmentId;
END
GO

-- SP: Get All Enrollments
IF OBJECT_ID('sp_GetAllEnrollments', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllEnrollments;
GO
CREATE PROCEDURE sp_GetAllEnrollments
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        e.enrollment_id,
        e.student_id,
        e.class_id,
        e.enrollment_date,
        e.status,
        e.enrollment_status,
        e.drop_deadline,
        e.notes,
        e.drop_reason,
        e.created_at,
        e.created_by,
        e.updated_at,
        e.updated_by,
        s.student_code,
        s.full_name as student_name,
        c.class_code,
        c.class_name,
        sub.subject_code,
        sub.subject_name
    FROM dbo.enrollments e
    INNER JOIN dbo.students s ON e.student_id = s.student_id
    INNER JOIN dbo.classes c ON e.class_id = c.class_id
    LEFT JOIN dbo.subjects sub ON c.subject_id = sub.subject_id
    WHERE e.deleted_at IS NULL
    ORDER BY e.enrollment_date DESC;
END
GO

-- SP: Get Enrollment By ID
IF OBJECT_ID('sp_GetEnrollmentById', 'P') IS NOT NULL DROP PROCEDURE sp_GetEnrollmentById;
GO
CREATE PROCEDURE sp_GetEnrollmentById
    @EnrollmentId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        e.enrollment_id,
        e.student_id,
        e.class_id,
        e.enrollment_date,
        e.status,
        e.enrollment_status,
        e.drop_deadline,
        e.notes,
        e.drop_reason,
        e.created_at,
        e.created_by,
        e.updated_at,
        e.updated_by,
        s.student_code,
        s.full_name as student_name,
        c.class_code,
        c.class_name,
        sub.subject_code,
        sub.subject_name
    FROM dbo.enrollments e
    INNER JOIN dbo.students s ON e.student_id = s.student_id
    INNER JOIN dbo.classes c ON e.class_id = c.class_id
    LEFT JOIN dbo.subjects sub ON c.subject_id = sub.subject_id
    WHERE e.enrollment_id = @EnrollmentId AND e.deleted_at IS NULL;
END
GO

-- SP: Withdraw Enrollment
IF OBJECT_ID('sp_WithdrawEnrollment', 'P') IS NOT NULL DROP PROCEDURE sp_WithdrawEnrollment;
GO
CREATE PROCEDURE sp_WithdrawEnrollment
    @EnrollmentId VARCHAR(50),
    @Reason NVARCHAR(500) = NULL,
    @WithdrawnBy VARCHAR(50) = 'system'
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.enrollments
    SET enrollment_status = 'WITHDRAWN',
        drop_reason = @Reason,
        updated_at = GETDATE(),
        updated_by = @WithdrawnBy
    WHERE enrollment_id = @EnrollmentId AND deleted_at IS NULL;
END
GO

-- SP: Get Classes By Lecturer
IF OBJECT_ID('sp_GetClassesByLecturer', 'P') IS NOT NULL DROP PROCEDURE sp_GetClassesByLecturer;
GO
CREATE PROCEDURE sp_GetClassesByLecturer
    @LecturerId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        c.class_id,
        c.class_code,
        c.class_name,
        c.subject_id,
        c.lecturer_id,
        c.academic_year_id,
        c.semester,
        c.max_students,
        c.current_enrollment,
        c.schedule,
        c.room,
        c.created_at,
        c.created_by,
        s.subject_code,
        s.subject_name,
        l.full_name as lecturer_name,
        ay.year_name
    FROM dbo.classes c
    LEFT JOIN dbo.subjects s ON c.subject_id = s.subject_id
    LEFT JOIN dbo.lecturers l ON c.lecturer_id = l.lecturer_id
    LEFT JOIN dbo.academic_years ay ON c.academic_year_id = ay.academic_year_id
    WHERE c.lecturer_id = @LecturerId AND c.deleted_at IS NULL
    ORDER BY c.created_at DESC;
END
GO

-- SP: Get Classes By Student
IF OBJECT_ID('sp_GetClassesByStudent', 'P') IS NOT NULL DROP PROCEDURE sp_GetClassesByStudent;
GO
CREATE PROCEDURE sp_GetClassesByStudent
    @StudentId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        c.class_id,
        c.class_code,
        c.class_name,
        c.subject_id,
        c.lecturer_id,
        c.academic_year_id,
        c.semester,
        c.max_students,
        c.current_enrollment,
        c.schedule,
        c.room,
        c.created_at,
        e.enrollment_id,
        e.enrollment_date,
        e.enrollment_status,
        s.subject_code,
        s.subject_name,
        l.full_name as lecturer_name,
        ay.year_name
    FROM dbo.classes c
    INNER JOIN dbo.enrollments e ON c.class_id = e.class_id
    LEFT JOIN dbo.subjects s ON c.subject_id = s.subject_id
    LEFT JOIN dbo.lecturers l ON c.lecturer_id = l.lecturer_id
    LEFT JOIN dbo.academic_years ay ON c.academic_year_id = ay.academic_year_id
    WHERE e.student_id = @StudentId AND e.deleted_at IS NULL AND c.deleted_at IS NULL
    ORDER BY c.created_at DESC;
END
GO

PRINT '[OK] Enrollments Management SPs created';
GO

-- ===========================================
-- 9. CLASSES MANAGEMENT
-- ===========================================

IF OBJECT_ID('sp_GetAllClasses', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllClasses;
GO
CREATE PROCEDURE sp_GetAllClasses
AS
BEGIN
    SELECT c.*, s.subject_name, l.full_name as lecturer_name, ay.year_name
    FROM dbo.classes c
    LEFT JOIN dbo.subjects s ON c.subject_id = s.subject_id
    LEFT JOIN dbo.lecturers l ON c.lecturer_id = l.lecturer_id
    LEFT JOIN dbo.academic_years ay ON c.academic_year_id = ay.academic_year_id
    WHERE c.deleted_at IS NULL
    ORDER BY c.created_at DESC;
END
GO

IF OBJECT_ID('sp_GetClassById', 'P') IS NOT NULL DROP PROCEDURE sp_GetClassById;
GO
CREATE PROCEDURE sp_GetClassById
    @ClassId VARCHAR(50)
AS
BEGIN
    SELECT c.*, s.subject_name, l.full_name as lecturer_name, ay.year_name
    FROM dbo.classes c
    LEFT JOIN dbo.subjects s ON c.subject_id = s.subject_id
    LEFT JOIN dbo.lecturers l ON c.lecturer_id = l.lecturer_id
    LEFT JOIN dbo.academic_years ay ON c.academic_year_id = ay.academic_year_id
    WHERE c.class_id = @ClassId AND c.deleted_at IS NULL;
END
GO

IF OBJECT_ID('sp_CreateClass', 'P') IS NOT NULL DROP PROCEDURE sp_CreateClass;
GO
CREATE PROCEDURE sp_CreateClass
    @ClassId VARCHAR(50),
    @ClassCode VARCHAR(20),
    @ClassName NVARCHAR(200),
    @SubjectId VARCHAR(50),
    @LecturerId VARCHAR(50) = NULL,
    @AcademicYearId VARCHAR(50) = NULL,
    @Semester INT = NULL,
    @MaxStudents INT = NULL,
    @Schedule NVARCHAR(500) = NULL,
    @Room NVARCHAR(100) = NULL,
    @CreatedBy VARCHAR(50) = 'system'
AS
BEGIN
    INSERT INTO dbo.classes (class_id, class_code, class_name, subject_id, lecturer_id,
                             academic_year_id, semester, max_students, schedule, room,
                             created_at, created_by)
    VALUES (@ClassId, @ClassCode, @ClassName, @SubjectId, @LecturerId, @AcademicYearId,
            @Semester, @MaxStudents, @Schedule, @Room, GETDATE(), @CreatedBy);
    SELECT @ClassId AS class_id;
END
GO

IF OBJECT_ID('sp_UpdateClass', 'P') IS NOT NULL DROP PROCEDURE sp_UpdateClass;
GO
CREATE PROCEDURE sp_UpdateClass
    @ClassId VARCHAR(50),
    @ClassCode VARCHAR(20),
    @ClassName NVARCHAR(200),
    @SubjectId VARCHAR(50),
    @LecturerId VARCHAR(50) = NULL,
    @Semester INT = NULL,
    @AcademicYearId VARCHAR(50) = NULL,
    @MaxStudents INT = NULL,
    @Schedule NVARCHAR(500) = NULL,
    @Room NVARCHAR(100) = NULL,
    @UpdatedBy VARCHAR(50) = 'system'
AS
BEGIN
    UPDATE dbo.classes
    SET class_code = @ClassCode, class_name = @ClassName, subject_id = @SubjectId,
        lecturer_id = @LecturerId, semester = @Semester, academic_year_id = @AcademicYearId,
        max_students = @MaxStudents, schedule = @Schedule, room = @Room, 
        updated_at = GETDATE(), updated_by = @UpdatedBy
    WHERE class_id = @ClassId AND deleted_at IS NULL;
END
GO

IF OBJECT_ID('sp_DeleteClass', 'P') IS NOT NULL DROP PROCEDURE sp_DeleteClass;
GO
CREATE PROCEDURE sp_DeleteClass
    @ClassId VARCHAR(50),
    @DeletedBy VARCHAR(50) = 'system'
AS
BEGIN
    UPDATE dbo.classes
    SET deleted_at = GETDATE(), deleted_by = @DeletedBy
    WHERE class_id = @ClassId;
END
GO

PRINT '[OK] Classes Management SPs created';
GO

-- ===========================================
-- 10. ENROLLMENTS MANAGEMENT
-- ===========================================

IF OBJECT_ID('sp_GetEnrollmentsByClass', 'P') IS NOT NULL DROP PROCEDURE sp_GetEnrollmentsByClass;
GO
CREATE PROCEDURE sp_GetEnrollmentsByClass
    @ClassId VARCHAR(50)
AS
BEGIN
    SELECT e.*, s.student_code, s.full_name as student_name
    FROM dbo.enrollments e
    LEFT JOIN dbo.students s ON e.student_id = s.student_id
    WHERE e.class_id = @ClassId AND e.deleted_at IS NULL
    ORDER BY s.student_code;
END
GO

IF OBJECT_ID('sp_CreateEnrollment', 'P') IS NOT NULL DROP PROCEDURE sp_CreateEnrollment;
GO
CREATE PROCEDURE sp_CreateEnrollment
    @EnrollmentId VARCHAR(50),
    @StudentId VARCHAR(50),
    @ClassId VARCHAR(50),
    @Status NVARCHAR(50) = N'Äang há»c',
    @CreatedBy VARCHAR(50) = 'system'
AS
BEGIN
    INSERT INTO dbo.enrollments (enrollment_id, student_id, class_id, status,
                                  enrollment_date, created_at, created_by)
    VALUES (@EnrollmentId, @StudentId, @ClassId, @Status, GETDATE(), GETDATE(), @CreatedBy);
END
GO

IF OBJECT_ID('sp_DeleteEnrollment', 'P') IS NOT NULL DROP PROCEDURE sp_DeleteEnrollment;
GO
CREATE PROCEDURE sp_DeleteEnrollment
    @EnrollmentId VARCHAR(50),
    @DeletedBy VARCHAR(50) = 'system'
AS
BEGIN
    UPDATE dbo.enrollments
    SET deleted_at = GETDATE(), deleted_by = @DeletedBy
    WHERE enrollment_id = @EnrollmentId;
END
GO

PRINT '[OK] Enrollments Management SPs created';
GO

PRINT '[OK] Classes Management SPs, Enrollments Management SPs completed';
GO
