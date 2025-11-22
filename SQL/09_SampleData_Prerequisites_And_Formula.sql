-- ============================================================
-- SCRIPT TẠO DỮ LIỆU MẪU: TIÊN QUYẾT VÀ CÔNG THỨC ĐIỂM
-- ============================================================
-- Mô tả: Script này tạo dữ liệu mẫu cho 2 chức năng:
--   1. Subject Prerequisites (Tiên quyết môn học)
--   2. Grade Formula Config (Công thức tính điểm)
--
-- Lưu ý: Script này giả định các môn học, lớp học, năm học đã tồn tại
-- Nếu chưa có, vui lòng chạy SQL/03_SeedData_FullTest.sql trước
-- ============================================================

PRINT '========================================';
PRINT 'BẮT ĐẦU: Tạo dữ liệu mẫu Tiên quyết và Công thức điểm';
PRINT '========================================';
GO

-- ============================================================
-- PHẦN 1: DỮ LIỆU MẪU - TIÊN QUYẾT MÔN HỌC
-- ============================================================
PRINT '';
PRINT '📚 Đang tạo dữ liệu mẫu cho Subject Prerequisites...';
GO

-- Xóa dữ liệu mẫu cũ (nếu có) để tránh conflict
DELETE FROM dbo.subject_prerequisites WHERE created_by = 'sample_data';
GO

-- Kiểm tra và xử lý conflict với dữ liệu seed (nếu có)
-- Nếu đã có tiên quyết với cùng subject_id và prerequisite_subject_id nhưng ID khác,
-- script sẽ UPDATE thay vì INSERT (nhờ MERGE)
GO

-- Insert dữ liệu mẫu cho Tiên quyết
MERGE dbo.subject_prerequisites AS target
USING (VALUES
    -- ============================================
    -- CHUỖI TIÊN QUYẾT: LẬP TRÌNH
    -- ============================================
    -- SE101 (Lập trình cơ bản) → SE201 (Phân tích thiết kế)
    ('PREREQ_SAMPLE_001', 'SUB_SE201', 'SUB_SE101', 5.0, 1, 
     N'Phải hoàn thành Lập trình cơ bản với điểm tối thiểu 5.0 trước khi học Phân tích thiết kế', 'sample_data'),
    
    -- SE201 (Phân tích thiết kế) → SE301 (Đồ án web)
    ('PREREQ_SAMPLE_002', 'SUB_SE301', 'SUB_SE201', 6.0, 1, 
     N'Phải hoàn thành Phân tích thiết kế với điểm tối thiểu 6.0 trước khi làm đồ án', 'sample_data'),
    
    -- SE101 (Lập trình cơ bản) → SE301 (Đồ án web) - Tiên quyết trực tiếp
    ('PREREQ_SAMPLE_003', 'SUB_SE301', 'SUB_SE101', 5.5, 1, 
     N'Phải có kiến thức lập trình cơ bản trước khi làm đồ án', 'sample_data'),
    
    -- ============================================
    -- CHUỖI TIÊN QUYẾT: DỮ LIỆU
    -- ============================================
    -- SE101 (Lập trình cơ bản) → DS101 (Nhập môn dữ liệu) - Không bắt buộc
    ('PREREQ_SAMPLE_004', 'SUB_DS101', 'SUB_SE101', 5.5, 0, 
     N'Khuyến khích có kiến thức lập trình cơ bản trước khi học dữ liệu (không bắt buộc)', 'sample_data')
) AS src(prerequisite_id, subject_id, prerequisite_subject_id, minimum_grade, is_required, description, created_by)
ON target.subject_id = src.subject_id 
   AND target.prerequisite_subject_id = src.prerequisite_subject_id
   AND target.deleted_at IS NULL
WHEN MATCHED THEN
    UPDATE SET 
        minimum_grade = src.minimum_grade,
        is_required = src.is_required,
        description = src.description,
        updated_at = GETDATE(),
        updated_by = 'sample_data'
WHEN NOT MATCHED THEN
    INSERT (prerequisite_id, subject_id, prerequisite_subject_id, minimum_grade, is_required, description, created_by, is_active, created_at)
    VALUES (src.prerequisite_id, src.subject_id, src.prerequisite_subject_id, src.minimum_grade, src.is_required, src.description, src.created_by, 1, GETDATE());
