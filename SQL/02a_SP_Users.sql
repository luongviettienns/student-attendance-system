-- ===========================================
-- 02a_SP_Users.sql
-- ===========================================
-- Description: Users Management SPs
-- Generated from: SQL/02_StoredProcedures.sql
-- ===========================================

USE EducationManagement;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

PRINT '========================================';
PRINT 'Starting: 02a_SP_Users.sql';
PRINT '========================================';
GO

-- ===========================================
-- 1. USERS MANAGEMENT
-- ===========================================

IF OBJECT_ID('sp_GetAllUsers', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllUsers;
GO
CREATE PROCEDURE sp_GetAllUsers
    @Page INT = 1,
    @PageSize INT = 10,
    @Search NVARCHAR(255) = NULL,
    @RoleId VARCHAR(50) = NULL,
    @IsActive BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Offset INT = (@Page - 1) * @PageSize;
    
    SELECT COUNT(*) as TotalCount
    FROM dbo.users u
    LEFT JOIN dbo.roles r ON u.role_id = r.role_id AND r.deleted_at IS NULL
    WHERE u.deleted_at IS NULL
        AND (@Search IS NULL OR u.username LIKE '%' + @Search + '%' 
             OR u.full_name LIKE '%' + @Search + '%' OR u.email LIKE '%' + @Search + '%')
        AND (@RoleId IS NULL OR u.role_id = @RoleId)
        AND (@IsActive IS NULL OR u.is_active = @IsActive);
    
    SELECT u.user_id, u.username, u.full_name, u.email, u.phone, u.role_id,
           ISNULL(r.role_name, 'No Role') as role_name, u.avatar_url, u.is_active,
           u.last_login_at, u.created_at, u.created_by, u.updated_at, u.updated_by
    FROM dbo.users u
    LEFT JOIN dbo.roles r ON u.role_id = r.role_id AND r.deleted_at IS NULL
    WHERE u.deleted_at IS NULL
        AND (@Search IS NULL OR u.username LIKE '%' + @Search + '%' 
             OR u.full_name LIKE '%' + @Search + '%' OR u.email LIKE '%' + @Search + '%')
        AND (@RoleId IS NULL OR u.role_id = @RoleId)
        AND (@IsActive IS NULL OR u.is_active = @IsActive)
    ORDER BY u.created_at DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END
GO

IF OBJECT_ID('sp_GetUserById', 'P') IS NOT NULL DROP PROCEDURE sp_GetUserById;
GO
CREATE PROCEDURE sp_GetUserById
    @UserId VARCHAR(50)
AS
BEGIN
    SELECT u.user_id, u.username, u.full_name, u.email, u.phone, u.role_id,
           r.role_name, u.avatar_url, u.is_active, u.last_login_at,
           u.created_at, u.created_by, u.updated_at, u.updated_by
    FROM dbo.users u
    LEFT JOIN dbo.roles r ON u.role_id = r.role_id
    WHERE u.user_id = @UserId AND u.deleted_at IS NULL;
END
GO

IF OBJECT_ID('sp_GetUserByUsername', 'P') IS NOT NULL DROP PROCEDURE sp_GetUserByUsername;
GO
CREATE PROCEDURE sp_GetUserByUsername
    @Username VARCHAR(50)
AS
BEGIN
    SELECT u.user_id, u.username, u.password_hash, u.full_name, u.email, 
           u.phone, u.role_id, r.role_name, u.avatar_url, u.is_active, u.last_login_at
    FROM dbo.users u
    LEFT JOIN dbo.roles r ON u.role_id = r.role_id
    WHERE u.username = @Username AND u.deleted_at IS NULL;
END
GO

IF OBJECT_ID('sp_CreateUser', 'P') IS NOT NULL DROP PROCEDURE sp_CreateUser;
GO
CREATE PROCEDURE sp_CreateUser
    @UserId VARCHAR(50),
    @Username VARCHAR(50),
    @PasswordHash VARCHAR(255),
    @Email VARCHAR(150),
    @Phone VARCHAR(20) = NULL,
    @FullName NVARCHAR(150),
    @RoleId VARCHAR(50),
    @IsActive BIT = 1,
    @AvatarUrl VARCHAR(300) = NULL,
    @CreatedBy VARCHAR(50) = 'system'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validation: Check duplicate username
        IF EXISTS (SELECT 1 FROM users WHERE username = @Username AND deleted_at IS NULL)
        BEGIN
            RAISERROR(N'Username already exists: %s', 16, 1, @Username);
            RETURN;
        END
        
        -- Validation: Check duplicate email
        IF EXISTS (SELECT 1 FROM users WHERE email = @Email AND deleted_at IS NULL)
        BEGIN
            RAISERROR(N'Email already exists: %s', 16, 1, @Email);
            RETURN;
        END
        
        -- Validation: Check role exists
        IF NOT EXISTS (SELECT 1 FROM roles WHERE role_id = @RoleId AND deleted_at IS NULL)
        BEGIN
            RAISERROR(N'Role does not exist: %s', 16, 1, @RoleId);
            RETURN;
        END
        
        -- Insert
        INSERT INTO dbo.users (user_id, username, password_hash, email, phone, full_name, 
                               role_id, is_active, avatar_url, created_at, created_by)
        VALUES (@UserId, @Username, @PasswordHash, @Email, @Phone, @FullName, 
                @RoleId, @IsActive, @AvatarUrl, GETDATE(), @CreatedBy);
        
        COMMIT TRANSACTION;
        SELECT @UserId AS user_id;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

IF OBJECT_ID('sp_UpdateUser', 'P') IS NOT NULL DROP PROCEDURE sp_UpdateUser;
GO
CREATE PROCEDURE sp_UpdateUser
    @UserId VARCHAR(50),
    @FullName NVARCHAR(150),
    @Email VARCHAR(150),
    @Phone VARCHAR(20) = NULL,
    @RoleId VARCHAR(50),
    @IsActive BIT,
    @AvatarUrl VARCHAR(300) = NULL,
    @UpdatedBy VARCHAR(50) = 'system'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validation: Check user exists
        IF NOT EXISTS (SELECT 1 FROM users WHERE user_id = @UserId AND deleted_at IS NULL)
        BEGIN
            RAISERROR(N'User does not exist: %s', 16, 1, @UserId);
            RETURN;
        END
        
        -- Validation: Check duplicate email (except current user)
        IF EXISTS (SELECT 1 FROM users WHERE email = @Email AND user_id != @UserId AND deleted_at IS NULL)
        BEGIN
            RAISERROR(N'Email Ä‘Ă£ Ä‘Æ°á»£c sá»­ dá»¥ng bá»Ÿi user khĂ¡c: %s', 16, 1, @Email);
            RETURN;
        END
        
        -- Validation: Check role exists
        IF NOT EXISTS (SELECT 1 FROM roles WHERE role_id = @RoleId AND deleted_at IS NULL)
        BEGIN
            RAISERROR(N'Role does not exist: %s', 16, 1, @RoleId);
            RETURN;
        END
        
        -- Update
        UPDATE dbo.users
        SET full_name = @FullName, email = @Email, phone = @Phone, role_id = @RoleId,
            is_active = @IsActive, avatar_url = ISNULL(@AvatarUrl, avatar_url),
            updated_at = GETDATE(), updated_by = @UpdatedBy
        WHERE user_id = @UserId AND deleted_at IS NULL;
        
        COMMIT TRANSACTION;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

IF OBJECT_ID('sp_DeleteUser', 'P') IS NOT NULL DROP PROCEDURE sp_DeleteUser;
GO
CREATE PROCEDURE sp_DeleteUser
    @UserId VARCHAR(50),
    @DeletedBy VARCHAR(50) = 'system'
AS
BEGIN
    UPDATE dbo.users
    SET deleted_at = GETDATE(), deleted_by = @DeletedBy
    WHERE user_id = @UserId;
END
GO

IF OBJECT_ID('sp_UpdateLastLogin', 'P') IS NOT NULL DROP PROCEDURE sp_UpdateLastLogin;
GO
CREATE PROCEDURE sp_UpdateLastLogin
    @UserId VARCHAR(50)
AS
BEGIN
    UPDATE dbo.users
    SET last_login_at = GETDATE()
    WHERE user_id = @UserId;
END
GO

-- SP: Toggle User Status
IF OBJECT_ID('sp_ToggleUserStatus', 'P') IS NOT NULL DROP PROCEDURE sp_ToggleUserStatus;
GO
CREATE PROCEDURE sp_ToggleUserStatus
    @UserId VARCHAR(50),
    @UpdatedBy VARCHAR(50) = 'system'
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @NewStatus BIT;
    
    -- Get current status and toggle
    SELECT @NewStatus = CASE WHEN is_active = 1 THEN 0 ELSE 1 END
    FROM dbo.users
    WHERE user_id = @UserId AND deleted_at IS NULL;
    
    IF @NewStatus IS NULL
    BEGIN
        RAISERROR(N'User does not exist: %s', 16, 1, @UserId);
        RETURN;
    END
    
    -- Update status
    UPDATE dbo.users
    SET is_active = @NewStatus,
        updated_at = GETDATE(),
        updated_by = @UpdatedBy
    WHERE user_id = @UserId;
    
    -- Return new status
    SELECT @NewStatus AS is_active;
END
GO

PRINT '[OK] Users Management SPs created';
GO

PRINT '[OK] Users Management SPs completed';
GO
