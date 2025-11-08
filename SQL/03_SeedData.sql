-- ===========================================
-- 🎓 HỆ THỐNG QUẢN LÝ ĐIỂM DANH SINH VIÊN
-- 📋 File 7: SEED DATA - UPDATED WITH COHORTS & SCHOOL YEARS
-- ===========================================
-- 
-- CẤU TRÚC MỚI:
-- - ACADEMIC YEARS = NIÊN KHÓA (4 năm): K21, K22, K23, K24
-- - SCHOOL YEARS = NĂM HỌC (1 năm = 2 học kỳ): 2024-2025
-- - SEMESTERS = HỌC KỲ: CHỈ CÓ HK1 (Tháng 9 - Tháng 1) và HK2 (Tháng 2 - Tháng 6)
--
-- ===========================================

USE EducationManagement;
GO

SET QUOTED_IDENTIFIER ON;
GO

PRINT '🌱 Bắt đầu seed data (updated with automation)...';
GO

-- ===========================================
-- 1. ROLES (4 roles) - SAME AS BEFORE
-- ===========================================
PRINT '👥 Seeding Roles...';

IF NOT EXISTS (SELECT 1 FROM roles WHERE role_id = 'ROLE_ADMIN')
BEGIN
    INSERT INTO dbo.roles (role_id, role_name, description, is_active) VALUES
    ('ROLE_ADMIN', N'Admin', N'Quản trị viên hệ thống', 1),
    ('ROLE_LECTURER', N'Lecturer', N'Giảng viên', 1),
    ('ROLE_STUDENT', N'Student', N'Sinh viên', 1),
    ('ROLE_ADVISOR', N'Advisor', N'Cố vấn học tập', 1);
    PRINT '   ✅ 4 roles created';
END
ELSE
    PRINT '   ⚠️  Roles already exist';
GO

-- ===========================================
-- 2. USERS - UPDATED
-- ===========================================
PRINT '👤 Seeding Users...';

-- Admin password: "admin123" 
-- BCrypt hash: $2a$10$h5gvrNjE2bhwhHn6Ofofq.Ppr0hvpLY5Q3mbY1OjkkGL8CMxm2VBm
-- Other users password: "password123"
-- BCrypt hash: $2a$10$Ya6MFL1CGpg2/y088u6t7.ACYkMJdmA1869rbBmAnyn6OQi0hTBue

-- Create users if not exist (one by one to avoid skipping if some already exist)
IF NOT EXISTS (SELECT 1 FROM users WHERE user_id = 'USER001')
BEGIN
    INSERT INTO dbo.users (user_id, username, password_hash, email, phone, full_name, role_id, is_active) VALUES
    ('USER001', 'admin', '$2a$10$h5gvrNjE2bhwhHn6Ofofq.Ppr0hvpLY5Q3mbY1OjkkGL8CMxm2VBm', 'admin@example.com', '0901234567', N'Nguyễn Văn Admin', 'ROLE_ADMIN', 1);
END

IF NOT EXISTS (SELECT 1 FROM users WHERE user_id = 'USER002')
BEGIN
    INSERT INTO dbo.users (user_id, username, password_hash, email, phone, full_name, role_id, is_active) VALUES
    ('USER002', 'lecturer01', '$2a$10$Ya6MFL1CGpg2/y088u6t7.ACYkMJdmA1869rbBmAnyn6OQi0hTBue', 'lecturer01@example.com', '0902222222', N'Trần Thị Hoa', 'ROLE_LECTURER', 1);
END

IF NOT EXISTS (SELECT 1 FROM users WHERE user_id = 'USER003')
BEGIN
    INSERT INTO dbo.users (user_id, username, password_hash, email, phone, full_name, role_id, is_active) VALUES
    ('USER003', 'student_k21_01', '$2a$10$Ya6MFL1CGpg2/y088u6t7.ACYkMJdmA1869rbBmAnyn6OQi0hTBue', 'student.k21.01@example.com', '0903333333', N'Lê Văn An', 'ROLE_STUDENT', 1);
END

IF NOT EXISTS (SELECT 1 FROM users WHERE user_id = 'USER004')
BEGIN
    INSERT INTO dbo.users (user_id, username, password_hash, email, phone, full_name, role_id, is_active) VALUES
    ('USER004', 'student_k21_02', '$2a$10$Ya6MFL1CGpg2/y088u6t7.ACYkMJdmA1869rbBmAnyn6OQi0hTBue', 'student.k21.02@example.com', '0904444444', N'Phạm Thị Bình', 'ROLE_STUDENT', 1);
END

IF NOT EXISTS (SELECT 1 FROM users WHERE user_id = 'USER005')
BEGIN
    INSERT INTO dbo.users (user_id, username, password_hash, email, phone, full_name, role_id, is_active) VALUES
    ('USER005', 'student_k22_01', '$2a$10$Ya6MFL1CGpg2/y088u6t7.ACYkMJdmA1869rbBmAnyn6OQi0hTBue', 'student.k22.01@example.com', '0905555555', N'Nguyễn Văn Cường', 'ROLE_STUDENT', 1);
END

IF NOT EXISTS (SELECT 1 FROM users WHERE user_id = 'USER006')
BEGIN
    INSERT INTO dbo.users (user_id, username, password_hash, email, phone, full_name, role_id, is_active) VALUES
    ('USER006', 'student_k23_01', '$2a$10$Ya6MFL1CGpg2/y088u6t7.ACYkMJdmA1869rbBmAnyn6OQi0hTBue', 'student.k23.01@example.com', '0906666666', N'Hoàng Thị Dung', 'ROLE_STUDENT', 1);
END

IF NOT EXISTS (SELECT 1 FROM users WHERE user_id = 'USER007')
BEGIN
    INSERT INTO dbo.users (user_id, username, password_hash, email, phone, full_name, role_id, is_active) VALUES
    ('USER007', 'student_k24_01', '$2a$10$Ya6MFL1CGpg2/y088u6t7.ACYkMJdmA1869rbBmAnyn6OQi0hTBue', 'student.k24.01@example.com', '0907777777', N'Đinh Văn Em', 'ROLE_STUDENT', 1);
END

