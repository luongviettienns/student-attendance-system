-- Education Management Database Script
-- Create database
USE master;
GO

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'EducationManagement')
BEGIN
    CREATE DATABASE EducationManagement;
END
GO

USE EducationManagement;
GO

-- Create tables

-- Users table (extended from BanOto)
CREATE TABLE [dbo].[users](
    [user_id] [varchar](50) NOT NULL,
    [hoten] [nvarchar](150) NULL,
    [ngaysinh] [date] NULL,
    [diachi] [nvarchar](250) NULL,
    [gioitinh] [nvarchar](30) NULL,
    [email] [varchar](150) NULL,
    [taikhoan] [varchar](30) NULL,
    [matkhau] [varchar](255) NULL,
    [role] [varchar](30) NULL,
    [image_url] [varchar](300) NULL,
    [student_code] [varchar](20) NULL,
    [faculty_id] [varchar](50) NULL,
    [major] [varchar](100) NULL,
    [academic_year] [varchar](10) NULL,
    [phone] [varchar](15) NULL,
    [is_active] [bit] NOT NULL DEFAULT 1,
    [created_date] [datetime] NOT NULL DEFAULT GETDATE(),
    CONSTRAINT [PK_users] PRIMARY KEY CLUSTERED ([user_id] ASC)
);

-- Subjects table
CREATE TABLE [dbo].[subjects](
    [subject_id] [varchar](50) NOT NULL,
    [subject_code] [varchar](20) NOT NULL,
    [subject_name] [nvarchar](200) NOT NULL,
    [credits] [int] NOT NULL,
    [description] [nvarchar](500) NULL,
    [is_active] [bit] NOT NULL DEFAULT 1,
    [created_date] [datetime] NOT NULL DEFAULT GETDATE(),
    [created_by] [varchar](50) NULL,
    CONSTRAINT [PK_subjects] PRIMARY KEY CLUSTERED ([subject_id] ASC),
    CONSTRAINT [UQ_subjects_code] UNIQUE ([subject_code])
);

-- Classes table
CREATE TABLE [dbo].[classes](
    [class_id] [varchar](50) NOT NULL,
    [class_code] [varchar](20) NOT NULL,
    [class_name] [nvarchar](200) NOT NULL,
    [subject_id] [varchar](50) NOT NULL,
    [lecturer_id] [varchar](50) NOT NULL,
    [semester] [varchar](20) NOT NULL,
    [academic_year] [varchar](10) NOT NULL,
    [max_students] [int] NOT NULL DEFAULT 50,
    [is_active] [bit] NOT NULL DEFAULT 1,
    [created_date] [datetime] NOT NULL DEFAULT GETDATE(),
    [created_by] [varchar](50) NULL,
    CONSTRAINT [PK_classes] PRIMARY KEY CLUSTERED ([class_id] ASC),
    CONSTRAINT [UQ_classes_code] UNIQUE ([class_code]),
    CONSTRAINT [FK_classes_subjects] FOREIGN KEY ([subject_id]) REFERENCES [subjects]([subject_id]),
    CONSTRAINT [FK_classes_users] FOREIGN KEY ([lecturer_id]) REFERENCES [users]([user_id])
);

-- Schedules table
CREATE TABLE [dbo].[schedules](
    [schedule_id] [varchar](50) NOT NULL,
    [class_id] [varchar](50) NOT NULL,
    [room] [nvarchar](50) NULL,
    [start_time] [datetime] NOT NULL,
    [end_time] [datetime] NOT NULL,
    [day_of_week] [varchar](10) NULL,
    [schedule_type] [varchar](20) NOT NULL DEFAULT 'Lecture',
    [is_active] [bit] NOT NULL DEFAULT 1,
    [created_date] [datetime] NOT NULL DEFAULT GETDATE(),
    [created_by] [varchar](50) NULL,
    CONSTRAINT [PK_schedules] PRIMARY KEY CLUSTERED ([schedule_id] ASC),
    CONSTRAINT [FK_schedules_classes] FOREIGN KEY ([class_id]) REFERENCES [classes]([class_id])
);

-- Enrollments table
CREATE TABLE [dbo].[enrollments](
    [enrollment_id] [varchar](50) NOT NULL,
    [student_id] [varchar](50) NOT NULL,
    [class_id] [varchar](50) NOT NULL,
    [enrollment_date] [datetime] NOT NULL DEFAULT GETDATE(),
    [status] [varchar](20) NOT NULL DEFAULT 'Active',
    [semester] [varchar](20) NOT NULL,
    [academic_year] [varchar](10) NOT NULL,
    [dropped_date] [datetime] NULL,
    [dropped_reason] [nvarchar](500) NULL,
    CONSTRAINT [PK_enrollments] PRIMARY KEY CLUSTERED ([enrollment_id] ASC),
    CONSTRAINT [FK_enrollments_users] FOREIGN KEY ([student_id]) REFERENCES [users]([user_id]),
    CONSTRAINT [FK_enrollments_classes] FOREIGN KEY ([class_id]) REFERENCES [classes]([class_id]),
    CONSTRAINT [UQ_enrollments_student_class] UNIQUE ([student_id], [class_id])
);

