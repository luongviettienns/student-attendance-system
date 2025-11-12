# 🔑 Thông Tin Tài Khoản Hệ Thống

## 📋 Tổng Quan

File này chứa thông tin đăng nhập cho tất cả các tài khoản được seed trong hệ thống Quản lý Điểm danh Sinh viên (Full Test Dataset).

**⚠️ LƯU Ý BẢO MẬT:**
- File này chỉ dùng cho môi trường **Development/Testing**
- **KHÔNG** sử dụng các mật khẩu này trong môi trường Production
- Nên thay đổi mật khẩu sau khi deploy lên môi trường thực tế

---

## 👤 Tài Khoản Admin

### Admin Chính

| Username | Password | Email | Vai trò | Mô tả |
|----------|----------|-------|---------|-------|
| `admin` | `admin123` | admin@example.com | Admin | Quản trị viên hệ thống chính |

**Thông tin chi tiết:**
- **User ID:** USER001
- **Họ tên:** Nguyễn Văn Admin
- **Số điện thoại:** 0901234567
- **Quyền:** ROLE_ADMIN (Toàn quyền hệ thống)

### Admin Full Test

| Username | Password | Email | Vai trò | Mô tả |
|----------|----------|-------|---------|-------|
| `admin_fulltest` | `admin123` | admin.ft@example.com | Admin | Admin cho mục đích test |

**Thông tin chi tiết:**
- **User ID:** USR_ADMIN_FT
- **Họ tên:** Nguyen Minh Quan Tri
- **Số điện thoại:** 0901000000
- **Quyền:** ROLE_ADMIN (Toàn quyền hệ thống)

---

## 👨‍🏫 Tài Khoản Giảng Viên

### Giảng Viên 01

| Username | Password | Email | Vai trò | Mô tả |
|----------|----------|-------|---------|-------|
| `lecturer_hung` | `password123` | hung.lecturer@example.com | Lecturer | Giảng viên Nguyễn Hữu Hùng |

**Thông tin chi tiết:**
- **User ID:** USR_LEC_01
- **Lecturer ID:** LEC_FT_01
- **Lecturer Code:** GVFT01
- **Họ tên:** Nguyen Huu Hung
- **Số điện thoại:** 0909000001
- **Bộ môn:** Bộ môn Công nghệ Phần mềm (DEP_SE)
- **Quyền:** ROLE_LECTURER (Quản lý lớp học, nhập điểm, điểm danh)

### Giảng Viên 02

| Username | Password | Email | Vai trò | Mô tả |
|----------|----------|-------|---------|-------|
| `lecturer_thao` | `password123` | thao.lecturer@example.com | Lecturer | Giảng viên Phạm Thảo Như |

**Thông tin chi tiết:**
- **User ID:** USR_LEC_02
- **Lecturer ID:** LEC_FT_02
- **Lecturer Code:** GVFT02
- **Họ tên:** Pham Thao Nhu
- **Số điện thoại:** 0909000002
- **Bộ môn:** Bộ môn Khoa học Dữ liệu (DEP_DS)
- **Quyền:** ROLE_LECTURER (Quản lý lớp học, nhập điểm, điểm danh)

---

## 🎓 Tài Khoản Cố Vấn Học Tập & Nhân Viên Phòng Đào Tạo

**Lưu ý:** Role này đã được gộp từ "Cố vấn học tập" và "Nhân viên phòng đào tạo" thành một role duy nhất.

### Cố Vấn / Nhân Viên Phòng Đào Tạo 01

| Username | Password | Email | Vai trò | Mô tả |
|----------|----------|-------|---------|-------|
| `support_academic` | `password123` | support.academic@example.com | Advisor | Nhân viên phòng đào tạo (đã gộp vào Advisor) |

**Thông tin chi tiết:**
- **User ID:** USR_SUPPORT_FT
- **Họ tên:** Trần Hoài Thu
- **Số điện thoại:** 0901000001
- **Quyền:** ROLE_ADVISOR
  - Quyền Cố vấn học tập: Quản lý sinh viên được phụ trách, cảnh báo, phúc khảo, duyệt đăng ký
  - Quyền Nhân viên phòng đào tạo: Quản lý đợt đăng ký, quản lý đăng ký học phần, xem nhật ký hệ thống

### Cố Vấn Học Tập 02

| Username | Password | Email | Vai trò | Mô tả |
|----------|----------|-------|---------|-------|
| `advisor_toan` | `password123` | advisor.toan@example.com | Advisor | Cố vấn học tập |