-- Create advisor user (USER008) - IMPORTANT: Must exist before creating lecturer
IF NOT EXISTS (SELECT 1 FROM users WHERE user_id = 'USER008')
BEGIN
    INSERT INTO dbo.users (user_id, username, password_hash, email, phone, full_name, role_id, is_active) VALUES
    ('USER008', 'advisor01', '$2a$10$Ya6MFL1CGpg2/y088u6t7.ACYkMJdmA1869rbBmAnyn6OQi0hTBue', 'advisor01@example.com', '0908888888', N'Nguyễn Văn Cố Vấn', 'ROLE_ADVISOR', 1);
    PRINT '   ✅ Created advisor user (USER008)';
END

PRINT '   ✅ Users seeding completed';
GO

-- ===========================================
-- 3. FACULTIES (1 faculty)
-- ===========================================
PRINT '🏛️  Seeding Faculties...';

IF NOT EXISTS (SELECT 1 FROM faculties WHERE faculty_id = 'FAC001')
BEGIN
    INSERT INTO dbo.faculties (faculty_id, faculty_code, faculty_name, description, is_active) VALUES
    ('FAC001', 'CNTT', N'Công nghệ Thông tin', N'Khoa Công nghệ Thông tin', 1);
    PRINT '   ✅ 1 faculty created';
END
ELSE
    PRINT '   ⚠️  Faculty already exists';
GO

-- ===========================================
-- 4. DEPARTMENTS (2 departments)
-- ===========================================
PRINT '🏢 Seeding Departments...';

IF NOT EXISTS (SELECT 1 FROM departments WHERE department_id = 'DEPT001')
BEGIN
    INSERT INTO dbo.departments (department_id, department_code, department_name, faculty_id, description) VALUES
    ('DEPT001', 'DEPT001', N'Khoa học Máy tính', 'FAC001', N'Bộ môn Khoa học Máy tính'),
    ('DEPT002', 'DEPT002', N'Hệ thống Thông tin', 'FAC001', N'Bộ môn Hệ thống Thông tin');
    PRINT '   ✅ 2 departments created';
END
ELSE
    PRINT '   ⚠️  Departments already exist';
GO

-- ===========================================
-- 5. MAJORS (2 majors)
-- ===========================================
PRINT '📚 Seeding Majors...';

IF NOT EXISTS (SELECT 1 FROM majors WHERE major_id = 'MAJ001')
BEGIN
    INSERT INTO dbo.majors (major_id, major_name, major_code, faculty_id, description) VALUES
    ('MAJ001', N'Công nghệ Phần mềm', 'SE', 'FAC001', N'Chuyên ngành Công nghệ Phần mềm'),
    ('MAJ002', N'Khoa học Dữ liệu', 'DS', 'FAC001', N'Chuyên ngành Khoa học Dữ liệu');
    PRINT '   ✅ 2 majors created';
END
ELSE
    PRINT '   ⚠️  Majors already exist';
GO

-- ===========================================
-- 6. ACADEMIC YEARS (NIÊN KHÓA) - 4 COHORTS
-- ===========================================
PRINT '📅 Seeding Academic Years (Cohorts - 4 years each)...';

-- Use stored procedure to auto-create cohorts
-- Prefer using SP if exists; otherwise fallback to inline creation
IF OBJECT_ID('sp_AutoCreateCohort','P') IS NOT NULL
BEGIN
    BEGIN TRY
        EXEC sp_AutoCreateCohort @StartYear = 2021, @DurationYears = 4, @CreatedBy = 'system';
        EXEC sp_AutoCreateCohort @StartYear = 2022, @DurationYears = 4, @CreatedBy = 'system';
        EXEC sp_AutoCreateCohort @StartYear = 2023, @DurationYears = 4, @CreatedBy = 'system';
        EXEC sp_AutoCreateCohort @StartYear = 2024, @DurationYears = 4, @CreatedBy = 'system';
        PRINT '   ✅ 4 cohorts created (K21..K24) via sp_AutoCreateCohort';
    END TRY
    BEGIN CATCH
        PRINT CONCAT('   ⚠️  Cohorts may already exist (SP): ', ERROR_MESSAGE());
    END CATCH
END
ELSE
BEGIN
    PRINT '   ℹ️  sp_AutoCreateCohort not found, using inline creation...';
    DECLARE @y INT = 2021;
    WHILE @y <= 2024
    BEGIN
        DECLARE @ayId VARCHAR(50) = CONCAT('AY', @y);
        DECLARE @cohortCode NVARCHAR(10) = CONCAT('K', SUBSTRING(CAST(@y AS VARCHAR(4)), 3, 2)); -- K21, K22, K23, K24
        IF NOT EXISTS (SELECT 1 FROM dbo.academic_years WHERE academic_year_id=@ayId)
        BEGIN
            INSERT INTO dbo.academic_years (academic_year_id, year_name, cohort_code, start_year, end_year, duration_years, is_active, created_at, created_by)
            VALUES (@ayId, CONCAT(@y,'-',@y+1), @cohortCode, @y, @y+1, 4, CASE WHEN @y=2021 THEN 1 ELSE 0 END, GETDATE(), 'system');
        END
        ELSE
        BEGIN
            -- Update cohort_code nếu đã tồn tại nhưng chưa có cohort_code
            UPDATE dbo.academic_years 
            SET cohort_code = @cohortCode 
            WHERE academic_year_id = @ayId AND cohort_code IS NULL;
        END
        DECLARE @syId VARCHAR(50) = CONCAT('SY', @y);
        IF NOT EXISTS (SELECT 1 FROM dbo.school_years WHERE school_year_id=@syId)
        BEGIN
            INSERT INTO dbo.school_years (
                school_year_id, year_code, year_name, academic_year_id,
                start_date, end_date,
                semester1_start, semester1_end,
                semester2_start, semester2_end,
                is_active, current_semester, created_at)
            VALUES (
                @syId, CONCAT('SY', @y), CONCAT(@y,'-',@y+1,' - HK1/HK2'), @ayId,
                DATEFROMPARTS(@y, 9, 1), DATEFROMPARTS(@y+1, 8, 31),
                DATEFROMPARTS(@y, 9, 1), DATEFROMPARTS(@y, 12, 31),
                DATEFROMPARTS(@y+1, 1, 1), DATEFROMPARTS(@y+1, 5, 31),
                CASE WHEN @y=2021 THEN 1 ELSE 0 END, 1, GETDATE()
            );
        END
        SET @y += 1;
    END
END
GO

-- Activate current school year (2024-2025 or nearest future school year)
DECLARE @CurrentYear INT = YEAR(GETDATE());
DECLARE @SchoolYearToActivate VARCHAR(50);
DECLARE @SemesterToSet INT;

