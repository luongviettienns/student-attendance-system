-- ===========================================
-- 🎓 HỆ THỐNG QUẢN LÝ ĐIỂM DANH SINH VIÊN
-- 📋 File 7: REFRESH TOKENS TABLE & PROCEDURES
-- ===========================================

USE EducationManagement;
GO

SET QUOTED_IDENTIFIER ON;
GO

PRINT '🔄 Bắt đầu tạo Refresh Tokens table & procedures...';
GO

-- ===========================================
-- 1. CREATE REFRESH_TOKENS TABLE
-- ===========================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'refresh_tokens')
BEGIN
    CREATE TABLE dbo.refresh_tokens (
        id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        user_id VARCHAR(50) NOT NULL,
        token VARCHAR(500) NOT NULL UNIQUE,
        expires_at DATETIME NOT NULL,
        created_at DATETIME NOT NULL DEFAULT GETDATE(),
        revoked_at DATETIME NULL,
        replaced_by_token VARCHAR(500) NULL,
        
        CONSTRAINT fk_refresh_tokens_user 
            FOREIGN KEY (user_id) REFERENCES dbo.users(user_id) ON DELETE CASCADE
    );
    
    PRINT '✅ Created table: refresh_tokens';
END
ELSE
    PRINT '⏭️  Table refresh_tokens already exists';
GO

-- ===========================================
-- 2. CREATE INDEXES FOR PERFORMANCE
-- ===========================================
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_refresh_tokens_token')
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX idx_refresh_tokens_token 
        ON refresh_tokens(token)
        WHERE revoked_at IS NULL;
    PRINT '✅ Created index: idx_refresh_tokens_token';
END
ELSE
    PRINT '⏭️  Index idx_refresh_tokens_token already exists';
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_refresh_tokens_user')
BEGIN
    CREATE NONCLUSTERED INDEX idx_refresh_tokens_user 
        ON refresh_tokens(user_id, created_at DESC);
    PRINT '✅ Created index: idx_refresh_tokens_user';
END
ELSE
    PRINT '⏭️  Index idx_refresh_tokens_user already exists';
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_refresh_tokens_expires')
BEGIN
    CREATE NONCLUSTERED INDEX idx_refresh_tokens_expires 
        ON refresh_tokens(expires_at)
        WHERE revoked_at IS NULL;
    PRINT '✅ Created index: idx_refresh_tokens_expires';
END
ELSE
    PRINT '⏭️  Index idx_refresh_tokens_expires already exists';
GO

-- ===========================================
-- 3. STORED PROCEDURES
-- ===========================================

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
            RAISERROR(N'User không tồn tại: %s', 16, 1, @UserId);
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
PRINT '✅ Created: sp_SaveRefreshToken';
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
PRINT '✅ Created: sp_GetRefreshTokenByToken';
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
PRINT '✅ Created: sp_RevokeRefreshToken';
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
        
        PRINT CONCAT('✅ Cleaned ', @DeletedCount, ' expired/revoked refresh tokens');
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
PRINT '✅ Created: sp_CleanExpiredRefreshTokens';
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
PRINT '✅ Created: sp_RevokeAllUserTokens';
GO

PRINT '';
PRINT '🎉 HOÀN THÀNH TẠO REFRESH TOKENS TABLE & PROCEDURES!';
PRINT '✅ Table: refresh_tokens';
PRINT '✅ Indexes: 3 indexes for performance';
PRINT '✅ Stored Procedures: 5 procedures';
PRINT '';
PRINT '💡 TIP: Chạy sp_CleanExpiredRefreshTokens định kỳ (SQL Agent Job)';
PRINT '';

