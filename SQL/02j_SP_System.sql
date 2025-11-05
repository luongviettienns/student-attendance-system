-- ===========================================
-- 02j_SP_System.sql
-- ===========================================
-- Description: Roles Management SPs, Notifications Management SPs, Audit Logs Management SPs
-- Generated from: SQL/02_StoredProcedures.sql
-- ===========================================

USE EducationManagement;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

PRINT '========================================';
PRINT 'Starting: 02j_SP_System.sql';
PRINT '========================================';
GO

-- ===========================================
-- 13. ROLES MANAGEMENT
-- ===========================================

IF OBJECT_ID('sp_GetAllRoles', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllRoles;
GO
CREATE PROCEDURE sp_GetAllRoles
AS
BEGIN
    SELECT role_id, role_name, description, is_active, created_at
    FROM dbo.roles
    WHERE deleted_at IS NULL
    ORDER BY role_name;
END
GO

IF OBJECT_ID('sp_GetRoleById', 'P') IS NOT NULL DROP PROCEDURE sp_GetRoleById;
GO
CREATE PROCEDURE sp_GetRoleById
    @RoleId VARCHAR(50)
AS
BEGIN
    SELECT * FROM dbo.roles
    WHERE role_id = @RoleId AND deleted_at IS NULL;
END
GO

PRINT '[OK] Roles Management SPs created';
GO

-- ===========================================
-- 14. NOTIFICATIONS MANAGEMENT
-- ===========================================

IF OBJECT_ID('sp_GetNotificationsByUser', 'P') IS NOT NULL DROP PROCEDURE sp_GetNotificationsByUser;
GO
CREATE PROCEDURE sp_GetNotificationsByUser
    @UserId VARCHAR(50)
AS
BEGIN
    SELECT * FROM dbo.notifications
    WHERE user_id = @UserId
    ORDER BY created_at DESC;
END
GO

IF OBJECT_ID('sp_MarkNotificationAsRead', 'P') IS NOT NULL DROP PROCEDURE sp_MarkNotificationAsRead;
GO
CREATE PROCEDURE sp_MarkNotificationAsRead
    @NotificationId VARCHAR(50)
AS
BEGIN
    UPDATE dbo.notifications
    SET is_read = 1
    WHERE notification_id = @NotificationId;
END
GO

PRINT '[OK] Notifications Management SPs created';
GO

-- ===========================================
-- 15. AUDIT LOGS MANAGEMENT
-- ===========================================

IF OBJECT_ID('sp_GetAllAuditLogs', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllAuditLogs;
GO
CREATE PROCEDURE sp_GetAllAuditLogs
    @Page INT = 1,
    @PageSize INT = 25,
    @Search NVARCHAR(255) = NULL,
    @Action VARCHAR(50) = NULL,
    @EntityType VARCHAR(100) = NULL,
    @UserId VARCHAR(50) = NULL,
    @FromDate DATETIME = NULL,
    @ToDate DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Offset INT = (@Page - 1) * @PageSize;
    
    -- Tráº£ vá» TotalCount
    SELECT COUNT(*) as TotalCount
    FROM dbo.audit_logs al
    LEFT JOIN dbo.users u ON al.user_id = u.user_id
    WHERE (@Search IS NULL OR u.full_name LIKE '%' + @Search + '%' 
           OR u.username LIKE '%' + @Search + '%'
           OR al.entity_type LIKE '%' + @Search + '%'
           OR al.action LIKE '%' + @Search + '%')
        AND (@Action IS NULL OR al.action = @Action)
        AND (@EntityType IS NULL OR al.entity_type = @EntityType)
        AND (@UserId IS NULL OR al.user_id = @UserId)
        AND (@FromDate IS NULL OR al.created_at >= @FromDate)
        AND (@ToDate IS NULL OR al.created_at <= @ToDate);
    
    -- Tráº£ vá» Data vá»›i pagination
    SELECT 
        al.log_id,
        al.user_id,
        ISNULL(u.username, 'System') as user_name,
        ISNULL(u.full_name, 'System') as user_full_name,
        al.action,
        al.entity_type,
        al.entity_id,
        al.old_values,
        al.new_values,
        al.ip_address,
        al.user_agent,
        al.created_at
    FROM dbo.audit_logs al
    LEFT JOIN dbo.users u ON al.user_id = u.user_id
    WHERE (@Search IS NULL OR u.full_name LIKE '%' + @Search + '%' 
           OR u.username LIKE '%' + @Search + '%'
           OR al.entity_type LIKE '%' + @Search + '%'
           OR al.action LIKE '%' + @Search + '%')
        AND (@Action IS NULL OR al.action = @Action)
        AND (@EntityType IS NULL OR al.entity_type = @EntityType)
        AND (@UserId IS NULL OR al.user_id = @UserId)
        AND (@FromDate IS NULL OR al.created_at >= @FromDate)
        AND (@ToDate IS NULL OR al.created_at <= @ToDate)
    ORDER BY al.created_at DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END
GO

IF OBJECT_ID('sp_GetAuditLogById', 'P') IS NOT NULL DROP PROCEDURE sp_GetAuditLogById;
GO
CREATE PROCEDURE sp_GetAuditLogById
    @LogId BIGINT
AS
BEGIN
    SELECT 
        al.log_id,
        al.user_id,
        ISNULL(u.username, 'System') as user_name,
        ISNULL(u.full_name, 'System') as user_full_name,
        al.action,
        al.entity_type,
        al.entity_id,
        al.old_values,
        al.new_values,
        al.ip_address,
        al.user_agent,
        al.created_at
    FROM dbo.audit_logs al
    LEFT JOIN dbo.users u ON al.user_id = u.user_id
    WHERE al.log_id = @LogId;
END
GO

IF OBJECT_ID('sp_GetAuditLogsByUser', 'P') IS NOT NULL DROP PROCEDURE sp_GetAuditLogsByUser;
GO
CREATE PROCEDURE sp_GetAuditLogsByUser
    @UserId VARCHAR(50),
    @Page INT = 1,
    @PageSize INT = 25
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Offset INT = (@Page - 1) * @PageSize;
    
    SELECT COUNT(*) as TotalCount
    FROM dbo.audit_logs
    WHERE user_id = @UserId;
    
    SELECT 
        al.log_id,
        al.user_id,
        u.username as user_name,
        u.full_name as user_full_name,
        al.action,
        al.entity_type,
        al.entity_id,
        al.old_values,
        al.new_values,
        al.ip_address,
        al.user_agent,
        al.created_at
    FROM dbo.audit_logs al
    LEFT JOIN dbo.users u ON al.user_id = u.user_id
    WHERE al.user_id = @UserId
    ORDER BY al.created_at DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END
GO

IF OBJECT_ID('sp_GetAuditLogsByEntity', 'P') IS NOT NULL DROP PROCEDURE sp_GetAuditLogsByEntity;
GO
CREATE PROCEDURE sp_GetAuditLogsByEntity
    @EntityType VARCHAR(100),
    @EntityId VARCHAR(50),
    @Page INT = 1,
    @PageSize INT = 25
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Offset INT = (@Page - 1) * @PageSize;
    
    SELECT COUNT(*) as TotalCount
    FROM dbo.audit_logs
    WHERE entity_type = @EntityType AND entity_id = @EntityId;
    
    SELECT 
        al.log_id,
        al.user_id,
        ISNULL(u.username, 'System') as user_name,
        ISNULL(u.full_name, 'System') as user_full_name,
        al.action,
        al.entity_type,
        al.entity_id,
        al.old_values,
        al.new_values,
        al.ip_address,
        al.user_agent,
        al.created_at
    FROM dbo.audit_logs al
    LEFT JOIN dbo.users u ON al.user_id = u.user_id
    WHERE al.entity_type = @EntityType AND al.entity_id = @EntityId
    ORDER BY al.created_at DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END
GO

IF OBJECT_ID('sp_CreateAuditLog', 'P') IS NOT NULL DROP PROCEDURE sp_CreateAuditLog;
GO
CREATE PROCEDURE sp_CreateAuditLog
    @UserId VARCHAR(50) = NULL,
    @Action VARCHAR(50),
    @EntityType VARCHAR(100),
    @EntityId VARCHAR(50) = NULL,
    @OldValues NVARCHAR(MAX) = NULL,
    @NewValues NVARCHAR(MAX) = NULL,
    @IpAddress VARCHAR(50) = NULL,
    @UserAgent VARCHAR(500) = NULL
AS
BEGIN
    INSERT INTO dbo.audit_logs (user_id, action, entity_type, entity_id, 
                                 old_values, new_values, ip_address, user_agent, created_at)
    VALUES (@UserId, @Action, @EntityType, @EntityId, 
            @OldValues, @NewValues, @IpAddress, @UserAgent, GETDATE());
    
    SELECT SCOPE_IDENTITY() AS log_id;
END
GO

PRINT '[OK] Audit Logs Management SPs created';
GO

-- ===========================================
-- 13. ROLES MANAGEMENT
-- ===========================================

IF OBJECT_ID('sp_GetAllRoles', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllRoles;
GO
CREATE PROCEDURE sp_GetAllRoles
AS
BEGIN
    SELECT role_id, role_name, description, is_active, created_at
    FROM dbo.roles
    WHERE deleted_at IS NULL
    ORDER BY role_name;
END
GO

IF OBJECT_ID('sp_GetRoleById', 'P') IS NOT NULL DROP PROCEDURE sp_GetRoleById;
GO
CREATE PROCEDURE sp_GetRoleById
    @RoleId VARCHAR(50)
AS
BEGIN
    SELECT * FROM dbo.roles
    WHERE role_id = @RoleId AND deleted_at IS NULL;
END
GO

PRINT '[OK] Roles Management SPs created';
GO

-- ===========================================
-- 14. NOTIFICATIONS MANAGEMENT
-- ===========================================

IF OBJECT_ID('sp_GetNotificationsByUser', 'P') IS NOT NULL DROP PROCEDURE sp_GetNotificationsByUser;
GO
CREATE PROCEDURE sp_GetNotificationsByUser
    @UserId VARCHAR(50)
AS
BEGIN
    SELECT * FROM dbo.notifications
    WHERE user_id = @UserId
    ORDER BY created_at DESC;
END
GO

IF OBJECT_ID('sp_MarkNotificationAsRead', 'P') IS NOT NULL DROP PROCEDURE sp_MarkNotificationAsRead;
GO
CREATE PROCEDURE sp_MarkNotificationAsRead
    @NotificationId VARCHAR(50)
AS
BEGIN
    UPDATE dbo.notifications
    SET is_read = 1
    WHERE notification_id = @NotificationId;
END
GO

PRINT '[OK] Notifications Management SPs created';
GO

-- ===========================================
-- 15. AUDIT LOGS MANAGEMENT
-- ===========================================

IF OBJECT_ID('sp_GetAllAuditLogs', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllAuditLogs;
GO
CREATE PROCEDURE sp_GetAllAuditLogs
    @Page INT = 1,
    @PageSize INT = 25,
    @Search NVARCHAR(255) = NULL,
    @Action VARCHAR(50) = NULL,
    @EntityType VARCHAR(100) = NULL,
    @UserId VARCHAR(50) = NULL,
    @FromDate DATETIME = NULL,
    @ToDate DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Offset INT = (@Page - 1) * @PageSize;
    
    -- Tráº£ vá» TotalCount
    SELECT COUNT(*) as TotalCount
    FROM dbo.audit_logs al
    LEFT JOIN dbo.users u ON al.user_id = u.user_id
    WHERE (@Search IS NULL OR u.full_name LIKE '%' + @Search + '%' 
           OR u.username LIKE '%' + @Search + '%'
           OR al.entity_type LIKE '%' + @Search + '%'
           OR al.action LIKE '%' + @Search + '%')
        AND (@Action IS NULL OR al.action = @Action)
        AND (@EntityType IS NULL OR al.entity_type = @EntityType)
        AND (@UserId IS NULL OR al.user_id = @UserId)
        AND (@FromDate IS NULL OR al.created_at >= @FromDate)
        AND (@ToDate IS NULL OR al.created_at <= @ToDate);
    
    -- Tráº£ vá» Data vá»›i pagination
    SELECT 
        al.log_id,
        al.user_id,
        ISNULL(u.username, 'System') as user_name,
        ISNULL(u.full_name, 'System') as user_full_name,
        al.action,
        al.entity_type,
        al.entity_id,
        al.old_values,
        al.new_values,
        al.ip_address,
        al.user_agent,
        al.created_at
    FROM dbo.audit_logs al
    LEFT JOIN dbo.users u ON al.user_id = u.user_id
    WHERE (@Search IS NULL OR u.full_name LIKE '%' + @Search + '%' 
           OR u.username LIKE '%' + @Search + '%'
           OR al.entity_type LIKE '%' + @Search + '%'
           OR al.action LIKE '%' + @Search + '%')
        AND (@Action IS NULL OR al.action = @Action)
        AND (@EntityType IS NULL OR al.entity_type = @EntityType)
        AND (@UserId IS NULL OR al.user_id = @UserId)
        AND (@FromDate IS NULL OR al.created_at >= @FromDate)
        AND (@ToDate IS NULL OR al.created_at <= @ToDate)
    ORDER BY al.created_at DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END
GO

IF OBJECT_ID('sp_GetAuditLogById', 'P') IS NOT NULL DROP PROCEDURE sp_GetAuditLogById;
GO
CREATE PROCEDURE sp_GetAuditLogById
    @LogId BIGINT
AS
BEGIN
    SELECT 
        al.log_id,
        al.user_id,
        ISNULL(u.username, 'System') as user_name,
        ISNULL(u.full_name, 'System') as user_full_name,
        al.action,
        al.entity_type,
        al.entity_id,
        al.old_values,
        al.new_values,
        al.ip_address,
        al.user_agent,
        al.created_at
    FROM dbo.audit_logs al
    LEFT JOIN dbo.users u ON al.user_id = u.user_id
    WHERE al.log_id = @LogId;
END
GO

IF OBJECT_ID('sp_GetAuditLogsByUser', 'P') IS NOT NULL DROP PROCEDURE sp_GetAuditLogsByUser;
GO
CREATE PROCEDURE sp_GetAuditLogsByUser
    @UserId VARCHAR(50),
    @Page INT = 1,
    @PageSize INT = 25
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Offset INT = (@Page - 1) * @PageSize;
    
    SELECT COUNT(*) as TotalCount
    FROM dbo.audit_logs
    WHERE user_id = @UserId;
    
    SELECT 
        al.log_id,
        al.user_id,
        u.username as user_name,
        u.full_name as user_full_name,
        al.action,
        al.entity_type,
        al.entity_id,
        al.old_values,
        al.new_values,
        al.ip_address,
        al.user_agent,
        al.created_at
    FROM dbo.audit_logs al
    LEFT JOIN dbo.users u ON al.user_id = u.user_id
    WHERE al.user_id = @UserId
    ORDER BY al.created_at DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END
GO

IF OBJECT_ID('sp_GetAuditLogsByEntity', 'P') IS NOT NULL DROP PROCEDURE sp_GetAuditLogsByEntity;
GO
CREATE PROCEDURE sp_GetAuditLogsByEntity
    @EntityType VARCHAR(100),
    @EntityId VARCHAR(50),
    @Page INT = 1,
    @PageSize INT = 25
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Offset INT = (@Page - 1) * @PageSize;
    
    SELECT COUNT(*) as TotalCount
    FROM dbo.audit_logs
    WHERE entity_type = @EntityType AND entity_id = @EntityId;
    
    SELECT 
        al.log_id,
        al.user_id,
        ISNULL(u.username, 'System') as user_name,
        ISNULL(u.full_name, 'System') as user_full_name,
        al.action,
        al.entity_type,
        al.entity_id,
        al.old_values,
        al.new_values,
        al.ip_address,
        al.user_agent,
        al.created_at
    FROM dbo.audit_logs al
    LEFT JOIN dbo.users u ON al.user_id = u.user_id
    WHERE al.entity_type = @EntityType AND al.entity_id = @EntityId
    ORDER BY al.created_at DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END
GO

IF OBJECT_ID('sp_CreateAuditLog', 'P') IS NOT NULL DROP PROCEDURE sp_CreateAuditLog;
GO
CREATE PROCEDURE sp_CreateAuditLog
    @UserId VARCHAR(50) = NULL,
    @Action VARCHAR(50),
    @EntityType VARCHAR(100),
    @EntityId VARCHAR(50) = NULL,
    @OldValues NVARCHAR(MAX) = NULL,
    @NewValues NVARCHAR(MAX) = NULL,
    @IpAddress VARCHAR(50) = NULL,
    @UserAgent VARCHAR(500) = NULL
AS
BEGIN
    INSERT INTO dbo.audit_logs (user_id, action, entity_type, entity_id, 
                                 old_values, new_values, ip_address, user_agent, created_at)
    VALUES (@UserId, @Action, @EntityType, @EntityId, 
            @OldValues, @NewValues, @IpAddress, @UserAgent, GETDATE());
    
    SELECT SCOPE_IDENTITY() AS log_id;
END
GO

PRINT '[OK] Audit Logs Management SPs created';
GO

PRINT '[OK] Roles Management SPs, Notifications Management SPs, Audit Logs Management SPs completed';
GO


-- ===========================================
-- 16. REFRESH TOKENS MANAGEMENT
-- ===========================================

-- ===========================================
PRINT '';
PRINT 'đŸ” Báº¯t Ä‘áº§u táº¡o Stored Procedures cho REFRESH TOKENS...';
PRINT '';

-- SP 1: Save Refresh Token
IF OBJECT_ID('sp_SaveRefreshToken', 'P') IS NOT NULL DROP PROCEDURE sp_SaveRefreshToken;
GO
CREATE PROCEDURE sp_SaveRefreshToken
    @Id UNIQUEIDENTIFIER,
    @UserId VARCHAR(50),
    @Token VARCHAR(500),
    @ExpiresAt DATETIME,
    @CreatedAt DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if user exists
        IF NOT EXISTS (SELECT 1 FROM dbo.users WHERE user_id = @UserId AND deleted_at IS NULL)
        BEGIN
            RAISERROR(N'User does not exist: %s', 16, 1, @UserId);
            RETURN;
        END
        
        -- Insert new refresh token
        INSERT INTO dbo.refresh_tokens (id, user_id, token, expires_at, created_at)
        VALUES (@Id, @UserId, @Token, @ExpiresAt, @CreatedAt);
        
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
PRINT 'âœ… Táº¡o sp_SaveRefreshToken';
GO

-- SP 2: Get Refresh Token by Token String
IF OBJECT_ID('sp_GetRefreshTokenByToken', 'P') IS NOT NULL DROP PROCEDURE sp_GetRefreshTokenByToken;
GO
CREATE PROCEDURE sp_GetRefreshTokenByToken
    @Token VARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT 
            id,
            user_id,
            token,
            expires_at,
            created_at,
            revoked_at,
            replaced_by_token
        FROM dbo.refresh_tokens
        WHERE token = @Token;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO
PRINT 'âœ… Táº¡o sp_GetRefreshTokenByToken';
GO

-- SP 3: Revoke Refresh Token
IF OBJECT_ID('sp_RevokeRefreshToken', 'P') IS NOT NULL DROP PROCEDURE sp_RevokeRefreshToken;
GO
CREATE PROCEDURE sp_RevokeRefreshToken
    @Id UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE dbo.refresh_tokens
        SET revoked_at = GETDATE()
        WHERE id = @Id;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO
PRINT 'âœ… Táº¡o sp_RevokeRefreshToken';
GO

-- SP 4: Clean Expired Tokens (Maintenance Job)
IF OBJECT_ID('sp_CleanExpiredRefreshTokens', 'P') IS NOT NULL DROP PROCEDURE sp_CleanExpiredRefreshTokens;
GO
CREATE PROCEDURE sp_CleanExpiredRefreshTokens
    @DaysToKeep INT = 30
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @CutoffDate DATETIME = DATEADD(DAY, -@DaysToKeep, GETDATE());
        DECLARE @DeletedCount INT;
        
        BEGIN TRANSACTION;
        
        DELETE FROM dbo.refresh_tokens
        WHERE (expires_at < GETDATE() OR revoked_at IS NOT NULL)
            AND created_at < @CutoffDate;
        
        SET @DeletedCount = @@ROWCOUNT;
        
        COMMIT TRANSACTION;
        
        PRINT CONCAT('âœ… Cleaned ', @DeletedCount, ' expired/revoked refresh tokens');
        SELECT @DeletedCount AS DeletedCount;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO
PRINT 'âœ… Táº¡o sp_CleanExpiredRefreshTokens';
GO

-- SP 5: Revoke All User Tokens (Logout from all devices)
IF OBJECT_ID('sp_RevokeAllUserTokens', 'P') IS NOT NULL DROP PROCEDURE sp_RevokeAllUserTokens;
GO
CREATE PROCEDURE sp_RevokeAllUserTokens
    @UserId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        UPDATE dbo.refresh_tokens
        SET revoked_at = GETDATE()
        WHERE user_id = @UserId
            AND revoked_at IS NULL;
        
        DECLARE @RevokedCount INT = @@ROWCOUNT;
        
        COMMIT TRANSACTION;
        
        SELECT @RevokedCount AS RevokedCount;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO
PRINT 'âœ… Táº¡o sp_RevokeAllUserTokens';
GO

PRINT 'âœ… Refresh Tokens Management SPs created (5 procedures)';
GO


-- ===========================================
-- PERMISSIONS MANAGEMENT
-- ===========================================
PRINT '';
PRINT 'đŸ” Báº¯t Ä‘áº§u táº¡o Stored Procedures cho PERMISSIONS...';
PRINT '';

-- SP 1: Get All Permissions
IF OBJECT_ID('sp_GetAllPermissions', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllPermissions;
GO
CREATE PROCEDURE sp_GetAllPermissions
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        permission_id,
        permission_code,
        permission_name,
        description,
        created_at,
        created_by,
        updated_at,
        updated_by
    FROM dbo.permissions
    ORDER BY permission_code;
END
GO
PRINT 'âœ“ Táº¡o sp_GetAllPermissions';
GO

-- SP 2: Get Permissions by Role
IF OBJECT_ID('sp_GetPermissionsByRole', 'P') IS NOT NULL DROP PROCEDURE sp_GetPermissionsByRole;
GO
CREATE PROCEDURE sp_GetPermissionsByRole
    @RoleId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        p.permission_id,
        p.permission_code,
        p.permission_name,
        p.description,
        CASE WHEN rp.permission_id IS NOT NULL THEN 1 ELSE 0 END AS is_assigned
    FROM dbo.permissions p
    LEFT JOIN dbo.role_permissions rp 
        ON p.permission_id = rp.permission_id 
        AND rp.role_id = @RoleId
    ORDER BY p.permission_code;
END
GO
PRINT 'âœ“ Táº¡o sp_GetPermissionsByRole';
GO

-- SP 2.5: Get Permissions by Role Name (for Menu API)
IF OBJECT_ID('sp_GetPermissionsByRoleName', 'P') IS NOT NULL DROP PROCEDURE sp_GetPermissionsByRoleName;
GO
CREATE PROCEDURE sp_GetPermissionsByRoleName
    @RoleName NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Join roles -> role_permissions -> permissions
    SELECT 
        p.permission_id,
        p.permission_code,
        p.permission_name,
        p.description,
        p.created_at,
        p.created_by,
        p.updated_at,
        p.updated_by
    FROM dbo.permissions p
    INNER JOIN dbo.role_permissions rp ON p.permission_id = rp.permission_id
    INNER JOIN dbo.roles r ON rp.role_id = r.role_id
    WHERE r.role_name = @RoleName 
        AND r.deleted_at IS NULL
    ORDER BY p.permission_code;
END
GO
PRINT 'âœ“ Táº¡o sp_GetPermissionsByRoleName';
GO

-- SP 3: Get Permission IDs by Role
IF OBJECT_ID('sp_GetPermissionIdsByRole', 'P') IS NOT NULL DROP PROCEDURE sp_GetPermissionIdsByRole;
GO
CREATE PROCEDURE sp_GetPermissionIdsByRole
    @RoleId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT permission_id
    FROM dbo.role_permissions
    WHERE role_id = @RoleId;
END
GO
PRINT 'âœ“ Táº¡o sp_GetPermissionIdsByRole';
GO

-- SP 4: Assign Permission to Role
IF OBJECT_ID('sp_AssignPermissionToRole', 'P') IS NOT NULL DROP PROCEDURE sp_AssignPermissionToRole;
GO
CREATE PROCEDURE sp_AssignPermissionToRole
    @RoleId VARCHAR(50),
    @PermissionId VARCHAR(50),
    @CreatedBy VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT EXISTS (
        SELECT 1 FROM dbo.role_permissions 
        WHERE role_id = @RoleId AND permission_id = @PermissionId
    )
    BEGIN
        INSERT INTO dbo.role_permissions (role_id, permission_id, created_at, created_by)
        VALUES (@RoleId, @PermissionId, GETDATE(), @CreatedBy);
    END
END
GO
PRINT 'âœ“ Táº¡o sp_AssignPermissionToRole';
GO

-- SP 5: Remove Permission from Role
IF OBJECT_ID('sp_RemovePermissionFromRole', 'P') IS NOT NULL DROP PROCEDURE sp_RemovePermissionFromRole;
GO
CREATE PROCEDURE sp_RemovePermissionFromRole
    @RoleId VARCHAR(50),
    @PermissionId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM dbo.role_permissions
    WHERE role_id = @RoleId AND permission_id = @PermissionId;
END
GO
PRINT 'âœ“ Táº¡o sp_RemovePermissionFromRole';
GO

-- SP 6: Delete All Permissions by Role
IF OBJECT_ID('sp_DeleteAllPermissionsByRole', 'P') IS NOT NULL DROP PROCEDURE sp_DeleteAllPermissionsByRole;
GO
CREATE PROCEDURE sp_DeleteAllPermissionsByRole
    @RoleId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM dbo.role_permissions
    WHERE role_id = @RoleId;
    
    SELECT @@ROWCOUNT AS DeletedCount;
END
GO
PRINT 'âœ“ Táº¡o sp_DeleteAllPermissionsByRole';
GO

-- SP 7: Get User Permissions
IF OBJECT_ID('sp_GetUserPermissions', 'P') IS NOT NULL DROP PROCEDURE sp_GetUserPermissions;
GO
CREATE PROCEDURE sp_GetUserPermissions
    @UserId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT DISTINCT
        p.permission_id,
        p.permission_code,
        p.permission_name,
        p.description
    FROM dbo.users u
    INNER JOIN dbo.roles r ON u.role_id = r.role_id
    INNER JOIN dbo.role_permissions rp ON r.role_id = rp.role_id
    INNER JOIN dbo.permissions p ON rp.permission_id = p.permission_id
    WHERE u.user_id = @UserId
        AND u.is_active = 1
        AND u.deleted_at IS NULL
        AND r.is_active = 1
        AND r.deleted_at IS NULL
    ORDER BY p.permission_code;
END
GO
PRINT 'âœ“ Táº¡o sp_GetUserPermissions';
GO

-- SP 8: Check User Permission
IF OBJECT_ID('sp_CheckUserPermission', 'P') IS NOT NULL DROP PROCEDURE sp_CheckUserPermission;
GO
CREATE PROCEDURE sp_CheckUserPermission
    @UserId VARCHAR(50),
    @PermissionCode VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (
        SELECT 1
        FROM dbo.users u
        INNER JOIN dbo.roles r ON u.role_id = r.role_id
        INNER JOIN dbo.role_permissions rp ON r.role_id = rp.role_id
        INNER JOIN dbo.permissions p ON rp.permission_id = p.permission_id
        WHERE u.user_id = @UserId
            AND p.permission_code = @PermissionCode
            AND u.is_active = 1
            AND u.deleted_at IS NULL
            AND r.is_active = 1
            AND r.deleted_at IS NULL
    )
        SELECT 1 AS HasPermission;
    ELSE
        SELECT 0 AS HasPermission;
END
GO
PRINT 'âœ“ Táº¡o sp_CheckUserPermission';
GO

-- SP 9: Get Roles with Permission Count
IF OBJECT_ID('sp_GetRolesWithPermissionCount', 'P') IS NOT NULL DROP PROCEDURE sp_GetRolesWithPermissionCount;
GO
CREATE PROCEDURE sp_GetRolesWithPermissionCount
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        r.role_id,
        r.role_name,
        r.description,
        r.is_active,
        r.created_at,
        r.updated_at,
        COUNT(rp.permission_id) AS permission_count
    FROM dbo.roles r
    LEFT JOIN dbo.role_permissions rp ON r.role_id = rp.role_id
    WHERE r.deleted_at IS NULL
    GROUP BY 
        r.role_id,
        r.role_name,
        r.description,
        r.is_active,
        r.created_at,
        r.updated_at
    ORDER BY r.role_name;
END
GO
PRINT 'âœ“ Táº¡o sp_GetRolesWithPermissionCount';
GO

PRINT '[OK] Permissions Management SPs created';
GO
