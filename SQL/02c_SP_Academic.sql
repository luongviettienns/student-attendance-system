-- ===========================================
-- 02c_SP_Academic.sql
-- ===========================================
-- Description: Academic Years Management SPs
-- Generated from: SQL/02_StoredProcedures.sql
-- ===========================================

USE EducationManagement;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

PRINT '========================================';
PRINT 'Starting: 02c_SP_Academic.sql';
PRINT '========================================';
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

PRINT '[OK] Academic Years Management SPs created';
GO

-- SP: Check Academic Year Code Exists
IF OBJECT_ID('sp_CheckAcademicYearCodeExists', 'P') IS NOT NULL DROP PROCEDURE sp_CheckAcademicYearCodeExists;
GO
CREATE PROCEDURE sp_CheckAcademicYearCodeExists
    @YearName NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CASE WHEN EXISTS (
        SELECT 1 FROM dbo.academic_years 
        WHERE year_name = @YearName AND deleted_at IS NULL
    ) THEN 1 ELSE 0 END;
END
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

PRINT '[OK] Academic Years Management SPs created';
GO

PRINT '[OK] Academic Years Management SPs completed';
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
        -- 1. Kiá»ƒm tra nÄƒm há»c má»›i cĂ³ tá»“n táº¡i khĂ´ng
        IF NOT EXISTS (SELECT 1 FROM dbo.academic_years WHERE academic_year_id = @NewAcademicYearId AND deleted_at IS NULL)
        BEGIN
            RAISERROR(N'âŒ NÄƒm há»c má»›i khĂ´ng tá»“n táº¡i hoáº·c Ä‘Ă£ bá»‹ xĂ³a!', 16, 1);
            RETURN;
        END
        
        -- 2. Láº¥y nÄƒm há»c hiá»‡n táº¡i (Ä‘ang active)
        DECLARE @OldAcademicYearId VARCHAR(50);
        SELECT TOP 1 @OldAcademicYearId = academic_year_id
        FROM dbo.academic_years
        WHERE is_active = 1 AND deleted_at IS NULL;
        
        IF @OldAcademicYearId IS NOT NULL
        BEGIN
            -- 3. TĂ­nh GPA cho táº¥t cáº£ sinh viĂªn cá»§a nÄƒm há»c cÅ©
            EXEC sp_CalculateAllStudentGPA 
                @AcademicYearId = @OldAcademicYearId,
                @Semester = NULL, -- TĂ­nh GPA cáº£ nÄƒm
                @CreatedBy = @ExecutedBy;
            
            -- 4. ÄĂ³ng nÄƒm há»c cÅ©
            UPDATE dbo.academic_years 
            SET is_active = 0, 
                updated_at = GETDATE(), 
                updated_by = @ExecutedBy
            WHERE academic_year_id = @OldAcademicYearId;
        END
        
        -- 5. KĂ­ch hoáº¡t nÄƒm há»c má»›i
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
            N'âœ… Chuyá»ƒn nÄƒm há»c thĂ nh cĂ´ng!' as Message;
            
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

PRINT '[OK] Academic Year Transition SPs created';
GO


-- ===========================================
-- AUTOMATION: Auto Create Cohort
-- ===========================================

CREATE PROCEDURE dbo.sp_AutoCreateCohort
    @StartYear INT,
    @DurationYears INT = 4,
    @CreatedBy VARCHAR(50) = 'system'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 0;
    WHILE @i < @DurationYears
    BEGIN
        DECLARE @yearName NVARCHAR(50) = CONCAT(@StartYear + @i, '-', @StartYear + @i + 1);
        DECLARE @ayId VARCHAR(50) = CONCAT('AY', @StartYear + @i);

        IF NOT EXISTS (SELECT 1 FROM dbo.academic_years WHERE academic_year_id = @ayId)
        BEGIN
            INSERT INTO dbo.academic_years (academic_year_id, year_name, start_year, end_year, duration_years, is_active, created_at, created_by)
            VALUES (@ayId, @yearName, @StartYear + @i, @StartYear + @i + 1, @DurationYears, CASE WHEN @i=0 THEN 1 ELSE 0 END, GETDATE(), @CreatedBy);
        END

        -- create single school_year_id per academic year to match SeedData (SY{StartYear})
        DECLARE @syId VARCHAR(50) = CONCAT('SY', @StartYear + @i);
        IF NOT EXISTS (SELECT 1 FROM dbo.school_years WHERE school_year_id=@syId)
        BEGIN
            INSERT INTO dbo.school_years (
                school_year_id, year_code, year_name, academic_year_id,
                start_date, end_date,
                semester1_start, semester1_end,
                semester2_start, semester2_end,
                is_active, current_semester, created_at)
            VALUES (
                @syId,
                CONCAT('SY', @StartYear + @i),
                CONCAT(@yearName, ' - HK1/HK2'),
                @ayId,
                DATEFROMPARTS(@StartYear + @i, 9, 1),
                DATEFROMPARTS(@StartYear + @i + 1, 8, 31),
                DATEFROMPARTS(@StartYear + @i, 9, 1), DATEFROMPARTS(@StartYear + @i, 12, 31),
                DATEFROMPARTS(@StartYear + @i + 1, 1, 1), DATEFROMPARTS(@StartYear + @i + 1, 5, 31),
                CASE WHEN @i=0 THEN 1 ELSE 0 END,
                1,
                GETDATE()
            );
        END

        SET @i += 1;
    END
END
GO