-- Try to find school year that covers current date or nearest future
SELECT TOP 1 
    @SchoolYearToActivate = school_year_id,
    @SemesterToSet = CASE 
        WHEN CAST(GETDATE() AS DATE) BETWEEN semester1_start AND semester1_end THEN 1
        WHEN CAST(GETDATE() AS DATE) BETWEEN semester2_start AND semester2_end THEN 2
        WHEN CAST(GETDATE() AS DATE) < semester1_start THEN 1  -- Before semester 1, set to 1
        WHEN CAST(GETDATE() AS DATE) > semester2_end THEN 2   -- After semester 2, set to 2
        ELSE 1
    END
FROM school_years
WHERE deleted_at IS NULL
    AND (
        -- Current date is within school year range
        (CAST(GETDATE() AS DATE) BETWEEN start_date AND end_date)
        -- OR current date is before school year starts (nearest future)
        OR (CAST(GETDATE() AS DATE) < start_date)
    )
ORDER BY 
    CASE WHEN CAST(GETDATE() AS DATE) BETWEEN start_date AND end_date THEN 0 ELSE 1 END,
    start_date ASC;

-- If no match, activate SY2024 if exists
IF @SchoolYearToActivate IS NULL
BEGIN
    IF EXISTS (SELECT 1 FROM school_years WHERE school_year_id = 'SY2024')
    BEGIN
        SET @SchoolYearToActivate = 'SY2024';
        SET @SemesterToSet = 1;
    END
END

-- Activate the school year
IF @SchoolYearToActivate IS NOT NULL
BEGIN
    -- Deactivate all other school years first
    UPDATE school_years 
    SET is_active = 0
    WHERE school_year_id != @SchoolYearToActivate;
    
    -- Activate target school year
    UPDATE school_years 
    SET is_active = 1, 
        current_semester = @SemesterToSet
    WHERE school_year_id = @SchoolYearToActivate;
    
    PRINT CONCAT('   ✅ Activated school year: ', @SchoolYearToActivate, ' (Semester ', CAST(@SemesterToSet AS VARCHAR), ')');
END
ELSE
BEGIN
    PRINT '   ⚠️  No school year found to activate - ensure school years exist for current/future dates';
END
GO

-- ===========================================
-- 7. LECTURERS (2 lecturers: 1 lecturer, 1 advisor)
-- ===========================================
-- LƯU Ý: Advisor (LEC002) là Cố vấn phòng đào tạo, quản lý CHUNG TOÀN BỘ sinh viên.
-- Advisor KHÔNG được gán vào lớp hành chính cụ thể (không có advisor_id trong administrative_classes).
-- ===========================================
PRINT '👨‍🏫 Seeding Lecturers...';

-- Create lecturer (LEC001) if not exists
IF NOT EXISTS (SELECT 1 FROM lecturers WHERE lecturer_id = 'LEC001')
BEGIN
    -- Ensure USER002 exists before creating lecturer
    IF EXISTS (SELECT 1 FROM users WHERE user_id = 'USER002')
    BEGIN
        INSERT INTO dbo.lecturers (lecturer_id, lecturer_code, full_name, email, phone, department_id, user_id) VALUES
        ('LEC001', 'GV001', N'Trần Thị Hoa', 'lecturer01@example.com', '0902222222', 'DEPT001', 'USER002');
        PRINT '   ✅ Created lecturer (LEC001)';
    END
    ELSE
        PRINT '   ⚠️  USER002 not found, skipping LEC001 creation';
END

-- Create advisor lecturer (LEC002) if not exists
-- IMPORTANT: USER008 must exist (created in users section above)
IF NOT EXISTS (SELECT 1 FROM lecturers WHERE lecturer_id = 'LEC002')
BEGIN
    -- Ensure USER008 exists before creating advisor lecturer
    IF EXISTS (SELECT 1 FROM users WHERE user_id = 'USER008')
    BEGIN
        INSERT INTO dbo.lecturers (lecturer_id, lecturer_code, full_name, email, phone, department_id, user_id) VALUES
        ('LEC002', 'ADV001', N'Nguyễn Văn Cố Vấn', 'advisor01@example.com', '0908888888', 'DEPT001', 'USER008');
        PRINT '   ✅ Created advisor lecturer (LEC002 - Cố vấn phòng đào tạo)';
        PRINT '   ⚠️  Lưu ý: Advisor KHÔNG được gán vào lớp hành chính, quản lý chung toàn bộ sinh viên';
    END
    ELSE
    BEGIN
        PRINT '   ⚠️  USER008 (advisor) not found! Please ensure advisor user is created first.';
        PRINT '   ⚠️  Skipping LEC002 creation';
    END
END
ELSE
    PRINT '   ✅ Advisor lecturer (LEC002) already exists';

PRINT '   ✅ Lecturers seeding completed';
GO

-- ===========================================
-- 8. STUDENTS - DISTRIBUTED ACROSS COHORTS
-- ===========================================
PRINT '👨‍🎓 Seeding Students (5 students from K21, K22, K23, K24)...';