GO

PRINT '✅ Đã tạo dữ liệu mẫu cho Subject Prerequisites';
GO

-- ============================================================
-- PHẦN 2: DỮ LIỆU MẪU - CÔNG THỨC TÍNH ĐIỂM
-- ============================================================
PRINT '';
PRINT '📊 Đang tạo dữ liệu mẫu cho Grade Formula Config...';
GO

-- Xóa dữ liệu cũ (nếu muốn reset)
-- DELETE FROM dbo.grade_formula_config WHERE created_by = 'sample_data';
-- GO

MERGE dbo.grade_formula_config AS target
USING (VALUES
    -- ============================================
    -- 1. CÔNG THỨC MẶC ĐỊNH (Default Formula)
    -- ============================================
    -- Công thức chuẩn: Giữa kỳ 30% + Cuối kỳ 70%
    -- Lưu ý: Constraint CHK_Formula_Scope yêu cầu ít nhất 1 scope (subject_id, class_id, hoặc school_year_id)
    -- Vì vậy, công thức mặc định sẽ dùng school_year_id để thỏa constraint, nhưng is_default = 1 để đánh dấu là mặc định
    -- Hoặc có thể tạo với một subject_id giả, nhưng cách tốt nhất là dùng school_year_id
    -- Constraint CHK_Formula_Scope yêu cầu ít nhất 1 scope, nên dùng school_year_id để thỏa constraint
    -- Công thức mặc định sẽ được tìm bằng is_default = 1, nhưng cần có ít nhất 1 scope
    ('GFC_DEFAULT_001', NULL, NULL, 'SY2024', 
     0.30, 0.70, 0.00, 0.00, 0.00, 
     NULL, 'STANDARD', 2, 
     N'Công thức mặc định cho tất cả môn học: Giữa kỳ 30% + Cuối kỳ 70%', 
     1, 'sample_data'),
    
    -- ============================================
    -- 2. CÔNG THỨC THEO MÔN HỌC
    -- ============================================
    -- SE101: Giữa kỳ 30% + Cuối kỳ 50% + Bài tập 20%
    ('GFC_SUB_SE101', 'SUB_SE101', NULL, NULL,
     0.30, 0.50, 0.20, 0.00, 0.00,
     N'midterm*0.3 + final*0.5 + assignment*0.2', 'STANDARD', 2,
     N'Công thức cho SE101 - Lập trình cơ bản: Chú trọng bài tập thực hành', 
     0, 'sample_data'),
    
    -- SE201: Giữa kỳ 40% + Cuối kỳ 60%
    ('GFC_SUB_SE201', 'SUB_SE201', NULL, NULL,
     0.40, 0.60, 0.00, 0.00, 0.00,
     N'midterm*0.4 + final*0.6', 'STANDARD', 2,
     N'Công thức cho SE201 - Phân tích thiết kế: Cân bằng giữa kỳ và cuối kỳ', 
     0, 'sample_data'),
    
    -- SE301: Giữa kỳ 20% + Cuối kỳ 30% + Đồ án 50%
    ('GFC_SUB_SE301', 'SUB_SE301', NULL, NULL,
     0.20, 0.30, 0.00, 0.00, 0.50,
     N'midterm*0.2 + final*0.3 + project*0.5', 'CEILING', 1,
     N'Công thức cho SE301 - Đồ án web: Chú trọng đồ án (làm tròn lên)', 
     0, 'sample_data'),
    
    -- DS101: Giữa kỳ 25% + Cuối kỳ 45% + Bài tập 20% + Kiểm tra 10%
    ('GFC_SUB_DS101', 'SUB_DS101', NULL, NULL,
     0.25, 0.45, 0.20, 0.10, 0.00,
     N'midterm*0.25 + final*0.45 + assignment*0.2 + quiz*0.1', 'STANDARD', 2,
     N'Công thức cho DS101 - Nhập môn dữ liệu: Đánh giá đa dạng', 
     0, 'sample_data'),
    
    -- ============================================
    -- 3. CÔNG THỨC THEO LỚP HỌC (Ưu tiên cao nhất)
    -- ============================================
    -- Lớp SE301-24-HK2: Công thức riêng cho đồ án
    ('GFC_CLS_SE301_2024', NULL, 'CLS_SE301_2024', NULL,
     0.15, 0.25, 0.00, 0.00, 0.60,
     N'midterm*0.15 + final*0.25 + project*0.6', 'CEILING', 1,
     N'Công thức riêng cho lớp SE301-24-HK2: Đồ án chiếm 60% (làm tròn lên)', 
     0, 'sample_data'),
    
    -- Lớp SE101-24-HK1: Công thức thực hành
    ('GFC_CLS_SE101_2024', NULL, 'CLS_SE101_2024', NULL,
     0.25, 0.45, 0.30, 0.00, 0.00,
     N'midterm*0.25 + final*0.45 + assignment*0.3', 'STANDARD', 2,
     N'Công thức riêng cho lớp SE101-24-HK1: Chú trọng bài tập thực hành', 
     0, 'sample_data'),
    
    -- ============================================
    -- 4. CÔNG THỨC THEO NĂM HỌC
    -- ============================================
    -- Năm học 2024-2025: Công thức chung
    ('GFC_SY_2024', NULL, NULL, 'SY2024',
     0.35, 0.65, 0.00, 0.00, 0.00,
     N'midterm*0.35 + final*0.65', 'STANDARD', 2,
     N'Công thức chung cho năm học 2024-2025: Tăng trọng số cuối kỳ', 
     0, 'sample_data'),
    
    -- ============================================
    -- 5. CÔNG THỨC ĐẶC BIỆT: LÀM TRÒN
    -- ============================================
    -- Ví dụ: Làm tròn xuống (FLOOR)
    ('GFC_FLOOR_EXAMPLE', 'SUB_SE201', NULL, NULL,
     0.30, 0.70, 0.00, 0.00, 0.00,
     NULL, 'FLOOR', 0,
     N'Ví dụ làm tròn xuống: 8.9 → 8 (không có chữ số thập phân)', 
     0, 'sample_data'),
    
    -- Ví dụ: Không làm tròn (NONE)
    ('GFC_NONE_EXAMPLE', 'SUB_DS101', NULL, NULL,
     0.30, 0.70, 0.00, 0.00, 0.00,
     NULL, 'NONE', 4,
     N'Ví dụ không làm tròn: Giữ nguyên 4 chữ số thập phân', 
     0, 'sample_data')
    
) AS src(
    config_id, subject_id, class_id, school_year_id,
    midterm_weight, final_weight, assignment_weight, quiz_weight, project_weight,
    custom_formula, rounding_method, decimal_places, description, is_default, created_by
)
ON target.config_id = src.config_id
WHEN MATCHED THEN
    UPDATE SET 
        subject_id = src.subject_id,
        class_id = src.class_id,
        school_year_id = src.school_year_id,
        midterm_weight = src.midterm_weight,
        final_weight = src.final_weight,
        assignment_weight = src.assignment_weight,
        quiz_weight = src.quiz_weight,
        project_weight = src.project_weight,
        custom_formula = src.custom_formula,
        rounding_method = src.rounding_method,
        decimal_places = src.decimal_places,
        description = src.description,
        is_default = src.is_default,
        updated_at = GETDATE(),
        updated_by = 'sample_data'
