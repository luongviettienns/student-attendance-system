# Checklist Test UI: Chuyển học kỳ và hiển thị điểm

## ✅ Code UI hiện tại hoạt động như thế nào?

### 1. **Filter điểm theo học kỳ** - ✅ ĐÚNG

**Code hoạt động:**
- `GradeDashboardService.js` (dòng 287): Lấy `selectedSemester` từ dropdown
- `GradeService.js` (dòng 73-84): Gửi `semester` parameter lên backend
- Backend filter theo `classes.semester` (đúng logic nghiệp vụ)

**Kết quả:**
- ✅ Khi chọn "Học kỳ 1" → Chỉ hiển thị điểm của lớp HK1
- ✅ Khi chọn "Học kỳ 2" → Chỉ hiển thị điểm của lớp HK2
- ✅ Khi chọn "Tất cả" → Hiển thị tất cả điểm

### 2. **Tự động chọn học kỳ** - ⚠️ CẦN CẢI THIỆN

**Code hiện tại:**
- `GradeDashboardService.js` (dòng 254-259): Chỉ tự động set `selectedSemester` khi **lần đầu load**
- Khi chuyển học kỳ, UI **không tự động cập nhật** `selectedSemester`

**Vấn đề:**
- ⚠️ Sau khi chuyển học kỳ, user phải **tự refresh trang** hoặc click **"Làm mới"** để thấy học kỳ mới
- ⚠️ Nếu user đang xem điểm HK1, sau khi chuyển học kỳ, dropdown vẫn hiển thị "Học kỳ 1" (chưa tự động chuyển sang HK2)

**Giải pháp tạm thời:**
- User cần click nút **"Làm mới"** sau khi chuyển học kỳ
- Hoặc refresh trang (`F5`)

---

## 📋 Hướng dẫn Test UI (Bạn đã có điểm rồi)

### Bước 1: Kiểm tra điểm HK1 hiện tại

1. **Vào trang xem điểm:**
   - URL: `/student/grades` (hoặc menu "Kết quả học tập")
   - Đăng nhập với tài khoản sinh viên đã có điểm

2. **Chọn năm học và học kỳ:**
   - Chọn năm học hiện tại
   - Chọn "Học kỳ 1"
   - Click "Làm mới" nếu cần

3. **Kiểm tra:**
   - ✅ Hiển thị điểm của lớp HK1
   - ✅ Điểm giữa kỳ, cuối kỳ, tổng kết đều có
   - ✅ GPA HK1 hiển thị đúng

**Ghi chú điểm hiện tại:**
- Ghi lại điểm của từng môn để so sánh sau

### Bước 2: Chuyển học kỳ

1. **Mở tab mới hoặc cửa sổ mới:**
   - Giữ tab xem điểm đang mở
   - Mở tab mới: `/school-years` (Quản lý Năm học)

2. **Chuyển học kỳ:**
   - Click nút **"Chuyển học kỳ tự động"**
   - Xác nhận chuyển
   - **Kỳ vọng**: Thông báo thành công, học kỳ chuyển từ 1 → 2

3. **Kiểm tra học kỳ hiện tại:**
   - Xem phần "Năm học hiện tại"
   - **Kỳ vọng**: Hiển thị "Học kỳ 2"

### Bước 3: Kiểm tra điểm HK1 sau khi chuyển (QUAN TRỌNG)

1. **Quay lại tab xem điểm:**
   - Vẫn ở trang `/student/grades`
   - **KHÔNG refresh trang** (để test xem có tự động cập nhật không)

2. **Kiểm tra dropdown học kỳ:**
   - ⚠️ **Kỳ vọng**: Dropdown vẫn hiển thị "Học kỳ 1" (chưa tự động cập nhật)
   - ✅ **Điều này là bình thường** - UI chưa tự động cập nhật

3. **Click "Làm mới":**
   - Click nút **"Làm mới"** (icon refresh)
   - **Kỳ vọng**: 
     - ✅ Dropdown tự động chuyển sang "Học kỳ 2" (hoặc vẫn là "Học kỳ 1" nếu logic chưa cập nhật)
     - ✅ Điểm HK1 vẫn còn nguyên (không bị mất)

4. **Chọn lại "Học kỳ 1" thủ công:**
   - Chọn "Học kỳ 1" từ dropdown
   - Click "Làm mới" hoặc đợi auto-load
   - **Kỳ vọng**: 
     - ✅ Vẫn hiển thị điểm HK1 như ban đầu
     - ✅ Điểm không bị thay đổi
     - ✅ Điểm không bị mất

### Bước 4: Kiểm tra điểm HK2 (làm mới)

1. **Chọn "Học kỳ 2":**
   - Chọn "Học kỳ 2" từ dropdown
   - Click "Làm mới" nếu cần

