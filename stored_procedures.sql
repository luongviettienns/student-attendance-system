-- Stored Procedures for Education Management System
USE EducationManagement;
GO

-- User Stored Procedures

-- Create user
CREATE PROCEDURE [dbo].[sp_user_create]
    @user_id VARCHAR(50),
    @hoten NVARCHAR(150),
    @ngaysinh DATE = NULL,
    @diachi NVARCHAR(250) = NULL,
    @gioitinh NVARCHAR(30) = NULL,
    @email VARCHAR(150) = NULL,
    @taikhoan VARCHAR(30),
    @matkhau VARCHAR(255),
    @role VARCHAR(30),
    @image_url VARCHAR(300) = NULL,
    @student_code VARCHAR(20) = NULL,
    @faculty_id VARCHAR(50) = NULL,
    @major VARCHAR(100) = NULL,
    @academic_year VARCHAR(10) = NULL,
    @phone VARCHAR(15) = NULL,
    @is_active BIT = 1,
    @created_by VARCHAR(50) = NULL
AS
BEGIN
    INSERT INTO [users] (
        [user_id], [hoten], [ngaysinh], [diachi], [gioitinh], [email], 
        [taikhoan], [matkhau], [role], [image_url], [student_code], 
        [faculty_id], [major], [academic_year], [phone], [is_active], [created_by]
    )
    VALUES (
        @user_id, @hoten, @ngaysinh, @diachi, @gioitinh, @email,
        @taikhoan, @matkhau, @role, @image_url, @student_code,
        @faculty_id, @major, @academic_year, @phone, @is_active, @created_by
    );
    SELECT '';
END;
GO

-- Update user
CREATE PROCEDURE [dbo].[sp_user_update]
    @user_id VARCHAR(50),
    @hoten NVARCHAR(150),
    @ngaysinh DATE = NULL,
    @diachi NVARCHAR(250) = NULL,
    @gioitinh NVARCHAR(30) = NULL,
    @email VARCHAR(150) = NULL,
    @taikhoan VARCHAR(30),
    @matkhau VARCHAR(255) = NULL,
    @role VARCHAR(30),
    @image_url VARCHAR(300) = NULL,
    @student_code VARCHAR(20) = NULL,
    @faculty_id VARCHAR(50) = NULL,
    @major VARCHAR(100) = NULL,
    @academic_year VARCHAR(10) = NULL,
    @phone VARCHAR(15) = NULL,
    @is_active BIT = 1
AS
BEGIN
    UPDATE [users] SET
        [hoten] = @hoten,
        [ngaysinh] = @ngaysinh,
        [diachi] = @diachi,
        [gioitinh] = @gioitinh,
        [email] = @email,
        [taikhoan] = @taikhoan,
        [matkhau] = ISNULL(@matkhau, [matkhau]),
        [role] = @role,
        [image_url] = @image_url,
        [student_code] = @student_code,
        [faculty_id] = @faculty_id,
        [major] = @major,
        [academic_year] = @academic_year,
        [phone] = @phone,
        [is_active] = @is_active
    WHERE [user_id] = @user_id;
    SELECT '';
END;
GO

-- Delete user
CREATE PROCEDURE [dbo].[sp_user_delete]
    @user_id VARCHAR(50)
AS
BEGIN
    DELETE FROM [users] WHERE [user_id] = @user_id;
    SELECT '';
END;
GO

-- Get user by ID
CREATE PROCEDURE [dbo].[sp_user_get_by_id]
    @user_id VARCHAR(50)
AS
BEGIN
    SELECT 
        [user_id], [hoten], [ngaysinh], [diachi], [gioitinh], [email],
        [taikhoan], [matkhau], [role], [image_url], [student_code],
        [faculty_id], [major], [academic_year], [phone], [is_active], [created_date]
    FROM [users]
    WHERE [user_id] = @user_id;
END;
GO

-- Get user by username and password
CREATE PROCEDURE [dbo].[sp_user_get_by_username_password]
    @taikhoan VARCHAR(30),
    @matkhau VARCHAR(255)
AS
BEGIN
    SELECT 
        [user_id], [hoten], [ngaysinh], [diachi], [gioitinh], [email],
        [taikhoan], [role], [image_url], [student_code],
        [faculty_id], [major], [academic_year], [phone], [is_active], [created_date]
    FROM [users]
    WHERE [taikhoan] = @taikhoan AND [matkhau] = @matkhau AND [is_active] = 1;
END;
GO

