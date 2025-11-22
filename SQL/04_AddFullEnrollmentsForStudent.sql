-- ===========================================
-- THÊM ENROLLMENT VÀ ĐIỂM ĐẦY ĐỦ CHO SINH VIÊN
-- Sinh viên: STU_K21_001 - Trần Nhật Minh (K21SE001)
-- Năm học: SY2024, Học kỳ: 1
-- ===========================================

USE EducationManagement;
GO

SET NOCOUNT ON;
PRINT '========================================';
PRINT 'Thêm enrollment và điểm đầy đủ cho STU_K21_001';
PRINT 'Năm học: SY2024, Học kỳ: 1';
PRINT '========================================';
GO

-- ===========================================
-- 1. THÊM ENROLLMENTS CHO STU_K21_001 - HK1 SY2024
-- ===========================================
PRINT '📝 Thêm enrollments...';

MERGE dbo.enrollments AS target
USING (VALUES
    -- STU_K21_001 đăng ký các môn trong HK1 SY2024
    ('ENR_K21_001_SE101', 'STU_K21_001', 'CLS_SE101_2024', DATEFROMPARTS(2024,8,25), N'Dang hoc', 'APPROVED', DATEFROMPARTS(2024,9,9),  N'Dang ky mon co ban', NULL),
    ('ENR_K21_001_SE201', 'STU_K21_001', 'CLS_SE201_2024', DATEFROMPARTS(2024,8,25), N'Dang hoc', 'APPROVED', DATEFROMPARTS(2024,9,9),  N'Dang ky mon nang cao', NULL),
    ('ENR_K21_001_DS101', 'STU_K21_001', 'CLS_DS101_2024', DATEFROMPARTS(2024,8,26), N'Dang hoc', 'APPROVED', DATEFROMPARTS(2024,9,10), N'Hoc them mon du lieu', NULL)
) AS src(enrollment_id, student_id, class_id, enrollment_date, status, enrollment_status, drop_deadline, notes, drop_reason)
ON target.enrollment_id = src.enrollment_id
WHEN MATCHED THEN
    UPDATE SET student_id = src.student_id,
               class_id = src.class_id,
               enrollment_date = src.enrollment_date,
               status = src.status,
               enrollment_status = src.enrollment_status,
               drop_deadline = src.drop_deadline,
               notes = src.notes,
               drop_reason = src.drop_reason,
               updated_at = GETDATE(),
               updated_by = 'add_full_enrollments'
WHEN NOT MATCHED THEN
    INSERT (enrollment_id, student_id, class_id, enrollment_date, status, enrollment_status,
            drop_deadline, notes, drop_reason, created_by)
    VALUES (src.enrollment_id, src.student_id, src.class_id, src.enrollment_date, src.status, src.enrollment_status,
            src.drop_deadline, src.notes, src.drop_reason, 'add_full_enrollments');
GO

PRINT '   ✅ Đã thêm 3 enrollments cho STU_K21_001';
GO

-- ===========================================
-- 2. THÊM GRADES CHO CÁC ENROLLMENTS
-- ===========================================
PRINT '💯 Thêm grades...';

MERGE dbo.grades AS target
USING (VALUES
    -- Điểm cho SE101 - Lập trình .NET cơ bản (Điểm tốt)
    ('GRD_K21_001_SE101', 'ENR_K21_001_SE101', 8.5, 9.0, 8.8, 'A'),
    
    -- Điểm cho SE201 - Phân tích thiết kế hệ thống (Điểm khá)
    ('GRD_K21_001_SE201', 'ENR_K21_001_SE201', 7.5, 8.0, 7.8, 'B'),
    
    -- Điểm cho DS101 - Nhập môn Khoa học Dữ liệu (Điểm tốt)
    ('GRD_K21_001_DS101', 'ENR_K21_001_DS101', 8.0, 8.5, 8.3, 'A')
) AS src(grade_id, enrollment_id, midterm_score, final_score, total_score, letter_grade)
ON target.grade_id = src.grade_id
WHEN MATCHED THEN
    UPDATE SET enrollment_id = src.enrollment_id,
               midterm_score = src.midterm_score,
               final_score = src.final_score,
               total_score = src.total_score,
               letter_grade = src.letter_grade,
               updated_at = GETDATE(),
               updated_by = 'add_full_enrollments'
