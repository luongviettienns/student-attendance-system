-- ===========================================
-- 🎓 HỆ THỐNG QUẢN LÝ ĐIỂM DANH SINH VIÊN
-- 📋 File 6/7: VIEWS (Các view truy vấn)
-- ===========================================

USE EducationManagement;
GO

PRINT '🔄 Bắt đầu tạo Views...';
GO

-- ===========================================
-- 1. VIEW: BẢNG ĐIỂM SINH VIÊN THEO NĂM HỌC
-- ===========================================
IF OBJECT_ID('vw_StudentTranscript', 'V') IS NOT NULL DROP VIEW vw_StudentTranscript;
GO

CREATE VIEW vw_StudentTranscript
AS
SELECT 
    s.student_id,
    s.student_code,
    s.full_name as student_name,
    s.email as student_email,
    m.major_name,
    ay.academic_year_id,
    ay.year_name as academic_year,
    c.semester,
    sub.subject_id,
    sub.subject_code,
    sub.subject_name,
    sub.credits,
    c.class_code,
    c.class_name,
    g.midterm_score,
    g.final_score,
    g.total_score,
    g.letter_grade,
    l.full_name as lecturer_name,
    e.enrollment_date,
    e.status as enrollment_status
FROM dbo.students s
INNER JOIN dbo.enrollments e ON s.student_id = e.student_id
INNER JOIN dbo.classes c ON e.class_id = c.class_id
INNER JOIN dbo.subjects sub ON c.subject_id = sub.subject_id
LEFT JOIN dbo.grades g ON e.enrollment_id = g.enrollment_id
INNER JOIN dbo.academic_years ay ON c.academic_year_id = ay.academic_year_id
LEFT JOIN dbo.lecturers l ON c.lecturer_id = l.lecturer_id
LEFT JOIN dbo.majors m ON s.major_id = m.major_id
WHERE s.deleted_at IS NULL 
    AND e.deleted_at IS NULL
    AND ay.deleted_at IS NULL;
GO

-- ===========================================
-- 2. VIEW: TỔNG HỢP GPA SINH VIÊN
-- ===========================================
IF OBJECT_ID('vw_StudentGPASummary', 'V') IS NOT NULL DROP VIEW vw_StudentGPASummary;
GO

CREATE VIEW vw_StudentGPASummary
AS
SELECT 
    s.student_id,
    s.student_code,
    s.full_name as student_name,
    s.email,
    m.major_name,
    f.faculty_name,
    g.academic_year_id,
    ay.year_name as academic_year,
    COALESCE(g.semester, 0) as semester, -- 0 = Cả năm (thay thế NULL)
    CASE 
        WHEN g.semester IS NULL THEN N'Cả năm'
        WHEN g.semester = 1 THEN N'Học kỳ 1'
        WHEN g.semester = 2 THEN N'Học kỳ 2'
        WHEN g.semester = 3 THEN N'Học kỳ hè'
        ELSE N'Không xác định'
    END as semester_text,
    g.gpa10,
    g.gpa4,
    g.total_credits,
    g.accumulated_credits,
    g.rank_text,
    g.created_at as calculated_at
FROM dbo.gpas g
INNER JOIN dbo.students s ON g.student_id = s.student_id
INNER JOIN dbo.academic_years ay ON g.academic_year_id = ay.academic_year_id
LEFT JOIN dbo.majors m ON s.major_id = m.major_id
LEFT JOIN dbo.faculties f ON m.faculty_id = f.faculty_id
WHERE s.deleted_at IS NULL 
    AND g.deleted_at IS NULL
    AND ay.deleted_at IS NULL;
GO

-- ===========================================
-- 3. VIEW: THỐNG KÊ LỚP HỌC
-- ===========================================
IF OBJECT_ID('vw_ClassStatistics', 'V') IS NOT NULL DROP VIEW vw_ClassStatistics;
GO

