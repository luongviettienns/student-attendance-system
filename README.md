# 🎓 Hệ Thống Quản Lý Đào Tạo & Điểm Danh Sinh Viên

[![.NET](https://img.shields.io/badge/.NET-8.0-512BD4?logo=dotnet)](https://dotnet.microsoft.com/)
[![AngularJS](https://img.shields.io/badge/AngularJS-1.x-E23237?logo=angular)](https://angularjs.org/)
[![SQL Server](https://img.shields.io/badge/SQL%20Server-2019+-CC2927?logo=microsoft-sql-server)](https://www.microsoft.com/sql-server)

> Hệ thống quản lý toàn diện cho việc quản lý đào tạo, điểm danh, điểm số và cảnh báo chuyên cần cho sinh viên trong môi trường giáo dục đại học.

---

## 📋 Mục Lục

- [Tổng Quan](#-tổng-quan)
- [Tính Năng Chính](#-tính-năng-chính)
- [Công Nghệ Sử Dụng](#-công-nghệ-sử-dụng)
- [Cấu Trúc Dự Án](#-cấu-trúc-dự-án)
- [Cài Đặt](#-cài-đặt)
- [Sử Dụng](#-sử-dụng)
- [Vai Trò Người Dùng](#-vai-trò-người-dùng)
- [API Documentation](#-api-documentation)
- [Database Schema](#-database-schema)
- [Đóng Góp](#-đóng-góp)

---

## 🎯 Tổng Quan

Hệ thống Quản lý Đào Tạo & Điểm Danh Sinh Viên là một giải pháp quản lý toàn diện được thiết kế để hỗ trợ các trường đại học trong việc:

- **Quản lý đào tạo:** Danh mục môn học, lớp học, niên khóa, đăng ký học phần
- **Quản lý lịch học/thi:** Tạo và quản lý lịch học, lịch thi cho từng lớp
- **Điểm danh:** Điểm danh theo buổi học với hỗ trợ web và mobile
- **Quản lý điểm số:** Nhập điểm thành phần, cấu hình công thức tính điểm
- **Cảnh báo tự động:** Cảnh báo vắng học, GPA thấp, gửi email thông báo
- **Phúc khảo:** Workflow duyệt phúc khảo điểm từ sinh viên → giảng viên → cố vấn
- **Báo cáo:** Phân phối điểm, tỷ lệ qua môn, chuyên cần

---

## ✨ Tính Năng Chính

### 👥 Quản Lý Người Dùng & Phân Quyền
- ✅ 4 vai trò: **Admin**, **Giảng viên**, **Cố vấn**, **Sinh viên**
- ✅ Hệ thống phân quyền chi tiết dựa trên `role_permissions`
- ✅ JWT Authentication & Authorization
- ✅ Audit log đầy đủ cho mọi thao tác quan trọng

### 📚 Quản Lý Đào Tạo
- ✅ **Danh mục môn học:** Quản lý môn học, tín chỉ, điều kiện tiên quyết
- ✅ **Lớp học phần:** Tạo và quản lý lớp học phần, số lượng đăng ký
- ✅ **Lớp hành chính:** Quản lý lớp hành chính theo niên khóa
- ✅ **Niên khóa & Năm học:** Quản lý niên khóa (4 năm) và năm học (2 học kỳ)
- ✅ **Đăng ký học phần:** Workflow đăng ký với đợt đăng ký, duyệt/từ chối

### 📅 Lịch Học & Lịch Thi
- ✅ **Lịch học:** Tạo lịch học theo tuần, phòng, giảng viên
- ✅ **Lịch thi:** Quản lý lịch thi giữa kỳ và cuối kỳ
- ✅ **Phân ca thi:** Tự động phân ca thi cho sinh viên
- ✅ **Xung đột lịch:** Kiểm tra xung đột phòng và giảng viên

### ✅ Điểm Danh
- ✅ **Điểm danh theo buổi:** Present, Absent, Late, Excused
- ✅ **Hỗ trợ Web & Mobile:** API sẵn sàng cho mobile app
- ✅ **Lịch sử điểm danh:** Xem lịch sử điểm danh của sinh viên
- ✅ **Thống kê chuyên cần:** Tỷ lệ vắng mặt, cảnh báo tự động

### 💯 Quản Lý Điểm Số
- ✅ **Nhập điểm thành phần:**
  - Điểm giữa kỳ (Midterm)
  - Điểm cuối kỳ (Final)
  - Điểm chuyên cần (Attendance)
  - Điểm bài tập (Assignment)
- ✅ **Công thức tính điểm cấu hình:**
  - Cấu hình trọng số cho từng loại điểm
  - Công thức tùy chỉnh
  - Làm tròn điểm (STANDARD, CEILING, FLOOR, NONE)
  - Áp dụng theo môn học, lớp, hoặc năm học
- ✅ **Tính GPA:** GPA hệ 10 và hệ 4, GPA tích lũy
- ✅ **Bảng điểm cá nhân:** Sinh viên xem bảng điểm theo học kỳ/năm học

### ⚠️ Cảnh Báo & Học Lại
- ✅ **Cảnh báo tự động:**
  - Cảnh báo vắng > x% (có thể cấu hình)
  - Cảnh báo GPA < ngưỡng
  - Gửi email thông báo tự động
- ✅ **Học lại:**
  - Tự động tạo bản ghi học lại khi vắng > ngưỡng hoặc điểm < 4.0
  - Đăng ký học lại
  - Duyệt học lại (Cố vấn)

### 📝 Phúc Khảo Điểm
- ✅ **Workflow duyệt:**
  1. Sinh viên tạo yêu cầu phúc khảo
  2. Giảng viên xem và phản hồi
  3. Cố vấn duyệt cuối cùng (nếu cần)
  4. Cập nhật điểm sau phúc khảo
- ✅ **Tài liệu đính kèm:** Hỗ trợ đính kèm tài liệu

### 📊 Báo Cáo & Thống Kê
- ✅ **Báo cáo Admin:**
  - Phân phối GPA
  - Tỷ lệ qua môn
  - Thống kê tín chỉ nợ
  - Top sinh viên nợ tín chỉ
- ✅ **Báo cáo Giảng viên:**
  - Thống kê điểm danh lớp chủ nhiệm
  - Phân bố GPA
  - Sinh viên điểm danh thấp
- ✅ **Báo cáo Sinh viên:**
  - Tổng quan học tập
  - Xu hướng GPA theo học kỳ
  - Phân bố điểm số
  - Tín chỉ còn nợ
- ✅ **Báo cáo Cố vấn:**
  - Dashboard thống kê toàn trường
  - Sinh viên cảnh báo
  - Tỷ lệ chuyên cần trung bình

### 📧 Thông Báo & Email
- ✅ **Thông báo trong hệ thống:** Real-time notifications
- ✅ **Email tự động:**
  - Cảnh báo vắng học
  - Cảnh báo GPA thấp
  - Thông báo điểm mới
  - Gửi email hàng loạt

### 📥 Import/Export
- ✅ **Import Excel:** Import danh sách sinh viên từ Excel
- ✅ **Validation:** Kiểm tra dữ liệu trước khi import
- ✅ **Error handling:** Báo lỗi chi tiết cho từng dòng

---

## 🛠 Công Nghệ Sử Dụng

### Backend
- **.NET 8.0** - Framework chính
- **ASP.NET Core Web API** - RESTful API
- **JWT Bearer Authentication** - Xác thực và phân quyền
- **BCrypt.Net** - Mã hóa mật khẩu
- **SignalR** - Real-time notifications
- **StackExchange.Redis** - Caching (tùy chọn)

### Frontend
- **AngularJS 1.x** - Framework frontend
- **Custom CSS** - UI framework tự viết (không dùng Bootstrap)
- **Chart.js** - Biểu đồ
- **XLSX.js** - Đọc file Excel
- **SignalR Client** - Real-time communication
- **Font Awesome** - Icons
- **Google Fonts (Inter)** - Typography

### Database
- **SQL Server 2019+** - Database chính
- **Stored Procedures** - Business logic
- **Table-Valued Parameters** - Batch operations

### Tools & Libraries
- **Swagger/OpenAPI** - API documentation
- **Git** - Version control

---

## 📁 Cấu Trúc Dự Án

```
student-attendance-system/
├── AdminFrontend/              # Frontend AngularJS
│   ├── controllers/           # AngularJS Controllers
│   ├── services/              # AngularJS Services
│   ├── views/                 # HTML Views
│   ├── css/                   # Stylesheets
│   ├── js/                    # JavaScript libraries
│   └── index.html             # Entry point
│
├── EducationManagement/        # Backend .NET
│   ├── EducationManagement.API.Admin/    # API Controllers
│   ├── EducationManagement.API.Gateway/  # API Gateway
│   ├── EducationManagement.BLL/          # Business Logic Layer
│   ├── EducationManagement.DAL/          # Data Access Layer
│   ├── EducationManagement.Common/       # Shared Models & DTOs
│   └── EducationManagement.sln           # Solution file
│
├── SQL/                       # Database Scripts
│   ├── 01_CreateTables.sql    # Tạo bảng
│   ├── 02_SP_*.sql            # Stored Procedures
│   ├── 03_SeedData_FullTest.sql  # Seed data
│   ├── 04_Indexes.sql         # Indexes
│   ├── 05_Views.sql           # Views
│   └── ACCOUNT_CREDENTIALS.md  # Tài khoản mặc định
│
├── ĐÁNH_GIÁ_HỆ_THỐNG.md      # Đánh giá hệ thống
└── README.md                  # File này
```

---

## 🚀 Cài Đặt

### Yêu Cầu Hệ Thống

- **.NET SDK 8.0** hoặc cao hơn
- **SQL Server 2019** hoặc cao hơn
- **Node.js** (cho frontend, nếu cần build)
- **Visual Studio 2022** hoặc **VS Code** (khuyến nghị)

### Bước 1: Clone Repository

```bash
git clone https://github.com/your-username/student-attendance-system.git
cd student-attendance-system
```

### Bước 2: Cấu Hình Database

1. Mở SQL Server Management Studio (SSMS)
2. Chạy các script SQL theo thứ tự:
   ```sql
   -- 1. Tạo database và bảng
   SQL/01_CreateTables.sql
   
   -- 2. Tạo stored procedures
   SQL/02_SP_Academic_Operations.sql
   SQL/02_SP_Advisor.sql
   SQL/02_SP_Curriculum.sql
   SQL/02_SP_Grade_Appeals_And_Formula.sql
   SQL/02_SP_Notifications.sql
   SQL/02_SP_Organization_And_Academic.sql
   SQL/02_SP_People.sql
   SQL/02_SP_Rooms.sql
   SQL/02_SP_Scheduling.sql
   SQL/02_SP_Users_And_System.sql
   SQL/06_ExamSchedules.sql
   SQL/07_SP_ExamSchedules.sql
   SQL/08_RetakeRegistration.sql
   
   -- 3. Tạo indexes và views
   SQL/04_Indexes.sql
   SQL/05_Views.sql
   
   -- 4. Seed data (tùy chọn)
   SQL/03_SeedData_FullTest.sql
   ```

### Bước 3: Cấu Hình Backend

1. Mở file `EducationManagement/EducationManagement.API.Admin/appsettings.json`
2. Cấu hình connection string:
   ```json
   {
     "ConnectionStrings": {
       "DefaultConnection": "Server=localhost;Database=EducationManagement;User Id=sa;Password=YourPassword;TrustServerCertificate=True;"
     },
     "Jwt": {
       "SecretKey": "YourSecretKeyHere",
       "Issuer": "EducationManagement",
       "Audience": "EducationManagement",
       "ExpirationMinutes": 60
     },
     "Email": {
       "SmtpServer": "smtp.gmail.com",
       "SmtpPort": 587,
       "SmtpUsername": "your-email@gmail.com",
       "SmtpPassword": "your-app-password",
       "FromEmail": "your-email@gmail.com",
       "FromName": "Hệ Thống Quản Lý Đào Tạo"
     }
   }
   ```

### Bước 4: Chạy Backend

```bash
cd EducationManagement/EducationManagement.API.Admin
dotnet restore
dotnet build
dotnet run
```

Backend sẽ chạy tại: `https://localhost:5001` hoặc `http://localhost:5000`

### Bước 5: Cấu Hình Frontend

1. Mở file `AdminFrontend/services/ApiService.js`
2. Cập nhật API base URL:
   ```javascript
   const API_BASE_URL = 'https://localhost:5001/api-edu';
   ```

### Bước 6: Chạy Frontend

**Cách 1: Sử dụng Live Server (VS Code)**
- Cài đặt extension "Live Server"
- Right-click vào `AdminFrontend/index.html` → "Open with Live Server"

**Cách 2: Sử dụng Python HTTP Server**
```bash
cd AdminFrontend
python -m http.server 8080
```

**Cách 3: Sử dụng Node.js http-server**
```bash
npm install -g http-server
cd AdminFrontend
http-server -p 8080
```

Frontend sẽ chạy tại: `http://localhost:8080`

---

## 📖 Sử Dụng

### Đăng Nhập

Sau khi seed data, bạn có thể đăng nhập với các tài khoản sau:

#### 👤 Admin
- **Username:** `admin`
- **Password:** `admin123`

#### 👨‍🏫 Giảng Viên
- **Username:** `lecturer01`
- **Password:** `password123`

#### 🎓 Cố Vấn
- **Username:** `support_academic`
- **Password:** `password123`

#### 👨‍🎓 Sinh Viên
- **Username:** `student_k21_01`
- **Password:** `password123`

> 📝 Xem thêm tài khoản tại: `SQL/ACCOUNT_CREDENTIALS.md`

### Hướng Dẫn Sử Dụng Theo Vai Trò

#### Admin
- Quản lý người dùng, vai trò, quyền
- Quản lý khoa, bộ môn, ngành học
- Quản lý niên khóa, năm học
- Xem báo cáo tổng quan
- Xem audit logs

#### Giảng Viên
- Quản lý lớp học phần
- Điểm danh sinh viên
- Nhập điểm (giữa kỳ, cuối kỳ)
- Xem lịch học/thi
- Xử lý phúc khảo
- Xem báo cáo lớp chủ nhiệm

#### Cố Vấn
- Quản lý sinh viên
- Duyệt đăng ký học phần
- Cấu hình cảnh báo
- Gửi email cảnh báo
- Xử lý phúc khảo
- Duyệt học lại
- Xem báo cáo toàn trường

#### Sinh Viên
- Xem lịch học/thi
- Xem điểm danh
- Xem bảng điểm
- Đăng ký học phần
- Tạo yêu cầu phúc khảo
- Đăng ký học lại
- Xem báo cáo cá nhân

---

## 👥 Vai Trò Người Dùng

| Vai Trò | Mô Tả | Quyền Chính |
|---------|-------|-------------|
| **Admin** | Quản trị viên hệ thống | Toàn quyền hệ thống |
| **Lecturer** | Giảng viên | Quản lý lớp, điểm danh, nhập điểm |
| **Advisor** | Cố vấn học tập & Nhân viên phòng đào tạo | Quản lý sinh viên, duyệt đăng ký, cảnh báo |
| **Student** | Sinh viên | Xem thông tin, đăng ký học phần, phúc khảo |

---

## 📡 API Documentation

### Base URL
```
https://localhost:5001/api-edu
```

### Authentication
Tất cả API (trừ login) đều yêu cầu JWT token trong header:
```
Authorization: Bearer <token>
```

### Các Endpoint Chính

#### Authentication
- `POST /auth/login` - Đăng nhập
- `POST /auth/refresh` - Refresh token
- `POST /auth/logout` - Đăng xuất

#### Students
- `GET /students` - Lấy danh sách sinh viên
- `GET /students/{id}` - Lấy thông tin sinh viên
- `POST /students/import/batch` - Import sinh viên từ Excel

#### Classes
- `GET /classes` - Lấy danh sách lớp
- `POST /classes` - Tạo lớp mới
- `PUT /classes/{id}` - Cập nhật lớp

#### Enrollments
- `GET /enrollments` - Lấy danh sách đăng ký
- `POST /enrollments` - Đăng ký học phần
- `PUT /enrollments/{id}/approve` - Duyệt đăng ký

#### Attendances
- `GET /attendances` - Lấy lịch sử điểm danh
- `POST /attendances` - Điểm danh

#### Grades
- `GET /grades` - Lấy danh sách điểm
- `POST /grades` - Nhập điểm
- `PUT /grades/{id}` - Cập nhật điểm

#### Grade Appeals
- `GET /grade-appeals` - Lấy danh sách phúc khảo
- `POST /grade-appeals` - Tạo yêu cầu phúc khảo
- `PUT /grade-appeals/{id}/review` - Xử lý phúc khảo

> 📚 Xem chi tiết API tại Swagger UI: `https://localhost:5001/swagger`

---

## 🗄 Database Schema

### Các Bảng Chính

| Bảng | Mô Tả |
|------|-------|
| `users` | Người dùng hệ thống |
| `roles` | Vai trò |
| `permissions` | Quyền hạn |
| `students` | Sinh viên |
| `lecturers` | Giảng viên |
| `subjects` | Môn học |
| `classes` | Lớp học phần |
| `enrollments` | Đăng ký học phần |
| `attendances` | Điểm danh |
| `grades` | Điểm số |
| `gpas` | Điểm trung bình |
| `grade_appeals` | Phúc khảo |
| `retake_records` | Học lại |
| `timetable_sessions` | Lịch học |
| `exam_schedules` | Lịch thi |
| `notifications` | Thông báo |
| `audit_logs` | Nhật ký hệ thống |

> 📊 Xem chi tiết schema tại: `SQL/01_CreateTables.sql`

---

## 🤝 Đóng Góp

Chúng tôi hoan nghênh mọi đóng góp! Vui lòng:

1. Fork repository
2. Tạo feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Tạo Pull Request

### Quy Tắc Đóng Góp

- Tuân thủ coding standards
- Viết unit tests cho code mới
- Cập nhật documentation
- Đảm bảo không có lỗi build

---

## 🙏 Lời Cảm Ơn

Cảm ơn tất cả những người đã đóng góp cho dự án này!

---

**⭐ Nếu dự án này hữu ích, hãy cho chúng tôi một star!**

