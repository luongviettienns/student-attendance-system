-- ===========================================
-- 02f_SP_Subjects.sql
-- ===========================================
-- Description: Subjects Management SPs
-- Generated from: SQL/02_StoredProcedures.sql
-- ===========================================

USE EducationManagement;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

PRINT '========================================';
PRINT 'Starting: 02f_SP_Subjects.sql';
PRINT '========================================';
GO

-- ===========================================
-- 8. SUBJECTS MANAGEMENT
-- ===========================================

IF OBJECT_ID('sp_GetAllSubjects', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllSubjects;
GO
CREATE PROCEDURE sp_GetAllSubjects
AS
BEGIN
    SELECT s.*, d.department_name, f.faculty_name
    FROM dbo.subjects s
    LEFT JOIN dbo.departments d ON s.department_id = d.department_id
    LEFT JOIN dbo.faculties f ON d.faculty_id = f.faculty_id
    WHERE s.deleted_at IS NULL
    ORDER BY s.subject_name;
END
GO

IF OBJECT_ID('sp_GetSubjectById', 'P') IS NOT NULL DROP PROCEDURE sp_GetSubjectById;
GO
CREATE PROCEDURE sp_GetSubjectById
    @SubjectId VARCHAR(50)
AS
BEGIN
    SELECT s.*, d.department_name
    FROM dbo.subjects s
    LEFT JOIN dbo.departments d ON s.department_id = d.department_id
    WHERE s.subject_id = @SubjectId AND s.deleted_at IS NULL;
END
GO

IF OBJECT_ID('sp_CreateSubject', 'P') IS NOT NULL DROP PROCEDURE sp_CreateSubject;
GO
CREATE PROCEDURE sp_CreateSubject
    @SubjectId VARCHAR(50),
    @SubjectCode VARCHAR(20),
    @SubjectName NVARCHAR(200),
    @Credits INT,
    @DepartmentId VARCHAR(50) = NULL,
    @Description NVARCHAR(500) = NULL,
    @CreatedBy VARCHAR(50) = 'system'
AS
BEGIN
    INSERT INTO dbo.subjects (subject_id, subject_code, subject_name, credits,
                              department_id, description, created_at, created_by)
    VALUES (@SubjectId, @SubjectCode, @SubjectName, @Credits, @DepartmentId,
            @Description, GETDATE(), @CreatedBy);
END
GO

IF OBJECT_ID('sp_UpdateSubject', 'P') IS NOT NULL DROP PROCEDURE sp_UpdateSubject;
GO
CREATE PROCEDURE sp_UpdateSubject
    @SubjectId VARCHAR(50),
    @SubjectCode VARCHAR(20),
    @SubjectName NVARCHAR(200),
    @Credits INT,
    @DepartmentId VARCHAR(50) = NULL,
    @Description NVARCHAR(500) = NULL,
    @UpdatedBy VARCHAR(50) = 'system'
AS
BEGIN
    UPDATE dbo.subjects
    SET subject_code = @SubjectCode, subject_name = @SubjectName, credits = @Credits,
        department_id = @DepartmentId, description = @Description,
        updated_at = GETDATE(), updated_by = @UpdatedBy
    WHERE subject_id = @SubjectId AND deleted_at IS NULL;
END
GO

IF OBJECT_ID('sp_DeleteSubject', 'P') IS NOT NULL DROP PROCEDURE sp_DeleteSubject;
GO
CREATE PROCEDURE sp_DeleteSubject
    @SubjectId VARCHAR(50),
    @DeletedBy VARCHAR(50) = 'system'
AS
BEGIN
    UPDATE dbo.subjects
    SET deleted_at = GETDATE(), deleted_by = @DeletedBy
    WHERE subject_id = @SubjectId;
END
GO

PRINT '[OK] Subjects Management SPs created';
GO

-- SP: Check Subject Code Exists
IF OBJECT_ID('sp_CheckSubjectCodeExists', 'P') IS NOT NULL DROP PROCEDURE sp_CheckSubjectCodeExists;
GO
CREATE PROCEDURE sp_CheckSubjectCodeExists
    @SubjectCode VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CASE WHEN EXISTS (
        SELECT 1 FROM dbo.subjects 
        WHERE subject_code = @SubjectCode AND deleted_at IS NULL
    ) THEN 1 ELSE 0 END;
END
GO

-- SP: Get Subjects By Department
IF OBJECT_ID('sp_GetSubjectsByDepartment', 'P') IS NOT NULL DROP PROCEDURE sp_GetSubjectsByDepartment;
GO
CREATE PROCEDURE sp_GetSubjectsByDepartment
    @DepartmentId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        s.subject_id,
        s.subject_code,
        s.subject_name,
        s.credits,
        s.department_id,
        s.description,
        s.created_at,
        s.created_by,
        s.updated_at,
        s.updated_by,
        d.department_name,
        f.faculty_name
    FROM dbo.subjects s
    LEFT JOIN dbo.departments d ON s.department_id = d.department_id
    LEFT JOIN dbo.faculties f ON d.faculty_id = f.faculty_id
    WHERE s.department_id = @DepartmentId AND s.deleted_at IS NULL
    ORDER BY s.subject_code;
END
GO

-- SP: Get Subjects Available For Student (for enrollment)
IF OBJECT_ID('sp_GetSubjectsAvailableForStudent', 'P') IS NOT NULL DROP PROCEDURE sp_GetSubjectsAvailableForStudent;
GO
CREATE PROCEDURE sp_GetSubjectsAvailableForStudent
    @StudentId VARCHAR(50),
    @AcademicYearId VARCHAR(50) = NULL,
    @Semester INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    -- Get subjects that student can enroll (not already enrolled, prerequisites met)
    SELECT DISTINCT
        s.subject_id,
        s.subject_code,
        s.subject_name,
        s.credits,
        s.department_id,
        d.department_name,
        s.description,
        CASE WHEN EXISTS (
            SELECT 1 FROM dbo.enrollments e
            INNER JOIN dbo.classes c ON e.class_id = c.class_id
            WHERE e.student_id = @StudentId 
                AND c.subject_id = s.subject_id
                AND e.deleted_at IS NULL
        ) THEN 1 ELSE 0 END AS is_already_enrolled
    FROM dbo.subjects s
    LEFT JOIN dbo.departments d ON s.department_id = d.department_id
    WHERE s.deleted_at IS NULL
        AND (@AcademicYearId IS NULL OR EXISTS (
            SELECT 1 FROM dbo.classes c 
            WHERE c.subject_id = s.subject_id 
                AND c.academic_year_id = @AcademicYearId
                AND c.deleted_at IS NULL
        ))
        AND (@Semester IS NULL OR EXISTS (
            SELECT 1 FROM dbo.classes c 
            WHERE c.subject_id = s.subject_id 
                AND c.semester = @Semester
                AND c.deleted_at IS NULL
        ))
    ORDER BY s.subject_code;
END
GO

-- ===========================================
-- 8. SUBJECTS MANAGEMENT
-- ===========================================

IF OBJECT_ID('sp_GetAllSubjects', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllSubjects;
GO
CREATE PROCEDURE sp_GetAllSubjects
AS
BEGIN
    SELECT s.*, d.department_name, f.faculty_name
    FROM dbo.subjects s
    LEFT JOIN dbo.departments d ON s.department_id = d.department_id
    LEFT JOIN dbo.faculties f ON d.faculty_id = f.faculty_id
    WHERE s.deleted_at IS NULL
    ORDER BY s.subject_name;
END
GO

IF OBJECT_ID('sp_GetSubjectById', 'P') IS NOT NULL DROP PROCEDURE sp_GetSubjectById;
GO
CREATE PROCEDURE sp_GetSubjectById
    @SubjectId VARCHAR(50)
AS
BEGIN
    SELECT s.*, d.department_name
    FROM dbo.subjects s
    LEFT JOIN dbo.departments d ON s.department_id = d.department_id
    WHERE s.subject_id = @SubjectId AND s.deleted_at IS NULL;
END
GO

IF OBJECT_ID('sp_CreateSubject', 'P') IS NOT NULL DROP PROCEDURE sp_CreateSubject;
GO
CREATE PROCEDURE sp_CreateSubject
    @SubjectId VARCHAR(50),
    @SubjectCode VARCHAR(20),
    @SubjectName NVARCHAR(200),
    @Credits INT,
    @DepartmentId VARCHAR(50) = NULL,
    @Description NVARCHAR(500) = NULL,
    @CreatedBy VARCHAR(50) = 'system'
AS
BEGIN
    INSERT INTO dbo.subjects (subject_id, subject_code, subject_name, credits,
                              department_id, description, created_at, created_by)
    VALUES (@SubjectId, @SubjectCode, @SubjectName, @Credits, @DepartmentId,
            @Description, GETDATE(), @CreatedBy);
END
GO

IF OBJECT_ID('sp_UpdateSubject', 'P') IS NOT NULL DROP PROCEDURE sp_UpdateSubject;
GO
CREATE PROCEDURE sp_UpdateSubject
    @SubjectId VARCHAR(50),
    @SubjectCode VARCHAR(20),
    @SubjectName NVARCHAR(200),
    @Credits INT,
    @DepartmentId VARCHAR(50) = NULL,
    @Description NVARCHAR(500) = NULL,
    @UpdatedBy VARCHAR(50) = 'system'
AS
BEGIN
    UPDATE dbo.subjects
    SET subject_code = @SubjectCode, subject_name = @SubjectName, credits = @Credits,
        department_id = @DepartmentId, description = @Description,
        updated_at = GETDATE(), updated_by = @UpdatedBy
    WHERE subject_id = @SubjectId AND deleted_at IS NULL;
END
GO

IF OBJECT_ID('sp_DeleteSubject', 'P') IS NOT NULL DROP PROCEDURE sp_DeleteSubject;
GO
CREATE PROCEDURE sp_DeleteSubject
    @SubjectId VARCHAR(50),
    @DeletedBy VARCHAR(50) = 'system'
AS
BEGIN
    UPDATE dbo.subjects
    SET deleted_at = GETDATE(), deleted_by = @DeletedBy
    WHERE subject_id = @SubjectId;
END
GO

PRINT '[OK] Subjects Management SPs created';
GO

PRINT '[OK] Subjects Management SPs completed';
GO