CREATE VIEW vw_ClassStatistics
AS
SELECT 
    c.class_id,
    c.class_code,
    c.class_name,
    sub.subject_code,
    sub.subject_name,
    sub.credits,
    ay.year_name as academic_year,
    c.semester,
    l.full_name as lecturer_name,
    c.max_students,
    COUNT(DISTINCT e.student_id) as enrolled_students,
    c.max_students - COUNT(DISTINCT e.student_id) as remaining_slots,
    AVG(g.total_score) as average_score,
    COUNT(CASE WHEN g.total_score >= 5.0 THEN 1 END) as passed_students,
    COUNT(CASE WHEN g.total_score < 5.0 THEN 1 END) as failed_students,
    c.room,
    c.schedule
FROM dbo.classes c
INNER JOIN dbo.subjects sub ON c.subject_id = sub.subject_id
INNER JOIN dbo.academic_years ay ON c.academic_year_id = ay.academic_year_id
LEFT JOIN dbo.lecturers l ON c.lecturer_id = l.lecturer_id
LEFT JOIN dbo.enrollments e ON c.class_id = e.class_id AND e.deleted_at IS NULL
LEFT JOIN dbo.grades g ON e.enrollment_id = g.enrollment_id
WHERE c.deleted_at IS NULL
GROUP BY 
    c.class_id, c.class_code, c.class_name, 
    sub.subject_code, sub.subject_name, sub.credits,
    ay.year_name, c.semester, l.full_name,
    c.max_students, c.room, c.schedule;
GO

-- ===========================================
-- 4. VIEW: LỊCH SỬ ĐIỂM DANH
-- ===========================================
IF OBJECT_ID('vw_AttendanceHistory', 'V') IS NOT NULL DROP VIEW vw_AttendanceHistory;
GO

CREATE VIEW vw_AttendanceHistory
AS
SELECT 
    s.student_id,
    s.student_code,
    s.full_name as student_name,
    c.class_code,
    c.class_name,
    sub.subject_name,
    ay.year_name as academic_year,
    a.attendance_date,
    a.status,
    a.note,
    l.full_name as lecturer_name
FROM dbo.attendances a
INNER JOIN dbo.enrollments e ON a.enrollment_id = e.enrollment_id
INNER JOIN dbo.students s ON e.student_id = s.student_id
INNER JOIN dbo.classes c ON a.class_id = c.class_id
INNER JOIN dbo.subjects sub ON c.subject_id = sub.subject_id
INNER JOIN dbo.academic_years ay ON c.academic_year_id = ay.academic_year_id
LEFT JOIN dbo.lecturers l ON c.lecturer_id = l.lecturer_id
WHERE s.deleted_at IS NULL 
    AND e.deleted_at IS NULL;
GO

-- ===========================================
-- 5. VIEW: ĐIỂM TRUNG BÌNH TÍCH LŨY
-- ===========================================
IF OBJECT_ID('vw_StudentCumulativeGPA', 'V') IS NOT NULL DROP VIEW vw_StudentCumulativeGPA;
GO

CREATE VIEW vw_StudentCumulativeGPA
AS
SELECT 
    s.student_id,
    s.student_code,
    s.full_name as student_name,
    m.major_name,
    f.faculty_name,
    -- GPA tích lũy (trung bình của tất cả các năm học)
    ROUND(AVG(g.gpa10), 2) as cumulative_gpa10,
    ROUND(AVG(g.gpa4), 2) as cumulative_gpa4,
    SUM(g.accumulated_credits) as total_accumulated_credits,
    -- GPA cao nhất
    MAX(g.gpa10) as highest_gpa10,
    -- GPA thấp nhất
    MIN(g.gpa10) as lowest_gpa10,
    -- Xếp loại tổng hợp
    CASE 
        WHEN ROUND(AVG(g.gpa10), 2) >= 8.5 THEN N'Xuất sắc'
        WHEN ROUND(AVG(g.gpa10), 2) >= 7.0 THEN N'Giỏi'
        WHEN ROUND(AVG(g.gpa10), 2) >= 5.5 THEN N'Khá'
        WHEN ROUND(AVG(g.gpa10), 2) >= 4.0 THEN N'Trung bình'
        ELSE N'Yếu'
    END as overall_rank