-- Search users
CREATE PROCEDURE [dbo].[sp_user_search]
    @page_index INT,
    @page_size INT,
    @hoten NVARCHAR(150) = '',
    @taikhoan VARCHAR(30) = '',
    @role VARCHAR(30) = ''
AS
BEGIN
    DECLARE @RecordCount BIGINT;
    
    IF(@page_size <> 0)
    BEGIN
        SET NOCOUNT ON;
        SELECT(ROW_NUMBER() OVER(ORDER BY [hoten] ASC)) AS RowNumber, 
               [user_id], [hoten], [ngaysinh], [diachi], [gioitinh], [email],
               [taikhoan], [role], [image_url], [student_code],
               [faculty_id], [major], [academic_year], [phone], [is_active], [created_date]
        INTO #Results1
        FROM [users]
        WHERE (@hoten = '' OR [hoten] LIKE '%' + @hoten + '%')
          AND (@taikhoan = '' OR [taikhoan] = @taikhoan)
          AND (@role = '' OR [role] = @role)
          AND [is_active] = 1;
          
        SELECT @RecordCount = COUNT(*) FROM #Results1;
        
        SELECT *, @RecordCount AS RecordCount
        FROM #Results1
        WHERE RowNumber BETWEEN (@page_index - 1) * @page_size + 1 
                          AND ((@page_index - 1) * @page_size + 1) + @page_size - 1
              OR @page_index = -1;
        DROP TABLE #Results1;
    END
    ELSE
    BEGIN
        SET NOCOUNT ON;
        SELECT(ROW_NUMBER() OVER(ORDER BY [hoten] ASC)) AS RowNumber, 
               [user_id], [hoten], [ngaysinh], [diachi], [gioitinh], [email],
               [taikhoan], [role], [image_url], [student_code],
               [faculty_id], [major], [academic_year], [phone], [is_active], [created_date]
        INTO #Results2
        FROM [users]
        WHERE (@hoten = '' OR [hoten] LIKE '%' + @hoten + '%')
          AND (@taikhoan = '' OR [taikhoan] = @taikhoan)
          AND (@role = '' OR [role] = @role)
          AND [is_active] = 1;
          
        SELECT @RecordCount = COUNT(*) FROM #Results2;
        
        SELECT *, @RecordCount AS RecordCount
        FROM #Results2;
        DROP TABLE #Results2;
    END;
END;
GO

-- Get all users
CREATE PROCEDURE [dbo].[sp_user_get_all]
AS
BEGIN
    SELECT 
        [user_id], [hoten], [ngaysinh], [diachi], [gioitinh], [email],
        [taikhoan], [role], [image_url], [student_code],
        [faculty_id], [major], [academic_year], [phone], [is_active], [created_date]
    FROM [users]
    WHERE [is_active] = 1
    ORDER BY [hoten];
END;
GO

-- Change password
CREATE PROCEDURE [dbo].[sp_user_change_password]
    @user_id VARCHAR(50),
    @new_password VARCHAR(255)
AS
BEGIN
    UPDATE [users] 
    SET [matkhau] = @new_password
    WHERE [user_id] = @user_id;
    SELECT '';
END;
GO

-- Check email exists
CREATE PROCEDURE [dbo].[sp_user_check_email_exists]
    @email VARCHAR(150)
AS
BEGIN
    SELECT CASE WHEN EXISTS(SELECT 1 FROM [users] WHERE [email] = @email) THEN 1 ELSE 0 END;
END;
GO

-- Check username exists
CREATE PROCEDURE [dbo].[sp_user_check_username_exists]
    @taikhoan VARCHAR(30)
AS
BEGIN
    SELECT CASE WHEN EXISTS(SELECT 1 FROM [users] WHERE [taikhoan] = @taikhoan) THEN 1 ELSE 0 END;
END;
GO

-- Get user by email
CREATE PROCEDURE [dbo].[sp_user_get_by_email]
    @email VARCHAR(150)
AS
BEGIN
    SELECT 
        [user_id], [hoten], [ngaysinh], [diachi], [gioitinh], [email],
        [taikhoan], [role], [image_url], [student_code],
        [faculty_id], [major], [academic_year], [phone], [is_active], [created_date]
    FROM [users]
    WHERE [email] = @email AND [is_active] = 1;
END;
GO

-- Subject Stored Procedures

-- Create subject
CREATE PROCEDURE [dbo].[sp_subject_create]
    @subject_id VARCHAR(50),
    @subject_code VARCHAR(20),
    @subject_name NVARCHAR(200),
    @credits INT,
    @description NVARCHAR(500) = NULL,
    @is_active BIT = 1,
    @created_by VARCHAR(50) = NULL
