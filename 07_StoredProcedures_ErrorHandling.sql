-- ===========================================
-- 🎓 HỆ THỐNG QUẢN LÝ ĐIỂM DANH SINH VIÊN
-- 📋 File 8: ERROR HANDLING FOR STORED PROCEDURES
-- ===========================================
-- Thêm TRY-CATCH blocks cho tất cả SPs quan trọng
-- ===========================================

USE EducationManagement;
GO

PRINT '🔄 Bắt đầu thêm Error Handling cho Stored Procedures...';
GO

-- ===========================================
-- 1. USERS MANAGEMENT - WITH ERROR HANDLING
-- ===========================================

-- sp_CreateUser with Error Handling
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
        
        -- Audit log
        INSERT INTO audit_logs (action, entity_type, entity_id, new_values, created_at)
        VALUES ('CREATE', 'User', @UserId, 
                (SELECT * FROM users WHERE user_id = @UserId FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER),
                GETDATE());
        
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
PRINT '✅ Updated: sp_CreateUser (với error handling)';
GO

-- sp_UpdateUser with Error Handling
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
        
        -- Get old values for audit
        DECLARE @OldValues NVARCHAR(MAX);
        SELECT @OldValues = (SELECT * FROM users WHERE user_id = @UserId FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER);
        
        -- Update
        UPDATE dbo.users
        SET full_name = @FullName, email = @Email, phone = @Phone, role_id = @RoleId,
            is_active = @IsActive, avatar_url = ISNULL(@AvatarUrl, avatar_url),
            updated_at = GETDATE(), updated_by = @UpdatedBy
        WHERE user_id = @UserId AND deleted_at IS NULL;
        
        -- Get new values for audit
        DECLARE @NewValues NVARCHAR(MAX);
        SELECT @NewValues = (SELECT * FROM users WHERE user_id = @UserId FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER);
        
        -- Audit log
        INSERT INTO audit_logs (action, entity_type, entity_id, old_values, new_values, created_at)
        VALUES ('UPDATE', 'User', @UserId, @OldValues, @NewValues, GETDATE());
        
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
PRINT '✅ Updated: sp_UpdateUser (với error handling)';
GO

-- ===========================================
-- 2. STUDENTS MANAGEMENT - WITH ERROR HANDLING
-- ===========================================

-- sp_CreateStudent with Error Handling
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
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validation: Check duplicate student code
        IF EXISTS (SELECT 1 FROM students WHERE student_code = @StudentCode AND deleted_at IS NULL)
        BEGIN
            RAISERROR(N'Mã sinh viên đã tồn tại: %s', 16, 1, @StudentCode);
            RETURN;
        END
        
        -- Validation: Check user exists
        IF NOT EXISTS (SELECT 1 FROM users WHERE user_id = @UserId AND deleted_at IS NULL)
        BEGIN
            RAISERROR(N'User không tồn tại: %s', 16, 1, @UserId);
            RETURN;
        END
        
        -- Validation: Check major exists (if provided)
        IF @MajorId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM majors WHERE major_id = @MajorId AND deleted_at IS NULL)
        BEGIN
            RAISERROR(N'Ngành học không tồn tại: %s', 16, 1, @MajorId);
            RETURN;
        END
        
        -- Insert
        INSERT INTO dbo.students (student_id, user_id, student_code, full_name, gender, date_of_birth,
                                  email, phone, address, major_id, academic_year_id,
                                  created_at, created_by)
        VALUES (@StudentId, @UserId, @StudentCode, @FullName, @Gender, @Dob, @Email, @Phone,
                @Address, @MajorId, @AcademicYearId, GETDATE(), @CreatedBy);
        
        -- Audit log
        INSERT INTO audit_logs (action, entity_type, entity_id, new_values, created_at)
        VALUES ('CREATE', 'Student', @StudentId,
                (SELECT * FROM students WHERE student_id = @StudentId FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER),
                GETDATE());
        
        COMMIT TRANSACTION;
        SELECT @StudentId AS student_id;
        
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
PRINT '✅ Updated: sp_CreateStudent (với error handling)';
GO