WHEN NOT MATCHED THEN
    INSERT (grade_id, enrollment_id, midterm_score, final_score, total_score, letter_grade, created_by)
    VALUES (src.grade_id, src.enrollment_id, src.midterm_score, src.final_score, src.total_score, src.letter_grade, 'add_full_enrollments');
GO

PRINT '   ✅ Đã thêm 3 grades cho STU_K21_001';
GO

-- ===========================================
-- 3. CẬP NHẬT GPA CHO HK1 SY2024
-- ===========================================
PRINT '📊 Cập nhật GPA HK1 SY2024...';

-- Tính GPA từ các điểm vừa thêm
-- SE101: 8.8 (A) - 3 credits
-- SE201: 7.8 (B) - 3 credits  
-- DS101: 8.3 (A) - 3 credits
-- Tổng: 9 credits
-- GPA = (8.8*3 + 7.8*3 + 8.3*3) / 9 = (26.4 + 23.4 + 24.9) / 9 = 74.7 / 9 = 8.3

MERGE dbo.gpas AS target
USING (VALUES
    ('GPA_K21_001_SY2024_S1', 'STU_K21_001', 'AY2021', 'SY2024', 1, 8.3, 3.3, 9, 129, N'Gioi', 1)
) AS src(gpa_id, student_id, academic_year_id, school_year_id, semester, gpa10, gpa4, total_credits, accumulated_credits, rank_text, is_active)
ON target.student_id = src.student_id 
   AND target.school_year_id = src.school_year_id 
   AND target.semester = src.semester
WHEN MATCHED THEN
    UPDATE SET gpa_id = src.gpa_id,
               academic_year_id = src.academic_year_id,
               gpa10 = src.gpa10,
               gpa4 = src.gpa4,
               total_credits = src.total_credits,
               accumulated_credits = src.accumulated_credits,
               rank_text = src.rank_text,
               is_active = src.is_active,
               updated_at = GETDATE(),
               updated_by = 'add_full_enrollments'
WHEN NOT MATCHED THEN
    INSERT (gpa_id, student_id, academic_year_id, school_year_id, semester,
            gpa10, gpa4, total_credits, accumulated_credits, rank_text, is_active, created_by)
    VALUES (src.gpa_id, src.student_id, src.academic_year_id, src.school_year_id, src.semester,
            src.gpa10, src.gpa4, src.total_credits, src.accumulated_credits, src.rank_text, src.is_active, 'add_full_enrollments');
GO

PRINT '   ✅ Đã cập nhật GPA HK1 SY2024: 8.3 (Giỏi)';
GO

-- ===========================================
-- 4. THÊM ATTENDANCE RECORDS (Tùy chọn)
-- ===========================================
PRINT '📅 Thêm attendance records...';

