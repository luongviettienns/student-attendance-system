# 📚 HƯỚNG DẪN CÁC FILE SQL

## 🎯 TÓM TẮT NHANH

### ✅ **FILES CẦN GIỮ & SỬ DỤNG** (Thứ tự chạy)

| STT | File | Mục đích | Bắt buộc | Khi nào chạy |
|-----|------|----------|----------|--------------|
| 1️⃣ | `00_ResetData.sql` | Xóa toàn bộ database | ❌ | Chỉ khi muốn reset hoàn toàn |
| 2️⃣ | `01_CreateTables.sql` | Tạo tất cả bảng | ✅ | Lần đầu setup hoặc reset |
| 3️⃣ | `02_StoredProcedures.sql` | Tạo stored procedures cơ bản | ✅ | Sau khi tạo tables |
| 4️⃣ | `03_Triggers.sql` | Tạo triggers cho audit | ⚠️ | Optional - xem chi tiết bên dưới |
| 5️⃣ | `04_SeedData.sql` | Insert dữ liệu mẫu | ✅ | Để có data test |
| 6️⃣ | `05_Indexes.sql` | Tạo indexes cho performance | ✅ | **BẮT BUỘC cho production** |
| 7️⃣ | `06_Views.sql` | Tạo views cho reporting | ✅ | Hữu ích cho báo cáo |
| 8️⃣ | `07_RefreshTokens.sql` | Stored procedures cho tokens | ✅ | **MỚI - CẦN CHẠY** |
| 9️⃣ | `08_StoredProcedures_ErrorHandling.sql` | Update SPs với error handling | ✅ | **MỚI - CẦN CHẠY** |

---

## 📋 CHI TIẾT TỪNG FILE

### 1. `00_ResetData.sql` ⚠️
**Mục đích:** Xóa toàn bộ database để bắt đầu lại từ đầu

**Khi nào dùng:**
- ❌ **KHÔNG dùng** trong production
- ✅ Dùng khi development và muốn reset hoàn toàn
- ✅ Dùng khi test migrations

**Nội dung:**
```sql
DROP DATABASE IF EXISTS EducationManagement;
```

**Lưu ý:** File này XÓA TOÀN BỘ DATA. Chỉ dùng khi chắc chắn!

---

### 2. `01_CreateTables.sql` ✅ **CẬP NHẬT**
**Mục đích:** Tạo toàn bộ cấu trúc database

**Đã bổ sung:** ✅ Bảng `refresh_tokens`

**Các bảng được tạo:**
1. `roles` - Vai trò người dùng
2. `users` - Người dùng
3. `faculties` - Khoa
4. `departments` - Bộ môn
5. `majors` - Ngành học
6. `academic_years` - Năm học
7. `students` - Sinh viên
8. `lecturers` - Giảng viên
9. `subjects` - Môn học
10. `classes` - Lớp học
11. `enrollments` - Đăng ký học
12. `attendances` - Điểm danh
13. `grades` - Điểm số
14. `gpas` - GPA
15. `notifications` - Thông báo
16. `permissions` - Quyền hạn
17. `role_permissions` - Quyền theo vai trò
18. `audit_logs` - Nhật ký hệ thống
19. **`refresh_tokens`** - JWT refresh tokens (NEW!)

**Khi nào chạy:**
- Lần đầu setup database
- Sau khi chạy `00_ResetData.sql`
- Khi muốn tạo lại database structure

---

### 3. `02_StoredProcedures.sql` ✅
**Mục đích:** Tạo 90+ stored procedures cho CRUD operations

**Nhóm procedures:**
- **Users Management** (7 SPs)
- **Faculties Management** (5 SPs)
- **Departments Management** (5 SPs)
- **Majors Management** (6 SPs)
- **Academic Years Management** (6 SPs)
- **Students Management** (6 SPs)
- **Lecturers Management** (5 SPs)
- **Subjects Management** (5 SPs)
- **Classes Management** (5 SPs)
- **Enrollments Management** (3 SPs)
- **Attendances Management** (3 SPs)
- **Grades Management** (4 SPs)
- **Roles Management** (2 SPs)
- **Notifications Management** (2 SPs)
- **Audit Logs Management** (5 SPs)
- **GPAs Management** (3 SPs)
- **Academic Year Transition** (2 SPs)
- **Permissions Management** (9 SPs)

**Có thể merge với:** `08_StoredProcedures_ErrorHandling.sql` (nhưng để riêng dễ quản lý hơn)

---

### 4. `03_Triggers.sql` ⚠️ **XEM XÉT**
**Mục đích:** Tự động tạo audit logs khi có thay đổi

**Nội dung:**
- Triggers cho Users, Students, Classes, Grades, Enrollments

