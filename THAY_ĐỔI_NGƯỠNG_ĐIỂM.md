# Thay Đổi Ngưỡng Điểm: 4.0 → 5.0

## Tổng Quan

Đã thống nhất ngưỡng điểm đạt từ 4.0 lên 5.0 cho toàn bộ hệ thống để đảm bảo tính nhất quán.

## Lý Do Thay Đổi

### Vấn Đề Trước Đây
- **Không nhất quán**: Hệ thống sử dụng 2 ngưỡng khác nhau
  - Ngưỡng 4.0: Tích lũy tín chỉ, tự động tạo retake record
  - Ngưỡng 5.0: Thống kê failed subjects, hiển thị trạng thái đạt/trượt

- **Mâu thuẫn**: Điểm 4.0-4.9
  - Được tích lũy tín chỉ (>= 4.0)
  - Không tự động retake (>= 4.0)
  - Nhưng vẫn tính là "failed" (< 5.0)
  - GPA 4.0 = 0.0

### Giải Pháp
Thống nhất về ngưỡng 5.0:
- Điểm đạt: >= 5.0
- Điểm trượt: < 5.0
- Tích lũy tín chỉ: >= 5.0
- Tự động retake: < 5.0

## Chi Tiết Thay Đổi

### 1. Backend C# (.NET)

#### GradeService.cs
```csharp
// Trước: total_score < 4.0m
// Sau: total_score < 5.0m
if (grade.TotalScore.HasValue && grade.TotalScore.Value < 5.0m)
{
    await _retakeService.CheckAndCreateRetakeAsync(grade.EnrollmentId);
}

// Trước: >= 4.0m
// Sau: >= 5.0m
summary.AccumulatedCredits = gradesWithScore.Where(g => g.TotalScore!.Value >= 5.0m)
    .Sum(g => g.Credits!.Value);
```

#### RetakeService.cs
```csharp
// Trước: gradeThreshold = 4.0m
// Sau: gradeThreshold = 5.0m
public async Task CheckAndCreateRetakeAsync(string enrollmentId, 
    decimal attendanceThreshold = 20.0m, decimal gradeThreshold = 5.0m)
```

#### FailedSubjectDto.cs
```csharp
// Trước: "Điểm thấp (< 4.0)"
// Sau: "Điểm thấp (< 5.0)"
"GRADE" => "Điểm thấp (< 5.0)"
```

### 2. SQL Stored Procedures

#### sp_CheckRetakeRequired
```sql
-- Trước: @GradeThreshold DECIMAL(4,2) = 4.0
-- Sau: @GradeThreshold DECIMAL(4,2) = 5.0
CREATE PROCEDURE sp_CheckRetakeRequired
    @EnrollmentId VARCHAR(50),
    @AttendanceThreshold DECIMAL(5,2) = 20.0,
    @GradeThreshold DECIMAL(4,2) = 5.0
```

#### sp_CalculateGPA
```sql
-- Trước: WHEN g.total_score >= 4.0 THEN sub.credits ELSE 0
-- Sau: WHEN g.total_score >= 5.0 THEN sub.credits ELSE 0
@AccumulatedCredits = SUM(CASE WHEN g.total_score >= 5.0 THEN sub.credits ELSE 0 END)
```

#### sp_GetCumulativeGPA
```sql
-- Trước: WHEN g.total_score >= 4.0 THEN 0.5
-- Sau: Xóa dòng này (không có điểm GPA 4.0 cho điểm < 5.0)
CASE 
    WHEN g.total_score >= 9.0 THEN 4.0
    WHEN g.total_score >= 8.5 THEN 3.7
    WHEN g.total_score >= 8.0 THEN 3.5
    WHEN g.total_score >= 7.0 THEN 3.0
    WHEN g.total_score >= 6.5 THEN 2.5
    WHEN g.total_score >= 6.0 THEN 2.0
    WHEN g.total_score >= 5.5 THEN 1.5
    WHEN g.total_score >= 5.0 THEN 1.0
    ELSE 0  -- < 5.0 = 0
END
```

#### sp_GetGradeSummary
```sql
-- Trước: >= 4.0 THEN N'Yếu'
-- Sau: >= 5.0 THEN N'Yếu'
WHEN ROUND(SUM(g.total_score * sub.credits) / NULLIF(SUM(sub.credits), 0), 2) >= 5.0 THEN N'Yếu'
```

### 3. DAL Repository (C#)

#### ReportRepository.cs
```csharp
// Xóa dòng: WHEN g.total_score >= 4.0 THEN 0.5
// GPA 4.0 scale: < 5.0 = 0.0
WHEN g.total_score >= 9.0 THEN 4.0
WHEN g.total_score >= 8.5 THEN 3.7
WHEN g.total_score >= 8.0 THEN 3.5
WHEN g.total_score >= 7.0 THEN 3.0
WHEN g.total_score >= 6.5 THEN 2.5
WHEN g.total_score >= 6.0 THEN 2.0
WHEN g.total_score >= 5.5 THEN 1.5
WHEN g.total_score >= 5.0 THEN 1.0
ELSE 0
```

### 4. Frontend AngularJS

#### StudentRetakeRegisterController.js
```javascript
// Trước: 'Điểm thấp (< 4.0)'
// Sau: 'Điểm thấp (< 5.0)'
case 'GRADE': return 'Điểm thấp (< 5.0)';
```

