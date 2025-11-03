using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using EducationManagement.Common.Models;

namespace EducationManagement.DAL.Repositories
{
    public class AttendanceRepository
    {
        private readonly string _connectionString;

        public AttendanceRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new ArgumentNullException("Connection string 'DefaultConnection' not found.");
        }

        /// <summary>
        /// Lấy tất cả attendance records
        /// </summary>
        public async Task<List<Attendance>> GetAllAsync()
        {
            var attendances = new List<Attendance>();

            var dt = await DatabaseHelper.ExecuteQueryAsync(_connectionString, "sp_GetAllAttendances");

            foreach (DataRow row in dt.Rows)
            {
                attendances.Add(MapToAttendance(row));
            }

            return attendances;
        }

        /// <summary>
        /// Lấy attendance theo ID
        /// </summary>
        public async Task<Attendance?> GetByIdAsync(string attendanceId)
        {
            var param = new SqlParameter("@AttendanceId", attendanceId);
            var dt = await DatabaseHelper.ExecuteQueryAsync(_connectionString, "sp_GetAttendanceById", param);

            if (dt.Rows.Count == 0)
                return null;

            return MapToAttendance(dt.Rows[0]);
        }

        /// <summary>
        /// Tạo attendance record mới
        /// </summary>
        public async Task<string> CreateAsync(string attendanceId, string enrollmentId, string classId,
            DateTime attendanceDate, string status, string? note, string? scheduleId, string createdBy)
        {
            var parameters = new[]
            {
                new SqlParameter("@AttendanceId", attendanceId),
                new SqlParameter("@EnrollmentId", enrollmentId),
                new SqlParameter("@ClassId", classId),
                new SqlParameter("@AttendanceDate", attendanceDate),
                new SqlParameter("@Status", status),
                new SqlParameter("@Note", (object?)note ?? DBNull.Value),
                new SqlParameter("@ScheduleId", (object?)scheduleId ?? DBNull.Value),
                new SqlParameter("@CreatedBy", createdBy)
            };

            var result = await DatabaseHelper.ExecuteScalarAsync(_connectionString, "sp_CreateAttendance", parameters);
            return result?.ToString() ?? attendanceId;
        }

        /// <summary>
        /// Cập nhật attendance
        /// </summary>
        public async Task UpdateAsync(string attendanceId, string status, string? note, string updatedBy)
        {
            var parameters = new[]
            {
                new SqlParameter("@AttendanceId", attendanceId),
                new SqlParameter("@Status", status),
                new SqlParameter("@Note", (object?)note ?? DBNull.Value),
                new SqlParameter("@UpdatedBy", updatedBy)
            };

            await DatabaseHelper.ExecuteNonQueryAsync(_connectionString, "sp_UpdateAttendance", parameters);
        }

        /// <summary>
        /// Xóa attendance (soft delete)
        /// </summary>
        public async Task DeleteAsync(string attendanceId, string deletedBy)
        {
            var parameters = new[]
            {
                new SqlParameter("@AttendanceId", attendanceId),
                new SqlParameter("@DeletedBy", deletedBy)
            };

            await DatabaseHelper.ExecuteNonQueryAsync(_connectionString, "sp_DeleteAttendance", parameters);
        }

        /// <summary>
        /// Lấy attendances theo student ID
        /// </summary>
        public async Task<List<Attendance>> GetByStudentIdAsync(string studentId)
        {
            var attendances = new List<Attendance>();
            var param = new SqlParameter("@StudentId", studentId);

            var dt = await DatabaseHelper.ExecuteQueryAsync(_connectionString, "sp_GetAttendancesByStudent", param);

            foreach (DataRow row in dt.Rows)
            {
                attendances.Add(MapToAttendance(row));
            }

            return attendances;
        }

        /// <summary>
        /// Lấy attendances theo schedule ID
        /// </summary>
        public async Task<List<Attendance>> GetByScheduleIdAsync(string scheduleId)
        {
            var attendances = new List<Attendance>();
            var param = new SqlParameter("@ScheduleId", scheduleId);

            var dt = await DatabaseHelper.ExecuteQueryAsync(_connectionString, "sp_GetAttendancesBySchedule", param);

            foreach (DataRow row in dt.Rows)
            {
                attendances.Add(MapToAttendance(row));
            }

            return attendances;
        }