IF NOT EXISTS (SELECT 1 FROM students WHERE student_id = 'STU001')
BEGIN
    -- Verify academic years exist before inserting students
    IF NOT EXISTS (SELECT 1 FROM academic_years WHERE academic_year_id = 'AY2021')
    BEGIN
        INSERT INTO academic_years (academic_year_id, year_name, cohort_code, start_year, end_year, duration_years, is_active, created_at, created_by)
        VALUES ('AY2021', '2021-2025', 'K21', 2021, 2025, 4, 0, GETDATE(), 'system');
    END
    
    IF NOT EXISTS (SELECT 1 FROM academic_years WHERE academic_year_id = 'AY2022')
    BEGIN
        INSERT INTO academic_years (academic_year_id, year_name, cohort_code, start_year, end_year, duration_years, is_active, created_at, created_by)
        VALUES ('AY2022', '2022-2026', 'K22', 2022, 2026, 4, 0, GETDATE(), 'system');
    END
    
    IF NOT EXISTS (SELECT 1 FROM academic_years WHERE academic_year_id = 'AY2023')
    BEGIN
        INSERT INTO academic_years (academic_year_id, year_name, cohort_code, start_year, end_year, duration_years, is_active, created_at, created_by)
        VALUES ('AY2023', '2023-2027', 'K23', 2023, 2027, 4, 0, GETDATE(), 'system');
    END
    
    IF NOT EXISTS (SELECT 1 FROM academic_years WHERE academic_year_id = 'AY2024')
    BEGIN
        INSERT INTO academic_years (academic_year_id, year_name, cohort_code, start_year, end_year, duration_years, is_active, created_at, created_by)
        VALUES ('AY2024', '2024-2028', 'K24', 2024, 2028, 4, 0, GETDATE(), 'system');
    END
    
    INSERT INTO dbo.students (student_id, user_id, student_code, full_name, gender, date_of_birth, email, phone, major_id, academic_year_id, is_active) VALUES
    -- K21 students (2021-2025) - Year 4 now
    ('STU001', 'USER003', 'SV2021001', N'Lê Văn An', N'Nam', '2003-05-15', 'student.k21.01@example.com', '0903333333', 'MAJ001', 'AY2021', 1),
    ('STU002', 'USER004', 'SV2021002', N'Phạm Thị Bình', N'Nữ', '2003-08-20', 'student.k21.02@example.com', '0904444444', 'MAJ001', 'AY2021', 1),
    
    -- K22 student (2022-2026) - Year 3 now
    ('STU003', 'USER005', 'SV2022001', N'Nguyễn Văn Cường', N'Nam', '2004-03-10', 'student.k22.01@example.com', '0905555555', 'MAJ002', 'AY2022', 1),
    
    -- K23 student (2023-2027) - Year 2 now
    ('STU004', 'USER006', 'SV2023001', N'Hoàng Thị Dung', N'Nữ', '2005-07-25', 'student.k23.01@example.com', '0906666666', 'MAJ001', 'AY2023', 1),
    
    -- K24 student (2024-2028) - Year 1 now (freshman)
    ('STU005', 'USER007', 'SV2024001', N'Đinh Văn Em', N'Nam', '2006-11-30', 'student.k24.01@example.com', '0907777777', 'MAJ002', 'AY2024', 1);
    
    PRINT '   ✅ 5 students created (2 from K21, 1 from K22, 1 from K23, 1 from K24)';
END
ELSE
    PRINT '   ⚠️  Students already exist';
GO

-- ===========================================
-- 9. SUBJECTS (4 subjects - for different years)
-- ===========================================
PRINT '📖 Seeding Subjects...';

IF NOT EXISTS (SELECT 1 FROM subjects WHERE subject_id = 'SUB001')
BEGIN
    INSERT INTO dbo.subjects (subject_id, subject_code, subject_name, credits, department_id, description) VALUES
    ('SUB001', 'CS101', N'Lập trình C#', 3, 'DEPT001', N'Nhập môn lập trình C# - Năm 1'),
    ('SUB002', 'CS102', N'Cơ sở dữ liệu', 3, 'DEPT001', N'Hệ quản trị cơ sở dữ liệu - Năm 1'),
    ('SUB003', 'CS201', N'Cấu trúc dữ liệu', 4, 'DEPT001', N'Cấu trúc dữ liệu và giải thuật - Năm 2'),
    ('SUB004', 'CS301', N'Công nghệ Web', 4, 'DEPT001', N'Lập trình Web nâng cao - Năm 3');
    PRINT '   ✅ 4 subjects created';
END
ELSE
    PRINT '   ⚠️  Subjects already exist';
GO

-- ===========================================
-- 10. CLASSES - FOR SCHOOL YEAR 2024-2025 (SEMESTER 1)
-- ===========================================
PRINT '🏫 Seeding Classes (School Year 2024-2025, Semester 1)...';

IF NOT EXISTS (SELECT 1 FROM classes WHERE class_id = 'CLS001')
BEGIN
    -- Link to NEW school_year_id instead of old academic_year_id
    INSERT INTO dbo.classes (class_id, class_code, class_name, subject_id, lecturer_id, academic_year_id, school_year_id, semester, max_students, schedule, room) VALUES
    -- Semester 1 classes for 2024-2025
    ('CLS001', 'CS101-01-2024', N'Lập trình C# - Lớp 01 (2024-2025 HK1)', 'SUB001', 'LEC001', 'AY2024', 'SY2024', 1, 40, N'Thứ 2, 7:00-9:00', 'A101'),
    ('CLS002', 'CS102-01-2024', N'Cơ sở dữ liệu - Lớp 01 (2024-2025 HK1)', 'SUB002', 'LEC001', 'AY2024', 'SY2024', 1, 40, N'Thứ 4, 7:00-9:00', 'A102'),
    ('CLS003', 'CS201-01-2024', N'Cấu trúc dữ liệu - Lớp 01 (2024-2025 HK1)', 'SUB003', 'LEC001', 'AY2023', 'SY2024', 1, 35, N'Thứ 3, 13:00-15:00', 'B201'),
    ('CLS004', 'CS301-01-2024', N'Công nghệ Web - Lớp 01 (2024-2025 HK1)', 'SUB004', 'LEC001', 'AY2022', 'SY2024', 1, 30, N'Thứ 5, 15:00-17:00', 'C301');
    
    PRINT '   ✅ 4 classes created for 2024-2025 Semester 1';
END
ELSE
    PRINT '   ⚠️  Classes already exist';
GO
-- ===========================================
-- 11. ENROLLMENTS - Students register for classes
-- ===========================================
PRINT '📝 Seeding Enrollments...';

IF NOT EXISTS (SELECT 1 FROM enrollments WHERE enrollment_id = 'ENR001')
BEGIN
    INSERT INTO dbo.enrollments (enrollment_id, student_id, class_id, status, enrollment_status, enrollment_date) VALUES
    -- K24 student (freshman) takes year 1 courses
    ('ENR001', 'STU005', 'CLS001', N'Đang học', 'APPROVED', GETDATE()),  -- CS101
    ('ENR002', 'STU005', 'CLS002', N'Đang học', 'APPROVED', GETDATE()),  -- CS102
    
    -- K23 student (year 2) takes year 2 course
    ('ENR003', 'STU004', 'CLS003', N'Đang học', 'APPROVED', GETDATE()),  -- CS201
    
    -- K22 student (year 3) takes year 3 course
    ('ENR004', 'STU003', 'CLS004', N'Đang học', 'APPROVED', GETDATE()),  -- CS301
    
    -- K21 students (year 4) also take some courses
    ('ENR005', 'STU001', 'CLS004', N'Đang học', 'APPROVED', GETDATE()),  -- CS301
    ('ENR006', 'STU002', 'CLS003', N'Đang học', 'APPROVED', GETDATE());  -- CS201
    
    PRINT '   ✅ 6 enrollments created';
END
ELSE
    PRINT '   ⚠️  Enrollments already exist';