WHEN NOT MATCHED THEN
    INSERT (
        config_id, subject_id, class_id, school_year_id,
        midterm_weight, final_weight, assignment_weight, quiz_weight, project_weight,
        custom_formula, rounding_method, decimal_places, description, is_default, created_by
    )
    VALUES (
        src.config_id, src.subject_id, src.class_id, src.school_year_id,
        src.midterm_weight, src.final_weight, src.assignment_weight, src.quiz_weight, src.project_weight,
        src.custom_formula, src.rounding_method, src.decimal_places, src.description, src.is_default, src.created_by
    );
GO

PRINT '✅ Đã tạo dữ liệu mẫu cho Grade Formula Config';
GO

-- ============================================================
-- PHẦN 3: KIỂM TRA DỮ LIỆU ĐÃ TẠO
-- ============================================================
PRINT '';
PRINT '🔍 Đang kiểm tra dữ liệu đã tạo...';
GO

-- Kiểm tra số lượng tiên quyết
DECLARE @PrereqCount INT;
SELECT @PrereqCount = COUNT(*) 
FROM dbo.subject_prerequisites 
WHERE created_by = 'sample_data' AND deleted_at IS NULL;
PRINT '   📚 Số lượng tiên quyết đã tạo: ' + CAST(@PrereqCount AS VARCHAR(10));

