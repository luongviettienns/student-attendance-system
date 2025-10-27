# 🗄️ HƯỚNG DẪN KHỞI TẠO DATABASE

## Hệ thống Quản lý Điểm danh Sinh viên

---

## 📋 DANH SÁCH FILES SQL (7 files)

| # | File | Mục đích | Bắt buộc |
|---|------|----------|----------|
| 0️⃣ | `00_ResetData.sql` | Xóa database | ⚠️ Dev only |
| 1️⃣ | `01_CreateTables.sql` | Tạo 19 bảng | ✅ BẮT BUỘC |
| 2️⃣ | `02_StoredProcedures.sql` | Tạo 90+ procedures | ✅ BẮT BUỘC |
| 3️⃣ | `03_SeedData.sql` | Dữ liệu mẫu | 🔶 Dev/Test |
| 4️⃣ | `04_Indexes.sql` | Tạo indexes | ✅ BẮT BUỘC |
| 5️⃣ | `05_Views.sql` | Tạo views báo cáo | ✅ Recommended |
| 6️⃣ | `06_RefreshTokens.sql` | JWT tokens | ✅ BẮT BUỘC |
| 7️⃣ | `07_StoredProcedures_ErrorHandling.sql` | Error handling | ✅ BẮT BUỘC |

---

## 🚀 QUY TRÌNH KHỞI TẠO

### 📍 **SCENARIO 1: KHỞI TẠO LẦN ĐẦU (Development)**

#### **Bước 1: Chuẩn bị**

```powershell
# Mở PowerShell/Terminal
cd "C:\Users\TK\Desktop\student-attendance-system"

# Kiểm tra SQL Server đang chạy
# Mở SQL Server Management Studio (SSMS)
# Hoặc kiểm tra service:
Get-Service MSSQL*
```

#### **Bước 2: Reset (Optional - Chỉ nếu muốn xóa hết)**

```sql
-- Chỉ chạy nếu muốn XÓA database cũ
-- ⚠️ CẢNH BÁO: Mất hết dữ liệu!

-- Option A: Dùng file SQL
-- Mở SSMS, chạy file:
00_ResetData.sql

-- Option B: Chạy trực tiếp
USE master;
GO
DROP DATABASE IF EXISTS EducationManagement;
GO
```

#### **Bước 3: Tạo Structure & Logic (4 files - THỨ TỰ QUAN TRỌNG!)**

```powershell
# Chạy lần lượt từ PowerShell:
sqlcmd -S DESKTOP-2PQVVC6\SQLEXPRESS -i 01_CreateTables.sql
sqlcmd -S DESKTOP-2PQVVC6\SQLEXPRESS -i 02_StoredProcedures.sql
sqlcmd -S DESKTOP-2PQVVC6\SQLEXPRESS -i 06_RefreshTokens.sql
sqlcmd -S DESKTOP-2PQVVC6\SQLEXPRESS -i 07_StoredProcedures_ErrorHandling.sql
```

**Hoặc từ SSMS:**
1. Mở SQL Server Management Studio
2. Kết nối: `DESKTOP-2PQVVC6\SQLEXPRESS`
3. File → Open → chọn file SQL
4. Chạy (F5) theo thứ tự:
   - `01_CreateTables.sql` → ✅
   - `02_StoredProcedures.sql` → ✅
   - `06_RefreshTokens.sql` → ✅
   - `07_StoredProcedures_ErrorHandling.sql` → ✅

**Kết quả mong đợi:**
```
✅ Đã tạo xong tất cả các bảng (19 bảng)
✅ Đã tạo 90+ stored procedures
✅ Đã tạo refresh_tokens procedures (5 SPs)
✅ Đã cập nhật error handling (5 SPs)
```

#### **Bước 4: Tối ưu Performance (2 files)**

```powershell
# Tạo indexes cho performance
sqlcmd -S DESKTOP-2PQVVC6\SQLEXPRESS -i 04_Indexes.sql

# Tạo views cho báo cáo
sqlcmd -S DESKTOP-2PQVVC6\SQLEXPRESS -i 05_Views.sql
```

**Kết quả mong đợi:**
```
✅ Đã tạo 25+ indexes
✅ Đã tạo 6 views
```

#### **Bước 5: Thêm dữ liệu mẫu (Development/Test only)**

```powershell
sqlcmd -S DESKTOP-2PQVVC6\SQLEXPRESS -i 03_SeedData.sql
```

**Kết quả mong đợi:**
```
✅ Đã tạo roles (Admin, Lecturer, Student, Advisor)
✅ Đã tạo user mẫu (admin@example.com / Admin@123)
✅ Đã tạo faculties, departments, majors mẫu
✅ Đã tạo students, lecturers mẫu
✅ Đã tạo permissions data
```

#### **Bước 6: Verify (Kiểm tra)**