        /// <summary>
        /// Lấy attendances theo class ID
        /// </summary>
        public async Task<List<Attendance>> GetByClassIdAsync(string classId, DateTime? attendanceDate = null)
        {
            var attendances = new List<Attendance>();
            var parameters = new[]
            {
                new SqlParameter("@ClassId", classId),
                new SqlParameter("@AttendanceDate", (object?)attendanceDate?.Date ?? DBNull.Value)
            };

            var dt = await DatabaseHelper.ExecuteQueryAsync(_connectionString, "sp_GetAttendancesByClass", parameters);

            foreach (DataRow row in dt.Rows)
            {
                attendances.Add(MapToAttendance(row));
            }

            return attendances;
        }

        /// <summary>
        /// Map DataRow to Attendance model
        /// </summary>
        private static Attendance MapToAttendance(DataRow row)
        {
            return new Attendance
            {
                AttendanceId = row["attendance_id"].ToString()!,
                EnrollmentId = row.Table.Columns.Contains("enrollment_id") ? row["enrollment_id"].ToString()! : string.Empty,
                ClassId = row.Table.Columns.Contains("class_id") ? row["class_id"].ToString()! : string.Empty,
                StudentId = row.Table.Columns.Contains("student_id") ? row["student_id"]?.ToString() : null,
                StudentCode = row.Table.Columns.Contains("student_code") ? row["student_code"]?.ToString() : null,
                StudentName = row.Table.Columns.Contains("student_name") ? row["student_name"]?.ToString() : null,
                ScheduleId = row.Table.Columns.Contains("schedule_id") ? row["schedule_id"]?.ToString() : null,
                AttendanceDate = row.Table.Columns.Contains("attendance_date") && row["attendance_date"] != DBNull.Value 
                    ? Convert.ToDateTime(row["attendance_date"]) 
                    : DateTime.Now,
                Status = row["status"].ToString()!,
                Note = row.Table.Columns.Contains("note") ? row["note"]?.ToString() : null,
                ClassName = row.Table.Columns.Contains("class_name") ? row["class_name"]?.ToString() : null,
                SubjectName = row.Table.Columns.Contains("subject_name") ? row["subject_name"]?.ToString() : null,
                Room = row.Table.Columns.Contains("room") ? row["room"]?.ToString() : null,
                ScheduleStartTime = row.Table.Columns.Contains("schedule_start_time") && row["schedule_start_time"] != DBNull.Value
                    ? Convert.ToDateTime(row["schedule_start_time"])
                    : (DateTime?)null,
                MarkedBy = row.Table.Columns.Contains("marked_by") ? row["marked_by"]?.ToString() : null,
                MarkedByName = row.Table.Columns.Contains("marked_by_name") ? row["marked_by_name"]?.ToString() : null,
                IsActive = row.Table.Columns.Contains("is_active") && row["is_active"] != DBNull.Value
                    ? Convert.ToBoolean(row["is_active"])
                    : true,
                CreatedAt = row.Table.Columns.Contains("created_at") && row["created_at"] != DBNull.Value 
                    ? Convert.ToDateTime(row["created_at"]) 
                    : DateTime.Now,
                CreatedBy = row.Table.Columns.Contains("created_by") ? row["created_by"]?.ToString() : null,
                UpdatedAt = row.Table.Columns.Contains("updated_at") && row["updated_at"] != DBNull.Value 
                    ? Convert.ToDateTime(row["updated_at"]) 
                    : (DateTime?)null,
                UpdatedBy = row.Table.Columns.Contains("updated_by") ? row["updated_by"]?.ToString() : null,
                DeletedAt = row.Table.Columns.Contains("deleted_at") && row["deleted_at"] != DBNull.Value
                    ? Convert.ToDateTime(row["deleted_at"])
                    : null,
                DeletedBy = row.Table.Columns.Contains("deleted_by") ? row["deleted_by"]?.ToString() : null
            };
        }
    }
}