-- sp_UpdateStudent with Error Handling
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
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validation: Check student exists
        IF NOT EXISTS (SELECT 1 FROM students WHERE student_id = @StudentId AND deleted_at IS NULL)
        BEGIN
            RAISERROR(N'Sinh viên không tồn tại: %s', 16, 1, @StudentId);
            RETURN;
        END

        -- Validation: Check major exists (if provided)
        IF @MajorId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM majors WHERE major_id = @MajorId AND deleted_at IS NULL)
        BEGIN
            RAISERROR(N'Ngành học không tồn tại: %s', 16, 1, @MajorId);
            RETURN;
        END

        -- Validation: Check academic year exists (if provided)
        IF @AcademicYearId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM academic_years WHERE academic_year_id = @AcademicYearId AND deleted_at IS NULL)
        BEGIN
            RAISERROR(N'Năm học không tồn tại: %s', 16, 1, @AcademicYearId);
            RETURN;
        END

        -- Get old values for audit
        DECLARE @OldValuesStu NVARCHAR(MAX);
        SELECT @OldValuesStu = (SELECT * FROM students WHERE student_id = @StudentId FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER);

        -- Update
        UPDATE dbo.students
        SET full_name = @FullName,
            gender = @Gender,
            date_of_birth = @Dob,
            email = @Email,
            phone = @Phone,
            address = @Address,
            major_id = @MajorId,
            academic_year_id = @AcademicYearId,
            updated_at = GETDATE(),
            updated_by = @UpdatedBy
        WHERE student_id = @StudentId AND deleted_at IS NULL;

        -- Get new values for audit
        DECLARE @NewValuesStu NVARCHAR(MAX);
        SELECT @NewValuesStu = (SELECT * FROM students WHERE student_id = @StudentId FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER);

        -- Audit log
        INSERT INTO audit_logs (action, entity_type, entity_id, old_values, new_values, created_at)
        VALUES ('UPDATE', 'Student', @StudentId, @OldValuesStu, @NewValuesStu, GETDATE());

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
PRINT '✅ Updated: sp_UpdateStudent (với error handling)';
GO

-- sp_DeleteStudent with Error Handling (soft delete + cascade related soft deletes)
IF OBJECT_ID('sp_DeleteStudent', 'P') IS NOT NULL DROP PROCEDURE sp_DeleteStudent;
GO
CREATE PROCEDURE sp_DeleteStudent
    @StudentId VARCHAR(50),
    @DeletedBy VARCHAR(50) = 'system'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validation: Check student exists
        IF NOT EXISTS (SELECT 1 FROM students WHERE student_id = @StudentId AND deleted_at IS NULL)
        BEGIN
            RAISERROR(N'Sinh viên không tồn tại hoặc đã bị xóa: %s', 16, 1, @StudentId);
            RETURN;
        END

        -- Get old values for audit
        DECLARE @OldValuesStuDel NVARCHAR(MAX);
        SELECT @OldValuesStuDel = (SELECT * FROM students WHERE student_id = @StudentId FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER);

        -- Remove related: attendances, grades, then soft delete enrollments
        DELETE a
        FROM attendances a
        INNER JOIN enrollments e ON a.enrollment_id = e.enrollment_id
        WHERE e.student_id = @StudentId;

        DELETE g
        FROM grades g
        INNER JOIN enrollments e ON g.enrollment_id = e.enrollment_id
        WHERE e.student_id = @StudentId;

        UPDATE e
        SET e.deleted_at = GETDATE(), e.deleted_by = @DeletedBy
        FROM enrollments e
        WHERE e.student_id = @StudentId AND e.deleted_at IS NULL;

        -- Soft delete related GPAs
        UPDATE gpa
        SET gpa.deleted_at = GETDATE(), gpa.deleted_by = @DeletedBy
        FROM gpas gpa
        WHERE gpa.student_id = @StudentId AND gpa.deleted_at IS NULL;

        -- Soft delete student
        UPDATE dbo.students
        SET deleted_at = GETDATE(), deleted_by = @DeletedBy
        WHERE student_id = @StudentId;

        -- Audit log
        INSERT INTO audit_logs (action, entity_type, entity_id, old_values, new_values, created_at)
        VALUES ('DELETE', 'Student', @StudentId, @OldValuesStuDel, NULL, GETDATE());

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage2 NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity2 INT = ERROR_SEVERITY();
        DECLARE @ErrorState2 INT = ERROR_STATE();

        RAISERROR(@ErrorMessage2, @ErrorSeverity2, @ErrorState2);
    END CATCH
END
GO
PRINT '✅ Updated: sp_DeleteStudent (với error handling + cascade soft delete)';
GO

-- ===========================================
-- 3. ENROLLMENTS - WITH ERROR HANDLING
-- ===========================================