2. **Kiểm tra:**
   - ✅ **Nếu chưa có lớp HK2**: Hiển thị "Chưa có điểm" (đúng)
   - ✅ **Nếu đã có lớp HK2 nhưng chưa nhập điểm**: Hiển thị danh sách lớp nhưng chưa có điểm (đúng)
   - ✅ **Nếu đã có điểm HK2**: Chỉ hiển thị điểm của lớp HK2 (không có điểm từ HK1)

3. **So sánh với HK1:**
   - ✅ Điểm HK2 hoàn toàn riêng biệt với điểm HK1
   - ✅ Không bị trộn lẫn

### Bước 5: Kiểm tra GPA

1. **Xem GPA HK1:**
   - Chọn "Học kỳ 1"
   - Xem phần "GPA Hiện tại"
   - **Kỳ vọng**: 
     - ✅ Hiển thị GPA HK1
     - ✅ Số tín chỉ HK1
     - ✅ Xếp loại HK1

2. **Xem GPA HK2:**
   - Chọn "Học kỳ 2"
   - Xem phần "GPA Hiện tại"
   - **Kỳ vọng**: 
     - ✅ Hiển thị GPA HK2 (nếu đã có điểm)
     - ✅ Hoặc GPA = 0 nếu chưa có điểm

3. **Xem GPA tích lũy:**
   - Chọn "Tất cả" hoặc không chọn học kỳ
   - Xem phần "GPA Tích lũy"
   - **Kỳ vọng**: 
     - ✅ Hiển thị GPA tích lũy (bao gồm cả HK1 và HK2)

---

## ✅ Checklist Test

### Test Pass nếu:

- [ ] **Điểm HK1 vẫn còn sau khi chuyển học kỳ**
  - Sau khi chuyển học kỳ, chọn lại "Học kỳ 1"
  - Điểm vẫn hiển thị đầy đủ như ban đầu
  - Điểm không bị thay đổi

- [ ] **Filter điểm theo học kỳ hoạt động đúng**
  - Chọn "Học kỳ 1" → Chỉ hiển thị điểm HK1
  - Chọn "Học kỳ 2" → Chỉ hiển thị điểm HK2 (hoặc "Chưa có điểm")
  - Chọn "Tất cả" → Hiển thị cả HK1 và HK2

- [ ] **Điểm HK2 làm mới (không có điểm từ HK1)**
  - Khi chọn "Học kỳ 2", không thấy điểm của lớp HK1
  - Điểm HK2 hoàn toàn riêng biệt

- [ ] **GPA hiển thị đúng**
  - GPA HK1 hiển thị đúng
  - GPA HK2 hiển thị riêng (không trộn với HK1)
  - GPA tích lũy bao gồm cả HK1 và HK2

### Test Fail nếu:

- [ ] Điểm HK1 bị mất sau khi chuyển học kỳ
- [ ] Điểm HK1 bị thay đổi sau khi chuyển học kỳ
- [ ] Điểm HK2 hiển thị điểm từ HK1
- [ ] Filter không hoạt động (chọn HK1 nhưng hiển thị HK2)
- [ ] GPA bị tính sai hoặc trộn lẫn

---

## 🔧 Cải thiện đề xuất (Tùy chọn)

Nếu muốn UI tự động cập nhật học kỳ sau khi chuyển, có thể:

1. **Thêm logic tự động refresh:**
   - Khi chuyển học kỳ thành công, tự động refresh trang xem điểm
   - Hoặc dùng SignalR để real-time update

2. **Cải thiện `loadSchoolYears()`:**
   - Khi năm học đã được chọn, vẫn cập nhật `selectedSemester` theo `currentSemester` mới

3. **Thêm event listener:**
   - Lắng nghe sự kiện chuyển học kỳ
   - Tự động cập nhật UI

**Nhưng hiện tại, code đã hoạt động đúng về mặt logic nghiệp vụ!** ✅

---

## 📝 Kết luận

**Code UI hiện tại:**
- ✅ **Filter điểm theo học kỳ**: Hoạt động đúng
- ✅ **Lưu trữ điểm**: Điểm HK1 không bị mất
- ✅ **Phân biệt điểm theo học kỳ**: Hoạt động đúng
- ⚠️ **Tự động cập nhật học kỳ**: Chưa tự động (cần click "Làm mới")

**Để test:**
1. Xem điểm HK1 trước khi chuyển
2. Chuyển học kỳ
3. Click "Làm mới" và kiểm tra điểm HK1 vẫn còn
4. Chọn "Học kỳ 2" và kiểm tra điểm làm mới

**Kết quả mong đợi:** Tất cả test case đều pass! ✅