GO

-- ===========================================
-- 12. GRADES - Sample grades for current semester
-- ===========================================
PRINT '💯 Seeding Grades...';

IF NOT EXISTS (SELECT 1 FROM grades WHERE grade_id = 'GRD001')
BEGIN
    INSERT INTO dbo.grades (grade_id, enrollment_id, midterm_score, final_score, total_score, letter_grade) VALUES
    ('GRD001', 'ENR001', 8.5, 9.0, 8.8, 'A'),
    ('GRD002', 'ENR002', 7.0, 7.5, 7.3, 'B'),
    ('GRD003', 'ENR003', 9.0, 9.5, 9.3, 'A'),
    ('GRD004', 'ENR004', 6.5, 7.0, 6.8, 'C'),
    ('GRD005', 'ENR005', 8.0, 8.5, 8.3, 'A'),
    ('GRD006', 'ENR006', 7.5, 8.0, 7.8, 'B');
    
    PRINT '   ✅ 6 grades created';
END
ELSE
    PRINT '   ⚠️  Grades already exist';
GO

-- ===========================================
-- 13. PERMISSIONS (Menu Permissions với đầy đủ cấu trúc)
-- ===========================================
PRINT '🔐 Seeding Menu Permissions...';

-- Student Parent Permissions (Sections)
IF NOT EXISTS (SELECT 1 FROM permissions WHERE permission_code = 'STUDENT_SECTION_OVERVIEW')
BEGIN
    INSERT INTO dbo.permissions (permission_id, permission_code, permission_name, parent_code, icon, sort_order, description, is_active) VALUES
    ('PERM_STU_OVERVIEW', 'STUDENT_SECTION_OVERVIEW', N'TỔNG QUAN', NULL, 'fas fa-home', 1, N'Menu section tổng quan cho sinh viên', 1),
    ('PERM_STU_STUDY', 'STUDENT_SECTION_STUDY', N'HỌC TẬP', NULL, 'fas fa-book', 2, N'Menu section học tập cho sinh viên', 1),
    ('PERM_STU_PROFILE', 'STUDENT_SECTION_PROFILE', N'CÁ NHÂN', NULL, 'fas fa-user', 3, N'Menu section cá nhân cho sinh viên', 1),
    ('PERM_STU_SYSTEM', 'STUDENT_SECTION_SYSTEM', N'HỆ THỐNG', NULL, 'fas fa-cog', 4, N'Menu section hệ thống cho sinh viên', 1);
END

-- Student Child Permissions (Menu Items)
IF NOT EXISTS (SELECT 1 FROM permissions WHERE permission_code = 'STUDENT_DASHBOARD')
BEGIN
    INSERT INTO dbo.permissions (permission_id, permission_code, permission_name, parent_code, icon, sort_order, description, is_active) VALUES
    ('PERM_STU_DASHBOARD', 'STUDENT_DASHBOARD', N'Dashboard', 'STUDENT_SECTION_OVERVIEW', 'fas fa-tachometer-alt', 1, N'Dashboard sinh viên', 1),
    ('PERM_STU_TIMETABLE', 'STUDENT_TIMETABLE', N'Thời khóa biểu', 'STUDENT_SECTION_STUDY', 'fas fa-calendar-alt', 1, N'Xem thời khóa biểu', 1),
    ('PERM_STU_SCHEDULE', 'STUDENT_SCHEDULE', N'Lịch học', 'STUDENT_SECTION_STUDY', 'fas fa-calendar', 2, N'Xem lịch học', 1),
    ('PERM_STU_GRADES', 'STUDENT_GRADES', N'Kết quả học tập', 'STUDENT_SECTION_STUDY', 'fas fa-graduation-cap', 3, N'Xem bảng điểm', 1),
    ('PERM_STU_ATTENDANCE', 'STUDENT_ATTENDANCE', N'Điểm danh', 'STUDENT_SECTION_STUDY', 'fas fa-clipboard-check', 4, N'Xem lịch sử điểm danh', 1),
    ('PERM_STU_ENROLLMENT', 'STUDENT_ENROLLMENT', N'Đăng ký học phần', 'STUDENT_SECTION_STUDY', 'fas fa-edit', 5, N'Đăng ký học phần', 1),
    ('PERM_STU_PROFILE_ITEM', 'STUDENT_PROFILE', N'Thông tin cá nhân', 'STUDENT_SECTION_PROFILE', 'fas fa-user', 1, N'Quản lý thông tin cá nhân', 1),
    ('PERM_STU_NOTIFICATIONS', 'STUDENT_NOTIFICATIONS', N'Thông báo', 'STUDENT_SECTION_SYSTEM', 'fas fa-bell', 1, N'Xem thông báo', 1);
END

-- Lecturer Parent Permissions
IF NOT EXISTS (SELECT 1 FROM permissions WHERE permission_code = 'TEACHER_SECTION_OVERVIEW')
BEGIN
    INSERT INTO dbo.permissions (permission_id, permission_code, permission_name, parent_code, icon, sort_order, description, is_active) VALUES
    ('PERM_TCH_OVERVIEW', 'TEACHER_SECTION_OVERVIEW', N'TỔNG QUAN', NULL, 'fas fa-home', 1, N'Menu section tổng quan cho giảng viên', 1),
    ('PERM_TCH_TEACHING', 'TEACHER_SECTION_TEACHING', N'GIẢNG DẠY', NULL, 'fas fa-chalkboard-teacher', 2, N'Menu section giảng dạy', 1),
    ('PERM_TCH_SYSTEM', 'TEACHER_SECTION_SYSTEM', N'HỆ THỐNG', NULL, 'fas fa-cog', 3, N'Menu section hệ thống cho giảng viên', 1);
END