-- sp_CreateEnrollment with Error Handling
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
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validation: Check student exists
        IF NOT EXISTS (SELECT 1 FROM students WHERE student_id = @StudentId AND deleted_at IS NULL)
        BEGIN
            RAISERROR(N'Sinh viên không tồn tại: %s', 16, 1, @StudentId);
            RETURN;
        END
        
        -- Validation: Check class exists
        IF NOT EXISTS (SELECT 1 FROM classes WHERE class_id = @ClassId AND deleted_at IS NULL)
        BEGIN
            RAISERROR(N'Lớp học không tồn tại: %s', 16, 1, @ClassId);
            RETURN;
        END
        
        -- Validation: Check duplicate enrollment
        IF EXISTS (SELECT 1 FROM enrollments 
                   WHERE student_id = @StudentId AND class_id = @ClassId AND deleted_at IS NULL)
        BEGIN
            RAISERROR(N'Sinh viên đã đăng ký lớp học này', 16, 1);
            RETURN;
        END
        
        -- Check class capacity
        DECLARE @CurrentCount INT, @MaxStudents INT;
        
        SELECT @MaxStudents = max_students
        FROM classes
        WHERE class_id = @ClassId;
        
        SELECT @CurrentCount = COUNT(*)
        FROM enrollments
        WHERE class_id = @ClassId AND deleted_at IS NULL;
        
        IF @MaxStudents IS NOT NULL AND @CurrentCount >= @MaxStudents
        BEGIN
            RAISERROR(N'Lớp học đã đầy (Max: %d sinh viên)', 16, 1, @MaxStudents);
            RETURN;
        END
        
        -- Insert
        INSERT INTO dbo.enrollments (enrollment_id, student_id, class_id, status,
                                      enrollment_date, created_at, created_by)
        VALUES (@EnrollmentId, @StudentId, @ClassId, @Status, GETDATE(), GETDATE(), @CreatedBy);
        
        -- Audit log
        INSERT INTO audit_logs (action, entity_type, entity_id, new_values, created_at)
        VALUES ('CREATE', 'Enrollment', @EnrollmentId,
                (SELECT * FROM enrollments WHERE enrollment_id = @EnrollmentId FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER),
                GETDATE());
        
        COMMIT TRANSACTION;
        SELECT @EnrollmentId AS enrollment_id;
        
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
PRINT '✅ Updated: sp_CreateEnrollment (với error handling)';
GO

-- ===========================================
-- 4. GRADES - WITH ERROR HANDLING
-- ===========================================

-- sp_UpdateGrade with Error Handling
IF OBJECT_ID('sp_UpdateGrade', 'P') IS NOT NULL DROP PROCEDURE sp_UpdateGrade;
GO
CREATE PROCEDURE sp_UpdateGrade
    @GradeId VARCHAR(50),
    @MidtermScore DECIMAL(4,2) = NULL,
    @FinalScore DECIMAL(4,2) = NULL,
    @UpdatedBy VARCHAR(50) = 'system'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validation: Check grade exists
        IF NOT EXISTS (SELECT 1 FROM grades WHERE grade_id = @GradeId)
        BEGIN
            RAISERROR(N'Điểm không tồn tại: %s', 16, 1, @GradeId);
            RETURN;
        END
        
        -- Validation: Check score ranges
        IF @MidtermScore IS NOT NULL AND (@MidtermScore < 0 OR @MidtermScore > 10)
        BEGIN
            DECLARE @MidtermMsg NVARCHAR(200) = N'Điểm giữa kỳ phải từ 0-10. Giá trị nhận được: ' + CAST(@MidtermScore AS NVARCHAR(10));
            RAISERROR(@MidtermMsg, 16, 1);
            RETURN;
        END
        
        IF @FinalScore IS NOT NULL AND (@FinalScore < 0 OR @FinalScore > 10)
        BEGIN
            DECLARE @FinalMsg NVARCHAR(200) = N'Điểm cuối kỳ phải từ 0-10. Giá trị nhận được: ' + CAST(@FinalScore AS NVARCHAR(10));
            RAISERROR(@FinalMsg, 16, 1);
            RETURN;
        END
        
        -- Get old values
        DECLARE @OldValues NVARCHAR(MAX);
        SELECT @OldValues = (SELECT * FROM grades WHERE grade_id = @GradeId FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER);
        
        -- Calculate total score (40% midterm + 60% final)
        DECLARE @TotalScore DECIMAL(4,2) = NULL;
        IF @MidtermScore IS NOT NULL AND @FinalScore IS NOT NULL
        BEGIN
            SET @TotalScore = ROUND(@MidtermScore * 0.4 + @FinalScore * 0.6, 2);
        END
        
        -- Update
        UPDATE dbo.grades
        SET midterm_score = @MidtermScore, 
            final_score = @FinalScore,
            total_score = @TotalScore,
            updated_at = GETDATE(), 
            updated_by = @UpdatedBy
        WHERE grade_id = @GradeId;
        
        -- Get new values
        DECLARE @NewValues NVARCHAR(MAX);
        SELECT @NewValues = (SELECT * FROM grades WHERE grade_id = @GradeId FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER);
        
        -- Audit log
        INSERT INTO audit_logs (action, entity_type, entity_id, old_values, new_values, created_at)
        VALUES ('UPDATE', 'Grade', @GradeId, @OldValues, @NewValues, GETDATE());
        
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
PRINT '✅ Updated: sp_UpdateGrade (với error handling)';
GO

PRINT '';
PRINT '🎉 HOÀN THÀNH THÊM ERROR HANDLING!';
PRINT '✅ Đã thêm TRY-CATCH blocks cho các SPs quan trọng:';
PRINT '   - sp_CreateUser';
PRINT '   - sp_UpdateUser';
PRINT '   - sp_CreateStudent';
PRINT '   - sp_CreateEnrollment';
PRINT '   - sp_UpdateGrade';
PRINT '';
PRINT '💡 TIP: Các SPs khác cũng nên áp dụng pattern tương tự';
PRINT '';

