-- ===========================================
-- BẢNG LỊCH SỬ CHUYỂN LỚP (Student Class Transfers)
-- ===========================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'student_class_transfers')
BEGIN
    PRINT 'Creating table: student_class_transfers';
    
    CREATE TABLE dbo.student_class_transfers (
        -- Primary Key
        transfer_id          VARCHAR(50) PRIMARY KEY,
        
        -- Student Information
        student_id           VARCHAR(50) NOT NULL,
        
        -- Class Information
        from_admin_class_id  VARCHAR(50) NULL,  -- Lớp cũ (NULL nếu chưa có lớp)
        to_admin_class_id    VARCHAR(50) NOT NULL,  -- Lớp mới
        
        -- Transfer Details
        transfer_reason      NVARCHAR(500) NULL,  -- Lý do chuyển lớp
        transfer_date        DATETIME NOT NULL DEFAULT(GETDATE()),  -- Ngày chuyển
        
        -- Audit Fields
        transferred_by       VARCHAR(50) NOT NULL,  -- Người thực hiện chuyển lớp
        created_at           DATETIME NOT NULL DEFAULT(GETDATE()),
        
        -- Foreign Keys
        FOREIGN KEY (student_id) REFERENCES dbo.students(student_id),
        FOREIGN KEY (from_admin_class_id) REFERENCES dbo.administrative_classes(admin_class_id),
        FOREIGN KEY (to_admin_class_id) REFERENCES dbo.administrative_classes(admin_class_id)
    );
    
    -- Indexes
    CREATE INDEX IX_StudentClassTransfer_StudentId ON dbo.student_class_transfers(student_id);
    CREATE INDEX IX_StudentClassTransfer_FromClass ON dbo.student_class_transfers(from_admin_class_id);
    CREATE INDEX IX_StudentClassTransfer_ToClass ON dbo.student_class_transfers(to_admin_class_id);
    CREATE INDEX IX_StudentClassTransfer_Date ON dbo.student_class_transfers(transfer_date);
    
    PRINT '✓ Created table: student_class_transfers';
END
ELSE
BEGIN
    PRINT '✓ Table already exists: student_class_transfers';
END
GO

-- ===========================================
-- STORED PROCEDURE: sp_TransferStudentToClass
-- ===========================================

IF OBJECT_ID('sp_TransferStudentToClass', 'P') IS NOT NULL
    DROP PROCEDURE sp_TransferStudentToClass;
GO

CREATE PROCEDURE sp_TransferStudentToClass
    @StudentId          VARCHAR(50),
    @ToAdminClassId     VARCHAR(50),
    @TransferReason     NVARCHAR(500) = NULL,
    @TransferredBy      VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- 1. Validate student exists
        IF NOT EXISTS (SELECT 1 FROM dbo.students WHERE student_id = @StudentId AND deleted_at IS NULL)
        BEGIN
            THROW 50009, N'Không tìm thấy sinh viên', 1;
        END
        
        -- 2. Validate target class exists and is active
        IF NOT EXISTS (SELECT 1 FROM dbo.administrative_classes 
                       WHERE admin_class_id = @ToAdminClassId AND deleted_at IS NULL)
        BEGIN
            THROW 50010, N'Không tìm thấy lớp hành chính đích', 1;
        END
        
        -- 3. Check if target class has available slots
        DECLARE @CurrentStudents INT, @MaxStudents INT;
        SELECT @CurrentStudents = current_students, @MaxStudents = max_students
        FROM dbo.administrative_classes
        WHERE admin_class_id = @ToAdminClassId;
        
        IF @CurrentStudents >= @MaxStudents
        BEGIN
            THROW 50011, N'Lớp đích đã đầy, không thể chuyển sinh viên', 1;
        END
        
        -- 4. Get current class (if any)
        DECLARE @FromAdminClassId VARCHAR(50);
        SELECT @FromAdminClassId = admin_class_id 
        FROM dbo.students 
        WHERE student_id = @StudentId;
        
        -- 5. Validate: student is not already in target class
        IF @FromAdminClassId = @ToAdminClassId
        BEGIN
            THROW 50012, N'Sinh viên đã ở trong lớp này rồi', 1;
        END
        
        -- 6. Create transfer record
        DECLARE @TransferId VARCHAR(50) = 'TRF-' + CONVERT(VARCHAR(36), NEWID());
        
        INSERT INTO dbo.student_class_transfers (
            transfer_id,
            student_id,
            from_admin_class_id,
            to_admin_class_id,
            transfer_reason,
            transfer_date,
            transferred_by
        )
        VALUES (
            @TransferId,
            @StudentId,
            @FromAdminClassId,
            @ToAdminClassId,
            @TransferReason,
            GETDATE(),
            @TransferredBy
        );
        
        -- 7. Update student's admin_class_id
        UPDATE dbo.students
        SET admin_class_id = @ToAdminClassId,
            updated_at = GETDATE(),
            updated_by = @TransferredBy
        WHERE student_id = @StudentId;
        
        -- 8. Decrease old class count (if exists)
        IF @FromAdminClassId IS NOT NULL
        BEGIN
            UPDATE dbo.administrative_classes
            SET current_students = current_students - 1,
                updated_at = GETDATE(),
                updated_by = @TransferredBy
            WHERE admin_class_id = @FromAdminClassId;
        END
        
        -- 9. Increase new class count
        UPDATE dbo.administrative_classes
        SET current_students = current_students + 1,
            updated_at = GETDATE(),
            updated_by = @TransferredBy
        WHERE admin_class_id = @ToAdminClassId;
        
        COMMIT TRANSACTION;
        
        -- Return success
        SELECT 
            1 AS Success,
            N'Chuyển lớp thành công' AS Message,
            @TransferId AS TransferId,
            @FromAdminClassId AS FromClassId,
            @ToAdminClassId AS ToClassId;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorNumber INT = ERROR_NUMBER();
        
        -- Re-throw with original error number if it's a custom error
        IF @ErrorNumber >= 50000
            THROW;
        ELSE
            THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT '✓ Created stored procedure: sp_TransferStudentToClass';
