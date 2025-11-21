-- ===========================================
-- 🎓 HỆ THỐNG QUẢN LÝ ĐIỂM DANH SINH VIÊN
-- 📋 File: MIGRATION & STORED PROCEDURES CHO ĐỢT ĐĂNG KÝ HỌC LẠI
-- ===========================================

USE EducationManagement;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

PRINT '========================================';
PRINT 'Starting: 08_RetakeRegistration.sql';
PRINT 'Retake Registration Migration & SPs';
PRINT '========================================';
GO

-- ===========================================
-- 1. MIGRATION: Thêm column period_type vào registration_periods
-- ===========================================

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('registration_periods') AND name = 'period_type')
BEGIN
    ALTER TABLE dbo.registration_periods 
    ADD period_type NVARCHAR(20) DEFAULT 'NORMAL' NOT NULL;
    
    -- Thêm constraint CHECK
    ALTER TABLE dbo.registration_periods
    ADD CONSTRAINT CHK_Period_Type CHECK (period_type IN ('NORMAL', 'RETAKE'));
    
    -- Set giá trị mặc định cho các records hiện tại
    UPDATE dbo.registration_periods
    SET period_type = 'NORMAL'
    WHERE period_type IS NULL;
    
    PRINT '✓ Added column: registration_periods.period_type';
END
ELSE
BEGIN
    PRINT '✓ Column already exists: registration_periods.period_type';
END
GO

-- Tạo index cho period_type
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Period_Type' AND object_id = OBJECT_ID('registration_periods'))
BEGIN
    CREATE INDEX IX_Period_Type ON registration_periods(period_type, status);
    PRINT '✓ Created index: IX_Period_Type';
END
ELSE
BEGIN
    PRINT '✓ Index already exists: IX_Period_Type';
END
GO

-- Cập nhật unique constraint để cho phép nhiều OPEN periods nếu khác period_type
-- Drop old unique index nếu tồn tại
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'UQ_Period_AcademicYearSemester' AND object_id = OBJECT_ID('registration_periods'))
BEGIN
    DROP INDEX UQ_Period_AcademicYearSemester ON registration_periods;
    PRINT '✓ Dropped old unique index: UQ_Period_AcademicYearSemester';
END
GO

-- Tạo unique constraint mới bao gồm period_type
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'UQ_Period_AcademicYearSemesterType' AND object_id = OBJECT_ID('registration_periods'))
BEGIN
    CREATE UNIQUE INDEX UQ_Period_AcademicYearSemesterType 
    ON registration_periods(academic_year_id, semester, period_type, is_active) 
    WHERE is_active = 1 AND deleted_at IS NULL AND status = 'OPEN';
    PRINT '✓ Created unique index: UQ_Period_AcademicYearSemesterType';
END
ELSE
BEGIN
    PRINT '✓ Unique index already exists: UQ_Period_AcademicYearSemesterType';
END
GO

-- ===========================================
-- 2. SP_GETFAILEDSUBJECTSBYSTUDENT - Lấy danh sách môn trượt của sinh viên
-- ===========================================

