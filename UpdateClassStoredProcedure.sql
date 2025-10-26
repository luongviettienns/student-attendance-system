USE EducationManagement;
GO

-- Update sp_CreateClass stored procedure
IF OBJECT_ID('sp_CreateClass', 'P') IS NOT NULL DROP PROCEDURE sp_CreateClass;
GO

CREATE PROCEDURE sp_CreateClass
    @ClassId VARCHAR(50),
    @ClassCode VARCHAR(20),
    @ClassName NVARCHAR(200),
    @SubjectId VARCHAR(50),
    @LecturerId VARCHAR(50) = NULL,
    @AcademicYearId VARCHAR(50) = NULL,
    @Semester VARCHAR(10) = NULL,
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

-- Update sp_UpdateClass stored procedure
IF OBJECT_ID('sp_UpdateClass', 'P') IS NOT NULL DROP PROCEDURE sp_UpdateClass;
GO

CREATE PROCEDURE sp_UpdateClass
    @ClassId VARCHAR(50),
    @ClassCode VARCHAR(20),
    @ClassName NVARCHAR(200),
    @SubjectId VARCHAR(50),
    @LecturerId VARCHAR(50) = NULL,
    @Semester VARCHAR(10) = NULL,
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

PRINT 'Đã cập nhật stored procedures sp_CreateClass và sp_UpdateClass';
