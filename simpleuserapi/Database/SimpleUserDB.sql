-- =============================================
-- Database: SimpleUserDB
-- Description: Database cho Simple User API
-- Created: 2025-09-20
-- =============================================

-- Tạo database
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'SimpleUserDB')
BEGIN
    CREATE DATABASE [SimpleUserDB]
    COLLATE SQL_Latin1_General_CP1_CI_AS
END
GO

USE [SimpleUserDB]
GO

-- =============================================
-- Tạo bảng Users
-- =============================================
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='users' AND xtype='U')
BEGIN
    CREATE TABLE [dbo].[users](
        [user_id] [int] IDENTITY(1,1) NOT NULL,
        [user_name] [nvarchar](50) NOT NULL,
        [password] [nvarchar](255) NOT NULL,
        [full_name] [nvarchar](100) NOT NULL,
        [email] [nvarchar](100) NULL,
        [phone] [nvarchar](20) NULL,
        [role] [nvarchar](20) NOT NULL DEFAULT('User'),
        [created_at] [datetime2](7) NOT NULL DEFAULT(GETUTCDATE()),
        [updated_at] [datetime2](7) NULL,
        [is_active] [bit] NOT NULL DEFAULT(1),
        CONSTRAINT [PK_users] PRIMARY KEY CLUSTERED ([user_id] ASC)
    )
END
GO

-- =============================================
-- Tạo Index cho bảng Users
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_users_user_name')
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX [IX_users_user_name] ON [dbo].[users]
    (
        [user_name] ASC
    )
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_users_email')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_users_email] ON [dbo].[users]
    (
        [email] ASC
    )
END
GO

-- =============================================
-- Insert dữ liệu mẫu
-- =============================================
IF NOT EXISTS (SELECT 1 FROM users WHERE user_name = 'admin')
BEGIN
    INSERT INTO [dbo].[users] ([user_name], [password], [full_name], [email], [phone], [role])
    VALUES 
    ('admin', 'admin123', 'Administrator', 'admin@example.com', '0123456789', 'Admin'),
    ('user1', 'user123', 'Nguyễn Văn A', 'user1@example.com', '0987654321', 'User'),
    ('user2', 'user123', 'Trần Thị B', 'user2@example.com', '0369852147', 'User'),
    ('manager1', 'manager123', 'Lê Văn C', 'manager1@example.com', '0147258369', 'Manager')
END
GO

-- =============================================
-- Tạo Stored Procedures
-- =============================================

-- SP: Get All Users
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetAllUsers')
    DROP PROCEDURE [dbo].[sp_GetAllUsers]
GO

CREATE PROCEDURE [dbo].[sp_GetAllUsers]
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        user_id,
        user_name,
        full_name,
        email,
        phone,
        role,
        created_at,
        updated_at,
        is_active
    FROM users 
    WHERE is_active = 1
    ORDER BY created_at DESC
END
GO

-- SP: Get User By ID
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetUserById')
    DROP PROCEDURE [dbo].[sp_GetUserById]
GO

CREATE PROCEDURE [dbo].[sp_GetUserById]
    @user_id INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        user_id,
        user_name,
        full_name,
        email,
        phone,
        role,
        created_at,
        updated_at,
        is_active
    FROM users 
    WHERE user_id = @user_id AND is_active = 1
END
GO

-- SP: Create User
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_CreateUser')
    DROP PROCEDURE [dbo].[sp_CreateUser]
GO

CREATE PROCEDURE [dbo].[sp_CreateUser]
    @user_name NVARCHAR(50),
    @password NVARCHAR(255),
    @full_name NVARCHAR(100),
    @email NVARCHAR(100) = NULL,
    @phone NVARCHAR(20) = NULL,
    @role NVARCHAR(20) = 'User'
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if username already exists
    IF EXISTS (SELECT 1 FROM users WHERE user_name = @user_name)
    BEGIN
        RAISERROR('Tên đăng nhập đã tồn tại', 16, 1)
        RETURN
    END
    
    INSERT INTO [dbo].[users] ([user_name], [password], [full_name], [email], [phone], [role])
    VALUES (@user_name, @password, @full_name, @email, @phone, @role)
    
    SELECT SCOPE_IDENTITY() AS user_id
END
GO

-- SP: Update User
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_UpdateUser')
    DROP PROCEDURE [dbo].[sp_UpdateUser]
GO

