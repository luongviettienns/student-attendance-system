using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using EducationManagement.Common.Models;

namespace EducationManagement.DAL.Repositories
{
    public class ClassRepository
    {
        private readonly string _connectionString;

        public ClassRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new ArgumentNullException("Connection string 'DefaultConnection' not found.");
        }

        /// <summary>
        /// Lấy tất cả classes
        /// </summary>
        public async Task<List<Class>> GetAllAsync()
        {
            var classes = new List<Class>();

            // sp_GetAllClasses yêu cầu parameters và trả về multiple result sets
            var parameters = new[]
            {
                new SqlParameter("@Page", 1),
                new SqlParameter("@PageSize", 9999), // Get all
                new SqlParameter("@Search", DBNull.Value),
                new SqlParameter("@SubjectId", DBNull.Value),
                new SqlParameter("@LecturerId", DBNull.Value),
                new SqlParameter("@AcademicYearId", DBNull.Value)
            };

            var ds = await DatabaseHelper.ExecuteQueryMultipleAsync(
                _connectionString,
                "sp_GetAllClasses",
                parameters
            );

            // Table[0] = TotalCount, Table[1] = Data
            if (ds.Tables.Count > 1 && ds.Tables[1].Rows.Count > 0)
            {
                foreach (DataRow row in ds.Tables[1].Rows)
                {
                    classes.Add(MapToClass(row));
                }
            }

            return classes;
        }

        /// <summary>
        /// Lấy class theo ID
        /// </summary>
        public async Task<Class?> GetByIdAsync(string classId)
        {
            var param = new SqlParameter("@ClassId", classId);
            var dt = await DatabaseHelper.ExecuteQueryAsync(_connectionString, "sp_GetClassById", param);

            if (dt.Rows.Count == 0)
                return null;

            return MapToClass(dt.Rows[0]);
        }

        /// <summary>
        /// Tạo class mới
        /// </summary>
        public async Task<string> CreateAsync(string classId, string classCode, string className,
            string subjectId, string lecturerId, string semester, string academicYearId,
            int maxStudents, string createdBy)
        {
            var parameters = new[]
            {
                new SqlParameter("@ClassId", classId),
                new SqlParameter("@ClassCode", classCode),
                new SqlParameter("@ClassName", className),
                new SqlParameter("@SubjectId", subjectId),
                new SqlParameter("@LecturerId", lecturerId),
                new SqlParameter("@Semester", semester),
                new SqlParameter("@AcademicYearId", academicYearId),
                new SqlParameter("@MaxStudents", maxStudents),
                new SqlParameter("@CreatedBy", createdBy)
            };

            var result = await DatabaseHelper.ExecuteScalarAsync(_connectionString, "sp_CreateClass", parameters);
            return result?.ToString() ?? classId;
        }

        /// <summary>
        /// Cập nhật class
        /// </summary>
        public async Task UpdateAsync(string classId, string classCode, string className,
            string subjectId, string lecturerId, string semester, string academicYearId,
            int maxStudents, string updatedBy)
        {
            var parameters = new[]
            {
                new SqlParameter("@ClassId", classId),
                new SqlParameter("@ClassCode", classCode),
                new SqlParameter("@ClassName", className),
                new SqlParameter("@SubjectId", subjectId),
                new SqlParameter("@LecturerId", lecturerId),
                new SqlParameter("@Semester", semester),
                new SqlParameter("@AcademicYearId", academicYearId),
                new SqlParameter("@MaxStudents", maxStudents),
                new SqlParameter("@UpdatedBy", updatedBy)
            };

            await DatabaseHelper.ExecuteNonQueryAsync(_connectionString, "sp_UpdateClass", parameters);
        }

        /// <summary>
        /// Xóa class (soft delete)
        /// </summary>
        public async Task DeleteAsync(string classId, string deletedBy)
        {
            var parameters = new[]
            {
                new SqlParameter("@ClassId", classId),
                new SqlParameter("@DeletedBy", deletedBy)
            };

            await DatabaseHelper.ExecuteNonQueryAsync(_connectionString, "sp_DeleteClass", parameters);
        }

        /// <summary>
        /// Lấy classes theo lecturer ID
        /// </summary>
        public async Task<List<Class>> GetByLecturerIdAsync(string lecturerId)
        {
            var classes = new List<Class>();
            var param = new SqlParameter("@LecturerId", lecturerId);

            var dt = await DatabaseHelper.ExecuteQueryAsync(_connectionString, "sp_GetClassesByLecturer", param);

            foreach (DataRow row in dt.Rows)
            {
                classes.Add(MapToClass(row));
            }

            return classes;
        }

        /// <summary>
        /// Lấy classes theo student ID (qua enrollments)
        /// </summary>
        public async Task<List<Class>> GetByStudentIdAsync(string studentId)
        {
            var classes = new List<Class>();
            var param = new SqlParameter("@StudentId", studentId);

            var dt = await DatabaseHelper.ExecuteQueryAsync(_connectionString, "sp_GetClassesByStudent", param);

            foreach (DataRow row in dt.Rows)
            {
                classes.Add(MapToClass(row));
            }

            return classes;
        }

        /// <summary>
        /// Map DataRow to Class model
        /// </summary>
        private static Class MapToClass(DataRow row)
        {
            return new Class
            {
                ClassId = row["class_id"].ToString()!,
                ClassCode = row["class_code"].ToString()!,
                ClassName = row["class_name"].ToString()!,
                SubjectId = row["subject_id"].ToString()!,
                LecturerId = row["lecturer_id"].ToString()!,
                Semester = row["semester"].ToString()!,
                AcademicYearId = row["academic_year_id"].ToString()!,
                MaxStudents = row.Table.Columns.Contains("max_students") ? Convert.ToInt32(row["max_students"]) : 0,
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