-- Kiểm tra số lượng công thức điểm
DECLARE @FormulaCount INT;
SELECT @FormulaCount = COUNT(*) 
FROM dbo.grade_formula_config 
WHERE created_by = 'sample_data' AND deleted_at IS NULL;
PRINT '   📊 Số lượng công thức điểm đã tạo: ' + CAST(@FormulaCount AS VARCHAR(10));

-- Hiển thị danh sách tiên quyết
PRINT '';
PRINT '📋 Danh sách tiên quyết:';
SELECT 
    prerequisite_id,
    (SELECT subject_code FROM subjects WHERE subject_id = sp.subject_id) AS subject_code,
    (SELECT subject_code FROM subjects WHERE subject_id = sp.prerequisite_subject_id) AS prereq_code,
    minimum_grade,
    CASE WHEN is_required = 1 THEN N'Bắt buộc' ELSE N'Không bắt buộc' END AS is_required
FROM dbo.subject_prerequisites sp
WHERE created_by = 'sample_data' AND deleted_at IS NULL
ORDER BY subject_id, prerequisite_subject_id;

-- Hiển thị danh sách công thức điểm
PRINT '';
PRINT '📋 Danh sách công thức điểm:';
SELECT 
    config_id,
    CASE 
        WHEN class_id IS NOT NULL THEN 'Lớp: ' + (SELECT class_code FROM classes WHERE class_id = gfc.class_id)
        WHEN subject_id IS NOT NULL THEN 'Môn: ' + (SELECT subject_code FROM subjects WHERE subject_id = gfc.subject_id)
        WHEN school_year_id IS NOT NULL THEN 'Năm học: ' + (SELECT year_code FROM school_years WHERE school_year_id = gfc.school_year_id)
        WHEN is_default = 1 THEN 'Mặc định'
        ELSE 'Chưa xác định'
    END AS scope,
    CAST(midterm_weight * 100 AS VARCHAR) + '%' AS midterm,
    CAST(final_weight * 100 AS VARCHAR) + '%' AS final,
    CASE WHEN assignment_weight > 0 THEN CAST(assignment_weight * 100 AS VARCHAR) + '%' ELSE '-' END AS assignment,
    CASE WHEN quiz_weight > 0 THEN CAST(quiz_weight * 100 AS VARCHAR) + '%' ELSE '-' END AS quiz,
    CASE WHEN project_weight > 0 THEN CAST(project_weight * 100 AS VARCHAR) + '%' ELSE '-' END AS project,
    rounding_method + ' (' + CAST(decimal_places AS VARCHAR) + ')' AS rounding
FROM dbo.grade_formula_config gfc
WHERE created_by = 'sample_data' AND deleted_at IS NULL
ORDER BY 
    CASE WHEN is_default = 1 THEN 0 ELSE 1 END,
    CASE WHEN class_id IS NOT NULL THEN 1 WHEN subject_id IS NOT NULL THEN 2 WHEN school_year_id IS NOT NULL THEN 3 ELSE 4 END,
    config_id;

GO

PRINT '';
PRINT '========================================';
PRINT '✅ HOÀN THÀNH: Đã tạo dữ liệu mẫu thành công!';
PRINT '========================================';
PRINT '';
PRINT '📝 HƯỚNG DẪN SỬ DỤNG:';
PRINT '   1. Vào trang "Quản lý Môn tiên quyết" để xem và quản lý tiên quyết';
PRINT '   2. Vào trang "Cấu hình công thức tính điểm" để xem và quản lý công thức';
PRINT '   3. Thử kiểm tra điều kiện đăng ký với mã sinh viên và môn học có tiên quyết';
PRINT '   4. Thử tạo/sửa/xóa công thức điểm để hiểu cách hoạt động';
PRINT '';
GO

