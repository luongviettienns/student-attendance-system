# 📝 HƯỚNG DẪN SỬ DỤNG DỮ LIỆU MẪU

## 🎯 File: `09_SampleData_Prerequisites_And_Formula.sql`

Script này tạo dữ liệu mẫu cho 2 chức năng:
1. **Subject Prerequisites** (Tiên quyết môn học)
2. **Grade Formula Config** (Công thức tính điểm)

---

## 📋 YÊU CẦU TRƯỚC KHI CHẠY

### ✅ Đảm bảo đã có dữ liệu cơ bản:
- **Môn học (subjects):** SUB_SE101, SUB_SE201, SUB_SE301, SUB_DS101, SUB_BUS201
- **Lớp học (classes):** CLS_SE101_2024, CLS_SE201_2024, CLS_SE301_2024, CLS_DS101_2024
- **Năm học (school_years):** SY2024

### 🔧 Nếu chưa có, chạy trước:
```sql
-- Chạy script seed data đầy đủ
SQL/03_SeedData_FullTest.sql
```

---

## 🚀 CÁCH CHẠY SCRIPT

### Cách 1: SQL Server Management Studio (SSMS)
1. Mở SSMS và kết nối đến database
2. Mở file `09_SampleData_Prerequisites_And_Formula.sql`
3. Click **Execute** (F5) hoặc **Execute All**

### Cách 2: Command Line (sqlcmd)
```bash
sqlcmd -S localhost -d YourDatabaseName -i "SQL/09_SampleData_Prerequisites_And_Formula.sql"
```

### Cách 3: Azure Data Studio / VS Code
1. Mở file SQL
2. Kết nối đến database
3. Chạy script (Ctrl+Shift+E hoặc F5)

---

## 📊 DỮ LIỆU MẪU SẼ ĐƯỢC TẠO

### 1. Subject Prerequisites (Tiên quyết) - 4 bản ghi

| ID | Môn học | Môn tiên quyết | Điểm tối thiểu | Bắt buộc | Mô tả |
|---|---|---|---|---|---|
| PREREQ_SAMPLE_001 | SE201 | SE101 | 5.0 | ✅ | Phải hoàn thành SE101 trước SE201 |
| PREREQ_SAMPLE_002 | SE301 | SE201 | 6.0 | ✅ | Phải hoàn thành SE201 trước SE301 |
| PREREQ_SAMPLE_003 | SE301 | SE101 | 5.5 | ✅ | Phải có SE101 trước làm đồ án |
| PREREQ_SAMPLE_004 | DS101 | SE101 | 5.5 | ❌ | Khuyến khích có SE101 (không bắt buộc) |

**Chuỗi tiên quyết:**
```
SE101 → SE201 → SE301
SE101 → DS101 (không bắt buộc)
SE101 → SE301 (trực tiếp)
```

### 2. Grade Formula Config (Công thức điểm) - 9 bản ghi

#### a) Công thức mặc định (1 bản ghi)
- **ID:** GFC_DEFAULT_001
- **Phạm vi:** Mặc định (áp dụng cho tất cả)
- **Công thức:** Giữa kỳ 30% + Cuối kỳ 70%
- **Làm tròn:** STANDARD, 2 chữ số

#### b) Công thức theo môn học (4 bản ghi)

| ID | Môn học | Giữa kỳ | Cuối kỳ | Bài tập | Kiểm tra | Đồ án | Làm tròn |
|---|---|---|---|---|---|---|---|
| GFC_SUB_SE101 | SE101 | 30% | 50% | 20% | - | - | STANDARD (2) |
| GFC_SUB_SE201 | SE201 | 40% | 60% | - | - | - | STANDARD (2) |
| GFC_SUB_SE301 | SE301 | 20% | 30% | - | - | 50% | CEILING (1) |
| GFC_SUB_DS101 | DS101 | 25% | 45% | 20% | 10% | - | STANDARD (2) |

#### c) Công thức theo lớp học (2 bản ghi)

| ID | Lớp học | Giữa kỳ | Cuối kỳ | Bài tập | Đồ án | Làm tròn |
|---|---|---|---|---|---|---|
| GFC_CLS_SE301_2024 | SE301-24-HK2 | 15% | 25% | - | 60% | CEILING (1) |
| GFC_CLS_SE101_2024 | SE101-24-HK1 | 25% | 45% | 30% | - | STANDARD (2) |

#### d) Công thức theo năm học (1 bản ghi)
- **ID:** GFC_SY_2024
- **Năm học:** 2024-2025
- **Công thức:** Giữa kỳ 35% + Cuối kỳ 65%

#### e) Ví dụ làm tròn (2 bản ghi)
- **GFC_FLOOR_EXAMPLE:** Làm tròn xuống (FLOOR, 0 chữ số)
- **GFC_NONE_EXAMPLE:** Không làm tròn (NONE, 4 chữ số)

---

## 🔍 KIỂM TRA DỮ LIỆU SAU KHI CHẠY

### Query kiểm tra tiên quyết:
```sql
SELECT 
    sp.prerequisite_id,
    s1.subject_code AS subject_code,
    s2.subject_code AS prereq_code,
    sp.minimum_grade,
    CASE WHEN sp.is_required = 1 THEN 'Bắt buộc' ELSE 'Không bắt buộc' END AS is_required,
    sp.description
FROM dbo.subject_prerequisites sp
INNER JOIN dbo.subjects s1 ON sp.subject_id = s1.subject_id
INNER JOIN dbo.subjects s2 ON sp.prerequisite_subject_id = s2.subject_id
WHERE sp.created_by = 'sample_data' AND sp.deleted_at IS NULL
ORDER BY s1.subject_code, s2.subject_code;
```