**⚠️ ĐỀ XUẤT:**
- **CÓ THỂ KHÔNG CẦN** vì đã có audit logging trong stored procedures (file 08)
- **Triggers có thể gây chậm** khi có nhiều transactions
- **Trade-off:** 
  - ✅ Ưu điểm: Tự động audit mọi thay đổi (kể cả UPDATE trực tiếp)
  - ❌ Nhược điểm: Performance overhead, khó debug

**Quyết định:**
- 🟢 **GIỮ NẾU:** Bạn muốn audit mọi thay đổi kể cả direct SQL updates
- 🔴 **XÓA NẾU:** Chỉ dùng stored procedures và đã có error handling (file 08)

**Đề xuất:** ⚠️ **DISABLE hoặc XÓA** vì đã có audit trong SPs

---

### 5. `04_SeedData.sql` ✅
**Mục đích:** Insert dữ liệu mẫu để test

**Nội dung:**
- Roles (Admin, Lecturer, Student, Advisor)
- Sample Users
- Faculties, Departments, Majors
- Academic Years
- Sample Students & Lecturers
- Permissions data

**Khi nào chạy:**
- Sau khi tạo tables và stored procedures
- Khi cần data để test
- **KHÔNG chạy** trong production (hoặc chỉnh sửa data phù hợp)

---

### 6. `05_Indexes.sql` ✅ **ĐÃ CẬP NHẬT**
**Mục đích:** Tạo indexes để tối ưu performance

**Đã thêm:**
- ✅ 10+ pagination indexes
- ✅ 5+ foreign key indexes
- ✅ 2+ covering indexes
- ✅ 4 audit log indexes
- ✅ Role/Permission indexes
- ✅ Notification indexes

**BẮT BUỘC CHO PRODUCTION!**
- Không có indexes → Database RẤT CHẬM
- Với indexes → Queries nhanh 100x

**Khi nào chạy:**
- **Sau khi có data** (indexes work best với data)
- **Trước khi production**
- Có thể chạy bất kỳ lúc nào (idempotent)

---

### 7. `06_Views.sql` ✅
**Mục đích:** Tạo views để query dữ liệu dễ dàng

**Views được tạo:**
1. `vw_StudentTranscript` - Bảng điểm sinh viên
2. `vw_StudentGPASummary` - Tổng hợp GPA
3. `vw_ClassStatistics` - Thống kê lớp học
4. `vw_AttendanceHistory` - Lịch sử điểm danh
5. `vw_StudentCumulativeGPA` - GPA tích lũy
6. `vw_ClassRoster` - Danh sách sinh viên theo lớp

**Ưu điểm:**
- ✅ Đơn giản hóa queries phức tạp
- ✅ Hữu ích cho reporting
- ✅ Tái sử dụng logic

**Có thể bỏ qua nếu:** Bạn không cần reporting features

---

### 8. `07_RefreshTokens.sql` ✅ **MỚI - BẮT BUỘC**
**Mục đích:** Stored procedures để quản lý JWT refresh tokens

**Nội dung:**
- ✅ Tạo bảng `refresh_tokens` (nếu chưa có từ file 01)
- ✅ 3 indexes cho performance
- ✅ 5 stored procedures:
  - `sp_SaveRefreshToken`
  - `sp_GetRefreshTokenByToken`
  - `sp_RevokeRefreshToken`
  - `sp_CleanExpiredRefreshTokens`
  - `sp_RevokeAllUserTokens`

**⚠️ LƯU Ý:**
- Nếu đã chạy file `01_CreateTables.sql` (version mới), bảng `refresh_tokens` đã có
- File này sẽ skip tạo table nếu đã tồn tại
- Chỉ cần chạy để có stored procedures

**BẮT BUỘC CHO PRODUCTION!**

---

### 9. `08_StoredProcedures_ErrorHandling.sql` ✅ **MỚI - BẮT BUỘC**
**Mục đích:** Update stored procedures quan trọng với error handling

**Procedures được update:**
1. `sp_CreateUser` - Validation + audit
2. `sp_UpdateUser` - Duplicate check + audit
3. `sp_CreateStudent` - Business logic validation
4. `sp_CreateEnrollment` - Capacity check
5. `sp_UpdateGrade` - Score validation

**Tính năng:**
- ✅ TRY-CATCH blocks
- ✅ Transaction support
- ✅ Business logic validation
- ✅ Vietnamese error messages
- ✅ Automatic audit logging

**BẮT BUỘC CHO PRODUCTION!**

---

## 🚀 THỨ TỰ CHẠY ĐỀ XUẤT

### A. **SETUP LẦN ĐẦU** (Development)

```sql
-- Bước 1: Reset (optional)
-- 00_ResetData.sql

-- Bước 2: Tạo structure
01_CreateTables.sql          -- Tạo tất cả bảng (đã có refresh_tokens)

-- Bước 3: Tạo logic
02_StoredProcedures.sql      -- 90+ CRUD procedures
07_RefreshTokens.sql         -- Refresh token procedures
08_StoredProcedures_ErrorHandling.sql  -- Error handling

-- Bước 4: Optional
03_Triggers.sql              -- ⚠️ XEM XÉT - có thể bỏ qua

-- Bước 5: Tối ưu & Data
05_Indexes.sql               -- BẮT BUỘC!
06_Views.sql                 -- Hữu ích cho reporting
04_SeedData.sql              -- Test data
```

