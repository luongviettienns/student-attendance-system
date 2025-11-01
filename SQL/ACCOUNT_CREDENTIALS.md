# 🔑 Thông Tin Tài Khoản Hệ Thống

## 📋 Tổng Quan

File này chứa thông tin đăng nhập cho tất cả các tài khoản được seed trong hệ thống Quản lý Điểm danh Sinh viên.

**⚠️ LƯU Ý BẢO MẬT:**
- File này chỉ dùng cho môi trường **Development/Testing**
- **KHÔNG** sử dụng các mật khẩu này trong môi trường Production
- Nên thay đổi mật khẩu sau khi deploy lên môi trường thực tế

---

## 👤 Tài Khoản Admin

| Username | Password | Email | Vai trò | Mô tả |
|----------|----------|-------|---------|-------|
| `admin` | `admin123` | admin@example.com | Admin | Quản trị viên hệ thống |

**Thông tin chi tiết:**
- **User ID:** USER001
- **Họ tên:** Nguyễn Văn Admin
- **Số điện thoại:** 0901234567
- **Quyền:** ROLE_ADMIN (Toàn quyền hệ thống)

---

## 👨‍🏫 Tài Khoản Giảng Viên

| Username | Password | Email | Vai trò | Mô tả |
|----------|----------|-------|---------|-------|
| `lecturer01` | `password123` | lecturer01@example.com | Lecturer | Giảng viên |

**Thông tin chi tiết:**
- **User ID:** USER002
- **Lecturer ID:** LEC001
- **Lecturer Code:** GV001
- **Họ tên:** Trần Thị Hoa
- **Số điện thoại:** 0902222222
- **Bộ môn:** Khoa học Máy tính (DEPT001)
- **Quyền:** ROLE_LECTURER (Quản lý lớp học, nhập điểm)

---

## 👨‍🎓 Tài Khoản Sinh Viên

### Khóa 21 (K21) - Năm 4

| Username | Password | Email | Vai trò | Mô tả |
|----------|----------|-------|---------|-------|
| `student_k21_01` | `password123` | student.k21.01@example.com | Student | Sinh viên K21 |
| `student_k21_02` | `password123` | student.k21.02@example.com | Student | Sinh viên K21 |

**Thông tin chi tiết:**

**student_k21_01:**
- **User ID:** USER003
- **Student ID:** STU001
- **Student Code:** SV2021001
- **Họ tên:** Lê Văn An
- **Giới tính:** Nam
- **Ngày sinh:** 2003-05-15
- **Số điện thoại:** 0903333333
- **Chuyên ngành:** Công nghệ Phần mềm (MAJ001)
- **Niên khóa:** AY2021 (2021-2025)

**student_k21_02:**
- **User ID:** USER004
- **Student ID:** STU002
- **Student Code:** SV2021002
- **Họ tên:** Phạm Thị Bình
- **Giới tính:** Nữ
- **Ngày sinh:** 2003-08-20
- **Số điện thoại:** 0904444444
- **Chuyên ngành:** Công nghệ Phần mềm (MAJ001)
- **Niên khóa:** AY2021 (2021-2025)

---

### Khóa 22 (K22) - Năm 3

| Username | Password | Email | Vai trò | Mô tả |
|----------|----------|-------|---------|-------|
| `student_k22_01` | `password123` | student.k22.01@example.com | Student | Sinh viên K22 |

**Thông tin chi tiết:**
- **User ID:** USER005
- **Student ID:** STU003
- **Student Code:** SV2022001
- **Họ tên:** Nguyễn Văn Cường
- **Giới tính:** Nam
- **Ngày sinh:** 2004-03-10
- **Số điện thoại:** 0905555555
- **Chuyên ngành:** Khoa học Dữ liệu (MAJ002)
- **Niên khóa:** AY2022 (2022-2026)

---

### Khóa 23 (K23) - Năm 2

| Username | Password | Email | Vai trò | Mô tả |
|----------|----------|-------|---------|-------|
| `student_k23_01` | `password123` | student.k23.01@example.com | Student | Sinh viên K23 |

**Thông tin chi tiết:**
- **User ID:** USER006
- **Student ID:** STU004
- **Student Code:** SV2023001
- **Họ tên:** Hoàng Thị Dung
- **Giới tính:** Nữ
- **Ngày sinh:** 2005-07-25
- **Số điện thoại:** 0906666666
- **Chuyên ngành:** Công nghệ Phần mềm (MAJ001)
- **Niên khóa:** AY2023 (2023-2027)

---

### Khóa 24 (K24) - Năm 1 (Sinh viên mới)

| Username | Password | Email | Vai trò | Mô tả |
|----------|----------|-------|---------|-------|
| `student_k24_01` | `password123` | student.k24.01@example.com | Student | Sinh viên K24 |

**Thông tin chi tiết:**
- **User ID:** USER007
- **Student ID:** STU005
- **Student Code:** SV2024001
- **Họ tên:** Đinh Văn Em
- **Giới tính:** Nam
- **Ngày sinh:** 2006-11-30
- **Số điện thoại:** 0907777777
- **Chuyên ngành:** Khoa học Dữ liệu (MAJ002)
- **Niên khóa:** AY2024 (2024-2028)

---

## 📊 Tóm Tắt

| Loại tài khoản | Số lượng | Mật khẩu mặc định |
|----------------|----------|-------------------|
| Admin | 1 | `admin123` |
| Lecturer | 1 | `password123` |
| Student (K21) | 2 | `password123` |
| Student (K22) | 1 | `password123` |
| Student (K23) | 1 | `password123` |
| Student (K24) | 1 | `password123` |
| **TỔNG CỘNG** | **7** | - |

---

## 🔐 Thông Tin Hash (BCrypt)

### Admin
- **Password:** `admin123`
- **Hash:** `$2a$10$h5gvrNjE2bhwhHn6Ofofq.Ppr0hvpLY5Q3mbY1OjkkGL8CMxm2VBm`

### Các user khác
- **Password:** `password123`
- **Hash:** `$2a$10$Ya6MFL1CGpg2/y088u6t7.ACYkMJdmA1869rbBmAnyn6OQi0hTBue`

---

## 🎯 Cách Sử Dụng

### Đăng nhập qua API
```http
POST {{base_url}}/auth/login
Content-Type: application/json

{
    "username": "admin",
    "password": "admin123"
}
```

### Đăng nhập qua Frontend
1. Truy cập trang đăng nhập
2. Nhập username và password tương ứng
3. Chọn vai trò (nếu có)

---

## 📝 Lưu Ý

1. **Môi trường Development:** Các mật khẩu này chỉ dùng cho testing
2. **Môi trường Production:** Bắt buộc phải thay đổi mật khẩu
3. **Bảo mật:** Không chia sẻ file này công khai
4. **Reset mật khẩu:** Sử dụng chức năng "Quên mật khẩu" hoặc liên hệ admin

---

## 🔄 Cập Nhật

File này được tạo từ: `SQL/03_SeedData.sql`
Cập nhật lần cuối: Dựa trên seed data hiện tại

---

**📌 Lưu ý:** Nếu bạn cần reset lại tất cả mật khẩu về mặc định, chạy script:
- `SQL/03_ResetDataOnly.sql` - Reset data và seed lại
- `SQL/FixPasswordHashes.sql` - Chỉ cập nhật password hash

