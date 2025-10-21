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
        public async Task<string> CreateAsync(string attendanceId, string studentId, string scheduleId,
            DateTime attendanceDate, string status, string? notes, string? markedBy, string createdBy)
        {
            var parameters = new[]
            {
                new SqlParameter("@AttendanceId", attendanceId),
                new SqlParameter("@StudentId", studentId),
                new SqlParameter("@ScheduleId", scheduleId),
                new SqlParameter("@AttendanceDate", attendanceDate),
                new SqlParameter("@Status", status),
                new SqlParameter("@Notes", (object?)notes ?? DBNull.Value),
                new SqlParameter("@MarkedBy", (object?)markedBy ?? DBNull.Value),
                new SqlParameter("@CreatedBy", createdBy)
            };

            var result = await DatabaseHelper.ExecuteScalarAsync(_connectionString, "sp_CreateAttendance", parameters);
            return result?.ToString() ?? attendanceId;
        }

        /// <summary>
        /// Cập nhật attendance
        /// </summary>
        public async Task UpdateAsync(string attendanceId, string status, string? notes, string updatedBy)
        {
            var parameters = new[]
            {
                new SqlParameter("@AttendanceId", attendanceId),
                new SqlParameter("@Status", status),
                new SqlParameter("@Notes", (object?)notes ?? DBNull.Value),
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
        public async Task<List<Attendance>> GetByClassIdAsync(string classId)
        {
            var attendances = new List<Attendance>();
            var param = new SqlParameter("@ClassId", classId);

            var dt = await DatabaseHelper.ExecuteQueryAsync(_connectionString, "sp_GetAttendancesByClass", param);

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
                StudentId = row["student_id"].ToString()!,
                ScheduleId = row["schedule_id"].ToString()!,
                AttendanceDate = row.Table.Columns.Contains("attendance_date") && row["attendance_date"] != DBNull.Value 
                    ? Convert.ToDateTime(row["attendance_date"]) 
                    : DateTime.Now,
                Status = row["status"].ToString()!,
                Notes = row.Table.Columns.Contains("notes") ? row["notes"]?.ToString() : null,
                MarkedBy = row.Table.Columns.Contains("marked_by") ? row["marked_by"]?.ToString() : null,
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