-- Lecturer Child Permissions
IF NOT EXISTS (SELECT 1 FROM permissions WHERE permission_code = 'TEACHER_DASHBOARD')
BEGIN
    INSERT INTO dbo.permissions (permission_id, permission_code, permission_name, parent_code, icon, sort_order, description, is_active) VALUES
    ('PERM_TCH_DASHBOARD', 'TEACHER_DASHBOARD', N'Dashboard', 'TEACHER_SECTION_OVERVIEW', 'fas fa-tachometer-alt', 1, N'Dashboard giảng viên', 1),
    ('PERM_TCH_ATTENDANCE', 'TEACHER_ATTENDANCE', N'Điểm danh', 'TEACHER_SECTION_TEACHING', 'fas fa-check-square', 1, N'Điểm danh sinh viên', 1),
    ('PERM_TCH_GRADES', 'TEACHER_GRADES', N'Nhập điểm', 'TEACHER_SECTION_TEACHING', 'fas fa-graduation-cap', 2, N'Nhập điểm sinh viên', 1),
    ('PERM_TCH_TIMETABLE', 'TEACHER_TIMETABLE', N'Thời khóa biểu', 'TEACHER_SECTION_TEACHING', 'fas fa-calendar-alt', 3, N'Xem thời khóa biểu giảng dạy', 1),
    ('PERM_TCH_NOTIFICATIONS', 'TEACHER_NOTIFICATIONS', N'Thông báo', 'TEACHER_SECTION_SYSTEM', 'fas fa-bell', 1, N'Xem thông báo', 1);
END

-- Advisor Parent Permissions
IF NOT EXISTS (SELECT 1 FROM permissions WHERE permission_code = 'ADVISOR_SECTION_OVERVIEW')
BEGIN
    INSERT INTO dbo.permissions (permission_id, permission_code, permission_name, parent_code, icon, sort_order, description, is_active) VALUES
    ('PERM_ADV_OVERVIEW', 'ADVISOR_SECTION_OVERVIEW', N'TỔNG QUAN', NULL, 'fas fa-home', 1, N'Menu section tổng quan cho cố vấn', 1),
    ('PERM_ADV_ADVISING', 'ADVISOR_SECTION_ADVISING', N'CỐ VẤN', NULL, 'fas fa-user-graduate', 2, N'Menu section cố vấn', 1),
    ('PERM_ADV_SYSTEM', 'ADVISOR_SECTION_SYSTEM', N'HỆ THỐNG', NULL, 'fas fa-cog', 3, N'Menu section hệ thống cho cố vấn', 1);
END

-- Advisor Child Permissions
IF NOT EXISTS (SELECT 1 FROM permissions WHERE permission_code = 'ADVISOR_DASHBOARD')
BEGIN
    INSERT INTO dbo.permissions (permission_id, permission_code, permission_name, parent_code, icon, sort_order, description, is_active) VALUES
    ('PERM_ADV_DASHBOARD', 'ADVISOR_DASHBOARD', N'Dashboard', 'ADVISOR_SECTION_OVERVIEW', 'fas fa-tachometer-alt', 1, N'Dashboard cố vấn', 1),
    ('PERM_ADV_STUDENTS', 'ADVISOR_STUDENTS', N'Sinh viên', 'ADVISOR_SECTION_ADVISING', 'fas fa-user-graduate', 1, N'Quản lý sinh viên được phụ trách', 1),
    ('PERM_ADV_WARNINGS', 'ADVISOR_WARNINGS', N'Cảnh báo', 'ADVISOR_SECTION_ADVISING', 'fas fa-exclamation-triangle', 2, N'Cảnh báo và gửi email cho sinh viên', 1),
    ('PERM_ADV_NOTIFICATIONS', 'ADVISOR_NOTIFICATIONS', N'Thông báo', 'ADVISOR_SECTION_SYSTEM', 'fas fa-bell', 1, N'Xem thông báo', 1);
END

-- Admin Parent Permissions
IF NOT EXISTS (SELECT 1 FROM permissions WHERE permission_code = 'ADMIN_SECTION_OVERVIEW')
BEGIN
    INSERT INTO dbo.permissions (permission_id, permission_code, permission_name, parent_code, icon, sort_order, description, is_active) VALUES
    ('PERM_ADM_OVERVIEW', 'ADMIN_SECTION_OVERVIEW', N'TỔNG QUAN', NULL, 'fas fa-home', 1, N'Menu section tổng quan cho admin', 1),
    ('PERM_ADM_USERS', 'ADMIN_SECTION_USERS', N'QUẢN LÝ NGƯỜI DÙNG', NULL, 'fas fa-users', 2, N'Menu section quản lý người dùng', 1),
    ('PERM_ADM_ACADEMIC', 'ADMIN_SECTION_ACADEMIC', N'QUẢN LÝ ĐÀO TẠO', NULL, 'fas fa-graduation-cap', 3, N'Menu section quản lý đào tạo', 1),
    ('PERM_ADM_SUBJECTS', 'ADMIN_SECTION_SUBJECTS', N'HỌC PHẦN', NULL, 'fas fa-book', 4, N'Menu section học phần', 1),
    ('PERM_ADM_ADMIN_CLASSES_SECTION', 'ADMIN_SECTION_CLASSES', N'LỚP HỌC', NULL, 'fas fa-users-class', 5, N'Menu section lớp học', 1),
    ('PERM_ADM_ENROLLMENT', 'ADMIN_SECTION_ENROLLMENT', N'ĐĂNG KÝ HỌC PHẦN', NULL, 'fas fa-clipboard-list', 6, N'Menu section đăng ký học phần', 1),
    ('PERM_ADM_TIMETABLE', 'ADMIN_SECTION_TIMETABLE', N'QUẢN LÝ THỜI KHÓA BIỂU', NULL, 'fas fa-calendar-alt', 7, N'Menu section quản lý thời khóa biểu', 1),
    ('PERM_ADM_SYSTEM', 'ADMIN_SECTION_SYSTEM', N'HỆ THỐNG', NULL, 'fas fa-cog', 8, N'Menu section hệ thống', 1);
END

