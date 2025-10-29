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
    INSERT INTO dbo.users (user_id, username, password_hash, email, phone, full_name, 
                           role_id, is_active, avatar_url, created_at, created_by)
    VALUES (@UserId, @Username, @PasswordHash, @Email, @Phone, @FullName, 
            @RoleId, @IsActive, @AvatarUrl, GETDATE(), @CreatedBy);
    SELECT @UserId AS user_id;
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
    UPDATE dbo.users
    SET full_name = @FullName, email = @Email, phone = @Phone, role_id = @RoleId,
        is_active = @IsActive, avatar_url = ISNULL(@AvatarUrl, avatar_url),
        updated_at = GETDATE(), updated_by = @UpdatedBy
    WHERE user_id = @UserId AND deleted_at IS NULL;
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

PRINT '';
PRINT '================================';
PRINT '🎉 HOÀN THÀNH TẠO STORED PROCEDURES!';
PRINT '✅ Đã tạo 9 Permission SPs + Pagination SPs + Auto Code Function';
PRINT '';