FROM dbo.students s
LEFT JOIN dbo.gpas g ON s.student_id = g.student_id AND g.semester IS NULL AND g.deleted_at IS NULL
LEFT JOIN dbo.majors m ON s.major_id = m.major_id
LEFT JOIN dbo.faculties f ON m.faculty_id = f.faculty_id
WHERE s.deleted_at IS NULL
GROUP BY 
    s.student_id, s.student_code, s.full_name,
    m.major_name, f.faculty_name;
GO

-- ===========================================
-- 6. VIEW: DANH SÁCH SINH VIÊN THEO LỚP
-- ===========================================
IF OBJECT_ID('vw_ClassRoster', 'V') IS NOT NULL DROP VIEW vw_ClassRoster;
GO

CREATE VIEW vw_ClassRoster
AS
SELECT 
    c.class_id,
    c.class_code,
    c.class_name,
    sub.subject_code,
    sub.subject_name,
    sub.credits,
    ay.year_name as academic_year,
    c.semester,
    s.student_id,
    s.student_code,
    s.full_name as student_name,
    s.email as student_email,
    m.major_name,
    e.enrollment_date,
    e.status as enrollment_status,
    g.midterm_score,
    g.final_score,
    g.total_score,
    g.letter_grade
FROM dbo.classes c
INNER JOIN dbo.subjects sub ON c.subject_id = sub.subject_id
INNER JOIN dbo.academic_years ay ON c.academic_year_id = ay.academic_year_id
INNER JOIN dbo.enrollments e ON c.class_id = e.class_id
INNER JOIN dbo.students s ON e.student_id = s.student_id
LEFT JOIN dbo.grades g ON e.enrollment_id = g.enrollment_id
LEFT JOIN dbo.majors m ON s.major_id = m.major_id
WHERE c.deleted_at IS NULL 
    AND e.deleted_at IS NULL
    AND s.deleted_at IS NULL;
GO

-- ===========================================
-- 7. VIEW: QUẢN LÝ ĐỢT ĐĂNG KÝ HỌC PHẦN (Admin)
-- ===========================================
IF OBJECT_ID('vw_RegistrationPeriodManagement', 'V') IS NOT NULL DROP VIEW vw_RegistrationPeriodManagement;
GO

CREATE VIEW vw_RegistrationPeriodManagement
AS
SELECT 
    rp.period_id,
    rp.period_name,
    rp.academic_year_id,
    ay.year_name as academic_year_name,
    rp.semester,
    CASE 
        WHEN rp.semester = 1 THEN N'Học kỳ 1'
        WHEN rp.semester = 2 THEN N'Học kỳ 2'
        WHEN rp.semester = 3 THEN N'Học kỳ 3 (Hè)'
        ELSE N'Không xác định'
    END as semester_text,
    rp.start_date,
    rp.end_date,
    rp.status,
    CASE 
        WHEN rp.status = 'OPEN' THEN N'Đang mở'
        WHEN rp.status = 'CLOSED' THEN N'Đã đóng'
        WHEN rp.status = 'UPCOMING' THEN N'Sắp mở'
        ELSE N'Không xác định'
    END as status_text,
    rp.description,
    rp.is_active,
    rp.created_at,
    rp.created_by,
    rp.updated_at,
    rp.updated_by,
    -- Thống kê
    COUNT(DISTINCT pc.class_id) as total_classes,
    COUNT(DISTINCT CASE WHEN pc.is_active = 1 AND pc.deleted_at IS NULL THEN pc.class_id END) as active_classes,
    SUM(DISTINCT c.max_students) as total_capacity,
    SUM(DISTINCT c.current_enrollment) as total_enrolled,
    SUM(DISTINCT c.max_students) - SUM(DISTINCT c.current_enrollment) as total_available_slots,
    -- Thời gian còn lại (nếu đang mở)
    CASE 
        WHEN rp.status = 'OPEN' AND GETDATE() BETWEEN rp.start_date AND rp.end_date 
        THEN DATEDIFF(DAY, GETDATE(), rp.end_date)
        ELSE NULL
    END as days_remaining,
    -- Trạng thái thời gian
    CASE 
        WHEN GETDATE() < rp.start_date THEN N'Chưa bắt đầu'
        WHEN GETDATE() BETWEEN rp.start_date AND rp.end_date THEN N'Đang diễn ra'
        WHEN GETDATE() > rp.end_date THEN N'Đã kết thúc'
        ELSE N'Không xác định'
    END as time_status