### Query kiểm tra công thức điểm:
```sql
SELECT 
    gfc.config_id,
    CASE 
        WHEN gfc.class_id IS NOT NULL THEN 'Lớp: ' + c.class_code
        WHEN gfc.subject_id IS NOT NULL THEN 'Môn: ' + s.subject_code
        WHEN gfc.school_year_id IS NOT NULL THEN 'Năm học: ' + sy.year_code
        WHEN gfc.is_default = 1 THEN 'Mặc định'
        ELSE 'Chưa xác định'
    END AS scope,
    CAST(gfc.midterm_weight * 100 AS VARCHAR) + '%' AS midterm,
    CAST(gfc.final_weight * 100 AS VARCHAR) + '%' AS final,
    CASE WHEN gfc.assignment_weight > 0 THEN CAST(gfc.assignment_weight * 100 AS VARCHAR) + '%' ELSE '-' END AS assignment,
    CASE WHEN gfc.quiz_weight > 0 THEN CAST(gfc.quiz_weight * 100 AS VARCHAR) + '%' ELSE '-' END AS quiz,
    CASE WHEN gfc.project_weight > 0 THEN CAST(gfc.project_weight * 100 AS VARCHAR) + '%' ELSE '-' END AS project,
    gfc.rounding_method + ' (' + CAST(gfc.decimal_places AS VARCHAR) + ')' AS rounding,
    gfc.description
FROM dbo.grade_formula_config gfc
LEFT JOIN dbo.classes c ON gfc.class_id = c.class_id
LEFT JOIN dbo.subjects s ON gfc.subject_id = s.subject_id
LEFT JOIN dbo.school_years sy ON gfc.school_year_id = sy.school_year_id
WHERE gfc.created_by = 'sample_data' AND gfc.deleted_at IS NULL
ORDER BY 
    CASE WHEN gfc.is_default = 1 THEN 0 ELSE 1 END,
    CASE WHEN gfc.class_id IS NOT NULL THEN 1 
         WHEN gfc.subject_id IS NOT NULL THEN 2 
         WHEN gfc.school_year_id IS NOT NULL THEN 3 
         ELSE 4 END,
    gfc.config_id;
```

---

## 🧪 TEST CÁC CHỨC NĂNG

### 1. Test Tiên quyết:
1. Vào trang **Quản lý Môn tiên quyết** (`/subject-prerequisites`)
2. Chọn môn **SE201** → Xem tiên quyết **SE101**
3. Chọn môn **SE301** → Xem tiên quyết **SE201** và **SE101**
4. **Kiểm tra điều kiện:**
   - Nhập mã sinh viên: `STU_K24_001`
   - Chọn môn: **SE301**
   - Click "Kiểm tra" → Xem kết quả

### 2. Test Công thức điểm:
1. Vào trang **Cấu hình công thức tính điểm** (`/grade-formula`)
2. **Xem danh sách:**
   - Sẽ thấy 9 cấu hình đã tạo
   - Có công thức mặc định, theo môn, theo lớp, theo năm học
3. **Test phạm vi áp dụng:**
   - Lớp **SE301-24-HK2** sẽ dùng công thức của lớp (60% đồ án)
   - Lớp **SE101-24-HK1** sẽ dùng công thức của lớp (30% bài tập)
   - Các lớp khác sẽ dùng công thức của môn hoặc mặc định

---

## 🗑️ XÓA DỮ LIỆU MẪU (Nếu cần)

### Xóa tất cả dữ liệu mẫu:
```sql
-- Xóa tiên quyết mẫu
DELETE FROM dbo.subject_prerequisites 
WHERE created_by = 'sample_data';

-- Xóa công thức điểm mẫu
DELETE FROM dbo.grade_formula_config 
WHERE created_by = 'sample_data';
```

### Xóa từng loại:
```sql
-- Chỉ xóa tiên quyết
DELETE FROM dbo.subject_prerequisites 
WHERE created_by = 'sample_data';

-- Chỉ xóa công thức điểm
DELETE FROM dbo.grade_formula_config 
WHERE created_by = 'sample_data';
```

---

## ⚠️ LƯU Ý

1. **Script sử dụng MERGE:** Nếu dữ liệu đã tồn tại (cùng ID), sẽ **UPDATE** thay vì tạo mới
2. **Không xóa dữ liệu cũ:** Script không xóa dữ liệu hiện có, chỉ thêm/cập nhật
3. **Đánh dấu `created_by = 'sample_data':** Dễ dàng xác định và xóa dữ liệu mẫu sau này
4. **Kiểm tra Foreign Keys:** Đảm bảo các môn học, lớp học, năm học đã tồn tại trước khi chạy

---

## 📞 HỖ TRỢ

Nếu gặp lỗi khi chạy script:
1. Kiểm tra xem các bảng đã được tạo chưa (chạy `01_CreateTables.sql`)
2. Kiểm tra xem dữ liệu cơ bản đã có chưa (chạy `03_SeedData_FullTest.sql`)
3. Kiểm tra Foreign Key constraints
4. Xem thông báo lỗi chi tiết trong SQL Server

---

**Cập nhật:** 2024-12-XX