**Thông tin chi tiết:**
- **User ID:** USR_ADV_01
- **Lecturer ID:** LEC_FT_ADV
- **Lecturer Code:** ADFT01
- **Họ tên:** Dang Quoc Toan
- **Số điện thoại:** 0909000003
- **Bộ môn:** Bộ môn Công nghệ Phần mềm (DEP_SE)
- **Quyền:** ROLE_ADVISOR
  - Quyền Cố vấn học tập: Quản lý sinh viên được phụ trách, cảnh báo, phúc khảo, duyệt đăng ký
  - Quyền Nhân viên phòng đào tạo: Quản lý đợt đăng ký, quản lý đăng ký học phần, xem nhật ký hệ thống

---

## 👨‍🎓 Tài Khoản Sinh Viên

### Khóa 21 (K21) - Năm 4

#### Sinh Viên K21 - 001

| Username | Password | Email | Vai trò | Mô tả |
|----------|----------|-------|---------|-------|
| `student_k21_a` | `password123` | st.k21.001@example.com | Student | Sinh viên K21 - Công nghệ Phần mềm |

**Thông tin chi tiết:**
- **User ID:** USR_STU_21A
- **Student ID:** STU_K21_001
- **Student Code:** K21SE001
- **Họ tên:** Tran Nhat Minh
- **Giới tính:** Nam
- **Ngày sinh:** 2003-02-11
- **Số điện thoại:** 0911000001
- **Địa chỉ:** Quan 1, TP HCM
- **Chuyên ngành:** Công nghệ Phần mềm (MAJ_SE)
- **Niên khóa:** AY2021 (2021-2025)
- **Lớp hành chính:** ADM_K21_SE_A
- **Cố vấn:** Dang Quoc Toan (LEC_FT_ADV)

#### Sinh Viên K21 - 002

| Username | Password | Email | Vai trò | Mô tả |
|----------|----------|-------|---------|-------|
| `student_k21_b` | `password123` | st.k21.002@example.com | Student | Sinh viên K21 - Công nghệ Phần mềm |

**Thông tin chi tiết:**
- **User ID:** USR_STU_21B
- **Student ID:** STU_K21_002
- **Student Code:** K21SE002
- **Họ tên:** Ngo Dieu Anh
- **Giới tính:** Nữ
- **Ngày sinh:** 2003-07-30
- **Số điện thoại:** 0911000002
- **Địa chỉ:** Quan 3, TP HCM
- **Chuyên ngành:** Công nghệ Phần mềm (MAJ_SE)
- **Niên khóa:** AY2021 (2021-2025)
- **Lớp hành chính:** ADM_K21_SE_A
- **Cố vấn:** Dang Quoc Toan (LEC_FT_ADV)

---

### Khóa 22 (K22) - Năm 3

#### Sinh Viên K22 - 001

| Username | Password | Email | Vai trò | Mô tả |
|----------|----------|-------|---------|-------|
| `student_k22_a` | `password123` | st.k22.010@example.com | Student | Sinh viên K22 - Công nghệ Phần mềm |

**Thông tin chi tiết:**
- **User ID:** USR_STU_22A
- **Student ID:** STU_K22_001
- **Student Code:** K22SE010
- **Họ tên:** Pham Huu Long
- **Giới tính:** Nam
- **Ngày sinh:** 2004-05-15
- **Số điện thoại:** 0912000001
- **Địa chỉ:** Thu Duc, TP HCM
- **Chuyên ngành:** Công nghệ Phần mềm (MAJ_SE)
- **Niên khóa:** AY2022 (2022-2026)
- **Lớp hành chính:** ADM_K22_SE_B
- **Cố vấn:** Dang Quoc Toan (LEC_FT_ADV)

---

### Khóa 23 (K23) - Năm 2

#### Sinh Viên K23 - 001

| Username | Password | Email | Vai trò | Mô tả |
|----------|----------|-------|---------|-------|
| `student_k23_a` | `password123` | st.k23.005@example.com | Student | Sinh viên K23 - Khoa học Dữ liệu |

**Thông tin chi tiết:**
- **User ID:** USR_STU_23A
- **Student ID:** STU_K23_001
- **Student Code:** K23DS005
- **Họ tên:** Luu Gia Khanh
- **Giới tính:** Nam
- **Ngày sinh:** 2005-04-02
- **Số điện thoại:** 0913000001
- **Địa chỉ:** Quan 7, TP HCM
- **Chuyên ngành:** Khoa học Dữ liệu (MAJ_DS)
- **Niên khóa:** AY2023 (2023-2027)
- **Lớp hành chính:** ADM_K23_DS_A
- **Cố vấn:** Pham Thao Nhu (LEC_FT_02)

