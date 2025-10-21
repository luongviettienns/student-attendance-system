-- ===========================================
-- 🎓 HỆ THỐNG QUẢN LÝ ĐIỂM DANH SINH VIÊN
-- 📋 File 3/4: TRIGGERS
-- ===========================================

USE EducationManagement;
GO

-- ===========================================
-- 1. AUDIT TRIGGER FOR USERS
-- ===========================================
CREATE OR ALTER TRIGGER tr_Users_Audit
ON dbo.users
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Action VARCHAR(10);
    DECLARE @UserId VARCHAR(50);
    DECLARE @OldValues NVARCHAR(MAX);
    DECLARE @NewValues NVARCHAR(MAX);
    
    IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
        SET @Action = 'UPDATE';
    ELSE IF EXISTS (SELECT 1 FROM inserted)
        SET @Action = 'INSERT';
    ELSE
        SET @Action = 'DELETE';
    
    SET @UserId = COALESCE(
        (SELECT CAST(SESSION_CONTEXT(N'CurrentUserId') AS VARCHAR(50))),
        'system'
    );
    
    IF @Action = 'INSERT'
    BEGIN
        SELECT @NewValues = (
            SELECT user_id, username, email, full_name, role_id, is_active
            FROM inserted FOR JSON PATH
        );
        
        INSERT INTO dbo.audit_logs (user_id, action, entity_type, entity_id, new_values)
        SELECT @UserId, 'INSERT', 'users', user_id, @NewValues
        FROM inserted;
    END
    
    ELSE IF @Action = 'UPDATE'
    BEGIN
        SELECT @OldValues = (SELECT * FROM deleted FOR JSON PATH);
        SELECT @NewValues = (SELECT * FROM inserted FOR JSON PATH);
        
        INSERT INTO dbo.audit_logs (user_id, action, entity_type, entity_id, old_values, new_values)
        SELECT @UserId, 'UPDATE', 'users', i.user_id, @OldValues, @NewValues
        FROM inserted i;
    END
    
    ELSE IF @Action = 'DELETE'
    BEGIN
        SELECT @OldValues = (SELECT * FROM deleted FOR JSON PATH);
        
        INSERT INTO dbo.audit_logs (user_id, action, entity_type, entity_id, old_values)
        SELECT @UserId, 'DELETE', 'users', user_id, @OldValues
        FROM deleted;
    END
END
GO

-- ===========================================
-- 2. AUDIT TRIGGER FOR STUDENTS
-- ===========================================
CREATE OR ALTER TRIGGER tr_Students_Audit
ON dbo.students
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Action VARCHAR(10);
    DECLARE @UserId VARCHAR(50) = COALESCE(
        (SELECT CAST(SESSION_CONTEXT(N'CurrentUserId') AS VARCHAR(50))), 'system'
    );
    
    IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
        SET @Action = 'UPDATE';
    ELSE IF EXISTS (SELECT 1 FROM inserted)
        SET @Action = 'INSERT';
    ELSE
        SET @Action = 'DELETE';
    
    IF @Action IN ('INSERT', 'UPDATE')
    BEGIN
        INSERT INTO dbo.audit_logs (user_id, action, entity_type, entity_id, new_values)
        SELECT @UserId, @Action, 'students', student_id, 
               (SELECT * FROM inserted FOR JSON PATH)
        FROM inserted;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.audit_logs (user_id, action, entity_type, entity_id, old_values)
        SELECT @UserId, 'DELETE', 'students', student_id,
               (SELECT * FROM deleted FOR JSON PATH)
        FROM deleted;
    END
END
GO

-- ===========================================
-- 3. TRIGGER - PREVENT DUPLICATE ATTENDANCE
-- ===========================================
CREATE OR ALTER TRIGGER tr_PreventDuplicateAttendance
ON dbo.attendances
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Kiểm tra xem đã có điểm danh trong ngày chưa
    IF EXISTS (
        SELECT 1 FROM dbo.attendances a
        INNER JOIN inserted i ON a.enrollment_id = i.enrollment_id 
            AND CAST(a.attendance_date AS DATE) = CAST(i.attendance_date AS DATE)
    )
    BEGIN
        RAISERROR('Sinh viên đã được điểm danh trong ngày này!', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
    
    -- Nếu chưa có, insert bình thường
    INSERT INTO dbo.attendances (attendance_id, enrollment_id, class_id, 
                                  attendance_date, status, note, created_at, created_by)
    SELECT attendance_id, enrollment_id, class_id, attendance_date, status, note,
           created_at, created_by
    FROM inserted;
END
GO

-- ===========================================
-- 4. TRIGGER - AUTO UPDATE TOTAL GRADE
-- ===========================================
CREATE OR ALTER TRIGGER tr_AutoCalculateTotalGrade
ON dbo.grades
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE g
    SET total_score = ISNULL(i.midterm_score, 0) * 0.4 + ISNULL(i.final_score, 0) * 0.6,
        letter_grade = CASE
            WHEN (ISNULL(i.midterm_score, 0) * 0.4 + ISNULL(i.final_score, 0) * 0.6) >= 9.0 THEN 'A+'
            WHEN (ISNULL(i.midterm_score, 0) * 0.4 + ISNULL(i.final_score, 0) * 0.6) >= 8.5 THEN 'A'
            WHEN (ISNULL(i.midterm_score, 0) * 0.4 + ISNULL(i.final_score, 0) * 0.6) >= 8.0 THEN 'B+'
            WHEN (ISNULL(i.midterm_score, 0) * 0.4 + ISNULL(i.final_score, 0) * 0.6) >= 7.0 THEN 'B'
            WHEN (ISNULL(i.midterm_score, 0) * 0.4 + ISNULL(i.final_score, 0) * 0.6) >= 6.5 THEN 'C+'
            WHEN (ISNULL(i.midterm_score, 0) * 0.4 + ISNULL(i.final_score, 0) * 0.6) >= 5.5 THEN 'C'
            WHEN (ISNULL(i.midterm_score, 0) * 0.4 + ISNULL(i.final_score, 0) * 0.6) >= 5.0 THEN 'D+'
            WHEN (ISNULL(i.midterm_score, 0) * 0.4 + ISNULL(i.final_score, 0) * 0.6) >= 4.0 THEN 'D'
            ELSE 'F'
        END
    FROM dbo.grades g
    INNER JOIN inserted i ON g.grade_id = i.grade_id;
END
GO

-- ===========================================
-- 5. TRIGGER - ENSURE ONLY ONE ACTIVE ACADEMIC YEAR
-- ===========================================
CREATE OR ALTER TRIGGER tr_EnsureOneActiveAcademicYear
ON dbo.academic_years
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Nếu có academic year mới được set is_active = 1
    IF EXISTS (SELECT 1 FROM inserted WHERE is_active = 1)
    BEGIN
        -- Vô hiệu hóa tất cả các academic year khác
        UPDATE dbo.academic_years
        SET is_active = 0
        WHERE academic_year_id NOT IN (SELECT academic_year_id FROM inserted WHERE is_active = 1)
            AND is_active = 1;
    END
END
GO

PRINT '✅ Đã tạo xong tất cả triggers!';

