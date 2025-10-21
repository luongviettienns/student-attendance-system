using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using EducationManagement.Common.Models;

namespace EducationManagement.DAL.Repositories
{
    public class GradeRepository
    {
        private readonly string _connectionString;

        public GradeRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new ArgumentNullException("Connection string 'DefaultConnection' not found.");
        }

        public async Task<List<Grade>> GetAllAsync()
        {
            var grades = new List<Grade>();
            var dt = await DatabaseHelper.ExecuteQueryAsync(_connectionString, "sp_GetAllGrades");

            foreach (DataRow row in dt.Rows)
                grades.Add(MapToGrade(row));

            return grades;
        }

        public async Task<Grade?> GetByIdAsync(string gradeId)
        {
            var param = new SqlParameter("@GradeId", gradeId);
            var dt = await DatabaseHelper.ExecuteQueryAsync(_connectionString, "sp_GetGradeById", param);

            if (dt.Rows.Count == 0)
                return null;

            return MapToGrade(dt.Rows[0]);
        }

        public async Task<string> CreateAsync(string gradeId, string studentId, string classId,
            string gradeType, decimal score, decimal maxScore, decimal weight, string? notes,
            string? gradedBy, string createdBy)
        {
            var parameters = new[]
            {
                new SqlParameter("@GradeId", gradeId),
                new SqlParameter("@StudentId", studentId),
                new SqlParameter("@ClassId", classId),
                new SqlParameter("@GradeType", gradeType),
                new SqlParameter("@Score", score),
                new SqlParameter("@MaxScore", maxScore),
                new SqlParameter("@Weight", weight),
                new SqlParameter("@Notes", (object?)notes ?? DBNull.Value),
                new SqlParameter("@GradedBy", (object?)gradedBy ?? DBNull.Value),
                new SqlParameter("@CreatedBy", createdBy)
            };

            var result = await DatabaseHelper.ExecuteScalarAsync(_connectionString, "sp_CreateGrade", parameters);
            return result?.ToString() ?? gradeId;
        }

        public async Task UpdateAsync(string gradeId, string gradeType, decimal score,
            decimal maxScore, decimal weight, string? notes, string updatedBy)
        {
            var parameters = new[]
            {
                new SqlParameter("@GradeId", gradeId),
                new SqlParameter("@GradeType", gradeType),
                new SqlParameter("@Score", score),
                new SqlParameter("@MaxScore", maxScore),
                new SqlParameter("@Weight", weight),
                new SqlParameter("@Notes", (object?)notes ?? DBNull.Value),
                new SqlParameter("@UpdatedBy", updatedBy)
            };

            await DatabaseHelper.ExecuteNonQueryAsync(_connectionString, "sp_UpdateGrade", parameters);
        }

        public async Task DeleteAsync(string gradeId, string deletedBy)
        {
            var parameters = new[]
            {
                new SqlParameter("@GradeId", gradeId),
                new SqlParameter("@DeletedBy", deletedBy)
            };

            await DatabaseHelper.ExecuteNonQueryAsync(_connectionString, "sp_DeleteGrade", parameters);
        }

        public async Task<List<Grade>> GetByStudentIdAsync(string studentId)
        {
            var grades = new List<Grade>();
            var param = new SqlParameter("@StudentId", studentId);
            var dt = await DatabaseHelper.ExecuteQueryAsync(_connectionString, "sp_GetGradesByStudent", param);

            foreach (DataRow row in dt.Rows)
                grades.Add(MapToGrade(row));

            return grades;
        }

        public async Task<List<Grade>> GetByClassIdAsync(string classId)
        {
            var grades = new List<Grade>();
            var param = new SqlParameter("@ClassId", classId);
            var dt = await DatabaseHelper.ExecuteQueryAsync(_connectionString, "sp_GetGradesByClass", param);

            foreach (DataRow row in dt.Rows)
                grades.Add(MapToGrade(row));

            return grades;
        }

        private static Grade MapToGrade(DataRow row)
        {
            return new Grade
            {
                GradeId = row["grade_id"].ToString()!,
                StudentId = row["student_id"].ToString()!,
                ClassId = row["class_id"].ToString()!,
                GradeType = row["grade_type"].ToString()!,
                Score = row.Table.Columns.Contains("score") ? Convert.ToDecimal(row["score"]) : 0,
                MaxScore = row.Table.Columns.Contains("max_score") ? Convert.ToDecimal(row["max_score"]) : 0,
                Weight = row.Table.Columns.Contains("weight") ? Convert.ToDecimal(row["weight"]) : 0,
                Notes = row.Table.Columns.Contains("notes") ? row["notes"]?.ToString() : null,
                GradedBy = row.Table.Columns.Contains("graded_by") ? row["graded_by"]?.ToString() : null,
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