MERGE dbo.attendances AS target
USING (VALUES
    -- Attendance cho SE101
    ('ATT_K21_001_SE101_01', 'ENR_K21_001_SE101', 'CLS_SE101_2024', DATEFROMPARTS(2024,9,2),  N'Present', N'Co mat dung gio'),
    ('ATT_K21_001_SE101_02', 'ENR_K21_001_SE101', 'CLS_SE101_2024', DATEFROMPARTS(2024,9,9),  N'Present', N'Tham gia tich cuc'),
    ('ATT_K21_001_SE101_03', 'ENR_K21_001_SE101', 'CLS_SE101_2024', DATEFROMPARTS(2024,9,16), N'Present', N'Tra bai tap'),
    
    -- Attendance cho SE201
    ('ATT_K21_001_SE201_01', 'ENR_K21_001_SE201', 'CLS_SE201_2024', DATEFROMPARTS(2024,9,4),  N'Present', N'Co mat dung gio'),
    ('ATT_K21_001_SE201_02', 'ENR_K21_001_SE201', 'CLS_SE201_2024', DATEFROMPARTS(2024,9,11), N'Present', N'Tham gia thuc hanh'),
    
    -- Attendance cho DS101
    ('ATT_K21_001_DS101_01', 'ENR_K21_001_DS101', 'CLS_DS101_2024', DATEFROMPARTS(2024,9,6),  N'Present', N'Co mat dung gio'),
    ('ATT_K21_001_DS101_02', 'ENR_K21_001_DS101', 'CLS_DS101_2024', DATEFROMPARTS(2024,9,13), N'Present', N'Tra bai tap du')
) AS src(attendance_id, enrollment_id, class_id, attendance_date, status, note)
ON target.attendance_id = src.attendance_id
WHEN MATCHED THEN
    UPDATE SET enrollment_id = src.enrollment_id,
               class_id = src.class_id,
               attendance_date = src.attendance_date,
               status = src.status,
               note = src.note,
               updated_at = GETDATE(),
               updated_by = 'add_full_enrollments'
WHEN NOT MATCHED THEN
    INSERT (attendance_id, enrollment_id, class_id, attendance_date, status, note, created_by)
    VALUES (src.attendance_id, src.enrollment_id, src.class_id, src.attendance_date, src.status, src.note, 'add_full_enrollments');
GO

PRINT '   ✅ Đã thêm 7 attendance records';
GO

-- ===========================================
-- 5. KIỂM TRA KẾT QUẢ
-- ===========================================
PRINT '';
PRINT '========================================';
PRINT '✅ HOÀN THÀNH!';
PRINT '========================================';
PRINT '';
PRINT '📊 Tổng kết cho STU_K21_001 (Trần Nhật Minh):';
PRINT '';

-- Kiểm tra enrollments
PRINT '📝 Enrollments trong HK1 SY2024:';
SELECT 
    e.enrollment_id,
    c.class_code,
    c.class_name,
    sub.subject_code,
    sub.subject_name,
    sub.credits,
    e.status,
    e.enrollment_status
FROM dbo.enrollments e
INNER JOIN dbo.classes c ON e.class_id = c.class_id
INNER JOIN dbo.subjects sub ON c.subject_id = sub.subject_id
WHERE e.student_id = 'STU_K21_001'
  AND c.school_year_id = 'SY2024'
  AND c.semester = 1
  AND e.deleted_at IS NULL
ORDER BY c.class_code;
GO

-- Kiểm tra grades
PRINT '';
PRINT '💯 Grades trong HK1 SY2024:';
SELECT 
    g.grade_id,
    c.class_code,
    sub.subject_name,
    g.midterm_score,
    g.final_score,
    g.total_score,
    g.letter_grade
FROM dbo.grades g
INNER JOIN dbo.enrollments e ON g.enrollment_id = e.enrollment_id
INNER JOIN dbo.classes c ON e.class_id = c.class_id
INNER JOIN dbo.subjects sub ON c.subject_id = sub.subject_id
WHERE e.student_id = 'STU_K21_001'
  AND c.school_year_id = 'SY2024'
  AND c.semester = 1
  AND e.deleted_at IS NULL
ORDER BY c.class_code;
GO

-- Kiểm tra GPA
PRINT '';
PRINT '📊 GPA HK1 SY2024:';
SELECT 
    gpa.gpa_id,
    gpa.semester,
    gpa.gpa10,
    gpa.gpa4,
    gpa.total_credits,
    gpa.accumulated_credits,
    gpa.rank_text
FROM dbo.gpas gpa
WHERE gpa.student_id = 'STU_K21_001'
  AND gpa.school_year_id = 'SY2024'
  AND gpa.semester = 1
  AND gpa.deleted_at IS NULL;
GO

PRINT '';
PRINT '========================================';
PRINT '✅ Script hoàn thành!';
PRINT '========================================';
GO

