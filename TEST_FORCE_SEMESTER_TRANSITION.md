# Hướng Dẫn Test: Force Chuyển Học Kỳ Để Test

## 🎯 Vấn Đề

Hiện tại theo thời gian thực tế vẫn đang ở **Học kỳ 1**, nhưng bạn muốn test tính năng chuyển học kỳ.

## ✅ Giải Pháp

Tạo script SQL để **force chuyển học kỳ** (chỉ dùng cho test, không dùng trong production).

---

## 📋 Cách 1: Sử Dụng Script SQL (Khuyến nghị)

### Bước 1: Chạy script force chuyển học kỳ

```sql
-- Chạy file: SQL/Test_Force_Semester_Transition.sql
```

**Script sẽ:**
1. ✅ Lưu dữ liệu gốc (để khôi phục sau)
2. ✅ Force chuyển `current_semester` từ 1 → 2
3. ✅ Tính GPA cho HK1 (nếu có)
4. ✅ Hiển thị kết quả

### Bước 2: Test trên UI

1. **Mở trang xem điểm:**
   - URL: `/student/grades`
   - **Kỳ vọng**: Dropdown học kỳ hiển thị "Học kỳ 2"

2. **Kiểm tra điểm HK1:**
   - Chọn "Học kỳ 1" từ dropdown
   - **Kỳ vọng**: Vẫn hiển thị điểm HK1 (không bị mất)

3. **Kiểm tra điểm HK2:**
   - Chọn "Học kỳ 2" từ dropdown
   - **Kỳ vọng**: Không có điểm (hoặc chỉ có điểm của lớp HK2)

4. **Test chuyển học kỳ:**
   - Mở `/school-years` → Click "Chuyển học kỳ tự động"
   - **Kỳ vọng**: Thông báo thành công (hoặc "Không cần chuyển" nếu đã ở HK2)

### Bước 3: Khôi phục dữ liệu

```sql
-- Chạy file: SQL/Restore_SchoolYear_Dates.sql
```

**Script sẽ:**
- ✅ Khôi phục `current_semester` về trạng thái ban đầu
- ✅ Khôi phục ngày tháng năm học (nếu đã thay đổi)

---

## 📋 Cách 2: Sửa Trực Tiếp Trong Database (Nhanh)

### Option A: Force chuyển học kỳ (không đổi ngày tháng)

```sql
USE EducationManagement;
GO

-- Lấy năm học active
DECLARE @SchoolYearId VARCHAR(50);
SELECT TOP 1 @SchoolYearId = school_year_id
FROM school_years
WHERE deleted_at IS NULL AND is_active = 1
ORDER BY start_date DESC;

-- Force chuyển sang HK2
UPDATE school_years
SET current_semester = 2,
    updated_at = GETDATE(),
    updated_by = 'test'
WHERE school_year_id = @SchoolYearId;

-- Tính GPA cho HK1 (nếu đang ở HK1)
EXEC sp_CalculateAllStudentGPA 
    @AcademicYearId = @SchoolYearId,
    @Semester = 1,
    @CreatedBy = 'test';

PRINT '✅ Đã force chuyển sang HK2';
```

### Option B: Khôi phục về HK1

```sql
USE EducationManagement;
GO

-- Lấy năm học active
DECLARE @SchoolYearId VARCHAR(50);
SELECT TOP 1 @SchoolYearId = school_year_id
FROM school_years
WHERE deleted_at IS NULL AND is_active = 1
ORDER BY start_date DESC;

-- Khôi phục về HK1
UPDATE school_years
SET current_semester = 1,
    updated_at = GETDATE(),
    updated_by = 'restore'
WHERE school_year_id = @SchoolYearId;

PRINT '✅ Đã khôi phục về HK1';
```

---

## 📋 Cách 3: Tạo Endpoint Test (Cho Developer)

Nếu bạn muốn tạo endpoint riêng để test (không khuyến nghị cho production):

### Backend (C#)

```csharp
/// <summary>
/// FORCE chuyển học kỳ (CHỈ DÙNG CHO TEST)
/// </summary>
[HttpPost("force-transition-semester/{targetSemester}")]
[RequirePermission("ADMIN_SCHOOL_YEARS")]
public async Task<IActionResult> ForceTransitionSemester(int targetSemester)
{
    if (targetSemester < 1 || targetSemester > 2)
        return BadRequest(new { message = "Semester must be 1 or 2" });
    
    try
    {
        var userName = User.Identity?.Name ?? "test";
        var active = await _service.GetActiveAsync();
        
        if (active == null)
            return BadRequest(new { message = "No active school year" });
        
        // Tính GPA cho học kỳ cũ (nếu có)
        if (active.CurrentSemester.HasValue && active.CurrentSemester.Value != targetSemester)
        {
            // Calculate GPA for old semester
        }
        
        // Force update
        active.CurrentSemester = targetSemester;
        active.UpdatedBy = userName;
        await _service.UpdateAsync(active, userName);
        
        return Ok(new { 
            message = $"✅ Đã force chuyển sang HK{targetSemester}",
            schoolYearId = active.SchoolYearId,
            currentSemester = targetSemester
        });
    }
    catch (Exception ex)
    {
        return BadRequest(new { message = ex.Message });
    }
}
```

