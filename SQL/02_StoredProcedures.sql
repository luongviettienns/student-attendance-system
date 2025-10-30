-- ===========================================
-- 🎓 HỆ THỐNG QUẢN LÝ ĐIỂM DANH SINH VIÊN
-- 📋 File 2/4: STORED PROCEDURES (ĐẦY ĐỦ)
-- ===========================================

USE EducationManagement;
GO

PRINT '🔄 Bắt đầu tạo Stored Procedures...';
GO

-- ===========================================
-- 1. USERS MANAGEMENT
-- ===========================================

IF OBJECT_ID('sp_GetAllUsers', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllUsers;
GO
CREATE PROCEDURE sp_GetAllUsers
    @Page INT = 1,
    @PageSize INT = 10,
    @Search NVARCHAR(255) = NULL,
    @RoleId VARCHAR(50) = NULL,
    @IsActive BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Offset INT = (@Page - 1) * @PageSize;
    
    SELECT COUNT(*) as TotalCount
    FROM dbo.users u
    LEFT JOIN dbo.roles r ON u.role_id = r.role_id AND r.deleted_at IS NULL
    WHERE u.deleted_at IS NULL
        AND (@Search IS NULL OR u.username LIKE '%' + @Search + '%' 
             OR u.full_name LIKE '%' + @Search + '%' OR u.email LIKE '%' + @Search + '%')
        AND (@RoleId IS NULL OR u.role_id = @RoleId)
        AND (@IsActive IS NULL OR u.is_active = @IsActive);
    
    SELECT u.user_id, u.username, u.full_name, u.email, u.phone, u.role_id,
           ISNULL(r.role_name, 'No Role') as role_name, u.avatar_url, u.is_active,
           u.last_login_at, u.created_at, u.created_by, u.updated_at, u.updated_by
    FROM dbo.users u
    LEFT JOIN dbo.roles r ON u.role_id = r.role_id AND r.deleted_at IS NULL
    WHERE u.deleted_at IS NULL
        AND (@Search IS NULL OR u.username LIKE '%' + @Search + '%' 
             OR u.full_name LIKE '%' + @Search + '%' OR u.email LIKE '%' + @Search + '%')
        AND (@RoleId IS NULL OR u.role_id = @RoleId)
        AND (@IsActive IS NULL OR u.is_active = @IsActive)
    ORDER BY u.created_at DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END
GO

IF OBJECT_ID('sp_GetUserById', 'P') IS NOT NULL DROP PROCEDURE sp_GetUserById;
GO
CREATE PROCEDURE sp_GetUserById
    @UserId VARCHAR(50)
AS
BEGIN
    SELECT u.user_id, u.username, u.full_name, u.email, u.phone, u.role_id,
           r.role_name, u.avatar_url, u.is_active, u.last_login_at,
           u.created_at, u.created_by, u.updated_at, u.updated_by
    FROM dbo.users u
    LEFT JOIN dbo.roles r ON u.role_id = r.role_id
    WHERE u.user_id = @UserId AND u.deleted_at IS NULL;
END
GO

IF OBJECT_ID('sp_GetUserByUsername', 'P') IS NOT NULL DROP PROCEDURE sp_GetUserByUsername;
GO
CREATE PROCEDURE sp_GetUserByUsername
    @Username VARCHAR(50)
AS
BEGIN
    SELECT u.user_id, u.username, u.password_hash, u.full_name, u.email, 
           u.phone, u.role_id, r.role_name, u.avatar_url, u.is_active, u.last_login_at
    FROM dbo.users u
    LEFT JOIN dbo.roles r ON u.role_id = r.role_id
    WHERE u.username = @Username AND u.deleted_at IS NULL;
END
GO

IF OBJECT_ID('sp_CreateUser', 'P') IS NOT NULL DROP PROCEDURE sp_CreateUser;
GO
CREATE PROCEDURE sp_CreateUser
    @UserId VARCHAR(50),
    @Username VARCHAR(50),
    @PasswordHash VARCHAR(255),
    @Email VARCHAR(150),
    @Phone VARCHAR(20) = NULL,
    @FullName NVARCHAR(150),
    @RoleId VARCHAR(50),
    @IsActive BIT = 1,
    @AvatarUrl VARCHAR(300) = NULL,
    @CreatedBy VARCHAR(50) = 'system'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validation: Check duplicate username
        IF EXISTS (SELECT 1 FROM users WHERE username = @Username AND deleted_at IS NULL)
        BEGIN
            RAISERROR(N'Username đã tồn tại: %s', 16, 1, @Username);
            RETURN;
        END
        
        -- Validation: Check duplicate email
        IF EXISTS (SELECT 1 FROM users WHERE email = @Email AND deleted_at IS NULL)
        BEGIN
            RAISERROR(N'Email đã tồn tại: %s', 16, 1, @Email);
            RETURN;
        END
        
        -- Validation: Check role exists
        IF NOT EXISTS (SELECT 1 FROM roles WHERE role_id = @RoleId AND deleted_at IS NULL)
        BEGIN
            RAISERROR(N'Role không tồn tại: %s', 16, 1, @RoleId);
            RETURN;
        END
        
        -- Insert
        INSERT INTO dbo.users (user_id, username, password_hash, email, phone, full_name, 
                               role_id, is_active, avatar_url, created_at, created_by)
        VALUES (@UserId, @Username, @PasswordHash, @Email, @Phone, @FullName, 
                @RoleId, @IsActive, @AvatarUrl, GETDATE(), @CreatedBy);
        
        COMMIT TRANSACTION;
        SELECT @UserId AS user_id;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

IF OBJECT_ID('sp_UpdateUser', 'P') IS NOT NULL DROP PROCEDURE sp_UpdateUser;
GO
CREATE PROCEDURE sp_UpdateUser
    @UserId VARCHAR(50),
    @FullName NVARCHAR(150),
    @Email VARCHAR(150),
    @Phone VARCHAR(20) = NULL,
    @RoleId VARCHAR(50),
    @IsActive BIT,
    @AvatarUrl VARCHAR(300) = NULL,
    @UpdatedBy VARCHAR(50) = 'system'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validation: Check user exists
        IF NOT EXISTS (SELECT 1 FROM users WHERE user_id = @UserId AND deleted_at IS NULL)
        BEGIN
            RAISERROR(N'User không tồn tại: %s', 16, 1, @UserId);
            RETURN;
        END
        
        -- Validation: Check duplicate email (except current user)
        IF EXISTS (SELECT 1 FROM users WHERE email = @Email AND user_id != @UserId AND deleted_at IS NULL)
        BEGIN
            RAISERROR(N'Email đã được sử dụng bởi user khác: %s', 16, 1, @Email);
            RETURN;
        END
        
        -- Validation: Check role exists
        IF NOT EXISTS (SELECT 1 FROM roles WHERE role_id = @RoleId AND deleted_at IS NULL)
        BEGIN
            RAISERROR(N'Role không tồn tại: %s', 16, 1, @RoleId);
            RETURN;
        END
        
        -- Update
        UPDATE dbo.users
        SET full_name = @FullName, email = @Email, phone = @Phone, role_id = @RoleId,
            is_active = @IsActive, avatar_url = ISNULL(@AvatarUrl, avatar_url),
            updated_at = GETDATE(), updated_by = @UpdatedBy
        WHERE user_id = @UserId AND deleted_at IS NULL;
        
        COMMIT TRANSACTION;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

IF OBJECT_ID('sp_DeleteUser', 'P') IS NOT NULL DROP PROCEDURE sp_DeleteUser;
GO
CREATE PROCEDURE sp_DeleteUser
    @UserId VARCHAR(50),
    @DeletedBy VARCHAR(50) = 'system'
AS
BEGIN
    UPDATE dbo.users
    SET deleted_at = GETDATE(), deleted_by = @DeletedBy
    WHERE user_id = @UserId;
END
GO

IF OBJECT_ID('sp_UpdateLastLogin', 'P') IS NOT NULL DROP PROCEDURE sp_UpdateLastLogin;
GO
CREATE PROCEDURE sp_UpdateLastLogin
    @UserId VARCHAR(50)
AS
BEGIN
    UPDATE dbo.users
    SET last_login_at = GETDATE()
    WHERE user_id = @UserId;
END
GO

PRINT '✅ Users Management SPs created';
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

PRINT '✅ Faculties Management SPs created';
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

PRINT '✅ Departments Management SPs created';
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

PRINT '✅ Majors Management SPs created';
GO

-- ===========================================
-- 5. ACADEMIC YEARS MANAGEMENT
-- ===========================================

IF OBJECT_ID('sp_GetAllAcademicYears', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllAcademicYears;
GO
CREATE PROCEDURE sp_GetAllAcademicYears
AS
BEGIN
    SELECT * FROM dbo.academic_years
    WHERE deleted_at IS NULL
    ORDER BY start_year DESC;
END
GO

IF OBJECT_ID('sp_GetAcademicYearById', 'P') IS NOT NULL DROP PROCEDURE sp_GetAcademicYearById;
GO
CREATE PROCEDURE sp_GetAcademicYearById
    @AcademicYearId VARCHAR(50)
AS
BEGIN
    SELECT * FROM dbo.academic_years
    WHERE academic_year_id = @AcademicYearId AND deleted_at IS NULL;
END
GO

IF OBJECT_ID('sp_CreateAcademicYear', 'P') IS NOT NULL DROP PROCEDURE sp_CreateAcademicYear;
GO
CREATE PROCEDURE sp_CreateAcademicYear
    @AcademicYearId VARCHAR(50),
    @YearName NVARCHAR(50),
    @StartYear INT,
    @EndYear INT,
    @IsActive BIT = 0,
    @CreatedBy VARCHAR(50) = 'system'
AS
BEGIN
    INSERT INTO dbo.academic_years (academic_year_id, year_name, start_year, end_year,
                                     is_active, created_at, created_by)
    VALUES (@AcademicYearId, @YearName, @StartYear, @EndYear, @IsActive, GETDATE(), @CreatedBy);
END
GO

IF OBJECT_ID('sp_UpdateAcademicYear', 'P') IS NOT NULL DROP PROCEDURE sp_UpdateAcademicYear;
GO
CREATE PROCEDURE sp_UpdateAcademicYear
    @AcademicYearId VARCHAR(50),
    @YearName NVARCHAR(50),
    @StartYear INT,
    @EndYear INT,
    @IsActive BIT,
    @UpdatedBy VARCHAR(50) = 'system'
AS
BEGIN
    UPDATE dbo.academic_years
    SET year_name = @YearName, start_year = @StartYear, end_year = @EndYear,
        is_active = @IsActive, updated_at = GETDATE(), updated_by = @UpdatedBy
    WHERE academic_year_id = @AcademicYearId AND deleted_at IS NULL;
END
GO

IF OBJECT_ID('sp_DeleteAcademicYear', 'P') IS NOT NULL DROP PROCEDURE sp_DeleteAcademicYear;
GO
CREATE PROCEDURE sp_DeleteAcademicYear
    @AcademicYearId VARCHAR(50),
    @DeletedBy VARCHAR(50) = 'system'
AS
BEGIN
    UPDATE dbo.academic_years
    SET deleted_at = GETDATE(), deleted_by = @DeletedBy
    WHERE academic_year_id = @AcademicYearId;
END
GO

PRINT '✅ Academic Years Management SPs created';
GO

-- ===========================================
-- 6. STUDENTS MANAGEMENT
-- ===========================================

IF OBJECT_ID('sp_GetAllStudents', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllStudents;
GO
CREATE PROCEDURE sp_GetAllStudents
    @Page INT = 1,
    @PageSize INT = 10,
    @Search NVARCHAR(255) = NULL,
    @FacultyId VARCHAR(50) = NULL,
    @MajorId VARCHAR(50) = NULL,
    @AcademicYearId VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Offset INT = (@Page - 1) * @PageSize;
    
    SELECT COUNT(*) as TotalCount
    FROM dbo.students s
    LEFT JOIN dbo.majors m ON s.major_id = m.major_id
    WHERE s.deleted_at IS NULL
        AND (@Search IS NULL OR s.student_code LIKE '%' + @Search + '%' 
             OR s.full_name LIKE '%' + @Search + '%')
        AND (@FacultyId IS NULL OR m.faculty_id = @FacultyId)
        AND (@MajorId IS NULL OR s.major_id = @MajorId)
        AND (@AcademicYearId IS NULL OR s.academic_year_id = @AcademicYearId);
    
    SELECT s.student_id, s.user_id, s.student_code, s.full_name, s.gender, s.date_of_birth,
           s.email, s.phone, s.address, s.major_id, m.major_name, m.faculty_id, f.faculty_name,
           s.academic_year_id, ay.year_name, s.is_active,
           s.created_at, s.created_by, s.updated_at, s.updated_by
    FROM dbo.students s
    LEFT JOIN dbo.majors m ON s.major_id = m.major_id
    LEFT JOIN dbo.faculties f ON m.faculty_id = f.faculty_id
    LEFT JOIN dbo.academic_years ay ON s.academic_year_id = ay.academic_year_id
    WHERE s.deleted_at IS NULL
        AND (@Search IS NULL OR s.student_code LIKE '%' + @Search + '%' 
             OR s.full_name LIKE '%' + @Search + '%')
        AND (@FacultyId IS NULL OR m.faculty_id = @FacultyId)
        AND (@MajorId IS NULL OR s.major_id = @MajorId)
        AND (@AcademicYearId IS NULL OR s.academic_year_id = @AcademicYearId)
    ORDER BY s.created_at DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END
GO

IF OBJECT_ID('sp_GetStudentById', 'P') IS NOT NULL DROP PROCEDURE sp_GetStudentById;
GO
CREATE PROCEDURE sp_GetStudentById
    @StudentId VARCHAR(50)
AS
BEGIN
    SELECT s.*, m.major_name, m.faculty_id, f.faculty_name, ay.year_name
    FROM dbo.students s
    LEFT JOIN dbo.majors m ON s.major_id = m.major_id
    LEFT JOIN dbo.faculties f ON m.faculty_id = f.faculty_id
    LEFT JOIN dbo.academic_years ay ON s.academic_year_id = ay.academic_year_id
    WHERE s.student_id = @StudentId AND s.deleted_at IS NULL;
END
GO

IF OBJECT_ID('sp_CreateStudent', 'P') IS NOT NULL DROP PROCEDURE sp_CreateStudent;
GO
CREATE PROCEDURE sp_CreateStudent
    @StudentId VARCHAR(50),
    @UserId VARCHAR(50),
    @StudentCode VARCHAR(20),
    @FullName NVARCHAR(150),
    @Gender NVARCHAR(10) = NULL,
    @Dob DATE = NULL,
    @Email VARCHAR(150) = NULL,
    @Phone VARCHAR(20) = NULL,
    @Address NVARCHAR(300) = NULL,
    @MajorId VARCHAR(50) = NULL,
    @AcademicYearId VARCHAR(50) = NULL,
    @CreatedBy VARCHAR(50) = 'system'
AS
BEGIN
    INSERT INTO dbo.students (student_id, user_id, student_code, full_name, gender, date_of_birth,
                              email, phone, address, major_id, academic_year_id,
                              created_at, created_by)
    VALUES (@StudentId, @UserId, @StudentCode, @FullName, @Gender, @Dob, @Email, @Phone,
            @Address, @MajorId, @AcademicYearId, GETDATE(), @CreatedBy);
    SELECT @StudentId AS student_id;
END
GO

IF OBJECT_ID('sp_UpdateStudent', 'P') IS NOT NULL DROP PROCEDURE sp_UpdateStudent;
GO
CREATE PROCEDURE sp_UpdateStudent
    @StudentId VARCHAR(50),
    @FullName NVARCHAR(150),
    @Gender NVARCHAR(10) = NULL,
    @Dob DATE = NULL,
    @Email VARCHAR(150) = NULL,
    @Phone VARCHAR(20) = NULL,
    @Address NVARCHAR(300) = NULL,
    @MajorId VARCHAR(50) = NULL,
    @AcademicYearId VARCHAR(50) = NULL,
    @UpdatedBy VARCHAR(50) = 'system'
AS
BEGIN
    UPDATE dbo.students
    SET full_name = @FullName, gender = @Gender, date_of_birth = @Dob,
        email = @Email, phone = @Phone, address = @Address,
        major_id = @MajorId, academic_year_id = @AcademicYearId,
        updated_at = GETDATE(), updated_by = @UpdatedBy
    WHERE student_id = @StudentId AND deleted_at IS NULL;
END
GO

IF OBJECT_ID('sp_DeleteStudent', 'P') IS NOT NULL DROP PROCEDURE sp_DeleteStudent;
GO
CREATE PROCEDURE sp_DeleteStudent
    @StudentId VARCHAR(50),
    @DeletedBy VARCHAR(50) = 'system'
AS
BEGIN
    UPDATE dbo.students
    SET deleted_at = GETDATE(), deleted_by = @DeletedBy
    WHERE student_id = @StudentId;
END
GO

PRINT '✅ Students Management SPs created';
GO

-- ===========================================
-- 7. LECTURERS MANAGEMENT
-- ===========================================

IF OBJECT_ID('sp_GetAllLecturers', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllLecturers;
GO
CREATE PROCEDURE sp_GetAllLecturers
AS
BEGIN
    SELECT l.*, d.department_name, f.faculty_name
    FROM dbo.lecturers l
    LEFT JOIN dbo.departments d ON l.department_id = d.department_id
    LEFT JOIN dbo.faculties f ON d.faculty_id = f.faculty_id
    WHERE l.deleted_at IS NULL
    ORDER BY l.created_at DESC;
END
GO

IF OBJECT_ID('sp_GetLecturerById', 'P') IS NOT NULL DROP PROCEDURE sp_GetLecturerById;
GO
CREATE PROCEDURE sp_GetLecturerById
    @LecturerId VARCHAR(50)
AS
BEGIN
    SELECT l.*, d.department_name
    FROM dbo.lecturers l
    LEFT JOIN dbo.departments d ON l.department_id = d.department_id
    WHERE l.lecturer_id = @LecturerId AND l.deleted_at IS NULL;
END
GO

IF OBJECT_ID('sp_CreateLecturer', 'P') IS NOT NULL DROP PROCEDURE sp_CreateLecturer;
GO
CREATE PROCEDURE sp_CreateLecturer
    @LecturerId VARCHAR(50),
    @LecturerCode VARCHAR(20),
    @FullName NVARCHAR(150),
    @Email VARCHAR(150) = NULL,
    @Phone VARCHAR(20) = NULL,
    @DepartmentId VARCHAR(50) = NULL,
    @UserId VARCHAR(50) = NULL,
    @CreatedBy VARCHAR(50) = 'system'
AS
BEGIN
    INSERT INTO dbo.lecturers (lecturer_id, lecturer_code, full_name, email, phone,
                               department_id, user_id, created_at, created_by)
    VALUES (@LecturerId, @LecturerCode, @FullName, @Email, @Phone, @DepartmentId,
            @UserId, GETDATE(), @CreatedBy);
END
GO

IF OBJECT_ID('sp_UpdateLecturer', 'P') IS NOT NULL DROP PROCEDURE sp_UpdateLecturer;
GO
CREATE PROCEDURE sp_UpdateLecturer
    @LecturerId VARCHAR(50),
    @LecturerCode VARCHAR(20),
    @FullName NVARCHAR(150),
    @Email VARCHAR(150) = NULL,
    @Phone VARCHAR(20) = NULL,
    @DepartmentId VARCHAR(50) = NULL,
    @UpdatedBy VARCHAR(50) = 'system'
AS
BEGIN
    UPDATE dbo.lecturers
    SET lecturer_code = @LecturerCode, full_name = @FullName, email = @Email,
        phone = @Phone, department_id = @DepartmentId,
        updated_at = GETDATE(), updated_by = @UpdatedBy
    WHERE lecturer_id = @LecturerId AND deleted_at IS NULL;
END
GO

IF OBJECT_ID('sp_DeleteLecturer', 'P') IS NOT NULL DROP PROCEDURE sp_DeleteLecturer;
GO
CREATE PROCEDURE sp_DeleteLecturer
    @LecturerId VARCHAR(50),
    @DeletedBy VARCHAR(50) = 'system'
AS
BEGIN
    UPDATE dbo.lecturers
    SET deleted_at = GETDATE(), deleted_by = @DeletedBy
    WHERE lecturer_id = @LecturerId;
END
GO

PRINT '✅ Lecturers Management SPs created';
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

PRINT '✅ Subjects Management SPs created';
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

PRINT '✅ Classes Management SPs created';
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
    @Status NVARCHAR(50) = N'Đang học',
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

PRINT '✅ Enrollments Management SPs created';
GO

-- ===========================================
-- 11. ATTENDANCES MANAGEMENT
-- ===========================================

IF OBJECT_ID('sp_GetAttendancesByClass', 'P') IS NOT NULL DROP PROCEDURE sp_GetAttendancesByClass;
GO
CREATE PROCEDURE sp_GetAttendancesByClass
    @ClassId VARCHAR(50),
    @AttendanceDate DATE = NULL
AS
BEGIN
    SELECT a.*, e.enrollment_id, s.student_code, s.full_name as student_name
    FROM dbo.attendances a
    INNER JOIN dbo.enrollments e ON a.enrollment_id = e.enrollment_id
    INNER JOIN dbo.students s ON e.student_id = s.student_id
    WHERE a.class_id = @ClassId
        AND (@AttendanceDate IS NULL OR CAST(a.attendance_date AS DATE) = @AttendanceDate)
    ORDER BY s.student_code;
END
GO

IF OBJECT_ID('sp_CreateAttendance', 'P') IS NOT NULL DROP PROCEDURE sp_CreateAttendance;
GO
CREATE PROCEDURE sp_CreateAttendance
    @AttendanceId VARCHAR(50),
    @EnrollmentId VARCHAR(50),
    @ClassId VARCHAR(50),
    @AttendanceDate DATETIME,
    @Status NVARCHAR(20),
    @Note NVARCHAR(500) = NULL,
    @CreatedBy VARCHAR(50) = 'system'
AS
BEGIN
    INSERT INTO dbo.attendances (attendance_id, enrollment_id, class_id, attendance_date,
                                  status, note, created_at, created_by)
    VALUES (@AttendanceId, @EnrollmentId, @ClassId, @AttendanceDate, @Status, @Note,
            GETDATE(), @CreatedBy);
END
GO

IF OBJECT_ID('sp_UpdateAttendance', 'P') IS NOT NULL DROP PROCEDURE sp_UpdateAttendance;
GO
CREATE PROCEDURE sp_UpdateAttendance
    @AttendanceId VARCHAR(50),
    @Status NVARCHAR(20),
    @Note NVARCHAR(500) = NULL,
    @UpdatedBy VARCHAR(50) = 'system'
AS
BEGIN
    UPDATE dbo.attendances
    SET status = @Status, note = @Note, updated_at = GETDATE(), updated_by = @UpdatedBy
    WHERE attendance_id = @AttendanceId;
END
GO

PRINT '✅ Attendances Management SPs created';
GO

-- ===========================================
-- 12. GRADES MANAGEMENT
-- ===========================================

IF OBJECT_ID('sp_GetGradesByClass', 'P') IS NOT NULL DROP PROCEDURE sp_GetGradesByClass;
GO
CREATE PROCEDURE sp_GetGradesByClass
    @ClassId VARCHAR(50)
AS
BEGIN
    SELECT g.*, s.student_code, s.full_name as student_name
    FROM dbo.grades g
    INNER JOIN dbo.enrollments e ON g.enrollment_id = e.enrollment_id
    INNER JOIN dbo.students s ON e.student_id = s.student_id
    WHERE e.class_id = @ClassId
    ORDER BY s.student_code;
END
GO

IF OBJECT_ID('sp_CreateGrade', 'P') IS NOT NULL DROP PROCEDURE sp_CreateGrade;
GO
CREATE PROCEDURE sp_CreateGrade
    @GradeId VARCHAR(50),
    @EnrollmentId VARCHAR(50),
    @MidtermScore DECIMAL(4,2) = NULL,
    @FinalScore DECIMAL(4,2) = NULL,
    @CreatedBy VARCHAR(50) = 'system'
AS
BEGIN
    INSERT INTO dbo.grades (grade_id, enrollment_id, midterm_score, final_score,
                            created_at, created_by)
    VALUES (@GradeId, @EnrollmentId, @MidtermScore, @FinalScore, GETDATE(), @CreatedBy);
END
GO

IF OBJECT_ID('sp_UpdateGrade', 'P') IS NOT NULL DROP PROCEDURE sp_UpdateGrade;
GO
CREATE PROCEDURE sp_UpdateGrade
    @GradeId VARCHAR(50),
    @MidtermScore DECIMAL(4,2) = NULL,
    @FinalScore DECIMAL(4,2) = NULL,
    @UpdatedBy VARCHAR(50) = 'system'
AS
BEGIN
    UPDATE dbo.grades
    SET midterm_score = @MidtermScore, final_score = @FinalScore,
        updated_at = GETDATE(), updated_by = @UpdatedBy
    WHERE grade_id = @GradeId;
END
GO

PRINT '✅ Grades Management SPs created';
GO

-- ===========================================
-- 13. ROLES MANAGEMENT
-- ===========================================

IF OBJECT_ID('sp_GetAllRoles', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllRoles;
GO
CREATE PROCEDURE sp_GetAllRoles
AS
BEGIN
    SELECT role_id, role_name, description, is_active, created_at
    FROM dbo.roles
    WHERE deleted_at IS NULL
    ORDER BY role_name;
END
GO

IF OBJECT_ID('sp_GetRoleById', 'P') IS NOT NULL DROP PROCEDURE sp_GetRoleById;
GO
CREATE PROCEDURE sp_GetRoleById
    @RoleId VARCHAR(50)
AS
BEGIN
    SELECT * FROM dbo.roles
    WHERE role_id = @RoleId AND deleted_at IS NULL;
END
GO

PRINT '✅ Roles Management SPs created';
GO

-- ===========================================
-- 14. NOTIFICATIONS MANAGEMENT
-- ===========================================

IF OBJECT_ID('sp_GetNotificationsByUser', 'P') IS NOT NULL DROP PROCEDURE sp_GetNotificationsByUser;
GO
CREATE PROCEDURE sp_GetNotificationsByUser
    @UserId VARCHAR(50)
AS
BEGIN
    SELECT * FROM dbo.notifications
    WHERE user_id = @UserId
    ORDER BY created_at DESC;
END
GO

IF OBJECT_ID('sp_MarkNotificationAsRead', 'P') IS NOT NULL DROP PROCEDURE sp_MarkNotificationAsRead;
GO
CREATE PROCEDURE sp_MarkNotificationAsRead
    @NotificationId VARCHAR(50)
AS
BEGIN
    UPDATE dbo.notifications
    SET is_read = 1
    WHERE notification_id = @NotificationId;
END
GO

PRINT '✅ Notifications Management SPs created';
GO

-- ===========================================
-- 15. AUDIT LOGS MANAGEMENT
-- ===========================================

IF OBJECT_ID('sp_GetAllAuditLogs', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllAuditLogs;
GO
CREATE PROCEDURE sp_GetAllAuditLogs
    @Page INT = 1,
    @PageSize INT = 25,
    @Search NVARCHAR(255) = NULL,
    @Action VARCHAR(50) = NULL,
    @EntityType VARCHAR(100) = NULL,
    @UserId VARCHAR(50) = NULL,
    @FromDate DATETIME = NULL,
    @ToDate DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Offset INT = (@Page - 1) * @PageSize;
    
    -- Trả về TotalCount
    SELECT COUNT(*) as TotalCount
    FROM dbo.audit_logs al
    LEFT JOIN dbo.users u ON al.user_id = u.user_id
    WHERE (@Search IS NULL OR u.full_name LIKE '%' + @Search + '%' 
           OR u.username LIKE '%' + @Search + '%'
           OR al.entity_type LIKE '%' + @Search + '%'
           OR al.action LIKE '%' + @Search + '%')
        AND (@Action IS NULL OR al.action = @Action)
        AND (@EntityType IS NULL OR al.entity_type = @EntityType)
        AND (@UserId IS NULL OR al.user_id = @UserId)
        AND (@FromDate IS NULL OR al.created_at >= @FromDate)
        AND (@ToDate IS NULL OR al.created_at <= @ToDate);
    
    -- Trả về Data với pagination
    SELECT 
        al.log_id,
        al.user_id,
        ISNULL(u.username, 'System') as user_name,
        ISNULL(u.full_name, 'System') as user_full_name,
        al.action,
        al.entity_type,
        al.entity_id,
        al.old_values,
        al.new_values,
        al.ip_address,
        al.user_agent,
        al.created_at
    FROM dbo.audit_logs al
    LEFT JOIN dbo.users u ON al.user_id = u.user_id
    WHERE (@Search IS NULL OR u.full_name LIKE '%' + @Search + '%' 
           OR u.username LIKE '%' + @Search + '%'
           OR al.entity_type LIKE '%' + @Search + '%'
           OR al.action LIKE '%' + @Search + '%')
        AND (@Action IS NULL OR al.action = @Action)
        AND (@EntityType IS NULL OR al.entity_type = @EntityType)
        AND (@UserId IS NULL OR al.user_id = @UserId)
        AND (@FromDate IS NULL OR al.created_at >= @FromDate)
        AND (@ToDate IS NULL OR al.created_at <= @ToDate)
    ORDER BY al.created_at DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END
GO

IF OBJECT_ID('sp_GetAuditLogById', 'P') IS NOT NULL DROP PROCEDURE sp_GetAuditLogById;
GO
CREATE PROCEDURE sp_GetAuditLogById
    @LogId BIGINT
AS
BEGIN
    SELECT 
        al.log_id,
        al.user_id,
        ISNULL(u.username, 'System') as user_name,
        ISNULL(u.full_name, 'System') as user_full_name,
        al.action,
        al.entity_type,
        al.entity_id,
        al.old_values,
        al.new_values,
        al.ip_address,
        al.user_agent,
        al.created_at
    FROM dbo.audit_logs al
    LEFT JOIN dbo.users u ON al.user_id = u.user_id
    WHERE al.log_id = @LogId;
END
GO

IF OBJECT_ID('sp_GetAuditLogsByUser', 'P') IS NOT NULL DROP PROCEDURE sp_GetAuditLogsByUser;
GO
CREATE PROCEDURE sp_GetAuditLogsByUser
    @UserId VARCHAR(50),
    @Page INT = 1,
    @PageSize INT = 25
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Offset INT = (@Page - 1) * @PageSize;
    
    SELECT COUNT(*) as TotalCount
    FROM dbo.audit_logs
    WHERE user_id = @UserId;
    
    SELECT 
        al.log_id,
        al.user_id,
        u.username as user_name,
        u.full_name as user_full_name,
        al.action,
        al.entity_type,
        al.entity_id,
        al.old_values,
        al.new_values,
        al.ip_address,
        al.user_agent,
        al.created_at
    FROM dbo.audit_logs al
    LEFT JOIN dbo.users u ON al.user_id = u.user_id
    WHERE al.user_id = @UserId
    ORDER BY al.created_at DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END
GO

IF OBJECT_ID('sp_GetAuditLogsByEntity', 'P') IS NOT NULL DROP PROCEDURE sp_GetAuditLogsByEntity;
GO
CREATE PROCEDURE sp_GetAuditLogsByEntity
    @EntityType VARCHAR(100),
    @EntityId VARCHAR(50),
    @Page INT = 1,
    @PageSize INT = 25
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Offset INT = (@Page - 1) * @PageSize;
    
    SELECT COUNT(*) as TotalCount
    FROM dbo.audit_logs
    WHERE entity_type = @EntityType AND entity_id = @EntityId;
    
    SELECT 
        al.log_id,
        al.user_id,
        ISNULL(u.username, 'System') as user_name,
        ISNULL(u.full_name, 'System') as user_full_name,
        al.action,
        al.entity_type,
        al.entity_id,
        al.old_values,
        al.new_values,
        al.ip_address,
        al.user_agent,
        al.created_at
    FROM dbo.audit_logs al
    LEFT JOIN dbo.users u ON al.user_id = u.user_id
    WHERE al.entity_type = @EntityType AND al.entity_id = @EntityId
    ORDER BY al.created_at DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END
GO

IF OBJECT_ID('sp_CreateAuditLog', 'P') IS NOT NULL DROP PROCEDURE sp_CreateAuditLog;
GO
CREATE PROCEDURE sp_CreateAuditLog
    @UserId VARCHAR(50) = NULL,
    @Action VARCHAR(50),
    @EntityType VARCHAR(100),
    @EntityId VARCHAR(50) = NULL,
    @OldValues NVARCHAR(MAX) = NULL,
    @NewValues NVARCHAR(MAX) = NULL,
    @IpAddress VARCHAR(50) = NULL,
    @UserAgent VARCHAR(500) = NULL
AS
BEGIN
    INSERT INTO dbo.audit_logs (user_id, action, entity_type, entity_id, 
                                 old_values, new_values, ip_address, user_agent, created_at)
    VALUES (@UserId, @Action, @EntityType, @EntityId, 
            @OldValues, @NewValues, @IpAddress, @UserAgent, GETDATE());
    
    SELECT SCOPE_IDENTITY() AS log_id;
END
GO

PRINT '✅ Audit Logs Management SPs created';
GO

-- ===========================================
-- 14. GPAS MANAGEMENT
-- ===========================================

IF OBJECT_ID('sp_GetGPAsByStudent', 'P') IS NOT NULL DROP PROCEDURE sp_GetGPAsByStudent;
GO
CREATE PROCEDURE sp_GetGPAsByStudent
    @StudentId VARCHAR(50),
    @AcademicYearId VARCHAR(50) = NULL
AS
BEGIN
    SELECT g.*, s.student_code, s.full_name as student_name,
           ay.year_name as academic_year_name
    FROM dbo.gpas g
    INNER JOIN dbo.students s ON g.student_id = s.student_id
    INNER JOIN dbo.academic_years ay ON g.academic_year_id = ay.academic_year_id
    WHERE g.student_id = @StudentId
        AND (@AcademicYearId IS NULL OR g.academic_year_id = @AcademicYearId)
        AND g.deleted_at IS NULL
    ORDER BY ay.start_year DESC, g.semester;
END
GO

IF OBJECT_ID('sp_CalculateGPA', 'P') IS NOT NULL DROP PROCEDURE sp_CalculateGPA;
GO
CREATE PROCEDURE sp_CalculateGPA
    @StudentId VARCHAR(50),
    @AcademicYearId VARCHAR(50),
    @Semester INT = NULL, -- NULL = cả năm, 1/2/3 = học kỳ cụ thể
    @CreatedBy VARCHAR(50) = 'system'
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @GpaId VARCHAR(50) = NEWID();
    DECLARE @Gpa10 DECIMAL(4,2);
    DECLARE @Gpa4 DECIMAL(4,2);
    DECLARE @TotalCredits INT;
    DECLARE @AccumulatedCredits INT;
    DECLARE @RankText NVARCHAR(50);
    
    -- Tính điểm trung bình và tổng tín chỉ
    SELECT 
        @Gpa10 = ROUND(SUM(g.total_score * sub.credits) / NULLIF(SUM(sub.credits), 0), 2),
        @TotalCredits = SUM(sub.credits),
        @AccumulatedCredits = SUM(CASE WHEN g.total_score >= 4.0 THEN sub.credits ELSE 0 END)
    FROM dbo.students s
    INNER JOIN dbo.enrollments e ON s.student_id = e.student_id
    INNER JOIN dbo.classes c ON e.class_id = c.class_id
    INNER JOIN dbo.subjects sub ON c.subject_id = sub.subject_id
    INNER JOIN dbo.grades g ON e.enrollment_id = g.enrollment_id
    WHERE s.student_id = @StudentId
        AND c.academic_year_id = @AcademicYearId
        AND (@Semester IS NULL OR c.semester = @Semester)
        AND g.total_score IS NOT NULL
        AND s.deleted_at IS NULL
        AND e.deleted_at IS NULL;
    
    -- Tính GPA hệ 4
    SELECT 
        @Gpa4 = ROUND(
            SUM(
                CASE 
                    WHEN g.total_score >= 8.5 THEN 4.0
                    WHEN g.total_score >= 8.0 THEN 3.7
                    WHEN g.total_score >= 7.0 THEN 3.0
                    WHEN g.total_score >= 6.5 THEN 2.5
                    WHEN g.total_score >= 5.5 THEN 2.0
                    WHEN g.total_score >= 5.0 THEN 1.5
                    WHEN g.total_score >= 4.0 THEN 1.0
                    ELSE 0
                END * sub.credits
            ) / NULLIF(SUM(sub.credits), 0),
            2
        )
    FROM dbo.students s
    INNER JOIN dbo.enrollments e ON s.student_id = e.student_id
    INNER JOIN dbo.classes c ON e.class_id = c.class_id
    INNER JOIN dbo.subjects sub ON c.subject_id = sub.subject_id
    INNER JOIN dbo.grades g ON e.enrollment_id = g.enrollment_id
    WHERE s.student_id = @StudentId
        AND c.academic_year_id = @AcademicYearId
        AND (@Semester IS NULL OR c.semester = @Semester)
        AND g.total_score IS NOT NULL
        AND s.deleted_at IS NULL
        AND e.deleted_at IS NULL;
    
    -- Xếp loại
    SET @RankText = CASE 
        WHEN @Gpa10 >= 8.5 THEN N'Xuất sắc'
        WHEN @Gpa10 >= 7.0 THEN N'Giỏi'
        WHEN @Gpa10 >= 5.5 THEN N'Khá'
        WHEN @Gpa10 >= 4.0 THEN N'Trung bình'
        ELSE N'Yếu'
    END;
    
    -- Xóa GPA cũ nếu có (để cập nhật)
    DELETE FROM dbo.gpas 
    WHERE student_id = @StudentId 
        AND academic_year_id = @AcademicYearId 
        AND ((@Semester IS NULL AND semester IS NULL) OR semester = @Semester);
    
    -- Chèn GPA mới
    INSERT INTO dbo.gpas (
        gpa_id, student_id, academic_year_id, semester,
        gpa10, gpa4, total_credits, accumulated_credits, rank_text,
        created_at, created_by
    )
    VALUES (
        @GpaId, @StudentId, @AcademicYearId, @Semester,
        @Gpa10, @Gpa4, @TotalCredits, @AccumulatedCredits, @RankText,
        GETDATE(), @CreatedBy
    );
    
    -- Trả về kết quả
    SELECT 
        @GpaId as gpa_id,
        @StudentId as student_id,
        @AcademicYearId as academic_year_id,
        @Semester as semester,
        @Gpa10 as gpa10,
        @Gpa4 as gpa4,
        @TotalCredits as total_credits,
        @AccumulatedCredits as accumulated_credits,
        @RankText as rank_text;
END
GO

IF OBJECT_ID('sp_CalculateAllStudentGPA', 'P') IS NOT NULL DROP PROCEDURE sp_CalculateAllStudentGPA;
GO
CREATE PROCEDURE sp_CalculateAllStudentGPA
    @AcademicYearId VARCHAR(50),
    @Semester INT = NULL,
    @CreatedBy VARCHAR(50) = 'system'
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @StudentId VARCHAR(50);
    DECLARE student_cursor CURSOR FOR
        SELECT DISTINCT s.student_id
        FROM dbo.students s
        INNER JOIN dbo.enrollments e ON s.student_id = e.student_id
        INNER JOIN dbo.classes c ON e.class_id = c.class_id
        WHERE c.academic_year_id = @AcademicYearId
            AND (@Semester IS NULL OR c.semester = @Semester)
            AND s.deleted_at IS NULL
            AND e.deleted_at IS NULL;
    
    OPEN student_cursor;
    FETCH NEXT FROM student_cursor INTO @StudentId;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC sp_CalculateGPA 
            @StudentId = @StudentId,
            @AcademicYearId = @AcademicYearId,
            @Semester = @Semester,
            @CreatedBy = @CreatedBy;
        
        FETCH NEXT FROM student_cursor INTO @StudentId;
    END
    
    CLOSE student_cursor;
    DEALLOCATE student_cursor;
    
    SELECT 'SUCCESS' as Status, 
           COUNT(*) as TotalStudentsProcessed
    FROM dbo.gpas
    WHERE academic_year_id = @AcademicYearId
        AND ((@Semester IS NULL AND semester IS NULL) OR semester = @Semester);
END
GO

PRINT '✅ GPAs Management SPs created';
GO

-- ===========================================
-- 15. ACADEMIC YEAR TRANSITION
-- ===========================================

IF OBJECT_ID('sp_TransitionToNewAcademicYear', 'P') IS NOT NULL DROP PROCEDURE sp_TransitionToNewAcademicYear;
GO
CREATE PROCEDURE sp_TransitionToNewAcademicYear
    @NewAcademicYearId VARCHAR(50),
    @ExecutedBy VARCHAR(50) = 'system'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- 1. Kiểm tra năm học mới có tồn tại không
        IF NOT EXISTS (SELECT 1 FROM dbo.academic_years WHERE academic_year_id = @NewAcademicYearId AND deleted_at IS NULL)
        BEGIN
            RAISERROR(N'❌ Năm học mới không tồn tại hoặc đã bị xóa!', 16, 1);
            RETURN;
        END
        
        -- 2. Lấy năm học hiện tại (đang active)
        DECLARE @OldAcademicYearId VARCHAR(50);
        SELECT TOP 1 @OldAcademicYearId = academic_year_id
        FROM dbo.academic_years
        WHERE is_active = 1 AND deleted_at IS NULL;
        
        IF @OldAcademicYearId IS NOT NULL
        BEGIN
            -- 3. Tính GPA cho tất cả sinh viên của năm học cũ
            EXEC sp_CalculateAllStudentGPA 
                @AcademicYearId = @OldAcademicYearId,
                @Semester = NULL, -- Tính GPA cả năm
                @CreatedBy = @ExecutedBy;
            
            -- 4. Đóng năm học cũ
            UPDATE dbo.academic_years 
            SET is_active = 0, 
                updated_at = GETDATE(), 
                updated_by = @ExecutedBy
            WHERE academic_year_id = @OldAcademicYearId;
        END
        
        -- 5. Kích hoạt năm học mới
        UPDATE dbo.academic_years 
        SET is_active = 1, 
            updated_at = GETDATE(), 
            updated_by = @ExecutedBy
        WHERE academic_year_id = @NewAcademicYearId;
        
        -- 6. Ghi log audit
        INSERT INTO dbo.audit_logs (
            user_id, action, entity_type, entity_id, 
            old_values, new_values, created_at
        )
        VALUES (
            @ExecutedBy, 
            'TRANSITION_ACADEMIC_YEAR', 
            'academic_years', 
            @NewAcademicYearId,
            CONCAT('{"old_year":"', @OldAcademicYearId, '"}'),
            CONCAT('{"new_year":"', @NewAcademicYearId, '"}'),
            GETDATE()
        );
        
        COMMIT TRANSACTION;
        
        SELECT 
            'SUCCESS' as Status,
            @OldAcademicYearId as OldAcademicYearId,
            @NewAcademicYearId as NewAcademicYearId,
            GETDATE() as TransitionDate,
            N'✅ Chuyển năm học thành công!' as Message;
            
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

IF OBJECT_ID('sp_GetActiveAcademicYear', 'P') IS NOT NULL DROP PROCEDURE sp_GetActiveAcademicYear;
GO
CREATE PROCEDURE sp_GetActiveAcademicYear
AS
BEGIN
    SELECT TOP 1 * 
    FROM dbo.academic_years
    WHERE is_active = 1 
        AND deleted_at IS NULL
    ORDER BY start_year DESC;
END
GO

PRINT '✅ Academic Year Transition SPs created';
GO

PRINT '';
PRINT '🎉 HOÀN THÀNH TẠO STORED PROCEDURES!';
PRINT '✅ Đã tạo tổng cộng 90+ stored procedures';
PRINT '✅ Tất cả SPs đều có DROP trước khi CREATE';
PRINT '';

-- ===========================================
-- ⚡ PAGINATION UPDATE (CHẠY RIÊNG PHẦN NÀY)
-- ===========================================
-- 📌 CHÚ Ý: Nếu bạn đã chạy stored procedures trước đó,
--           chỉ cần chạy RIÊNG phần từ đây đến hết file
-- 
-- ✅ Cách chạy:
--    1. Bôi đen từ dòng "BEGIN PAGINATION UPDATE" 
--       đến dòng "END PAGINATION UPDATE"
--    2. Nhấn F5 hoặc Execute
-- 
-- ⏱️  Thời gian: ~5 giây
-- 📊 Sẽ update: 8 stored procedures với pagination
-- ===========================================

PRINT '';
PRINT '⚡ BẮT ĐẦU UPDATE PAGINATION...';
PRINT '================================';
GO

-- ========================================
-- BEGIN PAGINATION UPDATE - BẮT ĐẦU TỪ ĐÂY
-- ========================================

-- ===========================================
-- 1. UPDATE: sp_GetAllFaculties (THÊM PAGINATION)
-- ===========================================
IF OBJECT_ID('sp_GetAllFaculties', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllFaculties;
GO
CREATE PROCEDURE sp_GetAllFaculties
    @Page INT = 1,
    @PageSize INT = 10,
    @Search NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Offset INT = (@Page - 1) * @PageSize;
    
    -- Trả về TotalCount
    SELECT COUNT(*) as TotalCount
    FROM dbo.faculties
    WHERE deleted_at IS NULL
        AND (@Search IS NULL OR faculty_code LIKE '%' + @Search + '%' 
             OR faculty_name LIKE '%' + @Search + '%');
    
    -- Trả về Data với pagination
    SELECT faculty_id, faculty_code, faculty_name, description, 
           is_active, created_at, created_by, updated_at, updated_by
    FROM dbo.faculties
    WHERE deleted_at IS NULL
        AND (@Search IS NULL OR faculty_code LIKE '%' + @Search + '%' 
             OR faculty_name LIKE '%' + @Search + '%')
    ORDER BY faculty_name
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END
GO
PRINT '✅ Updated: sp_GetAllFaculties (với pagination)';
GO

-- ===========================================
-- 2. UPDATE: sp_GetAllDepartments (THÊM PAGINATION)
-- ===========================================
IF OBJECT_ID('sp_GetAllDepartments', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllDepartments;
GO
CREATE PROCEDURE sp_GetAllDepartments
    @Page INT = 1,
    @PageSize INT = 10,
    @Search NVARCHAR(255) = NULL,
    @FacultyId VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Offset INT = (@Page - 1) * @PageSize;
    
    -- Trả về TotalCount
    SELECT COUNT(*) as TotalCount
    FROM dbo.departments d
    LEFT JOIN dbo.faculties f ON d.faculty_id = f.faculty_id
    WHERE d.deleted_at IS NULL
        AND (@Search IS NULL OR d.department_code LIKE '%' + @Search + '%' 
             OR d.department_name LIKE '%' + @Search + '%')
        AND (@FacultyId IS NULL OR d.faculty_id = @FacultyId);
    
    -- Trả về Data với pagination
    SELECT d.*, f.faculty_name, f.faculty_code
    FROM dbo.departments d
    LEFT JOIN dbo.faculties f ON d.faculty_id = f.faculty_id
    WHERE d.deleted_at IS NULL
        AND (@Search IS NULL OR d.department_code LIKE '%' + @Search + '%'
             OR d.department_name LIKE '%' + @Search + '%')
        AND (@FacultyId IS NULL OR d.faculty_id = @FacultyId)
    ORDER BY d.department_name
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END
GO
PRINT '✅ Updated: sp_GetAllDepartments (với pagination)';
GO

-- ===========================================
-- 3. UPDATE: sp_GetAllMajors (THÊM PAGINATION)
-- ===========================================
IF OBJECT_ID('sp_GetAllMajors', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllMajors;
GO
CREATE PROCEDURE sp_GetAllMajors
    @Page INT = 1,
    @PageSize INT = 10,
    @Search NVARCHAR(255) = NULL,
    @FacultyId VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Offset INT = (@Page - 1) * @PageSize;
    
    -- Trả về TotalCount
    SELECT COUNT(*) as TotalCount
    FROM dbo.majors m
    LEFT JOIN dbo.faculties f ON m.faculty_id = f.faculty_id
    WHERE m.deleted_at IS NULL
        AND (@Search IS NULL OR m.major_name LIKE '%' + @Search + '%' 
             OR m.major_code LIKE '%' + @Search + '%')
        AND (@FacultyId IS NULL OR m.faculty_id = @FacultyId);
    
    -- Trả về Data với pagination
    SELECT m.*, f.faculty_name, f.faculty_code
    FROM dbo.majors m
    LEFT JOIN dbo.faculties f ON m.faculty_id = f.faculty_id
    WHERE m.deleted_at IS NULL
        AND (@Search IS NULL OR m.major_name LIKE '%' + @Search + '%' 
             OR m.major_code LIKE '%' + @Search + '%')
        AND (@FacultyId IS NULL OR m.faculty_id = @FacultyId)
    ORDER BY m.major_name
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END
GO
PRINT '✅ Updated: sp_GetAllMajors (với pagination)';
GO

-- ===========================================
-- 4. UPDATE: sp_GetAllAcademicYears (THÊM PAGINATION)
-- ===========================================
IF OBJECT_ID('sp_GetAllAcademicYears', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllAcademicYears;
GO
CREATE PROCEDURE sp_GetAllAcademicYears
    @Page INT = 1,
    @PageSize INT = 10,
    @Search NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Offset INT = (@Page - 1) * @PageSize;
    
    -- Trả về TotalCount
    SELECT COUNT(*) as TotalCount
    FROM dbo.academic_years
    WHERE deleted_at IS NULL
        AND (@Search IS NULL OR year_name LIKE '%' + @Search + '%');
    
    -- Trả về Data với pagination
    SELECT *
    FROM dbo.academic_years
    WHERE deleted_at IS NULL
        AND (@Search IS NULL OR year_name LIKE '%' + @Search + '%')
    ORDER BY start_year DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END
GO
PRINT '✅ Updated: sp_GetAllAcademicYears (với pagination)';
GO

-- ===========================================
-- 5. UPDATE: sp_GetAllLecturers (THÊM PAGINATION)
-- ===========================================
IF OBJECT_ID('sp_GetAllLecturers', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllLecturers;
GO
CREATE PROCEDURE sp_GetAllLecturers
    @Page INT = 1,
    @PageSize INT = 10,
    @Search NVARCHAR(255) = NULL,
    @DepartmentId VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Offset INT = (@Page - 1) * @PageSize;
    
    -- Trả về TotalCount
    SELECT COUNT(*) as TotalCount
    FROM dbo.lecturers l
    LEFT JOIN dbo.departments d ON l.department_id = d.department_id
    LEFT JOIN dbo.faculties f ON d.faculty_id = f.faculty_id
    WHERE l.deleted_at IS NULL
        AND (@Search IS NULL OR l.lecturer_code LIKE '%' + @Search + '%' 
             OR l.full_name LIKE '%' + @Search + '%')
        AND (@DepartmentId IS NULL OR l.department_id = @DepartmentId);
    
    -- Trả về Data với pagination
    SELECT l.*, d.department_name, f.faculty_name
    FROM dbo.lecturers l
    LEFT JOIN dbo.departments d ON l.department_id = d.department_id
    LEFT JOIN dbo.faculties f ON d.faculty_id = f.faculty_id
    WHERE l.deleted_at IS NULL
        AND (@Search IS NULL OR l.lecturer_code LIKE '%' + @Search + '%' 
             OR l.full_name LIKE '%' + @Search + '%')
        AND (@DepartmentId IS NULL OR l.department_id = @DepartmentId)
    ORDER BY l.created_at DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END
GO
PRINT '✅ Updated: sp_GetAllLecturers (với pagination)';
GO

-- ===========================================
-- 6. UPDATE: sp_GetAllSubjects (THÊM PAGINATION)
-- ===========================================
IF OBJECT_ID('sp_GetAllSubjects', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllSubjects;
GO
CREATE PROCEDURE sp_GetAllSubjects
    @Page INT = 1,
    @PageSize INT = 10,
    @Search NVARCHAR(255) = NULL,
    @DepartmentId VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Offset INT = (@Page - 1) * @PageSize;
    
    -- Trả về TotalCount
    SELECT COUNT(*) as TotalCount
    FROM dbo.subjects s
    LEFT JOIN dbo.departments d ON s.department_id = d.department_id
    LEFT JOIN dbo.faculties f ON d.faculty_id = f.faculty_id
    WHERE s.deleted_at IS NULL
        AND (@Search IS NULL OR s.subject_code LIKE '%' + @Search + '%' 
             OR s.subject_name LIKE '%' + @Search + '%')
        AND (@DepartmentId IS NULL OR s.department_id = @DepartmentId);
    
    -- Trả về Data với pagination
    SELECT s.*, d.department_name, f.faculty_name
    FROM dbo.subjects s
    LEFT JOIN dbo.departments d ON s.department_id = d.department_id
    LEFT JOIN dbo.faculties f ON d.faculty_id = f.faculty_id
    WHERE s.deleted_at IS NULL
        AND (@Search IS NULL OR s.subject_code LIKE '%' + @Search + '%' 
             OR s.subject_name LIKE '%' + @Search + '%')
        AND (@DepartmentId IS NULL OR s.department_id = @DepartmentId)
    ORDER BY s.subject_name
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END
GO
PRINT '✅ Updated: sp_GetAllSubjects (với pagination)';
GO

-- ===========================================
-- 7. UPDATE: sp_GetAllClasses (THÊM PAGINATION)
-- ===========================================
IF OBJECT_ID('sp_GetAllClasses', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllClasses;
GO
CREATE PROCEDURE sp_GetAllClasses
    @Page INT = 1,
    @PageSize INT = 10,
    @Search NVARCHAR(255) = NULL,
    @SubjectId VARCHAR(50) = NULL,
    @LecturerId VARCHAR(50) = NULL,
    @AcademicYearId VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Offset INT = (@Page - 1) * @PageSize;
    
    -- Trả về TotalCount
    SELECT COUNT(*) as TotalCount
    FROM dbo.classes c
    LEFT JOIN dbo.subjects s ON c.subject_id = s.subject_id
    LEFT JOIN dbo.lecturers l ON c.lecturer_id = l.lecturer_id
    LEFT JOIN dbo.academic_years ay ON c.academic_year_id = ay.academic_year_id
    WHERE c.deleted_at IS NULL
        AND (@Search IS NULL OR c.class_code LIKE '%' + @Search + '%' 
             OR c.class_name LIKE '%' + @Search + '%')
        AND (@SubjectId IS NULL OR c.subject_id = @SubjectId)
        AND (@LecturerId IS NULL OR c.lecturer_id = @LecturerId)
        AND (@AcademicYearId IS NULL OR c.academic_year_id = @AcademicYearId);
    
    -- Trả về Data với pagination
    SELECT c.*, s.subject_name, l.full_name as lecturer_name, ay.year_name
    FROM dbo.classes c
    LEFT JOIN dbo.subjects s ON c.subject_id = s.subject_id
    LEFT JOIN dbo.lecturers l ON c.lecturer_id = l.lecturer_id
    LEFT JOIN dbo.academic_years ay ON c.academic_year_id = ay.academic_year_id
    WHERE c.deleted_at IS NULL
        AND (@Search IS NULL OR c.class_code LIKE '%' + @Search + '%' 
             OR c.class_name LIKE '%' + @Search + '%')
        AND (@SubjectId IS NULL OR c.subject_id = @SubjectId)
        AND (@LecturerId IS NULL OR c.lecturer_id = @LecturerId)
        AND (@AcademicYearId IS NULL OR c.academic_year_id = @AcademicYearId)
    ORDER BY c.created_at DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END
GO
PRINT '✅ Updated: sp_GetAllClasses (với pagination)';
GO

-- ===========================================
-- 8. UPDATE: sp_GetAllRoles (THÊM PAGINATION)
-- ===========================================
IF OBJECT_ID('sp_GetAllRoles', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllRoles;
GO
CREATE PROCEDURE sp_GetAllRoles
    @Page INT = 1,
    @PageSize INT = 10,
    @Search NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Offset INT = (@Page - 1) * @PageSize;
    
    -- Trả về TotalCount
    SELECT COUNT(*) as TotalCount
    FROM dbo.roles
    WHERE deleted_at IS NULL
        AND (@Search IS NULL OR role_name LIKE '%' + @Search + '%');
    
    -- Trả về Data với pagination
    SELECT role_id, role_name, description, is_active, created_at
    FROM dbo.roles
    WHERE deleted_at IS NULL
        AND (@Search IS NULL OR role_name LIKE '%' + @Search + '%')
    ORDER BY role_name
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END
GO
PRINT '✅ Updated: sp_GetAllRoles (với pagination)';
GO

-- ========================================
-- END PAGINATION UPDATE - KẾT THÚC Ở ĐÂY
-- ========================================

PRINT '';
PRINT '================================';
PRINT '🎉 HOÀN THÀNH UPDATE PAGINATION!';
PRINT '';

-- ===========================================
-- PERMISSIONS MANAGEMENT STORED PROCEDURES
-- ===========================================
PRINT '';
PRINT '🔐 Bắt đầu tạo Stored Procedures cho PERMISSIONS...';
PRINT '';

-- SP 1: Get All Permissions
IF OBJECT_ID('sp_GetAllPermissions', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllPermissions;
GO
CREATE PROCEDURE sp_GetAllPermissions
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        permission_id,
        permission_code,
        permission_name,
        description,
        created_at,
        created_by,
        updated_at,
        updated_by
    FROM dbo.permissions
    ORDER BY permission_code;
END
GO
PRINT '✅ Tạo sp_GetAllPermissions';

-- SP 2: Get Permissions by Role
IF OBJECT_ID('sp_GetPermissionsByRole', 'P') IS NOT NULL DROP PROCEDURE sp_GetPermissionsByRole;
GO
CREATE PROCEDURE sp_GetPermissionsByRole
    @RoleId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        p.permission_id,
        p.permission_code,
        p.permission_name,
        p.description,
        CASE WHEN rp.permission_id IS NOT NULL THEN 1 ELSE 0 END AS is_assigned
    FROM dbo.permissions p
    LEFT JOIN dbo.role_permissions rp 
        ON p.permission_id = rp.permission_id 
        AND rp.role_id = @RoleId
    ORDER BY p.permission_code;
END
GO
PRINT '✅ Tạo sp_GetPermissionsByRole';

-- SP 2.5: Get Permissions by Role Name (for Menu API)
IF OBJECT_ID('sp_GetPermissionsByRoleName', 'P') IS NOT NULL DROP PROCEDURE sp_GetPermissionsByRoleName;
GO
CREATE PROCEDURE sp_GetPermissionsByRoleName
    @RoleName NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Join roles -> role_permissions -> permissions
    SELECT 
        p.permission_id,
        p.permission_code,
        p.permission_name,
        p.description,
        p.created_at,
        p.created_by,
        p.updated_at,
        p.updated_by
    FROM dbo.permissions p
    INNER JOIN dbo.role_permissions rp ON p.permission_id = rp.permission_id
    INNER JOIN dbo.roles r ON rp.role_id = r.role_id
    WHERE r.role_name = @RoleName 
        AND r.deleted_at IS NULL
    ORDER BY p.permission_code;
END
GO
PRINT '✅ Tạo sp_GetPermissionsByRoleName';

-- SP 3: Get Permission IDs by Role
IF OBJECT_ID('sp_GetPermissionIdsByRole', 'P') IS NOT NULL DROP PROCEDURE sp_GetPermissionIdsByRole;
GO
CREATE PROCEDURE sp_GetPermissionIdsByRole
    @RoleId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT permission_id
    FROM dbo.role_permissions
    WHERE role_id = @RoleId;
END
GO
PRINT '✅ Tạo sp_GetPermissionIdsByRole';

-- SP 4: Assign Permission to Role
IF OBJECT_ID('sp_AssignPermissionToRole', 'P') IS NOT NULL DROP PROCEDURE sp_AssignPermissionToRole;
GO
CREATE PROCEDURE sp_AssignPermissionToRole
    @RoleId VARCHAR(50),
    @PermissionId VARCHAR(50),
    @CreatedBy VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT EXISTS (
        SELECT 1 FROM dbo.role_permissions 
        WHERE role_id = @RoleId AND permission_id = @PermissionId
    )
    BEGIN
        INSERT INTO dbo.role_permissions (role_id, permission_id, created_at, created_by)
        VALUES (@RoleId, @PermissionId, GETDATE(), @CreatedBy);
    END
END
GO
PRINT '✅ Tạo sp_AssignPermissionToRole';

-- SP 5: Remove Permission from Role
IF OBJECT_ID('sp_RemovePermissionFromRole', 'P') IS NOT NULL DROP PROCEDURE sp_RemovePermissionFromRole;
GO
CREATE PROCEDURE sp_RemovePermissionFromRole
    @RoleId VARCHAR(50),
    @PermissionId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM dbo.role_permissions
    WHERE role_id = @RoleId AND permission_id = @PermissionId;
END
GO
PRINT '✅ Tạo sp_RemovePermissionFromRole';

-- SP 6: Delete All Permissions by Role
IF OBJECT_ID('sp_DeleteAllPermissionsByRole', 'P') IS NOT NULL DROP PROCEDURE sp_DeleteAllPermissionsByRole;
GO
CREATE PROCEDURE sp_DeleteAllPermissionsByRole
    @RoleId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM dbo.role_permissions
    WHERE role_id = @RoleId;
    
    SELECT @@ROWCOUNT AS DeletedCount;
END
GO
PRINT '✅ Tạo sp_DeleteAllPermissionsByRole';

-- SP 7: Get User Permissions
IF OBJECT_ID('sp_GetUserPermissions', 'P') IS NOT NULL DROP PROCEDURE sp_GetUserPermissions;
GO
CREATE PROCEDURE sp_GetUserPermissions
    @UserId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT DISTINCT
        p.permission_id,
        p.permission_code,
        p.permission_name,
        p.description
    FROM dbo.users u
    INNER JOIN dbo.roles r ON u.role_id = r.role_id
    INNER JOIN dbo.role_permissions rp ON r.role_id = rp.role_id
    INNER JOIN dbo.permissions p ON rp.permission_id = p.permission_id
    WHERE u.user_id = @UserId
        AND u.is_active = 1
        AND u.deleted_at IS NULL
        AND r.is_active = 1
        AND r.deleted_at IS NULL
    ORDER BY p.permission_code;
END
GO
PRINT '✅ Tạo sp_GetUserPermissions';

-- SP 8: Check User Permission
IF OBJECT_ID('sp_CheckUserPermission', 'P') IS NOT NULL DROP PROCEDURE sp_CheckUserPermission;
GO
CREATE PROCEDURE sp_CheckUserPermission
    @UserId VARCHAR(50),
    @PermissionCode VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (
        SELECT 1
        FROM dbo.users u
        INNER JOIN dbo.roles r ON u.role_id = r.role_id
        INNER JOIN dbo.role_permissions rp ON r.role_id = rp.role_id
        INNER JOIN dbo.permissions p ON rp.permission_id = p.permission_id
        WHERE u.user_id = @UserId
            AND p.permission_code = @PermissionCode
            AND u.is_active = 1
            AND u.deleted_at IS NULL
            AND r.is_active = 1
            AND r.deleted_at IS NULL
    )
        SELECT 1 AS HasPermission;
    ELSE
        SELECT 0 AS HasPermission;
END
GO
PRINT '✅ Tạo sp_CheckUserPermission';

-- SP 9: Get Roles with Permission Count
IF OBJECT_ID('sp_GetRolesWithPermissionCount', 'P') IS NOT NULL DROP PROCEDURE sp_GetRolesWithPermissionCount;
GO
CREATE PROCEDURE sp_GetRolesWithPermissionCount
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        r.role_id,
        r.role_name,
        r.description,
        r.is_active,
        r.created_at,
        r.updated_at,
        COUNT(rp.permission_id) AS permission_count
    FROM dbo.roles r
    LEFT JOIN dbo.role_permissions rp ON r.role_id = rp.role_id
    WHERE r.deleted_at IS NULL
    GROUP BY 
        r.role_id,
        r.role_name,
        r.description,
        r.is_active,
        r.created_at,
        r.updated_at
    ORDER BY r.role_name;
END
GO
PRINT '✅ Tạo sp_GetRolesWithPermissionCount';

-- ===========================================
-- 🔹 FUNCTION: Sinh mã Department Code tự động
-- ===========================================
IF OBJECT_ID('fn_GenerateNextDepartmentCode', 'FN') IS NOT NULL
    DROP FUNCTION fn_GenerateNextDepartmentCode;
GO

CREATE FUNCTION fn_GenerateNextDepartmentCode()
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @NextNumber INT;
    DECLARE @NextCode VARCHAR(20);
    
    -- Lấy số lớn nhất hiện tại từ các mã có format DEPT###
    SELECT @NextNumber = ISNULL(MAX(
        CASE 
            WHEN department_code LIKE 'DEPT[0-9][0-9][0-9]'
            THEN CAST(SUBSTRING(department_code, 5, 3) AS INT)
            ELSE 0
        END
    ), 0) + 1
    FROM dbo.departments
    WHERE deleted_at IS NULL;
    
    -- Format: DEPT001, DEPT002, DEPT003...
    SET @NextCode = 'DEPT' + RIGHT('000' + CAST(@NextNumber AS VARCHAR), 3);
    
    RETURN @NextCode;
END
GO
PRINT '✅ Created: fn_GenerateNextDepartmentCode';
GO

-- ===========================================
-- 16. REFRESH TOKENS MANAGEMENT
-- ===========================================
PRINT '';
PRINT '🔐 Bắt đầu tạo Stored Procedures cho REFRESH TOKENS...';
PRINT '';

-- SP 1: Save Refresh Token
IF OBJECT_ID('sp_SaveRefreshToken', 'P') IS NOT NULL DROP PROCEDURE sp_SaveRefreshToken;
GO
CREATE PROCEDURE sp_SaveRefreshToken
    @Id UNIQUEIDENTIFIER,
    @UserId VARCHAR(50),
    @Token VARCHAR(500),
    @ExpiresAt DATETIME,
    @CreatedAt DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if user exists
        IF NOT EXISTS (SELECT 1 FROM dbo.users WHERE user_id = @UserId AND deleted_at IS NULL)
        BEGIN
            RAISERROR(N'User không tồn tại: %s', 16, 1, @UserId);
            RETURN;
        END
        
        -- Insert new refresh token
        INSERT INTO dbo.refresh_tokens (id, user_id, token, expires_at, created_at)
        VALUES (@Id, @UserId, @Token, @ExpiresAt, @CreatedAt);
        
        COMMIT TRANSACTION;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO
PRINT '✅ Tạo sp_SaveRefreshToken';
GO

-- SP 2: Get Refresh Token by Token String
IF OBJECT_ID('sp_GetRefreshTokenByToken', 'P') IS NOT NULL DROP PROCEDURE sp_GetRefreshTokenByToken;
GO
CREATE PROCEDURE sp_GetRefreshTokenByToken
    @Token VARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT 
            id,
            user_id,
            token,
            expires_at,
            created_at,
            revoked_at,
            replaced_by_token
        FROM dbo.refresh_tokens
        WHERE token = @Token;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO
PRINT '✅ Tạo sp_GetRefreshTokenByToken';
GO

-- SP 3: Revoke Refresh Token
IF OBJECT_ID('sp_RevokeRefreshToken', 'P') IS NOT NULL DROP PROCEDURE sp_RevokeRefreshToken;
GO
CREATE PROCEDURE sp_RevokeRefreshToken
    @Id UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE dbo.refresh_tokens
        SET revoked_at = GETDATE()
        WHERE id = @Id;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO
PRINT '✅ Tạo sp_RevokeRefreshToken';
GO

-- SP 4: Clean Expired Tokens (Maintenance Job)
IF OBJECT_ID('sp_CleanExpiredRefreshTokens', 'P') IS NOT NULL DROP PROCEDURE sp_CleanExpiredRefreshTokens;
GO
CREATE PROCEDURE sp_CleanExpiredRefreshTokens
    @DaysToKeep INT = 30
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @CutoffDate DATETIME = DATEADD(DAY, -@DaysToKeep, GETDATE());
        DECLARE @DeletedCount INT;
        
        BEGIN TRANSACTION;
        
        DELETE FROM dbo.refresh_tokens
        WHERE (expires_at < GETDATE() OR revoked_at IS NOT NULL)
            AND created_at < @CutoffDate;
        
        SET @DeletedCount = @@ROWCOUNT;
        
        COMMIT TRANSACTION;
        
        PRINT CONCAT('✅ Cleaned ', @DeletedCount, ' expired/revoked refresh tokens');
        SELECT @DeletedCount AS DeletedCount;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO
PRINT '✅ Tạo sp_CleanExpiredRefreshTokens';
GO

-- SP 5: Revoke All User Tokens (Logout from all devices)
IF OBJECT_ID('sp_RevokeAllUserTokens', 'P') IS NOT NULL DROP PROCEDURE sp_RevokeAllUserTokens;
GO
CREATE PROCEDURE sp_RevokeAllUserTokens
    @UserId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        UPDATE dbo.refresh_tokens
        SET revoked_at = GETDATE()
        WHERE user_id = @UserId
            AND revoked_at IS NULL;
        
        DECLARE @RevokedCount INT = @@ROWCOUNT;
        
        COMMIT TRANSACTION;
        
        SELECT @RevokedCount AS RevokedCount;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO
PRINT '✅ Tạo sp_RevokeAllUserTokens';
GO

PRINT '✅ Refresh Tokens Management SPs created (5 procedures)';
GO

-- ===========================================
-- 17. BATCH IMPORT STUDENTS
-- ===========================================
PRINT '';
PRINT '🚀 Bắt đầu tạo Batch Import Stored Procedures...';
PRINT '';

-- Create TYPE for Student Table Parameter
IF EXISTS (SELECT * FROM sys.types WHERE name = 'StudentImportType' AND is_table_type = 1)
BEGIN
    DROP TYPE StudentImportType;
    PRINT '🗑️  Dropped existing type: StudentImportType';
END
GO

CREATE TYPE StudentImportType AS TABLE (
    StudentCode VARCHAR(20) NOT NULL,
    FullName NVARCHAR(150) NOT NULL,
    Email VARCHAR(150) NOT NULL,
    Phone VARCHAR(20) NULL,
    DateOfBirth DATE NULL,
    Gender NVARCHAR(10) NULL,
    Address NVARCHAR(300) NULL,
    MajorId VARCHAR(50) NOT NULL,
    AcademicYearId VARCHAR(50) NULL
);
GO
PRINT '✅ Created type: StudentImportType';
GO

-- BATCH IMPORT STORED PROCEDURE
IF OBJECT_ID('sp_ImportStudentsBatch', 'P') IS NOT NULL 
    DROP PROCEDURE sp_ImportStudentsBatch;
GO

CREATE PROCEDURE sp_ImportStudentsBatch
    @Students StudentImportType READONLY,
    @CreatedBy VARCHAR(50) = 'system'
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Variables for results
    DECLARE @SuccessCount INT = 0;
    DECLARE @ErrorCount INT = 0;
    DECLARE @Errors TABLE (
        RowNumber INT,
        StudentCode VARCHAR(20),
        ErrorMessage NVARCHAR(500)
    );
    
    -- Counter for row number
    DECLARE @RowNumber INT = 0;
    
    BEGIN TRY
        -- Process each student
        DECLARE @StudentCode VARCHAR(20);
        DECLARE @FullName NVARCHAR(150);
        DECLARE @Email VARCHAR(150);
        DECLARE @Phone VARCHAR(20);
        DECLARE @DateOfBirth DATE;
        DECLARE @Gender NVARCHAR(10);
        DECLARE @Address NVARCHAR(300);
        DECLARE @MajorId VARCHAR(50);
        DECLARE @AcademicYearId VARCHAR(50);
        
        DECLARE student_cursor CURSOR FOR
            SELECT StudentCode, FullName, Email, Phone, DateOfBirth, Gender, 
                   Address, MajorId, AcademicYearId
            FROM @Students;
        
        OPEN student_cursor;
        
        FETCH NEXT FROM student_cursor INTO 
            @StudentCode, @FullName, @Email, @Phone, @DateOfBirth, @Gender,
            @Address, @MajorId, @AcademicYearId;
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @RowNumber = @RowNumber + 1;
            
            BEGIN TRY
                -- Validate: Check duplicate student code
                IF EXISTS (SELECT 1 FROM students WHERE student_code = @StudentCode AND deleted_at IS NULL)
                BEGIN
                    INSERT INTO @Errors (RowNumber, StudentCode, ErrorMessage)
                    VALUES (@RowNumber, @StudentCode, N'Mã sinh viên đã tồn tại');
                    
                    SET @ErrorCount = @ErrorCount + 1;
                END
                -- Validate: Check duplicate email
                ELSE IF EXISTS (SELECT 1 FROM students WHERE email = @Email AND deleted_at IS NULL)
                BEGIN
                    INSERT INTO @Errors (RowNumber, StudentCode, ErrorMessage)
                    VALUES (@RowNumber, @StudentCode, N'Email đã tồn tại: ' + @Email);
                    
                    SET @ErrorCount = @ErrorCount + 1;
                END
                -- Validate: Check major exists
                ELSE IF NOT EXISTS (SELECT 1 FROM majors WHERE major_id = @MajorId AND deleted_at IS NULL)
                BEGIN
                    INSERT INTO @Errors (RowNumber, StudentCode, ErrorMessage)
                    VALUES (@RowNumber, @StudentCode, N'Ngành không tồn tại: ' + @MajorId);
                    
                    SET @ErrorCount = @ErrorCount + 1;
                END
                ELSE
                BEGIN
                    -- Generate student_id
                    DECLARE @StudentId VARCHAR(50) = 'STD-' + LOWER(CONVERT(VARCHAR(36), NEWID()));
                    
                    -- Generate user_id for student account
                    DECLARE @UserId VARCHAR(50) = 'USER-' + LOWER(CONVERT(VARCHAR(36), NEWID()));
                    
                    -- Generate default password (should be changed on first login)
                    DECLARE @PasswordHash VARCHAR(255) = '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5lSWE0cQ5pZri'; -- bcrypt hash of "Student@123"
                    
                    -- Create user account first
                    INSERT INTO users (user_id, username, password_hash, email, phone, full_name, 
                                      role_id, is_active, avatar_url, created_at, created_by)
                    VALUES (@UserId, @StudentCode, @PasswordHash, @Email, @Phone, @FullName,
                            'ROLE003', 1, '/avatars/default.png', GETDATE(), @CreatedBy);
                    
                    -- Create student record
                    INSERT INTO students (student_id, user_id, student_code, full_name, gender, 
                                         date_of_birth, email, phone, address, major_id,
                                         academic_year_id, is_active, 
                                         created_at, created_by)
                    VALUES (@StudentId, @UserId, @StudentCode, @FullName, @Gender,
                            @DateOfBirth, @Email, @Phone, @Address, @MajorId,
                            @AcademicYearId, 1,
                            GETDATE(), @CreatedBy);
                    
                    SET @SuccessCount = @SuccessCount + 1;
                END
            END TRY
            BEGIN CATCH
                -- Capture error for this row
                INSERT INTO @Errors (RowNumber, StudentCode, ErrorMessage)
                VALUES (@RowNumber, @StudentCode, ERROR_MESSAGE());
                
                SET @ErrorCount = @ErrorCount + 1;
            END CATCH
            
            FETCH NEXT FROM student_cursor INTO 
                @StudentCode, @FullName, @Email, @Phone, @DateOfBirth, @Gender,
                @Address, @MajorId, @AcademicYearId;
        END
        
        CLOSE student_cursor;
        DEALLOCATE student_cursor;
        
        -- Return results
        SELECT @SuccessCount AS SuccessCount, @ErrorCount AS ErrorCount;
        
        -- Return errors if any
        IF @ErrorCount > 0
        BEGIN
            SELECT RowNumber, StudentCode, ErrorMessage
            FROM @Errors
            ORDER BY RowNumber;
        END
        
    END TRY
    BEGIN CATCH
        IF CURSOR_STATUS('local', 'student_cursor') >= 0
        BEGIN
            CLOSE student_cursor;
            DEALLOCATE student_cursor;
        END
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO
PRINT '✅ Created procedure: sp_ImportStudentsBatch';
GO

PRINT '✅ Batch Import Students SPs created (1 procedure + 1 type)';
GO

PRINT '';
PRINT '================================';
PRINT '🎉 HOÀN THÀNH TẠO STORED PROCEDURES!';
PRINT '✅ Đã tạo:';
PRINT '   - 90+ Core Management SPs';
PRINT '   - 9 Permission SPs';
PRINT '   - 5 Refresh Token SPs';
PRINT '   - 1 Batch Import SP + Type';
PRINT '   - Pagination SPs';
PRINT '   - Auto Code Function';
PRINT '';

 
 
 - -   # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
 
 - -   P H A S E   2 :   E N R O L L M E N T   S Y S T E M   -   S T O R E D   P R O C E D U R E S 
 
 - -   # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
 
 
 
 
 -- =============================================
-- File: 11_SP_AdministrativeClasses.sql
-- Description: Stored Procedures for Administrative Classes Management
-- Author: Education Management System
-- Created Date: 2025-10-30
-- Total SPs: 10
-- =============================================

USE EducationManagement;
GO

PRINT '========================================';
PRINT 'Starting: 11_SP_AdministrativeClasses.sql';
PRINT 'Creating 10 Stored Procedures for Administrative Classes';
PRINT '========================================';
GO

-- =============================================
-- SP 1: sp_GetAllAdministrativeClasses
-- Description: Get all administrative classes with pagination and filters
-- =============================================

IF OBJECT_ID('sp_GetAllAdministrativeClasses', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetAllAdministrativeClasses;
GO

CREATE PROCEDURE sp_GetAllAdministrativeClasses
    @Page INT = 1,
    @PageSize INT = 10,
    @Search NVARCHAR(200) = NULL,
    @MajorId VARCHAR(50) = NULL,
    @CohortYear INT = NULL,
    @AdvisorId VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        DECLARE @Offset INT = (@Page - 1) * @PageSize;
        
        -- Get total count
        DECLARE @TotalCount INT;
        
        SELECT @TotalCount = COUNT(*)
        FROM administrative_classes ac
        LEFT JOIN majors m ON ac.major_id = m.major_id
        LEFT JOIN lecturers l ON ac.advisor_id = l.lecturer_id
        WHERE ac.is_active = 1 
        AND ac.deleted_at IS NULL
        AND (@Search IS NULL OR ac.class_code LIKE '%' + @Search + '%' OR ac.class_name LIKE '%' + @Search + '%')
        AND (@MajorId IS NULL OR ac.major_id = @MajorId)
        AND (@CohortYear IS NULL OR ac.cohort_year = @CohortYear)
        AND (@AdvisorId IS NULL OR ac.advisor_id = @AdvisorId);
        
        -- Get paginated data
        SELECT 
            ac.admin_class_id,
            ac.class_code,
            ac.class_name,
            ac.major_id,
            m.major_name,
            m.faculty_id,
            f.faculty_name,
            ac.cohort_year,
            ac.advisor_id,
            l.full_name AS advisor_name,
            ac.academic_year_id,
            ay.year_name,
            ac.max_students,
            ac.current_students,
            ac.description,
            ac.created_at,
            ac.created_by,
            @TotalCount AS TotalCount
        FROM administrative_classes ac
        LEFT JOIN majors m ON ac.major_id = m.major_id
        LEFT JOIN faculties f ON m.faculty_id = f.faculty_id
        LEFT JOIN lecturers l ON ac.advisor_id = l.lecturer_id
        LEFT JOIN academic_years ay ON ac.academic_year_id = ay.academic_year_id
        WHERE ac.is_active = 1 
        AND ac.deleted_at IS NULL
        AND (@Search IS NULL OR ac.class_code LIKE '%' + @Search + '%' OR ac.class_name LIKE '%' + @Search + '%')
        AND (@MajorId IS NULL OR ac.major_id = @MajorId)
        AND (@CohortYear IS NULL OR ac.cohort_year = @CohortYear)
        AND (@AdvisorId IS NULL OR ac.advisor_id = @AdvisorId)
        ORDER BY ac.cohort_year DESC, ac.class_code
        OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT 'Created: sp_GetAllAdministrativeClasses';
GO

-- =============================================
-- SP 2: sp_GetAdministrativeClassById
-- Description: Get detailed information of a specific class
-- =============================================

IF OBJECT_ID('sp_GetAdministrativeClassById', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetAdministrativeClassById;
GO

CREATE PROCEDURE sp_GetAdministrativeClassById
    @AdminClassId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        SELECT 
            ac.admin_class_id,
            ac.class_code,
            ac.class_name,
            ac.major_id,
            m.major_name,
            m.major_code,
            m.faculty_id,
            f.faculty_name,
            f.faculty_code,
            ac.cohort_year,
            ac.advisor_id,
            l.full_name AS advisor_name,
            l.email AS advisor_email,
            l.phone_number AS advisor_phone,
            ac.academic_year_id,
            ay.year_name,
            ac.max_students,
            ac.current_students,
            ac.description,
            ac.is_active,
            ac.created_at,
            ac.created_by,
            ac.updated_at,
            ac.updated_by
        FROM administrative_classes ac
        LEFT JOIN majors m ON ac.major_id = m.major_id
        LEFT JOIN faculties f ON m.faculty_id = f.faculty_id
        LEFT JOIN lecturers l ON ac.advisor_id = l.lecturer_id
        LEFT JOIN academic_years ay ON ac.academic_year_id = ay.academic_year_id
        WHERE ac.admin_class_id = @AdminClassId
        AND ac.deleted_at IS NULL;
        
        IF @@ROWCOUNT = 0
        BEGIN
            THROW 50002, N'Không tìm thấy lớp hành chính', 1;
        END
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT 'Created: sp_GetAdministrativeClassById';
GO

-- =============================================
-- SP 3: sp_CreateAdministrativeClass
-- Description: Create new administrative class
-- =============================================

IF OBJECT_ID('sp_CreateAdministrativeClass', 'P') IS NOT NULL
    DROP PROCEDURE sp_CreateAdministrativeClass;
GO

CREATE PROCEDURE sp_CreateAdministrativeClass
    @AdminClassId VARCHAR(50),
    @ClassCode VARCHAR(20),
    @ClassName NVARCHAR(150),
    @MajorId VARCHAR(50),
    @CohortYear INT,
    @AdvisorId VARCHAR(50) = NULL,
    @AcademicYearId VARCHAR(50) = NULL,
    @MaxStudents INT = 50,
    @Description NVARCHAR(500) = NULL,
    @CreatedBy VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate: Check duplicate class code
        IF EXISTS (SELECT 1 FROM administrative_classes WHERE class_code = @ClassCode AND deleted_at IS NULL)
        BEGIN
            THROW 50003, N'Mã lớp đã tồn tại', 1;
        END
        
        -- Validate: Check major exists
        IF NOT EXISTS (SELECT 1 FROM majors WHERE major_id = @MajorId AND is_active = 1 AND deleted_at IS NULL)
        BEGIN
            THROW 50004, N'Ngành học không tồn tại', 1;
        END
        
        -- Validate: Check advisor exists (if provided)
        IF @AdvisorId IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM lecturers WHERE lecturer_id = @AdvisorId AND is_active = 1 AND deleted_at IS NULL)
            BEGIN
                THROW 50005, N'Giảng viên chủ nhiệm không tồn tại', 1;
            END
        END
        
        -- Validate: Check academic year exists (if provided)
        IF @AcademicYearId IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM academic_years WHERE academic_year_id = @AcademicYearId AND deleted_at IS NULL)
            BEGIN
                THROW 50006, N'Năm học không tồn tại', 1;
            END
        END
        
        -- Insert new administrative class
        INSERT INTO administrative_classes (
            admin_class_id,
            class_code,
            class_name,
            major_id,
            cohort_year,
            advisor_id,
            academic_year_id,
            max_students,
            current_students,
            description,
            is_active,
            created_at,
            created_by
        )
        VALUES (
            @AdminClassId,
            @ClassCode,
            @ClassName,
            @MajorId,
            @CohortYear,
            @AdvisorId,
            @AcademicYearId,
            @MaxStudents,
            0, -- current_students starts at 0
            @Description,
            1, -- is_active = true
            GETDATE(),
            @CreatedBy
        );
        
        COMMIT TRANSACTION;
        
        -- Return created class
        EXEC sp_GetAdministrativeClassById @AdminClassId;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT 'Created: sp_CreateAdministrativeClass';
GO

-- =============================================
-- SP 4: sp_UpdateAdministrativeClass
-- Description: Update administrative class information
-- =============================================

IF OBJECT_ID('sp_UpdateAdministrativeClass', 'P') IS NOT NULL
    DROP PROCEDURE sp_UpdateAdministrativeClass;
GO

CREATE PROCEDURE sp_UpdateAdministrativeClass
    @AdminClassId VARCHAR(50),
    @ClassCode VARCHAR(20) = NULL,
    @ClassName NVARCHAR(150) = NULL,
    @MajorId VARCHAR(50) = NULL,
    @CohortYear INT = NULL,
    @AdvisorId VARCHAR(50) = NULL,
    @AcademicYearId VARCHAR(50) = NULL,
    @MaxStudents INT = NULL,
    @Description NVARCHAR(500) = NULL,
    @UpdatedBy VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if class exists
        IF NOT EXISTS (SELECT 1 FROM administrative_classes WHERE admin_class_id = @AdminClassId AND deleted_at IS NULL)
        BEGIN
            THROW 50002, N'Không tìm thấy lớp hành chính', 1;
        END
        
        -- Validate: Check duplicate class code (if changing)
        IF @ClassCode IS NOT NULL
        BEGIN
            IF EXISTS (
                SELECT 1 FROM administrative_classes 
                WHERE class_code = @ClassCode 
                AND admin_class_id != @AdminClassId 
                AND deleted_at IS NULL
            )
            BEGIN
                THROW 50003, N'Mã lớp đã tồn tại', 1;
            END
        END
        
        -- Validate: Check max_students >= current_students
        IF @MaxStudents IS NOT NULL
        BEGIN
            DECLARE @CurrentStudents INT;
            SELECT @CurrentStudents = current_students 
            FROM administrative_classes 
            WHERE admin_class_id = @AdminClassId;
            
            IF @MaxStudents < @CurrentStudents
            BEGIN
                THROW 50007, N'Sĩ số tối đa không được nhỏ hơn sĩ số hiện tại', 1;
            END
        END
        
        -- Update class
        UPDATE administrative_classes
        SET 
            class_code = ISNULL(@ClassCode, class_code),
            class_name = ISNULL(@ClassName, class_name),
            major_id = ISNULL(@MajorId, major_id),
            cohort_year = ISNULL(@CohortYear, cohort_year),
            advisor_id = ISNULL(@AdvisorId, advisor_id),
            academic_year_id = ISNULL(@AcademicYearId, academic_year_id),
            max_students = ISNULL(@MaxStudents, max_students),
            description = ISNULL(@Description, description),
            updated_at = GETDATE(),
            updated_by = @UpdatedBy
        WHERE admin_class_id = @AdminClassId;
        
        COMMIT TRANSACTION;
        
        -- Return updated class
        EXEC sp_GetAdministrativeClassById @AdminClassId;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT 'Created: sp_UpdateAdministrativeClass';
GO

-- =============================================
-- SP 5: sp_DeleteAdministrativeClass
-- Description: Soft delete administrative class
-- =============================================

IF OBJECT_ID('sp_DeleteAdministrativeClass', 'P') IS NOT NULL
    DROP PROCEDURE sp_DeleteAdministrativeClass;
GO

CREATE PROCEDURE sp_DeleteAdministrativeClass
    @AdminClassId VARCHAR(50),
    @DeletedBy VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if class exists
        IF NOT EXISTS (SELECT 1 FROM administrative_classes WHERE admin_class_id = @AdminClassId AND deleted_at IS NULL)
        BEGIN
            THROW 50002, N'Không tìm thấy lớp hành chính', 1;
        END
        
        -- Check if class has students
        DECLARE @StudentCount INT;
        SELECT @StudentCount = current_students 
        FROM administrative_classes 
        WHERE admin_class_id = @AdminClassId;
        
        IF @StudentCount > 0
        BEGIN
            THROW 50008, N'Không thể xóa lớp đang có sinh viên', 1;
        END
        
        -- Soft delete
        UPDATE administrative_classes
        SET 
            is_active = 0,
            deleted_at = GETDATE(),
            deleted_by = @DeletedBy
        WHERE admin_class_id = @AdminClassId;
        
        COMMIT TRANSACTION;
        
        SELECT 1 AS Success, N'Xóa lớp hành chính thành công' AS Message;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT 'Created: sp_DeleteAdministrativeClass';
GO

-- =============================================
-- SP 6: sp_GetStudentsByAdminClass
-- Description: Get all students in an administrative class
-- =============================================

IF OBJECT_ID('sp_GetStudentsByAdminClass', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetStudentsByAdminClass;
GO

CREATE PROCEDURE sp_GetStudentsByAdminClass
    @AdminClassId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Check if class exists
        IF NOT EXISTS (SELECT 1 FROM administrative_classes WHERE admin_class_id = @AdminClassId AND deleted_at IS NULL)
        BEGIN
            THROW 50002, N'Không tìm thấy lớp hành chính', 1;
        END
        
        SELECT 
            s.student_id,
            s.student_code,
            s.full_name,
            s.email,
            s.phone_number,
            s.date_of_birth,
            s.gender,
            s.address,
            s.admin_class_id,
            ac.class_code AS admin_class_code,
            ac.class_name AS admin_class_name,
            s.created_at AS enrolled_date
        FROM students s
        INNER JOIN administrative_classes ac ON s.admin_class_id = ac.admin_class_id
        WHERE s.admin_class_id = @AdminClassId
        AND s.deleted_at IS NULL
        ORDER BY s.student_code;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT 'Created: sp_GetStudentsByAdminClass';
GO

-- =============================================
-- SP 7: sp_AssignStudentToAdminClass
-- Description: Assign a student to administrative class
-- =============================================

IF OBJECT_ID('sp_AssignStudentToAdminClass', 'P') IS NOT NULL
    DROP PROCEDURE sp_AssignStudentToAdminClass;
GO

CREATE PROCEDURE sp_AssignStudentToAdminClass
    @StudentId VARCHAR(50),
    @AdminClassId VARCHAR(50),
    @UpdatedBy VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if student exists
        IF NOT EXISTS (SELECT 1 FROM students WHERE student_id = @StudentId AND deleted_at IS NULL)
        BEGIN
            THROW 50009, N'Không tìm thấy sinh viên', 1;
        END
        
        -- Check if class exists
        IF NOT EXISTS (SELECT 1 FROM administrative_classes WHERE admin_class_id = @AdminClassId AND deleted_at IS NULL)
        BEGIN
            THROW 50002, N'Không tìm thấy lớp hành chính', 1;
        END
        
        -- Check if class is full
        DECLARE @MaxStudents INT, @CurrentStudents INT;
        SELECT @MaxStudents = max_students, @CurrentStudents = current_students
        FROM administrative_classes
        WHERE admin_class_id = @AdminClassId;
        
        IF @CurrentStudents >= @MaxStudents
        BEGIN
            THROW 50010, N'Lớp đã đầy', 1;
        END
        
        -- Check if student already has a class
        DECLARE @OldClassId VARCHAR(50);
        SELECT @OldClassId = admin_class_id FROM students WHERE student_id = @StudentId;
        
        -- If student already in a class, decrease that class count
        IF @OldClassId IS NOT NULL AND @OldClassId != @AdminClassId
        BEGIN
            UPDATE administrative_classes
            SET current_students = current_students - 1,
                updated_at = GETDATE(),
                updated_by = @UpdatedBy
            WHERE admin_class_id = @OldClassId;
        END
        
        -- Assign student to new class
        UPDATE students
        SET admin_class_id = @AdminClassId
        WHERE student_id = @StudentId;
        
        -- Increase new class count (only if different from old class)
        IF @OldClassId IS NULL OR @OldClassId != @AdminClassId
        BEGIN
            UPDATE administrative_classes
            SET current_students = current_students + 1,
                updated_at = GETDATE(),
                updated_by = @UpdatedBy
            WHERE admin_class_id = @AdminClassId;
        END
        
        COMMIT TRANSACTION;
        
        SELECT 1 AS Success, N'Phân sinh viên vào lớp thành công' AS Message;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT 'Created: sp_AssignStudentToAdminClass';
GO

-- =============================================
-- SP 8: sp_RemoveStudentFromAdminClass
-- Description: Remove student from administrative class
-- =============================================

IF OBJECT_ID('sp_RemoveStudentFromAdminClass', 'P') IS NOT NULL
    DROP PROCEDURE sp_RemoveStudentFromAdminClass;
GO

CREATE PROCEDURE sp_RemoveStudentFromAdminClass
    @StudentId VARCHAR(50),
    @UpdatedBy VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if student exists
        IF NOT EXISTS (SELECT 1 FROM students WHERE student_id = @StudentId AND deleted_at IS NULL)
        BEGIN
            THROW 50009, N'Không tìm thấy sinh viên', 1;
        END
        
        -- Get student's current class
        DECLARE @AdminClassId VARCHAR(50);
        SELECT @AdminClassId = admin_class_id FROM students WHERE student_id = @StudentId;
        
        IF @AdminClassId IS NULL
        BEGIN
            THROW 50011, N'Sinh viên chưa có lớp hành chính', 1;
        END
        
        -- Remove student from class
        UPDATE students
        SET admin_class_id = NULL
        WHERE student_id = @StudentId;
        
        -- Decrease class count
        UPDATE administrative_classes
        SET current_students = current_students - 1,
            updated_at = GETDATE(),
            updated_by = @UpdatedBy
        WHERE admin_class_id = @AdminClassId;
        
        COMMIT TRANSACTION;
        
        SELECT 1 AS Success, N'Xóa sinh viên khỏi lớp thành công' AS Message;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT 'Created: sp_RemoveStudentFromAdminClass';
GO

-- =============================================
-- SP 9: sp_GetAdminClassReport
-- Description: Get report/statistics for a class
-- =============================================

IF OBJECT_ID('sp_GetAdminClassReport', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetAdminClassReport;
GO

CREATE PROCEDURE sp_GetAdminClassReport
    @AdminClassId VARCHAR(50),
    @Semester INT = NULL,
    @AcademicYearId VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Check if class exists
        IF NOT EXISTS (SELECT 1 FROM administrative_classes WHERE admin_class_id = @AdminClassId AND deleted_at IS NULL)
        BEGIN
            THROW 50002, N'Không tìm thấy lớp hành chính', 1;
        END
        
        -- Get class basic info
        SELECT 
            ac.admin_class_id,
            ac.class_code,
            ac.class_name,
            ac.cohort_year,
            ac.max_students,
            ac.current_students,
            m.major_name,
            l.full_name AS advisor_name
        FROM administrative_classes ac
        LEFT JOIN majors m ON ac.major_id = m.major_id
        LEFT JOIN lecturers l ON ac.advisor_id = l.lecturer_id
        WHERE ac.admin_class_id = @AdminClassId;
        
        -- Get student statistics (placeholder - will be enhanced with actual grade data)
        SELECT 
            COUNT(*) AS total_students,
            COUNT(CASE WHEN s.gender = 'M' THEN 1 END) AS male_students,
            COUNT(CASE WHEN s.gender = 'F' THEN 1 END) AS female_students
        FROM students s
        WHERE s.admin_class_id = @AdminClassId
        AND s.deleted_at IS NULL;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT 'Created: sp_GetAdminClassReport';
GO

-- =============================================
-- SP 10: sp_GetAdminClassStatistics
-- Description: Get overview statistics of all administrative classes
-- =============================================

IF OBJECT_ID('sp_GetAdminClassStatistics', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetAdminClassStatistics;
GO

CREATE PROCEDURE sp_GetAdminClassStatistics
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        SELECT 
            COUNT(*) AS total_classes,
            SUM(current_students) AS total_students,
            AVG(CAST(current_students AS FLOAT)) AS avg_students_per_class,
            SUM(CASE WHEN current_students >= max_students THEN 1 ELSE 0 END) AS full_classes,
            SUM(CASE WHEN current_students = 0 THEN 1 ELSE 0 END) AS empty_classes
        FROM administrative_classes
        WHERE is_active = 1 
        AND deleted_at IS NULL;
        
        -- Classes by cohort year
        SELECT 
            cohort_year,
            COUNT(*) AS class_count,
            SUM(current_students) AS student_count
        FROM administrative_classes
        WHERE is_active = 1 
        AND deleted_at IS NULL
        GROUP BY cohort_year
        ORDER BY cohort_year DESC;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT 'Created: sp_GetAdminClassStatistics';
GO

-- =============================================
-- VERIFICATION
-- =============================================

PRINT '';
PRINT '========================================';
PRINT 'VERIFICATION RESULTS';
PRINT '========================================';

DECLARE @SPCount INT;
SELECT @SPCount = COUNT(*)
FROM sys.procedures
WHERE name IN (
    'sp_GetAllAdministrativeClasses',
    'sp_GetAdministrativeClassById',
    'sp_CreateAdministrativeClass',
    'sp_UpdateAdministrativeClass',
    'sp_DeleteAdministrativeClass',
    'sp_GetStudentsByAdminClass',
    'sp_AssignStudentToAdminClass',
    'sp_RemoveStudentFromAdminClass',
    'sp_GetAdminClassReport',
    'sp_GetAdminClassStatistics'
);

PRINT 'Stored Procedures created: ' + CAST(@SPCount AS VARCHAR(10)) + '/10';

IF @SPCount = 10
    PRINT '✓ All Administrative Class SPs created successfully'
ELSE
    PRINT '✗ Some SPs missing';

PRINT '';
PRINT '========================================';
PRINT 'Completed: 11_SP_AdministrativeClasses.sql';
PRINT '========================================';
GO

-- =============================================
-- File: 12_SP_RegistrationPeriods.sql
-- Description: Stored Procedures for Registration Periods Management
-- Author: Education Management System
-- Created Date: 2025-10-30
-- Total SPs: 8
-- =============================================

USE EducationManagement;
GO

PRINT '========================================';
PRINT 'Starting: 12_SP_RegistrationPeriods.sql';
PRINT 'Creating 8 Stored Procedures for Registration Periods';
PRINT '========================================';
GO

-- =============================================
-- SP 1: sp_GetAllRegistrationPeriods
-- Description: Get all registration periods
-- =============================================

IF OBJECT_ID('sp_GetAllRegistrationPeriods', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetAllRegistrationPeriods;
GO

CREATE PROCEDURE sp_GetAllRegistrationPeriods
    @AcademicYearId VARCHAR(50) = NULL,
    @Semester INT = NULL,
    @Status NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        SELECT 
            rp.period_id,
            rp.period_name,
            rp.academic_year_id,
            ay.year_name,
            rp.semester,
            rp.start_date,
            rp.end_date,
            rp.status,
            rp.description,
            rp.is_active,
            rp.created_at,
            rp.created_by,
            CASE 
                WHEN rp.status = 'OPEN' THEN 1
                WHEN GETDATE() < rp.start_date THEN 2
                WHEN GETDATE() > rp.end_date THEN 3
                ELSE 4
            END AS sort_order
        FROM registration_periods rp
        LEFT JOIN academic_years ay ON rp.academic_year_id = ay.academic_year_id
        WHERE rp.deleted_at IS NULL
        AND (@AcademicYearId IS NULL OR rp.academic_year_id = @AcademicYearId)
        AND (@Semester IS NULL OR rp.semester = @Semester)
        AND (@Status IS NULL OR rp.status = @Status)
        ORDER BY sort_order, rp.start_date DESC;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT 'Created: sp_GetAllRegistrationPeriods';
GO

-- =============================================
-- SP 2: sp_GetActiveRegistrationPeriod
-- Description: Get currently active (OPEN) registration period
-- =============================================

IF OBJECT_ID('sp_GetActiveRegistrationPeriod', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetActiveRegistrationPeriod;
GO

CREATE PROCEDURE sp_GetActiveRegistrationPeriod
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        SELECT TOP 1
            rp.period_id,
            rp.period_name,
            rp.academic_year_id,
            ay.year_name,
            rp.semester,
            rp.start_date,
            rp.end_date,
            rp.status,
            rp.description,
            DATEDIFF(DAY, GETDATE(), rp.end_date) AS days_remaining
        FROM registration_periods rp
        LEFT JOIN academic_years ay ON rp.academic_year_id = ay.academic_year_id
        WHERE rp.status = 'OPEN'
        AND rp.deleted_at IS NULL
        AND GETDATE() BETWEEN rp.start_date AND rp.end_date
        ORDER BY rp.start_date DESC;
        
        IF @@ROWCOUNT = 0
        BEGIN
            SELECT NULL AS period_id, N'Không có đợt đăng ký nào đang mở' AS message;
        END
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT 'Created: sp_GetActiveRegistrationPeriod';
GO

-- =============================================
-- SP 3: sp_GetRegistrationPeriodById
-- Description: Get registration period by ID
-- =============================================

IF OBJECT_ID('sp_GetRegistrationPeriodById', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetRegistrationPeriodById;
GO

CREATE PROCEDURE sp_GetRegistrationPeriodById
    @PeriodId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        SELECT 
            rp.period_id,
            rp.period_name,
            rp.academic_year_id,
            ay.year_name,
            rp.semester,
            rp.start_date,
            rp.end_date,
            rp.status,
            rp.description,
            rp.is_active,
            rp.created_at,
            rp.created_by,
            rp.updated_at,
            rp.updated_by,
            DATEDIFF(DAY, rp.start_date, rp.end_date) AS duration_days,
            CASE 
                WHEN GETDATE() < rp.start_date THEN DATEDIFF(DAY, GETDATE(), rp.start_date)
                WHEN GETDATE() > rp.end_date THEN 0
                ELSE DATEDIFF(DAY, GETDATE(), rp.end_date)
            END AS days_remaining
        FROM registration_periods rp
        LEFT JOIN academic_years ay ON rp.academic_year_id = ay.academic_year_id
        WHERE rp.period_id = @PeriodId
        AND rp.deleted_at IS NULL;
        
        IF @@ROWCOUNT = 0
        BEGIN
            THROW 50012, N'Không tìm thấy đợt đăng ký', 1;
        END
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT 'Created: sp_GetRegistrationPeriodById';
GO

-- =============================================
-- SP 4: sp_CreateRegistrationPeriod
-- Description: Create new registration period
-- =============================================

IF OBJECT_ID('sp_CreateRegistrationPeriod', 'P') IS NOT NULL
    DROP PROCEDURE sp_CreateRegistrationPeriod;
GO

CREATE PROCEDURE sp_CreateRegistrationPeriod
    @PeriodId VARCHAR(50),
    @PeriodName NVARCHAR(200),
    @AcademicYearId VARCHAR(50),
    @Semester INT,
    @StartDate DATETIME,
    @EndDate DATETIME,
    @Description NVARCHAR(500) = NULL,
    @CreatedBy VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate: Start date < End date
        IF @StartDate >= @EndDate
        BEGIN
            THROW 50013, N'Ngày bắt đầu phải nhỏ hơn ngày kết thúc', 1;
        END
        
        -- Validate: Semester is 1, 2, or 3
        IF @Semester NOT IN (1, 2, 3)
        BEGIN
            THROW 50014, N'Học kỳ không hợp lệ (phải là 1, 2, hoặc 3)', 1;
        END
        
        -- Validate: Academic year exists
        IF NOT EXISTS (SELECT 1 FROM academic_years WHERE academic_year_id = @AcademicYearId AND deleted_at IS NULL)
        BEGIN
            THROW 50006, N'Năm học không tồn tại', 1;
        END
        
        -- Validate: Check for overlapping periods (same academic year and semester)
        IF EXISTS (
            SELECT 1 FROM registration_periods
            WHERE academic_year_id = @AcademicYearId
            AND semester = @Semester
            AND deleted_at IS NULL
            AND (
                (@StartDate BETWEEN start_date AND end_date) OR
                (@EndDate BETWEEN start_date AND end_date) OR
                (start_date BETWEEN @StartDate AND @EndDate) OR
                (end_date BETWEEN @StartDate AND @EndDate)
            )
        )
        BEGIN
            THROW 50015, N'Đã có đợt đăng ký trùng thời gian cho học kỳ này', 1;
        END
        
        -- Insert new period
        INSERT INTO registration_periods (
            period_id,
            period_name,
            academic_year_id,
            semester,
            start_date,
            end_date,
            status,
            description,
            is_active,
            created_at,
            created_by
        )
        VALUES (
            @PeriodId,
            @PeriodName,
            @AcademicYearId,
            @Semester,
            @StartDate,
            @EndDate,
            'UPCOMING', -- Default status
            @Description,
            1,
            GETDATE(),
            @CreatedBy
        );
        
        COMMIT TRANSACTION;
        
        -- Return created period
        EXEC sp_GetRegistrationPeriodById @PeriodId;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT 'Created: sp_CreateRegistrationPeriod';
GO

-- =============================================
-- SP 5: sp_UpdateRegistrationPeriod
-- Description: Update registration period
-- =============================================

IF OBJECT_ID('sp_UpdateRegistrationPeriod', 'P') IS NOT NULL
    DROP PROCEDURE sp_UpdateRegistrationPeriod;
GO

CREATE PROCEDURE sp_UpdateRegistrationPeriod
    @PeriodId VARCHAR(50),
    @PeriodName NVARCHAR(200) = NULL,
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @Description NVARCHAR(500) = NULL,
    @UpdatedBy VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if period exists
        IF NOT EXISTS (SELECT 1 FROM registration_periods WHERE period_id = @PeriodId AND deleted_at IS NULL)
        BEGIN
            THROW 50012, N'Không tìm thấy đợt đăng ký', 1;
        END
        
        -- Get current values
        DECLARE @CurrentStartDate DATETIME, @CurrentEndDate DATETIME, @CurrentStatus NVARCHAR(20);
        SELECT 
            @CurrentStartDate = start_date,
            @CurrentEndDate = end_date,
            @CurrentStatus = status
        FROM registration_periods
        WHERE period_id = @PeriodId;
        
        -- Use current values if not provided
        SET @StartDate = ISNULL(@StartDate, @CurrentStartDate);
        SET @EndDate = ISNULL(@EndDate, @CurrentEndDate);
        
        -- Validate: Start date < End date
        IF @StartDate >= @EndDate
        BEGIN
            THROW 50013, N'Ngày bắt đầu phải nhỏ hơn ngày kết thúc', 1;
        END
        
        -- Don't allow editing if status is CLOSED
        IF @CurrentStatus = 'CLOSED'
        BEGIN
            THROW 50016, N'Không thể sửa đợt đăng ký đã đóng', 1;
        END
        
        -- Update period
        UPDATE registration_periods
        SET 
            period_name = ISNULL(@PeriodName, period_name),
            start_date = @StartDate,
            end_date = @EndDate,
            description = ISNULL(@Description, description),
            updated_at = GETDATE(),
            updated_by = @UpdatedBy
        WHERE period_id = @PeriodId;
        
        COMMIT TRANSACTION;
        
        -- Return updated period
        EXEC sp_GetRegistrationPeriodById @PeriodId;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT 'Created: sp_UpdateRegistrationPeriod';
GO

-- =============================================
-- SP 6: sp_DeleteRegistrationPeriod
-- Description: Soft delete registration period
-- =============================================

IF OBJECT_ID('sp_DeleteRegistrationPeriod', 'P') IS NOT NULL
    DROP PROCEDURE sp_DeleteRegistrationPeriod;
GO

CREATE PROCEDURE sp_DeleteRegistrationPeriod
    @PeriodId VARCHAR(50),
    @DeletedBy VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if period exists
        IF NOT EXISTS (SELECT 1 FROM registration_periods WHERE period_id = @PeriodId AND deleted_at IS NULL)
        BEGIN
            THROW 50012, N'Không tìm thấy đợt đăng ký', 1;
        END
        
        -- Check if period is OPEN
        DECLARE @Status NVARCHAR(20);
        SELECT @Status = status FROM registration_periods WHERE period_id = @PeriodId;
        
        IF @Status = 'OPEN'
        BEGIN
            THROW 50017, N'Không thể xóa đợt đăng ký đang mở', 1;
        END
        
        -- Soft delete
        UPDATE registration_periods
        SET 
            is_active = 0,
            deleted_at = GETDATE(),
            deleted_by = @DeletedBy
        WHERE period_id = @PeriodId;
        
        COMMIT TRANSACTION;
        
        SELECT 1 AS Success, N'Xóa đợt đăng ký thành công' AS Message;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT 'Created: sp_DeleteRegistrationPeriod';
GO

-- =============================================
-- SP 7: sp_OpenRegistrationPeriod
-- Description: Open a registration period (close all others)
-- =============================================

IF OBJECT_ID('sp_OpenRegistrationPeriod', 'P') IS NOT NULL
    DROP PROCEDURE sp_OpenRegistrationPeriod;
GO

CREATE PROCEDURE sp_OpenRegistrationPeriod
    @PeriodId VARCHAR(50),
    @UpdatedBy VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if period exists
        IF NOT EXISTS (SELECT 1 FROM registration_periods WHERE period_id = @PeriodId AND deleted_at IS NULL)
        BEGIN
            THROW 50012, N'Không tìm thấy đợt đăng ký', 1;
        END
        
        -- Validate: Period dates are valid
        DECLARE @StartDate DATETIME, @EndDate DATETIME, @AcademicYearId VARCHAR(50), @Semester INT;
        SELECT 
            @StartDate = start_date,
            @EndDate = end_date,
            @AcademicYearId = academic_year_id,
            @Semester = semester
        FROM registration_periods
        WHERE period_id = @PeriodId;
        
        IF GETDATE() < @StartDate
        BEGIN
            THROW 50018, N'Chưa đến thời gian mở đợt đăng ký', 1;
        END
        
        IF GETDATE() > @EndDate
        BEGIN
            THROW 50019, N'Đã quá thời gian đăng ký', 1;
        END
        
        -- Close all other OPEN periods for the same academic year and semester
        UPDATE registration_periods
        SET 
            status = 'CLOSED',
            updated_at = GETDATE(),
            updated_by = @UpdatedBy
        WHERE academic_year_id = @AcademicYearId
        AND semester = @Semester
        AND status = 'OPEN'
        AND period_id != @PeriodId
        AND deleted_at IS NULL;
        
        -- Open the requested period
        UPDATE registration_periods
        SET 
            status = 'OPEN',
            updated_at = GETDATE(),
            updated_by = @UpdatedBy
        WHERE period_id = @PeriodId;
        
        COMMIT TRANSACTION;
        
        -- Return updated period
        EXEC sp_GetRegistrationPeriodById @PeriodId;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT 'Created: sp_OpenRegistrationPeriod';
GO

-- =============================================
-- SP 8: sp_CloseRegistrationPeriod
-- Description: Close a registration period
-- =============================================

IF OBJECT_ID('sp_CloseRegistrationPeriod', 'P') IS NOT NULL
    DROP PROCEDURE sp_CloseRegistrationPeriod;
GO

CREATE PROCEDURE sp_CloseRegistrationPeriod
    @PeriodId VARCHAR(50),
    @UpdatedBy VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if period exists
        IF NOT EXISTS (SELECT 1 FROM registration_periods WHERE period_id = @PeriodId AND deleted_at IS NULL)
        BEGIN
            THROW 50012, N'Không tìm thấy đợt đăng ký', 1;
        END
        
        -- Close the period
        UPDATE registration_periods
        SET 
            status = 'CLOSED',
            updated_at = GETDATE(),
            updated_by = @UpdatedBy
        WHERE period_id = @PeriodId;
        
        COMMIT TRANSACTION;
        
        -- Return updated period
        EXEC sp_GetRegistrationPeriodById @PeriodId;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT 'Created: sp_CloseRegistrationPeriod';
GO

-- =============================================
-- VERIFICATION
-- =============================================

PRINT '';
PRINT '========================================';
PRINT 'VERIFICATION RESULTS';
PRINT '========================================';

DECLARE @SPCount INT;
SELECT @SPCount = COUNT(*)
FROM sys.procedures
WHERE name IN (
    'sp_GetAllRegistrationPeriods',
    'sp_GetActiveRegistrationPeriod',
    'sp_GetRegistrationPeriodById',
    'sp_CreateRegistrationPeriod',
    'sp_UpdateRegistrationPeriod',
    'sp_DeleteRegistrationPeriod',
    'sp_OpenRegistrationPeriod',
    'sp_CloseRegistrationPeriod'
);

PRINT 'Stored Procedures created: ' + CAST(@SPCount AS VARCHAR(10)) + '/8';

IF @SPCount = 8
    PRINT '✓ All Registration Period SPs created successfully'
ELSE
    PRINT '✗ Some SPs missing';

PRINT '';
PRINT '========================================';
PRINT 'Completed: 12_SP_RegistrationPeriods.sql';
PRINT '========================================';
GO

-- =============================================
-- File: 13_SP_Enrollments.sql
-- Description: Stored Procedures for Course Enrollment Management (CORE FEATURE)
-- Author: Education Management System
-- Created Date: 2025-10-30
-- Total SPs: 12
-- =============================================

USE EducationManagement;
GO

PRINT '========================================';
PRINT 'Starting: 13_SP_Enrollments.sql';
PRINT 'Creating 12 Stored Procedures for Enrollment Management';
PRINT '========================================';
GO

-- =============================================
-- SP 1: sp_GetAvailableClassesForStudent
-- Description: Get list of classes available for student enrollment
-- =============================================

IF OBJECT_ID('sp_GetAvailableClassesForStudent', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetAvailableClassesForStudent;
GO

CREATE PROCEDURE sp_GetAvailableClassesForStudent
    @StudentId VARCHAR(50),
    @AcademicYearId VARCHAR(50),
    @Semester INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Get all classes for the semester
        SELECT 
            c.class_id,
            c.class_code,
            c.class_name,
            c.subject_id,
            s.subject_name,
            s.subject_code,
            s.credits,
            c.lecturer_id,
            l.full_name AS lecturer_name,
            c.schedule,
            c.room,
            c.max_students,
            c.current_enrollment,
            (c.max_students - c.current_enrollment) AS available_slots,
            CASE 
                WHEN c.current_enrollment >= c.max_students THEN 0
                ELSE 1
            END AS has_slots,
            -- Check if already enrolled
            CASE 
                WHEN EXISTS (
                    SELECT 1 FROM enrollments e
                    WHERE e.student_id = @StudentId
                    AND e.class_id = c.class_id
                    AND e.deleted_at IS NULL
                    AND e.enrollment_status IN ('PENDING', 'APPROVED')
                ) THEN 1
                ELSE 0
            END AS is_enrolled,
            -- Eligibility check (basic - detailed check in sp_CheckEnrollmentEligibility)
            CASE 
                WHEN c.current_enrollment >= c.max_students THEN N'Lớp đã đầy'
                WHEN EXISTS (
                    SELECT 1 FROM enrollments e
                    WHERE e.student_id = @StudentId
                    AND e.class_id = c.class_id
                    AND e.deleted_at IS NULL
                    AND e.enrollment_status IN ('PENDING', 'APPROVED')
                ) THEN N'Đã đăng ký lớp này'
                ELSE NULL
            END AS ineligible_reason
        FROM classes c
        INNER JOIN subjects s ON c.subject_id = s.subject_id
        LEFT JOIN lecturers l ON c.lecturer_id = l.lecturer_id
        WHERE c.academic_year_id = @AcademicYearId
        AND c.semester = @Semester
        AND c.deleted_at IS NULL
        ORDER BY s.subject_name, c.class_code;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT 'Created: sp_GetAvailableClassesForStudent';
GO

-- =============================================
-- SP 2: sp_CheckEnrollmentEligibility
-- Description: Check if student can enroll in a class (detailed validation)
-- =============================================

IF OBJECT_ID('sp_CheckEnrollmentEligibility', 'P') IS NOT NULL
    DROP PROCEDURE sp_CheckEnrollmentEligibility;
GO

CREATE PROCEDURE sp_CheckEnrollmentEligibility
    @StudentId VARCHAR(50),
    @ClassId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        DECLARE @IsEligible BIT = 1;
        DECLARE @ErrorMessage NVARCHAR(500) = NULL;
        
        -- Check 1: Student exists
        IF NOT EXISTS (SELECT 1 FROM students WHERE student_id = @StudentId AND deleted_at IS NULL)
        BEGIN
            SET @IsEligible = 0;
            SET @ErrorMessage = N'Sinh viên không tồn tại';
        END
        
        -- Check 2: Class exists
        ELSE IF NOT EXISTS (SELECT 1 FROM classes WHERE class_id = @ClassId AND deleted_at IS NULL)
        BEGIN
            SET @IsEligible = 0;
            SET @ErrorMessage = N'Lớp học không tồn tại';
        END
        
        -- Check 3: Registration period is OPEN
        ELSE IF NOT EXISTS (
            SELECT 1 FROM registration_periods rp
            INNER JOIN classes c ON rp.academic_year_id = c.academic_year_id AND rp.semester = c.semester
            WHERE c.class_id = @ClassId
            AND rp.status = 'OPEN'
            AND GETDATE() BETWEEN rp.start_date AND rp.end_date
            AND rp.deleted_at IS NULL
        )
        BEGIN
            SET @IsEligible = 0;
            SET @ErrorMessage = N'Không trong thời gian đăng ký';
        END
        
        -- Check 4: Class not full
        ELSE 
        BEGIN
            DECLARE @MaxStudents INT, @CurrentEnrollment INT;
            SELECT @MaxStudents = max_students, @CurrentEnrollment = current_enrollment
            FROM classes WHERE class_id = @ClassId;
            
            IF @CurrentEnrollment >= @MaxStudents
            BEGIN
                SET @IsEligible = 0;
                SET @ErrorMessage = N'Lớp đã đầy';
            END
        END
        
        -- Check 5: Not already enrolled
        IF @IsEligible = 1
        BEGIN
            IF EXISTS (
                SELECT 1 FROM enrollments
                WHERE student_id = @StudentId
                AND class_id = @ClassId
                AND enrollment_status IN ('PENDING', 'APPROVED')
                AND deleted_at IS NULL
            )
            BEGIN
                SET @IsEligible = 0;
                SET @ErrorMessage = N'Đã đăng ký lớp này';
            END
        END
        
        -- Check 6: No schedule conflict (basic check on schedule string)
        IF @IsEligible = 1
        BEGIN
            DECLARE @NewSchedule NVARCHAR(500);
            SELECT @NewSchedule = schedule FROM classes WHERE class_id = @ClassId;
            
            IF EXISTS (
                SELECT 1 FROM enrollments e
                INNER JOIN classes c ON e.class_id = c.class_id
                WHERE e.student_id = @StudentId
                AND e.enrollment_status = 'APPROVED'
                AND e.deleted_at IS NULL
                AND c.schedule = @NewSchedule -- Simple string comparison
                AND c.class_id != @ClassId
            )
            BEGIN
                SET @IsEligible = 0;
                SET @ErrorMessage = N'Trùng lịch học';
            END
        END
        
        -- Return result
        SELECT 
            @IsEligible AS is_eligible,
            @ErrorMessage AS error_message,
            @StudentId AS student_id,
            @ClassId AS class_id;
        
    END TRY
    BEGIN CATCH
        DECLARE @Error NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @Error, 1;
    END CATCH
END
GO

PRINT 'Created: sp_CheckEnrollmentEligibility';
GO

-- =============================================
-- SP 3: sp_CreateEnrollment
-- Description: Enroll student in a class
-- =============================================

IF OBJECT_ID('sp_CreateEnrollment', 'P') IS NOT NULL
    DROP PROCEDURE sp_CreateEnrollment;
GO

CREATE PROCEDURE sp_CreateEnrollment
    @EnrollmentId VARCHAR(50),
    @StudentId VARCHAR(50),
    @ClassId VARCHAR(50),
    @Notes NVARCHAR(500) = NULL,
    @CreatedBy VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check eligibility first
        DECLARE @IsEligible BIT, @ErrorMsg NVARCHAR(500);
        
        EXEC sp_CheckEnrollmentEligibility 
            @StudentId = @StudentId,
            @ClassId = @ClassId;
        
        -- Get eligibility result from temp table or variable
        -- For simplicity, re-run checks inline
        
        -- Validate class not full
        DECLARE @MaxStudents INT, @CurrentEnrollment INT;
        SELECT @MaxStudents = max_students, @CurrentEnrollment = current_enrollment
        FROM classes WHERE class_id = @ClassId;
        
        IF @CurrentEnrollment >= @MaxStudents
        BEGIN
            THROW 50020, N'Lớp đã đầy', 1;
        END
        
        -- Check not already enrolled
        IF EXISTS (
            SELECT 1 FROM enrollments
            WHERE student_id = @StudentId
            AND class_id = @ClassId
            AND enrollment_status IN ('PENDING', 'APPROVED')
            AND deleted_at IS NULL
        )
        BEGIN
            THROW 50021, N'Đã đăng ký lớp này', 1;
        END
        
        -- Calculate drop deadline (enrollment_date + 2 weeks)
        DECLARE @DropDeadline DATE = CAST(DATEADD(WEEK, 2, GETDATE()) AS DATE);
        
        -- Insert enrollment
        INSERT INTO enrollments (
            enrollment_id,
            student_id,
            class_id,
            enrollment_date,
            enrollment_status,
            drop_deadline,
            notes,
            created_at,
            created_by
        )
        VALUES (
            @EnrollmentId,
            @StudentId,
            @ClassId,
            GETDATE(),
            'APPROVED', -- Auto-approve
            @DropDeadline,
            @Notes,
            GETDATE(),
            @CreatedBy
        );
        
        -- Update class enrollment count
        UPDATE classes
        SET current_enrollment = current_enrollment + 1
        WHERE class_id = @ClassId;
        
        COMMIT TRANSACTION;
        
        -- Return enrollment info
        SELECT 
            e.enrollment_id,
            e.student_id,
            s.student_code,
            s.full_name AS student_name,
            e.class_id,
            c.class_code,
            c.class_name,
            sub.subject_name,
            e.enrollment_date,
            e.enrollment_status,
            e.drop_deadline,
            1 AS success,
            N'Đăng ký thành công' AS message
        FROM enrollments e
        INNER JOIN students s ON e.student_id = s.student_id
        INNER JOIN classes c ON e.class_id = c.class_id
        INNER JOIN subjects sub ON c.subject_id = sub.subject_id
        WHERE e.enrollment_id = @EnrollmentId;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT 'Created: sp_CreateEnrollment';
GO

-- =============================================
-- SP 4: sp_DropEnrollment
-- Description: Drop an enrollment (student withdraws from class)
-- =============================================

IF OBJECT_ID('sp_DropEnrollment', 'P') IS NOT NULL
    DROP PROCEDURE sp_DropEnrollment;
GO

CREATE PROCEDURE sp_DropEnrollment
    @EnrollmentId VARCHAR(50),
    @Reason NVARCHAR(500) = NULL,
    @DeletedBy VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if enrollment exists
        IF NOT EXISTS (SELECT 1 FROM enrollments WHERE enrollment_id = @EnrollmentId AND deleted_at IS NULL)
        BEGIN
            THROW 50022, N'Không tìm thấy đăng ký', 1;
        END
        
        -- Get enrollment info
        DECLARE @ClassId VARCHAR(50), @DropDeadline DATE, @EnrollmentStatus NVARCHAR(20);
        SELECT 
            @ClassId = class_id,
            @DropDeadline = drop_deadline,
            @EnrollmentStatus = enrollment_status
        FROM enrollments
        WHERE enrollment_id = @EnrollmentId;
        
        -- Check if already dropped
        IF @EnrollmentStatus = 'DROPPED'
        BEGIN
            THROW 50023, N'Đã hủy đăng ký trước đó', 1;
        END
        
        -- Check deadline
        IF @DropDeadline IS NOT NULL AND GETDATE() > @DropDeadline
        BEGIN
            THROW 50024, N'Đã quá hạn hủy đăng ký', 1;
        END
        
        -- Update enrollment status
        UPDATE enrollments
        SET 
            enrollment_status = 'DROPPED',
            drop_reason = @Reason,
            deleted_at = GETDATE(),
            deleted_by = @DeletedBy
        WHERE enrollment_id = @EnrollmentId;
        
        -- Decrease class enrollment count
        UPDATE classes
        SET current_enrollment = current_enrollment - 1
        WHERE class_id = @ClassId;
        
        COMMIT TRANSACTION;
        
        SELECT 1 AS Success, N'Hủy đăng ký thành công' AS Message;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT 'Created: sp_DropEnrollment';
GO

-- =============================================
-- SP 5: sp_BulkEnrollment
-- Description: Enroll student in multiple classes at once
-- =============================================

IF OBJECT_ID('sp_BulkEnrollment', 'P') IS NOT NULL
    DROP PROCEDURE sp_BulkEnrollment;
GO

CREATE PROCEDURE sp_BulkEnrollment
    @StudentId VARCHAR(50),
    @ClassIds NVARCHAR(MAX), -- Comma-separated list of class IDs
    @CreatedBy VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        DECLARE @SuccessCount INT = 0;
        DECLARE @ErrorCount INT = 0;
        DECLARE @Results TABLE (
            class_id VARCHAR(50),
            class_code VARCHAR(20),
            success BIT,
            message NVARCHAR(500)
        );
        
        -- Parse comma-separated class IDs
        DECLARE @ClassId VARCHAR(50);
        DECLARE @Pos INT;
        DECLARE @ClassIdList NVARCHAR(MAX) = @ClassIds + ',';
        
        WHILE LEN(@ClassIdList) > 0
        BEGIN
            SET @Pos = CHARINDEX(',', @ClassIdList);
            SET @ClassId = LTRIM(RTRIM(SUBSTRING(@ClassIdList, 1, @Pos - 1)));
            SET @ClassIdList = SUBSTRING(@ClassIdList, @Pos + 1, LEN(@ClassIdList));
            
            IF LEN(@ClassId) > 0
            BEGIN
                BEGIN TRY
                    -- Generate enrollment ID
                    DECLARE @EnrollmentId VARCHAR(50) = 'ENR-' + REPLACE(CONVERT(VARCHAR(36), NEWID()), '-', '');
                    
                    -- Try to enroll
                    EXEC sp_CreateEnrollment 
                        @EnrollmentId = @EnrollmentId,
                        @StudentId = @StudentId,
                        @ClassId = @ClassId,
                        @Notes = NULL,
                        @CreatedBy = @CreatedBy;
                    
                    SET @SuccessCount = @SuccessCount + 1;
                    
                    INSERT INTO @Results
                    SELECT @ClassId, class_code, 1, N'Thành công'
                    FROM classes WHERE class_id = @ClassId;
                    
                END TRY
                BEGIN CATCH
                    SET @ErrorCount = @ErrorCount + 1;
                    
                    INSERT INTO @Results
                    SELECT @ClassId, ISNULL(class_code, @ClassId), 0, ERROR_MESSAGE()
                    FROM classes WHERE class_id = @ClassId;
                END CATCH
            END
        END
        
        -- Return summary
        SELECT @SuccessCount AS success_count, @ErrorCount AS error_count;
        SELECT * FROM @Results;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT 'Created: sp_BulkEnrollment';
GO

-- =============================================
-- SP 6: sp_GetEnrollmentsByStudent
-- Description: Get all enrollments for a student
-- =============================================

IF OBJECT_ID('sp_GetEnrollmentsByStudent', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetEnrollmentsByStudent;
GO

CREATE PROCEDURE sp_GetEnrollmentsByStudent
    @StudentId VARCHAR(50),
    @AcademicYearId VARCHAR(50) = NULL,
    @Semester INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        SELECT 
            e.enrollment_id,
            e.student_id,
            e.class_id,
            c.class_code,
            c.class_name,
            c.subject_id,
            s.subject_name,
            s.subject_code,
            s.credits,
            c.lecturer_id,
            l.full_name AS lecturer_name,
            c.schedule,
            c.room,
            c.semester,
            c.academic_year_id,
            ay.year_name,
            e.enrollment_date,
            e.enrollment_status,
            e.drop_deadline,
            e.notes,
            CASE 
                WHEN e.drop_deadline IS NOT NULL AND GETDATE() <= e.drop_deadline THEN 1
                ELSE 0
            END AS can_drop
        FROM enrollments e
        INNER JOIN classes c ON e.class_id = c.class_id
        INNER JOIN subjects s ON c.subject_id = s.subject_id
        LEFT JOIN lecturers l ON c.lecturer_id = l.lecturer_id
        LEFT JOIN academic_years ay ON c.academic_year_id = ay.academic_year_id
        WHERE e.student_id = @StudentId
        AND e.deleted_at IS NULL
        AND (@AcademicYearId IS NULL OR c.academic_year_id = @AcademicYearId)
        AND (@Semester IS NULL OR c.semester = @Semester)
        ORDER BY c.semester, s.subject_name;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT 'Created: sp_GetEnrollmentsByStudent';
GO

-- =============================================
-- SP 7: sp_GetEnrollmentsByClass
-- Description: Get all enrollments for a class
-- =============================================

IF OBJECT_ID('sp_GetEnrollmentsByClass', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetEnrollmentsByClass;
GO

CREATE PROCEDURE sp_GetEnrollmentsByClass
    @ClassId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        SELECT 
            e.enrollment_id,
            e.student_id,
            s.student_code,
            s.full_name AS student_name,
            s.email,
            s.phone_number,
            s.admin_class_id,
            ac.class_code AS admin_class_code,
            e.enrollment_date,
            e.enrollment_status,
            e.notes
        FROM enrollments e
        INNER JOIN students s ON e.student_id = s.student_id
        LEFT JOIN administrative_classes ac ON s.admin_class_id = ac.admin_class_id
        WHERE e.class_id = @ClassId
        AND e.deleted_at IS NULL
        AND e.enrollment_status IN ('PENDING', 'APPROVED')
        ORDER BY s.student_code;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT 'Created: sp_GetEnrollmentsByClass';
GO

-- =============================================
-- SP 8: sp_GetStudentSchedule
-- Description: Get student's schedule (timetable)
-- =============================================

IF OBJECT_ID('sp_GetStudentSchedule', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetStudentSchedule;
GO

CREATE PROCEDURE sp_GetStudentSchedule
    @StudentId VARCHAR(50),
    @Semester INT,
    @AcademicYearId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        SELECT 
            c.class_id,
            c.class_code,
            c.class_name,
            s.subject_name,
            s.subject_code,
            s.credits,
            l.full_name AS lecturer_name,
            c.schedule,
            c.room
        FROM enrollments e
        INNER JOIN classes c ON e.class_id = c.class_id
        INNER JOIN subjects s ON c.subject_id = s.subject_id
        LEFT JOIN lecturers l ON c.lecturer_id = l.lecturer_id
        WHERE e.student_id = @StudentId
        AND c.semester = @Semester
        AND c.academic_year_id = @AcademicYearId
        AND e.enrollment_status = 'APPROVED'
        AND e.deleted_at IS NULL
        ORDER BY c.schedule;
        
        -- Summary
        SELECT 
            COUNT(*) AS total_classes,
            SUM(s.credits) AS total_credits
        FROM enrollments e
        INNER JOIN classes c ON e.class_id = c.class_id
        INNER JOIN subjects s ON c.subject_id = s.subject_id
        WHERE e.student_id = @StudentId
        AND c.semester = @Semester
        AND c.academic_year_id = @AcademicYearId
        AND e.enrollment_status = 'APPROVED'
        AND e.deleted_at IS NULL;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT 'Created: sp_GetStudentSchedule';
GO

-- =============================================
-- SP 9: sp_CheckScheduleConflict
-- Description: Check if a class conflicts with student's schedule
-- =============================================

IF OBJECT_ID('sp_CheckScheduleConflict', 'P') IS NOT NULL
    DROP PROCEDURE sp_CheckScheduleConflict;
GO

CREATE PROCEDURE sp_CheckScheduleConflict
    @StudentId VARCHAR(50),
    @NewClassId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        DECLARE @NewSchedule NVARCHAR(500);
        DECLARE @HasConflict BIT = 0;
        DECLARE @ConflictDetails NVARCHAR(MAX) = NULL;
        
        -- Get new class schedule
        SELECT @NewSchedule = schedule
        FROM classes
        WHERE class_id = @NewClassId;
        
        -- Check for conflicts (simple string comparison)
        IF EXISTS (
            SELECT 1 
            FROM enrollments e
            INNER JOIN classes c ON e.class_id = c.class_id
            WHERE e.student_id = @StudentId
            AND e.enrollment_status = 'APPROVED'
            AND e.deleted_at IS NULL
            AND c.schedule = @NewSchedule
        )
        BEGIN
            SET @HasConflict = 1;
            
            SELECT @ConflictDetails = STRING_AGG(c.class_code + ' (' + c.schedule + ')', ', ')
            FROM enrollments e
            INNER JOIN classes c ON e.class_id = c.class_id
            WHERE e.student_id = @StudentId
            AND e.enrollment_status = 'APPROVED'
            AND e.deleted_at IS NULL
            AND c.schedule = @NewSchedule;
        END
        
        SELECT 
            @HasConflict AS has_conflict,
            @ConflictDetails AS conflict_details,
            @NewSchedule AS new_class_schedule;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT 'Created: sp_CheckScheduleConflict';
GO

-- =============================================
-- SP 10: sp_GetClassRoster
-- Description: Get class roster for lecturer
-- =============================================

IF OBJECT_ID('sp_GetClassRoster', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetClassRoster;
GO

CREATE PROCEDURE sp_GetClassRoster
    @ClassId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Class info
        SELECT 
            c.class_id,
            c.class_code,
            c.class_name,
            s.subject_name,
            l.full_name AS lecturer_name,
            c.schedule,
            c.room,
            c.max_students,
            c.current_enrollment
        FROM classes c
        INNER JOIN subjects s ON c.subject_id = s.subject_id
        LEFT JOIN lecturers l ON c.lecturer_id = l.lecturer_id
        WHERE c.class_id = @ClassId;
        
        -- Student roster
        SELECT 
            ROW_NUMBER() OVER (ORDER BY st.student_code) AS stt,
            st.student_id,
            st.student_code,
            st.full_name,
            st.email,
            st.phone_number,
            ac.class_code AS admin_class_code,
            ac.class_name AS admin_class_name,
            e.enrollment_date
        FROM enrollments e
        INNER JOIN students st ON e.student_id = st.student_id
        LEFT JOIN administrative_classes ac ON st.admin_class_id = ac.admin_class_id
        WHERE e.class_id = @ClassId
        AND e.enrollment_status = 'APPROVED'
        AND e.deleted_at IS NULL
        ORDER BY st.student_code;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT 'Created: sp_GetClassRoster';
GO

-- =============================================
-- SP 11: sp_UpdateEnrollmentStatus
-- Description: Update enrollment status (Admin only)
-- =============================================

IF OBJECT_ID('sp_UpdateEnrollmentStatus', 'P') IS NOT NULL
    DROP PROCEDURE sp_UpdateEnrollmentStatus;
GO

CREATE PROCEDURE sp_UpdateEnrollmentStatus
    @EnrollmentId VARCHAR(50),
    @NewStatus NVARCHAR(20),
    @UpdatedBy VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate status
        IF @NewStatus NOT IN ('PENDING', 'APPROVED', 'DROPPED', 'WITHDRAWN')
        BEGIN
            THROW 50025, N'Trạng thái không hợp lệ', 1;
        END
        
        -- Check if enrollment exists
        IF NOT EXISTS (SELECT 1 FROM enrollments WHERE enrollment_id = @EnrollmentId AND deleted_at IS NULL)
        BEGIN
            THROW 50022, N'Không tìm thấy đăng ký', 1;
        END
        
        -- Get old status
        DECLARE @OldStatus NVARCHAR(20), @ClassId VARCHAR(50);
        SELECT @OldStatus = enrollment_status, @ClassId = class_id
        FROM enrollments
        WHERE enrollment_id = @EnrollmentId;
        
        -- Update status
        UPDATE enrollments
        SET enrollment_status = @NewStatus
        WHERE enrollment_id = @EnrollmentId;
        
        -- Adjust class enrollment count
        IF @OldStatus = 'APPROVED' AND @NewStatus != 'APPROVED'
        BEGIN
            UPDATE classes SET current_enrollment = current_enrollment - 1
            WHERE class_id = @ClassId;
        END
        ELSE IF @OldStatus != 'APPROVED' AND @NewStatus = 'APPROVED'
        BEGIN
            UPDATE classes SET current_enrollment = current_enrollment + 1
            WHERE class_id = @ClassId;
        END
        
        COMMIT TRANSACTION;
        
        SELECT 1 AS Success, N'Cập nhật trạng thái thành công' AS Message;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT 'Created: sp_UpdateEnrollmentStatus';
GO

-- =============================================
-- SP 12: sp_GetEnrollmentStatistics
-- Description: Get enrollment statistics for admin dashboard
-- =============================================

IF OBJECT_ID('sp_GetEnrollmentStatistics', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetEnrollmentStatistics;
GO

CREATE PROCEDURE sp_GetEnrollmentStatistics
    @AcademicYearId VARCHAR(50),
    @Semester INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Overall statistics
        SELECT 
            COUNT(DISTINCT c.class_id) AS total_classes,
            SUM(c.max_students) AS total_capacity,
            SUM(c.current_enrollment) AS total_enrolled,
            SUM(c.max_students - c.current_enrollment) AS available_slots,
            COUNT(DISTINCT e.student_id) AS unique_students,
            SUM(CASE WHEN c.current_enrollment >= c.max_students THEN 1 ELSE 0 END) AS full_classes,
            CAST(AVG(CAST(c.current_enrollment AS FLOAT) / NULLIF(c.max_students, 0) * 100) AS DECIMAL(5,2)) AS avg_fill_rate
        FROM classes c
        LEFT JOIN enrollments e ON c.class_id = e.class_id 
            AND e.enrollment_status = 'APPROVED' 
            AND e.deleted_at IS NULL
        WHERE c.academic_year_id = @AcademicYearId
        AND c.semester = @Semester
        AND c.deleted_at IS NULL;
        
        -- By subject
        SELECT 
            s.subject_id,
            s.subject_name,
            s.subject_code,
            COUNT(c.class_id) AS class_count,
            SUM(c.current_enrollment) AS enrolled_students,
            SUM(c.max_students) AS max_capacity
        FROM subjects s
        INNER JOIN classes c ON s.subject_id = c.subject_id
        WHERE c.academic_year_id = @AcademicYearId
        AND c.semester = @Semester
        AND c.deleted_at IS NULL
        GROUP BY s.subject_id, s.subject_name, s.subject_code
        ORDER BY enrolled_students DESC;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT 'Created: sp_GetEnrollmentStatistics';
GO

-- =============================================
-- VERIFICATION
-- =============================================

PRINT '';
PRINT '========================================';
PRINT 'VERIFICATION RESULTS';
PRINT '========================================';

DECLARE @SPCount INT;
SELECT @SPCount = COUNT(*)
FROM sys.procedures
WHERE name IN (
    'sp_GetAvailableClassesForStudent',
    'sp_CheckEnrollmentEligibility',
    'sp_CreateEnrollment',
    'sp_DropEnrollment',
    'sp_BulkEnrollment',
    'sp_GetEnrollmentsByStudent',
    'sp_GetEnrollmentsByClass',
    'sp_GetStudentSchedule',
    'sp_CheckScheduleConflict',
    'sp_GetClassRoster',
    'sp_UpdateEnrollmentStatus',
    'sp_GetEnrollmentStatistics'
);

PRINT 'Stored Procedures created: ' + CAST(@SPCount AS VARCHAR(10)) + '/12';

IF @SPCount = 12
    PRINT '✓ All Enrollment SPs created successfully'
ELSE
    PRINT '✗ Some SPs missing';

PRINT '';
PRINT '========================================';
PRINT 'Completed: 13_SP_Enrollments.sql';
PRINT '========================================';
GO

-- =============================================
-- File: 14_SP_Prerequisites.sql
-- Description: Stored Procedures for Subject Prerequisites Management
-- Author: Education Management System
-- Created Date: 2025-10-30
-- Total SPs: 5
-- =============================================

USE EducationManagement;
GO

PRINT '========================================';
PRINT 'Starting: 14_SP_Prerequisites.sql';
PRINT 'Creating 5 Stored Procedures for Prerequisites';
PRINT '========================================';
GO

-- =============================================
-- SP 1: sp_GetPrerequisitesBySubject
-- Description: Get all prerequisites for a subject
-- =============================================

IF OBJECT_ID('sp_GetPrerequisitesBySubject', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetPrerequisitesBySubject;
GO

CREATE PROCEDURE sp_GetPrerequisitesBySubject
    @SubjectId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        SELECT 
            sp.prerequisite_id,
            sp.subject_id,
            s1.subject_name AS subject_name,
            s1.subject_code AS subject_code,
            sp.prerequisite_subject_id,
            s2.subject_name AS prerequisite_name,
            s2.subject_code AS prerequisite_code,
            sp.minimum_grade,
            sp.is_required,
            sp.description,
            sp.created_at,
            sp.created_by
        FROM subject_prerequisites sp
        INNER JOIN subjects s1 ON sp.subject_id = s1.subject_id
        INNER JOIN subjects s2 ON sp.prerequisite_subject_id = s2.subject_id
        WHERE sp.subject_id = @SubjectId
        AND sp.is_active = 1
        AND sp.deleted_at IS NULL
        ORDER BY sp.is_required DESC, s2.subject_name;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT 'Created: sp_GetPrerequisitesBySubject';
GO

-- =============================================
-- SP 2: sp_CreatePrerequisite
-- Description: Create a prerequisite relationship
-- =============================================

IF OBJECT_ID('sp_CreatePrerequisite', 'P') IS NOT NULL
    DROP PROCEDURE sp_CreatePrerequisite;
GO

CREATE PROCEDURE sp_CreatePrerequisite
    @PrerequisiteId VARCHAR(50),
    @SubjectId VARCHAR(50),
    @PrerequisiteSubjectId VARCHAR(50),
    @MinimumGrade DECIMAL(4,2) = 4.0,
    @IsRequired BIT = 1,
    @Description NVARCHAR(500) = NULL,
    @CreatedBy VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate: Subject cannot be prerequisite of itself
        IF @SubjectId = @PrerequisiteSubjectId
        BEGIN
            THROW 50026, N'Môn học không thể là điều kiện tiên quyết của chính nó', 1;
        END
        
        -- Validate: Both subjects exist
        IF NOT EXISTS (SELECT 1 FROM subjects WHERE subject_id = @SubjectId AND deleted_at IS NULL)
        BEGIN
            THROW 50027, N'Môn học không tồn tại', 1;
        END
        
        IF NOT EXISTS (SELECT 1 FROM subjects WHERE subject_id = @PrerequisiteSubjectId AND deleted_at IS NULL)
        BEGIN
            THROW 50028, N'Môn học điều kiện tiên quyết không tồn tại', 1;
        END
        
        -- Validate: No duplicate prerequisite
        IF EXISTS (
            SELECT 1 FROM subject_prerequisites
            WHERE subject_id = @SubjectId
            AND prerequisite_subject_id = @PrerequisiteSubjectId
            AND deleted_at IS NULL
        )
        BEGIN
            THROW 50029, N'Điều kiện tiên quyết đã tồn tại', 1;
        END
        
        -- Validate: Minimum grade is valid (0-10)
        IF @MinimumGrade < 0 OR @MinimumGrade > 10
        BEGIN
            THROW 50030, N'Điểm tối thiểu phải từ 0 đến 10', 1;
        END
        
        -- Insert prerequisite
        INSERT INTO subject_prerequisites (
            prerequisite_id,
            subject_id,
            prerequisite_subject_id,
            minimum_grade,
            is_required,
            description,
            is_active,
            created_at,
            created_by
        )
        VALUES (
            @PrerequisiteId,
            @SubjectId,
            @PrerequisiteSubjectId,
            @MinimumGrade,
            @IsRequired,
            @Description,
            1,
            GETDATE(),
            @CreatedBy
        );
        
        COMMIT TRANSACTION;
        
        -- Return created prerequisite
        EXEC sp_GetPrerequisitesBySubject @SubjectId;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT 'Created: sp_CreatePrerequisite';
GO

-- =============================================
-- SP 3: sp_DeletePrerequisite
-- Description: Delete a prerequisite
-- =============================================

IF OBJECT_ID('sp_DeletePrerequisite', 'P') IS NOT NULL
    DROP PROCEDURE sp_DeletePrerequisite;
GO

CREATE PROCEDURE sp_DeletePrerequisite
    @PrerequisiteId VARCHAR(50),
    @DeletedBy VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if prerequisite exists
        IF NOT EXISTS (
            SELECT 1 FROM subject_prerequisites 
            WHERE prerequisite_id = @PrerequisiteId 
            AND deleted_at IS NULL
        )
        BEGIN
            THROW 50031, N'Không tìm thấy điều kiện tiên quyết', 1;
        END
        
        -- Soft delete
        UPDATE subject_prerequisites
        SET 
            is_active = 0,
            deleted_at = GETDATE(),
            deleted_by = @DeletedBy
        WHERE prerequisite_id = @PrerequisiteId;
        
        COMMIT TRANSACTION;
        
        SELECT 1 AS Success, N'Xóa điều kiện tiên quyết thành công' AS Message;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT 'Created: sp_DeletePrerequisite';
GO

-- =============================================
-- SP 4: sp_CheckStudentPrerequisites
-- Description: Check if student meets prerequisites for a subject
-- =============================================

IF OBJECT_ID('sp_CheckStudentPrerequisites', 'P') IS NOT NULL
    DROP PROCEDURE sp_CheckStudentPrerequisites;
GO

CREATE PROCEDURE sp_CheckStudentPrerequisites
    @StudentId VARCHAR(50),
    @SubjectId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Get all prerequisites for the subject
        DECLARE @Prerequisites TABLE (
            prerequisite_subject_id VARCHAR(50),
            prerequisite_name NVARCHAR(200),
            minimum_grade DECIMAL(4,2),
            is_required BIT,
            student_grade DECIMAL(4,2),
            is_met BIT
        );
        
        INSERT INTO @Prerequisites
        SELECT 
            sp.prerequisite_subject_id,
            s.subject_name,
            sp.minimum_grade,
            sp.is_required,
            ISNULL(g.final_grade, 0) AS student_grade,
            CASE 
                WHEN g.final_grade >= sp.minimum_grade THEN 1
                WHEN g.final_grade IS NULL AND sp.is_required = 0 THEN 1
                ELSE 0
            END AS is_met
        FROM subject_prerequisites sp
        INNER JOIN subjects s ON sp.prerequisite_subject_id = s.subject_id
        LEFT JOIN (
            -- Get student's best grade for each subject
            SELECT 
                student_id,
                subject_id,
                MAX(final_grade) AS final_grade
            FROM grades
            WHERE student_id = @StudentId
            AND deleted_at IS NULL
            GROUP BY student_id, subject_id
        ) g ON sp.prerequisite_subject_id = g.subject_id
        WHERE sp.subject_id = @SubjectId
        AND sp.is_active = 1
        AND sp.deleted_at IS NULL;
        
        -- Check if all required prerequisites are met
        DECLARE @AllMet BIT = 1;
        DECLARE @MissingPrerequisites NVARCHAR(MAX) = NULL;
        
        IF EXISTS (
            SELECT 1 FROM @Prerequisites
            WHERE is_required = 1 AND is_met = 0
        )
        BEGIN
            SET @AllMet = 0;
            
            SELECT @MissingPrerequisites = STRING_AGG(
                prerequisite_name + 
                CASE 
                    WHEN student_grade = 0 THEN N' (chưa học)'
                    ELSE N' (điểm ' + CAST(student_grade AS NVARCHAR(10)) + N' < ' + CAST(minimum_grade AS NVARCHAR(10)) + N')'
                END,
                ', '
            )
            FROM @Prerequisites
            WHERE is_required = 1 AND is_met = 0;
        END
        
        -- Return summary
        SELECT 
            @AllMet AS all_prerequisites_met,
            @MissingPrerequisites AS missing_prerequisites,
            @StudentId AS student_id,
            @SubjectId AS subject_id;
        
        -- Return details
        SELECT * FROM @Prerequisites ORDER BY is_required DESC, prerequisite_name;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT 'Created: sp_CheckStudentPrerequisites';
GO

-- =============================================
-- SP 5: sp_GetSubjectsWithPrerequisites
-- Description: Get all subjects that have prerequisites
-- =============================================

IF OBJECT_ID('sp_GetSubjectsWithPrerequisites', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetSubjectsWithPrerequisites;
GO

CREATE PROCEDURE sp_GetSubjectsWithPrerequisites
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        SELECT 
            s.subject_id,
            s.subject_code,
            s.subject_name,
            s.credits,
            COUNT(sp.prerequisite_id) AS prerequisite_count,
            STRING_AGG(s2.subject_code, ', ') AS prerequisite_codes
        FROM subjects s
        INNER JOIN subject_prerequisites sp ON s.subject_id = sp.subject_id
        INNER JOIN subjects s2 ON sp.prerequisite_subject_id = s2.subject_id
        WHERE sp.is_active = 1
        AND sp.deleted_at IS NULL
        AND s.deleted_at IS NULL
        GROUP BY s.subject_id, s.subject_code, s.subject_name, s.credits
        ORDER BY s.subject_name;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT 'Created: sp_GetSubjectsWithPrerequisites';
GO

-- =============================================
-- VERIFICATION
-- =============================================

PRINT '';
PRINT '========================================';
PRINT 'VERIFICATION RESULTS';
PRINT '========================================';

DECLARE @SPCount INT;
SELECT @SPCount = COUNT(*)
FROM sys.procedures
WHERE name IN (
    'sp_GetPrerequisitesBySubject',
    'sp_CreatePrerequisite',
    'sp_DeletePrerequisite',
    'sp_CheckStudentPrerequisites',
    'sp_GetSubjectsWithPrerequisites'
);

PRINT 'Stored Procedures created: ' + CAST(@SPCount AS VARCHAR(10)) + '/5';

IF @SPCount = 5
    PRINT '✓ All Prerequisites SPs created successfully'
ELSE
    PRINT '✗ Some SPs missing';

PRINT '';
PRINT '========================================';
PRINT 'Completed: 14_SP_Prerequisites.sql';
PRINT '========================================';
GO

PRINT '🔧 Starting Academic Year Automation Setup...';
GO

-- ===========================================
-- STEP 1: BỎ HỌC KỲ HÈ - CHỈ GIỮ HK1 VÀ HK2
-- ===========================================
PRINT '📋 Step 1: Removing Summer Semester (Semester 3)...';
GO

-- Update existing registration_periods constraint
IF EXISTS (
    SELECT * FROM sys.check_constraints 
    WHERE name LIKE '%semester%' AND parent_object_id = OBJECT_ID('registration_periods')
)
BEGIN
    DECLARE @ConstraintName NVARCHAR(255);
    SELECT @ConstraintName = name 
    FROM sys.check_constraints 
    WHERE parent_object_id = OBJECT_ID('registration_periods') 
        AND definition LIKE '%semester%';
    
    IF @ConstraintName IS NOT NULL
    BEGIN
        EXEC('ALTER TABLE registration_periods DROP CONSTRAINT ' + @ConstraintName);
        PRINT '   ✅ Dropped old semester constraint on registration_periods';
    END
END

-- Add new constraint: Only semester 1 and 2
ALTER TABLE registration_periods 
ADD CONSTRAINT CK_RegistrationPeriod_Semester CHECK (semester IN (1, 2));
PRINT '   ✅ Added new constraint: Semester can only be 1 or 2';
GO

-- Update GPA constraint if exists
IF EXISTS (
    SELECT * FROM sys.check_constraints 
    WHERE name LIKE '%semester%' AND parent_object_id = OBJECT_ID('gpas')
)
BEGIN
    DECLARE @GpaConstraintName NVARCHAR(255);
    SELECT @GpaConstraintName = name 
    FROM sys.check_constraints 
    WHERE parent_object_id = OBJECT_ID('gpas') 
        AND definition LIKE '%semester%';
    
    IF @GpaConstraintName IS NOT NULL
    BEGIN
        EXEC('ALTER TABLE gpas DROP CONSTRAINT ' + @GpaConstraintName);
        PRINT '   ✅ Dropped old semester constraint on gpas';
    END
END

-- GPA: NULL = cả năm, 1 = HK1, 2 = HK2
ALTER TABLE gpas 
ADD CONSTRAINT CK_GPA_Semester CHECK (semester IS NULL OR semester IN (1, 2));
PRINT '   ✅ Added new constraint on gpas: NULL (yearly) or 1, 2';
GO

-- ===========================================
-- STEP 2: TẠO BẢNG SCHOOL_YEARS (NĂM HỌC)
-- ===========================================
PRINT '📋 Step 2: Creating school_years table...';
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'school_years')
BEGIN
    CREATE TABLE dbo.school_years (
        school_year_id      VARCHAR(50) PRIMARY KEY,
        
        -- Basic Info
        year_code           NVARCHAR(20) NOT NULL UNIQUE,     -- "2024-2025"
        year_name           NVARCHAR(100) NOT NULL,           -- "Năm học 2024-2025"
        
        -- Link to Academic Year (Cohort)
        academic_year_id    VARCHAR(50) NULL FOREIGN KEY REFERENCES dbo.academic_years(academic_year_id),
        
        -- Duration
        start_date          DATE NOT NULL,                     -- 01-Sep-2024
        end_date            DATE NOT NULL,                     -- 30-Jun-2025
        
        -- Semester dates (Auto-calculated)
        semester1_start     DATE NULL,                         -- 01-Sep-2024
        semester1_end       DATE NULL,                         -- 31-Jan-2025
        semester2_start     DATE NULL,                         -- 01-Feb-2025
        semester2_end       DATE NULL,                         -- 30-Jun-2025
        
        -- Status
        is_active           BIT NOT NULL DEFAULT 0,            -- Only 1 can be active
        current_semester    INT NULL CHECK (current_semester IN (1, 2)),
        
        -- Audit fields
        created_at          DATETIME NOT NULL DEFAULT GETDATE(),
        created_by          VARCHAR(50) NULL,
        updated_at          DATETIME NULL,
        updated_by          VARCHAR(50) NULL,
        deleted_at          DATETIME NULL,
        deleted_by          VARCHAR(50) NULL,
        
        -- Constraints
        CONSTRAINT CK_SchoolYear_Dates CHECK (end_date > start_date),
        CONSTRAINT CK_SchoolYear_Semester1 CHECK (semester1_end > semester1_start),
        CONSTRAINT CK_SchoolYear_Semester2 CHECK (semester2_end > semester2_start)
    );
    
    -- Index for performance
    CREATE INDEX IX_SchoolYear_Active ON school_years(is_active) WHERE is_active = 1;
    CREATE INDEX IX_SchoolYear_YearCode ON school_years(year_code);
    CREATE INDEX IX_SchoolYear_AcademicYear ON school_years(academic_year_id);
    
    PRINT '   ✅ Table school_years created successfully';
END
ELSE
BEGIN
    PRINT '   ⚠️  Table school_years already exists';
END
GO

-- ===========================================
-- STEP 3: UPDATE ACADEMIC_YEARS (NIÊN KHÓA)
-- ===========================================
PRINT '📋 Step 3: Updating academic_years structure for Cohort (4 years)...';
GO

-- Add new columns for cohort management
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('academic_years') AND name = 'cohort_code')
BEGIN
    ALTER TABLE academic_years ADD cohort_code NVARCHAR(10) NULL;
    PRINT '   ✅ Added column: cohort_code (K21, K22, K23, K24)';
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('academic_years') AND name = 'duration_years')
BEGIN
    ALTER TABLE academic_years ADD duration_years INT NULL DEFAULT 4;
    PRINT '   ✅ Added column: duration_years (default 4 for undergraduate)';
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('academic_years') AND name = 'description')
BEGIN
    ALTER TABLE academic_years ADD description NVARCHAR(500) NULL;
    PRINT '   ✅ Added column: description';
END

-- Update existing data
UPDATE academic_years 
SET 
    cohort_code = 'K' + CAST(start_year % 100 AS VARCHAR(2)),
    duration_years = 4,
    end_year = start_year + 4,
    description = N'Niên khóa ' + CAST(start_year AS NVARCHAR) + N'-' + CAST(start_year + 4 AS NVARCHAR)
WHERE cohort_code IS NULL;

PRINT '   ✅ Updated existing academic_years with cohort info';
GO

-- ===========================================
-- STEP 4: ADD SCHOOL_YEAR_ID TO CLASSES
-- ===========================================
PRINT '📋 Step 4: Adding school_year_id to classes table...';
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('classes') AND name = 'school_year_id')
BEGIN
    ALTER TABLE classes ADD school_year_id VARCHAR(50) NULL;
    -- Will set FK after migrating data
    PRINT '   ✅ Added column: school_year_id to classes';
END
GO

-- ===========================================
-- STORED PROCEDURES
-- ===========================================

-- ===========================================
-- SP 1: AUTO CREATE COHORT (NIÊN KHÓA)
-- ===========================================
PRINT '📋 Creating SP: sp_AutoCreateCohort...';
GO

IF OBJECT_ID('sp_AutoCreateCohort', 'P') IS NOT NULL 
    DROP PROCEDURE sp_AutoCreateCohort;
GO

CREATE PROCEDURE sp_AutoCreateCohort
    @StartYear INT,                    -- 2025
    @DurationYears INT = 4,            -- Mặc định 4 năm (đại học)
    @CreatedBy VARCHAR(50) = 'system'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Validate
        IF @StartYear < 2020 OR @StartYear > 2050
            THROW 50001, N'❌ Năm bắt đầu không hợp lệ (2020-2050)', 1;
        
        DECLARE @CohortId VARCHAR(50) = 'AY' + CAST(@StartYear AS VARCHAR);
        DECLARE @CohortCode NVARCHAR(10) = 'K' + RIGHT(CAST(@StartYear AS VARCHAR), 2);
        DECLARE @EndYear INT = @StartYear + @DurationYears;
        DECLARE @YearName NVARCHAR(50) = CAST(@StartYear AS NVARCHAR) + N'-' + CAST(@EndYear AS NVARCHAR);
        DECLARE @Description NVARCHAR(500) = N'Niên khóa ' + @CohortCode + N' (' + CAST(@StartYear AS NVARCHAR) + N'-' + CAST(@EndYear AS NVARCHAR) + N')';
        
        -- Check exists
        IF EXISTS (SELECT 1 FROM academic_years WHERE academic_year_id = @CohortId)
            THROW 50002, N'❌ Niên khóa đã tồn tại!', 1;
        
        -- Insert cohort
        INSERT INTO academic_years (
            academic_year_id, year_name, start_year, end_year, 
            cohort_code, duration_years, description,
            is_active, created_at, created_by
        )
        VALUES (
            @CohortId, @YearName, @StartYear, @EndYear,
            @CohortCode, @DurationYears, @Description,
            0, GETDATE(), @CreatedBy
        );
        
        -- Auto-create school years for this cohort
        DECLARE @i INT = 0;
        WHILE @i < @DurationYears
        BEGIN
            EXEC sp_AutoCreateSchoolYear 
                @StartYear = @StartYear + @i,
                @AcademicYearId = @CohortId,
                @CreatedBy = @CreatedBy;
            SET @i = @i + 1;
        END
        
        SELECT 
            'SUCCESS' AS Status,
            @CohortId AS CohortId,
            @CohortCode AS CohortCode,
            @YearName AS YearName,
            @DurationYears AS DurationYears,
            N'✅ Đã tạo niên khóa ' + @CohortCode + N' và ' + CAST(@DurationYears AS NVARCHAR) + N' năm học' AS Message;
            
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO
PRINT '   ✅ Created: sp_AutoCreateCohort';
GO

-- ===========================================
-- SP 2: AUTO CREATE SCHOOL YEAR (NĂM HỌC)
-- ===========================================
PRINT '📋 Creating SP: sp_AutoCreateSchoolYear...';
GO

IF OBJECT_ID('sp_AutoCreateSchoolYear', 'P') IS NOT NULL 
    DROP PROCEDURE sp_AutoCreateSchoolYear;
GO

CREATE PROCEDURE sp_AutoCreateSchoolYear
    @StartYear INT,                           -- 2024
    @AcademicYearId VARCHAR(50) = NULL,       -- Optional link to cohort
    @CreatedBy VARCHAR(50) = 'system'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @SchoolYearId VARCHAR(50) = 'SY' + CAST(@StartYear AS VARCHAR);
        DECLARE @YearCode NVARCHAR(20) = CAST(@StartYear AS NVARCHAR) + N'-' + CAST(@StartYear + 1 AS NVARCHAR);
        DECLARE @YearName NVARCHAR(100) = N'Năm học ' + @YearCode;
        
        -- Dates according to Vietnamese university calendar
        DECLARE @StartDate DATE = DATEFROMPARTS(@StartYear, 9, 1);      -- 01-Sep
        DECLARE @EndDate DATE = DATEFROMPARTS(@StartYear + 1, 6, 30);   -- 30-Jun
        DECLARE @Sem1Start DATE = DATEFROMPARTS(@StartYear, 9, 1);      -- 01-Sep
        DECLARE @Sem1End DATE = DATEFROMPARTS(@StartYear + 1, 1, 31);   -- 31-Jan
        DECLARE @Sem2Start DATE = DATEFROMPARTS(@StartYear + 1, 2, 1);  -- 01-Feb
        DECLARE @Sem2End DATE = DATEFROMPARTS(@StartYear + 1, 6, 30);   -- 30-Jun
        
        -- Check exists
        IF EXISTS (SELECT 1 FROM school_years WHERE school_year_id = @SchoolYearId)
        BEGIN
            PRINT '   ⚠️  School year ' + @YearCode + ' already exists';
            RETURN;
        END
        
        -- Insert school year
        INSERT INTO school_years (
            school_year_id, year_code, year_name, academic_year_id,
            start_date, end_date,
            semester1_start, semester1_end, semester2_start, semester2_end,
            is_active, current_semester,
            created_at, created_by
        )
        VALUES (
            @SchoolYearId, @YearCode, @YearName, @AcademicYearId,
            @StartDate, @EndDate,
            @Sem1Start, @Sem1End, @Sem2Start, @Sem2End,
            0, NULL,
            GETDATE(), @CreatedBy
        );
        
        PRINT '   ✅ Created school year: ' + @YearCode;
        
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO
PRINT '   ✅ Created: sp_AutoCreateSchoolYear';
GO

-- ===========================================
-- SP 3: GET CURRENT SCHOOL YEAR & SEMESTER
-- ===========================================
PRINT '📋 Creating SP: sp_GetCurrentSchoolYearAndSemester...';
GO

IF OBJECT_ID('sp_GetCurrentSchoolYearAndSemester', 'P') IS NOT NULL 
    DROP PROCEDURE sp_GetCurrentSchoolYearAndSemester;
GO

CREATE PROCEDURE sp_GetCurrentSchoolYearAndSemester
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Today DATE = CAST(GETDATE() AS DATE);
    DECLARE @SchoolYearId VARCHAR(50);
    DECLARE @CurrentSemester INT;
    
    -- Find school year containing today
    SELECT TOP 1
        @SchoolYearId = school_year_id,
        @CurrentSemester = CASE 
            WHEN @Today BETWEEN semester1_start AND semester1_end THEN 1
            WHEN @Today BETWEEN semester2_start AND semester2_end THEN 2
            ELSE NULL
        END
    FROM school_years
    WHERE @Today BETWEEN start_date AND end_date
        AND deleted_at IS NULL
    ORDER BY is_active DESC, created_at DESC;
    
    -- Return result
    SELECT 
        sy.school_year_id,
        sy.year_code,
        sy.year_name,
        sy.academic_year_id,
        ay.cohort_code,
        @CurrentSemester AS current_semester,
        CASE @CurrentSemester
            WHEN 1 THEN N'Học kỳ 1'
            WHEN 2 THEN N'Học kỳ 2'
            ELSE N'Ngoài học kỳ'
        END AS semester_name,
        sy.is_active,
        sy.start_date,
        sy.end_date,
        sy.semester1_start,
        sy.semester1_end,
        sy.semester2_start,
        sy.semester2_end
    FROM school_years sy
    LEFT JOIN academic_years ay ON sy.academic_year_id = ay.academic_year_id
    WHERE sy.school_year_id = @SchoolYearId;
END
GO
PRINT '   ✅ Created: sp_GetCurrentSchoolYearAndSemester';
GO

-- ===========================================
-- SP 4: AUTO TRANSITION SEMESTER
-- ===========================================
PRINT '📋 Creating SP: sp_AutoTransitionSemester...';
GO

IF OBJECT_ID('sp_AutoTransitionSemester', 'P') IS NOT NULL 
    DROP PROCEDURE sp_AutoTransitionSemester;
GO

CREATE PROCEDURE sp_AutoTransitionSemester
    @ExecutedBy VARCHAR(50) = 'system'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    BEGIN TRY
        DECLARE @Today DATE = CAST(GETDATE() AS DATE);
        DECLARE @SchoolYearId VARCHAR(50);
        DECLARE @CurrentSemester INT;
        DECLARE @NewSemester INT;
        
        -- Get current school year and semester
        SELECT TOP 1
            @SchoolYearId = school_year_id,
            @CurrentSemester = current_semester,
            @NewSemester = CASE 
                WHEN @Today BETWEEN semester1_start AND semester1_end THEN 1
                WHEN @Today BETWEEN semester2_start AND semester2_end THEN 2
                ELSE NULL
            END
        FROM school_years
        WHERE @Today BETWEEN start_date AND end_date
            AND deleted_at IS NULL
        ORDER BY is_active DESC;
        
        -- If semester changed, transition
        IF @NewSemester IS NOT NULL AND (@CurrentSemester IS NULL OR @CurrentSemester <> @NewSemester)
        BEGIN
            -- Calculate GPA for previous semester if exists
            IF @CurrentSemester IS NOT NULL
            BEGIN
                PRINT '   📊 Calculating GPA for Semester ' + CAST(@CurrentSemester AS VARCHAR) + '...';
                EXEC sp_CalculateAllStudentGPA 
                    @AcademicYearId = @SchoolYearId,
                    @Semester = @CurrentSemester,
                    @CreatedBy = @ExecutedBy;
            END
            
            -- Update current semester
            UPDATE school_years
            SET current_semester = @NewSemester,
                updated_at = GETDATE(),
                updated_by = @ExecutedBy
            WHERE school_year_id = @SchoolYearId;
            
            PRINT '   ✅ Transitioned to Semester ' + CAST(@NewSemester AS VARCHAR);
            
            -- Log transition
            INSERT INTO audit_logs (user_id, action, entity_type, entity_id, new_values, created_at)
            VALUES (
                @ExecutedBy, 
                'AUTO_TRANSITION_SEMESTER', 
                'school_years', 
                @SchoolYearId,
                CONCAT('{"semester":', @NewSemester, '}'),
                GETDATE()
            );
        END
        ELSE
        BEGIN
            PRINT '   ℹ️  No semester transition needed';
        END
        
        COMMIT TRANSACTION;
        
        SELECT 
            'SUCCESS' AS Status,
            @SchoolYearId AS SchoolYearId,
            @NewSemester AS CurrentSemester,
            N'✅ Đã kiểm tra và cập nhật học kỳ' AS Message;
            
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO
PRINT '   ✅ Created: sp_AutoTransitionSemester';
GO

-- ===========================================
-- SP 5: AUTO TRANSITION TO NEW SCHOOL YEAR
-- ===========================================
PRINT '📋 Creating SP: sp_AutoTransitionToNewSchoolYear...';
GO

IF OBJECT_ID('sp_AutoTransitionToNewSchoolYear', 'P') IS NOT NULL 
    DROP PROCEDURE sp_AutoTransitionToNewSchoolYear;
GO

CREATE PROCEDURE sp_AutoTransitionToNewSchoolYear
    @NewSchoolYearId VARCHAR(50),
    @ExecutedBy VARCHAR(50) = 'system'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Validate new school year exists
        IF NOT EXISTS (SELECT 1 FROM school_years WHERE school_year_id = @NewSchoolYearId AND deleted_at IS NULL)
            THROW 50001, N'❌ Năm học mới không tồn tại!', 1;
        
        -- Get old school year
        DECLARE @OldSchoolYearId VARCHAR(50);
        SELECT @OldSchoolYearId = school_year_id
        FROM school_years
        WHERE is_active = 1 AND deleted_at IS NULL;
        
        IF @OldSchoolYearId IS NOT NULL
        BEGIN
            -- Calculate GPA for entire old school year
            PRINT '   📊 Calculating yearly GPA for old school year...';
            EXEC sp_CalculateAllStudentGPA 
                @AcademicYearId = @OldSchoolYearId,
                @Semester = NULL,  -- NULL = yearly GPA
                @CreatedBy = @ExecutedBy;
            
            -- Deactivate old school year
            UPDATE school_years
            SET is_active = 0,
                updated_at = GETDATE(),
                updated_by = @ExecutedBy
            WHERE school_year_id = @OldSchoolYearId;
            
            PRINT '   ✅ Closed old school year: ' + @OldSchoolYearId;
        END
        
        -- Activate new school year
        UPDATE school_years
        SET is_active = 1,
            current_semester = 1,  -- Start with Semester 1
            updated_at = GETDATE(),
            updated_by = @ExecutedBy
        WHERE school_year_id = @NewSchoolYearId;
        
        PRINT '   ✅ Activated new school year: ' + @NewSchoolYearId;
        
        -- Log transition
        INSERT INTO audit_logs (user_id, action, entity_type, entity_id, old_values, new_values, created_at)
        VALUES (
            @ExecutedBy,
            'AUTO_TRANSITION_SCHOOL_YEAR',
            'school_years',
            @NewSchoolYearId,
            CONCAT('{"old_school_year":"', @OldSchoolYearId, '"}'),
            CONCAT('{"new_school_year":"', @NewSchoolYearId, '"}'),
            GETDATE()
        );
        
        COMMIT TRANSACTION;
        
        SELECT 
            'SUCCESS' AS Status,
            @OldSchoolYearId AS OldSchoolYearId,
            @NewSchoolYearId AS NewSchoolYearId,
            N'✅ Đã chuyển sang năm học mới' AS Message;
            
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO
PRINT '   ✅ Created: sp_AutoTransitionToNewSchoolYear';
GO

-- ===========================================
-- SUMMARY
-- ===========================================
PRINT '';
PRINT '╔════════════════════════════════════════════════╗';
PRINT '║   ✅ ACADEMIC YEAR AUTOMATION SETUP COMPLETE   ║';
PRINT '╚════════════════════════════════════════════════╝';
PRINT '';
PRINT '📊 Summary:';
PRINT '   ✅ Removed Summer Semester (only HK1 & HK2)';
PRINT '   ✅ Created school_years table';
PRINT '   ✅ Updated academic_years for cohort management';
PRINT '   ✅ Created 5 automation stored procedures:';
PRINT '      • sp_AutoCreateCohort';
PRINT '      • sp_AutoCreateSchoolYear';
PRINT '      • sp_GetCurrentSchoolYearAndSemester';
PRINT '      • sp_AutoTransitionSemester';
PRINT '      • sp_AutoTransitionToNewSchoolYear';
PRINT '';
PRINT '🎯 Next Steps:';
PRINT '   1. Run seed data to create sample cohorts';
PRINT '   2. Update C# models and services';
PRINT '   3. Set up background job for auto-transition';
PRINT '';
GO