-- Admin Child Permissions
IF NOT EXISTS (SELECT 1 FROM permissions WHERE permission_code = 'ADMIN_DASHBOARD')
BEGIN
    INSERT INTO dbo.permissions (permission_id, permission_code, permission_name, parent_code, icon, sort_order, description, is_active) VALUES
    ('PERM_ADM_DASHBOARD', 'ADMIN_DASHBOARD', N'Dashboard', 'ADMIN_SECTION_OVERVIEW', 'fas fa-tachometer-alt', 1, N'Dashboard admin', 1),
    ('PERM_ADM_USERS_ITEM', 'ADMIN_USERS', N'Tài khoản', 'ADMIN_SECTION_USERS', 'fas fa-users', 1, N'Quản lý tài khoản', 1),
    ('PERM_ADM_ROLES', 'ADMIN_ROLES', N'Vai trò & quyền', 'ADMIN_SECTION_USERS', 'fas fa-shield-alt', 2, N'Quản lý vai trò và quyền', 1),
    ('PERM_ADM_ORGANIZATION', 'ADMIN_ORGANIZATION', N'Quản lý đào tạo', 'ADMIN_SECTION_ACADEMIC', 'fas fa-sitemap', 1, N'Quản lý tổ chức đào tạo', 1),
    ('PERM_ADM_STUDENTS', 'ADMIN_STUDENTS', N'Sinh viên', 'ADMIN_SECTION_ACADEMIC', 'fas fa-user-graduate', 2, N'Quản lý sinh viên', 1),
    ('PERM_ADM_LECTURERS', 'ADMIN_LECTURERS', N'Giảng viên', 'ADMIN_SECTION_ACADEMIC', 'fas fa-chalkboard-teacher', 3, N'Quản lý giảng viên', 1),
    ('PERM_ADM_ACADEMIC_YEARS', 'ADMIN_ACADEMIC_YEARS', N'Niên khóa', 'ADMIN_SECTION_ACADEMIC', 'fas fa-calendar-alt', 4, N'Quản lý niên khóa', 1),
    ('PERM_ADM_SCHOOL_YEARS', 'ADMIN_SCHOOL_YEARS', N'Năm học', 'ADMIN_SECTION_ACADEMIC', 'fas fa-calendar-check', 5, N'Quản lý năm học', 1),
    ('PERM_ADM_SUBJECT_PREREQUISITES', 'ADMIN_SUBJECT_PREREQUISITES', N'Tiên quyết', 'ADMIN_SECTION_SUBJECTS', 'fas fa-project-diagram', 1, N'Quản lý tiên quyết môn học', 1),
    ('PERM_ADM_CLASSES', 'ADMIN_CLASSES', N'Lớp học phần', 'ADMIN_SECTION_SUBJECTS', 'fas fa-chalkboard', 2, N'Quản lý lớp học phần', 1),
    ('PERM_ADM_ADMIN_CLASSES', 'ADMIN_ADMIN_CLASSES', N'Lớp chính khóa', 'ADMIN_SECTION_CLASSES', 'fas fa-users-class', 1, N'Quản lý lớp chính khóa', 1),
    ('PERM_ADM_REGISTRATION_PERIODS', 'ADMIN_REGISTRATION_PERIODS', N'Đợt đăng ký', 'ADMIN_SECTION_ENROLLMENT', 'fas fa-clock', 1, N'Quản lý đợt đăng ký học phần', 1),
    ('PERM_ADM_ENROLLMENTS', 'ADMIN_ENROLLMENTS', N'Quản lý đăng ký', 'ADMIN_SECTION_ENROLLMENT', 'fas fa-clipboard-list', 2, N'Quản lý đăng ký học phần', 1),
    ('PERM_ADM_TIMETABLE_ITEM', 'ADMIN_TIMETABLE', N'Xếp lịch', 'ADMIN_SECTION_TIMETABLE', 'fas fa-calendar-alt', 1, N'Quản lý thời khóa biểu', 1),
    ('PERM_ADM_AUDIT_LOGS', 'ADMIN_AUDIT_LOGS', N'Nhật ký hệ thống', 'ADMIN_SECTION_SYSTEM', 'fas fa-history', 1, N'Xem nhật ký hệ thống', 1),
    ('PERM_ADM_NOTIFICATIONS', 'ADMIN_NOTIFICATIONS', N'Thông báo', 'ADMIN_SECTION_SYSTEM', 'fas fa-bell', 2, N'Quản lý thông báo', 1);
END

PRINT '   ✅ Menu permissions created';
GO

-- ===========================================
-- 14. ROLE_PERMISSIONS (Assign Menu Permissions to Roles)
-- ===========================================
PRINT '🔗 Assigning Menu Permissions to Roles...';

-- Student Role - Assign all student permissions
IF NOT EXISTS (SELECT 1 FROM role_permissions WHERE role_id = 'ROLE_STUDENT' AND permission_id = 'PERM_STU_DASHBOARD')
BEGIN
    INSERT INTO dbo.role_permissions (role_id, permission_id) VALUES
    -- Student Overview
    ('ROLE_STUDENT', 'PERM_STU_OVERVIEW'),
    ('ROLE_STUDENT', 'PERM_STU_DASHBOARD'),
    -- Student Study
    ('ROLE_STUDENT', 'PERM_STU_STUDY'),
    ('ROLE_STUDENT', 'PERM_STU_TIMETABLE'),
    ('ROLE_STUDENT', 'PERM_STU_SCHEDULE'),
    ('ROLE_STUDENT', 'PERM_STU_GRADES'),
    ('ROLE_STUDENT', 'PERM_STU_ATTENDANCE'),
    ('ROLE_STUDENT', 'PERM_STU_ENROLLMENT'),
    -- Student Profile
    ('ROLE_STUDENT', 'PERM_STU_PROFILE'),
    ('ROLE_STUDENT', 'PERM_STU_PROFILE_ITEM'),
    -- Student System
    ('ROLE_STUDENT', 'PERM_STU_SYSTEM'),
    ('ROLE_STUDENT', 'PERM_STU_NOTIFICATIONS');
END

-- Lecturer Role - Assign all lecturer permissions
IF NOT EXISTS (SELECT 1 FROM role_permissions WHERE role_id = 'ROLE_LECTURER' AND permission_id = 'PERM_TCH_DASHBOARD')
BEGIN
    INSERT INTO dbo.role_permissions (role_id, permission_id) VALUES
    -- Lecturer Overview
    ('ROLE_LECTURER', 'PERM_TCH_OVERVIEW'),
    ('ROLE_LECTURER', 'PERM_TCH_DASHBOARD'),
    -- Lecturer Teaching
    ('ROLE_LECTURER', 'PERM_TCH_TEACHING'),
    ('ROLE_LECTURER', 'PERM_TCH_ATTENDANCE'),
    ('ROLE_LECTURER', 'PERM_TCH_GRADES'),
    ('ROLE_LECTURER', 'PERM_TCH_TIMETABLE'),
    -- Lecturer System
    ('ROLE_LECTURER', 'PERM_TCH_SYSTEM'),
    ('ROLE_LECTURER', 'PERM_TCH_NOTIFICATIONS');
END