### Frontend (JavaScript)

```javascript
// Thêm vào SchoolYearService.js
this.forceTransitionSemester = function(targetSemester) {
    return ApiService.post('/school-years/force-transition-semester/' + targetSemester);
};

// Sử dụng trong controller
$scope.forceTransitionToSemester2 = function() {
    if (!confirm('Force chuyển sang HK2 để test? (CHỈ DÙNG CHO TEST)')) {
        return;
    }
    
    SchoolYearService.forceTransitionSemester(2)
        .then(function(response) {
            ToastService.success(response.data.message);
            $scope.loadSchoolYears();
            $scope.loadCurrentSchoolYear();
            $scope.loadCurrentSemesterInfo();
        })
        .catch(function(error) {
            ToastService.error(error.data?.message || 'Không thể force chuyển học kỳ');
        });
};
```

---

## 🧪 Test Cases

### Test Case 1: Force chuyển HK1 → HK2

1. **Chạy script force:**
   ```sql
   -- Chạy: SQL/Test_Force_Semester_Transition.sql
   ```

2. **Kiểm tra UI:**
   - Vào `/student/grades`
   - **Kỳ vọng**: Dropdown hiển thị "Học kỳ 2"

3. **Kiểm tra điểm HK1:**
   - Chọn "Học kỳ 1"
   - **Kỳ vọng**: Vẫn hiển thị điểm HK1

4. **Kiểm tra điểm HK2:**
   - Chọn "Học kỳ 2"
   - **Kỳ vọng**: Không có điểm (hoặc chỉ có điểm HK2)

### Test Case 2: Chuyển học kỳ tự động

1. **Force chuyển về HK1:**
   ```sql
   UPDATE school_years SET current_semester = 1 WHERE is_active = 1;
   ```

2. **Chuyển học kỳ tự động:**
   - Vào `/school-years` → Click "Chuyển học kỳ tự động"
   - **Kỳ vọng**: 
     - Nếu ngày hiện tại nằm trong HK2 → Chuyển sang HK2
     - Nếu ngày hiện tại nằm trong HK1 → Không chuyển

3. **Kiểm tra điểm:**
   - Điểm HK1 vẫn còn
   - Điểm HK2 riêng biệt

### Test Case 3: Khôi phục dữ liệu

1. **Chạy script khôi phục:**
   ```sql
   -- Chạy: SQL/Restore_SchoolYear_Dates.sql
   ```

2. **Kiểm tra:**
   - `current_semester` đã về trạng thái ban đầu
   - Ngày tháng năm học đã khôi phục

---

## ⚠️ Lưu Ý

1. **Chỉ dùng cho test:**
   - Script force chuyển học kỳ chỉ dùng cho test
   - Không dùng trong production

2. **Nhớ khôi phục:**
   - Sau khi test xong, nhớ chạy script khôi phục
   - Hoặc ghi nhớ giá trị gốc để khôi phục thủ công

3. **Backup trước khi test:**
   - Nên backup database trước khi test
   - Để đảm bảo an toàn

4. **Test trên môi trường dev:**
   - Nên test trên môi trường development
   - Không test trên production

---

## 📝 Checklist

- [ ] Đã backup database
- [ ] Đã chạy script force chuyển học kỳ
- [ ] Đã test UI: Dropdown học kỳ hiển thị đúng
- [ ] Đã test: Điểm HK1 vẫn còn
- [ ] Đã test: Điểm HK2 riêng biệt
- [ ] Đã test: Chuyển học kỳ tự động
- [ ] Đã chạy script khôi phục
- [ ] Đã kiểm tra: Dữ liệu đã khôi phục đúng

---

## 🎯 Kết Luận

Bạn có thể test tính năng chuyển học kỳ bằng cách:
1. ✅ Chạy script SQL để force chuyển học kỳ
2. ✅ Test trên UI
3. ✅ Khôi phục dữ liệu sau khi test xong

**Script đã sẵn sàng để sử dụng!** 🚀

