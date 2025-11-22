# 📊 Dữ Liệu Điểm Học Sinh - Seed Data

Tài liệu này mô tả chi tiết dữ liệu điểm của từng học sinh có trong seed data (`03_SeedData_FullTest.sql`).

**Cập nhật:** Tự động tạo từ seed data  
**Nguồn:** `SQL/03_SeedData_FullTest.sql`

---

## 📋 Mục Lục

1. [Tổng Quan](#tổng-quan)
2. [Danh Sách Học Sinh](#danh-sách-học-sinh)
3. [Chi Tiết Điểm Theo Học Sinh](#chi-tiết-điểm-theo-học-sinh)
4. [Thống Kê](#thống-kê)

---

## 📊 Tổng Quan

### Thông Tin Tổng Quan

- **Tổng số học sinh:** 6
- **Tổng số enrollments:** 13
- **Tổng số grades:** 12
- **Năm học:** SY2024 (2024-2025)
- **Học kỳ:** HK1 và HK2

### Phân Bố Điểm

| Letter Grade | Số Lượng | Tỷ Lệ |
|--------------|----------|-------|
| A (8.0 - 10.0) | 5 | 41.7% |
| B (6.5 - 7.9) | 3 | 25.0% |
| C (5.0 - 6.4) | 1 | 8.3% |
| D (4.0 - 4.9) | 2 | 16.7% |
| F (< 4.0) | 2 | 16.7% |

---

## 👥 Danh Sách Học Sinh

| Student ID | Mã SV | Họ Tên | Khóa | Ngành | Email |
|------------|-------|--------|------|-------|-------|
| STU_K21_001 | K21SE001 | Trần Nhật Minh | 2021 | Software Engineering | st.k21.001@example.com |
| STU_K21_002 | K21SE002 | Ngô Diệu Anh | 2021 | Software Engineering | st.k21.002@example.com |
| STU_K22_001 | K22SE010 | Phạm Hữu Long | 2022 | Software Engineering | st.k22.010@example.com |
| STU_K23_001 | K23DS005 | Lưu Gia Khánh | 2023 | Data Science | st.k23.005@example.com |
| STU_K24_001 | K24SE015 | Đỗ Quỳnh Nhi | 2024 | Software Engineering | st.k24.015@example.com |
| STU_K24_002 | K24MKT099 | Lê Minh Triết | 2024 | Marketing | st.k24.099@example.com |

---

## 📚 Chi Tiết Điểm Theo Học Sinh

### 1. STU_K21_001 - Trần Nhật Minh (K21SE001)

**Thông tin:**
- Khóa: 2021 (Năm 4)
- Ngành: Software Engineering
- Email: st.k21.001@example.com

**Điểm số:**

| Grade ID | Enrollment ID | Môn Học | Lớp | Học Kỳ | Giữa Kỳ | Cuối Kỳ | Tổng Kết | Điểm Chữ |
|----------|---------------|---------|-----|--------|---------|---------|----------|----------|
| GRD_FT_004 | ENR_FT_005 | Đồ án web nâng cao | CLS_SE301_2024 | HK2 | 6.5 | 6.0 | **6.2** | **C** |

**GPA:**
- **GPA HK2 SY2024:** 7.2 (thang 10) / 2.9 (thang 4)
- **Tổng tín chỉ:** 12
- **Tích lũy tín chỉ:** 120
- **Xếp loại:** Trung bình

**Ghi chú:**
- Có phúc khảo điểm (APL_FT_004, APL_FT_007) - đã được duyệt, điểm điều chỉnh từ 6.2 → 7.0

---

### 2. STU_K21_002 - Ngô Diệu Anh (K21SE002)

**Thông tin:**
- Khóa: 2021 (Năm 4)
- Ngành: Software Engineering
- Email: st.k21.002@example.com

**Điểm số:**
- ❌ **Chưa có điểm** - Enrollment đã bị hủy (DROPPED) do vắng mặt quá 30%

**Enrollments:**
- ENR_FT_006: CLS_SE301_2024 (Đã hủy - DROPPED)

---

### 3. STU_K22_001 - Phạm Hữu Long (K22SE010)

**Thông tin:**
- Khóa: 2022 (Năm 3)
- Ngành: Software Engineering
- Email: st.k22.010@example.com

**Điểm số:**
- ❌ **Chưa có điểm** - Enrollment đã rút (WITHDRAWN)

**Enrollments:**
- ENR_FT_007: CLS_BUS201_2024 (Đã rút - WITHDRAWN)

**Enrollments khác:**
- ENR_FT_009: CLS_SE201_2024 - **Điểm:** 4.6 (D) - Giữa kỳ: 4.0, Cuối kỳ: 5.0

---

### 4. STU_K23_001 - Lưu Gia Khánh (K23DS005)

**Thông tin:**
- Khóa: 2023 (Năm 2)
- Ngành: Data Science
- Email: st.k23.005@example.com

**Điểm số:**

| Grade ID | Enrollment ID | Môn Học | Lớp | Học Kỳ | Giữa Kỳ | Cuối Kỳ | Tổng Kết | Điểm Chữ |
|----------|---------------|---------|-----|--------|---------|---------|----------|----------|
| GRD_FT_003 | ENR_FT_004 | Phân tích thiết kế hệ thống | CLS_SE201_2024 | HK1 | 8.0 | 8.0 | **8.0** | **A** |

**GPA:**
- **GPA HK1 SY2024:** 8.0 (thang 10) / 3.2 (thang 4)
- **Tổng tín chỉ:** 14
- **Tích lũy tín chỉ:** 60
- **Xếp loại:** Khá

**Ghi chú:**
- Có phúc khảo điểm (APL_FT_003, APL_FT_006) - đã bị từ chối

**Enrollments khác:**
- ENR_FT_010: CLS_DS101_2024 - **Điểm:** 3.7 (F) - Giữa kỳ: 3.5, Cuối kỳ: 3.8
- ENR_FT_013: CLS_SE101_2024 - **Điểm:** 7.8 (B) - Giữa kỳ: 7.5, Cuối kỳ: 8.0

---

### 5. STU_K24_001 - Đỗ Quỳnh Nhi (K24SE015)

**Thông tin:**
- Khóa: 2024 (Năm 1)
- Ngành: Software Engineering
- Email: st.k24.015@example.com

**Điểm số:**

| Grade ID | Enrollment ID | Môn Học | Lớp | Học Kỳ | Giữa Kỳ | Cuối Kỳ | Tổng Kết | Điểm Chữ |
|----------|---------------|---------|-----|--------|---------|---------|----------|----------|
| GRD_FT_001 | ENR_FT_001 | Lập trình .NET cơ bản | CLS_SE101_2024 | HK1 | 8.5 | 9.0 | **8.8** | **A** |
| GRD_FT_002 | ENR_FT_002 | Nhập môn Khoa học Dữ liệu | CLS_DS101_2024 | HK1 | 7.0 | 7.5 | **7.3** | **B** |
| GRD_FT_005 | ENR_FT_002 | Nhập môn Khoa học Dữ liệu | CLS_DS101_2024 | HK1 | 7.0 | 7.5 | **7.3** | **B** |
| GRD_FT_006 | ENR_FT_001 | Lập trình .NET cơ bản | CLS_SE101_2024 | HK1 | 8.5 | 9.0 | **8.8** | **A** |

**GPA:**
- **GPA HK1 SY2024:** 8.4 (thang 10) / 3.4 (thang 4)
- **Tổng tín chỉ:** 15
- **Tích lũy tín chỉ:** 15
- **Xếp loại:** Giỏi

**Ghi chú:**
- Có phúc khảo điểm (APL_FT_001, APL_FT_002, APL_FT_005)
- Có enrollment thêm: ENR_FT_012 (CLS_SE201_2024) - **Điểm:** 8.3 (A)

---

### 6. STU_K24_002 - Lê Minh Triết (K24MKT099)

**Thông tin:**
- Khóa: 2024 (Năm 1)
- Ngành: Marketing
- Email: st.k24.099@example.com

**Điểm số:**
- ❌ **Chưa có điểm** - Enrollment đang chờ duyệt (PENDING)

**Enrollments:**
- ENR_FT_003: CLS_SE101_2024 (Chờ duyệt - PENDING)

---

## 📈 Thống Kê

### Thống Kê Theo Học Sinh

| Học Sinh | Số Môn Có Điểm | Điểm TB | Điểm Cao Nhất | Điểm Thấp Nhất | Xếp Loại |
|----------|----------------|---------|---------------|----------------|-----------|
| STU_K24_001 | 2 | 8.05 | 8.8 (A) | 7.3 (B) | Giỏi |
| STU_K23_001 | 1 | 8.0 | 8.0 (A) | 8.0 (A) | Khá |
| STU_K21_001 | 1 | 6.2 | 6.2 (C) | 6.2 (C) | Trung bình |
| STU_K22_001 | 1 | 4.6 | 4.6 (D) | 4.6 (D) | Yếu |

### Thống Kê Theo Môn Học

| Môn Học | Mã Môn | Số SV Có Điểm | Điểm TB | Điểm Cao Nhất | Điểm Thấp Nhất |
|---------|--------|---------------|---------|---------------|----------------|
| Lập trình .NET cơ bản | SE101 | 2 | 8.8 | 8.8 (A) | 8.8 (A) |
| Nhập môn Khoa học Dữ liệu | DS101 | 1 | 7.3 | 7.3 (B) | 7.3 (B) |
| Phân tích thiết kế hệ thống | SE201 | 2 | 8.15 | 8.3 (A) | 8.0 (A) |
| Đồ án web nâng cao | SE301 | 1 | 6.2 | 6.2 (C) | 6.2 (C) |

### Thống Kê Theo Học Kỳ

| Học Kỳ | Số Môn Có Điểm | Điểm TB | Số SV Có Điểm |
|--------|----------------|---------|---------------|
| HK1 | 8 | 7.6 | 4 |
| HK2 | 1 | 6.2 | 1 |

---

## 🔍 Chi Tiết Enrollments

### Enrollments Có Điểm

| Enrollment ID | Student ID | Mã SV | Lớp | Môn Học | Trạng Thái | Grade ID | Điểm |
|---------------|------------|-------|-----|---------|------------|----------|------|
| ENR_FT_001 | STU_K24_001 | K24SE015 | CLS_SE101_2024 | SE101 | Đang học | GRD_FT_001, GRD_FT_006 | 8.8 (A) |
| ENR_FT_002 | STU_K24_001 | K24SE015 | CLS_DS101_2024 | DS101 | Đang học | GRD_FT_002, GRD_FT_005 | 7.3 (B) |
| ENR_FT_004 | STU_K23_001 | K23DS005 | CLS_SE201_2024 | SE201 | Đang học | GRD_FT_003 | 8.0 (A) |
| ENR_FT_005 | STU_K21_001 | K21SE001 | CLS_SE301_2024 | SE301 | Đang học | GRD_FT_004 | 6.2 (C) |
| ENR_FT_008 | STU_K21_003 | - | CLS_SE101_2024 | SE101 | Đang học | GRD_FT_007 | 4.7 (D) |
| ENR_FT_009 | STU_K22_002 | - | CLS_SE201_2024 | SE201 | Đang học | GRD_FT_008 | 4.6 (D) |
| ENR_FT_010 | STU_K23_002 | - | CLS_DS101_2024 | DS101 | Đang học | GRD_FT_009 | 3.7 (F) |
| ENR_FT_011 | STU_K24_003 | - | CLS_SE101_2024 | SE101 | Đang học | GRD_FT_010 | 3.3 (F) |
| ENR_FT_012 | STU_K24_001 | K24SE015 | CLS_SE201_2024 | SE201 | Đang học | GRD_FT_011 | 8.3 (A) |
| ENR_FT_013 | STU_K23_001 | K23DS005 | CLS_SE101_2024 | SE101 | Đang học | GRD_FT_012 | 7.8 (B) |

### Enrollments Chưa Có Điểm

| Enrollment ID | Student ID | Mã SV | Lớp | Môn Học | Trạng Thái | Ghi Chú |
|---------------|------------|-------|-----|---------|------------|---------|
| ENR_FT_003 | STU_K24_002 | K24MKT099 | CLS_SE101_2024 | SE101 | Chờ duyệt | PENDING |
| ENR_FT_006 | STU_K21_002 | K21SE002 | CLS_SE301_2024 | SE301 | Đã hủy | DROPPED - Vắng mặt >30% |
| ENR_FT_007 | STU_K22_001 | K22SE010 | CLS_BUS201_2024 | BUS201 | Đã rút | WITHDRAWN |

---

## 📝 Ghi Chú

### Phúc Khảo Điểm

1. **APL_FT_001** (STU_K24_001 - SE101): PENDING - Điểm hiện tại: 8.8, Mong muốn: 9.5
2. **APL_FT_002** (STU_K24_001 - DS101): REVIEWING - Điểm hiện tại: 7.3, Mong muốn: 7.8
3. **APL_FT_003** (STU_K23_001 - SE201): REVIEWING - Điểm hiện tại: 8.0, Mong muốn: 9.0
4. **APL_FT_004** (STU_K21_001 - SE301): REVIEWING - Điểm hiện tại: 6.2, Mong muốn: 7.0
5. **APL_FT_005** (STU_K24_001 - DS101): APPROVED - Đã duyệt, điểm điều chỉnh: 7.8
6. **APL_FT_006** (STU_K23_001 - SE201): REJECTED - Đã từ chối
7. **APL_FT_007** (STU_K21_001 - SE301): APPROVED - Đã duyệt, điểm điều chỉnh: 7.0

### Lưu Ý

- Một số enrollments có nhiều grade records (ví dụ: ENR_FT_001 có GRD_FT_001 và GRD_FT_006) - đây là dữ liệu test
- Một số học sinh có enrollments nhưng chưa có điểm (PENDING, DROPPED, WITHDRAWN)
- Dữ liệu này được tạo để test đầy đủ các tính năng của hệ thống

---

## 🔗 Tham Khảo

- **File Seed Data:** `SQL/03_SeedData_FullTest.sql`
- **Stored Procedure:** `sp_GetGradesByStudentSchoolYear`
- **Bảng dữ liệu:** `grades`, `enrollments`, `students`, `classes`, `subjects`

---

**Cập nhật lần cuối:** Tự động tạo từ seed data

