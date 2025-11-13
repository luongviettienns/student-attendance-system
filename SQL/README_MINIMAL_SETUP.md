# Hướng dẫn Khởi tạo Hệ thống Tối thiểu

## 📋 Tổng quan

File `00_Minimal_Setup.sql` chỉ tạo các thành phần cơ bản nhất để hệ thống có thể hoạt động:
- ✅ 4 Roles (Admin, Lecturer, Student, Advisor)
- ✅ 1 Admin User (để đăng nhập)
- ✅ Tất cả Permissions (để menu hoạt động)
- ✅ Role-Permission mappings

**KHÔNG tạo** dữ liệu mẫu như: Faculties, Departments, Majors, Students, Lecturers, Subjects, Classes, etc.

## 🚀 Cách sử dụng

### 📋 Thứ tự chạy các file SQL (QUAN TRỌNG!)

Chạy các file SQL **theo đúng thứ tự** sau:

#### **Bước 0: Reset Database (CHỈ chạy nếu muốn xóa database cũ)**

```sql
00_ResetDatabase.sql
```
⚠️ **Lưu ý:** File này sẽ **XÓA HOÀN TOÀN** database cũ và tạo lại. Chỉ chạy khi:
- Lần đầu setup
- Muốn reset hoàn toàn database
- Database hiện tại có lỗi cần xóa sạch

**Nếu database đã tồn tại và bạn chỉ muốn cập nhật, BỎ QUA bước này.**

---

#### **Bước 1: Tạo Database Structure (BẮT BUỘC)**

```sql
01_CreateTables.sql
```
✅ Tạo tất cả các bảng (tables) cần thiết

---

#### **Bước 2: Tạo Stored Procedures (BẮT BUỘC)**

Chạy **TẤT CẢ** các file sau theo thứ tự:

```sql
02_SP_Users_And_System.sql
02_SP_People.sql
02_SP_Organization_And_Academic.sql
02_SP_Academic_Operations.sql
02_SP_Curriculum.sql
02_SP_Scheduling.sql
02_SP_Advisor.sql
02_SP_Grade_Appeals_And_Formula.sql
02_SP_Notifications.sql
```
✅ Tạo tất cả stored procedures cho các chức năng

---

#### **Bước 3: Tạo Admin User và Permissions (BẮT BUỘC)**

```sql
00_Minimal_Setup.sql
```
✅ Tạo 4 roles, 1 admin user, và tất cả permissions

---

#### **Bước 4: Tối ưu hiệu năng (TÙY CHỌN - Khuyến nghị)**

```sql
04_Indexes.sql
```
✅ Tạo indexes để tối ưu hiệu năng truy vấn, đặc biệt cho phân trang

---

#### **Bước 5: Tạo Views (TÙY CHỌN)**

```sql
05_Views.sql
```
✅ Tạo các view để truy vấn dữ liệu dễ dàng hơn

---

#### **Bước 6: Tính năng mở rộng (TÙY CHỌN - Chỉ chạy nếu cần)**

```sql
06_Add_Warning_Support.sql    -- Hệ thống cảnh báo tự động
07_Create_Retake_Records.sql   -- Quản lý học lại
```

**Chi tiết:**

- **`06_Add_Warning_Support.sql`**: 
  - ✅ **Bổ sung** vào bảng `students` đã có (thêm cột `last_warning_sent`)
  - ✅ Tạo index mới cho hiệu năng
  - ⚠️ **KHÔNG** tạo bảng mới, chỉ mở rộng bảng hiện có

- **`07_Create_Retake_Records.sql`**: 
  - ✅ **Tạo bảng mới** `retake_records` (bảng này KHÔNG có trong `01_CreateTables.sql`)
  - ✅ Tạo các stored procedures mới cho quản lý học lại
  - ✅ Tạo indexes cho bảng mới
  - ⚠️ **BẮT BUỘC** nếu hệ thống cần tính năng học lại

---

### 📊 Tóm tắt thứ tự chạy