-- Attendances table
CREATE TABLE [dbo].[attendances](
    [attendance_id] [varchar](50) NOT NULL,
    [student_id] [varchar](50) NOT NULL,
    [schedule_id] [varchar](50) NOT NULL,
    [attendance_date] [datetime] NOT NULL,
    [status] [varchar](20) NOT NULL,
    [notes] [nvarchar](500) NULL,
    [marked_by] [varchar](50) NULL,
    [marked_at] [datetime] NOT NULL DEFAULT GETDATE(),
    CONSTRAINT [PK_attendances] PRIMARY KEY CLUSTERED ([attendance_id] ASC),
    CONSTRAINT [FK_attendances_users] FOREIGN KEY ([student_id]) REFERENCES [users]([user_id]),
    CONSTRAINT [FK_attendances_schedules] FOREIGN KEY ([schedule_id]) REFERENCES [schedules]([schedule_id]),
    CONSTRAINT [FK_attendances_marked_by] FOREIGN KEY ([marked_by]) REFERENCES [users]([user_id])
);

-- Grades table
CREATE TABLE [dbo].[grades](
    [grade_id] [varchar](50) NOT NULL,
    [student_id] [varchar](50) NOT NULL,
    [class_id] [varchar](50) NOT NULL,
    [grade_type] [varchar](20) NOT NULL,
    [score] [decimal](5,2) NOT NULL,
    [max_score] [decimal](5,2) NOT NULL,
    [weight] [decimal](5,2) NOT NULL DEFAULT 1.0,
    [notes] [nvarchar](500) NULL,
    [graded_by] [varchar](50) NULL,
    [graded_at] [datetime] NOT NULL DEFAULT GETDATE(),
    [is_final] [bit] NOT NULL DEFAULT 0,
    CONSTRAINT [PK_grades] PRIMARY KEY CLUSTERED ([grade_id] ASC),
    CONSTRAINT [FK_grades_users] FOREIGN KEY ([student_id]) REFERENCES [users]([user_id]),
    CONSTRAINT [FK_grades_classes] FOREIGN KEY ([class_id]) REFERENCES [classes]([class_id]),
    CONSTRAINT [FK_grades_graded_by] FOREIGN KEY ([graded_by]) REFERENCES [users]([user_id])
);

-- Appeals table
CREATE TABLE [dbo].[appeals](
    [appeal_id] [varchar](50) NOT NULL,
    [student_id] [varchar](50) NOT NULL,
    [grade_id] [varchar](50) NOT NULL,
    [reason] [nvarchar](1000) NOT NULL,
    [status] [varchar](20) NOT NULL DEFAULT 'Pending',
    [reviewed_by] [varchar](50) NULL,
    [reviewed_at] [datetime] NULL,
    [review_notes] [nvarchar](1000) NULL,
    [created_date] [datetime] NOT NULL DEFAULT GETDATE(),
    CONSTRAINT [PK_appeals] PRIMARY KEY CLUSTERED ([appeal_id] ASC),
    CONSTRAINT [FK_appeals_users] FOREIGN KEY ([student_id]) REFERENCES [users]([user_id]),
    CONSTRAINT [FK_appeals_grades] FOREIGN KEY ([grade_id]) REFERENCES [grades]([grade_id]),
    CONSTRAINT [FK_appeals_reviewed_by] FOREIGN KEY ([reviewed_by]) REFERENCES [users]([user_id])
);

-- Notifications table
CREATE TABLE [dbo].[notifications](
    [notification_id] [varchar](50) NOT NULL,
    [recipient_id] [varchar](50) NOT NULL,
    [title] [nvarchar](200) NOT NULL,
    [content] [nvarchar](2000) NOT NULL,
    [type] [varchar](20) NOT NULL,
    [is_read] [bit] NOT NULL DEFAULT 0,
    [created_date] [datetime] NOT NULL DEFAULT GETDATE(),
    [sent_date] [datetime] NULL,
    [created_by] [varchar](50) NULL,
    CONSTRAINT [PK_notifications] PRIMARY KEY CLUSTERED ([notification_id] ASC),
    CONSTRAINT [FK_notifications_users] FOREIGN KEY ([recipient_id]) REFERENCES [users]([user_id]),
    CONSTRAINT [FK_notifications_created_by] FOREIGN KEY ([created_by]) REFERENCES [users]([user_id])
);

-- Audit logs table
CREATE TABLE [dbo].[audit_logs](
    [log_id] [varchar](50) NOT NULL,
    [user_id] [varchar](50) NULL,
    [action] [varchar](100) NOT NULL,
    [table_name] [varchar](50) NOT NULL,
    [record_id] [varchar](50) NULL,
    [old_values] [nvarchar](max) NULL,
    [new_values] [nvarchar](max) NULL,
    [ip_address] [varchar](50) NULL,
    [user_agent] [nvarchar](500) NULL,
    [created_date] [datetime] NOT NULL DEFAULT GETDATE(),
    CONSTRAINT [PK_audit_logs] PRIMARY KEY CLUSTERED ([log_id] ASC),
    CONSTRAINT [FK_audit_logs_users] FOREIGN KEY ([user_id]) REFERENCES [users]([user_id])
);

