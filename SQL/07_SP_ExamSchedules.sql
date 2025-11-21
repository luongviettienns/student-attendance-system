-- ===========================================
-- 🎓 HỆ THỐNG QUẢN LÝ ĐIỂM DANH SINH VIÊN
-- 📋 File: STORED PROCEDURES CHO LỊCH THI
-- ===========================================

USE EducationManagement;
GO

-- ===========================================
-- 1. SP_GETSTUDENTSBYCLASS - Lấy danh sách sinh viên đã đăng ký trong lớp học phần
-- ===========================================

IF OBJECT_ID('sp_GetStudentsByClass', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetStudentsByClass;
GO

CREATE PROCEDURE sp_GetStudentsByClass
    @ClassId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        SELECT 
            s.student_id,
            s.student_code,
            s.full_name,
            e.enrollment_id,
            e.enrollment_date,
            e.status as enrollment_status
        FROM dbo.students s
        INNER JOIN dbo.enrollments e ON s.student_id = e.student_id
        WHERE e.class_id = @ClassId
            AND e.status = 'APPROVED'  -- Chỉ lấy enrollment đã được duyệt
            AND e.deleted_at IS NULL
            AND s.deleted_at IS NULL
        ORDER BY s.student_code;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT '✓ Created stored procedure: sp_GetStudentsByClass';
GO

-- ===========================================
-- 2. SP_CHECKSTUDENTQUALIFICATION - Kiểm tra sinh viên có đủ điều kiện dự thi không
-- ===========================================

IF OBJECT_ID('sp_CheckStudentQualification', 'P') IS NOT NULL
    DROP PROCEDURE sp_CheckStudentQualification;
GO

CREATE PROCEDURE sp_CheckStudentQualification
    @StudentId VARCHAR(50),
    @ClassId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        DECLARE @AttendanceRate DECIMAL(5,2);
        DECLARE @TotalSessions INT;
        DECLARE @AbsentSessions INT;
        DECLARE @IsQualified BIT = 1;
        
        -- Tính tỷ lệ chuyên cần
        SELECT 
            @TotalSessions = COUNT(*),
            @AbsentSessions = COUNT(CASE WHEN a.status = 'Absent' THEN 1 END)
        FROM dbo.enrollments e
        LEFT JOIN dbo.attendances a ON e.enrollment_id = a.enrollment_id
            AND a.deleted_at IS NULL
        WHERE e.student_id = @StudentId
            AND e.class_id = @ClassId
            AND e.status = 'APPROVED'
            AND e.deleted_at IS NULL;
        
        -- Tính tỷ lệ vắng mặt
        IF @TotalSessions > 0
        BEGIN
            SET @AttendanceRate = CAST((@AbsentSessions * 100.0 / @TotalSessions) AS DECIMAL(5,2));
            
            -- Nếu vắng mặt > 20% thì không đủ điều kiện
            IF @AttendanceRate > 20.0
                SET @IsQualified = 0;
        END
        
        -- Return result
        SELECT 
            @StudentId as student_id,
            @ClassId as class_id,
            ISNULL(@TotalSessions, 0) as total_sessions,
            ISNULL(@AbsentSessions, 0) as absent_sessions,
            ISNULL(@AttendanceRate, 0) as absent_rate,
            @IsQualified as is_qualified;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT '✓ Created stored procedure: sp_CheckStudentQualification';
GO

-- ===========================================
-- 3. SP_GETEXAMSCHEDULES - Lấy danh sách lịch thi với filter
-- ===========================================

IF OBJECT_ID('sp_GetExamSchedules', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetExamSchedules;
GO

CREATE PROCEDURE sp_GetExamSchedules
    @SchoolYearId VARCHAR(50) = NULL,
    @Semester INT = NULL,
    @ExamType NVARCHAR(20) = NULL,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL,
    @ClassId VARCHAR(50) = NULL,
    @SubjectId VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        SELECT 
            es.exam_id,
            es.class_id,
            c.class_code,
            c.class_name,
            es.subject_id,
            s.subject_code,
            s.subject_name,
            es.exam_date,
            es.exam_time,
            es.end_time,
            es.room_id,
            r.room_code,
            r.building,
            r.capacity as room_capacity,
            es.exam_type,
            es.session_no,
            es.proctor_lecturer_id,
            l.full_name as proctor_name,
            es.duration,
            es.max_students,
            es.notes,
            es.status,
            es.school_year_id,
            sy.year_code,
            sy.year_name,
            es.semester,
            (SELECT COUNT(*) FROM dbo.exam_assignments ea 
             WHERE ea.exam_id = es.exam_id AND ea.deleted_at IS NULL) as assigned_students,
            es.created_at,
            es.created_by,
            es.updated_at,
            es.updated_by
        FROM dbo.exam_schedules es
        INNER JOIN dbo.classes c ON es.class_id = c.class_id
        INNER JOIN dbo.subjects s ON es.subject_id = s.subject_id
        LEFT JOIN dbo.rooms r ON es.room_id = r.room_id
        LEFT JOIN dbo.lecturers l ON es.proctor_lecturer_id = l.lecturer_id
        LEFT JOIN dbo.school_years sy ON es.school_year_id = sy.school_year_id
        WHERE es.deleted_at IS NULL
            AND (@SchoolYearId IS NULL OR es.school_year_id = @SchoolYearId)
            AND (@Semester IS NULL OR es.semester = @Semester)
            AND (@ExamType IS NULL OR es.exam_type = @ExamType)
            AND (@StartDate IS NULL OR es.exam_date >= @StartDate)
            AND (@EndDate IS NULL OR es.exam_date <= @EndDate)
            AND (@ClassId IS NULL OR es.class_id = @ClassId)
            AND (@SubjectId IS NULL OR es.subject_id = @SubjectId)
        ORDER BY es.exam_date, es.exam_time, es.session_no;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT '✓ Created stored procedure: sp_GetExamSchedules';
GO

-- ===========================================
-- 4. SP_GETEXAMSCHEDULEBYID - Lấy chi tiết lịch thi
-- ===========================================

IF OBJECT_ID('sp_GetExamScheduleById', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetExamScheduleById;
GO

CREATE PROCEDURE sp_GetExamScheduleById
    @ExamId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        SELECT 
            es.exam_id,
            es.class_id,
            c.class_code,
            c.class_name,
            es.subject_id,
            s.subject_code,
            s.subject_name,
            es.exam_date,
            es.exam_time,
            es.end_time,
            es.room_id,
            r.room_code,
            r.building,
            r.capacity as room_capacity,
            es.exam_type,
            es.session_no,
            es.proctor_lecturer_id,
            l.full_name as proctor_name,
            es.duration,
            es.max_students,
            es.notes,
            es.status,
            es.school_year_id,
            sy.year_code,
            sy.year_name,
            es.semester,
            (SELECT COUNT(*) FROM dbo.exam_assignments ea 
             WHERE ea.exam_id = es.exam_id AND ea.deleted_at IS NULL) as assigned_students,
            es.created_at,
            es.created_by,
            es.updated_at,
            es.updated_by
        FROM dbo.exam_schedules es
        INNER JOIN dbo.classes c ON es.class_id = c.class_id
        INNER JOIN dbo.subjects s ON es.subject_id = s.subject_id
        LEFT JOIN dbo.rooms r ON es.room_id = r.room_id
        LEFT JOIN dbo.lecturers l ON es.proctor_lecturer_id = l.lecturer_id
        LEFT JOIN dbo.school_years sy ON es.school_year_id = sy.school_year_id
        WHERE es.exam_id = @ExamId
            AND es.deleted_at IS NULL;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT '✓ Created stored procedure: sp_GetExamScheduleById';
GO

-- ===========================================
-- 5. SP_CHECKROOMCONFLICT - Kiểm tra xung đột phòng thi
-- ===========================================

IF OBJECT_ID('sp_CheckRoomConflict', 'P') IS NOT NULL
    DROP PROCEDURE sp_CheckRoomConflict;
GO

CREATE PROCEDURE sp_CheckRoomConflict
    @RoomId VARCHAR(50),
    @ExamDate DATE,
    @StartTime TIME,
    @EndTime TIME,
    @ExcludeExamId VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        DECLARE @HasConflict BIT = 0;
        
        -- Kiểm tra xung đột: cùng phòng, cùng ngày, thời gian chồng chéo
        IF EXISTS (
            SELECT 1
            FROM dbo.exam_schedules es
            WHERE es.room_id = @RoomId
                AND es.exam_date = @ExamDate
                AND es.deleted_at IS NULL
                AND (@ExcludeExamId IS NULL OR es.exam_id != @ExcludeExamId)
                AND (
                    -- Kiểm tra chồng chéo thời gian
                    (@StartTime >= es.exam_time AND @StartTime < es.end_time)
                    OR (@EndTime > es.exam_time AND @EndTime <= es.end_time)
                    OR (@StartTime <= es.exam_time AND @EndTime >= es.end_time)
                )
        )
        BEGIN
            SET @HasConflict = 1;
        END
        
        SELECT @HasConflict as has_conflict;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT '✓ Created stored procedure: sp_CheckRoomConflict';
GO

-- ===========================================
-- 6. SP_CREATEEXAMSCHEDULE - Tạo lịch thi mới
-- ===========================================

IF OBJECT_ID('sp_CreateExamSchedule', 'P') IS NOT NULL
    DROP PROCEDURE sp_CreateExamSchedule;
GO

CREATE PROCEDURE sp_CreateExamSchedule
    @ExamId VARCHAR(50),
    @ClassId VARCHAR(50),
    @SubjectId VARCHAR(50),
    @ExamDate DATE,
    @ExamTime TIME,
    @EndTime TIME,
    @RoomId VARCHAR(50) = NULL,
    @ExamType NVARCHAR(20),
    @SessionNo INT = NULL,
    @ProctorLecturerId VARCHAR(50) = NULL,
    @Duration INT,
    @MaxStudents INT = NULL,
    @Notes NVARCHAR(500) = NULL,
    @Status NVARCHAR(20) = 'PLANNED',
    @SchoolYearId VARCHAR(50) = NULL,
    @Semester INT = NULL,
    @CreatedBy VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate: Kiểm tra xung đột phòng (nếu có phòng)
        IF @RoomId IS NOT NULL
        BEGIN
            DECLARE @HasConflict BIT = 0;
            
            -- Create temporary table to capture result
            CREATE TABLE #RoomConflictCheck (
                has_conflict BIT
            );
            
            INSERT INTO #RoomConflictCheck
            EXEC sp_CheckRoomConflict 
                @RoomId = @RoomId,
                @ExamDate = @ExamDate,
                @StartTime = @ExamTime,
                @EndTime = @EndTime,
                @ExcludeExamId = NULL;
            
            SELECT @HasConflict = has_conflict FROM #RoomConflictCheck;
            
            DROP TABLE #RoomConflictCheck;
            
            IF @HasConflict = 1
            BEGIN
                THROW 50001, N'Phòng thi đã được sử dụng trong khoảng thời gian này', 1;
            END
        END
        
        -- Insert exam schedule
        INSERT INTO dbo.exam_schedules (
            exam_id, class_id, subject_id, exam_date, exam_time, end_time,
            room_id, exam_type, session_no, proctor_lecturer_id, duration,
            max_students, notes, status, school_year_id, semester,
            created_at, created_by
        )
        VALUES (
            @ExamId, @ClassId, @SubjectId, @ExamDate, @ExamTime, @EndTime,
            @RoomId, @ExamType, @SessionNo, @ProctorLecturerId, @Duration,
            @MaxStudents, @Notes, @Status, @SchoolYearId, @Semester,
            GETDATE(), @CreatedBy
        );
        
        COMMIT TRANSACTION;
        
        -- Return created exam
        EXEC sp_GetExamScheduleById @ExamId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT '✓ Created stored procedure: sp_CreateExamSchedule';
GO

-- ===========================================
-- 7. SP_UPDATEEXAMSCHEDULE - Cập nhật lịch thi
-- ===========================================

IF OBJECT_ID('sp_UpdateExamSchedule', 'P') IS NOT NULL
    DROP PROCEDURE sp_UpdateExamSchedule;
GO

CREATE PROCEDURE sp_UpdateExamSchedule
    @ExamId VARCHAR(50),
    @ExamDate DATE = NULL,
    @ExamTime TIME = NULL,
    @EndTime TIME = NULL,
    @RoomId VARCHAR(50) = NULL,
    @SessionNo INT = NULL,
    @ProctorLecturerId VARCHAR(50) = NULL,
    @Duration INT = NULL,
    @MaxStudents INT = NULL,
    @Notes NVARCHAR(500) = NULL,
    @Status NVARCHAR(20) = NULL,
    @UpdatedBy VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate: Kiểm tra xung đột phòng (nếu có phòng mới hoặc thay đổi thời gian)
        IF @RoomId IS NOT NULL AND (@ExamDate IS NOT NULL OR @ExamTime IS NOT NULL OR @EndTime IS NOT NULL)
        BEGIN
            DECLARE @CurrentDate DATE, @CurrentStartTime TIME, @CurrentEndTime TIME;
            SELECT @CurrentDate = exam_date, @CurrentStartTime = exam_time, @CurrentEndTime = end_time
            FROM dbo.exam_schedules WHERE exam_id = @ExamId;
            
            DECLARE @FinalDate DATE = ISNULL(@ExamDate, @CurrentDate);
            DECLARE @FinalStartTime TIME = ISNULL(@ExamTime, @CurrentStartTime);
            DECLARE @FinalEndTime TIME = ISNULL(@EndTime, @CurrentEndTime);
            
            DECLARE @HasConflict BIT = 0;
            
            -- Create temporary table to capture result
            CREATE TABLE #RoomConflictCheck (
                has_conflict BIT
            );
            
            INSERT INTO #RoomConflictCheck
            EXEC sp_CheckRoomConflict 
                @RoomId = @RoomId,
                @ExamDate = @FinalDate,
                @StartTime = @FinalStartTime,
                @EndTime = @FinalEndTime,
                @ExcludeExamId = @ExamId;
            
            SELECT @HasConflict = has_conflict FROM #RoomConflictCheck;
            
            DROP TABLE #RoomConflictCheck;
            
            IF @HasConflict = 1
            BEGIN
                THROW 50001, N'Phòng thi đã được sử dụng trong khoảng thời gian này', 1;
            END
        END
        
        -- Update exam schedule
        UPDATE dbo.exam_schedules
        SET exam_date = ISNULL(@ExamDate, exam_date),
            exam_time = ISNULL(@ExamTime, exam_time),
            end_time = ISNULL(@EndTime, end_time),
            room_id = ISNULL(@RoomId, room_id),
            session_no = ISNULL(@SessionNo, session_no),
            proctor_lecturer_id = ISNULL(@ProctorLecturerId, proctor_lecturer_id),
            duration = ISNULL(@Duration, duration),
            max_students = ISNULL(@MaxStudents, max_students),
            notes = ISNULL(@Notes, notes),
            status = ISNULL(@Status, status),
            updated_at = GETDATE(),
            updated_by = @UpdatedBy
        WHERE exam_id = @ExamId
            AND deleted_at IS NULL;
        
        IF @@ROWCOUNT = 0
        BEGIN
            THROW 50001, N'Không tìm thấy lịch thi', 1;
        END
        
        COMMIT TRANSACTION;
        
        -- Return updated exam
        EXEC sp_GetExamScheduleById @ExamId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT '✓ Created stored procedure: sp_UpdateExamSchedule';
GO

-- ===========================================
-- 8. SP_DELETEEXAMSCHEDULE - Xóa lịch thi (soft delete)
-- ===========================================

IF OBJECT_ID('sp_DeleteExamSchedule', 'P') IS NOT NULL
    DROP PROCEDURE sp_DeleteExamSchedule;
GO

CREATE PROCEDURE sp_DeleteExamSchedule
    @ExamId VARCHAR(50),
    @DeletedBy VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Soft delete exam schedule
        UPDATE dbo.exam_schedules
        SET deleted_at = GETDATE(),
            deleted_by = @DeletedBy
        WHERE exam_id = @ExamId
            AND deleted_at IS NULL;
        
        IF @@ROWCOUNT = 0
        BEGIN
            THROW 50001, N'Không tìm thấy lịch thi', 1;
        END
        
        -- Soft delete exam assignments
        UPDATE dbo.exam_assignments
        SET deleted_at = GETDATE(),
            deleted_by = @DeletedBy
        WHERE exam_id = @ExamId
            AND deleted_at IS NULL;
        
        COMMIT TRANSACTION;
        
        SELECT 1 AS success, N'Xóa lịch thi thành công' AS message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT '✓ Created stored procedure: sp_DeleteExamSchedule';
GO

-- ===========================================
-- 9. SP_GETEXAMASSIGNMENTSBYEXAM - Lấy danh sách sinh viên trong ca thi
-- ===========================================

IF OBJECT_ID('sp_GetExamAssignmentsByExam', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetExamAssignmentsByExam;
GO

CREATE PROCEDURE sp_GetExamAssignmentsByExam
    @ExamId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        SELECT 
            ea.assignment_id,
            ea.exam_id,
            ea.enrollment_id,
            ea.student_id,
            s.student_code,
            s.full_name as student_name,
            ea.seat_number,
            ea.status,
            ea.notes,
            ea.created_at,
            ea.created_by
        FROM dbo.exam_assignments ea
        INNER JOIN dbo.students s ON ea.student_id = s.student_id
        WHERE ea.exam_id = @ExamId
            AND ea.deleted_at IS NULL
            AND s.deleted_at IS NULL
        ORDER BY ea.seat_number, s.student_code;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT '✓ Created stored procedure: sp_GetExamAssignmentsByExam';
GO

-- ===========================================
-- 10. SP_GETSTUDENTEXAMS - Lấy lịch thi của sinh viên
-- ===========================================

IF OBJECT_ID('sp_GetStudentExams', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetStudentExams;
GO

CREATE PROCEDURE sp_GetStudentExams
    @StudentId VARCHAR(50),
    @SchoolYearId VARCHAR(50) = NULL,
    @Semester INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        SELECT 
            es.exam_id,
            es.class_id,
            c.class_code,
            c.class_name,
            es.subject_id,
            s.subject_code,
            s.subject_name,
            es.exam_date,
            es.exam_time,
            es.end_time,
            es.room_id,
            r.room_code,
            r.building,
            es.exam_type,
            es.session_no,
            ea.seat_number,
            ea.status as assignment_status,
            es.status as exam_status,
            es.notes
        FROM dbo.exam_assignments ea
        INNER JOIN dbo.exam_schedules es ON ea.exam_id = es.exam_id
        INNER JOIN dbo.classes c ON es.class_id = c.class_id
        INNER JOIN dbo.subjects s ON es.subject_id = s.subject_id
        LEFT JOIN dbo.rooms r ON es.room_id = r.room_id
        WHERE ea.student_id = @StudentId
            AND ea.deleted_at IS NULL
            AND es.deleted_at IS NULL
            AND (@SchoolYearId IS NULL OR es.school_year_id = @SchoolYearId)
            AND (@Semester IS NULL OR es.semester = @Semester)
        ORDER BY es.exam_date, es.exam_time;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT '✓ Created stored procedure: sp_GetStudentExams';
GO

-- ===========================================
-- 11. SP_AUTOASSIGNSTUDENTSFROMCLASS - Tự động phân sinh viên trong lớp vào các ca thi
-- ===========================================

IF OBJECT_ID('sp_AutoAssignStudentsFromClass', 'P') IS NOT NULL
    DROP PROCEDURE sp_AutoAssignStudentsFromClass;
GO

CREATE PROCEDURE sp_AutoAssignStudentsFromClass
    @ExamId VARCHAR(50),
    @ClassId VARCHAR(50),
    @RoomCapacity INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @StudentId VARCHAR(50);
        DECLARE @EnrollmentId VARCHAR(50);
        DECLARE @AssignmentId VARCHAR(50);
        DECLARE @SeatNumber INT = 1;
        DECLARE @CurrentSession INT = 1;
        DECLARE @StudentsInSession INT = 0;
        DECLARE @IsQualified BIT;
        
        -- Create temporary table once for qualification check (will be reused in loop)
        CREATE TABLE #QualificationCheck (
            student_id VARCHAR(50),
            class_id VARCHAR(50),
            total_sessions INT,
            absent_sessions INT,
            absent_rate DECIMAL(5,2),
            is_qualified BIT
        );
        
        -- Cursor để duyệt qua từng sinh viên
        DECLARE student_cursor CURSOR FOR
        SELECT s.student_id, e.enrollment_id
        FROM dbo.students s
        INNER JOIN dbo.enrollments e ON s.student_id = e.student_id
        WHERE e.class_id = @ClassId
            AND e.status = 'APPROVED'
            AND e.deleted_at IS NULL
            AND s.deleted_at IS NULL
        ORDER BY s.student_code;
        
        OPEN student_cursor;
        FETCH NEXT FROM student_cursor INTO @StudentId, @EnrollmentId;
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Kiểm tra điều kiện dự thi
            -- Clear temp table before inserting new result
            TRUNCATE TABLE #QualificationCheck;
            
            INSERT INTO #QualificationCheck
            EXEC sp_CheckStudentQualification @StudentId, @ClassId;
            
            SELECT @IsQualified = is_qualified FROM #QualificationCheck;
            
            -- Nếu đã đủ capacity cho ca hiện tại, chuyển sang ca tiếp theo
            IF @StudentsInSession >= @RoomCapacity
            BEGIN
                SET @CurrentSession = @CurrentSession + 1;
                SET @StudentsInSession = 0;
                SET @SeatNumber = 1;
            END
            
            -- Tạo assignment
            SET @AssignmentId = NEWID();
            
            INSERT INTO dbo.exam_assignments (
                assignment_id, exam_id, enrollment_id, student_id,
                seat_number, status, created_at, created_by
            )
            VALUES (
                @AssignmentId, @ExamId, @EnrollmentId, @StudentId,
                @SeatNumber,
                CASE WHEN @IsQualified = 1 THEN 'ASSIGNED' ELSE 'NOT_QUALIFIED' END,
                GETDATE(), 'system'
            );
            
            SET @SeatNumber = @SeatNumber + 1;
            SET @StudentsInSession = @StudentsInSession + 1;
            
            FETCH NEXT FROM student_cursor INTO @StudentId, @EnrollmentId;
        END
        
        CLOSE student_cursor;
        DEALLOCATE student_cursor;
        
        -- Drop temporary table
        DROP TABLE IF EXISTS #QualificationCheck;
        
        COMMIT TRANSACTION;
        
        SELECT @CurrentSession as total_sessions_created,
               (SELECT COUNT(*) FROM dbo.exam_assignments WHERE exam_id = @ExamId AND deleted_at IS NULL) as total_students_assigned;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        IF CURSOR_STATUS('global', 'student_cursor') >= 0
        BEGIN
            CLOSE student_cursor;
            DEALLOCATE student_cursor;
        END
        
        -- Clean up temporary table in error handler
        DROP TABLE IF EXISTS #QualificationCheck;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT '✓ Created stored procedure: sp_AutoAssignStudentsFromClass';
GO

-- ===========================================
-- 12. SP_CREATEEXAMSCHEDULEFORCLASS - Tạo lịch thi cho lớp học phần (tự động phân sinh viên, tạo nhiều ca thi)
-- ===========================================

IF OBJECT_ID('sp_CreateExamScheduleForClass', 'P') IS NOT NULL
    DROP PROCEDURE sp_CreateExamScheduleForClass;
GO

CREATE PROCEDURE sp_CreateExamScheduleForClass
    @ClassId VARCHAR(50),
    @SubjectId VARCHAR(50),
    @ExamDate DATE,
    @ExamTime TIME,
    @EndTime TIME,
    @RoomId VARCHAR(50),
    @ExamType NVARCHAR(20),
    @ProctorLecturerId VARCHAR(50) = NULL,
    @Duration INT,
    @Notes NVARCHAR(500) = NULL,
    @SchoolYearId VARCHAR(50) = NULL,
    @Semester INT = NULL,
    @CreatedBy VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Lấy thông tin phòng để có capacity
        DECLARE @RoomCapacity INT;
        SELECT @RoomCapacity = capacity FROM dbo.rooms WHERE room_id = @RoomId;
        
        IF @RoomCapacity IS NULL
        BEGIN
            THROW 50001, N'Không tìm thấy thông tin phòng thi', 1;
        END
        
        -- Lấy số lượng sinh viên trong lớp
        DECLARE @TotalStudents INT;
        SELECT @TotalStudents = COUNT(*)
        FROM dbo.enrollments e
        WHERE e.class_id = @ClassId
            AND e.status = 'APPROVED'
            AND e.deleted_at IS NULL;
        
        -- Tính số ca thi cần thiết
        DECLARE @RequiredSessions INT = CEILING(CAST(@TotalStudents AS FLOAT) / @RoomCapacity);
        DECLARE @CurrentSession INT = 1;
        
        -- Tạo các ca thi
        WHILE @CurrentSession <= @RequiredSessions
        BEGIN
            DECLARE @ExamId VARCHAR(50) = NEWID();
            DECLARE @SessionStartTime TIME = @ExamTime;
            DECLARE @SessionEndTime TIME = @EndTime;
            
            -- Tính toán thời gian cho từng ca (nếu có nhiều ca)
            IF @RequiredSessions > 1
            BEGIN
                -- Tự động tính thời gian cho ca tiếp theo (thêm 30 phút nghỉ giữa các ca)
                DECLARE @MinutesBetweenSessions INT = 30;
                DECLARE @MinutesAdded INT = (@CurrentSession - 1) * (@Duration + @MinutesBetweenSessions);
                
                SET @SessionStartTime = DATEADD(MINUTE, @MinutesAdded, CAST(@ExamTime AS DATETIME));
                SET @SessionEndTime = DATEADD(MINUTE, @Duration, CAST(@SessionStartTime AS DATETIME));
                
                -- Convert back to TIME
                SET @SessionStartTime = CAST(@SessionStartTime AS TIME);
                SET @SessionEndTime = CAST(@SessionEndTime AS TIME);
            END
            
            -- Tạo ca thi
            INSERT INTO dbo.exam_schedules (
                exam_id, class_id, subject_id, exam_date, exam_time, end_time,
                room_id, exam_type, session_no, proctor_lecturer_id, duration,
                max_students, notes, status, school_year_id, semester,
                created_at, created_by
            )
            VALUES (
                @ExamId, @ClassId, @SubjectId, @ExamDate, @SessionStartTime, @SessionEndTime,
                @RoomId, @ExamType, @CurrentSession, @ProctorLecturerId, @Duration,
                @RoomCapacity, @Notes, 'PLANNED', @SchoolYearId, @Semester,
                GETDATE(), @CreatedBy
            );
            
            -- Tự động phân sinh viên vào ca thi này
            EXEC sp_AutoAssignStudentsFromClass @ExamId, @ClassId, @RoomCapacity;
            
            SET @CurrentSession = @CurrentSession + 1;
        END
        
        COMMIT TRANSACTION;
        
        -- Return danh sách các ca thi đã tạo
        SELECT 
            es.exam_id,
            es.class_id,
            c.class_code,
            c.class_name,
            es.exam_date,
            es.exam_time,
            es.end_time,
            es.session_no,
            (SELECT COUNT(*) FROM dbo.exam_assignments ea 
             WHERE ea.exam_id = es.exam_id AND ea.deleted_at IS NULL) as assigned_students
        FROM dbo.exam_schedules es
        INNER JOIN dbo.classes c ON es.class_id = c.class_id
        WHERE es.class_id = @ClassId
            AND es.exam_type = @ExamType
            AND es.exam_date = @ExamDate
            AND es.created_by = @CreatedBy
            AND es.deleted_at IS NULL
        ORDER BY es.session_no;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT '✓ Created stored procedure: sp_CreateExamScheduleForClass';
GO

-- ===========================================
-- 11. SP_ENTEREXAMSCORES - Nhập điểm cho kỳ thi và tự động gán vào grades
-- ===========================================

IF OBJECT_ID('sp_EnterExamScores', 'P') IS NOT NULL
    DROP PROCEDURE sp_EnterExamScores;
GO

CREATE PROCEDURE sp_EnterExamScores
    @ExamId VARCHAR(50),
    @EnteredBy VARCHAR(50),
    @Scores NVARCHAR(MAX) -- JSON array of scores: [{"assignmentId":"...","studentId":"...","enrollmentId":"...","score":8.5,"status":"ATTENDED","notes":""},...]
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Validate exam exists
        IF NOT EXISTS (SELECT 1 FROM dbo.exam_schedules WHERE exam_id = @ExamId AND deleted_at IS NULL)
        BEGIN
            THROW 50001, 'Không tìm thấy lịch thi', 1;
        END
        
        -- Get exam info
        DECLARE @ExamType NVARCHAR(20);
        DECLARE @ClassId VARCHAR(50);
        
        SELECT @ExamType = exam_type, @ClassId = class_id
        FROM dbo.exam_schedules
        WHERE exam_id = @ExamId;
        
        -- Parse JSON scores
        DECLARE @ScoreTable TABLE (
            assignment_id VARCHAR(50),
            student_id VARCHAR(50),
            enrollment_id VARCHAR(50),
            score DECIMAL(4,2),
            status NVARCHAR(20),
            notes NVARCHAR(500)
        );
        
        -- Parse JSON vào table (SQL Server 2016+ có OPENJSON)
        INSERT INTO @ScoreTable (assignment_id, student_id, enrollment_id, score, status, notes)
        SELECT 
            assignmentId,
            studentId,
            enrollmentId,
            score,
            ISNULL([status], 'ATTENDED'),
            ISNULL(notes, '')
        FROM OPENJSON(@Scores)
        WITH (
            assignmentId VARCHAR(50) '$.assignmentId',
            studentId VARCHAR(50) '$.studentId',
            enrollmentId VARCHAR(50) '$.enrollmentId',
            score DECIMAL(4,2) '$.score',
            [status] NVARCHAR(20) '$.status',
            notes NVARCHAR(500) '$.notes'
        );
        
        -- Update exam_assignments status và notes
        UPDATE ea
        SET 
            ea.status = st.status,
            ea.notes = ISNULL(st.notes, ea.notes)
        FROM dbo.exam_assignments ea
        INNER JOIN @ScoreTable st ON ea.assignment_id = st.assignment_id
        WHERE ea.exam_id = @ExamId
            AND ea.deleted_at IS NULL;
        
        -- Update grades table: gán điểm vào midterm_score hoặc final_score tùy theo exam_type
        -- Tìm grade từ enrollment_id
        IF @ExamType = 'GIỮA_HỌC_PHẦN'
        BEGIN
            -- Gán vào midterm_score
            UPDATE g
            SET 
                g.midterm_score = st.score,
                g.updated_at = GETDATE(),
                g.updated_by = @EnteredBy
            FROM dbo.grades g
            INNER JOIN @ScoreTable st ON g.enrollment_id = st.enrollment_id
            WHERE st.status = 'ATTENDED' AND st.score >= 0 AND st.score <= 10;
            
            -- Cập nhật total_score bằng cách gọi stored procedure tính điểm (nếu có)
            -- Hoặc tính trực tiếp nếu biết công thức
            -- Tạm thời chỉ cập nhật midterm_score, total_score sẽ được tính sau
        END
        ELSE IF @ExamType = 'KẾT_THÚC_HỌC_PHẦN'
        BEGIN
            -- Gán vào final_score
            UPDATE g
            SET 
                g.final_score = st.score,
                g.updated_at = GETDATE(),
                g.updated_by = @EnteredBy
            FROM dbo.grades g
            INNER JOIN @ScoreTable st ON g.enrollment_id = st.enrollment_id
            WHERE st.status = 'ATTENDED' AND st.score >= 0 AND st.score <= 10;
            
            -- Cập nhật total_score sau
        END
        
        -- Đánh dấu sinh viên vắng thi (status = ABSENT hoặc EXCUSED)
        UPDATE ea
        SET ea.status = st.status
        FROM dbo.exam_assignments ea
        INNER JOIN @ScoreTable st ON ea.assignment_id = st.assignment_id
        WHERE ea.exam_id = @ExamId
            AND st.status IN ('ABSENT', 'EXCUSED');
        
        -- Update exam_schedules status to COMPLETED
        UPDATE dbo.exam_schedules
        SET 
            status = 'COMPLETED',
            updated_at = GETDATE(),
            updated_by = @EnteredBy
        WHERE exam_id = @ExamId;
        
        COMMIT TRANSACTION;
        
        -- Return success
        SELECT @ExamId as exam_id, 'SUCCESS' as result;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT '✓ Created stored procedure: sp_EnterExamScores';
GO

-- ===========================================
-- 12. SP_GETEXAMSCORES - Lấy danh sách điểm đã nhập cho kỳ thi
-- ===========================================

IF OBJECT_ID('sp_GetExamScores', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetExamScores;
GO

CREATE PROCEDURE sp_GetExamScores
    @ExamId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        SELECT 
            ea.assignment_id,
            ea.exam_id,
            ea.enrollment_id,
            ea.student_id,
            s.student_code,
            s.full_name as student_name,
            ea.seat_number,
            ea.status,
            ea.notes,
            -- Lấy điểm từ grades table
            CASE 
                WHEN es.exam_type = 'GIỮA_HỌC_PHẦN' THEN g.midterm_score
                WHEN es.exam_type = 'KẾT_THÚC_HỌC_PHẦN' THEN g.final_score
                ELSE NULL
            END as score,
            es.exam_type,
            es.exam_date,
            es.exam_time,
            es.end_time
        FROM dbo.exam_assignments ea
        INNER JOIN dbo.exam_schedules es ON ea.exam_id = es.exam_id
        INNER JOIN dbo.students s ON ea.student_id = s.student_id
        LEFT JOIN dbo.grades g ON ea.enrollment_id = g.enrollment_id
        WHERE ea.exam_id = @ExamId
            AND ea.deleted_at IS NULL
            AND es.deleted_at IS NULL
        ORDER BY ea.seat_number, s.student_code;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @ErrorMessage, 1;
    END CATCH
END
GO

PRINT '✓ Created stored procedure: sp_GetExamScores';
GO

PRINT '';
PRINT '========================================';
PRINT '✅ STORED PROCEDURES FOR EXAM SCHEDULES COMPLETED!';
PRINT '========================================';
PRINT '';

