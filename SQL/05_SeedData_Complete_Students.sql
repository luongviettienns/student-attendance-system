-- ===========================================
-- 🎓 SEED DATA: SINH VIÊN ĐẦY ĐỦ THÔNG TIN
-- ===========================================
-- 
-- Mục đích: Tạo dữ liệu mẫu với sinh viên có ĐẦY ĐỦ thông tin:
-- - Administrative Classes (lớp hành chính)
-- - Students với đầy đủ thông tin (admin_class_id, faculty_id, cohort_year, etc.)
--
-- ===========================================

USE EducationManagement;
GO

SET QUOTED_IDENTIFIER ON;
GO

PRINT '🌱 Bắt đầu seed data cho sinh viên đầy đủ thông tin...';
GO

-- ===========================================
-- 1. TẠO ADMINISTRATIVE_CLASSES (Lớp hành chính)
-- ===========================================
PRINT '📚 Seeding Administrative Classes...';

-- Lớp hành chính cho K21 (Công nghệ Phần mềm)
IF NOT EXISTS (SELECT 1 FROM administrative_classes WHERE admin_class_id = 'ADMCLS001')
BEGIN
    INSERT INTO dbo.administrative_classes (
        admin_class_id, class_code, class_name,
        major_id, advisor_id, academic_year_id,
        cohort_year, max_students, current_students,
        description, is_active, created_at, created_by
    ) VALUES (
        'ADMCLS001', 'K21-CNPM-01', N'Lớp K21 Công nghệ Phần mềm 01',
        'MAJ001', NULL, 'AY2021',
        2021, 50, 0,
        N'Lớp hành chính cho sinh viên K21 ngành Công nghệ Phần mềm', 1, GETDATE(), 'system'
    );
    PRINT '   ✅ Tạo lớp: ADMCLS001 - K21-CNPM-01';
END

-- Lớp hành chính cho K22 (Khoa học Dữ liệu)
IF NOT EXISTS (SELECT 1 FROM administrative_classes WHERE admin_class_id = 'ADMCLS002')
BEGIN
    INSERT INTO dbo.administrative_classes (
        admin_class_id, class_code, class_name,
        major_id, advisor_id, academic_year_id,
        cohort_year, max_students, current_students,
        description, is_active, created_at, created_by
    ) VALUES (
        'ADMCLS002', 'K22-KHDL-01', N'Lớp K22 Khoa học Dữ liệu 01',
        'MAJ002', NULL, 'AY2022',
        2022, 50, 0,
        N'Lớp hành chính cho sinh viên K22 ngành Khoa học Dữ liệu', 1, GETDATE(), 'system'
    );
    PRINT '   ✅ Tạo lớp: ADMCLS002 - K22-KHDL-01';
END

-- Lớp hành chính cho K23 (Công nghệ Phần mềm)
IF NOT EXISTS (SELECT 1 FROM administrative_classes WHERE admin_class_id = 'ADMCLS003')
BEGIN
    INSERT INTO dbo.administrative_classes (
        admin_class_id, class_code, class_name,
        major_id, advisor_id, academic_year_id,
        cohort_year, max_students, current_students,
        description, is_active, created_at, created_by
    ) VALUES (
        'ADMCLS003', 'K23-CNPM-01', N'Lớp K23 Công nghệ Phần mềm 01',
        'MAJ001', NULL, 'AY2023',
        2023, 50, 0,
        N'Lớp hành chính cho sinh viên K23 ngành Công nghệ Phần mềm', 1, GETDATE(), 'system'
    );
    PRINT '   ✅ Tạo lớp: ADMCLS003 - K23-CNPM-01';
END

-- Lớp hành chính cho K24 (Khoa học Dữ liệu)
IF NOT EXISTS (SELECT 1 FROM administrative_classes WHERE admin_class_id = 'ADMCLS004')
BEGIN
    INSERT INTO dbo.administrative_classes (
        admin_class_id, class_code, class_name,
        major_id, advisor_id, academic_year_id,
        cohort_year, max_students, current_students,
        description, is_active, created_at, created_by
    ) VALUES (
        'ADMCLS004', 'K24-KHDL-01', N'Lớp K24 Khoa học Dữ liệu 01',
        'MAJ002', NULL, 'AY2024',
        2024, 50, 0,
        N'Lớp hành chính cho sinh viên K24 ngành Khoa học Dữ liệu', 1, GETDATE(), 'system'
    );
    PRINT '   ✅ Tạo lớp: ADMCLS004 - K24-KHDL-01';
