# ⚡ KHỞI TẠO DATABASE - 5 PHÚT

## Cách nhanh nhất để setup database

---

## 🚀 PHƯƠNG ÁN 1: SỬ DỤNG SCRIPT TỰ ĐỘNG (Recommended)

### Bước 1: Mở PowerShell
```powershell
cd C:\Users\TK\Desktop\student-attendance-system
```

### Bước 2: Chạy script

**Development (đầy đủ):**
```powershell
.\setup-database.ps1
```

**Development (reset toàn bộ):**
```powershell
.\setup-database.ps1 -Reset
```

**Chỉ update (đã có database):**
```powershell
.\setup-database.ps1 -UpdateOnly
```

**Production:**
```powershell
.\setup-database.ps1 -Production
```

### Bước 3: Xong! ✅
```
✅ SETUP COMPLETED!
   ✅ 19 Tables created
   ✅ 95+ Stored Procedures created
   ✅ 25+ Indexes created
   ✅ 6 Views created
   ✅ Sample data inserted

🔑 Login: admin@example.com / Admin@123
```

---

## 📝 PHƯƠNG ÁN 2: CHẠY THỦ CÔNG (SSMS)

### Bước 1: Mở SQL Server Management Studio
- Kết nối: `DESKTOP-2PQVVC6\SQLEXPRESS`

### Bước 2: Chạy lần lượt 7 files

| Thứ tự | File | Mô tả |
|--------|------|-------|
| 1️⃣ | `01_CreateTables.sql` | Tạo 19 bảng |
| 2️⃣ | `02_StoredProcedures.sql` | Tạo 90+ procedures |
| 3️⃣ | `07_RefreshTokens.sql` | Tạo token procedures |
| 4️⃣ | `08_StoredProcedures_ErrorHandling.sql` | Error handling |
| 5️⃣ | `05_Indexes.sql` | Tạo indexes |
| 6️⃣ | `06_Views.sql` | Tạo views |
| 7️⃣ | `04_SeedData.sql` | Dữ liệu mẫu (Dev only) |

**Cách chạy:**
- File → Open → chọn file SQL
- Nhấn F5 hoặc Execute
- Chờ "✅ Success"
- Lặp lại với file tiếp theo

---

## 📝 PHƯƠNG ÁN 3: COMMAND LINE

```powershell
# Development
sqlcmd -S DESKTOP-2PQVVC6\SQLEXPRESS -i 01_CreateTables.sql
sqlcmd -S DESKTOP-2PQVVC6\SQLEXPRESS -i 02_StoredProcedures.sql
sqlcmd -S DESKTOP-2PQVVC6\SQLEXPRESS -i 07_RefreshTokens.sql
sqlcmd -S DESKTOP-2PQVVC6\SQLEXPRESS -i 08_StoredProcedures_ErrorHandling.sql
sqlcmd -S DESKTOP-2PQVVC6\SQLEXPRESS -i 05_Indexes.sql
sqlcmd -S DESKTOP-2PQVVC6\SQLEXPRESS -i 06_Views.sql
sqlcmd -S DESKTOP-2PQVVC6\SQLEXPRESS -i 04_SeedData.sql
```

---

## ✅ KIỂM TRA

Chạy query này để verify:

```sql
-- Kiểm tra nhanh
SELECT 'Tables' AS Type, COUNT(*) AS Count 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_CATALOG = 'EducationManagement' AND TABLE_TYPE = 'BASE TABLE'
UNION ALL
SELECT 'Procedures', COUNT(*) 
FROM INFORMATION_SCHEMA.ROUTINES 
WHERE ROUTINE_TYPE = 'PROCEDURE'
UNION ALL
SELECT 'Indexes', COUNT(*) 
FROM sys.indexes i INNER JOIN sys.tables t ON i.object_id = t.object_id 
WHERE t.is_ms_shipped = 0 AND i.type > 0;
```

**Kết quả mong đợi:**
```
Tables        19
Procedures    95+
Indexes       25+
```

---

## 🔑 TEST LOGIN

```sql
-- Kiểm tra user admin
SELECT * FROM users WHERE email = 'admin@example.com';
```

**Login credentials (Development):**
- Email: `admin@example.com`
- Password: `Admin@123`

---

## 🐛 TROUBLESHOOTING

### ❌ "Cannot open database"
```powershell
# Chạy lại file 01
.\setup-database.ps1 -Reset
```

### ❌ "Login failed"
```
Dùng Windows Authentication trong SSMS
```

### ❌ Script execution disabled
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## 📚 CHI TIẾT

Xem `DATABASE_SETUP_GUIDE.md` để biết thêm chi tiết

---

## 🎯 TỔNG KẾT

**Thời gian:** 5 phút  
**Files cần:** 7 files SQL  
**Kết quả:** Database đầy đủ + Data mẫu  
**Khó:** ⭐☆☆☆☆ (Rất dễ!)

**Khuyến nghị:** Dùng PowerShell script `setup-database.ps1` 🚀

