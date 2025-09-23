# 🗄️ Hướng dẫn Setup Database cho SimpleUserAPI

## 📋 **Tổng quan**
File này hướng dẫn cách setup database cho project SimpleUserAPI để có thể chạy và test API.

## 🚀 **Cách 1: Chạy script SQL (Khuyến nghị)**

### **Bước 1: Mở SQL Server Management Studio (SSMS)**
1. Khởi động **SQL Server Management Studio**
2. Kết nối đến SQL Server instance của bạn

### **Bước 2: Chạy script database**
1. Mở file: `Database\SimpleUserDB.sql`
2. **Execute** toàn bộ script (F5)
3. Kiểm tra kết quả trong **Messages** tab

### **Bước 3: Kiểm tra database**
```sql
-- Kiểm tra database đã tạo
SELECT name FROM sys.databases WHERE name = 'SimpleUserDB'

-- Kiểm tra bảng users
USE SimpleUserDB
SELECT * FROM users

-- Kiểm tra stored procedures
SELECT name FROM sys.procedures WHERE name LIKE 'sp_%'
```

## 🔧 **Cách 2: Chạy từ Command Line**

### **Sử dụng sqlcmd:**
```bash
# Kết nối và chạy script
sqlcmd -S localhost\SQLEXPRESS -i "Database\SimpleUserDB.sql"

# Hoặc với authentication
sqlcmd -S localhost\SQLEXPRESS -U sa -P YourPassword -i "Database\SimpleUserDB.sql"
```

### **Sử dụng PowerShell:**
```powershell
# Chạy script từ PowerShell
Invoke-Sqlcmd -ServerInstance "localhost\SQLEXPRESS" -InputFile "Database\SimpleUserDB.sql"
```

## ⚙️ **Cấu hình Connection String**

### **Sau khi tạo database, cập nhật connection string:**

**File: `appsettings.json`**
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=SimpleUserDB;Trusted_Connection=True;TrustServerCertificate=True;"
  }
}
```

**File: `appsettings.Development.json`**
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=SimpleUserDB_Dev;Trusted_Connection=True;TrustServerCertificate=True;"
  }
}
```

## 🎯 **Các loại SQL Server được hỗ trợ**

### **1. SQL Server Express (Mặc định)**
```json
"Server=localhost\\SQLEXPRESS;Database=SimpleUserDB;Trusted_Connection=True;TrustServerCertificate=True;"
```

### **2. SQL Server Full**
```json
"Server=localhost;Database=SimpleUserDB;User Id=sa;Password=YourPassword123;TrustServerCertificate=True;"
```

### **3. LocalDB**
```json
"Server=(localdb)\\mssqllocaldb;Database=SimpleUserDB;Trusted_Connection=True;TrustServerCertificate=True;"
```

### **4. Remote Server**
```json
"Server=192.168.1.100;Database=SimpleUserDB;User Id=simpleuser_user;Password=YourPassword123;TrustServerCertificate=True;"
```

## 📊 **Cấu trúc Database**

### **Bảng: users**
| Column | Type | Description |
|--------|------|-------------|
| user_id | int | Primary Key, Identity |
| user_name | nvarchar(50) | Tên đăng nhập (Unique) |
| password | nvarchar(255) | Mật khẩu |
| full_name | nvarchar(100) | Họ tên đầy đủ |
| email | nvarchar(100) | Email |
| phone | nvarchar(20) | Số điện thoại |
| role | nvarchar(20) | Vai trò (Admin/User/Manager) |
| created_at | datetime2 | Thời gian tạo |
| updated_at | datetime2 | Thời gian cập nhật |
| is_active | bit | Trạng thái hoạt động |

### **Stored Procedures:**
- `sp_GetAllUsers` - Lấy danh sách users
- `sp_GetUserById` - Lấy user theo ID
- `sp_CreateUser` - Tạo user mới
- `sp_UpdateUser` - Cập nhật user
- `sp_DeleteUser` - Xóa user (soft delete)
- `sp_SearchUsers` - Tìm kiếm users

### **Views:**
- `vw_ActiveUsers` - View users đang hoạt động

### **Functions:**
- `fn_UserExists` - Kiểm tra user tồn tại

## 🧪 **Dữ liệu mẫu**

Script sẽ tự động tạo 4 users mẫu:
1. **admin** - Administrator
2. **user1** - Nguyễn Văn A
3. **user2** - Trần Thị B  
4. **manager1** - Lê Văn C

## 🔍 **Test Database**

### **Kiểm tra kết nối:**
```sql
USE SimpleUserDB
SELECT COUNT(*) as TotalUsers FROM users WHERE is_active = 1
```

### **Test Stored Procedures:**
```sql
-- Lấy tất cả users
EXEC sp_GetAllUsers

-- Lấy user theo ID
EXEC sp_GetUserById @user_id = 1

-- Tìm kiếm users
EXEC sp_SearchUsers @search_term = 'admin'
```

## 🚨 **Troubleshooting**

### **Lỗi 1: "Cannot connect to SQL Server"**
- Kiểm tra SQL Server đang chạy
- Kiểm tra firewall settings
- Kiểm tra connection string

### **Lỗi 2: "Database does not exist"**
- Chạy lại script tạo database
- Kiểm tra tên database trong connection string

### **Lỗi 3: "Login failed"**
- Kiểm tra username/password
- Kiểm tra SQL Server Authentication mode
- Tạo user mới nếu cần

### **Lỗi 4: "TrustServerCertificate"**
- Thêm `TrustServerCertificate=True` vào connection string
- Hoặc cài đặt SSL certificate

## 📝 **Ghi chú cho đồng nghiệp**

### **Để chạy project:**
1. **Tạo database:** Chạy script `SimpleUserDB.sql`
2. **Cập nhật connection string** trong `appsettings.json`
3. **Build project:** `dotnet build`
4. **Chạy API:** `dotnet run`
5. **Test API:** http://localhost:5000/swagger

### **API Endpoints:**
- `GET /api/user` - Lấy danh sách users
- `GET /api/user/{id}` - Lấy user theo ID
- `POST /api/user` - Tạo user mới
- `PUT /api/user/{id}` - Cập nhật user
- `DELETE /api/user/{id}` - Xóa user
- `GET /api/user/search?name=...` - Tìm kiếm user
- `GET /health` - Health check

### **Swagger UI:**
- URL: http://localhost:5000/swagger
- Test API trực tiếp trên browser

## 🎉 **Kết quả mong đợi**

Sau khi setup thành công:
- ✅ Database `SimpleUserDB` được tạo
- ✅ Bảng `users` với dữ liệu mẫu
- ✅ Stored procedures hoạt động
- ✅ API kết nối được database
- ✅ Test API thành công trên Postman/Swagger

**Chúc bạn setup thành công!** 🚀