END

PRINT '   ✅ Hoàn thành tạo administrative_classes';
GO

-- ===========================================
-- 2. CẬP NHẬT STUDENTS CÓ SẴN VỚI ĐẦY ĐỦ THÔNG TIN
-- ===========================================
PRINT '👨‍🎓 Cập nhật students có sẵn với đầy đủ thông tin...';

-- Cập nhật STU001 (K21, MAJ001) - Gán vào ADMCLS001
IF EXISTS (SELECT 1 FROM students WHERE student_id = 'STU001')
BEGIN
    UPDATE dbo.students
    SET 
        faculty_id = 'FAC001',
        admin_class_id = 'ADMCLS001',
        cohort_year = 2021,
        address = N'123 Đường ABC, Quận 1, TP.HCM',
        updated_at = GETDATE(),
        updated_by = 'system'
    WHERE student_id = 'STU001';
    PRINT '   ✅ Cập nhật STU001 - Lê Văn An (K21, CNPM, Lớp ADMCLS001)';
END

-- Cập nhật STU002 (K21, MAJ001) - Gán vào ADMCLS001
IF EXISTS (SELECT 1 FROM students WHERE student_id = 'STU002')
BEGIN
    UPDATE dbo.students
    SET 
        faculty_id = 'FAC001',
        admin_class_id = 'ADMCLS001',
        cohort_year = 2021,
        address = N'456 Đường XYZ, Quận 2, TP.HCM',
        updated_at = GETDATE(),
        updated_by = 'system'
    WHERE student_id = 'STU002';
    PRINT '   ✅ Cập nhật STU002 - Phạm Thị Bình (K21, CNPM, Lớp ADMCLS001)';
END

-- Cập nhật STU003 (K22, MAJ002) - Gán vào ADMCLS002
IF EXISTS (SELECT 1 FROM students WHERE student_id = 'STU003')
BEGIN
    UPDATE dbo.students
    SET 
        faculty_id = 'FAC001',
        admin_class_id = 'ADMCLS002',
        cohort_year = 2022,
        address = N'789 Đường DEF, Quận 3, TP.HCM',
        updated_at = GETDATE(),
        updated_by = 'system'
    WHERE student_id = 'STU003';
    PRINT '   ✅ Cập nhật STU003 - Nguyễn Văn Cường (K22, KHDL, Lớp ADMCLS002)';
END

-- Cập nhật STU004 (K23, MAJ001) - Gán vào ADMCLS003
IF EXISTS (SELECT 1 FROM students WHERE student_id = 'STU004')
BEGIN
    UPDATE dbo.students
    SET 
        faculty_id = 'FAC001',
        admin_class_id = 'ADMCLS003',
        cohort_year = 2023,
        address = N'321 Đường GHI, Quận 4, TP.HCM',
        updated_at = GETDATE(),
        updated_by = 'system'
    WHERE student_id = 'STU004';
    PRINT '   ✅ Cập nhật STU004 - Hoàng Thị Dung (K23, CNPM, Lớp ADMCLS003)';
END

-- Cập nhật STU005 (K24, MAJ002) - Gán vào ADMCLS004
IF EXISTS (SELECT 1 FROM students WHERE student_id = 'STU005')
BEGIN
    UPDATE dbo.students
    SET 
        faculty_id = 'FAC001',
        admin_class_id = 'ADMCLS004',
        cohort_year = 2024,
        address = N'654 Đường JKL, Quận 5, TP.HCM',
        updated_at = GETDATE(),
        updated_by = 'system'
    WHERE student_id = 'STU005';
    PRINT '   ✅ Cập nhật STU005 - Đinh Văn Em (K24, KHDL, Lớp ADMCLS004)';
END

-- Cập nhật current_students trong administrative_classes
UPDATE dbo.administrative_classes
SET current_students = (
    SELECT COUNT(*) 
    FROM students 
    WHERE admin_class_id = administrative_classes.admin_class_id 
        AND deleted_at IS NULL
),
updated_at = GETDATE(),
updated_by = 'system'
WHERE deleted_at IS NULL;