### B. **CẬP NHẬT HỆ THỐNG CŨ** (Nếu đã có database)

```sql
-- Chạy theo thứ tự:
07_RefreshTokens.sql                    -- Thêm refresh tokens
08_StoredProcedures_ErrorHandling.sql   -- Update SPs với error handling
05_Indexes.sql                          -- Thêm indexes mới (idempotent)
```

### C. **PRODUCTION DEPLOYMENT**

```sql
-- KHÔNG chạy 00_ResetData.sql và 04_SeedData.sql!

-- Chạy theo thứ tự:
01_CreateTables.sql                     -- Chỉ nếu database mới
02_StoredProcedures.sql
07_RefreshTokens.sql
08_StoredProcedures_ErrorHandling.sql
05_Indexes.sql                          -- BẮT BUỘC!
06_Views.sql                            -- Optional
-- Bỏ qua: 00, 03, 04
```

---

## ❌ FILES CÓ THỂ XÓA/MERGE

### 1. `03_Triggers.sql` ⚠️
**Đề xuất:** DISABLE hoặc XÓA

**Lý do:**
- Đã có audit logging trong stored procedures (file 08)
- Triggers gây performance overhead
- Khó debug và maintain

**Nếu muốn giữ:** Comment out hoặc rename thành `03_Triggers.sql.bak`

### 2. Không có file nào khác thừa!

---

## 🔄 TỐI ƯU HÓA (Optional)

### Option A: Merge files
```
08_StoredProcedures_ErrorHandling.sql → Merge vào 02_StoredProcedures.sql
```

**Ưu điểm:** Ít file hơn  
**Nhược điểm:** File 02 sẽ rất dài (2000+ lines)

**Đề xuất:** GIỮ RIÊNG để dễ quản lý

### Option B: Tạo master script
```sql
-- master_setup.sql
:r 01_CreateTables.sql
:r 02_StoredProcedures.sql
:r 07_RefreshTokens.sql
:r 08_StoredProcedures_ErrorHandling.sql
:r 05_Indexes.sql
:r 06_Views.sql
```

---

## 📊 TỔNG KẾT

### ✅ Files BẮT BUỘC (8 files)
1. ✅ `01_CreateTables.sql` - **ĐÃ CẬP NHẬT**
2. ✅ `02_StoredProcedures.sql`
3. ✅ `04_SeedData.sql` - Development only
4. ✅ `05_Indexes.sql` - **ĐÃ CẬP NHẬT**
5. ✅ `06_Views.sql`
6. ✅ `07_RefreshTokens.sql` - **MỚI**
7. ✅ `08_StoredProcedures_ErrorHandling.sql` - **MỚI**
8. ⚠️ `00_ResetData.sql` - Development only

### ⚠️ Files XEM XÉT (1 file)
- ⚠️ `03_Triggers.sql` - Có thể bỏ qua

### 📈 Thống kê
- **Tổng files:** 9 files
- **Files bắt buộc production:** 6 files (01, 02, 05, 06, 07, 08)
- **Files development:** 2 files (00, 04)
- **Files optional:** 1 file (03)

---

## 🎯 CHECKLIST TRIỂN KHAI

### Development
- [ ] Chạy `00_ResetData.sql` (optional)
- [ ] Chạy `01_CreateTables.sql` (updated)
- [ ] Chạy `02_StoredProcedures.sql`
- [ ] Chạy `07_RefreshTokens.sql` (NEW)
- [ ] Chạy `08_StoredProcedures_ErrorHandling.sql` (NEW)
- [ ] Quyết định về `03_Triggers.sql` (recommend: skip)
- [ ] Chạy `05_Indexes.sql` (updated)
- [ ] Chạy `06_Views.sql`
- [ ] Chạy `04_SeedData.sql`

### Production
- [ ] Backup database hiện tại
- [ ] Chạy `01_CreateTables.sql` (nếu database mới)
- [ ] Chạy `02_StoredProcedures.sql`
- [ ] Chạy `07_RefreshTokens.sql` ✨ **NEW**
- [ ] Chạy `08_StoredProcedures_ErrorHandling.sql` ✨ **NEW**
- [ ] Chạy `05_Indexes.sql` ⚡ **IMPORTANT**
- [ ] Chạy `06_Views.sql`
- [ ] Skip `00_ResetData.sql`, `03_Triggers.sql`, `04_SeedData.sql`
- [ ] Verify với sample queries
- [ ] Setup SQL Agent job cho `sp_CleanExpiredRefreshTokens`

---

**Version:** 2.0  
**Cập nhật:** Sau khi triển khai optimizations  
**Tác giả:** AI Assistant