| # | File | Bắt buộc? | Mô tả |
|---|------|-----------|-------|
| 0 | `00_ResetDatabase.sql` | ⚠️ Tùy chọn | Reset database (chỉ khi cần xóa sạch) |
| 1 | `01_CreateTables.sql` | ✅ **Bắt buộc** | Tạo tất cả tables |
| 2.1 | `02_SP_Users_And_System.sql` | ✅ **Bắt buộc** | SP cho Users & System |
| 2.2 | `02_SP_People.sql` | ✅ **Bắt buộc** | SP cho Students, Lecturers, Advisors |
| 2.3 | `02_SP_Organization_And_Academic.sql` | ✅ **Bắt buộc** | SP cho Organization & Academic |
| 2.4 | `02_SP_Academic_Operations.sql` | ✅ **Bắt buộc** | SP cho Attendance & Grades |
| 2.5 | `02_SP_Curriculum.sql` | ✅ **Bắt buộc** | SP cho Curriculum |
| 2.6 | `02_SP_Scheduling.sql` | ✅ **Bắt buộc** | SP cho Scheduling |
| 2.7 | `02_SP_Advisor.sql` | ✅ **Bắt buộc** | SP cho Advisor functions |
| 2.8 | `02_SP_Grade_Appeals_And_Formula.sql` | ✅ **Bắt buộc** | SP cho Grade Appeals |
| 2.9 | `02_SP_Notifications.sql` | ✅ **Bắt buộc** | SP cho Notifications |
| 3 | `00_Minimal_Setup.sql` | ✅ **Bắt buộc** | Tạo roles, admin user, permissions |
| 4 | `04_Indexes.sql` | ⚪ Khuyến nghị | Tối ưu hiệu năng |
| 5 | `05_Views.sql` | ⚪ Tùy chọn | Tạo views |
| 6 | `06_Add_Warning_Support.sql` | ⚪ Tùy chọn | Bổ sung cột vào bảng `students` (cảnh báo) |
| 7 | `07_Create_Retake_Records.sql` | ⚪ Tùy chọn | Tạo bảng mới `retake_records` (học lại) |

---

### ⚡ Script chạy nhanh (Copy & Paste vào SQL Server Management Studio)

```sql
-- ===========================================
-- MINIMAL SETUP - QUICK RUN
-- ===========================================

-- Bước 0: Reset (CHỈ chạy nếu cần xóa sạch database)
-- EXEC: 00_ResetDatabase.sql

-- Bước 1: Create Tables
:r "01_CreateTables.sql"

-- Bước 2: Stored Procedures
:r "02_SP_Users_And_System.sql"
:r "02_SP_People.sql"
:r "02_SP_Organization_And_Academic.sql"
:r "02_SP_Academic_Operations.sql"
:r "02_SP_Curriculum.sql"
:r "02_SP_Scheduling.sql"
:r "02_SP_Advisor.sql"
:r "02_SP_Grade_Appeals_And_Formula.sql"
:r "02_SP_Notifications.sql"

-- Bước 3: Minimal Setup (Roles, Admin, Permissions)
:r "00_Minimal_Setup.sql"

-- Bước 4: Indexes (Khuyến nghị)
:r "04_Indexes.sql"

-- Bước 5: Views (Tùy chọn)
:r "05_Views.sql"

-- Bước 6: Tính năng mở rộng (Tùy chọn)
-- :r "06_Add_Warning_Support.sql"
-- :r "07_Create_Retake_Records.sql"
```

**Lưu ý:** Syntax `:r` chỉ hoạt động trong SQLCMD mode. Nếu dùng SSMS, mở từng file và chạy lần lượt.

### Bước 3: Đăng nhập và Thêm Dữ liệu

1. **Đăng nhập với tài khoản admin:**
   - Username: `admin`
   - Password: `admin123`

2. **Thêm dữ liệu từ frontend theo thứ tự:**

   #### Thứ tự ưu tiên (theo Foreign Key dependencies):
   
   **Bước 1: Tổ chức đào tạo**
   - Quản lý đào tạo → Thêm **Khoa** (Faculties)
   - Quản lý đào tạo → Thêm **Bộ môn** (Departments) - cần có Khoa
   - Quản lý đào tạo → Thêm **Ngành học** (Majors) - cần có Khoa
   
   **Bước 2: Thời gian học**
   - Quản lý đào tạo → Thêm **Niên khóa** (Academic Years) - ví dụ: K21, K22, K23, K24
   - Quản lý đào tạo → Thêm **Năm học** (School Years) - ví dụ: 2024-2025
   
   **Bước 3: Môn học và Lớp**
   - Học phần → Thêm **Môn học** (Subjects) - cần có Bộ môn
   - Học phần → Quản lý **Môn tiên quyết** (Subject Prerequisites) - nếu có
   - Học phần → Thêm **Lớp học phần** (Classes) - cần có Môn học, Năm học, Giảng viên
   
   **Bước 4: Người dùng**
   - Quản lý đào tạo → Thêm **Sinh viên** (Students) - cần có Ngành học, Niên khóa
   - Quản lý đào tạo → Thêm **Giảng viên** (Lecturers) - cần có Bộ môn
   - Quản lý đào tạo → Thêm **Cố vấn học tập** (Advisors) - tạo user với role ROLE_ADVISOR
   - Quản lý người dùng → Thêm **Tài khoản** (Users) - cho các role khác
   
   **Bước 5: Lớp hành chính**
   - Lớp học → Thêm **Lớp chính khóa** (Administrative Classes) - cần có Niên khóa, Ngành học
   
   **Bước 6: Đăng ký học phần**
   - Đăng ký học phần → Thêm **Đợt đăng ký** (Registration Periods) - cần có Năm học
   - Đăng ký học phần → **Quản lý đăng ký** (Enrollments) - sinh viên đăng ký lớp học phần
   
   **Bước 7: Thời khóa biểu**
   - Quản lý thời khóa biểu → Xếp lịch cho các lớp học phần

