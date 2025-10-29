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
    public class DepartmentRepository
    {
        private readonly string _connectionString;

        public DepartmentRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new ArgumentNullException("Connection string 'DefaultConnection' not found.");
        }

        // ============================================================
        // 🔹 LẤY DANH SÁCH BỘ MÔN (ACTIVE)
        // ============================================================
        public async Task<List<Department>> GetAllAsync()
        {
            var ds = await DatabaseHelper.ExecuteQueryMultipleAsync(_connectionString, "sp_GetAllDepartments");
            var list = new List<Department>();

            // Table[0] = TotalCount, Table[1] = Data
            if (ds.Tables.Count > 1 && ds.Tables[1].Rows.Count > 0)
            {
                foreach (DataRow row in ds.Tables[1].Rows)
                    list.Add(MapToDepartment(row));
            }

            return list;
        }

        // ============================================================
        // 🔹 LẤY BỘ MÔN THEO ID
        // ============================================================
        public async Task<Department?> GetByIdAsync(string departmentId)
        {
            var param = new SqlParameter("@DepartmentId", departmentId);
            var dt = await DatabaseHelper.ExecuteQueryAsync(_connectionString, "sp_GetDepartmentById", param);

            if (dt.Rows.Count == 0)
                return null;

            return MapToDepartment(dt.Rows[0]);
        }

        // ============================================================
        // 🔹 THÊM MỚI BỘ MÔN
        // ============================================================
        public async Task AddAsync(Department department)
        {
            var parameters = new[]
            {
                new SqlParameter("@DepartmentId", department.DepartmentId),
                new SqlParameter("@DepartmentCode", department.DepartmentCode),
                new SqlParameter("@DepartmentName", department.DepartmentName),
                new SqlParameter("@FacultyId", department.FacultyId),
                new SqlParameter("@Description", (object?)department.Description ?? DBNull.Value),
                new SqlParameter("@CreatedBy", department.CreatedBy ?? "system")
            };

            await DatabaseHelper.ExecuteNonQueryAsync(_connectionString, "sp_CreateDepartment", parameters);
        }

        // ============================================================
        // 🔹 CẬP NHẬT BỘ MÔN
        // ============================================================
        public async Task<int> UpdateAsync(Department department)
        {
            var parameters = new[]
            {
                new SqlParameter("@DepartmentId", department.DepartmentId),
                new SqlParameter("@DepartmentCode", department.DepartmentCode),
                new SqlParameter("@DepartmentName", department.DepartmentName),
                new SqlParameter("@FacultyId", department.FacultyId),
                new SqlParameter("@Description", (object?)department.Description ?? DBNull.Value),
                new SqlParameter("@UpdatedBy", department.UpdatedBy ?? "system")
            };

            return await DatabaseHelper.ExecuteNonQueryAsync(_connectionString, "sp_UpdateDepartment", parameters);
        }

        // ============================================================
        // 🔹 SINH MÃ BỘ MÔN TỰ ĐỘNG (DEPT001, DEPT002...)
        // ============================================================
        public async Task<string> GenerateNextCodeAsync()
        {
            var sql = "SELECT dbo.fn_GenerateNextDepartmentCode()";
            var dt = await DatabaseHelper.ExecuteQueryAsync(_connectionString, sql);
            
            if (dt.Rows.Count > 0)
            {
                return dt.Rows[0][0].ToString() ?? "DEPT001";
            }
            
            return "DEPT001";
        }

        // ============================================================
        // 🔹 XOÁ MỀM (SOFT DELETE)
        // ============================================================
        public async Task DeleteAsync(string departmentId)
        {
            var parameters = new[]
            {
                new SqlParameter("@DepartmentId", departmentId),
                new SqlParameter("@DeletedBy", "System") // TODO: Lấy từ context user
            };

            await DatabaseHelper.ExecuteNonQueryAsync(_connectionString, "sp_DeleteDepartment", parameters);
        }

        // ============================================================
        // 🔹 MAP DỮ LIỆU DataRow → Department
        // ============================================================
        private static Department MapToDepartment(DataRow row)
        {
            return new Department
            {
                DepartmentId = row["department_id"].ToString()!,
                // Database không có department_code, dùng department_id làm code
                DepartmentCode = row.Table.Columns.Contains("department_code") 
                    ? row["department_code"]?.ToString() ?? ""
                    : row["department_id"].ToString()!,
                DepartmentName = row["department_name"].ToString()!,
                FacultyId = row["faculty_id"].ToString()!,
                FacultyName = row.Table.Columns.Contains("faculty_name") 
                    ? row["faculty_name"]?.ToString() 
                    : null,
                Description = row.Table.Columns.Contains("description") ? row["description"]?.ToString() : null,
                IsActive = row.Table.Columns.Contains("is_active") && row["is_active"] != DBNull.Value
                    ? Convert.ToBoolean(row["is_active"])
                    : true,
                CreatedAt = row.Table.Columns.Contains("created_at") && row["created_at"] != DBNull.Value 
                    ? Convert.ToDateTime(row["created_at"]) 
                    : (DateTime?)null,
                CreatedBy = row.Table.Columns.Contains("created_by") ? row["created_by"]?.ToString() : null,
                UpdatedAt = row.Table.Columns.Contains("updated_at") && row["updated_at"] != DBNull.Value 
                    ? Convert.ToDateTime(row["updated_at"]) 
                    : (DateTime?)null,
                UpdatedBy = row.Table.Columns.Contains("updated_by") ? row["updated_by"]?.ToString() : null
            };
        }
    }
}