AS
BEGIN
    INSERT INTO [subjects] (
        [subject_id], [subject_code], [subject_name], [credits], 
        [description], [is_active], [created_by]
    )
    VALUES (
        @subject_id, @subject_code, @subject_name, @credits,
        @description, @is_active, @created_by
    );
    SELECT '';
END;
GO

-- Update subject
CREATE PROCEDURE [dbo].[sp_subject_update]
    @subject_id VARCHAR(50),
    @subject_code VARCHAR(20),
    @subject_name NVARCHAR(200),
    @credits INT,
    @description NVARCHAR(500) = NULL,
    @is_active BIT = 1
AS
BEGIN
    UPDATE [subjects] SET
        [subject_code] = @subject_code,
        [subject_name] = @subject_name,
        [credits] = @credits,
        [description] = @description,
        [is_active] = @is_active
    WHERE [subject_id] = @subject_id;
    SELECT '';
END;
GO

-- Delete subject
CREATE PROCEDURE [dbo].[sp_subject_delete]
    @subject_id VARCHAR(50)
AS
BEGIN
    UPDATE [subjects] SET [is_active] = 0 WHERE [subject_id] = @subject_id;
    SELECT '';
END;
GO

-- Get subject by ID
CREATE PROCEDURE [dbo].[sp_subject_get_by_id]
    @subject_id VARCHAR(50)
AS
BEGIN
    SELECT 
        [subject_id], [subject_code], [subject_name], [credits], 
        [description], [is_active], [created_date], [created_by]
    FROM [subjects]
    WHERE [subject_id] = @subject_id;
END;
GO

-- Search subjects
CREATE PROCEDURE [dbo].[sp_subject_search]
    @page_index INT,
    @page_size INT,
    @subject_code VARCHAR(20) = '',
    @subject_name NVARCHAR(200) = ''
AS
BEGIN
    DECLARE @RecordCount BIGINT;
    
    IF(@page_size <> 0)
    BEGIN
        SET NOCOUNT ON;
        SELECT(ROW_NUMBER() OVER(ORDER BY [subject_name] ASC)) AS RowNumber, 
               [subject_id], [subject_code], [subject_name], [credits], 
               [description], [is_active], [created_date], [created_by]
        INTO #Results1
        FROM [subjects]
        WHERE (@subject_code = '' OR [subject_code] LIKE '%' + @subject_code + '%')
          AND (@subject_name = '' OR [subject_name] LIKE '%' + @subject_name + '%')
          AND [is_active] = 1;
          
        SELECT @RecordCount = COUNT(*) FROM #Results1;
        
        SELECT *, @RecordCount AS RecordCount
        FROM #Results1
        WHERE RowNumber BETWEEN (@page_index - 1) * @page_size + 1 
                          AND ((@page_index - 1) * @page_size + 1) + @page_size - 1
              OR @page_index = -1;
        DROP TABLE #Results1;
    END
    ELSE
    BEGIN
        SET NOCOUNT ON;
        SELECT(ROW_NUMBER() OVER(ORDER BY [subject_name] ASC)) AS RowNumber, 
               [subject_id], [subject_code], [subject_name], [credits], 
               [description], [is_active], [created_date], [created_by]
        INTO #Results2
        FROM [subjects]
        WHERE (@subject_code = '' OR [subject_code] LIKE '%' + @subject_code + '%')
          AND (@subject_name = '' OR [subject_name] LIKE '%' + @subject_name + '%')
          AND [is_active] = 1;
          
        SELECT @RecordCount = COUNT(*) FROM #Results2;
        
        SELECT *, @RecordCount AS RecordCount
        FROM #Results2;
        DROP TABLE #Results2;
    END;
END;
GO

-- Get all subjects
CREATE PROCEDURE [dbo].[sp_subject_get_all]
AS
BEGIN
    SELECT 
        [subject_id], [subject_code], [subject_name], [credits], 
        [description], [is_active], [created_date], [created_by]
    FROM [subjects]
    WHERE [is_active] = 1
    ORDER BY [subject_name];
END;
GO

-- Check subject code exists
CREATE PROCEDURE [dbo].[sp_subject_check_code_exists]
    @subject_code VARCHAR(20),
    @exclude_id VARCHAR(50) = NULL
AS
BEGIN
    SELECT CASE WHEN EXISTS(
        SELECT 1 FROM [subjects] 
        WHERE [subject_code] = @subject_code 
          AND (@exclude_id IS NULL OR [subject_id] != @exclude_id)
    ) THEN 1 ELSE 0 END;
END;
GO

PRINT 'Stored procedures created successfully!';



