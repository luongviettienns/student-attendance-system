using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using EducationManagement.Common.Models;

namespace EducationManagement.DAL.Repositories
{
    public class ScheduleRepository
    {
        private readonly string _connectionString;

        public ScheduleRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new ArgumentNullException("Connection string 'DefaultConnection' not found.");
        }

        public async Task<List<Schedule>> GetAllAsync()
        {
            var schedules = new List<Schedule>();
            var dt = await DatabaseHelper.ExecuteQueryAsync(_connectionString, "sp_GetAllSchedules");

            foreach (DataRow row in dt.Rows)
                schedules.Add(MapToSchedule(row));

            return schedules;
        }

        public async Task<Schedule?> GetByIdAsync(string scheduleId)
        {
            var param = new SqlParameter("@ScheduleId", scheduleId);
            var dt = await DatabaseHelper.ExecuteQueryAsync(_connectionString, "sp_GetScheduleById", param);

            if (dt.Rows.Count == 0)
                return null;

            return MapToSchedule(dt.Rows[0]);
        }

        public async Task<List<Schedule>> GetByClassIdAsync(string classId)
        {
            var schedules = new List<Schedule>();
            var param = new SqlParameter("@ClassId", classId);
            var dt = await DatabaseHelper.ExecuteQueryAsync(_connectionString, "sp_GetSchedulesByClass", param);

            foreach (DataRow row in dt.Rows)
                schedules.Add(MapToSchedule(row));

            return schedules;
        }

        private static Schedule MapToSchedule(DataRow row)
        {
            return new Schedule
            {
                ScheduleId = row["schedule_id"].ToString()!,
                ClassId = row["class_id"].ToString()!,
                Room = row.Table.Columns.Contains("room") ? row["room"]?.ToString() : null,
                DayOfWeek = row.Table.Columns.Contains("day_of_week") ? row["day_of_week"]?.ToString() : null,
                StartTime = row.Table.Columns.Contains("start_time") ? Convert.ToDateTime(row["start_time"]) : DateTime.Now,
                EndTime = row.Table.Columns.Contains("end_time") ? Convert.ToDateTime(row["end_time"]) : DateTime.Now,
                ScheduleType = row.Table.Columns.Contains("schedule_type") ? (row["schedule_type"]?.ToString() ?? "Lecture") : "Lecture",
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
                UpdatedBy = row.Table.Columns.Contains("updated_by") ? row["updated_by"]?.ToString() : null
            };
        }
    }
}