-- Create indexes for better performance
CREATE INDEX [IX_users_email] ON [users]([email]);
CREATE INDEX [IX_users_taikhoan] ON [users]([taikhoan]);
CREATE INDEX [IX_users_role] ON [users]([role]);
CREATE INDEX [IX_subjects_code] ON [subjects]([subject_code]);
CREATE INDEX [IX_classes_code] ON [classes]([class_code]);
CREATE INDEX [IX_classes_lecturer] ON [classes]([lecturer_id]);
CREATE INDEX [IX_schedules_class] ON [schedules]([class_id]);
CREATE INDEX [IX_enrollments_student] ON [enrollments]([student_id]);
CREATE INDEX [IX_enrollments_class] ON [enrollments]([class_id]);
CREATE INDEX [IX_attendances_student] ON [attendances]([student_id]);
CREATE INDEX [IX_attendances_schedule] ON [attendances]([schedule_id]);
CREATE INDEX [IX_grades_student] ON [grades]([student_id]);
CREATE INDEX [IX_grades_class] ON [grades]([class_id]);
CREATE INDEX [IX_appeals_student] ON [appeals]([student_id]);
CREATE INDEX [IX_notifications_recipient] ON [notifications]([recipient_id]);
CREATE INDEX [IX_audit_logs_user] ON [audit_logs]([user_id]);
CREATE INDEX [IX_audit_logs_table] ON [audit_logs]([table_name]);

-- Insert default admin user
INSERT INTO [users] ([user_id], [hoten], [email], [taikhoan], [matkhau], [role], [is_active])
VALUES ('admin-001', 'System Administrator', 'admin@education.com', 'admin', '$2a$11$rQZ8K7vJ8K7vJ8K7vJ8K7u', 'Admin', 1);

-- Insert sample subjects
INSERT INTO [subjects] ([subject_id], [subject_code], [subject_name], [credits], [description], [created_by])
VALUES 
('subj-001', 'CS101', 'Introduction to Computer Science', 3, 'Basic concepts of computer science', 'admin-001'),
('subj-002', 'MATH101', 'Calculus I', 4, 'Differential and integral calculus', 'admin-001'),
('subj-003', 'ENG101', 'English Composition', 3, 'Basic English writing skills', 'admin-001'),
('subj-004', 'PHYS101', 'Physics I', 4, 'Mechanics and thermodynamics', 'admin-001'),
('subj-005', 'CHEM101', 'General Chemistry', 4, 'Basic chemistry concepts', 'admin-001');

-- Insert sample lecturers
INSERT INTO [users] ([user_id], [hoten], [email], [taikhoan], [matkhau], [role], [is_active], [created_by])
VALUES 
('lect-001', 'Dr. John Smith', 'john.smith@education.com', 'jsmith', '$2a$11$rQZ8K7vJ8K7vJ8K7vJ8K7u', 'Lecturer', 1, 'admin-001'),
('lect-002', 'Dr. Jane Doe', 'jane.doe@education.com', 'jdoe', '$2a$11$rQZ8K7vJ8K7vJ8K7vJ8K7u', 'Lecturer', 1, 'admin-001'),
('lect-003', 'Prof. Mike Johnson', 'mike.johnson@education.com', 'mjohnson', '$2a$11$rQZ8K7vJ8K7vJ8K7vJ8K7u', 'Lecturer', 1, 'admin-001');

-- Insert sample classes
INSERT INTO [classes] ([class_id], [class_code], [class_name], [subject_id], [lecturer_id], [semester], [academic_year], [created_by])
VALUES 
('class-001', 'CS101-01', 'CS101 Section 1', 'subj-001', 'lect-001', 'Fall 2024', '2024-2025', 'admin-001'),
('class-002', 'MATH101-01', 'MATH101 Section 1', 'subj-002', 'lect-002', 'Fall 2024', '2024-2025', 'admin-001'),
('class-003', 'ENG101-01', 'ENG101 Section 1', 'subj-003', 'lect-003', 'Fall 2024', '2024-2025', 'admin-001');

-- Insert sample schedules
INSERT INTO [schedules] ([schedule_id], [class_id], [room], [start_time], [end_time], [day_of_week], [schedule_type], [created_by])
VALUES 
('sched-001', 'class-001', 'Room 101', '2024-09-15 08:00:00', '2024-09-15 09:30:00', 'Monday', 'Lecture', 'admin-001'),
('sched-002', 'class-001', 'Room 101', '2024-09-17 08:00:00', '2024-09-17 09:30:00', 'Wednesday', 'Lecture', 'admin-001'),
('sched-003', 'class-002', 'Room 201', '2024-09-15 10:00:00', '2024-09-15 11:30:00', 'Monday', 'Lecture', 'admin-001'),
('sched-004', 'class-003', 'Room 301', '2024-09-16 14:00:00', '2024-09-16 15:30:00', 'Tuesday', 'Lecture', 'admin-001');

PRINT 'Database and tables created successfully!';



