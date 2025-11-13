# ✅ Checklist - Minimal Setup

## 📋 Thứ tự chạy các file SQL

Đánh dấu ✅ sau khi hoàn thành mỗi bước:

### ⚠️ Bước 0: Reset Database (TÙY CHỌN)
- [ ] `00_ResetDatabase.sql` - **CHỈ chạy nếu muốn xóa sạch database cũ**

---

### ✅ Bước 1: Tạo Database Structure (BẮT BUỘC)
- [ ] `01_CreateTables.sql` - Tạo tất cả tables

---

### ✅ Bước 2: Tạo Stored Procedures (BẮT BUỘC)
- [ ] `02_SP_Users_And_System.sql`
- [ ] `02_SP_People.sql`
- [ ] `02_SP_Organization_And_Academic.sql`
- [ ] `02_SP_Academic_Operations.sql`
- [ ] `02_SP_Curriculum.sql`
- [ ] `02_SP_Scheduling.sql`
- [ ] `02_SP_Advisor.sql`
- [ ] `02_SP_Grade_Appeals_And_Formula.sql`
- [ ] `02_SP_Notifications.sql`

---

### ✅ Bước 3: Tạo Admin User và Permissions (BẮT BUỘC)
- [ ] `00_Minimal_Setup.sql` - Tạo roles, admin user, permissions

**Sau bước này, bạn có thể đăng nhập:**
- Username: `admin`
- Password: `admin123`

---

### ⚪ Bước 4: Tối ưu hiệu năng (KHUYẾN NGHỊ)
- [ ] `04_Indexes.sql` - Tạo indexes để tối ưu hiệu năng

---

### ⚪ Bước 5: Tạo Views (TÙY CHỌN)
- [ ] `05_Views.sql` - Tạo các view truy vấn

---

### ⚪ Bước 6: Tính năng mở rộng (TÙY CHỌN)
- [ ] `06_Add_Warning_Support.sql` - **Bổ sung** cột `last_warning_sent` vào bảng `students` (cảnh báo)
- [ ] `07_Create_Retake_Records.sql` - **Tạo bảng mới** `retake_records` + stored procedures (học lại)

---

## 🎯 Sau khi hoàn thành

1. ✅ Đăng nhập với tài khoản admin
2. ✅ Bắt đầu thêm dữ liệu từ frontend theo thứ tự:
   - Khoa → Bộ môn → Ngành học
   - Niên khóa → Năm học
   - Môn học → Lớp học phần
   - Sinh viên → Giảng viên → Cố vấn
   - Đợt đăng ký → Đăng ký học phần
   - Thời khóa biểu

---

## 📝 Ghi chú

- **Bắt buộc:** Bước 1, 2, 3 (không thể bỏ qua)
- **Khuyến nghị:** Bước 4 (nên chạy để tối ưu hiệu năng)
- **Tùy chọn:** Bước 0, 5, 6 (chỉ chạy nếu cần)

---

## ❌ KHÔNG chạy các file sau (dành cho Full Seed Data):

- ❌ `03_SeedData.sql` - File này tạo dữ liệu mẫu đầy đủ
- ❌ `03_ResetDataOnly.sql` - File này reset và seed lại data
- ❌ `03_DemoGrades.sql` - File này tạo điểm mẫu
- ❌ `04_SeedData_Advisor_Testing.sql` - File này seed data cho testing
- ❌ `05_SeedData_Complete_Students.sql` - File này seed data sinh viên đầy đủ

