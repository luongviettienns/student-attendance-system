using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using EducationManagement.Common.Models;

namespace EducationManagement.DAL.Repositories
{
    public class EnrollmentRepository
    {
        private readonly string _connectionString;

        public EnrollmentRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new ArgumentNullException("Connection string 'DefaultConnection' not found.");
        }

        public async Task<List<Enrollment>> GetAllAsync()
        {
            var enrollments = new List<Enrollment>();
            var dt = await DatabaseHelper.ExecuteQueryAsync(_connectionString, "sp_GetAllEnrollments");

            foreach (DataRow row in dt.Rows)
                enrollments.Add(MapToEnrollment(row));

            return enrollments;
        }

        public async Task<Enrollment?> GetByIdAsync(string enrollmentId)
        {
            var param = new SqlParameter("@EnrollmentId", enrollmentId);
            var dt = await DatabaseHelper.ExecuteQueryAsync(_connectionString, "sp_GetEnrollmentById", param);

            if (dt.Rows.Count == 0)
                return null;

            return MapToEnrollment(dt.Rows[0]);
        }

        public async Task<List<Enrollment>> GetByStudentIdAsync(string studentId)
        {
            var enrollments = new List<Enrollment>();
            var param = new SqlParameter("@StudentId", studentId);
            var dt = await DatabaseHelper.ExecuteQueryAsync(_connectionString, "sp_GetEnrollmentsByStudent", param);

            foreach (DataRow row in dt.Rows)
                enrollments.Add(MapToEnrollment(row));

            return enrollments;
        }

        public async Task<List<Enrollment>> GetByClassIdAsync(string classId)
        {
            var enrollments = new List<Enrollment>();
            var param = new SqlParameter("@ClassId", classId);
            var dt = await DatabaseHelper.ExecuteQueryAsync(_connectionString, "sp_GetEnrollmentsByClass", param);

            foreach (DataRow row in dt.Rows)
                enrollments.Add(MapToEnrollment(row));

            return enrollments;
        }

        private static Enrollment MapToEnrollment(DataRow row)
        {
            return new Enrollment
            {
                EnrollmentId = row["enrollment_id"].ToString()!,
                StudentId = row["student_id"].ToString()!,
                ClassId = row["class_id"].ToString()!,
                EnrollmentDate = Convert.ToDateTime(row["enrollment_date"]),
                Status = row["status"]?.ToString() ?? "Active",
                DroppedDate = row["dropped_date"] == DBNull.Value ? null : Convert.ToDateTime(row["dropped_date"]),
                DroppedReason = row["dropped_reason"]?.ToString(),
                CreatedAt = row["created_at"] == DBNull.Value ? DateTime.Now : Convert.ToDateTime(row["created_at"]),
                CreatedBy = row["created_by"]?.ToString(),
                UpdatedAt = row["updated_at"] == DBNull.Value ? null : Convert.ToDateTime(row["updated_at"]),
                UpdatedBy = row["updated_by"]?.ToString()
            };
        }
    }
}

