-- ===========================================
-- 02b_SP_Organization.sql
-- ===========================================
-- Description: Faculties Management SPs, Departments Management SPs, Majors Management SPs
-- Generated from: SQL/02_StoredProcedures.sql
-- ===========================================

USE EducationManagement;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

PRINT '========================================';
PRINT 'Starting: 02b_SP_Organization.sql';
PRINT '========================================';
GO

-- ===========================================
-- 2. FACULTIES MANAGEMENT
-- ===========================================

IF OBJECT_ID('sp_GetAllFaculties', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllFaculties;
GO
CREATE PROCEDURE sp_GetAllFaculties
AS
BEGIN
    SELECT faculty_id, faculty_code, faculty_name, description, 
           is_active, created_at, created_by, updated_at, updated_by
    FROM dbo.faculties
    WHERE deleted_at IS NULL
    ORDER BY faculty_name;
END
GO

IF OBJECT_ID('sp_GetFacultyById', 'P') IS NOT NULL DROP PROCEDURE sp_GetFacultyById;
GO
CREATE PROCEDURE sp_GetFacultyById
    @FacultyId VARCHAR(50)
AS
BEGIN
    SELECT * FROM dbo.faculties
    WHERE faculty_id = @FacultyId AND deleted_at IS NULL;
END
GO

IF OBJECT_ID('sp_CreateFaculty', 'P') IS NOT NULL DROP PROCEDURE sp_CreateFaculty;
GO
CREATE PROCEDURE sp_CreateFaculty
    @FacultyId VARCHAR(50),
    @FacultyCode VARCHAR(20),
    @FacultyName NVARCHAR(150),
    @Description NVARCHAR(500) = NULL,
    @IsActive BIT = 1,
    @CreatedBy VARCHAR(50) = 'system'
AS
BEGIN
    INSERT INTO dbo.faculties (faculty_id, faculty_code, faculty_name, description, is_active, created_at, created_by)
    VALUES (@FacultyId, @FacultyCode, @FacultyName, @Description, @IsActive, GETDATE(), @CreatedBy);
END
GO

IF OBJECT_ID('sp_UpdateFaculty', 'P') IS NOT NULL DROP PROCEDURE sp_UpdateFaculty;
GO
CREATE PROCEDURE sp_UpdateFaculty
    @FacultyId VARCHAR(50),
    @FacultyCode VARCHAR(20),
    @FacultyName NVARCHAR(150),
    @Description NVARCHAR(500) = NULL,
    @IsActive BIT = 1,
    @UpdatedBy VARCHAR(50) = 'system'
AS
BEGIN
    UPDATE dbo.faculties
    SET faculty_code = @FacultyCode, faculty_name = @FacultyName, description = @Description,
        is_active = @IsActive, updated_at = GETDATE(), updated_by = @UpdatedBy
    WHERE faculty_id = @FacultyId AND deleted_at IS NULL;
END
GO

IF OBJECT_ID('sp_DeleteFaculty', 'P') IS NOT NULL DROP PROCEDURE sp_DeleteFaculty;
GO
CREATE PROCEDURE sp_DeleteFaculty
    @FacultyId VARCHAR(50),
    @DeletedBy VARCHAR(50) = 'system'
AS
BEGIN
    UPDATE dbo.faculties
    SET deleted_at = GETDATE(), deleted_by = @DeletedBy
    WHERE faculty_id = @FacultyId;
END
GO

PRINT '[OK] Faculties Management SPs created';
GO

-- ===========================================
-- 3. DEPARTMENTS MANAGEMENT
-- ===========================================

IF OBJECT_ID('sp_GetAllDepartments', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllDepartments;
GO
CREATE PROCEDURE sp_GetAllDepartments
AS
BEGIN
    SELECT d.*, f.faculty_name, f.faculty_code
    FROM dbo.departments d
    LEFT JOIN dbo.faculties f ON d.faculty_id = f.faculty_id
    WHERE d.deleted_at IS NULL
    ORDER BY d.department_name;
END
GO

IF OBJECT_ID('sp_GetDepartmentById', 'P') IS NOT NULL DROP PROCEDURE sp_GetDepartmentById;
GO
CREATE PROCEDURE sp_GetDepartmentById
    @DepartmentId VARCHAR(50)
AS
BEGIN
    SELECT d.*, f.faculty_name
    FROM dbo.departments d
    LEFT JOIN dbo.faculties f ON d.faculty_id = f.faculty_id
    WHERE d.department_id = @DepartmentId AND d.deleted_at IS NULL;
END
GO

IF OBJECT_ID('sp_CreateDepartment', 'P') IS NOT NULL DROP PROCEDURE sp_CreateDepartment;
GO
CREATE PROCEDURE sp_CreateDepartment
    @DepartmentId VARCHAR(50),
    @DepartmentCode VARCHAR(20),
    @DepartmentName NVARCHAR(150),
    @FacultyId VARCHAR(50),
    @Description NVARCHAR(500) = NULL,
    @CreatedBy VARCHAR(50) = 'system'
AS
BEGIN
    INSERT INTO dbo.departments (department_id, department_code, department_name, faculty_id, description,
                                  created_at, created_by)
    VALUES (@DepartmentId, @DepartmentCode, @DepartmentName, @FacultyId, @Description, GETDATE(), @CreatedBy);
END
GO

IF OBJECT_ID('sp_UpdateDepartment', 'P') IS NOT NULL DROP PROCEDURE sp_UpdateDepartment;
GO
CREATE PROCEDURE sp_UpdateDepartment
    @DepartmentId VARCHAR(50),
    @DepartmentCode VARCHAR(20),
    @DepartmentName NVARCHAR(150),
    @FacultyId VARCHAR(50),
    @Description NVARCHAR(500) = NULL,
    @UpdatedBy VARCHAR(50) = 'system'
AS
BEGIN
    UPDATE dbo.departments
    SET department_code = @DepartmentCode,
        department_name = @DepartmentName,
        faculty_id = @FacultyId,
        description = @Description,
        updated_at = GETDATE(),
        updated_by = @UpdatedBy
    WHERE department_id = @DepartmentId AND deleted_at IS NULL;
END
GO

IF OBJECT_ID('sp_DeleteDepartment', 'P') IS NOT NULL DROP PROCEDURE sp_DeleteDepartment;
GO
CREATE PROCEDURE sp_DeleteDepartment
    @DepartmentId VARCHAR(50),
    @DeletedBy VARCHAR(50) = 'system'
AS
BEGIN
    UPDATE dbo.departments
    SET deleted_at = GETDATE(), deleted_by = @DeletedBy
    WHERE department_id = @DepartmentId;
END
GO

PRINT '[OK] Departments Management SPs created';
GO

-- ===========================================
-- 4. MAJORS MANAGEMENT
-- ===========================================

IF OBJECT_ID('sp_GetAllMajors', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllMajors;
GO
CREATE PROCEDURE sp_GetAllMajors
AS
BEGIN
    SELECT m.*, f.faculty_name, f.faculty_code
    FROM dbo.majors m
    LEFT JOIN dbo.faculties f ON m.faculty_id = f.faculty_id
    WHERE m.deleted_at IS NULL
    ORDER BY m.major_name;
END
GO

IF OBJECT_ID('sp_GetMajorById', 'P') IS NOT NULL DROP PROCEDURE sp_GetMajorById;
GO
CREATE PROCEDURE sp_GetMajorById
    @MajorId VARCHAR(50)
AS
BEGIN
    SELECT m.*, f.faculty_name
    FROM dbo.majors m
    LEFT JOIN dbo.faculties f ON m.faculty_id = f.faculty_id
    WHERE m.major_id = @MajorId AND m.deleted_at IS NULL;
END
GO

IF OBJECT_ID('sp_GetMajorsByFaculty', 'P') IS NOT NULL DROP PROCEDURE sp_GetMajorsByFaculty;
GO
CREATE PROCEDURE sp_GetMajorsByFaculty
    @FacultyId VARCHAR(50)
AS
BEGIN
    SELECT * FROM dbo.majors
    WHERE faculty_id = @FacultyId AND deleted_at IS NULL
    ORDER BY major_name;
END
GO

IF OBJECT_ID('sp_CreateMajor', 'P') IS NOT NULL DROP PROCEDURE sp_CreateMajor;
GO
CREATE PROCEDURE sp_CreateMajor
    @MajorId VARCHAR(50),
    @MajorName NVARCHAR(150),
    @MajorCode VARCHAR(20),
    @FacultyId VARCHAR(50),
    @Description NVARCHAR(500) = NULL,
    @CreatedBy VARCHAR(50) = 'system'
AS
BEGIN
    INSERT INTO dbo.majors (major_id, major_name, major_code, faculty_id, description,
                            created_at, created_by)
    VALUES (@MajorId, @MajorName, @MajorCode, @FacultyId, @Description, GETDATE(), @CreatedBy);
END
GO

IF OBJECT_ID('sp_UpdateMajor', 'P') IS NOT NULL DROP PROCEDURE sp_UpdateMajor;
GO
CREATE PROCEDURE sp_UpdateMajor
    @MajorId VARCHAR(50),
    @MajorName NVARCHAR(150),
    @MajorCode VARCHAR(20),
    @FacultyId VARCHAR(50),
    @Description NVARCHAR(500) = NULL,
    @UpdatedBy VARCHAR(50) = 'system'
AS
BEGIN
    UPDATE dbo.majors
    SET major_name = @MajorName, major_code = @MajorCode, faculty_id = @FacultyId,
        description = @Description, updated_at = GETDATE(), updated_by = @UpdatedBy
    WHERE major_id = @MajorId AND deleted_at IS NULL;
END
GO

IF OBJECT_ID('sp_DeleteMajor', 'P') IS NOT NULL DROP PROCEDURE sp_DeleteMajor;
GO
CREATE PROCEDURE sp_DeleteMajor
    @MajorId VARCHAR(50),
    @DeletedBy VARCHAR(50) = 'system'
AS
BEGIN
    UPDATE dbo.majors
    SET deleted_at = GETDATE(), deleted_by = @DeletedBy
    WHERE major_id = @MajorId;
END
GO

PRINT '[OK] Majors Management SPs created';
GO

-- ===========================================
-- 2. FACULTIES MANAGEMENT
-- ===========================================

IF OBJECT_ID('sp_GetAllFaculties', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllFaculties;
GO
CREATE PROCEDURE sp_GetAllFaculties
AS
BEGIN
    SELECT faculty_id, faculty_code, faculty_name, description, 
           is_active, created_at, created_by, updated_at, updated_by
    FROM dbo.faculties
    WHERE deleted_at IS NULL
    ORDER BY faculty_name;
END
GO

IF OBJECT_ID('sp_GetFacultyById', 'P') IS NOT NULL DROP PROCEDURE sp_GetFacultyById;
GO
CREATE PROCEDURE sp_GetFacultyById
    @FacultyId VARCHAR(50)
AS
BEGIN
    SELECT * FROM dbo.faculties
    WHERE faculty_id = @FacultyId AND deleted_at IS NULL;
END
GO

IF OBJECT_ID('sp_CreateFaculty', 'P') IS NOT NULL DROP PROCEDURE sp_CreateFaculty;
GO
CREATE PROCEDURE sp_CreateFaculty
    @FacultyId VARCHAR(50),
    @FacultyCode VARCHAR(20),
    @FacultyName NVARCHAR(150),
    @Description NVARCHAR(500) = NULL,
    @IsActive BIT = 1,
    @CreatedBy VARCHAR(50) = 'system'
AS
BEGIN
    INSERT INTO dbo.faculties (faculty_id, faculty_code, faculty_name, description, is_active, created_at, created_by)
    VALUES (@FacultyId, @FacultyCode, @FacultyName, @Description, @IsActive, GETDATE(), @CreatedBy);
END
GO

IF OBJECT_ID('sp_UpdateFaculty', 'P') IS NOT NULL DROP PROCEDURE sp_UpdateFaculty;
GO
CREATE PROCEDURE sp_UpdateFaculty
    @FacultyId VARCHAR(50),
    @FacultyCode VARCHAR(20),
    @FacultyName NVARCHAR(150),
    @Description NVARCHAR(500) = NULL,
    @IsActive BIT = 1,
    @UpdatedBy VARCHAR(50) = 'system'
AS
BEGIN
    UPDATE dbo.faculties
    SET faculty_code = @FacultyCode, faculty_name = @FacultyName, description = @Description,
        is_active = @IsActive, updated_at = GETDATE(), updated_by = @UpdatedBy
    WHERE faculty_id = @FacultyId AND deleted_at IS NULL;
END
GO

IF OBJECT_ID('sp_DeleteFaculty', 'P') IS NOT NULL DROP PROCEDURE sp_DeleteFaculty;
GO
CREATE PROCEDURE sp_DeleteFaculty
    @FacultyId VARCHAR(50),
    @DeletedBy VARCHAR(50) = 'system'
AS
BEGIN
    UPDATE dbo.faculties
    SET deleted_at = GETDATE(), deleted_by = @DeletedBy
    WHERE faculty_id = @FacultyId;
END
GO

PRINT '[OK] Faculties Management SPs created';
GO

-- ===========================================
-- 3. DEPARTMENTS MANAGEMENT
-- ===========================================

IF OBJECT_ID('sp_GetAllDepartments', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllDepartments;
GO
CREATE PROCEDURE sp_GetAllDepartments
AS
BEGIN
    SELECT d.*, f.faculty_name, f.faculty_code
    FROM dbo.departments d
    LEFT JOIN dbo.faculties f ON d.faculty_id = f.faculty_id
    WHERE d.deleted_at IS NULL
    ORDER BY d.department_name;
END
GO

IF OBJECT_ID('sp_GetDepartmentById', 'P') IS NOT NULL DROP PROCEDURE sp_GetDepartmentById;
GO
CREATE PROCEDURE sp_GetDepartmentById
    @DepartmentId VARCHAR(50)
AS
BEGIN
    SELECT d.*, f.faculty_name
    FROM dbo.departments d
    LEFT JOIN dbo.faculties f ON d.faculty_id = f.faculty_id
    WHERE d.department_id = @DepartmentId AND d.deleted_at IS NULL;
END
GO

IF OBJECT_ID('sp_CreateDepartment', 'P') IS NOT NULL DROP PROCEDURE sp_CreateDepartment;
GO
CREATE PROCEDURE sp_CreateDepartment
    @DepartmentId VARCHAR(50),
    @DepartmentCode VARCHAR(20),
    @DepartmentName NVARCHAR(150),
    @FacultyId VARCHAR(50),
    @Description NVARCHAR(500) = NULL,
    @CreatedBy VARCHAR(50) = 'system'
AS
BEGIN
    INSERT INTO dbo.departments (department_id, department_code, department_name, faculty_id, description,
                                  created_at, created_by)
    VALUES (@DepartmentId, @DepartmentCode, @DepartmentName, @FacultyId, @Description, GETDATE(), @CreatedBy);
END
GO

IF OBJECT_ID('sp_UpdateDepartment', 'P') IS NOT NULL DROP PROCEDURE sp_UpdateDepartment;
GO
CREATE PROCEDURE sp_UpdateDepartment
    @DepartmentId VARCHAR(50),
    @DepartmentCode VARCHAR(20),
    @DepartmentName NVARCHAR(150),
    @FacultyId VARCHAR(50),
    @Description NVARCHAR(500) = NULL,
    @UpdatedBy VARCHAR(50) = 'system'
AS
BEGIN
    UPDATE dbo.departments
    SET department_code = @DepartmentCode,
        department_name = @DepartmentName,
        faculty_id = @FacultyId,
        description = @Description,
        updated_at = GETDATE(),
        updated_by = @UpdatedBy
    WHERE department_id = @DepartmentId AND deleted_at IS NULL;
END
GO

IF OBJECT_ID('sp_DeleteDepartment', 'P') IS NOT NULL DROP PROCEDURE sp_DeleteDepartment;
GO
CREATE PROCEDURE sp_DeleteDepartment
    @DepartmentId VARCHAR(50),
    @DeletedBy VARCHAR(50) = 'system'
AS
BEGIN
    UPDATE dbo.departments
    SET deleted_at = GETDATE(), deleted_by = @DeletedBy
    WHERE department_id = @DepartmentId;
END
GO

PRINT '[OK] Departments Management SPs created';
GO

-- ===========================================
-- 4. MAJORS MANAGEMENT
-- ===========================================

IF OBJECT_ID('sp_GetAllMajors', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllMajors;
GO
CREATE PROCEDURE sp_GetAllMajors
AS
BEGIN
    SELECT m.*, f.faculty_name, f.faculty_code
    FROM dbo.majors m
    LEFT JOIN dbo.faculties f ON m.faculty_id = f.faculty_id
    WHERE m.deleted_at IS NULL
    ORDER BY m.major_name;
END
GO

IF OBJECT_ID('sp_GetMajorById', 'P') IS NOT NULL DROP PROCEDURE sp_GetMajorById;
GO
CREATE PROCEDURE sp_GetMajorById
    @MajorId VARCHAR(50)
AS
BEGIN
    SELECT m.*, f.faculty_name
    FROM dbo.majors m
    LEFT JOIN dbo.faculties f ON m.faculty_id = f.faculty_id
    WHERE m.major_id = @MajorId AND m.deleted_at IS NULL;
END
GO

IF OBJECT_ID('sp_GetMajorsByFaculty', 'P') IS NOT NULL DROP PROCEDURE sp_GetMajorsByFaculty;
GO
CREATE PROCEDURE sp_GetMajorsByFaculty
    @FacultyId VARCHAR(50)
AS
BEGIN
    SELECT * FROM dbo.majors
    WHERE faculty_id = @FacultyId AND deleted_at IS NULL
    ORDER BY major_name;
END
GO

IF OBJECT_ID('sp_CreateMajor', 'P') IS NOT NULL DROP PROCEDURE sp_CreateMajor;
GO
CREATE PROCEDURE sp_CreateMajor
    @MajorId VARCHAR(50),
    @MajorName NVARCHAR(150),
    @MajorCode VARCHAR(20),
    @FacultyId VARCHAR(50),
    @Description NVARCHAR(500) = NULL,
    @CreatedBy VARCHAR(50) = 'system'
AS
BEGIN
    INSERT INTO dbo.majors (major_id, major_name, major_code, faculty_id, description,
                            created_at, created_by)
    VALUES (@MajorId, @MajorName, @MajorCode, @FacultyId, @Description, GETDATE(), @CreatedBy);
END
GO

IF OBJECT_ID('sp_UpdateMajor', 'P') IS NOT NULL DROP PROCEDURE sp_UpdateMajor;
GO
CREATE PROCEDURE sp_UpdateMajor
    @MajorId VARCHAR(50),
    @MajorName NVARCHAR(150),
    @MajorCode VARCHAR(20),
    @FacultyId VARCHAR(50),
    @Description NVARCHAR(500) = NULL,
    @UpdatedBy VARCHAR(50) = 'system'
AS
BEGIN
    UPDATE dbo.majors
    SET major_name = @MajorName, major_code = @MajorCode, faculty_id = @FacultyId,
        description = @Description, updated_at = GETDATE(), updated_by = @UpdatedBy
    WHERE major_id = @MajorId AND deleted_at IS NULL;
END
GO

IF OBJECT_ID('sp_DeleteMajor', 'P') IS NOT NULL DROP PROCEDURE sp_DeleteMajor;
GO
CREATE PROCEDURE sp_DeleteMajor
    @MajorId VARCHAR(50),
    @DeletedBy VARCHAR(50) = 'system'
AS
BEGIN
    UPDATE dbo.majors
    SET deleted_at = GETDATE(), deleted_by = @DeletedBy
    WHERE major_id = @MajorId;
END
GO

PRINT '[OK] Majors Management SPs created';
GO

PRINT '[OK] Faculties Management SPs, Departments Management SPs, Majors Management SPs completed';
GO