GO

-- ===========================================
-- STORED PROCEDURE: sp_GetStudentTransferHistory
-- ===========================================

IF OBJECT_ID('sp_GetStudentTransferHistory', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetStudentTransferHistory;
GO

CREATE PROCEDURE sp_GetStudentTransferHistory
    @StudentId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        t.transfer_id,
        t.student_id,
        s.student_code,
        s.full_name AS student_name,
        t.from_admin_class_id,
        fc.class_code AS from_class_code,
        fc.class_name AS from_class_name,
        t.to_admin_class_id,
        tc.class_code AS to_class_code,
        tc.class_name AS to_class_name,
        t.transfer_reason,
        t.transfer_date,
        t.transferred_by,
        u.full_name AS transferred_by_name,
        t.created_at
    FROM dbo.student_class_transfers t
    INNER JOIN dbo.students s ON s.student_id = t.student_id
    LEFT JOIN dbo.administrative_classes fc ON fc.admin_class_id = t.from_admin_class_id
    INNER JOIN dbo.administrative_classes tc ON tc.admin_class_id = t.to_admin_class_id
    LEFT JOIN dbo.users u ON u.user_id = t.transferred_by
    WHERE t.student_id = @StudentId
    ORDER BY t.transfer_date DESC;
END
GO

PRINT '✓ Created stored procedure: sp_GetStudentTransferHistory';
GO

-- ===========================================
-- STORED PROCEDURE: sp_RecalculateAdminClassStudentCount
-- ===========================================

IF OBJECT_ID('sp_RecalculateAdminClassStudentCount', 'P') IS NOT NULL
    DROP PROCEDURE sp_RecalculateAdminClassStudentCount;
GO

CREATE PROCEDURE sp_RecalculateAdminClassStudentCount
    @AdminClassId VARCHAR(50) = NULL  -- NULL = recalculate all classes
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        IF @AdminClassId IS NOT NULL
        BEGIN
            -- Recalculate for specific class
            UPDATE ac
            SET ac.current_students = (
                SELECT COUNT(*)
                FROM dbo.students s
                WHERE s.admin_class_id = ac.admin_class_id
                  AND s.deleted_at IS NULL
            ),
            ac.updated_at = GETDATE()
            FROM dbo.administrative_classes ac
            WHERE ac.admin_class_id = @AdminClassId
              AND ac.deleted_at IS NULL;
        END
        ELSE
        BEGIN
            -- Recalculate for all classes
            UPDATE ac
            SET ac.current_students = (
                SELECT COUNT(*)
                FROM dbo.students s
                WHERE s.admin_class_id = ac.admin_class_id
                  AND s.deleted_at IS NULL
            ),
            ac.updated_at = GETDATE()
            FROM dbo.administrative_classes ac
            WHERE ac.deleted_at IS NULL;
        END
        
        COMMIT TRANSACTION;
        
        SELECT 1 AS Success, N'Đã cập nhật số lượng sinh viên thành công' AS Message;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorNumber INT = ERROR_NUMBER();
        
        IF @ErrorNumber >= 50000
            THROW;
        ELSE
            THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT '✓ Created stored procedure: sp_RecalculateAdminClassStudentCount';
GO