PRINT '   ✅ Cập nhật current_students cho các lớp';
GO

-- ===========================================
-- 3. TẠO SINH VIÊN MỚI VỚI ĐẦY ĐỦ THÔNG TIN
-- ===========================================
PRINT '👨‍🎓 Tạo sinh viên mới với đầy đủ thông tin...';

-- Sinh viên mới 1: K21 CNPM
IF NOT EXISTS (SELECT 1 FROM users WHERE user_id = 'USER014')
BEGIN
    INSERT INTO dbo.users (user_id, username, password_hash, email, phone, full_name, role_id, is_active) VALUES
    ('USER014', 'student_complete01', '$2a$10$Ya6MFL1CGpg2/y088u6t7.ACYkMJdmA1869rbBmAnyn6OQi0hTBue', 'student.complete01@example.com', '0914444444', N'Trần Thị Đầy Đủ', 'ROLE_STUDENT', 1);
END

IF NOT EXISTS (SELECT 1 FROM students WHERE student_id = 'STU011')
BEGIN
    INSERT INTO dbo.students (
        student_id, user_id, student_code, full_name, gender, date_of_birth, 
        email, phone, address, 
        faculty_id, major_id, admin_class_id, academic_year_id, cohort_year,
        is_active, created_at, created_by
    ) VALUES (
        'STU011', 'USER014', 'SV2021011', N'Trần Thị Đầy Đủ', N'Nữ', '2003-06-15',
        'student.complete01@example.com', '0914444444', N'111 Đường Mẫu, Quận 1, TP.HCM',
        'FAC001', 'MAJ001', 'ADMCLS001', 'AY2021', 2021,
        1, GETDATE(), 'system'
    );
    PRINT '   ✅ Tạo STU011 - Trần Thị Đầy Đủ (K21, CNPM, Lớp ADMCLS001)';
END

-- Sinh viên mới 2: K22 KHDL
IF NOT EXISTS (SELECT 1 FROM users WHERE user_id = 'USER015')
BEGIN
    INSERT INTO dbo.users (user_id, username, password_hash, email, phone, full_name, role_id, is_active) VALUES
    ('USER015', 'student_complete02', '$2a$10$Ya6MFL1CGpg2/y088u6t7.ACYkMJdmA1869rbBmAnyn6OQi0hTBue', 'student.complete02@example.com', '0915555555', N'Lê Văn Hoàn Chỉnh', 'ROLE_STUDENT', 1);
END

IF NOT EXISTS (SELECT 1 FROM students WHERE student_id = 'STU012')
BEGIN
    INSERT INTO dbo.students (
        student_id, user_id, student_code, full_name, gender, date_of_birth, 
        email, phone, address, 
        faculty_id, major_id, admin_class_id, academic_year_id, cohort_year,
        is_active, created_at, created_by
    ) VALUES (
        'STU012', 'USER015', 'SV2022012', N'Lê Văn Hoàn Chỉnh', N'Nam', '2004-07-20',
        'student.complete02@example.com', '0915555555', N'222 Đường Mẫu, Quận 2, TP.HCM',
        'FAC001', 'MAJ002', 'ADMCLS002', 'AY2022', 2022,
        1, GETDATE(), 'system'
    );
    PRINT '   ✅ Tạo STU012 - Lê Văn Hoàn Chỉnh (K22, KHDL, Lớp ADMCLS002)';
END

-- Sinh viên mới 3: K23 CNPM
IF NOT EXISTS (SELECT 1 FROM users WHERE user_id = 'USER016')
BEGIN
    INSERT INTO dbo.users (user_id, username, password_hash, email, phone, full_name, role_id, is_active) VALUES
    ('USER016', 'student_complete03', '$2a$10$Ya6MFL1CGpg2/y088u6t7.ACYkMJdmA1869rbBmAnyn6OQi0hTBue', 'student.complete03@example.com', '0916666666', N'Phạm Thị Đầy Đủ Thông Tin', 'ROLE_STUDENT', 1);
END

