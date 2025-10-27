using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using EducationManagement.Common.Models;

namespace EducationManagement.DAL.Repositories
{
    public class PermissionRepository
    {
        private readonly string _connectionString;

        public PermissionRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new ArgumentNullException("Connection string 'DefaultConnection' not found.");
        }

        // ============================================================
        // 🔹 1️⃣ LẤY TẤT CẢ PERMISSIONS
        // ============================================================
        public async Task<List<Permission>> GetAllAsync()
        {
            var permissions = new List<Permission>();
            var dt = await DatabaseHelper.ExecuteQueryAsync(_connectionString, "sp_GetAllPermissions");

            foreach (DataRow row in dt.Rows)
                permissions.Add(MapToPermission(row));

            return permissions;
        }

        // ============================================================
        // 🔹 2️⃣ LẤY PERMISSIONS CỦA MỘT ROLE (theo RoleId)
        // ============================================================
        public async Task<List<Permission>> GetByRoleIdAsync(string roleId)
        {
            var permissions = new List<Permission>();
            var param = new SqlParameter("@RoleId", roleId);
            var dt = await DatabaseHelper.ExecuteQueryAsync(_connectionString, "sp_GetPermissionsByRole", param);

            foreach (DataRow row in dt.Rows)
                permissions.Add(MapToPermission(row));

            return permissions;
        }

        // ============================================================
        // 🔹 3️⃣ LẤY PERMISSIONS THEO ROLE NAME (cho Menu)
        // ============================================================
        public async Task<List<Permission>> GetByRoleNameAsync(string roleName)
        {
            var permissions = new List<Permission>();
            var param = new SqlParameter("@RoleName", roleName);
            var dt = await DatabaseHelper.ExecuteQueryAsync(_connectionString, "sp_GetPermissionsByRoleName", param);

            foreach (DataRow row in dt.Rows)
                permissions.Add(MapToPermission(row));

            return permissions;
        }

        // ============================================================
        // 🔹 4️⃣ LẤY DANH SÁCH PERMISSION IDs CỦA ROLE
        // ============================================================
        public async Task<List<string>> GetPermissionIdsByRoleAsync(string roleId)
        {
            var permissionIds = new List<string>();
            var param = new SqlParameter("@RoleId", roleId);
            var dt = await DatabaseHelper.ExecuteQueryAsync(_connectionString, "sp_GetPermissionIdsByRole", param);

            // SP này chỉ trả về permission_id
            foreach (DataRow row in dt.Rows)
            {
                var permId = row["permission_id"]?.ToString();
                if (!string.IsNullOrEmpty(permId))
                    permissionIds.Add(permId);
            }

            return permissionIds;
        }

        // ============================================================
        // 🔹 5️⃣ XOÁ TẤT CẢ PERMISSIONS CỦA ROLE
        // ============================================================
        public async Task DeleteAllByRoleAsync(string roleId)
        {
            var param = new SqlParameter("@RoleId", roleId);
            await DatabaseHelper.ExecuteNonQueryAsync(_connectionString, "sp_DeleteAllPermissionsByRole", param);
        }

        // ============================================================
        // 🔹 6️⃣ THÊM PERMISSION CHO ROLE
        // ============================================================
        public async Task AddRolePermissionAsync(string roleId, string permissionId, string createdBy)
        {
            var parameters = new[]
            {
                new SqlParameter("@RoleId", roleId),
                new SqlParameter("@PermissionId", permissionId),
                new SqlParameter("@CreatedBy", createdBy)
            };

            await DatabaseHelper.ExecuteNonQueryAsync(_connectionString, "sp_AssignPermissionToRole", parameters);
        }

        // ============================================================
        // 🔹 MAP DataRow → Permission MODEL
        // ============================================================
        private static Permission MapToPermission(DataRow row)
        {
            return new Permission
            {
                PermissionId = row["permission_id"].ToString()!,
                PermissionCode = row["permission_code"].ToString()!,
                PermissionName = row["permission_name"].ToString()!,
                Description = row.Table.Columns.Contains("description") ? row["description"]?.ToString() : null,
                CreatedAt = row.Table.Columns.Contains("created_at") && row["created_at"] != DBNull.Value
                    ? Convert.ToDateTime(row["created_at"])
                    : DateTime.Now,
                CreatedBy = row.Table.Columns.Contains("created_by") ? row["created_by"]?.ToString() : null,
                UpdatedAt = row.Table.Columns.Contains("updated_at") && row["updated_at"] != DBNull.Value
                    ? Convert.ToDateTime(row["updated_at"])
                    : null,
                UpdatedBy = row.Table.Columns.Contains("updated_by") ? row["updated_by"]?.ToString() : null
            };
        }
    }
}