---

### Khóa 24 (K24) - Năm 1

#### Sinh Viên K24 - 001

| Username | Password | Email | Vai trò | Mô tả |
|----------|----------|-------|---------|-------|
| `student_k24_a` | `password123` | st.k24.015@example.com | Student | Sinh viên K24 - Công nghệ Phần mềm |

**Thông tin chi tiết:**
- **User ID:** USR_STU_24A
- **Student ID:** STU_K24_001
- **Student Code:** K24SE015
- **Họ tên:** Do Quynh Nhi
- **Giới tính:** Nữ
- **Ngày sinh:** 2006-10-19
- **Số điện thoại:** 0914000001
- **Địa chỉ:** Quan Binh Thanh, TP HCM
- **Chuyên ngành:** Công nghệ Phần mềm (MAJ_SE)
- **Niên khóa:** AY2024 (2024-2028)
- **Lớp hành chính:** ADM_K24_SE_A
- **Cố vấn:** Nguyen Huu Hung (LEC_FT_01)

#### Sinh Viên K24 - 002

| Username | Password | Email | Vai trò | Mô tả |
|----------|----------|-------|---------|-------|
| `student_k24_b` | `password123` | st.k24.099@example.com | Student | Sinh viên K24 - Marketing |

**Thông tin chi tiết:**
- **User ID:** USR_STU_24B
- **Student ID:** STU_K24_002
- **Student Code:** K24MKT099
- **Họ tên:** Le Minh Triet
- **Giới tính:** Nam
- **Ngày sinh:** 2006-12-01
- **Số điện thoại:** 0914000002
- **Địa chỉ:** Quan Phu Nhuan, TP HCM
- **Chuyên ngành:** Marketing (MAJ_MKT)
- **Niên khóa:** AY2024 (2024-2028)
- **Lớp hành chính:** ADM_K24_MKT_A
- **Cố vấn:** Pham Thao Nhu (LEC_FT_02)

---

## 📊 Tóm Tắt

| Loại tài khoản | Số lượng | Mật khẩu mặc định | Ghi chú |
|----------------|----------|-------------------|---------|
| Admin | 2 | `admin123` | USER001 (admin), USR_ADMIN_FT (admin_fulltest) |
| Lecturer | 2 | `password123` | USR_LEC_01, USR_LEC_02 |
| Advisor | 2 | `password123` | USR_SUPPORT_FT (gộp Support), USR_ADV_01 |
| Student (K21) | 2 | `password123` | USR_STU_21A, USR_STU_21B |
| Student (K22) | 1 | `password123` | USR_STU_22A |
| Student (K23) | 1 | `password123` | USR_STU_23A |
| Student (K24) | 2 | `password123` | USR_STU_24A, USR_STU_24B |
| **TỔNG CỘNG** | **12** | - | - |

---

## 🔐 Thông Tin Hash (BCrypt)

### Admin
- **Password:** `admin123`
- **Hash:** `$2a$10$h5gvrNjE2bhwhHn6Ofofq.Ppr0hvpLY5Q3mbY1OjkkGL8CMxm2VBm`

### Các user khác (Lecturer, Advisor, Student)
- **Password:** `password123`
- **Hash:** `$2a$10$Ya6MFL1CGpg2/y088u6t7.ACYkMJdmA1869rbBmAnyn6OQi0hTBue`

---

## 📝 Ghi Chú Quan Trọng

### Về Role Advisor
- Role **ROLE_ADVISOR** đã được gộp từ hai role:
  - **Cố vấn học tập** (Academic Advisor)
  - **Nhân viên phòng đào tạo** (Academic Support)
- Tất cả users có role này sẽ có đầy đủ quyền của cả hai chức năng:
  - Quản lý sinh viên được phụ trách
  - Quản lý đợt đăng ký học phần
  - Quản lý đăng ký học phần
  - Xem nhật ký hệ thống
  - Và các quyền khác...

### Về Seed Data
- File seed data chính: `SQL/03_SeedData_FullTest.sql`
- Tất cả tài khoản được tạo với `is_active = 1`
- Mật khẩu đã được hash bằng BCrypt

---

**Cập nhật lần cuối:** Sau khi gộp ROLE_SUPPORT vào ROLE_ADVISOR