```sql
-- Mở SSMS, chạy các query sau:

-- 1. Kiểm tra bảng
SELECT COUNT(*) AS TableCount 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_CATALOG = 'EducationManagement' 
  AND TABLE_TYPE = 'BASE TABLE';
-- Expected: 19 bảng

-- 2. Kiểm tra stored procedures
SELECT COUNT(*) AS ProcedureCount 
FROM INFORMATION_SCHEMA.ROUTINES 
WHERE ROUTINE_TYPE = 'PROCEDURE' 
  AND ROUTINE_CATALOG = 'EducationManagement';
-- Expected: 95+ procedures

-- 3. Kiểm tra indexes
SELECT COUNT(*) AS IndexCount 
FROM sys.indexes i
INNER JOIN sys.tables t ON i.object_id = t.object_id
WHERE t.is_ms_shipped = 0 AND i.type > 0;
-- Expected: 25+ indexes

-- 4. Kiểm tra views
SELECT COUNT(*) AS ViewCount 
FROM INFORMATION_SCHEMA.VIEWS 
WHERE TABLE_CATALOG = 'EducationManagement';
-- Expected: 6 views

-- 5. Kiểm tra data mẫu (nếu chạy 04_SeedData)
SELECT 'Users' AS TableName, COUNT(*) AS RowCount FROM users
UNION ALL
SELECT 'Students', COUNT(*) FROM students
UNION ALL
SELECT 'Roles', COUNT(*) FROM roles;
```

---

### 📍 **SCENARIO 2: CẬP NHẬT HỆ THỐNG CŨ**

Nếu bạn đã có database và chỉ cần update:

```powershell
# Chỉ chạy 3 files mới:
sqlcmd -S DESKTOP-2PQVVC6\SQLEXPRESS -i 06_RefreshTokens.sql
sqlcmd -S DESKTOP-2PQVVC6\SQLEXPRESS -i 07_StoredProcedures_ErrorHandling.sql
sqlcmd -S DESKTOP-2PQVVC6\SQLEXPRESS -i 04_Indexes.sql
```

**Lưu ý:** Các files này đều **idempotent** (chạy nhiều lần không sao)

---

### 📍 **SCENARIO 3: PRODUCTION DEPLOYMENT**

#### **YÊU CẦU:**
- ✅ Đã backup database hiện tại
- ✅ Đã test trên staging
- ✅ Có maintenance window
- ✅ Đã thông báo users

#### **Quy trình:**

```powershell
# 1. BACKUP trước khi làm gì
sqlcmd -S YOUR_PROD_SERVER -Q "BACKUP DATABASE [EducationManagement] TO DISK = 'D:\Backups\EducationManagement_BeforeUpdate.bak' WITH INIT, COMPRESSION"

# 2. Chạy scripts (KHÔNG chạy 00 và 03!)
sqlcmd -S YOUR_PROD_SERVER -i 01_CreateTables.sql        # Nếu database mới
sqlcmd -S YOUR_PROD_SERVER -i 02_StoredProcedures.sql
sqlcmd -S YOUR_PROD_SERVER -i 06_RefreshTokens.sql
sqlcmd -S YOUR_PROD_SERVER -i 07_StoredProcedures_ErrorHandling.sql
sqlcmd -S YOUR_PROD_SERVER -i 04_Indexes.sql
sqlcmd -S YOUR_PROD_SERVER -i 05_Views.sql

# 3. KHÔNG chạy:
# ❌ 00_ResetData.sql - Xóa database
# ❌ 03_SeedData.sql - Test data only

# 4. Verify
sqlcmd -S YOUR_PROD_SERVER -Q "SELECT @@VERSION; SELECT DB_NAME(); SELECT COUNT(*) FROM sys.tables;"
```

#### **Rollback Plan (Nếu có lỗi):**

```sql
-- Restore từ backup
USE master;
GO
ALTER DATABASE EducationManagement SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
RESTORE DATABASE EducationManagement 
FROM DISK = 'D:\Backups\EducationManagement_BeforeUpdate.bak'
WITH REPLACE;
GO
ALTER DATABASE EducationManagement SET MULTI_USER;
GO
```

---

## 📝 SCRIPT TỰ ĐỘNG

### **Windows PowerShell Script**

Tạo file `setup-database.ps1`:

```powershell
# Setup Database - Development
param(
    [string]$Server = "DESKTOP-2PQVVC6\SQLEXPRESS",
    [switch]$Reset,
    [switch]$Production
)

Write-Host "🚀 Khởi tạo Database..." -ForegroundColor Green

# Reset (optional)
if ($Reset) {
    Write-Host "⚠️  Reset database..." -ForegroundColor Yellow
    sqlcmd -S $Server -i 00_ResetData.sql
}

# Core structure
Write-Host "📋 Tạo tables..." -ForegroundColor Cyan
sqlcmd -S $Server -i 01_CreateTables.sql

Write-Host "⚙️  Tạo stored procedures..." -ForegroundColor Cyan
sqlcmd -S $Server -i 02_StoredProcedures.sql

Write-Host "🔐 Tạo refresh tokens..." -ForegroundColor Cyan
sqlcmd -S $Server -i 07_RefreshTokens.sql

Write-Host "🛡️  Thêm error handling..." -ForegroundColor Cyan
sqlcmd -S $Server -i 08_StoredProcedures_ErrorHandling.sql

Write-Host "🚀 Tạo indexes..." -ForegroundColor Cyan
sqlcmd -S $Server -i 05_Indexes.sql

Write-Host "📊 Tạo views..." -ForegroundColor Cyan
sqlcmd -S $Server -i 06_Views.sql

# Seed data (không chạy trong production)
if (-not $Production) {
    Write-Host "🎨 Thêm dữ liệu mẫu..." -ForegroundColor Cyan
    sqlcmd -S $Server -i 04_SeedData.sql
}

Write-Host "✅ Hoàn thành!" -ForegroundColor Green
```

