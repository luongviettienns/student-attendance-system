SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- Fix: sp_GetAdministrativeClassById (avoid phone_number missing column)
IF OBJECT_ID('dbo.sp_GetAdministrativeClassById','P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetAdministrativeClassById;
GO
CREATE PROCEDURE dbo.sp_GetAdministrativeClassById
    @AdminClassId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        ac.admin_class_id,
        ac.class_code,
        ac.class_name,
        ac.major_id,
        ac.advisor_id,
        ac.academic_year_id,
        ac.cohort_year,
        ac.max_students,
        ac.current_students,
        ac.description,
        ac.is_active,
        ac.created_at,
        ac.created_by,
        ac.updated_at,
        ac.updated_by,
        ac.deleted_at,
        ac.deleted_by,
        -- present advisor/major names if available
        m.major_name,
        l.full_name AS advisor_name,
        l.phone     AS advisor_phone
    FROM dbo.administrative_classes ac
    LEFT JOIN dbo.majors m ON m.major_id = ac.major_id
    LEFT JOIN dbo.lecturers l ON l.lecturer_id = ac.advisor_id
    WHERE ac.admin_class_id = @AdminClassId;
END
GO

-- Fix: sp_CreateAdministrativeClass (ensure is_active handled)
IF OBJECT_ID('dbo.sp_CreateAdministrativeClass','P') IS NOT NULL
    DROP PROCEDURE dbo.sp_CreateAdministrativeClass;
GO
CREATE PROCEDURE dbo.sp_CreateAdministrativeClass
    @AdminClassId    VARCHAR(50),
    @ClassCode       VARCHAR(20),
    @ClassName       NVARCHAR(150),
    @MajorId         VARCHAR(50) = NULL,
    @AdvisorId       VARCHAR(50) = NULL,
    @AcademicYearId  VARCHAR(50) = NULL,
    @CohortYear      INT,
    @MaxStudents     INT = 50,
    @Description     NVARCHAR(500) = NULL,
    @IsActive        BIT = 1,
    @CreatedBy       VARCHAR(50) = 'System'
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.administrative_classes (
        admin_class_id, class_code, class_name,
        major_id, advisor_id, academic_year_id,
        cohort_year, max_students, current_students,
        description, is_active, created_at, created_by
    ) VALUES (
        @AdminClassId, @ClassCode, @ClassName,
        @MajorId, @AdvisorId, @AcademicYearId,
        @CohortYear, @MaxStudents, 0,
        @Description, ISNULL(@IsActive,1), GETDATE(), @CreatedBy
    );

    SELECT @AdminClassId AS admin_class_id;
END
GO

-- Fix: sp_CheckStudentPrerequisites (align columns: student_id/subject_id/final_score)
IF OBJECT_ID('dbo.sp_CheckStudentPrerequisites','P') IS NOT NULL
    DROP PROCEDURE dbo.sp_CheckStudentPrerequisites;
GO
CREATE PROCEDURE dbo.sp_CheckStudentPrerequisites
    @StudentId VARCHAR(50),
    @SubjectId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH Required AS (
        SELECT sp.prerequisite_id, sp.subject_id, sp.required_subject_id
        FROM dbo.subject_prerequisites sp
        WHERE sp.subject_id = @SubjectId
    ),
    StudentPassed AS (
        SELECT DISTINCT s.subject_id
        FROM dbo.enrollments e
        INNER JOIN dbo.classes c ON c.class_id = e.class_id
        INNER JOIN dbo.subjects s ON s.subject_id = c.subject_id
        LEFT  JOIN dbo.grades g ON g.enrollment_id = e.enrollment_id
        WHERE e.student_id = @StudentId
          AND e.deleted_at IS NULL
          AND (g.final_score IS NULL OR g.final_score >= 4) -- treat null as passed for in-progress
    )
    SELECT r.required_subject_id AS MissingSubjectId
    FROM Required r
    LEFT JOIN StudentPassed p ON p.subject_id = r.required_subject_id
    WHERE p.subject_id IS NULL;
END
GO