FROM dbo.registration_periods rp
INNER JOIN dbo.academic_years ay ON rp.academic_year_id = ay.academic_year_id
LEFT JOIN dbo.period_classes pc ON rp.period_id = pc.period_id 
    AND pc.deleted_at IS NULL
LEFT JOIN dbo.classes c ON pc.class_id = c.class_id 
    AND c.deleted_at IS NULL
WHERE rp.deleted_at IS NULL
GROUP BY 
    rp.period_id, rp.period_name, rp.academic_year_id, ay.year_name,
    rp.semester, rp.start_date, rp.end_date, rp.status, rp.description,
    rp.is_active, rp.created_at, rp.created_by, rp.updated_at, rp.updated_by;
GO

-- ===========================================
-- 8. VIEW: CHI TIẾT LỚP HỌC TRONG ĐỢT ĐĂNG KÝ (Admin)
-- ===========================================
IF OBJECT_ID('vw_PeriodClassDetails', 'V') IS NOT NULL DROP VIEW vw_PeriodClassDetails;
GO

CREATE VIEW vw_PeriodClassDetails
AS
SELECT 
    pc.period_class_id,
    pc.period_id,
    rp.period_name,
    rp.status as period_status,
    rp.start_date as period_start_date,
    rp.end_date as period_end_date,
    pc.class_id,
    c.class_code,
    c.class_name,
    c.subject_id,
    sub.subject_code,
    sub.subject_name,
    sub.credits,
    c.lecturer_id,
    l.lecturer_code,
    l.full_name as lecturer_name,
    c.semester,
    c.max_students,
    c.current_enrollment,
    c.max_students - c.current_enrollment as available_seats,
    CASE 
        WHEN c.max_students > 0 
        THEN CAST(ROUND((c.current_enrollment * 100.0 / c.max_students), 2) AS DECIMAL(5,2))
        ELSE 0
    END as enrollment_percentage,
    c.room,
    c.schedule,
    ay.year_name as academic_year_name,
    sy.year_code as school_year_code,
    pc.is_active,
    pc.created_at,
    pc.created_by,
    pc.updated_at,
    pc.updated_by,
    -- Thống kê đăng ký trong đợt này
    COUNT(DISTINCT e.enrollment_id) as enrollments_in_period,
    -- Trạng thái lớp
    CASE 
        WHEN c.current_enrollment >= c.max_students THEN N'Đã đầy'
        WHEN c.current_enrollment >= c.max_students * 0.8 THEN N'Sắp đầy'
        WHEN c.current_enrollment > 0 THEN N'Còn chỗ'
        ELSE N'Chưa có đăng ký'
    END as class_status
FROM dbo.period_classes pc
INNER JOIN dbo.registration_periods rp ON pc.period_id = rp.period_id
INNER JOIN dbo.classes c ON pc.class_id = c.class_id
INNER JOIN dbo.subjects sub ON c.subject_id = sub.subject_id
LEFT JOIN dbo.lecturers l ON c.lecturer_id = l.lecturer_id
LEFT JOIN dbo.academic_years ay ON c.academic_year_id = ay.academic_year_id
LEFT JOIN dbo.school_years sy ON c.school_year_id = sy.school_year_id
LEFT JOIN dbo.enrollments e ON c.class_id = e.class_id 
    AND e.deleted_at IS NULL
    AND e.enrollment_date BETWEEN rp.start_date AND rp.end_date