CREATE PROCEDURE [dbo].[sp_UpdateUser]
    @user_id INT,
    @user_name NVARCHAR(50),
    @password NVARCHAR(255),
    @full_name NVARCHAR(100),
    @email NVARCHAR(100) = NULL,
    @phone NVARCHAR(20) = NULL,
    @role NVARCHAR(20) = 'User'
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if user exists
    IF NOT EXISTS (SELECT 1 FROM users WHERE user_id = @user_id AND is_active = 1)
    BEGIN
        RAISERROR('Không tìm thấy user', 16, 1)
        RETURN
    END
    
    -- Check if username already exists (excluding current user)
    IF EXISTS (SELECT 1 FROM users WHERE user_name = @user_name AND user_id != @user_id)
    BEGIN
        RAISERROR('Tên đăng nhập đã tồn tại', 16, 1)
        RETURN
    END
    
    UPDATE [dbo].[users]
    SET 
        user_name = @user_name,
        password = @password,
        full_name = @full_name,
        email = @email,
        phone = @phone,
        role = @role,
        updated_at = GETUTCDATE()
    WHERE user_id = @user_id
    
    SELECT @user_id AS user_id
END
GO

-- SP: Delete User (Soft Delete)
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_DeleteUser')
    DROP PROCEDURE [dbo].[sp_DeleteUser]
GO

CREATE PROCEDURE [dbo].[sp_DeleteUser]
    @user_id INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if user exists
    IF NOT EXISTS (SELECT 1 FROM users WHERE user_id = @user_id AND is_active = 1)
    BEGIN
        RAISERROR('Không tìm thấy user', 16, 1)
        RETURN
    END
    
    -- Soft delete
    UPDATE [dbo].[users]
    SET 
        is_active = 0,
        updated_at = GETUTCDATE()
    WHERE user_id = @user_id
    
    SELECT @user_id AS user_id
END
GO

-- SP: Search Users
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_SearchUsers')
    DROP PROCEDURE [dbo].[sp_SearchUsers]
GO

CREATE PROCEDURE [dbo].[sp_SearchUsers]
    @search_term NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        user_id,
        user_name,
        full_name,
        email,
        phone,
        role,
        created_at,
        updated_at,
        is_active
    FROM users 
    WHERE is_active = 1
    AND (
        @search_term IS NULL 
        OR full_name LIKE '%' + @search_term + '%'
        OR user_name LIKE '%' + @search_term + '%'
        OR email LIKE '%' + @search_term + '%'
    )
    ORDER BY created_at DESC
END
GO

-- =============================================
-- Tạo Views
-- =============================================

-- View: Active Users
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_ActiveUsers')
    DROP VIEW [dbo].[vw_ActiveUsers]
GO

CREATE VIEW [dbo].[vw_ActiveUsers]
AS
SELECT 
    user_id,
    user_name,
    full_name,
    email,
    phone,
    role,
    created_at,
    updated_at
FROM users 
WHERE is_active = 1
GO

-- =============================================
-- Tạo Functions
-- =============================================

-- Function: Check User Exists
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'FN' AND name = 'fn_UserExists')
    DROP FUNCTION [dbo].[fn_UserExists]
GO

CREATE FUNCTION [dbo].[fn_UserExists](@user_name NVARCHAR(50))
RETURNS BIT
AS
BEGIN
    DECLARE @exists BIT = 0
    
    IF EXISTS (SELECT 1 FROM users WHERE user_name = @user_name AND is_active = 1)
        SET @exists = 1
    
    RETURN @exists
END
GO

-- =============================================
-- Tạo Triggers
-- =============================================

-- Trigger: Update updated_at when user is modified
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'tr_users_updated_at')
    DROP TRIGGER [dbo].[tr_users_updated_at]
GO

CREATE TRIGGER [dbo].[tr_users_updated_at]
ON [dbo].[users]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE u
    SET updated_at = GETUTCDATE()
    FROM users u
    INNER JOIN inserted i ON u.user_id = i.user_id
END
GO

-- =============================================
-- Tạo User và Permissions (Optional)
-- =============================================

-- Tạo user cho ứng dụng (uncomment nếu cần)
/*
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'simpleuser_app')
BEGIN
    CREATE LOGIN [simpleuser_app] WITH PASSWORD = 'YourPassword123!'
END

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'simpleuser_app')
BEGIN
    CREATE USER [simpleuser_app] FOR LOGIN [simpleuser_app]
END

-- Grant permissions
ALTER ROLE [db_datareader] ADD MEMBER [simpleuser_app]
ALTER ROLE [db_datawriter] ADD MEMBER [simpleuser_app]
GRANT EXECUTE ON SCHEMA::[dbo] TO [simpleuser_app]
*/

-- =============================================
-- Kiểm tra dữ liệu
-- =============================================
PRINT 'Database SimpleUserDB đã được tạo thành công!'
DECLARE @userCount INT;
SELECT @userCount = COUNT(*) FROM users;
PRINT 'Số lượng users: ' + CAST(@userCount AS NVARCHAR(10));
PRINT 'Users mẫu:';
SELECT user_id, user_name, full_name, role FROM users WHERE is_active = 1;

GO


