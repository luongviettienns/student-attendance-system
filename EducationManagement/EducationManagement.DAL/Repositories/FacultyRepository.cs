using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using EducationManagement.Common.Models;
using EducationManagement.DAL;

namespace EducationManagement.DAL.Repositories
{
    public class FacultyRepository
    {
        private readonly string _connectionString;

        public FacultyRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new ArgumentNullException("Connection string 'DefaultConnection' not found.");
        }

        // ============================================================
        // 🔹 LẤY DANH SÁCH KHOA (ACTIVE)
        // ============================================================
        public async Task<List<Faculty>> GetAllAsync()
        {
            var dt = await DatabaseHelper.ExecuteQueryAsync(_connectionString, "sp_GetAllFaculties");
            var list = new List<Faculty>();

            foreach (DataRow row in dt.Rows)
                list.Add(MapToFaculty(row));

            return list;
        }

        // ============================================================
        // 🔹 LẤY KHOA THEO ID
        // ============================================================
        public async Task<Faculty?> GetByIdAsync(string facultyId)
        {
            var param = new SqlParameter("@FacultyId", facultyId);
            var dt = await DatabaseHelper.ExecuteQueryAsync(_connectionString, "sp_GetFacultyById", param);

            if (dt.Rows.Count == 0)
                return null;

            return MapToFaculty(dt.Rows[0]);
        }

        // ============================================================
        // 🔹 THÊM MỚI KHOA
        // ============================================================
        public async Task AddAsync(Faculty faculty)
        {
            var parameters = new[]
            {
                new SqlParameter("@FacultyId", faculty.FacultyId),
                new SqlParameter("@FacultyCode", faculty.FacultyCode),
                new SqlParameter("@FacultyName", faculty.FacultyName),
                new SqlParameter("@Description", (object?)faculty.Description ?? DBNull.Value),
                new SqlParameter("@CreatedBy", faculty.CreatedBy)
            };

            await DatabaseHelper.ExecuteNonQueryAsync(_connectionString, "sp_CreateFaculty", parameters);
        }

        // ============================================================
        // 🔹 CẬP NHẬT KHOA
        // ============================================================
        public async Task<int> UpdateAsync(Faculty faculty)
        {
            var parameters = new[]
            {
                new SqlParameter("@FacultyId", faculty.FacultyId),
                new SqlParameter("@FacultyCode", faculty.FacultyCode),
                new SqlParameter("@FacultyName", faculty.FacultyName),
                new SqlParameter("@Description", (object?)faculty.Description ?? DBNull.Value),
                new SqlParameter("@UpdatedBy", faculty.UpdatedBy)
            };

            return await DatabaseHelper.ExecuteNonQueryAsync(_connectionString, "sp_UpdateFaculty", parameters);
        }

        // ============================================================
        // 🔹 XOÁ MỀM (SOFT DELETE)
        // ============================================================
        public async Task DeleteAsync(string facultyId)
        {
            var parameters = new[]
            {
                new SqlParameter("@FacultyId", facultyId),
                new SqlParameter("@DeletedBy", "System") // TODO: Lấy từ context user
            };

            await DatabaseHelper.ExecuteNonQueryAsync(_connectionString, "sp_DeleteFaculty", parameters);
        }

        // ============================================================
        // 🔹 MAP DỮ LIỆU DataRow → Faculty
        // ============================================================
        private static Faculty MapToFaculty(DataRow row)
        {
            var faculty = new Faculty
            {
                FacultyId = row["faculty_id"].ToString()!,
                FacultyCode = row.Table.Columns.Contains("faculty_code") 
                    ? row["faculty_code"]?.ToString() ?? ""
                    : "",
                FacultyName = row["faculty_name"].ToString()!,
                Description = row.Table.Columns.Contains("description") ? row["description"]?.ToString() : null,
                IsActive = row.Table.Columns.Contains("is_active") && row["is_active"] != DBNull.Value
                    ? Convert.ToBoolean(row["is_active"])
                    : true,
                CreatedBy = row.Table.Columns.Contains("created_by") ? row["created_by"]?.ToString() : null,
                UpdatedBy = row.Table.Columns.Contains("updated_by") ? row["updated_by"]?.ToString() : null,
                DeletedBy = row.Table.Columns.Contains("deleted_by") ? row["deleted_by"]?.ToString() : null
            };

            // ✅ Gán giá trị DateTime an toàn, không lỗi kiểu
            faculty.CreatedAt = row.Table.Columns.Contains("created_at") && row["created_at"] != DBNull.Value
                ? Convert.ToDateTime(row["created_at"])
                : DateTime.Now;

            faculty.UpdatedAt = row.Table.Columns.Contains("updated_at") && row["updated_at"] != DBNull.Value
                ? Convert.ToDateTime(row["updated_at"])
                : (DateTime?)null;

            faculty.DeletedAt = row.Table.Columns.Contains("deleted_at") && row["deleted_at"] != DBNull.Value
                ? Convert.ToDateTime(row["deleted_at"])
                : null;

            return faculty;
        }

    }
}