IF NOT EXISTS (SELECT 1 FROM students WHERE student_id = 'STU013')
BEGIN
    INSERT INTO dbo.students (
        student_id, user_id, student_code, full_name, gender, date_of_birth, 
        email, phone, address, 
        faculty_id, major_id, admin_class_id, academic_year_id, cohort_year,
        is_active, created_at, created_by
    ) VALUES (
        'STU013', 'USER016', 'SV2023013', N'Phạm Thị Đầy Đủ Thông Tin', N'Nữ', '2005-08-25',
        'student.complete03@example.com', '0916666666', N'333 Đường Mẫu, Quận 3, TP.HCM',
        'FAC001', 'MAJ001', 'ADMCLS003', 'AY2023', 2023,
        1, GETDATE(), 'system'
    );
    PRINT '   ✅ Tạo STU013 - Phạm Thị Đầy Đủ Thông Tin (K23, CNPM, Lớp ADMCLS003)';
END

-- Cập nhật lại current_students sau khi thêm sinh viên mới
UPDATE dbo.administrative_classes
SET current_students = (
    SELECT COUNT(*) 
    FROM students 
    WHERE admin_class_id = administrative_classes.admin_class_id 
        AND deleted_at IS NULL
),
updated_at = GETDATE(),
updated_by = 'system'
WHERE deleted_at IS NULL;

PRINT '   ✅ Hoàn thành tạo sinh viên mới';
GO

-- ===========================================
-- 4. KIỂM TRA KẾT QUẢ
-- ===========================================
PRINT '';
PRINT '========================================';
PRINT '📊 KIỂM TRA KẾT QUẢ';
PRINT '========================================';
PRINT '';

-- Đếm số lượng
DECLARE @ClassCount INT = (SELECT COUNT(*) FROM administrative_classes WHERE deleted_at IS NULL);
DECLARE @StudentWithClass INT = (SELECT COUNT(*) FROM students WHERE deleted_at IS NULL AND admin_class_id IS NOT NULL);
DECLARE @StudentWithoutClass INT = (SELECT COUNT(*) FROM students WHERE deleted_at IS NULL AND admin_class_id IS NULL);

PRINT CONCAT('📚 Số lớp hành chính: ', @ClassCount);
PRINT CONCAT('✅ Số sinh viên CÓ lớp: ', @StudentWithClass);
PRINT CONCAT('⚠️  Số sinh viên CHƯA có lớp: ', @StudentWithoutClass);
PRINT '';

-- Hiển thị danh sách sinh viên có đầy đủ thông tin
PRINT '📋 Danh sách sinh viên có đầy đủ thông tin:';
SELECT 
    s.student_id,
    s.student_code,
    s.full_name,
    s.gender,
    s.cohort_year,
    s.faculty_id,
    f.faculty_name,
    s.major_id,
    m.major_name,
    s.admin_class_id,
    ac.class_code,
    ac.class_name,
    s.academic_year_id,
    ay.year_name as academic_year_name,
    s.address,
    s.email,
    s.phone
FROM students s
LEFT JOIN faculties f ON s.faculty_id = f.faculty_id
LEFT JOIN majors m ON s.major_id = m.major_id
LEFT JOIN administrative_classes ac ON s.admin_class_id = ac.admin_class_id
LEFT JOIN academic_years ay ON s.academic_year_id = ay.academic_year_id
WHERE s.deleted_at IS NULL
    AND s.admin_class_id IS NOT NULL
    AND s.faculty_id IS NOT NULL
    AND s.cohort_year IS NOT NULL
ORDER BY s.cohort_year, s.student_code;

PRINT '';
PRINT '========================================';
PRINT '✅ SEED DATA HOÀN TẤT';
PRINT '========================================';
PRINT '';
PRINT '📝 Tóm tắt:';
PRINT '   ✅ Đã tạo 4 administrative_classes';
PRINT '   ✅ Đã cập nhật 5 students có sẵn với đầy đủ thông tin';
PRINT '   ✅ Đã tạo 3 students mới với đầy đủ thông tin';
PRINT '   ✅ Tất cả students đã được gán vào lớp hành chính';
PRINT '   ✅ Tất cả students đã có faculty_id, cohort_year, address';
PRINT '';