IF OBJECT_ID('sp_GetFailedSubjectsByStudent', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetFailedSubjectsByStudent;
GO

CREATE PROCEDURE sp_GetFailedSubjectsByStudent
    @StudentId VARCHAR(50),
    @SchoolYearId VARCHAR(50) = NULL,
    @Semester INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Lấy danh sách môn trượt từ retake_records với status APPROVED
        SELECT DISTINCT
            r.retake_id,
            r.subject_id,
            s.subject_code,
            s.subject_name,
            s.credits,
            r.class_id AS failed_class_id,
            c.class_code AS failed_class_code,
            c.class_name AS failed_class_name,
            r.reason, -- ATTENDANCE, GRADE, BOTH
            r.current_value,
            r.threshold_value,
            r.status AS retake_status,
            r.created_at AS retake_created_at,
            sy.school_year_id,
            sy.year_code AS school_year_code,
            sy.start_date AS school_year_start_date,  -- Thêm vào để ORDER BY
            c.semester
        FROM dbo.retake_records r
        INNER JOIN dbo.subjects s ON r.subject_id = s.subject_id
        INNER JOIN dbo.classes c ON r.class_id = c.class_id
        LEFT JOIN dbo.school_years sy ON c.school_year_id = sy.school_year_id
        WHERE r.student_id = @StudentId
            AND r.status IN ('APPROVED', 'PENDING') -- Chỉ lấy môn đã được approve học lại hoặc đang chờ
            AND r.deleted_at IS NULL
            AND s.deleted_at IS NULL
            AND (@SchoolYearId IS NULL OR c.school_year_id = @SchoolYearId)
            AND (@Semester IS NULL OR c.semester = @Semester)
        ORDER BY sy.start_date DESC, c.semester, s.subject_name;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT '✓ Created stored procedure: sp_GetFailedSubjectsByStudent';
GO

-- ===========================================
-- 3. SP_GETRETAKECLASSESFORSUBJECT - Lấy danh sách lớp học lại của môn
-- ===========================================

IF OBJECT_ID('sp_GetRetakeClassesForSubject', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetRetakeClassesForSubject;
GO

CREATE PROCEDURE sp_GetRetakeClassesForSubject
    @SubjectId VARCHAR(50),
    @StudentId VARCHAR(50) = NULL, -- Optional: để kiểm tra xem sinh viên đã đăng ký chưa
    @PeriodId VARCHAR(50) = NULL   -- Optional: nếu không có thì lấy từ period đang mở
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Lấy period đang mở cho retake (nếu không có PeriodId)
        DECLARE @ActiveRetakePeriodId VARCHAR(50);
        
        IF @PeriodId IS NULL
        BEGIN
            SELECT TOP 1 @ActiveRetakePeriodId = period_id
            FROM dbo.registration_periods
            WHERE period_type = 'RETAKE'
                AND status = 'OPEN'
                AND GETDATE() BETWEEN start_date AND end_date
                AND deleted_at IS NULL
                AND is_active = 1
            ORDER BY created_at DESC;
        END
        ELSE
        BEGIN
            SET @ActiveRetakePeriodId = @PeriodId;
        END
        
        IF @ActiveRetakePeriodId IS NULL
        BEGIN
            -- Không có đợt đăng ký học lại đang mở, trả về empty result với structure đúng
            SELECT TOP 0 
                c.class_id,
                c.class_code,
                c.class_name,
                CAST(NULL AS VARCHAR(50)) AS subject_code,
                CAST(NULL AS NVARCHAR(200)) AS subject_name,
                CAST(NULL AS INT) AS credits,
                CAST(NULL AS VARCHAR(50)) AS lecturer_id,
                CAST(NULL AS NVARCHAR(100)) AS lecturer_name,
                CAST(NULL AS VARCHAR(50)) AS room_id,
                CAST(NULL AS VARCHAR(50)) AS room_code,
                CAST(NULL AS NVARCHAR(100)) AS building,
                c.max_students,
                c.current_enrollment,
                (c.max_students - c.current_enrollment) AS available_seats,
                0 AS is_registered,
                CAST(NULL AS VARCHAR(50)) AS school_year_code,
                CAST(NULL AS INT) AS semester,
                CAST(NULL AS NVARCHAR(500)) AS schedule_info
            FROM dbo.classes c;
            RETURN;
        END
        
        -- Lấy danh sách lớp học lại của môn trong đợt đăng ký đang mở
        SELECT 
            c.class_id,
            c.class_code,
            c.class_name,
            s.subject_code,
            s.subject_name,
            s.credits,
            l.lecturer_id,
            l.full_name AS lecturer_name,
            r.room_id,
            r.room_code,
            r.building,
            c.max_students,
            c.current_enrollment,
            (c.max_students - c.current_enrollment) AS available_seats,
            CASE 
                WHEN @StudentId IS NOT NULL AND EXISTS (
                    SELECT 1 FROM dbo.enrollments e
                    WHERE e.student_id = @StudentId
                        AND e.class_id = c.class_id
                        AND e.enrollment_status IN ('APPROVED', 'PENDING')
                        AND e.deleted_at IS NULL
                ) THEN 1
                ELSE 0
            END AS is_registered,
            sy.year_code AS school_year_code,
            c.semester,
            -- Lấy lịch học từ timetable_sessions
            (SELECT STRING_AGG(
                CASE 
                    WHEN ts.weekday = 1 THEN N'CN'
                    WHEN ts.weekday = 2 THEN N'T2'
                    WHEN ts.weekday = 3 THEN N'T3'
                    WHEN ts.weekday = 4 THEN N'T4'
                    WHEN ts.weekday = 5 THEN N'T5'
                    WHEN ts.weekday = 6 THEN N'T6'
                    WHEN ts.weekday = 7 THEN N'T7'
                    ELSE N'?'
                END + 
                CASE 
                    WHEN ts.period_from IS NOT NULL AND ts.period_to IS NOT NULL 
                    THEN N' Tiết ' + CAST(ts.period_from AS NVARCHAR(2)) + N'-' + CAST(ts.period_to AS NVARCHAR(2))
                    ELSE N' ' + CAST(ts.start_time AS NVARCHAR(5)) + N'-' + CAST(ts.end_time AS NVARCHAR(5))
                END, ', ')
             FROM dbo.timetable_sessions ts
             WHERE ts.class_id = c.class_id AND ts.deleted_at IS NULL
            ) AS schedule_info
        FROM dbo.period_classes pc
        INNER JOIN dbo.classes c ON pc.class_id = c.class_id
        INNER JOIN dbo.subjects s ON c.subject_id = s.subject_id
        LEFT JOIN dbo.lecturers l ON c.lecturer_id = l.lecturer_id
        LEFT JOIN dbo.school_years sy ON c.school_year_id = sy.school_year_id
        LEFT JOIN dbo.timetable_sessions ts ON c.class_id = ts.class_id AND ts.deleted_at IS NULL
        LEFT JOIN dbo.rooms r ON ts.room_id = r.room_id AND r.deleted_at IS NULL
        WHERE pc.period_id = @ActiveRetakePeriodId
            AND c.subject_id = @SubjectId
            AND pc.is_active = 1
            AND pc.deleted_at IS NULL
            AND c.deleted_at IS NULL
            AND s.deleted_at IS NULL
        GROUP BY 
            c.class_id, c.class_code, c.class_name,
            s.subject_code, s.subject_name, s.credits,
            l.lecturer_id, l.full_name,
            r.room_id, r.room_code, r.building,
            c.max_students, c.current_enrollment,
            sy.year_code, c.semester
        ORDER BY c.class_code;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT '✓ Created stored procedure: sp_GetRetakeClassesForSubject';
GO

-- ===========================================
-- 4. SP_CHECKRETAKEENROLLMENTELIGIBILITY - Kiểm tra điều kiện đăng ký học lại
-- ===========================================

IF OBJECT_ID('sp_CheckRetakeEnrollmentEligibility', 'P') IS NOT NULL
    DROP PROCEDURE sp_CheckRetakeEnrollmentEligibility;
GO

CREATE PROCEDURE sp_CheckRetakeEnrollmentEligibility
    @StudentId VARCHAR(50),
    @ClassId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        DECLARE @IsEligible BIT = 1;
        DECLARE @ErrorMessage NVARCHAR(500) = NULL;
        DECLARE @SubjectId VARCHAR(50);
        DECLARE @PeriodId VARCHAR(50);
        
        -- 1. Kiểm tra student và class tồn tại
        IF NOT EXISTS (SELECT 1 FROM dbo.students WHERE student_id = @StudentId AND deleted_at IS NULL)
        BEGIN
            SET @IsEligible = 0;
            SET @ErrorMessage = N'Sinh viên không tồn tại';
        END
        ELSE IF NOT EXISTS (SELECT 1 FROM dbo.classes WHERE class_id = @ClassId AND deleted_at IS NULL)
        BEGIN
            SET @IsEligible = 0;
            SET @ErrorMessage = N'Lớp học không tồn tại';
        END
        ELSE
        BEGIN
            -- Lấy subject_id của lớp
            SELECT @SubjectId = subject_id FROM dbo.classes WHERE class_id = @ClassId;
            
            -- 2. Kiểm tra sinh viên có retake_record APPROVED cho môn này không
            IF NOT EXISTS (
                SELECT 1 FROM dbo.retake_records
                WHERE student_id = @StudentId
                    AND subject_id = @SubjectId
                    AND status = 'APPROVED'
                    AND deleted_at IS NULL
            )
            BEGIN
                SET @IsEligible = 0;
                SET @ErrorMessage = N'Sinh viên chưa được duyệt học lại cho môn này';
            END
            -- 3. Kiểm tra đợt đăng ký học lại đang mở
            ELSE IF NOT EXISTS (
                SELECT 1 FROM dbo.registration_periods rp
                INNER JOIN dbo.period_classes pc ON rp.period_id = pc.period_id
                WHERE pc.class_id = @ClassId
                    AND rp.period_type = 'RETAKE'
                    AND rp.status = 'OPEN'
                    AND GETDATE() BETWEEN rp.start_date AND rp.end_date
                    AND rp.deleted_at IS NULL
                    AND pc.deleted_at IS NULL
                    AND pc.is_active = 1
            )
            BEGIN
                SET @IsEligible = 0;
                SET @ErrorMessage = N'Lớp không thuộc đợt đăng ký học lại đang mở';
            END
            -- 4. Kiểm tra lớp chưa đầy
            ELSE IF EXISTS (
                SELECT 1 FROM dbo.classes
                WHERE class_id = @ClassId
                    AND current_enrollment >= max_students
                    AND max_students IS NOT NULL
            )
            BEGIN
                SET @IsEligible = 0;
                SET @ErrorMessage = N'Lớp đã đầy';
            END
            -- 5. Kiểm tra chưa đăng ký vào lớp này
            ELSE IF EXISTS (
                SELECT 1 FROM dbo.enrollments
                WHERE student_id = @StudentId
                    AND class_id = @ClassId
                    AND enrollment_status IN ('APPROVED', 'PENDING')
                    AND deleted_at IS NULL
            )
            BEGIN
                SET @IsEligible = 0;
                SET @ErrorMessage = N'Sinh viên đã đăng ký vào lớp này';
            END
            -- 6. Kiểm tra trùng lịch học (tương tự sp_CheckEnrollmentEligibility)
            ELSE IF EXISTS (
                SELECT 1
                FROM dbo.enrollments e_existing
                INNER JOIN dbo.classes c_existing ON e_existing.class_id = c_existing.class_id
                INNER JOIN dbo.timetable_sessions ts_existing ON c_existing.class_id = ts_existing.class_id
                INNER JOIN dbo.timetable_sessions ts_new ON @ClassId = ts_new.class_id
                WHERE ts_existing.weekday = ts_new.weekday
                    AND ts_existing.week_no = ts_new.week_no
                    AND (
                        (ts_existing.period_from IS NOT NULL AND ts_new.period_from IS NOT NULL
                         AND ts_existing.period_from = ts_new.period_from
                         AND ts_existing.period_to = ts_new.period_to)
                        OR
                        (ts_existing.start_time IS NOT NULL AND ts_new.start_time IS NOT NULL
                         AND ts_existing.start_time = ts_new.start_time
                         AND ts_existing.end_time = ts_new.end_time)
                    )
                    AND ts_existing.deleted_at IS NULL
                    AND ts_new.deleted_at IS NULL
                    AND e_existing.student_id = @StudentId
                    AND e_existing.enrollment_status = 'APPROVED'
                    AND e_existing.deleted_at IS NULL
                    AND c_existing.class_id != @ClassId
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
            @ClassId AS class_id,
            @SubjectId AS subject_id;
        
    END TRY
    BEGIN CATCH
        DECLARE @Error NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @Error, 1;
    END CATCH
END
GO

PRINT '✓ Created stored procedure: sp_CheckRetakeEnrollmentEligibility';
GO

-- ===========================================
-- 5. CẬP NHẬT SP_CREATEENROLLMENT - Thêm logic cho retake enrollment
-- ===========================================

-- Lưu ý: sp_CreateEnrollment hiện tại sẽ cần được cập nhật để hỗ trợ retake
-- Nhưng để tránh breaking changes, chúng ta sẽ tạo thêm một SP riêng cho retake
-- Hoặc cập nhật logic trong sp_CreateEnrollment để tự động detect period_type

-- Tạm thời, sinh viên có thể dùng API register bình thường nhưng backend sẽ check retake eligibility
-- Dựa vào period_type của period chứa class đó

-- ===========================================
-- 6. CẬP NHẬT SP_GETREGISTRATIONPERIODS - Thêm filter period_type
-- ===========================================

-- Lưu ý: Cần cập nhật SP này trong file SQL/02_SP_Scheduling.sql
-- Hoặc tạo SP mới riêng cho retake periods

-- ===========================================

PRINT '========================================';
PRINT 'Completed: 08_RetakeRegistration.sql';
PRINT '========================================';
GO

