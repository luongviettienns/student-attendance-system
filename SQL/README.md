# Hệ Thống Quản Lý Điểm Danh Sinh Viên

## Cấu Trúc Database

### Thứ tự chạy các file SQL:

1. **00_ResetDatabase.sql** - Reset toàn bộ database (xóa và tạo lại)
2. **01_CreateTables.sql** - Tạo tất cả các bảng
3. **02a_SP_Users.sql** - Stored Procedures: Quản lý người dùng
4. **02b_SP_Organization.sql** - Stored Procedures: Quản lý tổ chức (Khoa, Bộ môn, Ngành)
5. **02c_SP_Academic.sql** - Stored Procedures: Quản lý niên khóa
6. **02d_SP_Students.sql** - Stored Procedures: Quản lý sinh viên
7. **02e_SP_Lecturers.sql** - Stored Procedures: Quản lý giảng viên
8. **02f_SP_Subjects.sql** - Stored Procedures: Quản lý môn học
9. **02g_SP_Classes.sql** - Stored Procedures: Quản lý lớp học và đăng ký học phần
10. **02h_SP_Attendance.sql** - Stored Procedures: Quản lý điểm danh
11. **02i_SP_Grades.sql** - Stored Procedures: Quản lý điểm số
12. **02j_SP_System.sql** - Stored Procedures: Quản lý hệ thống (Vai trò, Quyền, Thông báo, Audit Log)
13. **02k_SP_Timetable.sql** - Stored Procedures: Quản lý thời khóa biểu
14. **02l_SP_Administrative.sql** - Stored Procedures: Quản lý lớp hành chính
15. **03_SeedData.sql** - Dữ liệu mẫu (tùy chọn)
16. **04_Indexes.sql** - Tạo các index để tối ưu hiệu suất
17. **05_Views.sql** - Tạo các view (tùy chọn)

## Hướng Dẫn Chạy Script

### Cách 1: Sử dụng PowerShell Script (Khuyến nghị)

Chạy script PowerShell để tự động chạy tất cả các file SP:

```powershell
cd SQL
.\Run-All-Stored-Procedures.ps1
```

Script sẽ:
- Kết nối đến SQL Server
- Chạy tất cả các file SP theo đúng thứ tự
- Hiển thị tiến trình và kết quả

### Cách 2: Chạy thủ công trong SQL Server Management Studio (SSMS)

1. Mở SQL Server Management Studio
2. Kết nối đến server database
3. Chọn database `EducationManagement`
4. Mở từng file SQL và chạy theo thứ tự từ 02a đến 02l

### Cách 3: Sử dụng sqlcmd

```bash
sqlcmd -S localhost -d EducationManagement -i 02a_SP_Users.sql
sqlcmd -S localhost -d EducationManagement -i 02b_SP_Organization.sql
# ... tiếp tục với các file còn lại
```

## Cấu Hình

### Yêu Cầu Hệ Thống

- SQL Server 2016 trở lên
- PowerShell 5.1 trở lên (nếu dùng script)
- SQL Server Management Studio (tùy chọn)

### Cấu Hình Kết Nối Database

Khi chạy script PowerShell, bạn cần cấu hình:

1. Sửa file `Run-All-Stored-Procedures.ps1`
2. Thay đổi các thông số kết nối:
   ```powershell
   $server = "localhost"  # Hoặc tên server SQL của bạn
   $database = "EducationManagement"
   $integratedSecurity = $true  # Sử dụng Windows Authentication
   # Hoặc
   $username = "sa"
   $password = "your_password"
   ```

## Lưu Ý

- **Luôn backup database** trước khi chạy script reset hoặc thay đổi cấu trúc
- Chạy các file SP theo đúng thứ tự để tránh lỗi dependency
- Nếu gặp lỗi, kiểm tra log trong console hoặc SSMS output
- File `02z_SP_Master.sql` chỉ là file tham khảo, không cần chạy

## Tổng Quan Stored Procedures

Hệ thống bao gồm **135+ stored procedures** được tổ chức thành 12 module:

- **Users**: 10+ SP (Quản lý người dùng, đăng nhập, phân quyền)
- **Organization**: 15+ SP (Khoa, Bộ môn, Ngành học)
- **Academic**: 8+ SP (Niên khóa, năm học)
- **Students**: 15+ SP (Thông tin sinh viên, đăng ký)
- **Lecturers**: 8+ SP (Thông tin giảng viên)
- **Subjects**: 10+ SP (Môn học, tiên quyết)
- **Classes**: 15+ SP (Lớp học, đăng ký học phần)
- **Attendance**: 8+ SP (Điểm danh sinh viên)
- **Grades**: 12+ SP (Điểm số, GPA)
- **System**: 20+ SP (Vai trò, quyền, thông báo, audit log)
- **Timetable**: 10+ SP (Thời khóa biểu, lịch học)
- **Administrative**: 6+ SP (Lớp hành chính)

## Hỗ Trợ

Nếu gặp vấn đề, vui lòng kiểm tra:
1. Kết nối database có đúng không
2. Database `EducationManagement` đã được tạo chưa
3. Các bảng đã được tạo đầy đủ chưa (chạy 01_CreateTables.sql)
4. Thứ tự chạy các file SP có đúng không

