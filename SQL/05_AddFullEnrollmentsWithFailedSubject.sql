-- ===========================================
-- THÊM ENROLLMENT ĐẦY ĐỦ CHO SINH VIÊN (CÓ MÔN TRƯỢT)
-- Sinh viên: STU_K21_001 - Trần Nhật Minh (K21SE001)
-- Năm học: SY2024, Học kỳ: 1
-- Lưu ý: Có 1 môn trượt (BUS201 - Marketing số)
-- ===========================================

USE EducationManagement;
GO

SET NOCOUNT ON;
PRINT '========================================';
PRINT 'Thêm enrollment đầy đủ cho STU_K21_001';
PRINT 'Bao gồm: 1 môn trượt (BUS201)';
PRINT 'Năm học: SY2024, Học kỳ: 1';
PRINT '========================================';
GO

-- ===========================================
-- 1. THÊM ENROLLMENT CHO BUS201 (MÔN TRƯỢT)
-- ===========================================
PRINT '';
PRINT '📝 Thêm enrollment cho BUS201 (Marketing số - MÔN TRƯỢT)...';

MERGE dbo.enrollments AS target
USING (VALUES
    -- STU_K21_001 đăng ký BUS201 - Marketing số (môn trượt)
    ('ENR_K21_001_BUS201', 'STU_K21_001', 'CLS_BUS201_2024', DATEFROMPARTS(2024,8,27), N'Dang hoc', 'APPROVED', DATEFROMPARTS(2024,9,10), N'Dang ky mon tu chon - Marketing so', NULL)
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
               updated_by = 'add_full_enrollments_failed'
WHEN NOT MATCHED THEN
    INSERT (enrollment_id, student_id, class_id, enrollment_date, status, enrollment_status,
            drop_deadline, notes, drop_reason, created_by)
    VALUES (src.enrollment_id, src.student_id, src.class_id, src.enrollment_date, src.status, src.enrollment_status,
            src.drop_deadline, src.notes, src.drop_reason, 'add_full_enrollments_failed');
GO

PRINT '   ✅ Đã thêm enrollment BUS201 cho STU_K21_001';
GO

-- ===========================================
-- 2. THÊM GRADE CHO BUS201 (ĐIỂM TRƯỢT - F)
-- ===========================================
PRINT '';
PRINT '💯 Thêm grade cho BUS201 (ĐIỂM TRƯỢT - F)...';

MERGE dbo.grades AS target
USING (VALUES
    -- Điểm trượt cho BUS201 - Marketing số
    -- Giữa kỳ: 3.0, Cuối kỳ: 3.5, Tổng kết: 3.3 (F - Trượt)
    ('GRD_K21_001_BUS201', 'ENR_K21_001_BUS201', 3.0, 3.5, 3.3, 'F')
) AS src(grade_id, enrollment_id, midterm_score, final_score, total_score, letter_grade)
ON target.grade_id = src.grade_id
WHEN MATCHED THEN
    UPDATE SET enrollment_id = src.enrollment_id,
               midterm_score = src.midterm_score,
               final_score = src.final_score,
               total_score = src.total_score,
               letter_grade = src.letter_grade,
               updated_at = GETDATE(),
               updated_by = 'add_full_enrollments_failed'
WHEN NOT MATCHED THEN
    INSERT (grade_id, enrollment_id, midterm_score, final_score, total_score, letter_grade, created_by)
    VALUES (src.grade_id, src.enrollment_id, src.midterm_score, src.final_score, src.total_score, src.letter_grade, 'add_full_enrollments_failed');
GO

PRINT '   ✅ Đã thêm grade BUS201: 3.3 (F - Trượt)';
GO

-- ===========================================
-- 3. CẬP NHẬT GPA CHO HK1 SY2024 (CÓ ĐIỂM TRƯỢT)
-- ===========================================
PRINT '';
PRINT '📊 Cập nhật GPA HK1 SY2024 (có điểm trượt)...';

-- Tính lại GPA từ các điểm:
-- SE101: 8.8 (A) - 3 credits
-- SE201: 7.8 (B) - 3 credits  
-- DS101: 8.3 (A) - 3 credits
-- BUS201: 3.3 (F) - 3 credits (TRƯỢT)
-- Tổng: 12 credits
-- GPA = (8.8*3 + 7.8*3 + 8.3*3 + 3.3*3) / 12 = (26.4 + 23.4 + 24.9 + 9.9) / 12 = 84.6 / 12 = 7.05

MERGE dbo.gpas AS target
USING (VALUES
    ('GPA_K21_001_SY2024_S1', 'STU_K21_001', 'AY2021', 'SY2024', 1, 7.05, 2.8, 12, 129, N'Kha', 1)
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
               updated_by = 'add_full_enrollments_failed'
WHEN NOT MATCHED THEN
    INSERT (gpa_id, student_id, academic_year_id, school_year_id, semester,
            gpa10, gpa4, total_credits, accumulated_credits, rank_text, is_active, created_by)
    VALUES (src.gpa_id, src.student_id, src.academic_year_id, src.school_year_id, src.semester,
            src.gpa10, src.gpa4, src.total_credits, src.accumulated_credits, src.rank_text, src.is_active, 'add_full_enrollments_failed');
GO

PRINT '   ✅ Đã cập nhật GPA HK1 SY2024: 7.05 (Khá) - Có 1 môn trượt';
GO

-- ===========================================
-- 4. THÊM ATTENDANCE RECORDS CHO BUS201
-- ===========================================
PRINT '';
PRINT '📅 Thêm attendance records cho BUS201...';

MERGE dbo.attendances AS target
USING (VALUES
    -- Attendance cho BUS201 (có vắng mặt - dẫn đến trượt)
    ('ATT_K21_001_BUS201_01', 'ENR_K21_001_BUS201', 'CLS_BUS201_2024', DATEFROMPARTS(2024,9,5),  N'Present', N'Co mat dung gio'),
    ('ATT_K21_001_BUS201_02', 'ENR_K21_001_BUS201', 'CLS_BUS201_2024', DATEFROMPARTS(2024,9,12), N'Absent', N'Vang mat khong phep'),
    ('ATT_K21_001_BUS201_03', 'ENR_K21_001_BUS201', 'CLS_BUS201_2024', DATEFROMPARTS(2024,9,19), N'Late', N'Tre 10 phut'),
    ('ATT_K21_001_BUS201_04', 'ENR_K21_001_BUS201', 'CLS_BUS201_2024', DATEFROMPARTS(2024,9,26), N'Absent', N'Vang mat khong phep'),
    ('ATT_K21_001_BUS201_05', 'ENR_K21_001_BUS201', 'CLS_BUS201_2024', DATEFROMPARTS(2024,10,3), N'Present', N'Co mat dung gio')
) AS src(attendance_id, enrollment_id, class_id, attendance_date, status, note)
ON target.attendance_id = src.attendance_id
WHEN MATCHED THEN
    UPDATE SET enrollment_id = src.enrollment_id,
               class_id = src.class_id,
               attendance_date = src.attendance_date,
               status = src.status,
               note = src.note,
               updated_at = GETDATE(),
               updated_by = 'add_full_enrollments_failed'
WHEN NOT MATCHED THEN
    INSERT (attendance_id, enrollment_id, class_id, attendance_date, status, note, created_by)
    VALUES (src.attendance_id, src.enrollment_id, src.class_id, src.attendance_date, src.status, src.note, 'add_full_enrollments_failed');
GO

PRINT '   ✅ Đã thêm 5 attendance records (có vắng mặt)';
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

-- Kiểm tra tất cả enrollments trong HK1 SY2024
PRINT '📝 TẤT CẢ ENROLLMENTS trong HK1 SY2024:';
SELECT 
    e.enrollment_id,
    c.class_code,
    c.class_name,
    sub.subject_code,
    sub.subject_name,
    sub.credits,
    e.status,
    e.enrollment_status,
    CASE 
        WHEN g.grade_id IS NOT NULL THEN CONCAT(g.total_score, ' (', g.letter_grade, ')')
        ELSE N'Chưa có điểm'
    END AS grade_info
FROM dbo.enrollments e
INNER JOIN dbo.classes c ON e.class_id = c.class_id
INNER JOIN dbo.subjects sub ON c.subject_id = sub.subject_id
LEFT JOIN dbo.grades g ON g.enrollment_id = e.enrollment_id
WHERE e.student_id = 'STU_K21_001'
  AND c.school_year_id = 'SY2024'
  AND c.semester = 1
  AND e.deleted_at IS NULL
ORDER BY c.class_code;
GO

-- Kiểm tra tất cả grades
PRINT '';
PRINT '💯 TẤT CẢ GRADES trong HK1 SY2024:';
SELECT 
    g.grade_id,
    c.class_code,
    sub.subject_name,
    g.midterm_score,
    g.final_score,
    g.total_score,
    g.letter_grade,
    CASE 
        WHEN g.letter_grade = 'F' THEN N'❌ TRƯỢT'
        WHEN g.letter_grade IN ('D', 'D+') THEN N'⚠️ YẾU'
        WHEN g.letter_grade IN ('C', 'C+') THEN N'✓ TRUNG BÌNH'
        WHEN g.letter_grade IN ('B', 'B+') THEN N'✓✓ KHÁ'
        WHEN g.letter_grade IN ('A', 'A+') THEN N'✓✓✓ GIỎI'
        ELSE N'—'
    END AS status_text
FROM dbo.grades g
INNER JOIN dbo.enrollments e ON g.enrollment_id = e.enrollment_id
INNER JOIN dbo.classes c ON e.class_id = c.class_id
INNER JOIN dbo.subjects sub ON c.subject_id = sub.subject_id
WHERE e.student_id = 'STU_K21_001'
  AND c.school_year_id = 'SY2024'
  AND c.semester = 1
  AND e.deleted_at IS NULL
ORDER BY 
    CASE g.letter_grade
        WHEN 'F' THEN 1
        WHEN 'D' THEN 2
        WHEN 'C' THEN 3
        WHEN 'B' THEN 4
        WHEN 'A' THEN 5
        ELSE 6
    END,
    c.class_code;
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
    gpa.rank_text,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM dbo.grades g
            INNER JOIN dbo.enrollments e ON g.enrollment_id = e.enrollment_id
            INNER JOIN dbo.classes c ON e.class_id = c.class_id
            WHERE e.student_id = gpa.student_id
              AND c.school_year_id = gpa.school_year_id
              AND c.semester = gpa.semester
              AND g.letter_grade = 'F'
              AND e.deleted_at IS NULL
        ) THEN N'⚠️ CÓ MÔN TRƯỢT'
        ELSE N'✓ KHÔNG CÓ MÔN TRƯỢT'
    END AS failed_subjects_status
FROM dbo.gpas gpa
WHERE gpa.student_id = 'STU_K21_001'
  AND gpa.school_year_id = 'SY2024'
  AND gpa.semester = 1
  AND gpa.deleted_at IS NULL;
GO

-- Thống kê điểm
PRINT '';
PRINT '📈 THỐNG KÊ ĐIỂM:';
SELECT 
    COUNT(*) AS total_subjects,
    SUM(CASE WHEN g.letter_grade = 'A' THEN 1 ELSE 0 END) AS grade_A,
    SUM(CASE WHEN g.letter_grade = 'B' THEN 1 ELSE 0 END) AS grade_B,
    SUM(CASE WHEN g.letter_grade = 'C' THEN 1 ELSE 0 END) AS grade_C,
    SUM(CASE WHEN g.letter_grade = 'D' THEN 1 ELSE 0 END) AS grade_D,
    SUM(CASE WHEN g.letter_grade = 'F' THEN 1 ELSE 0 END) AS grade_F,
    AVG(g.total_score) AS avg_score
FROM dbo.grades g
INNER JOIN dbo.enrollments e ON g.enrollment_id = e.enrollment_id
INNER JOIN dbo.classes c ON e.class_id = c.class_id
WHERE e.student_id = 'STU_K21_001'
  AND c.school_year_id = 'SY2024'
  AND c.semester = 1
  AND e.deleted_at IS NULL;
GO

PRINT '';
PRINT '========================================';
PRINT '✅ Script hoàn thành!';
PRINT '========================================';
PRINT '';
PRINT '📋 TÓM TẮT:';
PRINT '  - Đã thêm enrollment: BUS201 (Marketing số)';
PRINT '  - Đã thêm grade: 3.3 (F - TRƯỢT)';
PRINT '  - Đã cập nhật GPA: 7.05 (Khá)';
PRINT '  - Tổng số môn học: 4 môn';
PRINT '  - Số môn trượt: 1 môn (BUS201)';
PRINT '';
GO