#### grades.html (đã đúng từ trước)
```html
<!-- Kiểm tra trượt: totalScore < 5.0 -->
<span ng-if="grade.totalScore < 5.0 || grade.letterGrade === 'F'" 
      class="badge badge-danger">
    <i class="fas fa-times-circle"></i> Trượt
</span>
<span ng-if="grade.totalScore >= 5.0 && grade.letterGrade !== 'F'" 
      class="badge badge-success">
    <i class="fas fa-check-circle"></i> Đạt
</span>
```

### 5. Seed Data

#### 03_SeedData_FullTest.sql
```sql
-- Trước: Điểm 4.6, 4.7 (D)
-- Sau: Điểm 5.3, 5.7 (C)
('GRD_FT_007', 'ENR_FT_008', 5.5, 5.8, 5.7, 'C'),  -- Updated to pass threshold
('GRD_FT_008', 'ENR_FT_009', 5.0, 5.5, 5.3, 'C'),  -- Updated to pass threshold
```

## Bảng Quy Đổi Điểm

### Thang Điểm 10 → Thang Điểm 4

| Điểm 10 | Điểm 4 (Trước) | Điểm 4 (Sau) | Xếp Loại |
|---------|----------------|---------------|----------|
| 9.0-10.0 | 4.0 | 4.0 | A (Xuất sắc) |
| 8.5-8.9 | 3.7 | 3.7 | A- (Giỏi) |
| 8.0-8.4 | 3.5 | 3.5 | B+ (Giỏi) |
| 7.0-7.9 | 3.0 | 3.0 | B (Khá) |
| 6.5-6.9 | 2.5 | 2.5 | B- (Khá) |
| 6.0-6.4 | 2.0 | 2.0 | C+ (Trung bình) |
| 5.5-5.9 | 1.5 | 1.5 | C (Trung bình) |
| 5.0-5.4 | 1.0 | 1.0 | C- (Trung bình) |
| 4.0-4.9 | 0.5 | **0.0** | **F (Trượt)** |
| < 4.0 | 0.0 | 0.0 | F (Trượt) |

### Xếp Loại Học Lực

| GPA 10 | Xếp Loại | Điều Kiện |
|--------|----------|-----------|
| >= 9.0 | Xuất sắc | Tất cả môn >= 8.0 |
| >= 8.0 | Giỏi | Tất cả môn >= 6.5 |
| >= 7.0 | Khá | Tất cả môn >= 5.0 |
| >= 5.5 | Trung bình | Tất cả môn >= 5.0 |
| >= 5.0 | Yếu | Có môn < 5.0 |
| < 5.0 | Kém | Nhiều môn < 5.0 |

## Ảnh Hưởng

### Sinh Viên
- Điểm 4.0-4.9: Từ "đạt yếu" → "trượt" (phải học lại)
- Tích lũy tín chỉ: Chỉ tính môn >= 5.0
- GPA 4.0: Điểm < 5.0 = 0.0 (thay vì 0.5)

### Hệ Thống
- Tự động tạo retake record: < 5.0 (thay vì < 4.0)
- Thống kê failed subjects: < 5.0 (không đổi)
- Hiển thị trạng thái: < 5.0 = Trượt (không đổi)

### Dữ Liệu
- Seed data: Cập nhật điểm 4.6, 4.7 → 5.3, 5.7
- Dữ liệu production: Cần review và cập nhật nếu cần

## Kiểm Tra

### Checklist
- [x] Backend C# - GradeService.cs
- [x] Backend C# - RetakeService.cs
- [x] Backend C# - FailedSubjectDto.cs
- [x] SQL - sp_CheckRetakeRequired
- [x] SQL - sp_CalculateGPA
- [x] SQL - sp_GetCumulativeGPA
- [x] SQL - sp_GetGradeSummary
- [x] DAL - ReportRepository.cs
- [x] Frontend - StudentRetakeRegisterController.js
- [x] Frontend - grades.html (đã đúng)
- [x] Seed Data - 03_SeedData_FullTest.sql

### Test Cases
1. Sinh viên có điểm 4.5:
   - Trước: Đạt, tích lũy tín chỉ, không retake
   - Sau: Trượt, không tích lũy, tự động retake

2. Sinh viên có điểm 5.0:
   - Trước: Đạt, tích lũy tín chỉ, không retake
   - Sau: Đạt, tích lũy tín chỉ, không retake (không đổi)

3. GPA calculation:
   - Điểm 4.5: GPA 4.0 = 0.0 (thay vì 0.5)
   - Điểm 5.0: GPA 4.0 = 1.0 (không đổi)

## Lưu Ý

1. **Migration dữ liệu**: Nếu có dữ liệu production với điểm 4.0-4.9, cần:
   - Review từng trường hợp
   - Quyết định xử lý (giữ nguyên, cập nhật, hoặc tạo retake)
   - Thông báo cho sinh viên

2. **Quy định trường**: Đảm bảo ngưỡng 5.0 phù hợp với quy chế đào tạo

3. **Testing**: Test kỹ các tính năng:
   - Tính GPA
   - Tích lũy tín chỉ
   - Tự động tạo retake
   - Hiển thị trạng thái đạt/trượt
   - Thống kê

4. **Documentation**: Cập nhật tài liệu hướng dẫn sử dụng

## Kết Luận

Hệ thống đã được thống nhất về ngưỡng điểm 5.0 cho tất cả các chức năng:
- ✅ Nhất quán: Một ngưỡng duy nhất
- ✅ Rõ ràng: Dễ hiểu và giải thích
- ✅ Đồng bộ: Backend, SQL, Frontend đều sử dụng cùng ngưỡng
- ✅ Chuẩn hóa: Phù hợp quy định phổ biến (điểm đạt >= 5.0)

