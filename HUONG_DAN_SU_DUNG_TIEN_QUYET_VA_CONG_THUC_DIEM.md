# 📚 HƯỚNG DẪN SỬ DỤNG: TIÊN QUYẾT VÀ CÔNG THỨC ĐIỂM

## 🎯 MỤC LỤC
1. [Chức năng Tiên quyết](#1-chức-năng-tiên-quyết)
2. [Chức năng Công thức điểm](#2-chức-năng-công-thức-điểm)

---

## 1. CHỨC NĂNG TIÊN QUYẾT

### 📍 Truy cập
- **URL:** `/subject-prerequisites`
- **Menu:** Quản lý đào tạo → Tiên quyết
- **Quyền:** 
  - **Xem:** Tất cả người dùng đã đăng nhập
  - **Thêm/Xóa:** Chỉ Admin

### 🎯 Mục đích
Quản lý điều kiện tiên quyết của các môn học, đảm bảo sinh viên chỉ đăng ký được các môn học mà họ đã hoàn thành các môn tiên quyết với điểm số đạt yêu cầu.

### 📋 Các tính năng

#### 1.1. Xem danh sách môn tiên quyết
**Cách sử dụng:**
1. Vào trang **Quản lý Môn tiên quyết**
2. Ở cột bên trái, chọn môn học từ dropdown **"Chọn môn học để xem điều kiện tiên quyết"**
3. Hệ thống sẽ tự động hiển thị danh sách các môn tiên quyết của môn học đó

**Thông tin hiển thị:**
- **Mã môn:** Mã của môn tiên quyết
- **Tên môn:** Tên của môn tiên quyết
- **Điểm tối thiểu:** Điểm tối thiểu cần đạt (0-10)
- **Bắt buộc:** Có bắt buộc hay không
- **Thao tác:** Nút xóa (chỉ Admin)

#### 1.2. Thêm môn tiên quyết (Admin only)
**Cách sử dụng:**
1. Chọn môn học cần thêm điều kiện tiên quyết
2. Click nút **"Thêm điều kiện"** (chỉ hiện khi đã chọn môn học)
3. Điền thông tin trong modal:
   - **Môn học chính:** Tự động điền (không thể sửa)
   - **Môn tiên quyết:** Chọn môn học làm điều kiện tiên quyết
   - **Điểm tối thiểu:** Nhập điểm tối thiểu (0-10), mặc định: 4.0
   - **Bắt buộc:** Checkbox, mặc định: Có
   - **Mô tả:** (Tùy chọn) Ghi chú về điều kiện
4. Click **"Thêm"** để lưu

**Lưu ý:**
- Môn học không thể là tiên quyết của chính nó
- Điểm tối thiểu phải từ 0 đến 10

#### 1.3. Xóa môn tiên quyết (Admin only)
**Cách sử dụng:**
1. Tìm môn tiên quyết cần xóa trong danh sách
2. Click nút **Xóa** (icon thùng rác) ở cột "Thao tác"
3. Xác nhận xóa trong hộp thoại

#### 1.4. Kiểm tra điều kiện đăng ký
**Cách sử dụng:**
1. Ở cột bên phải, nhập:
   - **Mã sinh viên:** Mã sinh viên cần kiểm tra
   - **Môn học:** Chọn môn học muốn đăng ký
2. Click nút **"Kiểm tra"**
3. Xem kết quả:
   - ✅ **Đủ điều kiện:** Hiển thị thông báo màu xanh
   - ❌ **Thiếu điều kiện:** Hiển thị danh sách các môn còn thiếu kèm lý do

**Kết quả kiểm tra hiển thị:**
- Trạng thái: Đủ điều kiện / Thiếu điều kiện
- Danh sách môn còn thiếu (nếu có):
  - Mã môn và tên môn
  - Lý do thiếu (chưa học, điểm chưa đạt, v.v.)
  - Điểm tối thiểu yêu cầu

### 🔍 Ví dụ sử dụng

**Ví dụ 1: Thêm tiên quyết cho môn "Lập trình nâng cao"**
1. Chọn môn học: **"CS301 - Lập trình nâng cao"**
2. Click **"Thêm điều kiện"**
3. Chọn môn tiên quyết: **"CS101 - Lập trình cơ bản"**
4. Điểm tối thiểu: **4.0**
5. Đánh dấu **"Bắt buộc"**
6. Click **"Thêm"**

**Ví dụ 2: Kiểm tra sinh viên có đủ điều kiện đăng ký không**
1. Nhập mã sinh viên: **"SV001"**
2. Chọn môn học: **"CS301 - Lập trình nâng cao"**
3. Click **"Kiểm tra"**
4. Nếu thiếu, hệ thống sẽ liệt kê:
   - CS101 - Lập trình cơ bản (Chưa đạt điểm tối thiểu 4.0)

---

## 2. CHỨC NĂNG CÔNG THỨC ĐIỂM

### 📍 Truy cập
- **URL Admin/Advisor:** `/grade-formula` hoặc `/advisor/grade-formula`
- **URL Lecturer:** `/lecturer/grade-formula`
- **Menu:** 
  - Admin: Quản lý đào tạo → Công thức điểm
  - Advisor: Công thức điểm
  - Lecturer: Công thức điểm
- **Quyền:**
  - **Xem:** Tất cả người dùng đã đăng nhập
  - **Tạo/Sửa/Xóa:** Admin, Advisor

### 🎯 Mục đích
Thiết lập công thức tính điểm tổng kết cho các môn học/lớp học. Hệ thống sẽ tự động tính điểm khi giảng viên nhập điểm thành phần.

### 📋 Các thành phần điểm
1. **Giữa kỳ (Midterm):** Điểm thi giữa kỳ
2. **Cuối kỳ (Final):** Điểm thi cuối kỳ
3. **Bài tập (Assignment):** Điểm bài tập về nhà
4. **Kiểm tra (Quiz):** Điểm kiểm tra ngắn
5. **Đồ án (Project):** Điểm đồ án/dự án

### 🎯 Phạm vi áp dụng (Scope)
Hệ thống áp dụng công thức theo thứ tự ưu tiên:
1. **Lớp học** (Class) - Ưu tiên cao nhất
2. **Môn học** (Subject)
3. **Năm học** (School Year)
4. **Mặc định** (Default) - Ưu tiên thấp nhất

**Ví dụ:** Nếu có công thức cho lớp "SE101-24-HK1" và công thức cho môn "SE101", thì lớp sẽ dùng công thức của lớp, không dùng công thức của môn.

### 📋 Các tính năng

#### 2.1. Xem danh sách cấu hình
**Cách sử dụng:**
1. Vào trang **Cấu hình công thức tính điểm**
2. Sử dụng bộ lọc (nếu cần):
   - **Môn học:** Lọc theo môn học
   - **Lớp:** Lọc theo lớp
   - **Năm học:** Lọc theo năm học
   - **Loại:** Mặc định / Cụ thể
3. Xem danh sách cấu hình với thông tin:
   - **Phạm vi:** Lớp/Môn/Năm học/Mặc định
   - **Trọng số:** % của từng thành phần điểm
   - **Làm tròn:** Phương pháp và số chữ số thập phân
   - **Mặc định:** Có/Không
   - **Ngày tạo**
   - **Thao tác:** Sửa / Xóa

#### 2.2. Tạo cấu hình mới
**Cách sử dụng:**
1. Click nút **"Tạo cấu hình mới"**
2. Điền thông tin qua 4 bước:

**Bước 1: Chọn phạm vi áp dụng**
- Chọn ít nhất một trong các tùy chọn:
  - **Lớp học:** Chọn lớp cụ thể
  - **Môn học:** Chọn môn học
  - **Năm học:** Chọn năm học
  - **Mặc định:** Đánh dấu nếu là công thức mặc định
- Click **"Tiếp theo"**

**Bước 2: Thiết lập trọng số**
- Nhập trọng số (0.00 - 1.00) cho các thành phần:
  - **Giữa kỳ:** Ví dụ: 0.30 (30%)
  - **Cuối kỳ:** Ví dụ: 0.70 (70%)
  - **Bài tập:** Ví dụ: 0.00 (0%)
  - **Kiểm tra:** Ví dụ: 0.00 (0%)
  - **Đồ án:** Ví dụ: 0.00 (0%)
- **Lưu ý:** Tổng trọng số không được vượt quá 1.0 (100%)
- Có thể dùng template:
  - **Chuẩn:** Giữa kỳ 30% + Cuối kỳ 70%
  - **Cân bằng:** Giữa kỳ 40% + Cuối kỳ 60%
  - **Thực hành:** Giữa kỳ 20% + Cuối kỳ 30% + Bài tập 30% + Đồ án 20%
- Xem **"Tổng trọng số"** và **"Ví dụ tính điểm"** để kiểm tra
- Click **"Tiếp theo"**

**Bước 3: Tùy chọn nâng cao**
- **Công thức tùy chỉnh:** (Tùy chọn) Nhập công thức tùy chỉnh dạng text
  - Ví dụ: `midterm*0.3 + final*0.7 + assignment*0.1`
- **Phương pháp làm tròn:**
  - **STANDARD:** Làm tròn chuẩn (0.5 → 1)
  - **CEILING:** Làm tròn lên (0.1 → 1)
  - **FLOOR:** Làm tròn xuống (0.9 → 0)
  - **NONE:** Không làm tròn
- **Số chữ số thập phân:** 0-4 (mặc định: 2)
- **Mô tả:** (Tùy chọn) Ghi chú về công thức
- Click **"Tiếp theo"**

**Bước 4: Xem lại và xác nhận**
- Xem lại tất cả thông tin
- Xem **"Công thức tổng kết"** (ví dụ: "Điểm cuối kỳ = (Giữa kỳ × 30%) + (Cuối kỳ × 70%)")
- Xem **"Ví dụ tính điểm"** với điểm mẫu
- Click **"Lưu cấu hình"** để hoàn tất

#### 2.3. Sửa cấu hình
**Cách sử dụng:**
1. Tìm cấu hình cần sửa trong danh sách
2. Click nút **"Sửa"** (icon bút chì)
3. Chỉnh sửa thông tin qua 4 bước (tương tự như tạo mới)
4. Click **"Lưu cấu hình"**

#### 2.4. Xóa cấu hình
**Cách sử dụng:**
1. Tìm cấu hình cần xóa
2. Click nút **"Xóa"** (icon thùng rác)
3. Xác nhận xóa trong hộp thoại

### 🔍 Ví dụ sử dụng

**Ví dụ 1: Tạo công thức mặc định**
1. Click **"Tạo cấu hình mới"**
2. Bước 1: Đánh dấu **"Mặc định"**, click **"Tiếp theo"**
3. Bước 2: 
   - Chọn template **"Chuẩn"** (Giữa kỳ 30% + Cuối kỳ 70%)
   - Click **"Tiếp theo"**
4. Bước 3: 
   - Phương pháp làm tròn: **STANDARD**
   - Số chữ số: **2**
   - Click **"Tiếp theo"**
5. Bước 4: Xem lại và click **"Lưu cấu hình"**

**Ví dụ 2: Tạo công thức cho môn học cụ thể**
1. Click **"Tạo cấu hình mới"**
2. Bước 1: Chọn môn học **"SE101 - Lập trình cơ bản"**, click **"Tiếp theo"**
3. Bước 2:
   - Giữa kỳ: **0.20** (20%)
   - Cuối kỳ: **0.50** (50%)
   - Bài tập: **0.20** (20%)
   - Kiểm tra: **0.10** (10%)
   - Tổng: **1.00** (100%)
   - Click **"Tiếp theo"**
4. Bước 3: Giữ nguyên mặc định, click **"Tiếp theo"**
5. Bước 4: Click **"Lưu cấu hình"**

**Ví dụ 3: Tạo công thức cho lớp học cụ thể**
1. Click **"Tạo cấu hình mới"**
2. Bước 1: Chọn lớp **"SE101-24-HK1"**, click **"Tiếp theo"**
3. Bước 2:
   - Chọn template **"Thực hành"** (tự động điền)
   - Click **"Tiếp theo"**
4. Bước 3:
   - Phương pháp làm tròn: **CEILING** (làm tròn lên)
   - Số chữ số: **1**
   - Mô tả: **"Công thức cho lớp thực hành SE101"**
   - Click **"Tiếp theo"**
5. Bước 4: Click **"Lưu cấu hình"**

### 📊 Công thức tính điểm

**Công thức chuẩn:**
```
Điểm tổng kết = (Giữa kỳ × Trọng số GK) + 
                (Cuối kỳ × Trọng số CK) + 
                (Bài tập × Trọng số BT) + 
                (Kiểm tra × Trọng số KT) + 
                (Đồ án × Trọng số DA)
```

**Ví dụ tính điểm:**
- Giữa kỳ: 8.0 (trọng số 30%)
- Cuối kỳ: 9.0 (trọng số 70%)
- **Điểm tổng kết = 8.0 × 0.30 + 9.0 × 0.70 = 2.4 + 6.3 = 8.7**

### ⚠️ Lưu ý quan trọng

1. **Tổng trọng số:**
   - Phải ≤ 1.0 (100%)
   - Có thể < 1.0 (ví dụ: 0.9 = 90%), nhưng không được > 1.0

2. **Phạm vi áp dụng:**
   - Công thức cụ thể (lớp/môn) sẽ ghi đè công thức chung (năm học/mặc định)
   - Nên tạo công thức mặc định trước, sau đó tạo công thức cụ thể khi cần

3. **Làm tròn:**
   - **STANDARD:** Làm tròn chuẩn (0.5 → 1, 0.4 → 0)
   - **CEILING:** Luôn làm tròn lên (0.1 → 1, 0.9 → 1)
   - **FLOOR:** Luôn làm tròn xuống (0.9 → 0, 0.1 → 0)
   - **NONE:** Giữ nguyên số thập phân

4. **Công thức tùy chỉnh:**
   - Chỉ sử dụng khi cần công thức phức tạp
   - Định dạng: `midterm*0.3 + final*0.7 + assignment*0.1`
   - Nếu có công thức tùy chỉnh, hệ thống sẽ ưu tiên dùng công thức này thay vì trọng số

5. **Xóa cấu hình:**
   - Khi xóa cấu hình, hệ thống sẽ tự động dùng cấu hình có phạm vi rộng hơn
   - Ví dụ: Xóa công thức của lớp → Dùng công thức của môn → Dùng công thức mặc định

---

## 🔗 API Endpoints (Tham khảo)

### Tiên quyết
- `GET /api-edu/subject-prerequisites/by-subject/{subjectId}` - Lấy danh sách tiên quyết
- `GET /api-edu/subject-prerequisites/check?studentId={id}&subjectId={id}` - Kiểm tra điều kiện
- `POST /api-edu/subject-prerequisites` - Thêm tiên quyết (Admin)
- `DELETE /api-edu/subject-prerequisites/{prerequisiteId}` - Xóa tiên quyết (Admin)

### Công thức điểm
- `GET /api-edu/grade-formula-configs` - Lấy danh sách cấu hình
- `GET /api-edu/grade-formula-configs/{id}` - Lấy cấu hình theo ID
- `GET /api-edu/grade-formula-configs/resolve?classId={id}&subjectId={id}&schoolYearId={id}` - Lấy cấu hình theo phạm vi
- `POST /api-edu/grade-formula-configs` - Tạo cấu hình mới
- `PUT /api-edu/grade-formula-configs/{id}` - Cập nhật cấu hình
- `DELETE /api-edu/grade-formula-configs/{id}` - Xóa cấu hình

---

## 📞 Hỗ trợ

Nếu gặp vấn đề hoặc cần hỗ trợ, vui lòng liên hệ:
- **Email:** support@educationmanagement.com
- **Hotline:** 1900-xxxx

---

**Cập nhật lần cuối:** 2024-12-XX