**Sử dụng:**
```powershell
# Development (full setup)
.\setup-database.ps1 -Reset

# Production (no reset, no seed data)
.\setup-database.ps1 -Server "PROD_SERVER" -Production

# Update only
.\setup-database.ps1
```

---

## 🔍 TROUBLESHOOTING

### ❌ Lỗi: "Database does not exist"
```sql
-- Chạy lại file 01
sqlcmd -S DESKTOP-2PQVVC6\SQLEXPRESS -i 01_CreateTables.sql
```

### ❌ Lỗi: "Procedure already exists"
```sql
-- Không sao! Files có DROP IF EXISTS
-- Chỉ cần chạy lại file đó
```

### ❌ Lỗi: "Foreign key constraint"
```sql
-- Chạy đúng thứ tự:
-- 01 → 02 → 07 → 08 → 05 → 06 → 04
```

### ❌ Lỗi: "Login failed"
```sql
-- Kiểm tra connection string
-- Hoặc dùng Windows Authentication trong SSMS
```

### ❌ Lỗi: "Timeout expired"
```sql
-- File 05_Indexes.sql có thể lâu với data lớn
-- Tăng timeout:
sqlcmd -S SERVER -i 05_Indexes.sql -t 120
```

---

## ✅ CHECKLIST HOÀN THÀNH

### Development Setup:
- [ ] Chạy `01_CreateTables.sql` → 19 bảng ✅
- [ ] Chạy `02_StoredProcedures.sql` → 90+ SPs ✅
- [ ] Chạy `07_RefreshTokens.sql` → 5 SPs tokens ✅
- [ ] Chạy `08_StoredProcedures_ErrorHandling.sql` → Error handling ✅
- [ ] Chạy `05_Indexes.sql` → 25+ indexes ✅
- [ ] Chạy `06_Views.sql` → 6 views ✅
- [ ] Chạy `04_SeedData.sql` → Test data ✅
- [ ] Verify: Tất cả queries test chạy OK ✅
- [ ] Test login: admin@example.com / Admin@123 ✅

### Production Deployment:
- [ ] Backup database hiện tại ✅
- [ ] Chạy files SQL (không chạy 00 và 04) ✅
- [ ] Verify: Check counts ✅
- [ ] Test: Login, CRUD operations ✅
- [ ] Monitor: Check performance ✅
- [ ] Setup SQL Agent job cho cleanup tokens ✅

---

## 📊 KẾT QUẢ CUỐI CÙNG

Sau khi setup xong, bạn sẽ có:

```
EducationManagement Database
├── 📦 19 Tables
│   ├── users, roles, permissions
│   ├── students, lecturers
│   ├── faculties, departments, majors
│   ├── classes, subjects, enrollments
│   ├── grades, gpas, attendances
│   ├── notifications, audit_logs
│   └── refresh_tokens
│
├── ⚙️ 95+ Stored Procedures
│   ├── CRUD operations
│   ├── Business logic
│   ├── Error handling
│   └── Token management
│
├── 🚀 25+ Indexes
│   ├── Pagination indexes
│   ├── Foreign key indexes
│   ├── Covering indexes
│   └── Search indexes
│
├── 📊 6 Views
│   ├── Student transcript
│   ├── GPA summary
│   ├── Class statistics
│   └── Attendance history
│
└── 🎨 Sample Data (Dev only)
    ├── 4 Roles
    ├── Admin user
    ├── 5 Students
    └── 3 Lecturers
```

---

## 🔗 BƯỚC TIẾP THEO

Sau khi setup database xong:

1. **Backend:**
   - Cập nhật connection string
   - Build & run API: `dotnet run`
   - Test endpoints

2. **Frontend:**
   - Cập nhật API URL
   - Start server
   - Test login

3. **Redis:**
   - Start Redis server
   - Test caching

4. **Testing:**
   - Test tất cả features
   - Load testing
   - Security testing

---

## 📚 TÀI LIỆU LIÊN QUAN

- `SQL_FILES_SUMMARY.md` - Tóm tắt files SQL
- `SQL_FILES_GUIDE.md` - Chi tiết từng file
- `OPTIMIZATION_IMPLEMENTATION_GUIDE.md` - Tối ưu hóa
- `QUICK_START.md` - Setup nhanh 15 phút

---

**Version:** 1.0  
**Cập nhật:** 2024  
**Tác giả:** AI Assistant

**Status:** ✅ READY TO USE

