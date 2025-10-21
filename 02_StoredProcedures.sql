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

IF OBJECT_ID('sp_ToggleUserStatus', 'P') IS NOT NULL DROP PROCEDURE sp_ToggleUserStatus;
GO
CREATE PROCEDURE sp_ToggleUserStatus
    @UserId VARCHAR(50),
    @UpdatedBy VARCHAR(50) = 'system'
AS
BEGIN
    UPDATE dbo.users
    SET is_active = CASE WHEN is_active = 1 THEN 0 ELSE 1 END,
        updated_at = GETDATE(), updated_by = @UpdatedBy
    WHERE user_id = @UserId;
    
    SELECT is_active FROM dbo.users WHERE user_id = @UserId;
END
GO

PRINT '✅ Users Management SPs created';
GO

-- ===========================================
-- 2. STUDENTS MANAGEMENT
-- ===========================================

IF OBJECT_ID('sp_GetAllStudents', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllStudents;
GO
CREATE PROCEDURE sp_GetAllStudents
    @Page INT = 1,
    @PageSize INT = 10,
    @Search NVARCHAR(255) = NULL,
    @MajorId VARCHAR(50) = NULL,
    @AcademicYearId VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Offset INT = (@Page - 1) * @PageSize;
    
    SELECT COUNT(*) as TotalCount
    FROM dbo.students s
    WHERE s.deleted_at IS NULL
        AND (@Search IS NULL OR s.student_code LIKE '%' + @Search + '%' 
             OR s.full_name LIKE '%' + @Search + '%')
        AND (@MajorId IS NULL OR s.major_id = @MajorId)
        AND (@AcademicYearId IS NULL OR s.academic_year_id = @AcademicYearId);
    
    SELECT s.student_id, s.student_code, s.full_name, s.date_of_birth, s.gender,
           s.email, s.phone, s.address, s.major_id, m.major_name,
           s.academic_year_id, ay.year_name, s.is_active,
           s.created_at, s.updated_at
    FROM dbo.students s
    LEFT JOIN dbo.majors m ON s.major_id = m.major_id
    LEFT JOIN dbo.academic_years ay ON s.academic_year_id = ay.academic_year_id
    WHERE s.deleted_at IS NULL
        AND (@Search IS NULL OR s.student_code LIKE '%' + @Search + '%' 
             OR s.full_name LIKE '%' + @Search + '%')
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
    SELECT s.*, m.major_name, ay.year_name
    FROM dbo.students s
    LEFT JOIN dbo.majors m ON s.major_id = m.major_id
    LEFT JOIN dbo.academic_years ay ON s.academic_year_id = ay.academic_year_id
    WHERE s.student_id = @StudentId AND s.deleted_at IS NULL;
END
GO

IF OBJECT_ID('sp_GetStudentByUserId', 'P') IS NOT NULL DROP PROCEDURE sp_GetStudentByUserId;
GO
CREATE PROCEDURE sp_GetStudentByUserId
    @UserId VARCHAR(50)
AS
BEGIN
    SELECT s.*, m.major_name, ay.year_name
    FROM dbo.students s
    LEFT JOIN dbo.majors m ON s.major_id = m.major_id
    LEFT JOIN dbo.academic_years ay ON s.academic_year_id = ay.academic_year_id
    WHERE s.user_id = @UserId AND s.deleted_at IS NULL;
END
GO

IF OBJECT_ID('sp_AddStudentFull', 'P') IS NOT NULL DROP PROCEDURE sp_AddStudentFull;
GO
CREATE PROCEDURE sp_AddStudentFull
    @StudentId VARCHAR(50),
    @StudentCode VARCHAR(20),
    @FullName NVARCHAR(150),
    @DateOfBirth DATE = NULL,
    @Gender NVARCHAR(10) = NULL,
    @Email VARCHAR(150) = NULL,
    @Phone VARCHAR(20) = NULL,
    @Address NVARCHAR(300) = NULL,
    @MajorId VARCHAR(50) = NULL,
    @AcademicYearId VARCHAR(50) = NULL,
    @AdvisorId VARCHAR(50) = NULL,
    @UserId VARCHAR(50) = NULL,
    @CreatedBy VARCHAR(50) = 'system'
AS
BEGIN
    INSERT INTO dbo.students (student_id, student_code, full_name, date_of_birth, gender,
                              email, phone, address, major_id, academic_year_id, advisor_id,
                              user_id, created_at, created_by)
    VALUES (@StudentId, @StudentCode, @FullName, @DateOfBirth, @Gender, @Email, @Phone,
            @Address, @MajorId, @AcademicYearId, @AdvisorId, @UserId, GETDATE(), @CreatedBy);
END
GO

IF OBJECT_ID('sp_UpdateStudentFull', 'P') IS NOT NULL DROP PROCEDURE sp_UpdateStudentFull;
GO
CREATE PROCEDURE sp_UpdateStudentFull
    @StudentId VARCHAR(50),
    @StudentCode VARCHAR(20),
    @FullName NVARCHAR(150),
    @DateOfBirth DATE = NULL,
    @Gender NVARCHAR(10) = NULL,
    @Email VARCHAR(150) = NULL,
    @Phone VARCHAR(20) = NULL,
    @Address NVARCHAR(300) = NULL,
    @MajorId VARCHAR(50) = NULL,
    @AcademicYearId VARCHAR(50) = NULL,
    @UpdatedBy VARCHAR(50) = 'system'
AS
BEGIN
    UPDATE dbo.students
    SET student_code = @StudentCode, full_name = @FullName, date_of_birth = @DateOfBirth,
        gender = @Gender, email = @Email, phone = @Phone, address = @Address,
        major_id = @MajorId, academic_year_id = @AcademicYearId,
        updated_at = GETDATE(), updated_by = @UpdatedBy
    WHERE student_id = @StudentId AND deleted_at IS NULL;
END
GO

IF OBJECT_ID('sp_DeleteStudentFull', 'P') IS NOT NULL DROP PROCEDURE sp_DeleteStudentFull;
GO
CREATE PROCEDURE sp_DeleteStudentFull
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
-- 3. LECTURERS MANAGEMENT
-- ===========================================

IF OBJECT_ID('sp_GetAllLecturers', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllLecturers;
GO
CREATE PROCEDURE sp_GetAllLecturers
AS
BEGIN
    SELECT l.*, d.department_name
    FROM dbo.lecturers l
    LEFT JOIN dbo.departments d ON l.department_id = d.department_id
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

IF OBJECT_ID('sp_GetLecturerByUserId', 'P') IS NOT NULL DROP PROCEDURE sp_GetLecturerByUserId;
GO
CREATE PROCEDURE sp_GetLecturerByUserId
    @UserId VARCHAR(50)
AS
BEGIN
    SELECT l.*, d.department_name
    FROM dbo.lecturers l
    LEFT JOIN dbo.departments d ON l.department_id = d.department_id
    WHERE l.user_id = @UserId AND l.deleted_at IS NULL;
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
-- 4. FACULTIES MANAGEMENT
-- ===========================================

IF OBJECT_ID('sp_GetAllFaculties', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllFaculties;
GO
CREATE PROCEDURE sp_GetAllFaculties
AS
BEGIN
    SELECT * FROM dbo.faculties
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
    @FacultyName NVARCHAR(150),
    @Description NVARCHAR(500) = NULL,
    @CreatedBy VARCHAR(50) = 'system'
AS
BEGIN
    INSERT INTO dbo.faculties (faculty_id, faculty_name, description, created_at, created_by)
    VALUES (@FacultyId, @FacultyName, @Description, GETDATE(), @CreatedBy);
END
GO

IF OBJECT_ID('sp_UpdateFaculty', 'P') IS NOT NULL DROP PROCEDURE sp_UpdateFaculty;
GO
CREATE PROCEDURE sp_UpdateFaculty
    @FacultyId VARCHAR(50),
    @FacultyName NVARCHAR(150),
    @Description NVARCHAR(500) = NULL,
    @UpdatedBy VARCHAR(50) = 'system'
AS
BEGIN
    UPDATE dbo.faculties
    SET faculty_name = @FacultyName, description = @Description,
        updated_at = GETDATE(), updated_by = @UpdatedBy
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
-- 5. DEPARTMENTS MANAGEMENT
-- ===========================================

IF OBJECT_ID('sp_GetAllDepartments', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllDepartments;
GO
CREATE PROCEDURE sp_GetAllDepartments
AS
BEGIN
    SELECT d.*, f.faculty_name
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
    @DepartmentName NVARCHAR(150),
    @FacultyId VARCHAR(50),
    @Description NVARCHAR(500) = NULL,
    @CreatedBy VARCHAR(50) = 'system'
AS
BEGIN
    INSERT INTO dbo.departments (department_id, department_name, faculty_id, description,
                                  created_at, created_by)
    VALUES (@DepartmentId, @DepartmentName, @FacultyId, @Description, GETDATE(), @CreatedBy);
END
GO

IF OBJECT_ID('sp_UpdateDepartment', 'P') IS NOT NULL DROP PROCEDURE sp_UpdateDepartment;
GO
CREATE PROCEDURE sp_UpdateDepartment
    @DepartmentId VARCHAR(50),
    @DepartmentName NVARCHAR(150),
    @FacultyId VARCHAR(50),
    @Description NVARCHAR(500) = NULL,
    @UpdatedBy VARCHAR(50) = 'system'
AS
BEGIN
    UPDATE dbo.departments
    SET department_name = @DepartmentName, faculty_id = @FacultyId, description = @Description,
        updated_at = GETDATE(), updated_by = @UpdatedBy
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
-- 6. MAJORS MANAGEMENT
-- ===========================================

IF OBJECT_ID('sp_GetAllMajors', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllMajors;
GO
CREATE PROCEDURE sp_GetAllMajors
AS
BEGIN
    SELECT m.*, f.faculty_name
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
-- 7. SUBJECTS MANAGEMENT
-- ===========================================

IF OBJECT_ID('sp_GetAllSubjects', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllSubjects;
GO
CREATE PROCEDURE sp_GetAllSubjects
AS
BEGIN
    SELECT s.*, d.department_name
    FROM dbo.subjects s
    LEFT JOIN dbo.departments d ON s.department_id = d.department_id
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

IF OBJECT_ID('sp_GetSubjectsByDepartment', 'P') IS NOT NULL DROP PROCEDURE sp_GetSubjectsByDepartment;
GO
CREATE PROCEDURE sp_GetSubjectsByDepartment
    @DepartmentId VARCHAR(50)
AS
BEGIN
    SELECT * FROM dbo.subjects
    WHERE department_id = @DepartmentId AND deleted_at IS NULL
    ORDER BY subject_name;
END
GO

IF OBJECT_ID('sp_CheckSubjectCodeExists', 'P') IS NOT NULL DROP PROCEDURE sp_CheckSubjectCodeExists;
GO
CREATE PROCEDURE sp_CheckSubjectCodeExists
    @SubjectCode VARCHAR(20)
AS
BEGIN
    SELECT COUNT(*) FROM dbo.subjects
    WHERE subject_code = @SubjectCode AND deleted_at IS NULL;
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
-- 8. ACADEMIC YEARS MANAGEMENT
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

IF OBJECT_ID('sp_CheckAcademicYearCodeExists', 'P') IS NOT NULL DROP PROCEDURE sp_CheckAcademicYearCodeExists;
GO
CREATE PROCEDURE sp_CheckAcademicYearCodeExists
    @YearName NVARCHAR(50)
AS
BEGIN
    SELECT COUNT(*) FROM dbo.academic_years
    WHERE year_name = @YearName AND deleted_at IS NULL;
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
-- 9. ROLES & PERMISSIONS MANAGEMENT
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
-- 10. CLASSES MANAGEMENT
-- ===========================================

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

IF OBJECT_ID('sp_GetClassesByLecturer', 'P') IS NOT NULL DROP PROCEDURE sp_GetClassesByLecturer;
GO
CREATE PROCEDURE sp_GetClassesByLecturer
    @LecturerId VARCHAR(50)
AS
BEGIN
    SELECT c.*, s.subject_name
    FROM dbo.classes c
    LEFT JOIN dbo.subjects s ON c.subject_id = s.subject_id
    WHERE c.lecturer_id = @LecturerId AND c.deleted_at IS NULL
    ORDER BY c.created_at DESC;
END
GO

IF OBJECT_ID('sp_GetClassesByStudent', 'P') IS NOT NULL DROP PROCEDURE sp_GetClassesByStudent;
GO
CREATE PROCEDURE sp_GetClassesByStudent
    @StudentId VARCHAR(50)
AS
BEGIN
    SELECT c.*, s.subject_name, l.full_name as lecturer_name
    FROM dbo.classes c
    INNER JOIN dbo.enrollments e ON c.class_id = e.class_id
    LEFT JOIN dbo.subjects s ON c.subject_id = s.subject_id
    LEFT JOIN dbo.lecturers l ON c.lecturer_id = l.lecturer_id
    WHERE e.student_id = @StudentId AND e.deleted_at IS NULL AND c.deleted_at IS NULL
    ORDER BY c.created_at DESC;
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
    @MaxStudents INT = NULL,
    @Schedule NVARCHAR(500) = NULL,
    @Room NVARCHAR(100) = NULL,
    @UpdatedBy VARCHAR(50) = 'system'
AS
BEGIN
    UPDATE dbo.classes
    SET class_code = @ClassCode, class_name = @ClassName, subject_id = @SubjectId,
        lecturer_id = @LecturerId, semester = @Semester, max_students = @MaxStudents,
        schedule = @Schedule, room = @Room, updated_at = GETDATE(), updated_by = @UpdatedBy
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
-- 11. ENROLLMENTS MANAGEMENT
-- ===========================================

IF OBJECT_ID('sp_GetAllEnrollments', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllEnrollments;
GO
CREATE PROCEDURE sp_GetAllEnrollments
AS
BEGIN
    SELECT e.*, s.student_code, s.full_name as student_name, c.class_code, c.class_name
    FROM dbo.enrollments e
    LEFT JOIN dbo.students s ON e.student_id = s.student_id
    LEFT JOIN dbo.classes c ON e.class_id = c.class_id
    WHERE e.deleted_at IS NULL
    ORDER BY e.created_at DESC;
END
GO

IF OBJECT_ID('sp_GetEnrollmentById', 'P') IS NOT NULL DROP PROCEDURE sp_GetEnrollmentById;
GO
CREATE PROCEDURE sp_GetEnrollmentById
    @EnrollmentId VARCHAR(50)
AS
BEGIN
    SELECT e.*, s.student_code, s.full_name as student_name, c.class_code, c.class_name
    FROM dbo.enrollments e
    LEFT JOIN dbo.students s ON e.student_id = s.student_id
    LEFT JOIN dbo.classes c ON e.class_id = c.class_id
    WHERE e.enrollment_id = @EnrollmentId AND e.deleted_at IS NULL;
END
GO

IF OBJECT_ID('sp_GetEnrollmentsByStudent', 'P') IS NOT NULL DROP PROCEDURE sp_GetEnrollmentsByStudent;
GO
CREATE PROCEDURE sp_GetEnrollmentsByStudent
    @StudentId VARCHAR(50)
AS
BEGIN
    SELECT e.*, c.class_code, c.class_name, sub.subject_name
    FROM dbo.enrollments e
    LEFT JOIN dbo.classes c ON e.class_id = c.class_id
    LEFT JOIN dbo.subjects sub ON c.subject_id = sub.subject_id
    WHERE e.student_id = @StudentId AND e.deleted_at IS NULL
    ORDER BY e.created_at DESC;
END
GO

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

PRINT '✅ Enrollments Management SPs created';
GO

-- ===========================================
-- 12. ATTENDANCES MANAGEMENT
-- ===========================================

IF OBJECT_ID('sp_GetAllAttendances', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllAttendances;
GO
CREATE PROCEDURE sp_GetAllAttendances
AS
BEGIN
    SELECT a.*, s.student_code, s.full_name as student_name, c.class_code
    FROM dbo.attendances a
    LEFT JOIN dbo.enrollments e ON a.enrollment_id = e.enrollment_id
    LEFT JOIN dbo.students s ON e.student_id = s.student_id
    LEFT JOIN dbo.classes c ON a.class_id = c.class_id
    ORDER BY a.attendance_date DESC;
END
GO

IF OBJECT_ID('sp_GetAttendanceById', 'P') IS NOT NULL DROP PROCEDURE sp_GetAttendanceById;
GO
CREATE PROCEDURE sp_GetAttendanceById
    @AttendanceId VARCHAR(50)
AS
BEGIN
    SELECT a.*, s.student_code, s.full_name as student_name, c.class_code
    FROM dbo.attendances a
    LEFT JOIN dbo.enrollments e ON a.enrollment_id = e.enrollment_id
    LEFT JOIN dbo.students s ON e.student_id = s.student_id
    LEFT JOIN dbo.classes c ON a.class_id = c.class_id
    WHERE a.attendance_id = @AttendanceId;
END
GO

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

IF OBJECT_ID('sp_GetAttendancesByStudent', 'P') IS NOT NULL DROP PROCEDURE sp_GetAttendancesByStudent;
GO
CREATE PROCEDURE sp_GetAttendancesByStudent
    @StudentId VARCHAR(50)
AS
BEGIN
    SELECT a.*, c.class_code, c.class_name
    FROM dbo.attendances a
    INNER JOIN dbo.enrollments e ON a.enrollment_id = e.enrollment_id
    INNER JOIN dbo.classes c ON a.class_id = c.class_id
    WHERE e.student_id = @StudentId
    ORDER BY a.attendance_date DESC;
END
GO

IF OBJECT_ID('sp_GetAttendancesBySchedule', 'P') IS NOT NULL DROP PROCEDURE sp_GetAttendancesBySchedule;
GO
CREATE PROCEDURE sp_GetAttendancesBySchedule
    @ScheduleId VARCHAR(50)
AS
BEGIN
    SELECT a.*, s.student_code, s.full_name as student_name
    FROM dbo.attendances a
    INNER JOIN dbo.enrollments e ON a.enrollment_id = e.enrollment_id
    INNER JOIN dbo.students s ON e.student_id = s.student_id
    ORDER BY a.attendance_date DESC, s.student_code;
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
    SELECT @AttendanceId AS attendance_id;
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

IF OBJECT_ID('sp_DeleteAttendance', 'P') IS NOT NULL DROP PROCEDURE sp_DeleteAttendance;
GO
CREATE PROCEDURE sp_DeleteAttendance
    @AttendanceId VARCHAR(50)
AS
BEGIN
    DELETE FROM dbo.attendances WHERE attendance_id = @AttendanceId;
END
GO

PRINT '✅ Attendances Management SPs created';
GO

-- ===========================================
-- 13. GRADES MANAGEMENT
-- ===========================================

IF OBJECT_ID('sp_GetAllGrades', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllGrades;
GO
CREATE PROCEDURE sp_GetAllGrades
AS
BEGIN
    SELECT g.*, s.student_code, s.full_name as student_name, c.class_code, sub.subject_name
    FROM dbo.grades g
    LEFT JOIN dbo.enrollments e ON g.enrollment_id = e.enrollment_id
    LEFT JOIN dbo.students s ON e.student_id = s.student_id
    LEFT JOIN dbo.classes c ON e.class_id = c.class_id
    LEFT JOIN dbo.subjects sub ON c.subject_id = sub.subject_id
    ORDER BY g.created_at DESC;
END
GO

IF OBJECT_ID('sp_GetGradeById', 'P') IS NOT NULL DROP PROCEDURE sp_GetGradeById;
GO
CREATE PROCEDURE sp_GetGradeById
    @GradeId VARCHAR(50)
AS
BEGIN
    SELECT g.*, s.student_code, s.full_name as student_name, c.class_code, sub.subject_name
    FROM dbo.grades g
    LEFT JOIN dbo.enrollments e ON g.enrollment_id = e.enrollment_id
    LEFT JOIN dbo.students s ON e.student_id = s.student_id
    LEFT JOIN dbo.classes c ON e.class_id = c.class_id
    LEFT JOIN dbo.subjects sub ON c.subject_id = sub.subject_id
    WHERE g.grade_id = @GradeId;
END
GO

IF OBJECT_ID('sp_GetGradesByStudent', 'P') IS NOT NULL DROP PROCEDURE sp_GetGradesByStudent;
GO
CREATE PROCEDURE sp_GetGradesByStudent
    @StudentId VARCHAR(50)
AS
BEGIN
    SELECT g.*, c.class_code, sub.subject_name
    FROM dbo.grades g
    INNER JOIN dbo.enrollments e ON g.enrollment_id = e.enrollment_id
    INNER JOIN dbo.classes c ON e.class_id = c.class_id
    LEFT JOIN dbo.subjects sub ON c.subject_id = sub.subject_id
    WHERE e.student_id = @StudentId
    ORDER BY g.created_at DESC;
END
GO

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
    DECLARE @TotalScore DECIMAL(4,2);
    DECLARE @LetterGrade VARCHAR(5);
    
    SET @TotalScore = ISNULL(@MidtermScore, 0) * 0.4 + ISNULL(@FinalScore, 0) * 0.6;
    SET @LetterGrade = CASE
        WHEN @TotalScore >= 9.0 THEN 'A+'
        WHEN @TotalScore >= 8.5 THEN 'A'
        WHEN @TotalScore >= 8.0 THEN 'B+'
        WHEN @TotalScore >= 7.0 THEN 'B'
        WHEN @TotalScore >= 6.5 THEN 'C+'
        WHEN @TotalScore >= 5.5 THEN 'C'
        WHEN @TotalScore >= 5.0 THEN 'D+'
        WHEN @TotalScore >= 4.0 THEN 'D'
        ELSE 'F'
    END;
    
    INSERT INTO dbo.grades (grade_id, enrollment_id, midterm_score, final_score,
                            total_score, letter_grade, created_at, created_by)
    VALUES (@GradeId, @EnrollmentId, @MidtermScore, @FinalScore, @TotalScore,
            @LetterGrade, GETDATE(), @CreatedBy);
    SELECT @GradeId AS grade_id;
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

IF OBJECT_ID('sp_DeleteGrade', 'P') IS NOT NULL DROP PROCEDURE sp_DeleteGrade;
GO
CREATE PROCEDURE sp_DeleteGrade
    @GradeId VARCHAR(50)
AS
BEGIN
    DELETE FROM dbo.grades WHERE grade_id = @GradeId;
END
GO

PRINT '✅ Grades Management SPs created';
GO

-- ===========================================
-- 14. SCHEDULES & NOTIFICATIONS
-- ===========================================

IF OBJECT_ID('sp_GetAllSchedules', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllSchedules;
GO
CREATE PROCEDURE sp_GetAllSchedules
AS
BEGIN
    SELECT * FROM dbo.schedules ORDER BY created_at DESC;
END
GO

IF OBJECT_ID('sp_GetScheduleById', 'P') IS NOT NULL DROP PROCEDURE sp_GetScheduleById;
GO
CREATE PROCEDURE sp_GetScheduleById
    @ScheduleId VARCHAR(50)
AS
BEGIN
    SELECT * FROM dbo.schedules WHERE schedule_id = @ScheduleId;
END
GO

IF OBJECT_ID('sp_GetSchedulesByClass', 'P') IS NOT NULL DROP PROCEDURE sp_GetSchedulesByClass;
GO
CREATE PROCEDURE sp_GetSchedulesByClass
    @ClassId VARCHAR(50)
AS
BEGIN
    SELECT * FROM dbo.schedules WHERE class_id = @ClassId ORDER BY created_at;
END
GO

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

PRINT '✅ Schedules & Notifications SPs created';
GO

PRINT '';
PRINT '🎉 HOÀN THÀNH TẠO STORED PROCEDURES!';
PRINT '✅ Đã tạo tổng cộng 80+ stored procedures';
PRINT '✅ Tất cả SPs đều có DROP trước khi CREATE';
PRINT '';

EXEC sp_GetAllUsers 
    @Page = 1,
    @PageSize = 10,
    @Search = NULL,
    @RoleId = NULL,
    @IsActive = NULL;
GO