-- Advisor Role - Assign all advisor permissions
IF NOT EXISTS (SELECT 1 FROM role_permissions WHERE role_id = 'ROLE_ADVISOR' AND permission_id = 'PERM_ADV_DASHBOARD')
BEGIN
    INSERT INTO dbo.role_permissions (role_id, permission_id) VALUES
    -- Advisor Overview
    ('ROLE_ADVISOR', 'PERM_ADV_OVERVIEW'),
    ('ROLE_ADVISOR', 'PERM_ADV_DASHBOARD'),
    -- Advisor Advising
    ('ROLE_ADVISOR', 'PERM_ADV_ADVISING'),
    ('ROLE_ADVISOR', 'PERM_ADV_STUDENTS'),
    ('ROLE_ADVISOR', 'PERM_ADV_WARNINGS'),
    -- Advisor System
    ('ROLE_ADVISOR', 'PERM_ADV_SYSTEM'),
    ('ROLE_ADVISOR', 'PERM_ADV_NOTIFICATIONS');
END

-- Admin Role - Assign all admin permissions
IF NOT EXISTS (SELECT 1 FROM role_permissions WHERE role_id = 'ROLE_ADMIN' AND permission_id = 'PERM_ADM_DASHBOARD')
BEGIN
    INSERT INTO dbo.role_permissions (role_id, permission_id) VALUES
    -- Admin Overview
    ('ROLE_ADMIN', 'PERM_ADM_OVERVIEW'),
    ('ROLE_ADMIN', 'PERM_ADM_DASHBOARD'),
    -- Admin Users
    ('ROLE_ADMIN', 'PERM_ADM_USERS'),
    ('ROLE_ADMIN', 'PERM_ADM_USERS_ITEM'),
    ('ROLE_ADMIN', 'PERM_ADM_ROLES'),
    -- Admin Academic
    ('ROLE_ADMIN', 'PERM_ADM_ACADEMIC'),
    ('ROLE_ADMIN', 'PERM_ADM_ORGANIZATION'),
    ('ROLE_ADMIN', 'PERM_ADM_STUDENTS'),
    ('ROLE_ADMIN', 'PERM_ADM_LECTURERS'),
    ('ROLE_ADMIN', 'PERM_ADM_ACADEMIC_YEARS'),
    ('ROLE_ADMIN', 'PERM_ADM_SCHOOL_YEARS'),
    -- Admin Subjects
    ('ROLE_ADMIN', 'PERM_ADM_SUBJECTS'),
    ('ROLE_ADMIN', 'PERM_ADM_SUBJECT_PREREQUISITES'),
    ('ROLE_ADMIN', 'PERM_ADM_CLASSES'),
    -- Admin Classes
    ('ROLE_ADMIN', 'PERM_ADM_ADMIN_CLASSES_SECTION'),
    ('ROLE_ADMIN', 'PERM_ADM_ADMIN_CLASSES'),
    -- Admin Enrollment
    ('ROLE_ADMIN', 'PERM_ADM_ENROLLMENT'),
    ('ROLE_ADMIN', 'PERM_ADM_REGISTRATION_PERIODS'),
    ('ROLE_ADMIN', 'PERM_ADM_ENROLLMENTS'),
    -- Admin Timetable
    ('ROLE_ADMIN', 'PERM_ADM_TIMETABLE'),
    ('ROLE_ADMIN', 'PERM_ADM_TIMETABLE_ITEM'),
    -- Admin System
    ('ROLE_ADMIN', 'PERM_ADM_SYSTEM'),
    ('ROLE_ADMIN', 'PERM_ADM_AUDIT_LOGS'),
    ('ROLE_ADMIN', 'PERM_ADM_NOTIFICATIONS');
END

PRINT '   ✅ Menu permissions assigned to roles';
GO

-- ===========================================
-- 15. SAMPLE NOTIFICATION
-- ===========================================
PRINT '🔔 Seeding Notifications...';

IF NOT EXISTS (SELECT 1 FROM notifications WHERE notification_id = 'NOTIF001')
BEGIN
    INSERT INTO dbo.notifications (notification_id, user_id, title, message, is_read) VALUES
    ('NOTIF001', 'USER003', N'Chào mừng K21', N'Chào mừng bạn đến với năm cuối cùng của Khóa 21!', 0),
    ('NOTIF002', 'USER007', N'Chào mừng K24', N'Chào mừng tân sinh viên Khóa 24! Chúc bạn có 4 năm học tập thật tốt!', 0);
    
    PRINT '   ✅ 2 notifications created';
END
ELSE
    PRINT '   ⚠️  Notifications already exist';
GO

PRINT '';
PRINT '╔════════════════════════════════════════════════╗';
PRINT '║     ✅ SEED DATA COMPLETED (AUTOMATED)         ║';
PRINT '╚════════════════════════════════════════════════╝';
PRINT '';
PRINT '📊 Summary:';
PRINT '   ✅ 4 Roles';
PRINT '   ✅ 8 Users (1 Admin, 1 Lecturer, 1 Advisor, 5 Students)';
PRINT '   ✅ 1 Faculty';
PRINT '   ✅ 2 Departments';
PRINT '   ✅ 2 Majors';
PRINT '   ✅ 4 Cohorts (K21, K22, K23, K24) - 16 school years total';
PRINT '   ✅ Active: School Year 2024-2025, Semester 1';
PRINT '   ✅ 2 Lecturers (1 lecturer, 1 advisor)';
PRINT '   ✅ 5 Students (distributed across K21-K24)';
PRINT '   ✅ 4 Subjects (year 1-3 courses)';
PRINT '   ✅ 4 Classes (2024-2025 HK1)';
PRINT '   ✅ 6 Enrollments';
PRINT '   ✅ 6 Grades';
PRINT '   ✅ 50+ Menu Permissions (Student: 12, Lecturer: 8, Advisor: 7, Admin: 24)';
PRINT '';
PRINT '🔑 Login Credentials:';
PRINT '   👤 Admin:        admin / admin123';
PRINT '   👨‍🏫 Lecturer:     lecturer01 / password123';
PRINT '   🎓 Advisor:      advisor01 / password123';
PRINT '   👨‍🎓 Student K21:  student_k21_01, student_k21_02 (Year 4) / password123';
PRINT '   👨‍🎓 Student K22:  student_k22_01 (Year 3) / password123';
PRINT '   👨‍🎓 Student K23:  student_k23_01 (Year 2) / password123';
PRINT '   👨‍🎓 Student K24:  student_k24_01 (Year 1 - Freshman) / password123';
PRINT '';
PRINT '🎯 Test Automation:';
PRINT '   • EXEC sp_GetCurrentSchoolYearAndSemester;';
PRINT '   • EXEC sp_AutoTransitionSemester;';
PRINT '   • EXEC sp_AutoCreateCohort @StartYear = 2025;';
PRINT '';
GO