## ⚠️ Lưu ý quan trọng

1. **Thứ tự thêm dữ liệu rất quan trọng** vì có Foreign Key constraints
2. **Không thể bỏ qua bước nào** - ví dụ: không thể thêm Sinh viên nếu chưa có Ngành học và Niên khóa
3. **Có thể thêm từng bước một** - không cần thêm tất cả cùng lúc
4. **Có thể import từ Excel** nếu frontend hỗ trợ chức năng import

## 🔄 So sánh với Full Seed Data

| Tính năng | Minimal Setup | Full Seed Data (03_SeedData.sql) |
|-----------|---------------|----------------------------------|
| Roles | ✅ 4 roles | ✅ 4 roles |
| Admin User | ✅ 1 user | ✅ 1 user |
| Permissions | ✅ Đầy đủ | ✅ Đầy đủ |
| Faculties | ❌ | ✅ 1 faculty |
| Departments | ❌ | ✅ 2 departments |
| Majors | ❌ | ✅ 2 majors |
| Academic Years | ❌ | ✅ 4 cohorts (K21-K24) |
| School Years | ❌ | ✅ 16 school years |
| Subjects | ❌ | ✅ 4 subjects |
| Students | ❌ | ✅ 5 students |
| Lecturers | ❌ | ✅ 2 lecturers |
| Classes | ❌ | ✅ 4 classes |
| Enrollments | ❌ | ✅ 6 enrollments |

## 💡 Khi nào dùng Minimal Setup?

✅ **Nên dùng khi:**
- Bạn muốn tự thêm dữ liệu thực tế từ đầu
- Bạn muốn kiểm soát hoàn toàn dữ liệu
- Bạn đang setup cho production
- Bạn có dữ liệu sẵn từ hệ thống cũ

❌ **Không nên dùng khi:**
- Bạn cần test nhanh với dữ liệu mẫu
- Bạn đang demo hệ thống
- Bạn muốn có dữ liệu để test các tính năng ngay

## 📝 Ghi chú

- File này **KHÔNG** tạo dữ liệu mẫu
- Bạn **PHẢI** thêm dữ liệu từ frontend sau khi đăng nhập
- Thứ tự thêm dữ liệu **RẤT QUAN TRỌNG** do Foreign Key constraints
- Có thể quay lại dùng `03_SeedData.sql` nếu muốn có dữ liệu mẫu đầy đủ

## 🔍 Chi tiết về File 06 và 07

### File 06: `06_Add_Warning_Support.sql`
- **Loại:** Bổ sung vào bảng đã có
- **Thay đổi:** 
  - Thêm cột `last_warning_sent DATETIME` vào bảng `students`
  - Tạo index `IX_Students_LastWarningSent`
- **An toàn:** Có thể chạy bất cứ lúc nào, không ảnh hưởng dữ liệu hiện có
- **Khi nào cần:** Khi muốn sử dụng tính năng cảnh báo tự động cho sinh viên

### File 07: `07_Create_Retake_Records.sql`
- **Loại:** Tạo bảng mới + stored procedures
- **Thay đổi:**
  - Tạo bảng mới `retake_records` (KHÔNG có trong `01_CreateTables.sql`)
  - Tạo 7 stored procedures mới cho quản lý học lại
  - Tạo 5 indexes cho bảng mới
- **An toàn:** Tạo bảng mới, không ảnh hưởng bảng cũ
- **Khi nào cần:** Khi muốn sử dụng tính năng quản lý học lại (retake) cho sinh viên
- **Lưu ý:** Bảng này có Foreign Key đến `enrollments`, `students`, `classes`, `subjects` - đảm bảo các bảng này đã tồn tại

