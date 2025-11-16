-- =============================================
-- 🔧 FIX REGISTRATION PERIOD STORED PROCEDURES
-- Sửa lỗi mismatch tên cột trong stored procedures
-- =============================================

USE EducationManagement;
GO

SET QUOTED_IDENTIFIER ON;
GO

PRINT '========================================';
PRINT '🔧 FIX REGISTRATION PERIOD STORED PROCEDURES';
PRINT '========================================';
PRINT '';

-- =============================================
-- 1. FIX sp_GetAllRegistrationPeriods
-- =============================================
PRINT '📊 Fixing sp_GetAllRegistrationPeriods...';

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
            ay.year_name AS academic_year_name,
            ay.start_year,
            ay.end_year,
            rp.semester,
            rp.start_date,
            rp.end_date,
            rp.status,
            rp.description,
            rp.is_active,
            rp.created_at,
            rp.created_by,
            (SELECT COUNT(*) FROM enrollments e WHERE e.enrollment_status = 'APPROVED' AND EXISTS (
                SELECT 1 FROM period_classes pc WHERE pc.period_id = rp.period_id AND pc.class_id = e.class_id AND pc.deleted_at IS NULL
            )) AS total_enrollments,
            (SELECT COUNT(DISTINCT e.student_id) FROM enrollments e WHERE e.enrollment_status = 'APPROVED' AND EXISTS (
                SELECT 1 FROM period_classes pc WHERE pc.period_id = rp.period_id AND pc.class_id = e.class_id AND pc.deleted_at IS NULL
            )) AS total_students_enrolled,
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

PRINT '   ✅ Fixed: sp_GetAllRegistrationPeriods';
PRINT '';

-- =============================================
-- 2. FIX sp_GetRegistrationPeriodById
-- =============================================
PRINT '📊 Fixing sp_GetRegistrationPeriodById...';

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
            ay.year_name AS academic_year_name,
            ay.start_year,
            ay.end_year,
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
            (SELECT COUNT(*) FROM enrollments e WHERE e.enrollment_status = 'APPROVED' AND EXISTS (
                SELECT 1 FROM period_classes pc WHERE pc.period_id = rp.period_id AND pc.class_id = e.class_id AND pc.deleted_at IS NULL
            )) AS total_enrollments,
            (SELECT COUNT(DISTINCT e.student_id) FROM enrollments e WHERE e.enrollment_status = 'APPROVED' AND EXISTS (
                SELECT 1 FROM period_classes pc WHERE pc.period_id = rp.period_id AND pc.class_id = e.class_id AND pc.deleted_at IS NULL
            )) AS total_students_enrolled,
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

PRINT '   ✅ Fixed: sp_GetRegistrationPeriodById';
PRINT '';

-- =============================================
-- 3. FIX sp_GetActiveRegistrationPeriod
-- =============================================
PRINT '📊 Fixing sp_GetActiveRegistrationPeriod...';

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
            ay.year_name AS academic_year_name,
            ay.start_year,
            ay.end_year,
            rp.semester,
            rp.start_date,
            rp.end_date,
            rp.status,
            rp.description,
            rp.is_active,
            rp.created_at,
            rp.created_by,
            (SELECT COUNT(*) FROM enrollments e WHERE e.enrollment_status = 'APPROVED' AND EXISTS (
                SELECT 1 FROM period_classes pc WHERE pc.period_id = rp.period_id AND pc.class_id = e.class_id AND pc.deleted_at IS NULL
            )) AS total_enrollments,
            (SELECT COUNT(DISTINCT e.student_id) FROM enrollments e WHERE e.enrollment_status = 'APPROVED' AND EXISTS (
                SELECT 1 FROM period_classes pc WHERE pc.period_id = rp.period_id AND pc.class_id = e.class_id AND pc.deleted_at IS NULL
            )) AS total_students_enrolled,
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

PRINT '   ✅ Fixed: sp_GetActiveRegistrationPeriod';
PRINT '';

PRINT '========================================';
PRINT '✅ HOÀN THÀNH FIX STORED PROCEDURES!';
PRINT '========================================';
PRINT '💡 Các thay đổi:';
PRINT '   - Đổi year_name → academic_year_name';
PRINT '   - Thêm start_year, end_year';
PRINT '   - Thêm total_enrollments, total_students_enrolled';
PRINT '========================================';
PRINT '';
GO