WHERE pc.deleted_at IS NULL
    AND rp.deleted_at IS NULL
    AND c.deleted_at IS NULL
GROUP BY 
    pc.period_class_id, pc.period_id, rp.period_name, rp.status, 
    rp.start_date, rp.end_date, pc.class_id, c.class_code, c.class_name,
    c.subject_id, sub.subject_code, sub.subject_name, sub.credits,
    c.lecturer_id, l.lecturer_code, l.full_name, c.semester,
    c.max_students, c.current_enrollment, c.room, c.schedule,
    ay.year_name, sy.year_code, pc.is_active, pc.created_at,
    pc.created_by, pc.updated_at, pc.updated_by;
GO

-- ===========================================
-- 9. VIEW: THỐNG KÊ ĐỢT ĐĂNG KÝ (Admin Dashboard)
-- ===========================================
IF OBJECT_ID('vw_RegistrationPeriodStatistics', 'V') IS NOT NULL DROP VIEW vw_RegistrationPeriodStatistics;
GO

CREATE VIEW vw_RegistrationPeriodStatistics
AS
SELECT 
    rp.period_id,
    rp.period_name,
    rp.status,
    rp.start_date,
    rp.end_date,
    -- Thống kê lớp
    COUNT(DISTINCT pc.class_id) as total_classes,
    COUNT(DISTINCT CASE WHEN pc.is_active = 1 THEN pc.class_id END) as active_classes,
    -- Thống kê đăng ký
    COUNT(DISTINCT e.enrollment_id) as total_enrollments,
    COUNT(DISTINCT e.student_id) as total_students,
    -- Thống kê sức chứa
    SUM(DISTINCT c.max_students) as total_capacity,
    SUM(DISTINCT c.current_enrollment) as total_enrolled,
    SUM(DISTINCT c.max_students) - SUM(DISTINCT c.current_enrollment) as total_available,
    -- Tỷ lệ đăng ký
    CASE 
        WHEN SUM(DISTINCT c.max_students) > 0
        THEN CAST(ROUND((SUM(DISTINCT c.current_enrollment) * 100.0 / SUM(DISTINCT c.max_students)), 2) AS DECIMAL(5,2))
        ELSE 0
    END as enrollment_rate,
    -- Thống kê theo môn học
    COUNT(DISTINCT c.subject_id) as total_subjects,
    -- Thống kê theo giảng viên
    COUNT(DISTINCT c.lecturer_id) as total_lecturers
FROM dbo.registration_periods rp
LEFT JOIN dbo.period_classes pc ON rp.period_id = pc.period_id 
    AND pc.deleted_at IS NULL
LEFT JOIN dbo.classes c ON pc.class_id = c.class_id 
    AND c.deleted_at IS NULL
LEFT JOIN dbo.enrollments e ON c.class_id = e.class_id 
    AND e.deleted_at IS NULL
    AND e.enrollment_date BETWEEN rp.start_date AND rp.end_date
WHERE rp.deleted_at IS NULL
GROUP BY 
    rp.period_id, rp.period_name, rp.status, rp.start_date, rp.end_date;
GO

PRINT '';
PRINT '✅ Đã tạo xong tất cả Views!';
PRINT '   - vw_StudentTranscript: Bảng điểm sinh viên';
PRINT '   - vw_StudentGPASummary: Tổng hợp GPA';
PRINT '   - vw_ClassStatistics: Thống kê lớp học';
PRINT '   - vw_AttendanceHistory: Lịch sử điểm danh';
PRINT '   - vw_StudentCumulativeGPA: GPA tích lũy';
PRINT '   - vw_ClassRoster: Danh sách sinh viên theo lớp';
PRINT '   - vw_RegistrationPeriodManagement: Quản lý đợt đăng ký (Admin)';
PRINT '   - vw_PeriodClassDetails: Chi tiết lớp trong đợt đăng ký (Admin)';
PRINT '   - vw_RegistrationPeriodStatistics: Thống kê đợt đăng ký (Admin)';
PRINT '';
GO
